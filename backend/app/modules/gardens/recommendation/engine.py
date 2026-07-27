"""Rule-based planting recommendation engine (KAN-19).
 
Structured-data-first per docs/03-architecture.md — no LLM involvement in
determining dates, windows, or status. An LLM may later rephrase this
engine's output into friendlier prose, but never originates the facts
themselves.
 
Frost-date handling is the central design decision here: docs/06's known
gap means GardenLocation.estimated_last_frost/estimated_first_frost are
almost always None right now. Rather than refuse to produce a
recommendation, or silently fabricate a date, this engine:
1. Prefers real per-location frost dates whenever they exist (confidence
   "high").
2. Falls back to a general zone-average reference table (confidence
   "low") — clearly labeled as an approximation, never as real data.
3. Returns "insufficient_data" if neither is available, rather than
   guessing.
 
Every recommendation carries its confidence level and the reasoning notes
a user should see — matching the "how was this calculated?" /
"which source influenced this?" requirements in
docs/01-product-requirements.md.
"""

from dataclasses import dataclass, field
from datetime import date, timedelta

from app.modules.gardens.recommendation.zone_frost_reference import ZONE_FROST_REFERENCE

# Offsets (in days, relative to last frost date) defining the "ideal"
# planting window for each frost-tolerance category. These are common
# horticultural rules of thumb, not species-specific — a real v2 would
# let individual species override these, but v1 applies one rule per
# tolerance category across all species.
FROST_TOLERANCE_WINDOW_OFFSETS = {
    "hardy": (-28, 14), # cold-hardy crops can go in weeks before last frost
    "half_hardy": (-7, 21),
    "frost_sensitive": (7, 45) # wait until well after last frost
}

# v1 simplification: frost-sensitive crops default to "transplant" (the
# common case — tomatoes, peppers), everything else defaults to
# "direct_sow". A real v2 would need a per-species preferred-method field
# rather than inferring it from frost tolerance alone.
GROW_ON_DAYS_BEFORE_TRANSPLANT = 14

@dataclass
class DateWindow:
    start: date
    end: date

@dataclass
class PlantingRecommendation:
    species_id: str
    confidence: str # "high" | "low" | "none"
    frost_data_source: str # "garden_location" | "zone_average" | "unavailable"
    main_method: str | None # "direct_sow" | "transplant" | None
    main_window: DateWindow | None
    main_window_status: str # "early" | "ideal" | "late" | "unsuitable" | "insufficient_data"
    indoor_start_window: DateWindow | None
    harvest_window: DateWindow | None
    notes: list[str] = field(default_factory=list)

def _date_in_year(month: int, day: int, year: int) -> date:
    return date(year, month, day)

def _zone_average_frost_dates(zone: str, today: date) -> tuple[date | None, date | None] | None:
    entry = ZONE_FROST_REFERENCE.get(zone)
    if entry is None:
        return None

    last_month, last_day, first_month, first_day = entry
    this_year_last = _date_in_year(last_month, last_day, today.year)
    this_year_first = (
        _date_in_year(first_month, first_day, today.year) if first_month else None
    )

    # If this year's first frost has already passed, the relevant season
    # for planning purposes is next year's — otherwise a recommendation
    # generated in December would nonsensically point at a window months
    # in the past.
    if this_year_first is not None and today > this_year_first:
        year = today.year + 1
        last = _date_in_year(last_month, last_day, year)
        first = _date_in_year(first_month, first_day, year) if first_month else None
        return last, first

    return this_year_last, this_year_first

def resolve_effective_frost_dates(
        zone: str | None,
        estimated_last_frost: date | None,
        estimated_first_frost: date | None,
        today: date,
) -> tuple[date | None, date | None, str, str]:
    """Returns (last_frost, first_frost, source, confidence)"""
    if estimated_last_frost is not None:
        # first_frost may still be None even with a real last_frost known
        # (partial data) — that's fine, downstream logic already handles
        # first_frost being optional.
        return estimated_last_frost, estimated_first_frost, "garden_location", "high"

    if zone is not None:
        zone_dates = _zone_average_frost_dates(zone, today)
        if zone_dates is not None:
            last, first = zone_dates
            return last, first, "zone_average", "low"

    return None, None, "unavailable", "none"

