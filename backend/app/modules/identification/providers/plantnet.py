"""Pl@ntNet plant identification provider adapter (KAN-27).

Per docs/03-architecture.md's provider adapter pattern: business logic
depends on the abstract PlantIdentificationProvider interface, not a
concrete vendor — swapping providers later (a fallback/comparison layer
per docs/05-api-matrix.md) means writing a new class here.

API reference: https://my.plantnet.org/doc/api/identify
Confidence-label thresholds (high/moderate/low) below are OUR heuristic
choice — Pl@ntNet only returns a raw 0.0-1.0 score, it doesn't define
label bands itself. Worth revisiting once real identification results
are seen in practice; these are a reasonable starting point, not a
calibrated conclusion.

Rejection handling: per Pl@ntNet's own FAQ, when no plant species is
predicted at all (even at a very low score), the API returns a
"404 Species not found" error — confirmed directly from their docs, not
assumed. That's handled here as a normal "no match" outcome, not an
exception, since it's an expected, documented API behavior the caller
needs to handle gracefully.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass, field

import httpx


@dataclass
class IdentificationCandidateResult:
    scientific_name: str
    common_name: str | None
    confidence_score: float
    confidence_label: str  # "high" | "moderate" | "low"
    provider: str
    model_version: str | None


@dataclass
class IdentificationResult:
    candidates: list[IdentificationCandidateResult] = field(default_factory=list)
    rejected_as_non_plant: bool = False


class PlantIdentificationProvider(ABC):
    @abstractmethod
    def identify(self, images: list[tuple[bytes, str, str]]) -> IdentificationResult:
        """images: list of (image_bytes, filename, organ) tuples.

        organ should be one of 'leaf', 'flower', 'fruit', 'bark', or
        'auto'. Callers using a different organ concept from their own
        guided-capture flow (e.g. 'stem', 'whole_plant', 'underside_of_leaf')
        should map to 'auto' before calling — see normalize_organ().
        """
        raise NotImplementedError


# Pl@ntNet only accepts these organ values (plus 'auto'). Anything else
# from our own guided-capture flow maps to 'auto', letting Pl@ntNet's own
# detection decide rather than guessing incorrectly at a mapping that
# doesn't exist.
_PLANTNET_ORGANS = {"leaf", "flower", "fruit", "bark"}


def normalize_organ(organ: str) -> str:
    return organ if organ in _PLANTNET_ORGANS else "auto"


def confidence_label(score: float) -> str:
    # Thresholds are our own choice — see module docstring.
    if score >= 0.7:
        return "high"
    if score >= 0.4:
        return "moderate"
    return "low"


class PlantNetProvider(PlantIdentificationProvider):
    BASE_URL = "https://my-api.plantnet.org/v2/identify"

    def __init__(self, api_key: str, project: str = "all") -> None:
        if not api_key:
            raise ValueError("PlantNetProvider requires a non-empty api_key")
        self._api_key = api_key
        self._project = project

    def identify(self, images: list[tuple[bytes, str, str]]) -> IdentificationResult:
        if not images:
            raise ValueError("At least one image is required")
        if len(images) > 5:
            raise ValueError("Pl@ntNet accepts at most 5 images per request")

        # organs are sent as multipart fields alongside the image files
        # (using the (None, value) convention for a non-file field within
        # multipart data), rather than as a separate `data=` parameter —
        # combining `files=` and `data=` list-of-tuples in the same
        # request triggered a TypeError deep in httpx/h11's request
        # encoding on a real device test. Folding everything into one
        # `files` list sidesteps that entirely and is standard practice
        # for mixing files with repeated non-file fields in multipart
        # requests.
        files = []
        for image_bytes, filename, organ in images:
            files.append(("images", (filename, image_bytes, "image/jpeg")))
            files.append(("organs", (None, normalize_organ(organ))))

        response = httpx.post(
            f"{self.BASE_URL}/{self._project}",
            params={"api-key": self._api_key},
            files=files,
            timeout=30.0,
        )

        if response.status_code == 404:
            # Documented Pl@ntNet behavior for "no plant species
            # predicted at all" — see module docstring.
            return IdentificationResult(candidates=[], rejected_as_non_plant=True)

        response.raise_for_status()
        payload = response.json()

        model_version = payload.get("version")
        candidates = []
        for result in payload.get("results", [])[:3]:
            species = result.get("species", {})
            common_names = species.get("commonNames") or []
            score = result.get("score", 0.0)
            candidates.append(
                IdentificationCandidateResult(
                    scientific_name=species.get("scientificName", "Unknown"),
                    common_name=common_names[0] if common_names else None,
                    confidence_score=score,
                    confidence_label=confidence_label(score),
                    provider="plantnet",
                    model_version=model_version,
                )
            )

        return IdentificationResult(candidates=candidates)