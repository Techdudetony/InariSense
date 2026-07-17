# InariSense — Product Requirements Document

## 1. Vision

InariSense is a cross-platform garden companion that helps beginner and intermediate gardeners decide what to plant, identify plants through the camera, maintain their gardens, diagnose problems, and receive location-aware, weather-adjusted guidance — with a clear explanation behind every recommendation.

## 2. Problem Statement

Most gardening apps either:

- Give static, one-size-fits-all planting calendars that ignore actual weather and microclimates, or
- Offer plant identification as a black box with a single "answer" and no explanation of confidence or reasoning.

Beginners are left unsure _why_ they should do something, and experienced gardeners don't get enough detail to trust the recommendation over their own judgment. InariSense's differentiator is explainability: every recommendation states what, when, why, how, the risk of delay, the confidence level, and the data source behind it.

## 3. Goals (v1 / MVP)

1. Location-based planting calendar, adjusted for real weather — not just USDA hardiness zone.
2. Camera-based plant identification returning top-3 candidates with confidence, never a single "definitive" answer.
3. Interactive visual markers on identification photos, explaining which features drove the result.
4. Personal garden inventory (gardens, beds, containers, plants).
5. Weather-aware reminders that adjust or postpone based on real conditions.
6. Garden journal for logging progress over time.
7. Works offline for previously loaded garden/tasks.
8. Transparent privacy controls (location, images, account deletion).

## 4. Non-Goals (v1)

- Disease/pest-specific identification (separate diagnosis workflow — post-MVP).
- Visual garden-beed layout planner (post-MVP).
- Bluetooth soil sensor integration (post-MVP).
- Community-verified identifications (post-MVP).
  On-device ML models (MVP uses a hosted identification API only).

## 5. Success Criteria

- A user with zero gardening experience can go from "I have a spot in my yard" to "I know what to plant and when" without leaving the app.
- Every identification result and every recommendation can be traced back to a stated data source or confidence level — nothing is presented as fact without a source.
- The app never fabricates a recommendation when required data (frost dates, weather, soil data) is unavailable; it says so and offers a manual fallback.

## 6. Core Principles (carried through every feature)

- **Structured data and rules first, generative AI second.** An LLM may explain a result in plain language; it must never originate a species fact, planting date, toxicity claim, or treatment instruction.
- **Confidence is always shown, never implied.** High / Moderate/ Low/ More photos needed — never a bare "this is X."
- **Provenance is tracked.** Every externally sources fact stores its provider, model version, and retrieval date.
- **Graceful degradation.** Missing data is disclosed, not papers over.

## 7. Target Platforms

iOS and Android, via a single Flutter codebase.

## 8. Out of Scope for This Document

Technical architecture, data model, and API intergration details are covered in `docs/03-architecture.md` (next in the docs sequence). This document covers product intent, users, and requirements only.
