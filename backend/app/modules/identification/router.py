"""Plant identification endpoint (KAN-28).

Wraps the Pl@ntNet provider (KAN-27) with real image storage
(storage.py) and DB persistence (the KAN-26 models). Never presents an
uncertain identification as definitive — status is explicitly
"needs_more_photos" when nothing confident comes back, matching the
confidence-transparency principle from docs/01-product-requirements.md.
"""

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.core.config import settings
from app.database import get_db
from app.models.identification import (
    ConfidenceLabel,
    IdentificationCandidate,
    IdentificationStatus,
    PlantIdentification,
)
from app.models.plant import PlantSpecies
from app.modules.identification.providers.plantnet import (
    IdentificationCandidateResult,
    PlantNetProvider,
)
from app.modules.identification.storage import save_image
from app.schemas.identification import IdentificationCandidateOut, IdentificationResponse

router = APIRouter()


def get_identification_provider() -> PlantNetProvider:
    return PlantNetProvider(api_key=settings.plantnet_api_key)


def _get_or_create_species(db: Session, candidate: IdentificationCandidateResult) -> PlantSpecies:
    """MVP simplification: auto-creates a PlantSpecies row from Pl@ntNet's
    result if we don't already have one matching this scientific_name.
    This bypasses formal taxonomy reconciliation against GBIF (a
    separate, not-yet-built concern per docs/03-architecture.md) — good
    enough to let a user act on a real identification result now, worth
    revisiting once real taxonomy reconciliation exists.
    """
    existing = db.query(PlantSpecies).filter_by(scientific_name=candidate.scientific_name).first()
    if existing:
        return existing

    species = PlantSpecies(
        common_name=candidate.common_name or candidate.scientific_name,
        scientific_name=candidate.scientific_name,
        taxonomy_source="plantnet",
    )
    db.add(species)
    db.flush()
    return species


def _build_response(identification: PlantIdentification) -> IdentificationResponse:
    candidates_out = [
        IdentificationCandidateOut(
            species_id=c.species_id,
            common_name=c.species.common_name if c.species else "Unknown",
            scientific_name=c.species.scientific_name if c.species else "Unknown",
            confidence_score=c.confidence_score,
            confidence_label=c.confidence_label.value,
            provider=c.provider,
            model_version=c.model_version,
            rank=c.rank,
        )
        for c in sorted(identification.candidates, key=lambda c: c.rank)
    ]

    return IdentificationResponse(
        id=identification.id,
        status=identification.status.value,
        images=identification.images,
        candidates=candidates_out,
    )


@router.post("/", response_model=IdentificationResponse, status_code=201)
async def create_identification(
    user_id: str = Form(...),
    images: list[UploadFile] = File(...),
    organs: list[str] = Form(...),
    db: Session = Depends(get_db),
    provider: PlantNetProvider = Depends(get_identification_provider),
) -> IdentificationResponse:
    if not images:
        raise HTTPException(status_code=400, detail="At least one image is required")
    if len(images) != len(organs):
        raise HTTPException(
            status_code=400,
            detail=f"Got {len(images)} image(s) but {len(organs)} organ value(s) — these must match 1:1.",
        )

    image_payload: list[tuple[bytes, str, str]] = []
    stored_refs: list[str] = []
    for upload, organ in zip(images, organs, strict=True):
        content = await upload.read()
        filename = upload.filename or "upload.jpg"
        stored_refs.append(save_image(content, filename))
        image_payload.append((content, filename, organ))

    try:
        result = provider.identify(image_payload)
    except Exception as err:
        raise HTTPException(
            status_code=502,
            detail="Could not reach the identification service. Please try again.",
        ) from err

    status = (
        IdentificationStatus.needs_more_photos
        if not result.candidates
        else IdentificationStatus.complete
    )

    identification = PlantIdentification(user_id=user_id, images=stored_refs, status=status)
    db.add(identification)
    db.flush()

    for rank, candidate in enumerate(result.candidates[:3], start=1):
        species = _get_or_create_species(db, candidate)
        db.add(
            IdentificationCandidate(
                identification_id=identification.id,
                species_id=species.id,
                confidence_score=candidate.confidence_score,
                confidence_label=ConfidenceLabel(candidate.confidence_label),
                provider=candidate.provider,
                model_version=candidate.model_version,
                rank=rank,
            )
        )

    db.commit()
    db.refresh(identification)
    return _build_response(identification)


@router.get("/{identification_id}", response_model=IdentificationResponse)
def get_identification(identification_id: str, db: Session = Depends(get_db)) -> IdentificationResponse:
    identification = db.get(PlantIdentification, identification_id)
    if identification is None:
        raise HTTPException(status_code=404, detail="Identification not found")
    return _build_response(identification)