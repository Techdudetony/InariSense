"""InariSense backend entry point.
 
This is a minimal scaffold: a FastAPI app instance with a health check
endpoint. Feature modules (gardens, identification, weather, etc.) each
get their own router, mounted here as they're built out — none exist yet
beyond empty package placeholders, per docs/03-architecture.md.
"""

from fastapi import FastAPI

from app.modules.gardens.router import router as gardens_router

app = FastAPI(
    title="InariSense API",
    description="Backend for the InariSense garden companion app.",
    version="0.1.0",
)

app.include_router(gardens_router, prefix="/gardens", tags=["gardens"])

@app.get("/health")
def health_check() -> dict[str, str]:
    '''Basic liveness check — confirms the service is up and responding.'''
    return {"status": "ok"}

# Additional feature routers will be included here as each module is
# implemented, e.g.:
# from app.modules.identification.router import router as identification_router
# app.include_router(identification_router, prefix="/identification", tags=["identification"])