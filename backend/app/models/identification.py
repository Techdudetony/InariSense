"""PlantIdentification, IdentificationCandidate, IdentificationEvidence,
and ImageAnnotation models, per docs/04-data-model.md.
 
Every candidate stores provider + model_version + confidence per the
cross-cutting provenance rule — never present an uncertain identification
as definitive, per docs/01-product-requirements.md.
"""

import enum

from sqlalchemy import Float, ForeignKey, Integer, JSON, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, generate_uuid

class IdentificationStatus(str, enum.Enum):
    pending = "pending"
    complete = "complete"
    needs_more_photos = "needs_more_photos"

class ConfidenceLabel(str, enum.Enum):
    high = "high"
    moderate = "moderate"
    low = "low"

class EvidenceDirection(str, enum.Enum):
    supports = "supports"
    contradicts = "contradicts"

class PlantIdentification(Base, TimestampMixin):
    __tablename__ = "plant_identifications"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"))
    # List of storage refs (URLs/keys) for the submitted photos — stored
    # as JSON rather than a separate table since images are always
    # fetched together as a set, never queried individually.
    images: Mapped[list] = mapped_column(JSON, default=list)
    status: Mapped[IdentificationStatus] = mapped_column(default=IdentificationStatus.pending)

    candidates: Mapped[list["IdentificationCandidate"]] = relationship(
        back_populates="identification", cascade="all, delete-orphan"
    )
    annotations: Mapped[list["ImageAnnotation"]] = relationship(
        back_populates="identification", cascade="all, delete-orphan"
    )

class IdentificationCandidate(Base, TimestampMixin):
    __tablename__ = "identification_candidates"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    identification_id: Mapped[str] = mapped_column(ForeignKey("plant_identifcations.id"))
    # Nullable: a candidate can come back with no confident species match
    # at all — the row still records that the provider considered and
    # rejected/couldn't match a possibility, per the "conflicting
    # evidence" requirement in docs/01-product-requirements.md.
    species_id: Mapped[str | None] = mapped_column(ForeignKey("plant_species.id"), nullable=True)
    confidence_score: Mapped[float] = mapped_column(Float)
    confidence_label: Mapped[ConfidenceLabel] = mapped_column()
    provider: Mapped[str] = mapped_column(String)
    model_version: Mapped[str | None] = mapped_column(String, nullable=True)
    rank: Mapped[int] = mapped_column(Integer) # 1-3 per "top three candidates"

    identification: Mapped["PlantIdentification"] = relationship(back_populates="candidates")
    species: Mapped["PlantSpecies | None"] = relationship()
    evidence: Mapped[list["IdentificationEvidence"]] = relationship(
        back_populates="candidate", cascade="all, delete-orphan"
    )

class IdentificationEvidence(Base, TimestampMixin):
    __tablename__ = "identification_evidence"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    candidate_id: Mapped[str] = mapped_column(ForeignKey("identification_candidates.id"))
    annotation_id: Mapped[str | None] = mapped_column(
        ForeignKey("image_annotations.id"), nullable=True
    )
    supports_or_contradicts: Mapped[EvidenceDirection] = mapped_column()
    explanation_text: Mapped[str] = mapped_column(String)

    candidate: Mapped["IdentificationCandidate"] = relationship(back_populates="evidence")
    annotation: Mapped["ImageAnnotation | None"] = relationship()

class ImageAnnotation(Base, TimestampMixin):
    __tablename__ = "image_annotations"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    identification_id: Mapped[str] = mapped_column(ForeignKey("plant_identifications.id"))
    image_ref: Mapped[str] = mapped_column(String)
    # Normalized 0.0-1.0 coordinates within the referenced image, so the
    # marker position is independent of the image's actual pixel
    # dimensions or any client-side resizing.
    x: Mapped[float] = mapped_column(Float)
    y: Mapped[float] = mapped_column(Float)
    # Free string rather than a rigid enum — docs/01-product-requirements.md
    # lists many possible feature types (leaf margin, vein pattern, stem
    # texture, flower structure, thorn location, disease lesion, ...)
    # without claiming that list is exhaustive.
    feature_type: Mapped[str] = mapped_column(String)
    label: Mapped[str | None] = mapped_column(String, nullable=True)

    identification: Mapped["PlantIdentification"] = relationship(back_populates="annotations")