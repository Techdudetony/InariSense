"""USDA zone -> approximate frost date reference table.
 
THIS IS A FALLBACK, NOT REAL DATA. It's a general, widely-used
approximation of typical last/first frost timing per USDA hardiness
zone — not specific to any actual location within that zone. It exists
because docs/06-mvp-matrix-and-roadmap.md's known gap (KAN-15: no real
frost-date-by-location provider is wired in yet) would otherwise leave
the recommendation engine with zero frost information to work from at
all.
 
Whenever a GardenLocation has real estimated_last_frost/
estimated_first_frost values (once KAN-15's gap is eventually closed with
a real historical dataset), those values MUST be preferred over this
table — this fallback exists only for the current in-between state, and
every recommendation built from it must be labeled with low confidence,
never presented as equivalent to real location data.
 
Values are (month, day) tuples representing a typical/average date within
each zone — genuinely approximate, and deliberately not precise to the
day for any real place.
"""

# zone -> (last_frost_month, last_frost_day, first_frost_month, first_frost_day)
# None for first_frost fields means "effectively frost-free" (zones 11a/11b).
ZONE_FROST_REFERENCE: dict[str, tuple[int, int, int | None, int | None]] = {
    "3a": (6, 1, 9, 1),
    "3b": (5, 20, 9, 15),
    "4a": (5, 15, 9, 20),
    "4b": (5, 10, 9, 25),
    "5a": (5, 5, 10, 1),
    "5b": (4, 25, 10, 10),
    "6a": (4, 20, 10, 15),
    "6b": (4, 15, 10, 20),
    "7a": (4, 5, 10, 30),
    "7b": (3, 30, 11, 5),
    "8a": (3, 20, 11, 15),
    "8b": (3, 10, 11, 20),
    "9a": (2, 20, 12, 1),
    "9b": (2, 10, 12, 10),
    "10a": (1, 30, 12, 15),
    "10b": (1, 15, 12, 25),
    "11a": (1, 1, None, None),
    "11b": (1, 1, None, None),
}