def _compute_main_window(frost_tolerance: str, last_frost: date) -> DateWindow:
    start_offset, end_offset = FROST_TOLERANCE_WINDOW_OFFSETS[frost_tolerance]
    return DateWindow(
        start=last_frost + timedelta(days=start_offset),
        end=last_frost + timedelta(days=end_offset),
    )

def _compute_indoor_start_window(
        germination_days_min: int | None,
        germination_days_max: int | None,
        main_window_start: date,
) -> DateWindow | None:
    if germination_days_max is None:
        return None
    germ_min = germination_days_min if germination_days_min is not None else germination_days_max

    latest_start = main_window_start - timedelta(
        days=germ_min + GROW_ON_DAYS_BEFORE_TRANSPLANT
    )
    earliest_start = main_window_start - timedelta(
        days=germination_days_max + GROW_ON_DAYS_BEFORE_TRANSPLANT
    )
    return DateWindow(start=earliest_start, end=latest_start)

def _compute_harvest_window(
        maturity_days_min: int | None,
        maturity_days_max: int | None,
        planting_date: date,
) -> DateWindow | None:
    if maturity_days_min is None or maturity_days_max is None:
        return None
    return DateWindow(
        start=planting_date + timedelta(days=maturity_days_min),
        end=planting_date + timedelta(days=maturity_days_max),
    )

def _determine_window_status(
        today: date,
        window: DateWindow | None,
        first_frost: date | None,
        maturity_days_max: int | None,
) -> str:
    if window is None:
        return "insufficient_data"

    def _blocked_by_first_frost(check_date: date) -> bool:
        if first_frost is None or maturity_days_max is None:
            return False
        return (first_frost - check_date).days < maturity_days_max

    if today < window.start:
        return "early"

    if window.start <= today <= window.end:
        return "unsuitable" if _blocked_by_first_frost(today) else "ideal"

    # today > window.end
    return "unsuitable" if _blocked_by_first_frost(today) else "late"

def generate_recommendation(
        *,
        species_id: str,
        frost_tolerance: str | None,
        germination_days_min: int | None,
        germination_days_max: int | None,
        maturity_days_min: int | None,
        maturity_days_max: int | None,
        zone: str | None,
        estimated_last_frost: date | None,
        estimated_first_frost: date | None,
        today: date | None = None,
) -> PlantingRecommendation:
    today = today or date.today()

    last_frost, first_frost, frost_source, confidence = resolve_effective_frost_dates(
        zone, estimated_last_frost, estimated_first_frost, today
    )

    notes: list[str] = []
    if frost_source == "zone_average":
        notes.append(
            "No zone or frost data available for this garden location — cannot"
            "generate a planting window."
        )

    if frost_source == "unavailable" or frost_tolerance is None or last_frost is None:
        if frost_tolerance is None:
            notes.append("This species' frost tolerance is unknown.")
            return PlantingRecommendation(
                species_id=species_id,
                confidence="none",
                frost_data_source=frost_source,
                main_method=None,
                main_window=None,
                main_window_status="insufficient_data",
                indoor_start_window=None,
                harvest_window=None,
                notes=notes,
            )

        main_window = _compute_main_window(frost_tolerance, last_frost)
        main_method = "transplant" if frost_tolerance == "frost_sensitive" else "direct_sow"
        status = _determine_window_status(today, main_window, first_frost, maturity_days_max)

        indoor_window = None
        if main_method == "transplant":
            indoor_window = _compute_indoor_start_window(
                germination_days_min, germination_days_max, main_window.start
            )

        harvest_window = _compute_harvest_window(
            maturity_days_min, maturity_days_max, main_window.start
        )

        if maturity_days_max is None:
            notes.append("Maturity period unknown for this species — no harvest window estimate.")

        return PlantingRecommendation(
            species_id=species_id,
            confidence=confidence,
            frost_data_source=frost_source,
            main_method=main_method,
            main_window=main_window,
            main_window_status=status,
            indoor_start_window=indoor_window,
            harvest_window=harvest_window,
            notes=notes,
        )