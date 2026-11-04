# Provisional launch roster (12 cryptids)

**Source:** Growth Strategist, matching `specs/09-launch-roster-and-monetisation.md` §3 (Draft v1, Wed 4 Nov 2026). **Status: PROVISIONAL (~70% sure).** Species may change before the **Fri 13 Nov freeze**; ids won't change once art starts (spec 09).
Dates: art due ~Mon 9 Nov · freeze Fri 13 Nov · launch Fri 20 Nov.

| # | Name | CryptidId | Rarity | Body | HxL |
|---|---|---|---|---|---|
| 1 | Mothman Hatchling | mothman_hatchling | Common | winged | 4.6x3.6 |
| 2 | Fresno Nightcrawler | fresno_nightcrawler | Common | biped | 6x3.3 |
| 3 | Hidebehind | hidebehind | Common | biped | 8x5 |
| 4 | Hodag | hodag | Common | quadruped | 3x6 |
| 5 | Jackalope | jackalope | Uncommon | quadruped | 3x4 |
| 6 | Dover Demon | dover_demon | Uncommon | biped | 4x3 |
| 7 | Snallygaster | snallygaster | Uncommon | winged | 5x7 |
| 8 | Loveland Frogman | loveland_frogman | Uncommon | biped | 5x3 |
| 9 | Flatwoods Monster | flatwoods_monster | Rare | biped | 9x5 |
| 10 | Beast of Bray Road | beast_of_bray_road | Rare | quadruped | 6x7 |
| 11 | Jersey Devil | jersey_devil | Epic | winged | 8x7 |
| 12 | Loch Ness Serpent | loch_ness_serpent | Epic | serpent | 9x8 |

- **Sizes** are height × length in studs (spec 09 marks them [A]). For the art checks, **L = the longest horizontal extent** of the visible model (span or nose-to-tail, whichever is bigger).
- **Body → kit archetype:** winged → `winged`, biped → `lurker`, quadruped → `beast`, serpent → `serpent`.
- **Rarity trims:** Common BoneDim, Uncommon Moss `#5E7A4A` (spec 01 A2), Rare Silver `#8C9AA3` (D11), Epic Blood.
- **Folklore rule (spec 09):** American/British cryptid folklore only; skip figures sacred to living Indigenous cultures.

## Art status (2026-11-04, after Batch 03)
| # | CryptidId | Placeholder | Full model |
|---|---|---|---|
| 1–4 | Commons | `art/models/placeholders/<Name>_PH.rbxmx` | Built (Batch 01); see the size check in `art/handoff/BATCH-02.md` |
| 5–8 | Uncommons | `<Name>_PH.rbxmx` | Built v1 (Batch 02); DoverDemon v1.1 (Neon eyes, D13) |
| 9–12 | Rares / Epics | `<Name>_PH.rbxmx` | Built v1 (Batch 03): FlatwoodsMonster 40, BeastOfBrayRoad 48, JerseyDevil 58, LochNessSerpent 44 parts, all within ±15% |

**Size check (Batch 02, full models vs table, ±15%):** all 8 built models within ±15%. **Resolved 2026-11-04:** the Growth Strategist accepted the Batch 02 size flags in spec 09: Fresno 6 × 3.3 (was 6 × 2), Hidebehind 8 × 5 (was 8 × 4), Hodag 3 × 6 (was 4 × 6). Placeholders regenerated at the new sizes. **Hidebehind is granted by the Starter Pack (spec 09), so its readability is a high-priority Studio check.**

Regenerate all placeholders from this table: `python3 art/tools/build_placeholder.py --roster art/roster-provisional.md`. If the roster changes, edit the table and rerun.
