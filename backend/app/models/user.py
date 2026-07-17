"""User model.
 
email is nullable to support guest mode (per docs/01-product-requirements.md
MVP goal: "Account creation and guest mode").
"""

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, generate_uuid

class User(Base, TimestampMixin):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    email: Mapped[str | None] = mapped_column(String, unique=True, nullable=True)
    display_name: Mapped[str | None] = mapped_column(String, nullable=True)

    gardens: Mapped[list["Garden"]] = relationship(back_populates="user")
    user_plants: Mapped[list["UserPlant"]] = relationship(back_populates="user")