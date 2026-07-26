"""Pydantic schemas for the zone/frost resolution endpoint."""

from datetime import date

from pydantic import BaseModel

class ZoneFrostRequest(BaseModel):
    latitude: float
    longitude: float

class ZoneFrostResponse(BaseModel):
    zone: str | None
    zone_source: str | None
    estimated_last_frost: date | None
    estimated_first_frost: date | None
    frost_source: str | None