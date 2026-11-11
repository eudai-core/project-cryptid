# Batch 01 handoff (2026-11-03/04): 6 assets + placeholder kit

All files are **box-side only** (`/workspace/project-cryptid/…`). Nothing was opened in Studio, nothing was copied to the user's computer or the repo. Parts only: no scripts, no meshes, no Creator Store assets, no decals.

| Asset | File | Parts | Version | Id attribute | Handoff |
|---|---|---|---|---|---|
| Mothman Hatchling | `art/models/MothmanHatchling.rbxmx` | 37 | 0.2 | `CryptidId = mothman_hatchling` | `MothmanHatchling.md` |
| Pad (4 states + affordable mod) | `art/models/Pad.rbxmx` | 13 (3–5 visible per state) | 1.0 | `AssetId = Pad` | `Pad.md` |
| Bone Altar (L0 + Tier1 + Tier2) | `art/models/BoneAltar.rbxmx` | 39 (14 / 12 / 13) | 1.0 | `AssetId = boneAltar` | `BoneAltar.md` |
| Fresno Nightcrawler | `art/models/FresnoNightcrawler.rbxmx` | 15 | 1.0 | `CryptidId = fresno_nightcrawler` | `FresnoNightcrawler.md` |
| Hidebehind | `art/models/Hidebehind.rbxmx` | 27 | 1.0 | `CryptidId = hidebehind` | `Hidebehind.md` |
| Hodag | `art/models/Hodag.rbxmx` | 35 | 1.0 | `CryptidId = hodag` | `Hodag.md` |
| Placeholder kit (12 samples) | `art/models/placeholders/*_PH.rbxmx` | 10–15 each | 1.0 | `CryptidId`, `IsPlaceholder = true` | `PLACEHOLDER-KIT.md` |

Shared conventions: `PrimaryPart = Root` (invisible, flat), `Root.PivotOffset` puts the pivot on the floor (y = 0), so **`PivotTo` needs no offset**. Front = −Z. Every part Anchored, CanCollide/CanTouch/CanQuery off, CastShadow off on parts < 1 stud³.

## Suggested Rojo mapping (Architect)
Copy **only the `.rbxmx` files** into the repo. ⚠️ Do **not** point Rojo at `art/models/` as-is: the `*.parts.json` preview files sitting next to them would be turned into ModuleScripts/JSON instances.
```
assets/cryptids/      MothmanHatchling.rbxmx FresnoNightcrawler.rbxmx Hidebehind.rbxmx Hodag.rbxmx
assets/lair/          Pad.rbxmx BoneAltar.rbxmx
assets/placeholders/  <Name>_PH.rbxmx   (only the ones the roster actually uses)
```
```json
"ReplicatedStorage": {
  "$className": "ReplicatedStorage",
  "Assets": {
    "$className": "Folder",
    "Cryptids":     { "$path": "assets/cryptids" },
    "Lair":         { "$path": "assets/lair" },
    "Placeholders": { "$path": "assets/placeholders" }
  }
}
```
Result: `ReplicatedStorage.Assets.Cryptids.{MothmanHatchling,FresnoNightcrawler,Hidebehind,Hodag}`, `ReplicatedStorage.Assets.Lair.{Pad,BoneAltar}`, `ReplicatedStorage.Assets.Placeholders.<Name>_PH`.
**Verified on the box only:** a throwaway Rojo 7.4.4 project (`/tmp/rt`) with exactly this layout built `.rbxlx` and `.rbxl` cleanly. Instance counts matched; PrimaryPart, PivotOffset, string attributes, the bool `IsPlaceholder` attribute and the 2 Neon eye parts all survived. Not tested in the real repo.

## Validation (box)
`python3 art/tools/validate_rbxmx.py <file> --max N --id-key … --id … [--neon Eye_R,Eye_L] [--version 0.2] [--placeholder]`. It checks:
- roblox v4, unique referents, one top Model, PrimaryPart = Root
- Root flat, invisible, with PivotOffset to the ground
- AssetVersion and id attribute (string + bool attributes)
- part classes limited to Part/WedgePart/CornerWedgePart, recursing into sub-Models
- physics flags, small-part shadows, palette colours
- no Plastic/SmoothPlastic, Neon only on allow-listed parts
- no scripts/meshes/decals, max parts

**All 6 assets and all 12 placeholder samples PASS.**

## PENDING: Studio-only checks (QA / Architect)
1. **Wedge facing.** Every WedgePart was built assuming Roblox's wedge has a full bottom and full back (+Z) face, with the slope running down toward −Z. If that's wrong, the Hodag spikes/teeth/tusks, Mothman wings and tatters, Fresno feet, Hidebehind jags/roots, altar crown horns and placeholder crests/jaws/tail tips will face backwards. Check one (e.g. Hodag `Spike1`) first. The fix is a 180° Y-rotation in `rbxlib.py`, regenerated in seconds.
2. **Studio screenshots** for every asset (checklist #13): `qa/screenshots/<id>_<date>_<view>.png`. The box previews are not proof.
3. **Lighting read in Play** (checklist #9), on a phone emulator at low brightness: style guide §4 tests (1) silhouette vs floor, (2) pad states distinguishable, (3) billboard readable at 30 studs. Hardest cases: Hidebehind (dark body) and Pad Empty vs Locked.
4. **Highlight 31-limit** (D8, UNVERIFIED) before any outline/Keen Eye effect.
5. **Pivot / billboard clearance:** cryptids sit flush on `Pad.CryptidMount` (no float/sink), and the pad billboard clears the tallest model (Hidebehind 8.2, Lurker Epic placeholder 7.3).
6. **Neon eye look** (Mothman, D10): check it reads menacing and bloom (Threshold 1.6) doesn't blow it out.
7. **Glass glows:** altar candle flames (GoldBright Glass) and Hodag eyes may read dull without Neon; check with the altar fill light on.
8. **Hodag in the Wilds:** the Wilds lighting/fog isn't specced yet. **2026-11-04 (`[D33]`): now the #1 readability check**: spec 01 v2.0 moved the catch to ~0:33; lantern proposal in `HODAG-ONBOARDING.md`.
9. **Triangle counts:** not measurable on the box; check in Studio's render stats if needed (all are well under the part caps).

## Shared tools (box)
- `art/tools/rbxlib.py`: palette, materials, rotations, `seg()`, `Asset` writer (nested sub-Models, attributes, deterministic referents, PivotOffset)
- `art/tools/build_assets.py [Name …]`: regenerates the 6 batch assets (`build_mothman.py` is the superseded v0.1 script)
- `art/tools/build_placeholder.py`: placeholder kit (see `PLACEHOLDER-KIT.md`)
- `art/tools/preview_parts.py <parts.json> <prefix>`: z-buffer box preview (front34 + side), labelled NOT Studio proof. It replaces the old matplotlib renderer, which gave wrong depth-sorting on the Pad.
- `art/tools/validate_rbxmx.py`: see above
