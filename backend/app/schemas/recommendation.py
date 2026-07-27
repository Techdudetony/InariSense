"""Pydantics schemas for the planting recommendations endpoint."""

from datetime import date

from pydantic import BaseModel

class DateWindowSchema(BaseModel):
    start: date
    end: date

class PlantingRecommendationResponse(BaseModel):
    species_id: str
    common_name: str
    scientific_name: str
    confidence: str # "high" | "low" | "none"
    frost_data_source: str # "garden_location" | "zone_average" | "unavailable"
    main_method: str | None
    main_window: DateWindowSchema | None
    main_window_status: str
    indoor_start_window: DateWindowSchema | None
    harvest_window: DateWindowSchema | None
    notes: list[str]