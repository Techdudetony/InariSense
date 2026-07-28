"""GardenLocation CRUD endpoints.

garden_id is unique on this table (one location per garden, per the
model) — attempting to create a second location for the same garden
returns 409, same pattern as PlantSpecies' duplicate scientific_name.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.garden import GardenLocation
from app.modules.gardens.geocoding_router import get_geocoding_provider
from app.modules.gardens.providers.geocoding import GeocodingProvider
from app.modules.gardens.providers.zone_frost import ZoneFrostProvider
from app.modules.gardens.zone_frost_router import get_zone_frost_provider
from app.schemas.garden_location import (
    GardenLocationCreate,
    GardenLocationCreateFromAddress,
    GardenLocationRead,
    GardenLocationUpdate,
)

router = APIRouter()


def _duplicate_location_error(garden_id: str) -> HTTPException:
    return HTTPException(
        status_code=409,
        detail=f"Garden '{garden_id}' already has a location. Update it instead of creating a new one.",
    )


@router.post("/", response_model=GardenLocationRead, status_code=201)
def create_garden_location(
    payload: GardenLocationCreate, db: Session = Depends(get_db)
) -> GardenLocation:
    location = GardenLocation(**payload.model_dump())
    db.add(location)
    try:
        db.commit()
    except IntegrityError as err:
        db.rollback()
        raise _duplicate_location_error(payload.garden_id) from err
    db.refresh(location)
    return location


@router.post("/from-address", response_model=GardenLocationRead, status_code=201)
def create_garden_location_from_address(
    payload: GardenLocationCreateFromAddress,
    db: Session = Depends(get_db),
    geocoding_provider: GeocodingProvider = Depends(get_geocoding_provider),
    zone_frost_provider: ZoneFrostProvider = Depends(get_zone_frost_provider),
) -> GardenLocation:
    geo_result = geocoding_provider.geocode(payload.address)
    if geo_result is None:
        raise HTTPException(
            status_code=404,
            detail=f"No location found for '{payload.address}'. Try a more specific address, city, or ZIP.",
        )

    zone_frost_result = zone_frost_provider.resolve(geo_result.latitude, geo_result.longitude)

    location = GardenLocation(
        garden_id=payload.garden_id,
        latitude=geo_result.latitude,
        longitude=geo_result.longitude,
        resolved_address=geo_result.resolved_address,
        usda_zone=zone_frost_result.zone,
        zone_source=zone_frost_result.zone_source,
        estimated_last_frost=zone_frost_result.estimated_last_frost,
        estimated_first_frost=zone_frost_result.estimated_first_frost,
        frost_source=zone_frost_result.frost_source,
    )
    db.add(location)
    try:
        db.commit()
    except IntegrityError as err:
        db.rollback()
        raise _duplicate_location_error(payload.garden_id) from err
    db.refresh(location)
    return location


@router.get("/{location_id}", response_model=GardenLocationRead)
def get_garden_location(location_id: str, db: Session = Depends(get_db)) -> GardenLocation:
    location = db.get(GardenLocation, location_id)
    if location is None:
        raise HTTPException(status_code=404, detail="Garden location not found")
    return location


@router.get("/", response_model=list[GardenLocationRead])
def list_garden_locations(garden_id: str, db: Session = Depends(get_db)) -> list[GardenLocation]:
    return db.query(GardenLocation).filter(GardenLocation.garden_id == garden_id).all()


@router.patch("/{location_id}", response_model=GardenLocationRead)
def update_garden_location(
    location_id: str, payload: GardenLocationUpdate, db: Session = Depends(get_db)
) -> GardenLocation:
    location = db.get(GardenLocation, location_id)
    if location is None:
        raise HTTPException(status_code=404, detail="Garden location not found")

    updates = payload.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(location, field, value)

    db.commit()
    db.refresh(location)
    return location


@router.delete("/{location_id}", status_code=204)
def delete_garden_location(location_id: str, db: Session = Depends(get_db)) -> None:
    location = db.get(GardenLocation, location_id)
    if location is None:
        raise HTTPException(status_code=404, detail="Garden location not found")
    db.delete(location)
    db.commit()