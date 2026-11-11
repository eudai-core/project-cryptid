# Spec 13: Seasonal layer v1 (studio lead ruling, 5 Nov 2026)
Goal: Cryptid feels right in any month (launch lands in December) without breaking the dark-occult identity, and plays well for every audience and region.

## Season resolver (server, deterministic)
- SeasonService picks the season from os.time() UTC month, northern-hemisphere default: Winter Dec-Feb, Spring Mar-May, Summer Jun-Aug, Autumn Sep-Nov.
- Overrides: a workspace attribute `SeasonOverride` (Studio/testing only), plus a DataStore-free constant table so live ops can force a season by code push.
- Replicate the season via a ReplicatedStorage attribute; clients only read it.

## What a season changes (cosmetic only, zero economy/odds impact)
| Season | Town/lair look | Atmosphere | Ambient |
|---|---|---|---|
| Winter (launch) | snow caps on roofs/paths (Snow material), frost on fences, a few warm lanterns with holly-like dark-green wreaths, bare trees | colder grade, light snowfall particles (low rate, off on Low quality) | wind + distant bells |
| Spring | moss, pale flowers, mist | softer fog | birds at dawn |
| Summer | long dusk, fireflies (reuse the fog-wisp budget) | warm haze | crickets |
| Autumn | leaves, pumpkins/candles | current default look | crows |
- Every seasonal prop is server-built from code using the existing palette (no new store assets, no Neon). It must stay inside the plot light cap of 8 and the part budgets.
- A seasonal swap lives in one module per season, so it's easy to add new ones.

## Seasonal content (Update 1+, not launch)
- Winter event "The Long Night" reuses the Fog Night event framework with a snow skin, plus 1 winter-variant cryptid look (cosmetic, earn-only).
- No limited-time paid items, FOMO timers or paid random seasonal crates (policy and our earn-only rule).

## Universal-play rules (all seasons)
- Keep horror mild: no gore and no jump-scares, to stay within our Content Maturity target.
- No region-specific holidays named in UI text ("winter" rather than "Christmas"). Text goes through LocalizationService-ready string keys.
- Phone-first readability holds in every season (snow must not hide UI or pads).

## Acceptance
- SeasonOverride swaps all 4 looks live in Studio, with no errors and part/light budgets held.
- Winter is active by default if the date is in Dec-Feb.
- A lune test covers the month-to-season mapping.
