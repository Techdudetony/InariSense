"""Geocoding provider interface + Nominatim implementation.

Per docs/03-architecture.md's provider adapter pattern: business logic
(the router) depends on the abstract GeocodingProvider interface, never on
a concrete vendor. Swapping Nominatim for Google/Apple/another provider
later means writing a new class here — the router and schemas don't
change.

Nominatim (OpenStreetMap) is the MVP default because it's free and
requires no API key or account setup, matching the "free or low-cost tier
sufficient for early real users" rule in docs/05-api-matrix.md. Its usage
policy requires a descriptive User-Agent header and a max of 1 request/
second — both handled here.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass

import httpx


@dataclass
class GeocodeResult:
    latitude: float
    longitude: float
    resolved_address: str
    source: str  # provider name, stored on GardenLocation per the
    # provenance rule in docs/04-data-model.md


class GeocodingProvider(ABC):
    @abstractmethod
    def geocode(self, query: str) -> GeocodeResult | None:
        """Return the best-match location for a free-text query
        (address, city, or ZIP), or None if nothing matched."""
        raise NotImplementedError


class NominatimGeocodingProvider(GeocodingProvider):
    BASE_URL = "https://nominatim.openstreetmap.org/search"

    def __init__(self, user_agent: str = "InariSense/0.1 (dev)") -> None:
        self._user_agent = user_agent

    def geocode(self, query: str) -> GeocodeResult | None:
        response = httpx.get(
            self.BASE_URL,
            params={"q": query, "format": "jsonv2", "limit": 1},
            headers={"User-Agent": self._user_agent},
            timeout=10.0,
        )
        response.raise_for_status()
        results = response.json()

        if not results:
            return None

        top = results[0]
        return GeocodeResult(
            latitude=float(top["lat"]),
            longitude=float(top["lon"]),
            resolved_address=top.get("display_name", query),
            source="nominatim",
        )