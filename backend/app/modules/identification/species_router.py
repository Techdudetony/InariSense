"""PlantSpecies CRUD endpoints.

Lives in the identification module rather than gardens — species/taxonomy
data is what the identification and taxonomy-reconciliation logic will
eventually populate from GBIF, per docs/03-architecture.md, even though
right now it's just plain CRUD with no external provider wired up yet.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.plant import PlantSpecies
from app.schemas.plant_species import (
    PlantSpeciesCreate,
    PlantSpeciesRead,
    PlantSpeciesUpdate,
)

router = APIRouter()


@router.post("/", response_model=PlantSpeciesRead, status_code=201)
def create_plant_species(
    payload: PlantSpeciesCreate, db: Session = Depends(get_db)
) -> PlantSpecies:
    species = PlantSpecies(**payload.model_dump())
    db.add(species)
    try:
        db.commit()
    except IntegrityError as err:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail=f"A species with scientific_name '{payload.scientific_name}' already exists",
        ) from err
    db.refresh(species)
    return species


@router.get("/", response_model=list[PlantSpeciesRead])
def list_plant_species(
    common_name: str | None = None, db: Session = Depends(get_db)
) -> list[PlantSpecies]:
    query = db.query(PlantSpecies)
    if common_name:
        query = query.filter(PlantSpecies.common_name.ilike(f"%{common_name}%"))
    return query.all()


@router.get("/{species_id}", response_model=PlantSpeciesRead)
def get_plant_species(species_id: str, db: Session = Depends(get_db)) -> PlantSpecies:
    species = db.get(PlantSpecies, species_id)
    if species is None:
        raise HTTPException(status_code=404, detail="Plant species not found")
    return species


@router.patch("/{species_id}", response_model=PlantSpeciesRead)
def update_plant_species(
    species_id: str, payload: PlantSpeciesUpdate, db: Session = Depends(get_db)
) -> PlantSpecies:
    species = db.get(PlantSpecies, species_id)
    if species is None:
        raise HTTPException(status_code=404, detail="Plant species not found")

    updates = payload.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(species, field, value)

    db.commit()
    db.refresh(species)
    return species


@router.delete("/{species_id}", status_code=204)
def delete_plant_species(species_id: str, db: Session = Depends(get_db)) -> None:
    species = db.get(PlantSpecies, species_id)
    if species is None:
        raise HTTPException(status_code=404, detail="Plant species not found")
    db.delete(species)
    db.commit()