### Handoff: MothmanHatchling (v0.2, 2026-11-03)

**v0.2 changes:** eyes are now **Neon Blood `#7A0F12`** per **D10** (Bone glints kept); `Root` is now **flat** (identity rotation) with `PivotOffset` putting the pivot at the feet, so **no placement offset is needed**; `AssetVersion = "0.2"`. Generator moved to `art/tools/build_assets.py` (`build_mothman.py` is the superseded v0.1 script). Geometry otherwise unchanged.
- **Asset id / model name:** `MothmanHatchling` · Attributes `CryptidId = "mothman_hatchling"` (id from spec 03 §4.4 / asset-list), `AssetVersion = "0.2"`
- **File path (box):** `/workspace/project-cryptid/art/models/MothmanHatchling.rbxmx`. Generator: `art/tools/build_assets.py MothmanHatchling` (shared lib `rbxlib.py`) (+ `models/MothmanHatchling.parts.json`)
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.MothmanHatchling` (style guide §8, proposed)
- **Goes in game at:** cloned onto a pad in `Workspace.Plots.Plot<i>` (Pad 1 for the starter, spec 01 B2 / spec 02 §3). Also used for inventory and the Pedlar Common pool.
- **Counts:** **37 parts** (incl. invisible `Root`); 18 blocks, 6 wedges, 8 cylinders, 5 balls. **0 meshes, 0 textures, 0 lights, 0 emitters, **Neon: 2 parts (eyes, D10)**, scripts: none.**
  - **Triangle estimate: ~1,000–2,000** (rough; Roblox doesn't publish primitive tri counts, the balls/cylinders dominate). Within the small-cryptid cap (40 parts / 2,000 tris).
- **Materials:** Fabric ×29, Limestone ×6, Neon ×2 (eyes only, D10). No Plastic/SmoothPlastic/Glass.
- **Colours (tokens):**
  - Soot: wings, head, legs, tatters, belly
  - Ash: torso, Root
  - BoneDim: fur ruff, antennae, wing veins, eyespot rings, one shard
  - Bone: claws, eye glints, shard
  - Blood: wing eyespots, eyes (Neon)
- **Pivot / facing:** `PrimaryPart = Root` (invisible, Transparency 1, anchored, **flat**, body-centre at (0, 1.9, 0.15); `PivotOffset` = (0, −1.9, 0) so the **pivot is at ground level under the body**). **Front = −Z** (`Root.CFrame.LookVector`). Feet at y = 0.
  - Place with `model:PivotTo(pad.CryptidMount.CFrame)` (or `CFrame.lookAt(padTop, gatePos)`); **no offset needed**.
- **Size (studs):** ~3.6 × 4.6 × 3.1 (fits a 10-stud pad; billboard sits above ~5 studs)
- **States / variants:** none
- **Physics:** every part `Anchored = true`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` on only for Torso, Head and both wings; off on the 33 small parts.
- **Scripts inside:** none ✅
- **Source & licence:** self-built by Grok Bot (Parts only), project-owned. No Creator Store assets, no generated meshes.
- **Screenshots:**
  - Box-side previews (NOT Studio proof): `qa/screenshots/MothmanHatchling_2026-11-03_preview-front34.png`, `..._preview-side.png`
  - Studio proof: **PENDING** (QA after import)

**Design:** a small, hunched moth-thing.
- Two **oversized folded triangular moth wings** wrap the body like a cloak. Their front tips rise to peaks above the head, the bottoms flare outward, the trailing edges are tattered with uneven teeth, and each carries a BoneDim vein pattern and a Blood eyespot.
- A big soot head with **two large red eyes** (Neon Blood + Bone glints, D10).
- A pale **fur ruff**, two splayed **feathery antennae** (stalk + 2 blade fronds each), stubby legs with bone claws, and **eggshell shards** at the feet for "hatchling".

#### Including it via Rojo (Architect)
1. Copy the file into the repo, e.g. `assets/cryptids/MothmanHatchling.rbxmx`.
2. Map it in `default.project.json`:
```json
"ReplicatedStorage": {
  "$className": "ReplicatedStorage",
  "Assets": {
    "$className": "Folder",
    "Cryptids": {
      "$className": "Folder",
      "MothmanHatchling": { "$path": "assets/cryptids/MothmanHatchling.rbxmx" }
    }
  }
}
```
   (Or point `"Cryptids": { "$path": "assets/cryptids" }` at the folder; Rojo turns each `.rbxmx` into an instance named after the file.)
3. Verified on the box only: a throwaway Rojo 7.4.4 project with exactly this mapping built `.rbxlx` and `.rbxl` cleanly (37 parts, PrimaryPart and attributes preserved). Not tested in the real repo.

#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: only §1 tokens, no purple |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: only `Eye_R`/`Eye_L` (2 parts), allowed by **D10**; validator allow-lists exactly these two |
| 4 | Materials | **PASS**: Fabric/Limestone + Neon eyes; no Plastic/SmoothPlastic |
| 5 | Silhouette | **PASS (box-side preview)**: wings, peaks, eyes and antennae read as a moth creature. Studio read **PENDING** |
| 6 | Not toy-like | **PASS (preview)**: angular, tattered, asymmetric hunch. Note the eyes are large glowing balls, so check in Studio they read menacing, not "cute", and that bloom (Threshold 1.6) doesn't blow them out |
| 7 | Fit | **PASS**: 3.6 × 4.6 × 3.1 ≤ 6 × 6 × 10; faces −Z |
| 8 | Budget | **PASS**: 37 ≤ 40 parts; 0 textures/emitters/lights (37 is over the asset list's ≤ 30 target) |
| 9 | Readability (phone, §4 lighting) | **PENDING**: needs a lighting read in Play in Studio |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored, collisions/touch/query off, no unions |
| 12 | Naming | **PASS**: every part uniquely named (`Wing_R`, `Eye_L`, …) |
| 13 | Screenshot proof | **PENDING**: Studio screenshots from QA after import (`qa/screenshots/mothman_hatchling_<YYYY-MM-DD>_<view>.png`). Box previews exist but are not proof |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no Script/LocalScript/ModuleScript |
| 15 | Licence | **PASS**: self-built |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):**
- The **Highlight limit** (UNVERIFIED, D8) before any outline effect is used on this cryptid.
- Pad billboard clearance.
- Pivot sits flush on the real pad (`CryptidMount`), no float/sink.
- Neon eye look under lair lighting + bloom (D10).

**Notes for code:** no attributes beyond `CryptidId`/`AssetVersion`; no attachments. Clone from `ReplicatedStorage`, never edit in place.
