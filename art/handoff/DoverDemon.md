### Handoff: DoverDemon (v1.0, 2026-11-04)
- **Asset id / model name:** `DoverDemon` · Attributes `CryptidId = "dover_demon"` (spec 09 §3 / `art/roster-provisional.md`), `AssetVersion = "1.0"`
- **Roster:** #6, Uncommon, biped, 4 × 3 (provisional, ~70%). Income $14/s (spec 09).
- **File path (box):** `/workspace/project-cryptid/art/models/DoverDemon.rbxmx`. Generator: `art/tools/build_assets.py DoverDemon` (lib `rbxlib.py`). The preview data in `models/DoverDemon.parts.json` must NOT be mapped into Rojo.
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.DoverDemon`. It replaces `Assets.Placeholders.DoverDemon_PH` because both share the same `CryptidId`; see `PLACEHOLDER-KIT.md`.
- **Goes in game at:** pads in `Workspace.Plots.Plot<i>`, inventory, Pedlar Uncommon pool, Rift belt per spec 09 §4 odds.
- **Counts:** **24 parts** (incl. invisible `Root`): 4 Part:Ball, 19 Part:Block. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, Neon: none, scripts: none.** Within the small-cryptid cap (Common/Uncommon ≤ 40 parts / 2,000 tris, style guide §6).
- **Materials:** Limestone ×2, Fabric ×19, Glass ×2. No Plastic/SmoothPlastic/Neon.
- **Colours (tokens):**
  - BoneDim: Head, HeadBack, Neck, Torso, Pelvis, ArmUpper_R, ArmFore_R, Finger1_R, Finger2_R, Finger3_R, Thigh_R, Shin_R, Foot_R, ArmUpper_L, ArmFore_L, Finger1_L, Finger2_L, Finger3_L, Thigh_L, Shin_L, Foot_L
  - GoldBright: Eye_R, Eye_L
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**), placed at the footprint centre. `PivotOffset` puts the pivot on the floor (y = 0), so `model:PivotTo(pad.CryptidMount.CFrame)` needs **no offset**. **Front = −Z.**
- **Size (studs):** 2.9 W × 4.0 H × 2.1 D → **H 4.0 × L 2.9** vs roster 4 × 3 (H +1%, L -5%, both within ±15%). Fits the ≤ 8 × 8 footprint and ≤ 10 height.
- **States / variants:** none.
- **Physics:** every part `Anchored`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` on only for `Head`, `HeadBack`; off on all others (< 1 stud³).
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned; folklore-based design; no Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/DoverDemon_2026-11-04_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** A pale, thin-limbed crouching figure with a huge melon-shaped head (2 overlapping balls), two large **glowing-orange eyes** (GoldBright Glass), stick arms with long three-finger hands hanging to the knees, and spindly legs. No mouth (folklore).
- **Redesign passes used:** 0.
- **Notes:** 'Glowing eyes' are GoldBright **Glass**, not Neon: D10 allows Neon eyes on the Mothman only. If they need a real glow, that's a new Master Controller decision (proposed D13). Also check the round head + big eyes don't read 'cute alien' in Studio.

#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: §1 tokens only (validator) |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Limestone, Fabric, Glass; no Plastic/SmoothPlastic. Glass only where a glow is wanted (§2) |
| 5 | Silhouette | **PASS (box preview)**: hero shape reads in 3/4 and side. Studio read **PENDING** |
| 6 | Not toy-like / age-appropriate | **PASS (preview)**: spooky, not gore; no blood or wounds |
| 7 | Fit | **PASS**: within ±15% of the roster H × L; ≤ 8 × 8, ≤ 10 tall; faces −Z |
| 8 | Budget | **PASS**: 24 ≤ 40 parts; 0 textures/lights/emitters |
| 9 | Readability (phone, §4 lighting) | **PENDING**: lighting read in Play in Studio |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; collide/touch/query off; small parts no shadow; no unions |
| 12 | Naming | **PASS**: unique part names (`_R`/`_L` mirrored pairs) |
| 13 | Screenshot proof | **PENDING**: Studio captures by QA. Per **D12** these also feed the icon/thumbnails; box renders are a fallback only if imports slip past Mon 9 Nov |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts/meshes/decals |
| 15 | Licence | **PASS**: self-built |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (BATCH-01 #1), pivot flush on `Pad.CryptidMount`, pad billboard clearance, Highlight limit (D8) before any outline, triangle count.
