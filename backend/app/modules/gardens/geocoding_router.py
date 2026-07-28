"""Geocoding endpoint.
 
The provider is injected via FastAPI's dependency system (get_provider)
rather than instantiated directly in the handler — this is what makes it
possible to override with a fake provider in tests without touching real
network calls, and to swap providers later via one dependency override
instead of editing the handler.
"""

from fastapi import APIRouter, Depends, HTTPException

from app.modules.gardens.providers.geocoding import GeocodingProvider, NominatimGeocodingProvider
from app.schemas.geocoding import GeocodeRequest, GeocodeResponse

router = APIRouter()

def get_geocoding_provider() -> GeocodingProvider:
    return NominatimGeocodingProvider()

@router.post("/", response_model=GeocodeResponse)
def geocode(
    payload: GeocodeRequest, 
    provider: GeocodingProvider = Depends(get_geocoding_provider),
) -> GeocodeResponse:
    result = provider.geocode(payload.query)
    if result is None:
        raise HTTPException(
            status_code=404, 
            detail=f"No location found for '{payload.query}'. Try a more specific address, city, or ZIP.",
        )
    return GeocodeResponse(
        latitude=result.latitude,
        longitude=result.longitude,
        resolved_address=result.resolved_address,
        source=result.source,
    )