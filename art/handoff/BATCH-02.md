# Batch 02 handoff (2026-11-04): roster, Uncommon trim, placeholders, size check, 4 Uncommons

Everything here is box-side only (Parts only; no Studio, no meshes, no scripts, no Store assets; the user's computer and the repo were not touched). Previews are labelled NOT Studio proof.

## 0. Style guide
- **D11:** Rare silver `#8C9AA3` is approved as a rarity-trim exception (Master Controller, 2026-11-04). OQ1 is closed.
- **D12:** the icon and thumbnails use real Studio captures, with box renders as a fallback if imports slip past Mon 9 Nov.

## 1–3. Roster, Uncommon trim, placeholders
- `art/roster-provisional.md`: 12 cryptids from spec 09 §3 (~70% sure), body → archetype mapping, art-status table. Linked from `asset-list.md`.
- Uncommon trim: Moss `#5E7A4A` band + 2 swept-back tufts (shape cue, §3). It sits between Common (BoneDim) and Rare (Silver + crest).
- `art/models/placeholders/<CamelCaseId>_PH.rbxmx` ×12 at roster H × L, with these part counts: MothmanHatchling 10, FresnoNightcrawler 11, Hidebehind 11, Hodag 12, Jackalope 14, DoverDemon 13, Snallygaster 12, LovelandFrogman 13, and the 4 Rares/Epics 12–13. All PASS. The 16 kit samples moved to `placeholders/samples/`, which is not mapped.
- Sheet: `qa/screenshots/RosterPlaceholders_2026-11-04_preview-sheet.png` (+ `-sheet-side.png`).

## 4. Size check: full models vs roster H × L (±15%)
| Model | H × L (built) | Roster | Result |
|---|---|---|---|
| MothmanHatchling | 4.6 × 3.6 | 4.6 × 3.6 | ✓ |
| FresnoNightcrawler | 6.2 × 3.3 | 6 × 2 | **FLAG**: L +65% (walking stride depth) |
| Hidebehind | 8.2 × 5.1 | 8 × 4 | **FLAG**: L +28% (stump branch + roots) |
| Hodag | 3.1 × 6.0 | 4 × 6 | **FLAG**: H −22% |
| Jackalope | 3.0 × 3.8 | 3 × 4 | ✓ |
| DoverDemon | 4.05 × 2.85 | 4 × 3 | ✓ |
| Snallygaster | 5.1 × 7.6 | 5 × 7 | ✓ (+9%) |
| LovelandFrogman | 4.8 × 3.1 | 5 × 3 | ✓ |

No rescale is trivial. A uniform scale fixes one axis and breaks the other, or breaks a cap: Hodag at H 4 becomes L 7.7, over the Common 6 cap. Fresno at L 2 would be only 3.8 tall. **Recommendation:** the roster sizes are [A] assumptions, so the Growth Strategist should update them to **Fresno 6 × 3.3, Hidebehind 8 × 5, Hodag 3 × 6** (or accept the models as built). The alternative is a pose edit: Fresno with a narrower stride, Hidebehind without the branch, or Hodag with taller dorsal spikes. That would use each model's last redesign pass.

## 5. Uncommon full models (v1.0)
| Model | Parts | Design | Passes |
|---|---|---|---|
| Jackalope | 26 | Dark hare, pale chest/snout/tail, swept ears, branching bone antlers, crimson Glass eyes | 0 |
| DoverDemon | 24 | Pale stick-limbed crouching figure, huge melon head, big glowing-orange Glass eyes, long 3-finger hands | 0 |
| Snallygaster | 33 | Hunched reptile-bird, single crimson forehead eye, corroded-gold metal beak, tentacle hints, bat wings (wedge triangles) | 0 |
| LovelandFrogman | 24 | Upright hunched frog-man, sloped wide head, bulging slit-pupil eyes, webbed hands/feet, wand with a gold Glass spark | 1 |

Each one has an `.rbxmx`, front34 + side previews (`qa/screenshots/<Name>_2026-11-04_preview-*.png`, viewed), a handoff note with the 16-point checklist, and an `asset-list.md` §8 status. New lib helper: `rbxlib.tri()` (flat triangle from 2 wedges).

## 6. Rojo mapping (Architect)
```json
"ReplicatedStorage": { "$className": "ReplicatedStorage",
  "Assets": { "$className": "Folder",
    "Cryptids":     { "$path": "assets/cryptids" },
    "Lair":         { "$path": "assets/lair" },
    "Placeholders": { "$path": "assets/placeholders" } } }
```
| Box source | Repo target |
|---|---|
| `art/models/{MothmanHatchling,FresnoNightcrawler,Hidebehind,Hodag,Jackalope,DoverDemon,Snallygaster,LovelandFrogman}.rbxmx` | `assets/cryptids/` |
| `art/models/{Pad,BoneAltar}.rbxmx` | `assets/lair/` |
| `art/models/placeholders/*_PH.rbxmx` (12, top level only) | `assets/placeholders/` |

Copy **only `.rbxmx`**. Do not copy `*.parts.json` (preview data) or `placeholders/samples/`. Code should look up models by `CryptidId` (Cryptids before Placeholders); see `PLACEHOLDER-KIT.md`.

## Validation (2026-11-04)
- `validate_rbxmx.py`: **10/10 full models PASS** (Mothman v0.2 `--neon Eye_R,Eye_L`; Uncommons `--max 40`). **12/12 roster placeholders PASS** and **16/16 samples PASS** (`--placeholder --max 15`).
- Throwaway Rojo 7.4.4 build (`/tmp/rt2`, both `.rbxlx` and `.rbxl`): **PASS**. Cryptids 8 models / 221 parts, Lair 2 / 59, Placeholders 12 / 147; 22 PivotOffsets.

## PENDING (Studio-only, QA / Architect)
1. **Wedge facing**: the assumed slope runs from top-back (+Z) down to bottom-front. Batch 02 depends on it more than before: Snallygaster wing membranes (`tri()`), beaks and crest; Frogman head, hands and feet; placeholder tufts and crests.
2. Studio screenshots for all 8 cryptids + placeholders. Per **D12** these also feed the icon/thumbnails; box renders are the fallback only if imports slip past Mon 9 Nov.
3. Lighting read (§4) on a phone at 30 studs: dark Soot bodies (Jackalope, Snallygaster, Frogman), thin antler tines.
4. Glass "glows": Dover Demon eyes, Frogman wand tip, Hodag eyes, placeholder eyes. If any must really glow, that needs a new Neon decision (D10 covers the Mothman only; proposed D13 for Dover Demon eyes).
5. Pivot flush on `Pad.CryptidMount`, pad billboard clearance (Hidebehind 8.2 and Snallygaster 5.1 are the tallest), Highlight limit (D8) before any outline, triangle count.
6. Roster size decision for Fresno, Hidebehind and Hodag (section 4).

**Not started (by instruction):** Rares/Epics #9–12 (Flatwoods Monster, Beast of Bray Road, Jersey Devil, Loch Ness Serpent). Their placeholders ship until full models exist.
