"""Pydantic schemas for the identification endpoint."""

from pydantic import BaseModel

class IdentificationCandidateOut(BaseModel):
    species_id: str
    common_name: str
    scientific_name: str
    confidence_score: float
    confidence_label: str # "high" | "moderate" | "low"
    provider: str
    model_version: str | None
    rank: int

class IdentificationResponse(BaseModel):
    id: str
    status: str # "pending" | "complete" | "needs_more_photos"
    images: list[str]
    candidates: list[IdentificationCandidateOut]