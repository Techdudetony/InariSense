"""Shared SQLAlchemy base and common column mixin.
 
Every model in app/models/ inherits from Base, and most also inherit
TimestampMixin so created_at/updated_at are consistent across entities
without repeating the columns in each file.
"""

import uuid
from datetime import datetime, timezone

from sqlalchemy import DateTime
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class Base(DeclarativeBase):
    pass

def _utcnow() -> datetime:
    return datetime.now(timezone.utc)

class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow)

def generate_uuid() -> str:
    return str(uuid.uuid4())