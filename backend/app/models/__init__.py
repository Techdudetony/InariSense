"""Import every model module here so Base.metadata and the mapper registry
know about all tables/relationships as soon as `app.models` is imported —
required for the string-based relationship() references (e.g. "Garden")
in individual model files to resolve correctly.
"""

from app.models.base import Base 
from app.models.user import User
from app.models.garden import Garden, GardenLocation, GardenBed, GardenType
from app.models.plant import PlantSpecies, PlantVariety, UserPlant, Planting, PlantingMethod