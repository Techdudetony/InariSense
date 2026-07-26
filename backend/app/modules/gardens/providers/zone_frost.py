"""USDA hardiness zone + frost date resolution.
 
Two different data-availability situations here, handled honestly rather
than papered over:
 
- USDA ZONE: resolved via reverse-geocoding the coordinates to a ZIP code
  (using Nominatim's reverse endpoint, same provider as geocoding.py),
  then looking up the zone for that ZIP via phzmapi.org — a free,
  keyless public API mirroring USDA's Plant Hardiness Zone Map data.
 
- FROST DATES: no free, keyless API providing frost dates by location was
  available at implementation time. Per the core principle in
  docs/01-product-requirements.md ("never fabricate a recommendation when
  required data is unavailable"), this returns None with a clear
  frost_source explaining why, rather than inventing dates from a
  latitude-based formula. This is a known, explicit gap — see the PR
  notes — not an oversight. A real historical frost-date dataset (e.g.
  NOAA) needs to be sourced and wired in before the planting calendar can
  actually use frost windows.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import date

import httpx

@dataclass
class ZoneFrostResult:
    zone: str | None
    zone_source: str | None
    estimated_last_frost: date | None
    estimated_first_frost: date | None
    frost_source: str | None


class ZoneFrostProvider(ABC):
    @abstractmethod
    def resolve(self, latitude: float, longitude: float) -> ZoneFrostResult:
        raise NotImplementedError

class UsPhzmapZoneFrostProvider(ZoneFrostProvider):
    """US-only (per docs/05-api-matrix.md's MVP scope decision)."""

    REVERSE_GEOCODE_URL = "https://nominatim.openstreetmap.org/reverse"
    PHZMAP_URL = "https://phzmapi.org/{zip_code}.json"

    def __init__(self, user_agent: str = "InariSense/0.1 (dev)") -> None:
        self._user_agent = user_agent

    def _reverse_geocode_zip(self, latitude: float, longitude: float) -> str | None:
        response = httpx.get(
            self.REVERSE_GEOCODE_URL,
            params={"lat": latitude, "lon": longitude, "format": "jsonv2"},
            headers={"User-Agent": self._user_agent},
            timeout=10.0,
        )
        response.raise_for_status()
        data = response.json()
        return data.get("address", {}).get("postcode")

    def _zone_for_zip(self, zip_code: str) -> str | None:
        response = httpx.get(self.PHZMAP_URL.format(zip_code=zip_code), timeout=10.0)
        if response.status_code == 404:
            return None
        response.raise_for_status()
        return response.json().get("zone")

    def resolve(self, latitude: float, longitude: float) -> ZoneFrostResult:
        zip_code = self._reverse_geocode_zip(latitude, longitude)
        zone = self._zone_for_zip(zip_code) if zip_code else None

        return ZoneFrostResult(
            zone=zone,
            zone_source="phzmapi.org (USDA Plant Hardiness Zone Map)" if zone else None,
            estimated_last_frost=None,
            estimated_first_frost=None,
            frost_source="not yet available - no keyless frost-date provider wired in",
        )