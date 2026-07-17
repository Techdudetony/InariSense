# InariSense — API Integration Matrix & Cost Estimate

For each integration: purposem MVP vs. later, and what to verify before committing to it. Exact current pricing/quotas should be re-checked at implementation time — they-re not locked in here since they change independently of this document.

## Plant Identification

| Provider                 | Role                   | MVP?  | Notes to verify before integrating                                            |
| ------------------------ | ---------------------- | ----- | ----------------------------------------------------------------------------- |
| Pl@ntNet                 | Primary identification | Yes   | Rate limits, commercial-use terms, attribution requirements                   |
| Secondary provider (TBD) | Fallback/comparison    | Later | Do not average scores across providers without calibration — store separately |

## Botanical / Taxonomy

| Provider           | Role                                 | MVP?          | Notes                                                              |
| ------------------ | ------------------------------------ | ------------- | ------------------------------------------------------------------ |
| GBIF Species API   | Scientific name validation, taxonomy | Yes           | Free, but check attribution requirements                           |
| GBIF Occurence API | Geographic occurrence context        | Later         | Userful for native/invasive context, not required for core ID flow |
| iNaturalist API    | Community observation context        | Later         | Rate limits on free tier                                           |
| USDA PLANTS        | US plant data                        | Yes (US-only) | Confirm licensing for commercial use                               |

## Weather

| Provider                       | Role                             | MVP?  | Notes                                             |
| ------------------------------ | -------------------------------- | ----- | ------------------------------------------------- |
| National Weather Service (NWS) | US alerts, forecast              | Yes   | Free, US-only, no key required — good MVP default |
| Apple WeatherKit               | Cross-platform current/forecast  | Later | Paid beyond free tier, iOS-native advantage       |
| Open-Meteo                     | Cross-platform fallback / non-US | Later | Free tier limits to verify at scale               |

Decision for MVP: **NWS for US users** keeps cost at zero during MVP;  
international support is explicitly out of scope until a paid provider is justified by usre demand.

## Location / Geocoding

| Provider                                | Role                  | MVP? | Note                                                               |
| --------------------------------------- | --------------------- | ---- | ------------------------------------------------------------------ |
| Device native geolocation               | Foreground location   | Yes  | Never request background location                                  |
| Geocoding provider (Google/Apple/other) | Address + coordinates | Yes  | Compare per-request pricing at real usage volume before locking in |

## Zones & Climate

| Provider                       | Role                      | MVP?  | Notes                             |
| ------------------------------ | ------------------------- | ----- | --------------------------------- |
| USDA Plant Hardiness Zone data | Zone lookup               | Yes   | Free, US-only                     |
| Historical frost-date dataset  | Frost estimates           | Yes   | Confirm source and update cadence |
| PRISM climate data             | Advanced climate modeling | Later | Licensing check required          |

## Soil

| Provider          | Role                       | MVP?  | Notes                                                                                        |
| ----------------- | -------------------------- | ----- | -------------------------------------------------------------------------------------------- |
| USDA NRCS SSURGO  | US soil survey data        | Later | Complex API, valuable but not MVP-blocking                                                   |
| SoilGrids         | Global estimated soil data | Later | Service availability has historically been inconsistent — verify uptime before relying on it |
| Manual user entry | Lab test results           | Yes   | Always available regardless of provider status — required fallback                           |

## Notifications

| Provider                        | Role              | MVP? | Notes                                  |
| ------------------------------- | ----------------- | ---- | -------------------------------------- |
| Firebase Cloud Messaging        | Android push      | Yes  | Free at expected MVP scale             |
| Apple Push Notification service | iOS push          | Yes  | Free, requires Apple Developer account |
| Local notifications             | Offline reminders | Yes  | No external cost                       |

## Cost Estimate (MVVP, rough order of magnitude)

- **Identification (Pl@ntNet):** cost scales with per-image-analysis calls; needs to be modeled against expected daily active users once real pricing tiers are confirmed at build time.
- **Weather (NWS):** $0 — free US government API.
- **Geocoding:** low cost, typically per-request pricing; low volume during MVP.
- **Hosting (backend + Postgres + Redis + object storage):** small managed hosting tier is sufficient for MVP-scale traffic.
- **Push notifications:** $0 (FCM/APNs both free)

Actual dollar figures are deliberately not locked into this document — pricing changes independently of the architecture, and estimating from outdated numbers would be worse than flagging that this needs a fresh check against current pricing pages before the identification and geocoding integrations are built.

## Guiding Rule

Every provider chosen for MVP should have a **free or low-cost tier sufficient for early real users**, so cost isn't a blocker before there's any usage data to model against.
