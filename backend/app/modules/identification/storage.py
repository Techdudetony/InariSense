"""Local-disk image storage for identification uploads.
 
THIS IS AN MVP PLACEHOLDER, NOT THE REAL APPROACH. docs/03-architecture.md
specifies object storage with signed upload URLs for production — this
just writes to a local uploads/ folder so the identification endpoint has
something functional to store images in during development, without
requiring cloud storage setup first. Swapping this for real object
storage later means replacing save_image()'s implementation; callers
only depend on it returning a stable image_ref string, not on how/where
that ref resolves.
"""

import uuid
from pathlib import Path

UPLOAD_DIR = Path("uploads/identifications")

def save_image(image_bytes: bytes, original_filename: str) -> str:
    UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

    extension = Path(original_filename).suffix or ".jpg"
    stored_filename = f"{uuid.uuid4()}{extension}"
    destination = UPLOAD_DIR / stored_filename
    destination.write_bytes(image_bytes)

    return str(destination)