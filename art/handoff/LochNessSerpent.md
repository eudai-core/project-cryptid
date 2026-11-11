### Handoff: LochNessSerpent (v1.0, 2026-11-04)
- **Asset id / model name:** `LochNessSerpent` · Attributes `CryptidId = "loch_ness_serpent"` (spec 09 §3 / `art/roster-provisional.md`), `AssetVersion = "1.0"`
- **Roster:** #12, Epic, serpent, 9 × 8 (provisional, ~70%).
- **File path (box):** `/workspace/project-cryptid/art/models/LochNessSerpent.rbxmx`. Generator: `art/tools/build_assets.py LochNessSerpent` (lib `rbxlib.py`). Do NOT map the preview data in `models/LochNessSerpent.parts.json` into Rojo.
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.LochNessSerpent`. It replaces `Assets.Placeholders.LochNessSerpent_PH` (same `CryptidId`; see `PLACEHOLDER-KIT.md`).
- **Counts:** **44 parts** (incl. invisible `Root`): 13 Part:Ball, 20 Part:Block, 10 WedgePart. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, Neon: none, scripts: none.** Within the large-cryptid cap (Rare+ ≤ 80 parts / 5,000 tris, style guide §6).
- **Materials:** Slate ×33, Fabric ×6, Glass ×2, Limestone ×2. No Plastic/SmoothPlastic.
- **Colours (tokens):**
  - Soot: Base, Neck1, Neck2, NeckJ1, Neck3, NeckJ2, Neck4, NeckJ3, Neck5, NeckJ4, Head, HumpA1, HumpA2, HumpAJ1, HumpA3, HumpAJ2, HumpA4, HumpAJ3, HumpB1, HumpB2, HumpBJ1, HumpB3, HumpBJ2, HumpB4, HumpBJ3, FlipperFront_R, FlipperBack_R, FlipperFront_L, FlipperBack_L
  - BoneDim: Throat1, Throat2, Throat3, Jaw
  - Blood: NeckFin1, NeckFin2, NeckFin3, NeckFin4, HumpFinA, HumpFinB, Eye_R, Eye_L
  - Bone: Horn_R, Horn_L
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**), at the footprint centre. `PivotOffset` puts the pivot on the floor (y = 0), so `model:PivotTo(pad.CryptidMount.CFrame)` needs **no offset**. **Front = −Z.**
- **Size (studs):** 3.3 W × 9.0 H × 8.0 D → **H 9.0 × L 8.0** vs roster 9 × 8 (H +0%, L +0%; ±15% OK). Fits ≤ 8 × 8 footprint and ≤ 10 height.
- **Rarity cue (§3):** Epic = Blood accent + horns: crimson dorsal fins on the neck and humps; small bone horns.
- **Physics:** all parts `Anchored`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` only on `Base`, `Neck1`, `Neck2`, `NeckJ1`, `Neck3`, `HumpA1`, `HumpAJ1`, `HumpAJ2`, `HumpA4`; off on everything else (< 1 stud³).
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned; based on folklore; no Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/LochNessSerpent_2026-11-04_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** A long, segmented neck rising from a rounded base, with **two humps** arching behind it resting directly on the base (no water modelled). Small flat head with pale jaw, crimson Glass eyes, bone horn nubs, pale throat plates, crimson dorsal fins and 4 flat flippers.
- **Redesign passes used:** 0.
- **Notes:** Narrow from the front (3.3 wide), so it reads best from the side or 3/4. The pad camera angle should favour that.

#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: §1 tokens only (validator) |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Slate, Fabric, Glass, Limestone; no Plastic/SmoothPlastic. Glass only where a glow is wanted (§2) |
| 5 | Silhouette | **PASS (box preview)**: hero shape reads in 3/4 and side. Studio read **PENDING** |
| 6 | Not toy-like / age-appropriate | **PASS (preview)**: spooky, not gore; no blood or wounds |
| 7 | Fit | **PASS**: within ±15% of roster H × L; ≤ 8 × 8, ≤ 10 tall; faces −Z |
| 8 | Budget | **PASS**: 44 ≤ 80 parts; 0 textures/lights/emitters |
| 9 | Readability (phone, §4 lighting) | **PENDING**: lighting read in Play (Studio) |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; collide/touch/query off; small parts cast no shadow; no unions |
| 12 | Naming | **PASS**: unique part names (`_R`/`_L` mirrored pairs) |
| 13 | Screenshot proof | **PENDING**: Studio captures by QA (D12: these also feed icon/thumbnails; box renders are only a fallback if imports slip past Mon 9 Nov) |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts/meshes/decals |
| 15 | Licence | **PASS**: self-built |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (BATCH-01 #1), pivot flush on `Pad.CryptidMount`, pad billboard clearance, Highlight limit (D8) before any outline, triangle count.
