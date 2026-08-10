"""Import every model module here so Base.metadata and the mapper registry
know about all tables/relationships as soon as `app.models` is imported —
required for the string-based relationship() references (e.g. "Garden")
in individual model files to resolve correctly.
"""

from app.models.base import Base  # noqa: F401
from app.models.user import User  # noqa: F401
from app.models.garden import Garden, GardenLocation, GardenBed, GardenType  # noqa: F401
from app.models.plant import (  # noqa: F401
    PlantSpecies,
    PlantVariety,
    UserPlant,
    Planting,
    PlantingMethod,
    SunlightRequirement,
    WaterRequirement,
    FrostTolerance,
)
from app.models.identification import (
    PlantIdentification,
    IdentificationCandidate,
    IdentificationEvidence,
    ImageAnnotation,
    IdentificationStatus,
    ConfidenceLabel,
    EvidenceDirection,
)