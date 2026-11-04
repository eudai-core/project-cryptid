### Handoff: Hidebehind (v1.0, 2026-11-03)
- **Asset id / model name:** `Hidebehind` · Attributes `CryptidId = "hidebehind"` (spec 01 B3 / spec 03 §4.3), `AssetVersion = "1.0"`
- **File path (box):** `/workspace/project-cryptid/art/models/Hidebehind.rbxmx`. Generator: `art/tools/build_assets.py Hidebehind` (shared lib `art/tools/rbxlib.py`; preview data `models/Hidebehind.parts.json`, do NOT map the `.json` into Rojo)
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.Hidebehind` (style guide §8, proposed)
- **Goes in game at:** Rift belt → Pad 3 → inventory.
- **Counts:** **27 parts** (1 invisible Root): 1 cylinder, 4 wedges, 19 blocks, 2 balls + Root. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, scripts: none.**
- **Materials:** Wood ×6 (stump, jags, roots, branch), Slate ×12 (creature), Limestone ×8 (fingers, eye glints). No Plastic/Neon.
- **Colours (tokens):**
  - BoneDim: stump, jags, roots, dead branch, fingers (Wood/Limestone)
  - Soot: whole creature body (Slate)
  - Bone: two eye glints
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**). `PivotOffset` puts the **pivot at ground level (y = 0)**, so `model:PivotTo(cf)` sits it flat with **no offset**. **Front = −Z** (`Root.CFrame.LookVector`). Pivot = footprint centre on the floor (not the stump centre).
- **Size (studs):** 4.9 × 8.2 × 5.1 (≤ 6 × 9 × 6 target)
- **States / variants:** none
- **Physics:** every part `Anchored = true`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` on only for `Stump`, `StumpJag1`, `Torso`; off on all other parts.
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned. No Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/Hidebehind_2026-11-03_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** a pale dead tree stump (part of the model) with a jagged top, two root flares and a dead branch. A tall, gaunt Soot creature stands behind it; only its head, two Bone eye glints and long BoneDim fingers wrapped round the bark show from the front. It peeks out on the model's **−X side** (viewer's right from the front).
- **Redesign passes used: 2** (the asked-for maximum). Pass 1: bigger stump, creature tucked behind it. Pass 2: mirrored so it peeks on the side away from the default 3/4 camera.
#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS** |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Wood stump (spec suggested WoodPlanks/Wood), Slate body |
| 5 | Silhouette | **PASS (box preview)**: "something hiding behind a stump" reads from the front/3/4 view. From behind, the whole body shows (by design) |
| 6 | Not toy-like | **PASS** |
| 7 | Fit | **PASS** |
| 8 | Budget | **PASS**: 27 ≤ 35 |
| 9 | Readability (phone, §4 lighting) | **PENDING**: the dark body is the hardest readability case (asset list). Check in Play that the eye glints and fingers read at 30 studs |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; CanCollide/CanTouch/CanQuery off; CastShadow off on parts < 1 stud³; no unions |
| 12 | Naming | **PASS**: every part uniquely named |
| 13 | Screenshot proof | **PENDING**: Studio screenshots by QA after import. Box previews exist but are not proof |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts, meshes or decals |
| 15 | Licence | **PASS**: self-built, project-owned |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (assumed slope runs down toward −Z; see BATCH-01), pivot flush on the real pad, Highlight limit (D8) before any outline, and pad billboard clearance.
