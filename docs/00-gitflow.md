# GitFlow Working Agreement

## Branches

| Branch      | Purpose                               | Merges into          |
| ----------- | ------------------------------------- | -------------------- |
| `main`      | Production releases only              | —                    |
| `develop`   | Integration branch, always buildable  | `main` (via release) |
| `feature/*` | One focused unit of work              | `develop`            |
| `release/*` | Stabilize before a production release | `main` + `develop`   |
| `hotfix/*`  | Urgent production fix                 | `main` + `develop`   |

## Feature Branch Naming

`feature/<area>-<short-description>`, e.g.:

- `feature/repo-scaffold`
- `feature/docs-prd`
- `feature/mobile-camera-capture`
- `feature/backend-identification-adapter`

## Working Increment Size

Each feature branch should correspond to **1-2 files or one narrow slice of functionality** — small enough to review in one sitting. This is deliberate: the project is large, and small PRs keep it followable step by step rather than arriving as large, hard-to-review drops.

## PR Checklist (once code branches start)

- [ ] Scope matches the branch name (no drive-by unrelated changes)
- [ ] Tests added/updated where applicable
- [ ] Docs updated if the change affects architecture or data model
- [ ] No hard-coded secrets
- [ ] Placeholder/mock functionality is clearly labeled as such

## Current Sequence (docs phase)

1. `feature/repo-scaffold` ← **you are here** (README + this file)
2. `feature/docs-prd` — product requirements doc, personas, user journeys
3. `feature/docs-architecture` — technical architecture + data model
4. `feature/docs-api-matrix` — API/integration matrix, cost estimate
5. `feature/docs-mvp-matrix` — MVP vs. post-MVP feature matrix, roadmap
   After the docs phase, we'll open a fresh sequence for `mobile/` and
   `backend/` scaffolding, then feature-by-feature implementation.
