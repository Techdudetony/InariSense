"""Pydantic schemas for GardenBed endpoints.
 
GardenBed doubles as "container" via is_container, per
docs/04-data-model.md's grouping — no separate Container schema.
"""

from datetime import datetime

from pydantic import BaseModel, ConfigDict

class GardenBedBase(BaseModel):
    name: str
    is_container: bool = False
    dimensions: str | None = None
    container_size: str | None = None
    bed_depth: str | None = None
    notes: str | None = None

class GardenBedCreate(GardenBedBase):
    garden_id: str

class GardenBedUpdate(BaseModel):
    name: str | None = None
    is_container: bool | None = None
    dimensions: str | None = None
    container_size: str | None = None
    bed_depth: str | None = None
    notes: str | None = None

class GardenBedRead(GardenBedBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    garden_id: str
    created_at: datetime
    updated_at: datetime