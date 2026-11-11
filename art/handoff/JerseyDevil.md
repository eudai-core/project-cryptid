### Handoff: JerseyDevil (v1.0, 2026-11-04)
- **Asset id / model name:** `JerseyDevil` · Attributes `CryptidId = "jersey_devil"` (spec 09 §3 / `art/roster-provisional.md`), `AssetVersion = "1.0"`
- **Roster:** #11, Epic, winged, 8 × 7 (provisional, ~70%).
- **File path (box):** `/workspace/project-cryptid/art/models/JerseyDevil.rbxmx`. Generator: `art/tools/build_assets.py JerseyDevil` (lib `rbxlib.py`). Do NOT map the preview data in `models/JerseyDevil.parts.json` into Rojo.
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.JerseyDevil`. It replaces `Assets.Placeholders.JerseyDevil_PH` (same `CryptidId`; see `PLACEHOLDER-KIT.md`).
- **Counts:** **58 parts** (incl. invisible `Root`): 4 Part:Ball, 36 Part:Block, 17 WedgePart. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, Neon: none, scripts: none.** Within the large-cryptid cap (Rare+ ≤ 80 parts / 5,000 tris, style guide §6).
- **Materials:** Slate ×20, Fabric ×18, Limestone ×15, Glass ×2, Basalt ×2. No Plastic/SmoothPlastic.
- **Colours (tokens):**
  - Soot: Pelvis, Torso, Chest, Neck, Head, Tail1, Tail2, Tail3, Ear_R, ArmUpper_R, ArmFore_R, Thigh_R, Shin_R, Cannon_R, Ear_L, ArmUpper_L, ArmFore_L, Thigh_L, Shin_L, Cannon_L
  - Blood: Mane, Spine1, Spine2, Spine3, Eye_R, TailFork_R, Eye_L, TailFork_L
  - BoneDim: Muzzle, WingArm_R, WingFinger1_R, WingFinger2_R, WingFinger3_R, WingArm_L, WingFinger1_L, WingFinger2_L, WingFinger3_L
  - Bone: HornBase_R, HornTip_R, Claw_R, HornBase_L, HornTip_L, Claw_L
  - Ash: WingA_Ra, WingA_Rb, WingB_Ra, WingB_Rb, WingC_Ra, WingC_Rb, WingA_La, WingA_Lb, WingB_La, WingB_Lb, WingC_La, WingC_Lb
  - Void: Hoof_R, Hoof_L
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**), at the footprint centre. `PivotOffset` puts the pivot on the floor (y = 0), so `model:PivotTo(pad.CryptidMount.CFrame)` needs **no offset**. **Front = −Z.**
- **Size (studs):** 7.1 W × 8.0 H × 7.1 D → **H 8.0 × L 7.1** vs roster 8 × 7 (H -0%, L +1%; ±15% OK). Fits ≤ 8 × 8 footprint and ≤ 10 height.
- **Rarity cue (§3):** Epic = Blood accent + horns: crimson mane/collar, dorsal spines and forked tail tips; curved bone horns.
- **Physics:** all parts `Anchored`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` only on `Pelvis`, `Torso`, `Chest`; off on everything else (< 1 stud³).
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned; based on folklore; no Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/JerseyDevil_2026-11-04_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** A crouched kangaroo-legged devil with a long **horse skull** head, curved bone horns, crimson Glass eyes, wide **bat wings** (BoneDim struts + Ash membrane triangles), small clawed arms, black hooves and a long tail ending in a crimson **fork**. A crimson mane at the neck is the accent.
- **Redesign passes used:** 0.
- **Notes:** Wing membranes and tail fork are wedges (`tri()`), so they depend on wedge facing. Wing span 7.1 fits 8 × 8.

#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: §1 tokens only (validator) |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Slate, Fabric, Limestone, Glass, Basalt; no Plastic/SmoothPlastic. Glass only where a glow is wanted (§2) |
| 5 | Silhouette | **PASS (box preview)**: hero shape reads in 3/4 and side. Studio read **PENDING** |
| 6 | Not toy-like / age-appropriate | **PASS (preview)**: spooky, not gore; no blood or wounds |
| 7 | Fit | **PASS**: within ±15% of roster H × L; ≤ 8 × 8, ≤ 10 tall; faces −Z |
| 8 | Budget | **PASS**: 58 ≤ 80 parts; 0 textures/lights/emitters |
| 9 | Readability (phone, §4 lighting) | **PENDING**: lighting read in Play (Studio) |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; collide/touch/query off; small parts cast no shadow; no unions |
| 12 | Naming | **PASS**: unique part names (`_R`/`_L` mirrored pairs) |
| 13 | Screenshot proof | **PENDING**: Studio captures by QA (D12: these also feed icon/thumbnails; box renders are only a fallback if imports slip past Mon 9 Nov) |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts/meshes/decals |
| 15 | Licence | **PASS**: self-built |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (BATCH-01 #1), pivot flush on `Pad.CryptidMount`, pad billboard clearance, Highlight limit (D8) before any outline, triangle count.
