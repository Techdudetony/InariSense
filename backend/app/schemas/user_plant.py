"""Pydantic schemas for UserPlant endpoints.
 
source_identification_id stays a plain optional string here too, matching
the model — it becomes a real FK once PlantIdentification exists.
"""

from datetime import datetime

from pydantic import BaseModel, ConfigDict

class UserPlantBase(BaseModel):
    nickname: str | None = None
    variety_id: str | None = None
    source_identification_id: str | None = None

class UserPlantCreate(UserPlantBase):
    user_id: str
    species_is: str

class UserPlantUpdate(BaseModel):
    nickname: str | None = None
    variety_id: str | None = None
    source_identification_id: str | None = None

class UserPlantRead(UserPlantBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    species_id: str
    created_at: datetime
    updated_at: datetime