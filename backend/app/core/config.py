"""Application settings, loaded from environment variables (.env in dev).
 
Nothing here should be hard-coded for production — DATABASE_URL points at
SQLite by default so the app runs out-of-the-box in local dev without
requiring Postgres/PostGIS to be running yet. Production deployment sets
DATABASE_URL to the real Postgres connection string via environment
variables, never committed to the repo.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "sqlite:///./inarisense.db"
    environment: str = "development"

settings = Settings()