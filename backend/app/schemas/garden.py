"""Pydantic schemas for Garden endpoints.
 
Separate Create/Update/Read schemas rather than one shared model:
- GardenCreate requires user_id + name; everything else optional.
- GardenUpdate makes every field optional (partial updates via PATCH).
- GardenRead includes server-generated fields (id, timestamps) and is
  built with from_attributes=True so it can be constructed directly from
  a SQLAlchemy model instance.
"""

from datetime import datetime

from pydantic import BaseModel, ConfigDict

from app.models.garden import GardenType

class GardenBase(BaseModel):
    name: str
    garden_type: GardenType = GardenType.in_ground
    sunlight_exposure: str | None = None
    soil_type: str | None = None
    soil_ph: float | None = None
    drainage: str | None = None
    irrigation_method: str | None = None
    notes: str | None = None

class GardenCreate(GardenBase):
    user_id: str

class GardenUpdate(BaseModel):
    name: str | None = None
    garden_type: GardenType | None = None
    sunlight_exposure: str | None = None
    soil_type: str | None = None
    soil_ph: float | None = None
    drainage: str | None = None
    irrigation_method: str | None = None
    notes: str | None = None

class GardenRead(GardenBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    created_at: datetime
    updated_at: datetime