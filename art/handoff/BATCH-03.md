# Batch 03 handoff (2026-11-04): D13, Rares/Epics, full-roster sheet

Box-side only: Parts only; no Studio, meshes, scripts or Store assets; the user's computer and the repo were not touched. All previews are NOT Studio proof.

## 0. D13: Dover Demon Neon eyes
- Logged in `style-guide.md` (decision table, §2 Neon rule, §6 budget line, Resolved list): Neon GoldBright on the Dover Demon's `Eye_R`/`Eye_L` **only**; placeholders stay Glass.
- `DoverDemon.rbxmx` rebuilt as **AssetVersion 1.1** (24 parts, unchanged otherwise). Handoff updated, including a new bloom check.
- `validate_rbxmx.py` now has a built-in **`NEON_ALLOW` by CryptidId** (`mothman_hatchling`, `dover_demon` → `Eye_R`, `Eye_L`). It never applies to `IsPlaceholder` models. Negative tests: Neon on a Jackalope eye → FAIL; Neon on `DoverDemon_PH` → FAIL. Mothman no longer needs `--neon`.

## Steering: roster sizes accepted (Growth Strategist, spec 09)
- Fresno 6 × 3.3, Hidebehind 8 × 5, Hodag 3 × 6 are now in `roster-provisional.md`. Marked **RESOLVED** in the BATCH-02 size table and `asset-list.md`.
- The 3 placeholders were regenerated at the new sizes (measured H × L: 6.0 × 3.3, 8.0 × 5.0, 3.0 × 6.0) and PASS.
- ⚠️ **Hidebehind is the Starter Pack grant, so its readability is a HIGH-PRIORITY Studio check.** This is flagged in its handoff note and in the asset list.

## 1. Rare / Epic full models (v1.0, large-cryptid cap 80 parts)
| Model | CryptidId | Parts | H × L built vs roster | Design (1 line) | Passes |
|---|---|---|---|---|---|
| FlatwoodsMonster | `flatwoods_monster` (Rare) | 40 | 9.0 × 5.0 vs 9 × 5 (0% / 0%) | Crimson ace-of-spades hood around a Void face with small gold Glass eyes, tiered pleated skirt body, long arms with bone claws; silver trims | 1 |
| BeastOfBrayRoad | `beast_of_bray_road` (Rare) | 48 | 5.95 × 7.4 vs 6 × 7 (−1% / +6%) | Hunched wolf-beast on all fours, big shoulder hump with silver mane spikes, low wolf head, fangs, crimson Glass eyes, bone claws | 0 |
| JerseyDevil | `jersey_devil` (Epic) | 58 | 8.0 × 7.1 vs 8 × 7 (0% / +1%) | Crouched, kangaroo-legged, horse-skull head, curved bone horns, bat wings, hooves, crimson mane, spines and forked tail | 0 |
| LochNessSerpent | `loch_ness_serpent` (Epic) | 44 | 9.0 × 8.0 vs 9 × 8 (0% / 0%) | Segmented neck rising from a base, 2 humps resting on the base (no water), pale throat plates, crimson fins, bone horn nubs, flippers | 0 |

Rarity cues (§3): Rare = Silver trim + crest-like shape (hood rim / mane); Epic = Blood accent + horns. All eyes are Glass (no Neon). Each model has its `.rbxmx`, front34 + side previews (viewed), a handoff note with the 16-point checklist, an asset-list §9 status, and roster art status. New helpers in `build_assets.py`: `chain`, `disc`, `vcyl`. New `tools/write_handoff.py` generates handoff notes.

## 2. Validation + Rojo
- `validate_rbxmx.py`: **14/14 PASS** (12 cryptids + Pad + BoneAltar); **12/12 roster placeholders PASS**; **16/16 kit samples PASS**.
- Throwaway Rojo 7.4.4 build (`/tmp/rt3`, `.rbxlx` + `.rbxl`): **PASS**. Cryptids 12 models / 411 parts, Lair 2 / 59, Placeholders 12 / 147. 26 PivotOffsets; exactly 4 Neon parts (Mothman + Dover eyes).
- Rojo mapping is the same as in BATCH-02, with the 4 new files added to `assets/cryptids/`. Copy only `.rbxmx` files; never `*.parts.json` or `placeholders/samples/`.

## 3. Full-roster contact sheet
- `qa/screenshots/Roster12_2026-11-04_preview-sheet.png` (3/4) + `Roster12_2026-11-04_preview-sheet-side.png`: all 12 FULL models at **one shared scale** (true relative size), labelled NOT Studio proof. `preview_parts.py` now has a `ZOOM` env var (sheet rendered with `ZOOM=1.35 COLS=4`).

## PENDING (Studio-only)
1. **Hidebehind readability (HIGH PRIORITY, Starter Pack).**
2. Wedge facing: this batch adds the Flatwoods hood spade, Jersey Devil wing membranes and tail fork, Bray mane and claws, and Loch Ness fins and flippers.
3. Dover Demon Neon eyes under Bloom (0.4 / 24 / 1.6); Neon ≤ 2% of view.
4. Flatwoods skirt may read as a stacked "cake"; Loch Ness is narrow front-on (3.3 wide), so it reads best from 3/4 or side.
5. Dark bodies (Bray, Jersey, Loch Ness, Snallygaster) in Play lighting; pad billboard clearance for the 9-stud Flatwoods and Loch Ness.
6. Studio screenshots for all 12 (D12: icon/thumbnails), pivots on `Pad.CryptidMount`, Highlight limit (D8), triangle counts.
