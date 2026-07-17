# InariSense

A cross-platform gardening app that combines location-aware planting guidance, camera-based plant identification with explainable AI markers, weather-adjusts reminders, and an educational "why" behind every recommendation.

## Confirmed Stack

**Mobile:** Flutter (Dart), Riverpod for state management, local SQLite/Drift for offline cache, camera + photo-library integration.

**Backend:** FastAPI (Python), PostgreSQL + PostGIS for geospatial queries, Redis for caching and scheduled work (weather refreshes, reminder evaluation), object storage for user-uploaded images with signed upload URLs.

**AI / Identification layer:** Provider-agnostic adapter (Pl@ntNet as primary), taxonomy reconciliation against GBIF, rule-based recommendation engine first — generative AI is used only to explain structured results, never to originate botanical facts, planting dates, or treatment advice.

## Repo Layout

```
inarisense/
├── mobile/       # Flutter app
├── backend/      # FastAPI service
├── docs/         # PRD, architecture, data model, API matrix, etc.
└── .github/
    └── workflows/  # CI (lint, test, build) — added once first code lands
```

## Branching Strategy

This repo follows GitFlow:

- `main` - release-only, always deployable
- `develop` - integration branch, all feature branches merge here first
- `feature/*` - one focused unit of work per branch (see `docs/00-gitflow.md`)
- `release/*` - release stabilization
- `hotfix/*` - urgent fixes off `main`

# Status

Scaffold Phase — no application code yet. See `docs/` for the product requirements, architecture, and roadmap being built out before implementation begins.
