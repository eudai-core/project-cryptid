### Handoff: BeastOfBrayRoad (v1.0, 2026-11-04)
- **Asset id / model name:** `BeastOfBrayRoad` · Attributes `CryptidId = "beast_of_bray_road"` (spec 09 §3 / `art/roster-provisional.md`), `AssetVersion = "1.0"`
- **Roster:** #10, Rare, quadruped, 6 × 7 (provisional, ~70%).
- **File path (box):** `/workspace/project-cryptid/art/models/BeastOfBrayRoad.rbxmx`. Generator: `art/tools/build_assets.py BeastOfBrayRoad` (lib `rbxlib.py`). Do NOT map the preview data in `models/BeastOfBrayRoad.parts.json` into Rojo.
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.BeastOfBrayRoad`. It replaces `Assets.Placeholders.BeastOfBrayRoad_PH` (same `CryptidId`; see `PLACEHOLDER-KIT.md`).
- **Counts:** **48 parts** (incl. invisible `Root`): 5 Part:Ball, 23 Part:Block, 19 WedgePart. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, Neon: none, scripts: none.** Within the large-cryptid cap (Rare+ ≤ 80 parts / 5,000 tris, style guide §6).
- **Materials:** Fabric ×32, Basalt ×1, Glass ×2, Limestone ×12. No Plastic/SmoothPlastic.
- **Colours (tokens):**
  - Ash: Hip, Waist, Ribcage, Muzzle, ForelegUpper_R, ForelegLower_R, Thigh_R, Hock_R, HindLower_R, ForelegUpper_L, ForelegLower_L, Thigh_L, Hock_L, HindLower_L
  - Soot: Hump, Neck, Head, Tail1, Ear_R, Forepaw_R, Hindpaw_R, Ear_L, Forepaw_L, Hindpaw_L
  - BoneDim: ChestRuff, Jaw
  - Void: Nose
  - Silver: Mane1, Mane2, Mane3, Mane4, Mane5, Tail2
  - Blood: Eye_R, Eye_L
  - Bone: Fang_R, ForeClaw1_R, ForeClaw2_R, ForeClaw3_R, HindClaw1_R, HindClaw2_R, Fang_L, ForeClaw1_L, ForeClaw2_L, ForeClaw3_L, HindClaw1_L, HindClaw2_L
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**), at the footprint centre. `PivotOffset` puts the pivot on the floor (y = 0), so `model:PivotTo(pad.CryptidMount.CFrame)` needs **no offset**. **Front = −Z.**
- **Size (studs):** 2.2 W × 6.0 H × 7.4 D → **H 6.0 × L 7.4** vs roster 6 × 7 (H -1%, L +6%; ±15% OK). Fits ≤ 8 × 8 footprint and ≤ 10 height.
- **Rarity cue (§3):** Silver Fabric mane spikes along the shoulder hump (crest) + silver tail tip.
- **Physics:** all parts `Anchored`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` only on `Hip`, `Waist`, `Ribcage`, `Hump`, `Neck`, `Head`; off on everything else (< 1 stud³).
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned; based on folklore; no Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/BeastOfBrayRoad_2026-11-04_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** A hunched wolf-beast on all fours: huge shoulder hump with a **spiked silver mane**, deep ribcage, long forelegs (built to rear up later), digitigrade hind legs, low wolf head with pale jaw, bone fangs, crimson Glass eyes and bone claws.
- **Redesign passes used:** 0.
- **Notes:** On all fours as specified; a rearing pose would be a separate variant. Body is dark Ash/Soot, so the lighting read matters.

#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: §1 tokens only (validator) |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Fabric, Basalt, Glass, Limestone; no Plastic/SmoothPlastic. Glass only where a glow is wanted (§2) |
| 5 | Silhouette | **PASS (box preview)**: hero shape reads in 3/4 and side. Studio read **PENDING** |
| 6 | Not toy-like / age-appropriate | **PASS (preview)**: spooky, not gore; no blood or wounds |
| 7 | Fit | **PASS**: within ±15% of roster H × L; ≤ 8 × 8, ≤ 10 tall; faces −Z |
| 8 | Budget | **PASS**: 48 ≤ 80 parts; 0 textures/lights/emitters |
| 9 | Readability (phone, §4 lighting) | **PENDING**: lighting read in Play (Studio) |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; collide/touch/query off; small parts cast no shadow; no unions |
| 12 | Naming | **PASS**: unique part names (`_R`/`_L` mirrored pairs) |
| 13 | Screenshot proof | **PENDING**: Studio captures by QA (D12: these also feed icon/thumbnails; box renders are only a fallback if imports slip past Mon 9 Nov) |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts/meshes/decals |
| 15 | Licence | **PASS**: self-built |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (BATCH-01 #1), pivot flush on `Pad.CryptidMount`, pad billboard clearance, Highlight limit (D8) before any outline, triangle count.
