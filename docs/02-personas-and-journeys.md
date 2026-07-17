# InariSense — User Personas & Primary Journeys

## Personas

### 1. Dana — Total Beginner

- First apartment with a small balcony, two containers.
- Has never grown anything. Doesn't know what "hardening off" means.
- Needs plain-language explanations and reassurance, not jargon.
- Primary fear: killing the plant without knowing why.

### 2. Marcus — Intermediate Backyard Gardener

- Has an in-ground vegetable bed, 3 seasons of experience.
- Knows the basics but wants to optimize timing and catch problems early.
- Wants companion planting and succession planting guidance.
- Primary fear: missing a pest problem until it's too late.

### 3. Priya — Plant-Curious Hiker

- Uses the identification feature mostly for plants encountered outdoors, not just her own garden.
- Cares about native/invasive status and toxicity warnings for her dog.
- Primary fear: misidentifying a poisonous plant as safe.

## Primary User Journeys (MVP)

### Journey A: First-Time Setup → First Planting Recommendation

1. User opens app, chooses guest mode or creates an account.
2. Grants or declines location access; if declined, enters ZIP manually.
3. App resolves USDA zone + estimated frost dates, clearly labeled as "estimated" with source.
4. User selects garden type (container, in-ground, etc.) and experience level.
5. App shows a filtered planting calendar with recommendations, each showing what/when/why/how/risk-of-delay/confidence/source.
6. User adds a plant to "My Garden," creating their first `Planting` record.

### Journey B: Identify an Unknown Plant

1. User opens Identify tap, is guided through taking multiple angle photos.
2. Photots are uploaded; top-3 candidates return with confidence levels.
3. User taps interactive markers on the photo to see which features supported or contadicted each candidate.
4. If confidence is low, app requests a specific additional photo (e.g. leaf underside).
5. User confirms a match, optionally adds it to their garden inventory.

### Journey C: Weather-Adjusted Reminder

1. Scheduled watering reminder is due.
2. Backend checks recent rainfall for the user's garden location.
3. Reminder is automatically postponed with an explanation ("meaningful rainfall occurred — check soil moisture before watering") instead of firing on a fixed schedule.
4. User can still override and mark complete, snooze, or skip.

### Journey D: Diagnose a Problem

1. User notices something wrong with a plant, opens Diagnose workflow.
2. Uploads photos, answers guided questions (recent waterinfs, weather, visible damage pattern).
3. App returns top possible causes with confidence and supporting/conflicting evidence.
4. Low-risk actions are suggested first; any chemical treatment mention includes label/regulation/pollinator warnings.
5. User logs the treatment in the garden journal.

## Notes for Jira Epic Mapping

Each journey above maps cleanly to a Jira epic:

- Epic: Location & Zone Setup → Journey A (steps 1–3)
- Epic: Planting Calendar → Journey A (steps 4–6)
- Epic: Plant Identification → Journey B
- Epic: Weather-Aware Reminders → Journey C
- Epic: Health Diagnosis → Journey D
  This mapping is expanded into a full epic/story breakdown in the next
  message, since Jira board structure isn't a docs-phase file — it's a
  project-management artifact you'll build directly in Jira.
