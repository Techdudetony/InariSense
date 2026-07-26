"""Pydantic schemas for GardenLocation endpoints.
 
Two creation paths:
- GardenLocationCreate: raw fields, for when the client already has
  coordinates/zone/frost data (e.g. re-creating from a backup, or a future
  admin tool).
- GardenLocationCreateFromAddress: the real-world path — client sends a
  garden_id + free-text address, and the endpoint does geocoding + zone
  resolution server-side before saving. This is what the mobile app will
  actually call.
"""

from datetime import date, datetime

from pydantic import BaseModel, ConfigDict

class GardenLocationBase(BaseModel):
    latitude: float | None = None
    longitude: float | None = None
    resolved_address: str | None = None
    usda_zone: str | None = None
    estimated_last_frost: date | None = None
    estimated_first_frost: date | None = None
    zone_source: str | None = None
    frost_source: str | None = None

class GardenLocationCreate(GardenLocationBase):
    garden_id: str

class GardenLocationCreateFromAddress(BaseModel):
    garden_id: str
    address: str

class GardenLocationUpdate(GardenLocationBase):
    pass

class GardenLocationRead(GardenLocationBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    garden_id: str
    created_at: datetime
    updated_at: datetime