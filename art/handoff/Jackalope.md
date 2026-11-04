### Handoff: Jackalope (v1.0, 2026-11-04)
- **Asset id / model name:** `Jackalope` · Attributes `CryptidId = "jackalope"` (spec 09 §3 / `art/roster-provisional.md`), `AssetVersion = "1.0"`
- **Roster:** #5, Uncommon, quadruped, 3 × 4 (provisional, ~70%). Income $12/s (spec 09).
- **File path (box):** `/workspace/project-cryptid/art/models/Jackalope.rbxmx`. Generator: `art/tools/build_assets.py Jackalope` (lib `rbxlib.py`). The preview data in `models/Jackalope.parts.json` must NOT be mapped into Rojo.
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.Jackalope`. It replaces `Assets.Placeholders.Jackalope_PH` because both share the same `CryptidId`; see `PLACEHOLDER-KIT.md`.
- **Goes in game at:** pads in `Workspace.Plots.Plot<i>`, inventory, Pedlar Uncommon pool, Rift belt per spec 09 §4 odds.
- **Counts:** **26 parts** (incl. invisible `Root`): 19 Part:Block, 6 Part:Ball. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, Neon: none, scripts: none.** Within the small-cryptid cap (Common/Uncommon ≤ 40 parts / 2,000 tris, style guide §6).
- **Materials:** Fabric ×14, Limestone ×9, Glass ×2. No Plastic/SmoothPlastic/Neon.
- **Colours (tokens):**
  - Soot: Body, Head, Haunch_R, Ear_R, Foreleg_R, HindFoot_R, Haunch_L, Ear_L, Foreleg_L, HindFoot_L
  - BoneDim: Chest, Snout, Forepaw_R, Forepaw_L
  - Bone: Tail, AntlerBeam_R, AntlerTine1_R, AntlerTine2_R, AntlerTine3_R, AntlerBeam_L, AntlerTine1_L, AntlerTine2_L, AntlerTine3_L
  - Blood: Eye_R, Eye_L
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**), placed at the footprint centre. `PivotOffset` puts the pivot on the floor (y = 0), so `model:PivotTo(pad.CryptidMount.CFrame)` needs **no offset**. **Front = −Z.**
- **Size (studs):** 2.4 W × 3.0 H × 3.8 D → **H 3.0 × L 3.8** vs roster 3 × 4 (H +1%, L -5%, both within ±15%). Fits the ≤ 8 × 8 footprint and ≤ 10 height.
- **States / variants:** none.
- **Physics:** every part `Anchored`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` on only for `Body`, `Chest`, `Haunch_R`, `Haunch_L`; off on all others (< 1 stud³).
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned; folklore-based design; no Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/Jackalope_2026-11-04_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** A sitting hare in dark Soot fur, with a pale chest and snout, long swept-back ears, a pale cotton tail and big hind feet. A pair of branching **bone antlers** (beam + 3 tines each) is the hero shape. Small crimson Glass eyes. Spooky, not cute: dark fur, red eyes and antlers wider than the head.
- **Redesign passes used:** 0.
- **Notes:** Antler tines are thin (0.13 studs). Check they survive at 30 studs on a phone.

#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: §1 tokens only (validator) |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Fabric, Limestone, Glass; no Plastic/SmoothPlastic. Glass only where a glow is wanted (§2) |
| 5 | Silhouette | **PASS (box preview)**: hero shape reads in 3/4 and side. Studio read **PENDING** |
| 6 | Not toy-like / age-appropriate | **PASS (preview)**: spooky, not gore; no blood or wounds |
| 7 | Fit | **PASS**: within ±15% of the roster H × L; ≤ 8 × 8, ≤ 10 tall; faces −Z |
| 8 | Budget | **PASS**: 26 ≤ 40 parts; 0 textures/lights/emitters |
| 9 | Readability (phone, §4 lighting) | **PENDING**: lighting read in Play in Studio |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; collide/touch/query off; small parts no shadow; no unions |
| 12 | Naming | **PASS**: unique part names (`_R`/`_L` mirrored pairs) |
| 13 | Screenshot proof | **PENDING**: Studio captures by QA. Per **D12** these also feed the icon/thumbnails; box renders are a fallback only if imports slip past Mon 9 Nov |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts/meshes/decals |
| 15 | Licence | **PASS**: self-built |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (BATCH-01 #1), pivot flush on `Pad.CryptidMount`, pad billboard clearance, Highlight limit (D8) before any outline, triangle count.
