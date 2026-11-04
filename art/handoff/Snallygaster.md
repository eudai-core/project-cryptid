### Handoff: Snallygaster (v1.0, 2026-11-04)
- **Asset id / model name:** `Snallygaster` · Attributes `CryptidId = "snallygaster"` (spec 09 §3 / `art/roster-provisional.md`), `AssetVersion = "1.0"`
- **Roster:** #7, Uncommon, winged, 5 × 7 (provisional, ~70%). Income $16/s (spec 09).
- **File path (box):** `/workspace/project-cryptid/art/models/Snallygaster.rbxmx`. Generator: `art/tools/build_assets.py Snallygaster` (lib `rbxlib.py`). The preview data in `models/Snallygaster.parts.json` must NOT be mapped into Rojo.
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.Snallygaster`. It replaces `Assets.Placeholders.Snallygaster_PH` because both share the same `CryptidId`; see `PLACEHOLDER-KIT.md`.
- **Goes in game at:** pads in `Workspace.Plots.Plot<i>`, inventory, Pedlar Uncommon pool, Rift belt per spec 09 §4 odds.
- **Counts:** **33 parts** (incl. invisible `Root`): 17 Part:Block, 2 Part:Ball, 13 WedgePart. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, Neon: none, scripts: none.** Within the small-cryptid cap (Common/Uncommon ≤ 40 parts / 2,000 tris, style guide §6).
- **Materials:** Slate ×10, CorrodedMetal ×2, Glass ×1, Limestone ×7, Fabric ×12. No Plastic/SmoothPlastic/Neon.
- **Colours (tokens):**
  - Soot: Body, Chest, Neck, Head, Tail1, Tail2, Thigh_R, Shin_R, Thigh_L, Shin_L
  - Gold: BeakUpper, BeakLower
  - Blood: Eye, Tentacle1, Tentacle2, Tentacle3, Tentacle4
  - Bone: Crest, Talon_R, Talon_L
  - BoneDim: WingArm_R, WingFinger_R, WingArm_L, WingFinger_L
  - Ash: WingInner_Ra, WingInner_Rb, WingOuter_Ra, WingOuter_Rb, WingInner_La, WingInner_Lb, WingOuter_La, WingOuter_Lb
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**), placed at the footprint centre. `PivotOffset` puts the pivot on the floor (y = 0), so `model:PivotTo(pad.CryptidMount.CFrame)` needs **no offset**. **Front = −Z.**
- **Size (studs):** 7.6 W × 5.1 H × 7.1 D → **H 5.1 × L 7.6** vs roster 5 × 7 (H +2%, L +9%, both within ±15%). Fits the ≤ 8 × 8 footprint and ≤ 10 height.
- **States / variants:** none.
- **Physics:** every part `Anchored`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` on only for `Body`, `Chest`; off on all others (< 1 stud³).
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned; folklore-based design; no Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/Snallygaster_2026-11-04_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** A hunched reptile-bird: Slate body, long neck, a **single crimson eye** in the forehead and a corroded-gold **metal beak** (both folklore). Bone crest, four short Blood tentacle hints hanging under the beak, wide bat wings (BoneDim struts, Ash membranes from 4 wedge triangles each side), clawed legs and a short tail.
- **Redesign passes used:** 0.
- **Notes:** Wing membranes are built from WedgePart triangles (new `tri()` helper), so they depend completely on the wedge-orientation check. Span 7.6 is within the 8 × 8 footprint.

#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: §1 tokens only (validator) |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Slate, CorrodedMetal, Glass, Limestone, Fabric; no Plastic/SmoothPlastic. Glass only where a glow is wanted (§2) |
| 5 | Silhouette | **PASS (box preview)**: hero shape reads in 3/4 and side. Studio read **PENDING** |
| 6 | Not toy-like / age-appropriate | **PASS (preview)**: spooky, not gore; no blood or wounds |
| 7 | Fit | **PASS**: within ±15% of the roster H × L; ≤ 8 × 8, ≤ 10 tall; faces −Z |
| 8 | Budget | **PASS**: 33 ≤ 40 parts; 0 textures/lights/emitters |
| 9 | Readability (phone, §4 lighting) | **PENDING**: lighting read in Play in Studio |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; collide/touch/query off; small parts no shadow; no unions |
| 12 | Naming | **PASS**: unique part names (`_R`/`_L` mirrored pairs) |
| 13 | Screenshot proof | **PENDING**: Studio captures by QA. Per **D12** these also feed the icon/thumbnails; box renders are a fallback only if imports slip past Mon 9 Nov |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts/meshes/decals |
| 15 | Licence | **PASS**: self-built |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (BATCH-01 #1), pivot flush on `Pad.CryptidMount`, pad billboard clearance, Highlight limit (D8) before any outline, triangle count.
