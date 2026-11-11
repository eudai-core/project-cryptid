### Handoff: BoneAltar (v1.0, 2026-11-03)
- **Asset id / model name:** `BoneAltar` · Attributes `AssetId = "boneAltar"` (key `upgrades.boneAltar`, spec 01 B6), `AssetVersion = "1.0"`, `MaxTier = "2"`
- **File path (box):** `/workspace/project-cryptid/art/models/BoneAltar.rbxmx`. Generator: `art/tools/build_assets.py BoneAltar` (shared lib `art/tools/rbxlib.py`; preview data `models/BoneAltar.parts.json`, do NOT map the `.json` into Rojo)
- **Proposed place path:** `ReplicatedStorage.Assets.Lair.BoneAltar` (style guide §8, proposed)
- **Goes in game at:** one per plot at plot-local **(0, 0, −4)**, centre of the pad ring `[S02 §3]`.
- **Counts:** **39 parts** (2 invisible): L0 base 14, Tier1 12, Tier2 13. 24 cylinders, 8 balls, 3 blocks, 2 wedges (+2 invisible blocks). **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, scripts: none.**
- **Materials:** Basalt ×4, Slate ×1, CorrodedMetal ×1, Limestone ×27, Glass ×4 (candle flames; Neon not allowed in the lair). No Plastic/Neon.
- **Colours (tokens):**
  - Soot: `Step1`, `Step2`, `Plinth`
  - Gold: `TopTrim`
  - Bone: candles, crown ribs, skull, Tier2 vertebrae 1/3, crown skull, horns
  - BoneDim: jaw, crossbones, vertebrae 2/4, cage ribs
  - GoldBright: 4 Glass flames
  - Void: skull sockets
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**). `PivotOffset` puts the **pivot at ground level (y = 0)**, so `model:PivotTo(cf)` sits it flat with **no offset**. **Front = −Z** (`Root.CFrame.LookVector`). Pivot = centre of the bottom step on the floor. **`FillLightMount`** (invisible, y = 9): the Architect adds the proposed altar fill PointLight here (`#FFB36B`, range 40, brightness 0.8, Shadows off, style guide §4).
- **Size (studs):** Ø 14 × 9.8 tall at Level II (≤ 16 footprint)
- **States / variants:** Level 0 / I / II via tier sub-Models (below)
- **Physics:** every part `Anchored = true`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` on only for `Step1`, `Step2`, `Plinth`, `TopTrim`, `Skull`; off on all other parts.
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned. No Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/BoneAltar_2026-11-03_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** a squat two-step basalt plinth with a gold trim and four bone candles (Level 0). **Tier1** adds a ring of six bone ribs curling up around a front-facing skull with crossbones on the front face. **Tier2** adds a vertebra spire, a rib cage and a horned crown skull on top, visible over the pads from the gate.

#### Tier toggling (Architect)
| Sub-Model | Attr | Parts | Parent it when |
|---|---|---|---|
| (base, direct children) | – | 14 | always |
| `Tier1` | `Tier = "1"` | 12 | `upgrades.boneAltar >= 1` |
| `Tier2` | `Tier = "2"` | 13 | `upgrades.boneAltar >= 2` (Tier1 stays) |

```lua
-- sketch only: on spawn, detach tiers; re-parent as the level rises
for _, t in ipairs(altar:GetChildren()) do
	local n = t:IsA("Model") and tonumber(t:GetAttribute("Tier"))
	if n then t.Parent = (level >= n) and altar or nil end   -- keep a reference to re-parent later
end
```
Levels III+ are deferred `[S01 B4]`; `MaxTier = "2"`. Each tier ≤ 20 parts, total 39 ≤ 60.
#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: Soot/Gold/Bone/BoneDim/GoldBright/Void only |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Basalt/Slate base, CorrodedMetal trim, Limestone bones; Glass flames (glow wanted, Neon banned in lair, §2) |
| 5 | Silhouette | **PASS (box preview)**: L0 → I → II grows clearly taller and busier. Studio read **PENDING** |
| 6 | Not toy-like | **PASS**: heavy, asymmetric bone placement |
| 7 | Fit | **PASS**: Ø14 ≤ 16; 9.8 tall |
| 8 | Budget | **PASS**: 39 ≤ 60 (L0 14 ≤ 15, T1 12 ≤ 20, T2 13 ≤ 20) |
| 9 | Readability (phone, §4 lighting) | **PENDING**: lighting read in Play; Glass flame look **PENDING** (they may read as dull yellow without the fill light) |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; CanCollide/CanTouch/CanQuery off; CastShadow off on parts < 1 stud³; no unions |
| 12 | Naming | **PASS**: every part uniquely named |
| 13 | Screenshot proof | **PENDING**: Studio screenshots by QA after import. Box previews exist but are not proof |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts, meshes or decals |
| 15 | Licence | **PASS**: self-built, project-owned |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (assumed slope runs down toward −Z; see BATCH-01), pivot flush on the real pad, Highlight limit (D8) before any outline, and pad billboard clearance.
