"""Pydantic schemas for the geocoding endpoint."""

from pydantic import BaseModel

class GeocodeRequest(BaseModel):
    query: str # free-text address, city, or ZIP

class GeocodeResponse(BaseModel):
    latitude: float
    longitude: float
    resolved_address: str
    source: str
    