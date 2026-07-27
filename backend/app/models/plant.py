"""PlantSpecies, PlantVariety, UserPlant, and Planting models.

source_identification_id on UserPlant is left as a plain nullable string
(not a foreign key yet) since PlantIdentification doesn't exist as a table
until the identification feature branch — it'll be upgraded to a real FK
at that point rather than left dangling.
"""

import enum

from sqlalchemy import Boolean, Date, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, generate_uuid


class PlantingMethod(str, enum.Enum):
    indoor_seed_start = "indoor_seed_start"
    direct_sow = "direct_sow"
    transplant = "transplant"


class SunlightRequirement(str, enum.Enum):
    full_sun = "full_sun"
    partial_sun = "partial_sun"
    partial_shade = "partial_shade"
    full_shade = "full_shade"


class WaterRequirement(str, enum.Enum):
    low = "low"
    moderate = "moderate"
    high = "high"


class FrostTolerance(str, enum.Enum):
    frost_sensitive = "frost_sensitive"  # damaged/killed by any frost
    half_hardy = "half_hardy"  # tolerates light frost
    hardy = "hardy"  # tolerates hard frost


class PlantSpecies(Base, TimestampMixin):
    __tablename__ = "plant_species"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    common_name: Mapped[str] = mapped_column(String)
    scientific_name: Mapped[str] = mapped_column(String, unique=True)
    category: Mapped[str | None] = mapped_column(String, nullable=True)
    native_status: Mapped[str | None] = mapped_column(String, nullable=True)
    toxicity_notes: Mapped[str | None] = mapped_column(String, nullable=True)
    invasive_flag: Mapped[bool] = mapped_column(Boolean, default=False)
    taxonomy_source: Mapped[str | None] = mapped_column(String, nullable=True)
    synonyms: Mapped[str | None] = mapped_column(String, nullable=True)

    # Growing requirements — added for the Planting Calendar recommendation
    # engine (KAN-18/KAN-19). All nullable: a species with unknown
    # requirements should show up as "not enough data" in a recommendation
    # rather than block the record from existing at all.
    sunlight_requirement: Mapped[SunlightRequirement | None] = mapped_column(nullable=True)
    water_requirement: Mapped[WaterRequirement | None] = mapped_column(nullable=True)
    frost_tolerance: Mapped[FrostTolerance | None] = mapped_column(nullable=True)
    spacing_inches: Mapped[float | None] = mapped_column(Float, nullable=True)
    soil_ph_min: Mapped[float | None] = mapped_column(Float, nullable=True)
    soil_ph_max: Mapped[float | None] = mapped_column(Float, nullable=True)
    germination_days_min: Mapped[int | None] = mapped_column(Integer, nullable=True)
    germination_days_max: Mapped[int | None] = mapped_column(Integer, nullable=True)
    maturity_days_min: Mapped[int | None] = mapped_column(Integer, nullable=True)
    maturity_days_max: Mapped[int | None] = mapped_column(Integer, nullable=True)

    varieties: Mapped[list["PlantVariety"]] = relationship(
        back_populates="species", cascade="all, delete-orphan"
    )


class PlantVariety(Base, TimestampMixin):
    __tablename__ = "plant_varieties"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    species_id: Mapped[str] = mapped_column(ForeignKey("plant_species.id"))
    variety_name: Mapped[str] = mapped_column(String)
    days_to_maturity: Mapped[int | None] = mapped_column(nullable=True)
    notes: Mapped[str | None] = mapped_column(String, nullable=True)

    species: Mapped["PlantSpecies"] = relationship(back_populates="varieties")


class UserPlant(Base, TimestampMixin):
    __tablename__ = "user_plants"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"))
    species_id: Mapped[str] = mapped_column(ForeignKey("plant_species.id"))
    variety_id: Mapped[str | None] = mapped_column(
        ForeignKey("plant_varieties.id"), nullable=True
    )
    nickname: Mapped[str | None] = mapped_column(String, nullable=True)
    source_identification_id: Mapped[str | None] = mapped_column(String, nullable=True)

    user: Mapped["User"] = relationship(back_populates="user_plants")
    species: Mapped["PlantSpecies"] = relationship()
    variety: Mapped["PlantVariety | None"] = relationship()
    plantings: Mapped[list["Planting"]] = relationship(
        back_populates="user_plant", cascade="all, delete-orphan"
    )


class Planting(Base, TimestampMixin):
    __tablename__ = "plantings"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    garden_bed_id: Mapped[str] = mapped_column(ForeignKey("garden_beds.id"))
    user_plant_id: Mapped[str] = mapped_column(ForeignKey("user_plants.id"))
    planting_method: Mapped[PlantingMethod] = mapped_column(
        default=PlantingMethod.direct_sow
    )
    indoor_start_date: Mapped[Date | None] = mapped_column(Date, nullable=True)
    transplant_date: Mapped[Date | None] = mapped_column(Date, nullable=True)
    direct_sow_date: Mapped[Date | None] = mapped_column(Date, nullable=True)
    estimated_germination_window: Mapped[str | None] = mapped_column(String, nullable=True)
    estimated_maturity_window: Mapped[str | None] = mapped_column(String, nullable=True)
    estimated_harvest_window: Mapped[str | None] = mapped_column(String, nullable=True)
    actual_harvest_date: Mapped[Date | None] = mapped_column(Date, nullable=True)

    garden_bed: Mapped["GardenBed"] = relationship(back_populates="plantings")
    user_plant: Mapped["UserPlant"] = relationship(back_populates="plantings")