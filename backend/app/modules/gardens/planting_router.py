"""Planting CRUD endpoints.
 
Lives in the gardens module (not a separate module) because
docs/03-architecture.md groups Garden, GardenBed, Container, and Planting
CRUD together under one module — splitting Planting into its own module
would fragment closely related, always-co-changed code for no benefit.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.plant import Planting
from app.schemas.planting import PlantingCreate, PlantingRead, PlantingUpdate

router = APIRouter()

@router.post("/", response_model=PlantingRead, status_code=201)
def create_planting(payload: PlantingCreate, db: Session = Depends(get_db)) -> Planting:
    planting = Planting(**payload.model_dump())
    db.add(planting)
    db.commit()
    db.refresh(planting)
    return planting

@router.get("/", response_model=list[PlantingRead])
def list_plantings(garden_bed_id: str, db: Session = Depends(get_db)) -> list[Planting]:
    return db.query(Planting).filter(Planting.garden_bed_id == garden_bed_id).all()

@router.get("/{planting_id}", response_model=PlantingRead)
def get_planting(planting_id: str, db: Session = Depends(get_db)) -> Planting:
    planting = db.get(Planting, planting_id)
    if planting is None:
        raise HTTPException(status_code=404, detail="Planting not found")
    return planting

@router.patch("/{planting_id}", response_model=PlantingRead)
def update_planting(planting_id: str, payload: PlantingUpdate, db: Session = Depends(get_db)) -> Planting:
    planting = db.get(Planting, planting_id)
    if planting is None:
        raise HTTPException(status_code=404, detail="Planting not found")
    
    updates = payload.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(planting, field, value)

    db.commit()
    db.refresh(planting)
    return planting

@router.delete("/{planting_id}", status_code=204)
def delete_planting(planting_id: str, db: Session = Depends(get_db)) -> None:
    planting = db.get(Planting, planting_id)
    if planting is None:
        raise HTTPException(status_code=404, detail="Planting not found")
    db.delete(planting)
    db.commit()