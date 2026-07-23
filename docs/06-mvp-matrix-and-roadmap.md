# InariSense — MVP vs. Post-MVP Feature Matrix & Roadmap

## Feature Matrix

| Feature                                | MVP | Post-MVP               | Notes                                                     |
| -------------------------------------- | --- | ---------------------- | --------------------------------------------------------- |
| Account creation + guest mode          | ✅  |                        |                                                           |
| Location setup (GPS or manual)         | ✅  |                        |                                                           |
| USDA zone + frost date profile         | ✅  |                        |                                                           |
| Location-based planting calendar       | ✅  |                        | Weather-adjusted, not zone-only                           |
| Camera photo capture (guided)          | ✅  |                        |                                                           |
| Top-3 plant ID with confidence         | ✅  |                        |                                                           |
| Interactive image markers              | ✅  |                        | Core differentiator — stays in MVP despite complexity     |
| "Why identified" explanations          | ✅  |                        |                                                           |
| Basic garden inventory                 | ✅  |                        | Gardens, beds/containers, plantings                       |
| Watering/feeding/harvest reminders     | ✅  |                        |                                                           |
| Weather-aware reminder adjustment      | ✅  |                        | Requires backend scheduler, not just local notifications  |
| Garden journal                         | ✅  |                        |                                                           |
| Offline access (saved gardens/tasks)   | ✅  |                        |                                                           |
| Privacy controls (delete data/account) | ✅  |                        |                                                           |
| Disease/pest-specific identification   |     | ✅                     | Separate diagnosis workflow, more provider dependencies   |
| Visual garden-bed layout planner       |     | ✅                     | Significant custom UI effort, not required for core value |
| Crop rotation guidance                 |     | ✅                     | Needs multi-season history to be useful                   |
| Companion planting                     |     | ✅                     | Can layer onto existing PlantSpecies data later           |
| Seed inventory                         |     | ✅                     |                                                           |
| Harvest analytics / yield forecasting  |     | ✅                     | Needs harvest history to be meaningful                    |
| Smart/Bluetooth sensor integration     |     | ✅ (premium candidate) | Hardware dependency                                       |
| Community-verified identifications     |     | ✅                     | Needs moderation design first                             |
| Local extension-office integration     |     | ✅                     | Content curation pipeline needed                          |
| Seasonal garden reports                |     | ✅                     |                                                           |
| Microclimate learning                  |     | ✅ (premium candidate) | Needs usage data to train against                         |
| Voice-based garden logging             |     | ✅                     | Accessibility win, not launch-blocking                    |

## Why the Line Is Drawn Here

The MVP set is everything required for Journeys A–D in
`02-personas-and-journeys.md` to work end-to-end. Anything that requires
history the app hasn't collected yet (yield forecasting, microclimate
learning, crop rotation) is structurally post-MVP — it can't be good on day
one regardless of engineering effort, so building it early wouldn't help
users yet.

## Roadmap (phased)

**Phase 0 — Docs** ✅ **Complete**
Product requirements, personas, architecture, data model, API matrix, this
feature matrix.

**Phase 1 — Scaffolding** ✅ **Complete**
`mobile/` Flutter project scaffold, `backend/` FastAPI project scaffold.
CI setup and mock services for offline development were originally
scoped here but haven't been built yet — deferred, not forgotten; see
note under Phase 2.

**Phase 2 — Core Data Layer** ⚠️ **Backend complete, mobile sync not started**
Done: database schema + Alembic migrations for all MVP entities; full
CRUD API for Garden, GardenBed, Planting, PlantSpecies, UserPlant; auth
module (registration + guest mode). Every entity in the chain is now
API-testable end to end.
Not done: mobile local cache (Drift) wired to backend sync — this was
originally scoped into Phase 2 but hasn't been touched yet, since all
work so far has been backend-only. It's fair game to pull into Phase 3
alongside the planting calendar UI, or treated as its own short phase —
worth deciding explicitly rather than letting it silently slip.
Also not done: CI setup, mock services (both originally scoped in
Phase 1) — still open.

**Phase 3 — Location & Planting Calendar**
Location setup flow, zone/frost resolution, recommendation engine v1
(rule-based), planting calendar UI.

**Phase 4 — Identification**
Guided photo capture, Pl@ntNet adapter, candidate/evidence storage,
interactive marker UI (highest-risk UI work — budget extra time here).

**Phase 5 — Reminders & Weather**
Weather adapter, background scheduler, weather-conditional reminder logic,
push notification wiring.

**Phase 6 — Journal & Polish**
Garden journal, photo timeline comparisons, accessibility pass, offline
edge-case handling, privacy controls audit.

**Phase 7 — Post-MVP**
Revisit the "Post-MVP" column above, re-prioritized based on real usage
from Phases 1–6.

## Suggested Jira Milestone Mapping

Each phase above maps to a Jira milestone, with the epics from
`02-personas-and-journeys.md` distributed across Phases 3–6 in the order
listed. Phase 1–2 epics (scaffolding, data layer) don't map to a persona
journey directly — they're infrastructure prerequisites and can be tracked
as their own "Foundation" epic.
