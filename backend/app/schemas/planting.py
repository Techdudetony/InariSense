"""Pydantic schemas for Planting endpoints.
 
Dates are plain ISO date strings on the wire; Pydantic handles the
conversion to/from Python's date type automatically via the `date` type
hint below.
"""

from datetime import date, datetime

from pydantic import BaseModel, ConfigDict

from app.models.plant import PlantingMethod

class PlantingBase(BaseModel):
    planting_method: PlantingMethod = PlantingMethod.direct_sow
    indoor_start_date: date | None = None
    transplant_date: date | None = None
    direct_sow_date: date | None = None
    estimated_germination_window: str | None = None
    estimated_maturity_window: str | None = None
    estimated_harvest_window: str | None = None
    actual_harvest_date: date | None = None

class PlantingCreate(PlantingBase):
    garden_bed_id: str
    user_plant_id: str

class PlantingUpdate(BaseModel):
    planting_method: PlantingMethod | None = None
    indoor_start_date: date | None = None
    transplant_date: date | None = None
    direct_sow_date: date | None = None
    estimated_germination_window: str | None = None
    estimated_maturity_window: str | None = None
    estimated_harvest_window: str | None = None
    actual_harvest_date: date | None = None

class PlantingRead(PlantingBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    garden_bed_id: str
    user_plant_id: str
    created_at: datetime
    updated_at: datetime