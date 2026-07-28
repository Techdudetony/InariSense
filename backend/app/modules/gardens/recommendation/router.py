"""Planting recommendations endpoint (KAN-20).
 
Wraps the pure-logic engine (recommendation/engine.py) with real Garden,
GardenLocation, and PlantSpecies data. The engine itself has no DB
dependency — this router is the only place that connects it to the
database.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.garden import Garden
from app.models.plant import PlantSpecies
from app.modules.gardens.recommendation.engine import generate_recommendation
from app.schemas.recommendation import DateWindowSchema, PlantingRecommendationResponse

router = APIRouter()

def _window_to_schema(window) -> DateWindowSchema | None:
    if window is None:
        return None
    return DateWindowSchema(start=window.start, end=window.end)

@router.get("/", response_model=list[PlantingRecommendationResponse])
def get_recommendations(
    garden_id: str,
    category: str | None = None,
    sunlight: str | None = None,
    db: Session = Depends(get_db),
) -> list[PlantingRecommendationResponse]:
    garden = db.get(Garden, garden_id)
    if garden is None:
        raise HTTPException(status_code=404, detail="Garden not found")

    if garden.location is None:
        raise HTTPException(
            status_code=400, 
            detail="This garden has no location set. Set a location before requesting recommendations."
        )

    query = db.query(PlantSpecies)
    if category:
        query = query.filter(PlantSpecies.category == category)
    if sunlight:
        query = query.filter(PlantSpecies.sunlight_requirement == sunlight)
    species_list = query.all()

    zone = garden.location.usda_zone
    estimated_last_frost = garden.location.estimated_last_frost
    estimated_first_frost = garden.location.estimated_first_frost

    results: list[PlantingRecommendationResponse] = []
    for species in species_list:
        rec = generate_recommendation(
            species_id=species.id,
            frost_tolerance=species.frost_tolerance.value if species.frost_tolerance else None,
            germination_days_min=species.germination_days_min,
            germination_days_max=species.germination_days_max,
            maturity_days_min=species.maturity_days_min,
            maturity_days_max=species.maturity_days_max,
            zone=zone,
            estimated_last_frost=estimated_last_frost,
            estimated_first_frost=estimated_first_frost,
        )
        results.append(
            PlantingRecommendationResponse(
                species_id=species.id,
                common_name=species.common_name,
                scientific_name=species.scientific_name,
                confidence=rec.confidence,
                frost_data_source=rec.frost_data_source,
                main_method=rec.main_method,
                main_window=_window_to_schema(rec.main_window),
                main_window_status=rec.main_window_status,
                indoor_start_window=_window_to_schema(rec.indoor_start_window),
                harvest_window=_window_to_schema(rec.harvest_window),
                notes=rec.notes,
            )
        )

    return results