"""Pydantic schemas for auth endpoints.
 
No password field yet — the User model doesn't have one. This branch
covers account creation and guest mode only, per the MVP goal in
docs/01-product-requirements.md ("Account creation and guest mode").
Real credential-based auth (password hashing, tokens/sessions) is a
separate, larger piece of work and intentionally not bundled in here.
"""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr

class UserRegister(BaseModel):
    email: EmailStr
    display_name: str | None = None

class UserRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    email: str | None
    display_name: str| None
    created_at: datetime
    updated_at: datetime