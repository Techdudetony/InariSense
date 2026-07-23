"""One-time dev seed script.
 
Run this once against your local dev DB to create the minimum prerequisite
records (User, Garden, GardenBed, PlantSpecies, UserPlant) needed to
manually test Planting endpoints through /docs — since those entities
don't have their own create endpoints yet.
 
Usage (from backend/):
    python scripts/seed_dev_data.py
 
Safe to run more than once — it checks for existing seed data by email
before inserting again, so it won't create duplicates on rerun.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app import models
from app.database import SessionLocal, engine

SEED_EMAIL = "dev-seed@example.com"

def main() -> None:
    models.Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    existing = db.query(models.User).filter_by(email=SEED_EMAIL).first()
    if existing:
        print("Seed data already exists - reusing it instead of duplication.")
        user = existing
        garden = user.gardens[0]
        bed = garden.beds[0]
        user_plant = user.user_plants[0]
    else:
        user = models.User(email=SEED_EMAIL, display_name="Dev Seed User")
        db.add(user)
        db.flush()

        garden = models.Garden(user_id=user.id, name="Seed Garden", garden_type=models.GardenType.raiser_bed)
        db.add(garden)
        db.flush()

        bed = models.GardenBed(garden_id=garden.id, name="Seed Bed 1")
        db.add(bed)
        db.flush()

        species = models.PlantSpecies(common_name="Tomato", scientific_name="Solanum lycopersicum")
        db.add(species)
        db.flush()

        user_plant = models.UserPlant(user_id=user.id, species_id=species.id, nickname="Seed Tomato")
        db.add(user_plant)
        db.commit()

    print()
    print("Seed data ready - use these IDs in /docs to test Planting endpoints:")
    print(f"  user_id:      {user.id}")
    print(f"  garden_id:      {garden.id}")
    print(f"  garden_bed_id:      {bed.id}")
    print(f"  user_plant_id:      {user_plant.id}")
    print()
    print("Example POST /plants/ body")
    print(
        f' {{"garden_bed_id": "{bed.id}", "user_plant_id": "{user_plant.id}", '
        f'"planting_method": "transplant", "transplant_data": "2026-05-01"}}'
    )

    db.close()

if __name__ == "__main__":
    main()