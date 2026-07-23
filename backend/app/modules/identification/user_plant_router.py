"""UserPlant CRUD endpoints.
 
Lives alongside PlantSpecies in the identification module — a UserPlant is
the link between a user, a species, and (eventually) the identification
that led them to it.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.plant import UserPlant
from app.schemas.user_plant import UserPlantCreate, UserPlantRead, UserPlantUpdate

router = APIRouter()

@router.post("/", response_model=UserPlantRead, status_code=201)
def create_user_plant(payload: UserPlantCreate, db: Session = Depends(get_db)) -> UserPlant:
    user_plant = UserPlant(**payload.model_dump())
    db.add(user_plant)
    db.commit()
    db.refresh(user_plant)
    return user_plant

@router.get("/", response_model=list[UserPlantRead])
def list_user_plants(user_id: str, db: Session = Depends(get_db)) -> list[UserPlant]:
    return db.query(UserPlant).filter(UserPlant.user_id == user_id).all()

@router.get("/{user_plant_id}", response_model=UserPlantRead)
def get_user_plant(user_plant_id: str, db: Session = Depends(get_db)) -> UserPlant:
    user_plant = db.get(UserPlant, user_plant_id)
    if user_plant is None:
        raise HTTPException(status_code=404, detail="User plant not found")
    return user_plant

@router.patch("/{user_plant_id}", response_model=UserPlantRead)
def update_user_plant(user_plant_id: str, payload: UserPlantUpdate, db: Session = Depends(get_db)) -> UserPlant:
    user_plant = db.get(UserPlant, user_plant_id)
    if user_plant is None:
        raise HTTPException(status_code=404, detail="User plant not found")

    updates = payload.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(user_plant, field, value)

    db.commit()
    db.refresh(user_plant)
    return user_plant

@router.delete("/{user_plant_id}", status_code=204)
def delete_user_plant(user_plant_id: str, db: Session = Depends(get_db)) -> None:
    user_plant = db.get(UserPlant, user_plant_id)
    if user_plant is None:
        raise HTTPException(status_code=404, detail="User plant not found")
    db.delete(user_plant)
    db.commit()