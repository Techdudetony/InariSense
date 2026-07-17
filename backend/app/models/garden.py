"""Garden, GardenLocation, and GardenBed/Container models.
 
GardenBed doubles as "container" via is_container — kept as one table per
docs/04-data-model.md's "GardenBed / Container" grouping, since they share
nearly all fields and splitting them would just duplicate columns.
"""

import enum

from sqlalchemy import Date, Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, generate_uuid

class GardenType(str, enum.Enum):
    raiser_bed = "raised_bed"
    in_ground = "in_ground"
    container = "container"
    indoor = "indoor"
    greenhouse = "greenhouse"
    hydroponic = "hydroponic"
    community = "community"
    orchard = "orchard"
    lawn = "lawn"
    landscape_bed = "landscape_bed"

class Garden(Base, TimestampMixin):
    __tablename__ = "gardens"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"))
    name: Mapped[str] = mapped_column(String)
    garden_type: Mapped[GardenType] = mapped_column(default=GardenType.in_ground)
    sunlight_exposure: Mapped[str | None] = mapped_column(str, nullable=True)
    soil_type: Mapped[str | None] = mapped_column(String, nullable=True)
    soil_ph: Mapped[str | None] = mapped_column(Float, nullable=True)
    drainage: Mapped[str | None] = mapped_column(String, nullable=True)
    irrigation_method: Mapped[str | None] = mapped_column(String, nullable=True)
    notes: Mapped[str | None] = mapped_column(String, nullable=True)

    user: Mapped["User"] = relationship(back_populates="gardens")
    location: Mapped["GardenLocation"] = relationship(back_populates="garden", uselist=False, cascade="all, delete-orphan")
    beds: Mapped[list["GardenBed"]] = relationship(back_populates="garden", cascade="all, delete-orphan")

class GardenLocation(Base, TimestampMixin):
    __tablename__ = "garden_locaitons"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    garden_id: Mapped[str] = mapped_column(ForeignKey("gardens.id"), unique=True)
    latitude: Mapped[Float | None] = mapped_column(Float, nullable=True)
    longitude: Mapped[Float | None] = mapped_column(Float, nullable=True)
    resolved_address: Mapped[str | None] = mapped_column(String, nullable=True)
    usda_zone: Mapped[str | None] = mapped_column(String, nullable=True)
    estimated_last_frost: Mapped[Date | None] = mapped_column(Date, nullable=True)
    estimated_first_frost: Mapped[Date | None] = mapped_column(Date, nullable=True)
    zone_source: Mapped[str | None] = mapped_column(String, nullable=True)    
    frost_source: Mapped[str | None] = mapped_column(String, nullable=True)    

    garden: Mapped["Garden"] = relationship(back_populates="location")

class GardenBed(Base, TimestampMixin):
    __tablename__ = "garden_beds"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    garden_id: Mapped[str] = mapped_column(ForeignKey("gardens.id"))
    name: Mapped[str] = mapped_column(String)
    is_container: Mapped[bool] = mapped_column(default=False)
    dimensions: Mapped[str | None] = mapped_column(String, nullable=True)
    container_size: Mapped[str | None] = mapped_column(String, nullable=True)
    bed_depth: Mapped[str | None] = mapped_column(String, nullable=True)
    notes: Mapped[str | None] = mapped_column(String, nullable=True)
 
    garden: Mapped["Garden"] = relationship(back_populates="beds")
    plantings: Mapped[list["Planting"]] = relationship(back_populates="garden_bed", cascade="all, delete-orphan")