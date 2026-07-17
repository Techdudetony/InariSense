"""Database engine and session setup.
 
FastAPI endpoints depend on `get_db` to receive a session per-request via
dependency injection — sessions are never created and held globally.
"""

from collections.abc import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import settings

# check_same_thread is only needed for SQLite (dev default); harmless to
# pass unconditionally since it's ignored by other dialects... actually
# it isn't ignored by all dialects, so we gate it explicitly below.
connect_args = (
    {"check_same_thread": False} if settings.database_url.startswith("sqlite") else {}
)

engine = create_engine(settings.database_url, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()