"""Garden CRUD endpoints.
 
Auth is intentionally not enforced yet — every endpoint takes user_id
explicitly (in the body for create, as a path/body field otherwise).
Once the auth module exists, user_id will come from the authenticated
session instead of being passed by the client, but that's a separate
branch so this one isn't blocked waiting on it.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.garden import Garden
from app.schemas.garden import GardenCreate, GardenRead, GardenUpdate

router = APIRouter()

@router.post("/", response_model=GardenRead, status_code=201)
def create_garden(payload: GardenCreate, db: Session = Depends(get_db)) -> Garden:
    garden = Garden(**payload.model_dump())
    db.add(garden)
    db.commit()
    db.refresh(garden)
    return garden

@router.get("/", response_model=list[GardenRead])
def list_gardens(user_id: str, db: Session = Depends(get_db)) -> list[Garden]:
    return db.query(Garden).filter(Garden.user_id == user_id).all()

@router.get("/{garden_id}", response_model=GardenRead)
def get_garden(garden_id: str, db: Session = Depends(get_db)) -> Garden:
    garden = db.get(Garden, garden_id)
    if garden is None:
        raise HTTPException(status_code=404, detail="Garden not found")
    return garden

@router.patch("/{garden_id}", response_model=GardenRead)
def update_garden(garden_id: str, payload: GardenUpdate, db: Session = Depends(get_db)) -> Garden:
    garden = db.get(Garden, garden_id)
    if garden is None:
        raise HTTPException(status_code=404, detail="Garden not found")
    
    updates = payload.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(garden, field, value)
    
    db.commit()
    db.refresh(garden)
    return garden

@router.delete("/{garden_id}", status_code=204)
def delete_garden(garden_id: str, db: Session = Depends(get_db)) -> None:
    garden = db.get(Garden, garden_id)
    if garden is None:
        raise HTTPException(status_code=404, detail="Garden not found")
    db.delete(garden)
    db.commit()