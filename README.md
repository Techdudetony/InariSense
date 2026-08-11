# InariSense

A cross-platform gardening app that combines location-aware planting guidance,
camera-based plant identification with explainable AI markers, weather-adjusted
reminders, and an educational "why" behind every recommendation.

## Status

Actively in development. Backend and mobile app both run locally end to end.

**Done:** Foundation (repo/GitFlow/scaffolds), core data layer (DB schema,
migrations, CRUD APIs for gardens/beds/plantings/species/users), basic auth
(registration + guest mode), location & zone setup (geocoding, USDA zone
resolution, saved garden locations), planting calendar (rule-based
recommendation engine with honest low-confidence fallbacks where real data
isn't available), garden management (full mobile UI for gardens/beds/
plantings), a real design system (Flutter theme, status/confidence styling),
and CI (lint + tests on every PR).

**In progress:** Plant identification — data model and the Pl@ntNet provider
adapter are done and verified against the real API; the actual upload
endpoint, guided capture screen, results screen, and interactive image-marker
system are still ahead.

**Not started yet:** Weather-aware reminders, health diagnosis, garden
journal, mobile offline sync (Drift), and mock services for offline
development (this last one is a known, explicitly tracked gap, not an
oversight).

See `docs/06-mvp-matrix-and-roadmap.md` for the full phase breakdown and
`docs/07-design-system.md` for the design tokens. Day-to-day work is tracked
on the project's Jira board (Kanban), with every epic tied back to a user
journey from the original planning docs.

## Confirmed Stack

**Mobile:** Flutter (Dart), Riverpod for state management, local SQLite/Drift
for offline cache (not yet wired to backend sync — tracked gap), camera +
photo-library integration, `geolocator`/`geocoding` for location, a session
bootstrap that creates a persistent guest user on first launch.

**Backend:** FastAPI (Python), SQLAlchemy + Alembic (SQLite for local dev,
PostgreSQL + PostGIS planned for production), `ruff` for linting, `pytest`
for tests (including a real migration-integrity test that runs actual
`alembic upgrade`/`downgrade`, not a mock).

**AI / Identification layer:** Provider-agnostic adapter pattern — Pl@ntNet
is the identification provider, Nominatim (OpenStreetMap) handles geocoding,
phzmapi.org resolves USDA zones. Every external call is verified for real
before merging, not just unit-tested against mocks. The recommendation
engine is rule-based and structured-data-first; generative AI, if used later,
would only rephrase results into friendlier prose — never originate
botanical facts, planting dates, or treatment advice.

## Getting Started

### Backend

```bash
cd backend
python -m venv venv
source venv/Scripts/activate   # Git Bash on Windows; venv\Scripts\activate for PowerShell/cmd
pip install -r requirements.txt
pip install -r requirements-dev.txt   # for linting/tests
alembic upgrade head
uvicorn app.main:app --reload
```

API docs available at `http://127.0.0.1:8000/docs` once running.

Add a `.env` file in `backend/` (never committed) for local secrets, e.g.:

```
PLANTNET_API_KEY=your-key-here
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

Requires a running backend. On an Android emulator, the app expects the API
at `http://10.0.2.2:8000` (see `lib/core/api_client.dart` for the platform-
specific baseURL notes — this is the most common source of "connection
refused" errors during local development).

### Tests

```bash
cd backend
ruff check .
pytest tests/ -v
```

```bash
cd mobile
flutter analyze
flutter test
```

## Repo Layout

```
inarisense/
├── mobile/               # Flutter app
│   ├── lib/
│   │   ├── core/         # API client, theme, session bootstrap
│   │   └── features/     # One folder per feature area
│   └── test/
├── backend/               # FastAPI service
│   ├── app/
│   │   ├── core/         # Settings
│   │   ├── models/       # SQLAlchemy models
│   │   ├── schemas/      # Pydantic schemas
│   │   └── modules/      # One folder per feature area (routers, providers)
│   ├── alembic/          # Migrations
│   ├── tests/            # pytest
│   └── scripts/          # Dev utilities (e.g. seed data)
├── docs/                  # PRD, architecture, data model, API matrix, roadmap, design system
└── .github/
    └── workflows/         # CI (lint + test on every PR)
```

## Branching Strategy

This repo follows GitFlow:

- `main` — release-only, always deployable
- `develop` — integration branch, all feature branches merge here first
- `feature/*` — one focused unit of work per branch (see `docs/00-gitflow.md`)
- `release/*` — release stabilization
- `hotfix/*` — urgent fixes off `main`

Feature branches are kept small — 1-2 files or one narrow slice of
functionality per PR — so changes stay reviewable.
