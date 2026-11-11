### Handoff: Hodag (v1.0, 2026-11-03)
- **Asset id / model name:** `Hodag` · Attributes `CryptidId = "hodag"` (spec 01 B3 #6), `AssetVersion = "1.0"`
- **File path (box):** `/workspace/project-cryptid/art/models/Hodag.rbxmx`. Generator: `art/tools/build_assets.py Hodag` (shared lib `art/tools/rbxlib.py`; preview data `models/Hodag.parts.json`, do NOT map the `.json` into Rojo)
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.Hodag` (style guide §8, proposed)
- **Goes in game at:** wild spawn in **The Wilds**, 20 studs outside the player's Wild Gate (tutorial) `[S01 B3, B7]`; then a pad and inventory.
- **Counts:** **35 parts** (1 invisible Root): 10 blocks, 20 wedges, 2 balls, 2 cylinders + Root. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, scripts: none.**
- **Materials:** Slate ×11 (hide), Limestone ×20 (horns/spikes/teeth/claws), Fabric ×1 (maw), Glass ×2 (eyes). No Plastic/Neon (and no mesh needed).
- **Colours (tokens):**
  - Soot: body, shoulders, skull, jaw, brows, tail, legs
  - Blood: maw
  - Bone: teeth, tusks, horns, 6 back spikes, tail spike, claws
  - GoldBright: eyes (Glass)
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**). `PivotOffset` puts the **pivot at ground level (y = 0)**, so `model:PivotTo(cf)` sits it flat with **no offset**. **Front = −Z** (`Root.CFrame.LookVector`). Pivot = footprint centre on the floor.
- **Size (studs):** 2.9 × 3.1 × 6.0 (≤ 6 × 6 Common footprint)
- **States / variants:** none
- **Physics:** every part `Anchored = true`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` on only for `Body`, `Shoulders`, `Skull`, `Jaw`, `Maw`; off on all other parts.
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned. No Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/Hodag_2026-11-03_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** a low, wide quadruped with a big boxy skull, a wide-open Blood maw full of bone teeth and two tusks, two forward horns, a ridge of six bone back spikes, a spiked tail and stubby clawed legs. Glowing-ish GoldBright Glass eyes.
- **Fit pass:** v1 came out 9 studs long, over the ≤ 6 × 6 Common footprint, so the whole model was scaled to 2/3 in the generator.
#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS** |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: Slate hide, Limestone bone, Fabric maw; Glass eyes (glow wanted, Neon not allowed, D10 is Mothman-only) |
| 5 | Silhouette | **PASS (box preview)**: horns + spike ridge + grin read in side and 3/4. Studio read **PENDING** |
| 6 | Not toy-like | **PASS**: snarling, angular |
| 7 | Fit | **PASS**: 2.9 × 3.1 × 6.0 |
| 8 | Budget | **PASS**: 35 ≤ 40 |
| 9 | Readability (phone, §4 lighting) | **PENDING**: must read **outside** lair lighting in Wilds fog; Wilds lighting not specced yet. Keen Eye outline needs the Highlight limit (D8) **PENDING** |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; CanCollide/CanTouch/CanQuery off; CastShadow off on parts < 1 stud³; no unions |
| 12 | Naming | **PASS**: every part uniquely named |
| 13 | Screenshot proof | **PENDING**: Studio screenshots by QA after import. Box previews exist but are not proof |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts, meshes or decals |
| 15 | Licence | **PASS**: self-built, project-owned |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (assumed slope runs down toward −Z; see BATCH-01), pivot flush on the real pad, Highlight limit (D8) before any outline, and pad billboard clearance.
