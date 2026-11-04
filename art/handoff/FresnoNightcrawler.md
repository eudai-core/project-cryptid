### Handoff: FresnoNightcrawler (v1.0, 2026-11-03)
- **Asset id / model name:** `FresnoNightcrawler` · Attributes `CryptidId = "fresno_nightcrawler"` (spec 01 B3 / spec 03 §4.3), `AssetVersion = "1.0"`
- **File path (box):** `/workspace/project-cryptid/art/models/FresnoNightcrawler.rbxmx`. Generator: `art/tools/build_assets.py FresnoNightcrawler` (shared lib `art/tools/rbxlib.py`; preview data `models/FresnoNightcrawler.parts.json`, do NOT map the `.json` into Rojo)
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.FresnoNightcrawler` (style guide §8, proposed)
- **Goes in game at:** first on the Rift Fissure belt, then Pad 2 and inventory `[S02 §3]`.
- **Counts:** **15 parts** (1 invisible Root): 5 blocks, 5 balls, 2 cylinders, 2 wedges + Root. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, scripts: none.**
- **Materials:** Fabric ×7, Limestone ×5, Basalt ×2 (anklets). No Plastic/Neon.
- **Colours (tokens):**
  - Bone: waist, bulb head, thighs, shins (the brightest cryptid, which helps readability)
  - BoneDim: knees, feet
  - Void: eye pits
  - Soot: anklets (grime)
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**). `PivotOffset` puts the **pivot at ground level (y = 0)**, so `model:PivotTo(cf)` sits it flat with **no offset**. **Front = −Z** (`Root.CFrame.LookVector`). Pivot = between the feet on the floor.
- **Size (studs):** 1.7 × 6.2 × 3.3 (≤ 6 × 6 Common footprint, ≤ 10 tall)
- **States / variants:** none
- **Physics:** every part `Anchored = true`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` on only for `Waist`, `Bulb`; off on all other parts.
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned. No Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/FresnoNightcrawler_2026-11-03_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** folklore "walking pair of pants": two tall, thin bone-white legs mid-stride, joined at a small waist block, topped by a small bulb head with two hollow Void eye pits. No arms. Reads as "legs only".
#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS** |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Fabric/Limestone/Basalt |
| 5 | Silhouette | **PASS (box preview)**: striding legs read in front and side views. Studio read **PENDING** |
| 6 | Not toy-like | **PASS**: thin, eerie, no cute proportions |
| 7 | Fit | **PASS** |
| 8 | Budget | **PASS**: 15 ≤ 15 target (Root included) |
| 9 | Readability (phone, §4 lighting) | **PENDING**: lighting read in Play; check the white legs don't bloom/clip on the Rift belt Neon |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; CanCollide/CanTouch/CanQuery off; CastShadow off on parts < 1 stud³; no unions |
| 12 | Naming | **PASS**: every part uniquely named |
| 13 | Screenshot proof | **PENDING**: Studio screenshots by QA after import. Box previews exist but are not proof |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts, meshes or decals |
| 15 | Licence | **PASS**: self-built, project-owned |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (assumed slope runs down toward −Z; see BATCH-01), pivot flush on the real pad, Highlight limit (D8) before any outline, and pad billboard clearance.
