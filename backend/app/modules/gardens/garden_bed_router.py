"""GardenBed CRUD endpoints.
 
Lives in the gardens module alongside Garden and Planting routers, per
docs/03-architecture.md's grouping.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.garden import GardenBed
from app.schemas.garden_bed import GardenBedCreate, GardenBedRead

router = APIRouter()

@router.post("/", response_model=GardenBedRead, status_code=201)
def create_garden_bed(payload: GardenBedCreate, db: Session = Depends(get_db)) -> GardenBed:
    bed = GardenBed(**payload.model_dump())
    db.add(bed)
    db.commit()
    db.refresh(bed)
    return bed

@router.get("/", response_model=list[GardenBedRead])
def list_garden_beds(garden_id: str, db: Session = Depends(get_db)) -> list[GardenBed]:
    return db.query(GardenBed).filter(GardenBed.garden_id == garden_id).all()

@router.get("/{bed_id}", response_model=GardenBedRead)
def get_garden_bed(bed_id: str, db: Session = Depends(get_db)) -> GardenBed:
    bed = db.get(GardenBed, bed_id)
    if bed is None:
        raise HTTPException(status_code=404, detail="Garden Bed not found")
    return bed

@router.patch("/{bed_id}", response_model=GardenBedRead)
def update_garden_bed(bed_id: str, payload: GardenBedRead, db: Session = Depends(get_db)) -> GardenBed:
    bed = db.get(GardenBed, bed_id)
    if bed is None:
        raise HTTPException(status_code=404, detail="Garden Bed not found")

    updates = payload.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(bed, field, value)

    db.commit()
    db.refresh(bed)
    return bed

@router.delete("/{bed_id}", status_code=204)
def delete_garden_bed(bed_id: str, db: Session = Depends(get_db)) -> None:
    bed = db.get(GardenBed, bed_id)
    if bed is None:
        raise HTTPException(status_code=404, detail="Garden Bed not found")
    db.delete(bed)
    db.commit()