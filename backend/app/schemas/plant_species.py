"""Pydantic schemas for PlantSpecies endpoints.

scientific_name is unique at the DB level (see app/models/plant.py) —
attempting to create a duplicate will raise an IntegrityError, which the
router below catches and turns into a proper 409 response rather than a
raw 500.
"""

from datetime import datetime

from pydantic import BaseModel, ConfigDict

from app.models.plant import FrostTolerance, SunlightRequirement, WaterRequirement


class PlantSpeciesBase(BaseModel):
    common_name: str
    scientific_name: str
    category: str | None = None
    native_status: str | None = None
    toxicity_notes: str | None = None
    invasive_flag: bool = False
    taxonomy_source: str | None = None
    synonyms: str | None = None
    sunlight_requirement: SunlightRequirement | None = None
    water_requirement: WaterRequirement | None = None
    frost_tolerance: FrostTolerance | None = None
    spacing_inches: float | None = None
    soil_ph_min: float | None = None
    soil_ph_max: float | None = None
    germination_days_min: int | None = None
    germination_days_max: int | None = None
    maturity_days_min: int | None = None
    maturity_days_max: int | None = None


class PlantSpeciesCreate(PlantSpeciesBase):
    pass


class PlantSpeciesUpdate(BaseModel):
    common_name: str | None = None
    category: str | None = None
    native_status: str | None = None
    toxicity_notes: str | None = None
    invasive_flag: bool | None = None
    taxonomy_source: str | None = None
    synonyms: str | None = None
    sunlight_requirement: SunlightRequirement | None = None
    water_requirement: WaterRequirement | None = None
    frost_tolerance: FrostTolerance | None = None
    spacing_inches: float | None = None
    soil_ph_min: float | None = None
    soil_ph_max: float | None = None
    germination_days_min: int | None = None
    germination_days_max: int | None = None
    maturity_days_min: int | None = None
    maturity_days_max: int | None = None
    # scientific_name intentionally excluded from updates — it's the
    # taxonomic identity of the record; correcting a wrong one should be a
    # deliberate re-create, not a casual PATCH.


class PlantSpeciesRead(PlantSpeciesBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    created_at: datetime
    updated_at: datetime