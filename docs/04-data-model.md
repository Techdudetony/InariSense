# InariSense — Data Model

This covers the core entities for the MVP. Fields are representative, not exhaustive — exact column types/migrations will be defined when the backend scaffold is built.

## User

- `id`, `email` (nullable for guest mode), display_name, created_at
- `notification_preferences` (→ `NotificationPreference`)

## Garden

- `id`, `user_id`, `name`, `garden_type` (`raised_bed` | `in_ground` | `container` | `indoor` | `greenhouse` | `hydroponic` | `community` | `orchard` | `lawn` | `landscape_bed`)
- `location_id` (→ `GardenLocation`)
- `sunlight_exposure`, `soil_type`, `soil_ph`, `drainage`, `irrigation_method`, `notes`

## GardenLocation

- `id`, `garden_id`, `latitude`, `longitude`, `resolved_address`, `usda_zone`,
  `estimated_last_frost`, `estimated_first_frost`, `zone_source`, `frost_source`,
  `retrieved_at`

## GardenBed / Container

- `id`, `garden_id`, `name`, `dimensions` (or `container_size`), `bed_depth`,
  `current_plantings` (→ `Planting[]`)

## PlantSpecies

- `id`, `common_name`, `scientific_name`, `category`, `native_status`,
  `toxicity_notes`, `invasive_flag`, `taxonomy_source` (GBIF id), `synonyms`

## PlantVariety

- `id`, `species_id`, `variety_name`, `days_to_maturity`, `notes`

## UserPlant

- `id`, `user_id`, `species_id`, `variety_id`, `nickname`, `source_identification_id`
  (nullable, → `PlantIdentification`)

## Planting

- `id`, `garden_bed_id` or `container_id`, `user_plant_id`, `planting_method`
  (`indoor_seed_start` | `direct_sow` | `transplant`), `indoor_start_date`,
  `transplant_date`, `direct_sow_date`, `estimated_germination_window`,
  `estimated_maturity_window`, `estimated_harvest_window`, `actual_harvest_date`

## PlantIdentification

- `id`, `user_id`, `submitted_at`, `images` (→ list of storage refs), `status`
  (`pending` | `complete` | `needs_more_photos`)

## IdentificationCandidate

- `id`, `identification_id`, `species_id` (nullable if unmatched), `confidence_score`,
  `confidence_label` (high | moderate | low), `provider`, `model_version`,
  `rank` (1–3)

## IdentificationEvidence

- `id`, `candidate_id`, `annotation_id` (→ `ImageAnnotation`, nullable),
  `supports_or_contradicts`, `explanation_text`

## ImageAnnotation

- `id`, `identification_id`, `image_ref`, `x`, `y`, `feature_type` (`leaf_margin` |
  `vein_pattern` | `stem_texture` | `flower_structure` | ... ), `label`

## CareTask

- `id`, `planting_id`, `task_type`, `priority`, `estimated_time`, `instructions`,
  `triggered_by` (`weather` | `schedule` | `growth_stage` | `manual`)

## Reminder

- `id`, `care_task_id`, `due_at`, `status` (`pending` | `completed` | `snoozed` |
  `skipped` | `rescheduled`), `adjustment_reason` (nullable), `adjustment_source`
  (nullable)

## TaskCompletion

- `id`, `reminder_id`, `completed_at`, `notes`, `photo_ref`

## WeatherSnapshot

- `id`, `garden_location_id`, `type` (`observed` | `forecast` | `historical_avg`),
  `captured_at`, `temperature`, `precipitation`, `wind`, `provider`, `retrieved_at`

## SoilProfile

- `id`, `garden_id`, `ph`, `texture`, `drainage`, `organic_carbon`, `source`
  (`user_entered` | `ssurgo` | `soilgrids`), `retrieved_at`

## SoilTest

- `id`, `soil_profile_id`, `tested_at`, `lab_name`, `results_json`

## PlantObservation

- `id`, `planting_id`, `observed_at`, `photos`, `notes`, `growth_stage`

## HealthDiagnosis

- `id`, `planting_id`, `submitted_at`, `photos`, `top_causes` (→ list w/ confidence),
  `urgency`, `professional_help_recommended`

## Treatment

- `id`, `diagnosis_id`, `treatment_type`, `applied_at`, `notes`, `is_chemical` (bool),
  `safety_warnings_shown` (bool)

## Harvest

- `id`, `planting_id`, `harvested_at`, `quantity`, `weight`, `quality_notes`

## JournalEntry

- `id`, `garden_id` or `planting_id`, `entry_type`, `created_at`, `photos`, `notes`

## ReferenceSource

- `id`, `title`, `url`, `jurisdiction`, `publisher`, `published_date`, `reviewed_date`,
  `applicable_species_or_pest`

## NotificationPreference

- `id`, `user_id`, `channel` (`push` | `local`), `reminder_types_enabled`

## APIProviderRecord

- `id`, `provider_name`, `service_type` (`identification` | `weather` | `soil` |
  `geocoding`), `model_version`, `last_success_at`, `last_failure_at`,
  `failure_count`

## Cross-Cutting Rule

Every entity populated from an external source stores **provider,
model/version, and retrieved_at** at minimum — this is what makes the "how
was this calculated?" and "which source influenced this?" UI promises from
the PRD actually possible to implement, rather than aspirational.
