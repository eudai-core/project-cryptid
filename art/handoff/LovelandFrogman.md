### Handoff: LovelandFrogman (v1.0, 2026-11-04)
- **Asset id / model name:** `LovelandFrogman` · Attributes `CryptidId = "loveland_frogman"` (spec 09 §3 / `art/roster-provisional.md`), `AssetVersion = "1.0"`
- **Roster:** #8, Uncommon, biped, 5 × 3 (provisional, ~70%). Income $18/s (spec 09).
- **File path (box):** `/workspace/project-cryptid/art/models/LovelandFrogman.rbxmx`. Generator: `art/tools/build_assets.py LovelandFrogman` (lib `rbxlib.py`). The preview data in `models/LovelandFrogman.parts.json` must NOT be mapped into Rojo.
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.LovelandFrogman`. It replaces `Assets.Placeholders.LovelandFrogman_PH` because both share the same `CryptidId`; see `PLACEHOLDER-KIT.md`.
- **Goes in game at:** pads in `Workspace.Plots.Plot<i>`, inventory, Pedlar Uncommon pool, Rift belt per spec 09 §4 odds.
- **Counts:** **24 parts** (incl. invisible `Root`): 14 Part:Block, 4 Part:Ball, 5 WedgePart. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, Neon: none, scripts: none.** Within the small-cryptid cap (Common/Uncommon ≤ 40 parts / 2,000 tris, style guide §6).
- **Materials:** Slate ×14, Limestone ×6, Fabric ×1, Wood ×1, Glass ×1. No Plastic/SmoothPlastic/Neon.
- **Colours (tokens):**
  - Soot: Torso, Head, ArmUpper_R, ArmFore_R, Thigh_R, Shin_R, Foot_R, ArmUpper_L, ArmFore_L, Thigh_L, Shin_L, Foot_L
  - BoneDim: Belly, Throat, Wand, Eye_R, Hand_R, Eye_L, Hand_L
  - Blood: Mouth
  - GoldBright: WandTip
  - Void: Pupil_R, Pupil_L
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**), placed at the footprint centre. `PivotOffset` puts the pivot on the floor (y = 0), so `model:PivotTo(pad.CryptidMount.CFrame)` needs **no offset**. **Front = −Z.**
- **Size (studs):** 3.1 W × 4.8 H × 2.0 D → **H 4.8 × L 3.1** vs roster 5 × 3 (H -4%, L +4%, both within ±15%). Fits the ≤ 8 × 8 footprint and ≤ 10 height.
- **States / variants:** none.
- **Physics:** every part `Anchored`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` on only for `Torso`, `Belly`, `Head`; off on all others (< 1 stud³).
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned; folklore-based design; no Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/LovelandFrogman_2026-11-04_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** An upright, hunched frog-man: Slate skin, a wide sloped frog head with a Blood mouth line, pale throat and pear belly, two bulging BoneDim eyes with Void slit pupils, bent frog legs with webbed wedge feet, and webbed hands. Holds a thin **wand** with a GoldBright Glass spark tip (folklore).
- **Redesign passes used:** 1 (box head → sloped wedge snout, eyes moved to the top of the head, deeper hunch).
- **Notes:** Head and feet are wedges, so they need the wedge-orientation check.

#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: §1 tokens only (validator) |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Slate, Limestone, Fabric, Wood, Glass; no Plastic/SmoothPlastic. Glass only where a glow is wanted (§2) |
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
