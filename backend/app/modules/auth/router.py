"""Auth endpoints: registration and guest mode.
 
No login/session/token endpoints yet — this covers only the two MVP
requirements that don't depend on a credential system: creating a real
account (email-identified) and creating a guest account (no email,
usable immediately, matching "guest mode" in the product requirements).
 
A guest account can later be "claimed" by adding an email — that upgrade
path isn't built yet either, but the data model already supports it since
User.email is nullable.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.schemas.auth import UserRead, UserRegister

router = APIRouter()

@router.post("/register", response_model=UserRead, status_code=201)
def register(payload: UserRegister, db: Session = Depends(get_db)) -> User:
    user = User(email=payload.email, display_name=payload.display_name)
    db.add(user)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail=f"An account with email '{payload.email}' already exists")
    db.refresh(user)
    return user

@router.post("/guest", response_model=UserRead, status_code=201)
def create_guest(db: Session = Depends(get_db)) -> User:
    user = User(email=None, display_name="Guest")
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@router.get("/{user_id}", response_model=UserRead)
def get_user(user_id: str, db: Session = Depends(get_db)) -> User:
    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user