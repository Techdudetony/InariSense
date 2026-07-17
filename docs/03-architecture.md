# InariSense — Technical Architecture

## 1. High-Level Overview

```
┌───────────────────────┐        ┌───────────────────────────┐
│   Flutter Mobile      │  HTTPS │        FastAPI            │
│   (iOS + Android)     │───────>│   Backend (Python)        │
│                       │<───────│                           │
│  - Riverpod state     │        │  - Auth                   │
│  - SQLite/Drift cache │        │  - Garden/Planting API    │
│  - Camera capture     │        │  - Identification adapter │
│  - Local notifications│        │  - Recommendation engine  │
└───────────────────────┘        │  - Reminder scheduler     │
                                 │  - Weather adjustment     │
                                 └───────────┬───────────────┘
                                             │
                     ┌───────────────────────┼───────────────────────┐
                     ▼                       ▼                       ▼
          ┌───────────────────┐   ┌───────────────────┐   ┌────────────────────┐
          │ PostgreSQL+PostGIS│   │  Redis            │   │ Object Storage     │
          │ (core data store) │   │  (cache/queues)   │   │ (user images)      │
          └───────────────────┘   └───────────────────┘   └────────────────────┘
                                            │
                    ┌───────────────────────┼───────────────────────────┐
                    ▼                       ▼                           ▼
          ┌──────────────────┐   ┌───────────────────┐       ┌────────────────────┐
          │ Pl@ntNet API     │   │ GBIF / iNaturalist│       │ Weather provider   │
          │ (identification) │   │ (taxonomy/occur.) │       │ (NWS/Open-Meteo)   │
          └──────────────────┘   └───────────────────┘       └────────────────────┘
```

## 2. Mobile App (Flutter)

- **State Management:** Riverpod.
- **Local storage:** SQLite via Drift, for offline garden/task caching.
- **Camera:** native camera + photo-library picker, guided multi-angle capture flow for identification and diagnosis.
- **Notifications:** local notifications for offline-safe reminders; push (FCM/APNs) for server-triggered weather-based reminders.
- **Accessibility:** dynamic text sizing, high-contrast mode, semantic labels on all interactive elements (including image markers).

## 3. Backend (FastAPI)

Organized as a modular monolith at this stage (not microservices) — the project doesn't yet have the scale or team size to justify the operational overhead of microservices, and a modular monolith keeps deployment simple while still enforcing separation of concerns internally.

Modules:

- `auth` — account creation, guest mode, tokens
- `gardens` — Garden, GardenBed, Container, Planting CRUD
- `identification` — photo upload, provider adapter calls, candidate/evidence storage
- `recommendation` — rule-based planting + task recommendation engine
- `weather` — provider adapter, current/forecast/historical separation
- `reminders` — scheduling + weather-conditional adjustment logic
- `diagnosis` — health diagnosis workflow
- `journal` — journal entries, photo timelines

## 4. Provider Adapter Pattern

Every external service (identification, weather, geocoding, soil data) is accessed throught an interface defined in our own codebase, not called directly from business logic. This means:

- Swapping Pl@ntNet for a second/fallback identification provider doesn't touch the recommendation engine.
- Every response is normalized into our own schema before storage, with provider name, model version, and retrieval timestamp preserved.
- Provider outages are caught at the adapter layer and surfaced as a labeled "data unavailable" state — never silently skipped.

## 5. Recommendation Engine

Rule-based and structured-data-first, as required by the product principles in `01-product-requirements.md`:

1. Structured facts (zone, frost dates, weather, plant requirements) feed a deteministic rules engine that produces the recommendation and its confidence/reasoning.
2. An optional LLM step may rephrase the structured output into friendlier prose — it receives the already-decided facts as input and is constrained to not introduce new facts.
3. Every recommendation object carries a `source` field per data point (e.g., frost date: NOAA historical average vs user override).

## 6. Weather-Conditional Reminders

Handled by a background worker (not just client-side scheduling):

1. Scheduler evaluates due/upcoming reminders per garden location on a recurring interval.
2. Pulls recent + forecast weather for that location.
3. Applies adjustment rules (e.g., recent rainfall → postpone watering, suggest soil check instead).
4. Pushes an updated reminder (with the adjustment reason) to the client.

## 7. Deployment (initial)

- Backend: containerized FastAPI app, deployed behind API gateway with rate limiting.
- Database: managed PostgreSQL with PostGIS extension enabled.
- Object storage: signed upload URLs issued by the backend; mobile app never holds provider credentials directly.
- CI: lint + test on every PR (added once the backend/mobile scaffolds exist — tracked as its own upcoming branch).

## 8. Explicitly Deferred (not in MVP architecture)

- Microservices split
- On-device ML (TensorFlow Lite/Core ML) — hosted API only for MVP
- Multi-region deployment
- Bluetooth sensor ingestion pipeline
