"""Zone/frost resolution endpoint.
 
Same dependency-injection pattern as geocoding_router.py — provider is
swappable and testable via override, not hard-wired into the handler.
"""

from fastapi import APIRouter, Depends

from app.modules.gardens.providers.zone_frost import UsPhzmapZoneFrostProvider, ZoneFrostProvider
from app.schemas.zone_frost import ZoneFrostRequest, ZoneFrostResponse

router = APIRouter()

def get_zone_frost_provider() -> ZoneFrostProvider:
    return UsPhzmapZoneFrostProvider()

@router.post("/", response_model=ZoneFrostResponse)
def resolve_zone_frost(payload: ZoneFrostRequest, provider: ZoneFrostProvider = Depends(get_zone_frost_provider),) -> ZoneFrostResponse:
    result = provider.resolve(payload.latitude, payload.longitude)
    return ZoneFrostResponse(
        zone=result.zone,
        zone_source=result.zone_source,
        estimated_last_frost=result.estimated_last_frost,
        estimated_first_frost=result.estimated_first_frost,
        frost_source=result.frost_source,
    )