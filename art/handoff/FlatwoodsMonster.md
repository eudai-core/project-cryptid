### Handoff: FlatwoodsMonster (v1.0, 2026-11-04)
- **Asset id / model name:** `FlatwoodsMonster` · Attributes `CryptidId = "flatwoods_monster"` (spec 09 §3 / `art/roster-provisional.md`), `AssetVersion = "1.0"`
- **Roster:** #9, Rare, biped, 9 × 5 (provisional, ~70%).
- **File path (box):** `/workspace/project-cryptid/art/models/FlatwoodsMonster.rbxmx`. Generator: `art/tools/build_assets.py FlatwoodsMonster` (lib `rbxlib.py`). Do NOT map the preview data in `models/FlatwoodsMonster.parts.json` into Rojo.
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.FlatwoodsMonster`. It replaces `Assets.Placeholders.FlatwoodsMonster_PH` (same `CryptidId`; see `PLACEHOLDER-KIT.md`).
- **Counts:** **40 parts** (incl. invisible `Root`): 6 Part:Cylinder, 29 Part:Block, 2 WedgePart, 2 Part:Ball. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, Neon: none, scripts: none.** Within the large-cryptid cap (Rare+ ≤ 80 parts / 5,000 tris, style guide §6).
- **Materials:** Fabric ×21, CorrodedMetal ×4, Slate ×5, Basalt ×1, Glass ×2, Limestone ×6. No Plastic/SmoothPlastic.
- **Colours (tokens):**
  - Ash: SkirtTier1, SkirtTier2, SkirtTier3
  - Silver: SkirtHem, Collar, HoodRim_R, HoodRim_L
  - Soot: Pleat1, PleatUpper1, Pleat2, PleatUpper2, Pleat3, PleatUpper3, Pleat4, PleatUpper4, Pleat5, PleatUpper5, Pleat6, PleatUpper6, Torso, ArmUpper_R, ArmFore_R, ArmUpper_L, ArmFore_L
  - Void: Face
  - Blood: HoodSpadea, HoodSpadeb, HoodLobe_R, Cowl_R, HoodLobe_L, Cowl_L
  - GoldBright: Eye_R, Eye_L
  - Bone: Claw1_R, Claw2_R, Claw3_R, Claw1_L, Claw2_L, Claw3_L
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**), at the footprint centre. `PivotOffset` puts the pivot on the floor (y = 0), so `model:PivotTo(pad.CryptidMount.CFrame)` needs **no offset**. **Front = −Z.**
- **Size (studs):** 5.0 W × 9.0 H × 4.0 D → **H 9.0 × L 5.0** vs roster 9 × 5 (H +0%, L +0%; ±15% OK). Fits ≤ 8 × 8 footprint and ≤ 10 height.
- **Rarity cue (§3):** Silver `#8C9AA3` (D11) hem ring, collar and hood-crest edge; the oversized spade hood is the big Rare shape.
- **Physics:** all parts `Anchored`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` only on `SkirtTier1`, `SkirtHem`, `SkirtTier2`, `SkirtTier3`, `Torso`, `HoodSpadea`, `HoodSpadeb`, `HoodLobe_R`, `HoodLobe_L`; off on everything else (< 1 stud³).
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned; based on folklore; no Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/FlatwoodsMonster_2026-11-04_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** A tall robed figure: a crimson **ace-of-spades hood** (triangle peak + two round lobes + side cowls) framing a **Void face** with two small GoldBright Glass eyes. Tiered, pleated dark skirt-like lower body, a narrow torso, and long thin arms ending in 3 bone claws each.
- **Redesign passes used:** 1 (hood thicker with the tip leaning over the face, more pleats, tilted skirt tiers).
- **Notes:** The skirt can still read as stacked tiers ('cake'); check in Studio. The hood is a flat plate, so it is thin from the side. Hood spade uses `tri()` wedges, so it depends on wedge facing.

#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: §1 tokens only (validator) |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Fabric, CorrodedMetal, Slate, Basalt, Glass, Limestone; no Plastic/SmoothPlastic. Glass only where a glow is wanted (§2) |
| 5 | Silhouette | **PASS (box preview)**: hero shape reads in 3/4 and side. Studio read **PENDING** |
| 6 | Not toy-like / age-appropriate | **PASS (preview)**: spooky, not gore; no blood or wounds |
| 7 | Fit | **PASS**: within ±15% of roster H × L; ≤ 8 × 8, ≤ 10 tall; faces −Z |
| 8 | Budget | **PASS**: 40 ≤ 80 parts; 0 textures/lights/emitters |
| 9 | Readability (phone, §4 lighting) | **PENDING**: lighting read in Play (Studio) |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; collide/touch/query off; small parts cast no shadow; no unions |
| 12 | Naming | **PASS**: unique part names (`_R`/`_L` mirrored pairs) |
| 13 | Screenshot proof | **PENDING**: Studio captures by QA (D12: these also feed icon/thumbnails; box renders are only a fallback if imports slip past Mon 9 Nov) |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts/meshes/decals |
| 15 | Licence | **PASS**: self-built |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (BATCH-01 #1), pivot flush on `Pad.CryptidMount`, pad billboard clearance, Highlight limit (D8) before any outline, triangle count.
