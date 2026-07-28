"""Smoke test for Garden CRUD — establishes the pattern (real TestClient,
real seeded data, real assertions) for tests added to other endpoints
going forward. Not exhaustive coverage of every endpoint; a starting
point, not a finished suite.
"""

from fastapi.testclient import TestClient

from app import models
from app.database import SessionLocal
from app.main import app


def test_garden_create_get_update_delete():
    client = TestClient(app)

    db = SessionLocal()
    user = models.User(email="ci-test@example.com")
    db.add(user)
    db.commit()
    user_id = user.id
    db.close()

    create_response = client.post(
        "/gardens/", json={"user_id": user_id, "name": "CI Test Garden", "garden_type": "raised_bed"}
    )
    assert create_response.status_code == 201
    garden_id = create_response.json()["id"]

    get_response = client.get(f"/gardens/{garden_id}")
    assert get_response.status_code == 200
    assert get_response.json()["name"] == "CI Test Garden"

    patch_response = client.patch(f"/gardens/{garden_id}", json={"soil_ph": 6.5})
    assert patch_response.status_code == 200
    assert patch_response.json()["soil_ph"] == 6.5
    assert patch_response.json()["name"] == "CI Test Garden"

    delete_response = client.delete(f"/gardens/{garden_id}")
    assert delete_response.status_code == 204

    confirm_response = client.get(f"/gardens/{garden_id}")
    assert confirm_response.status_code == 404