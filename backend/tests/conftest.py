"""Pytest configuration.
 
Sets DATABASE_URL before anything else imports app.database (which reads
it from settings at import time) — this ensures tests never touch the
real dev database, and each test function gets clean tables via the
autouse fixture below.
"""

import os

os.environ.setdefault("DATABASE_URL", "sqlite:///./test_ci.db")

import pytest

from app import models
from app.database import engine

@pytest.fixture(autouse=True)
def _clean_tables():
    models.Base.metadata.create_all(bind=engine)
    yield
    models.Base.metadata.drop_all(bind=engine)