# Project Cryptid: First Asset List (ranked by player impact)

> **Launch roster (provisional, ~70%):** [`roster-provisional.md`](roster-provisional.md), 12 cryptids from spec 09. Every entry has a `_PH` placeholder; Batch 02 adds the 4 Uncommons.

**Version:** v0.1 draft (2026-11-03) · Follows `art/style-guide.md`.
**Tags:** `[S01]`–`[S04]` = from that spec. **`[PROPOSED]`** = **Proposed default (needs Eudai sign-off)**.
**Important:** the specs give these cryptids only a **name, rarity, income, id and source**. **Every look/silhouette idea below is `[PROPOSED]`**, loosely based on public folklore, not spec facts.

**Ranking logic:** what the player sees first and most often in the first 3 minutes `[S01 B3]`, weighted by how many copies are on screen (8 plots `[S02]`).

| Rank | Asset | First seen | Why this rank |
|---|---|---|---|
| 1 | Mothman Hatchling | **0:00**, on Pad 1 | The 5-second hook: "your own cryptid already making money" `[S01 B1]` |
| 2 | Pads (12 per plot) | **0:00** | Always on screen, 96 copies in a full server, 4 states |
| 3 | Bone Altar | **0:00** (centre of plot), bought ~1:53 | Centrepiece of every plot, gains tiers |
| 4 | Fresno Nightcrawler | ~0:05–0:20, on the Rift belt | First purchase `[S01 B3 #2]` |
| 5 | Hidebehind | ~0:49–1:12, on the Rift belt | Second purchase `[S01 B3 #4]` |
| 6 | Hodag | ~2:00–2:25, in the Wilds | First wild catch `[S01 B3 #6]` |

---

## 1. Mothman Hatchling
- **STATUS (2026-11-03): v0.2 BUILT, box-side only.** `art/models/MothmanHatchling.rbxmx`, **37 parts**, 3.6 × 4.6 × 3.1. v0.2: eyes **Neon Blood (D10)**, Root flat with pivot at the feet (no offset). Validator + Rojo build PASS. **PENDING:** Studio import, screenshots, lighting read, Neon eye look. Handoff: `art/handoff/MothmanHatchling.md`.
  - Deviations from the plan below: 37 parts vs the ≤ 30 target (still under the 40 cap). Bone parts are **Limestone**. Hatchling **eggshell shards** added.
- **Spec facts:** Common, free starter, id `mothman_hatchling`, **$2/s**, on **Pad 1** from second 0, `source = starter`, Pedlar price $60 `[S01 B2] [S03 §4.3]`.
- **Silhouette** `[PROPOSED]`: a small, hunched, owl-sized moth-thing with **oversized ragged wings folded like a cloak** and **two large dark-red eyes**. The wings are the hero shape.
- **Build:** **Parts + materials**. Wedge parts for the wing shapes, a body block, eye discs.
- **Budget:** **≤ 30 parts** (small cryptid cap is 40); ~4 × 5 × 4 studs `[PROPOSED]`.
- **Materials/colours** `[PROPOSED]`: wings **Fabric** in Soot with BoneDim tattered edges; body **Fabric** Ash; eyes **Blood** (no Neon, since lair Neon is reserved for the Fissure `[S01 A4]`).
- **Lives:** `Workspace.Plots.Plot<i>` Pad 1 (any pad later), inventory, Pedlar Common pool `[S02 §5] [S03 §4.4]`.
- **Depends on:** pad model (size), pad billboard `[S01 B5]`, §4 lighting (dark wings need the ambient floor), grimoire entry.

## 2. Pads (Pads 1–12, per plot)
- **STATUS (2026-11-03): v1.0 BUILT, box-side only.** `art/models/Pad.rbxmx`, 13 parts in the template, **3–5 visible per state** (≤ 6). States are sub-Models `State_Occupied/Empty/Locked/Sealed` + `Mod_Affordable` (Blood rim), plus an invisible `CryptidMount`. Sigils are Parts, not a Decal (sigil artwork still TBD). **PENDING:** Studio read of Empty vs Locked, screenshots. Handoff: `art/handoff/Pad.md`.
- **Spec facts:** ring of **12, radius 28** around the altar; Pad 1 nearest the gate `[S02 §3]`. **CorrodedMetal ring tinted Gold, Slate centre** `[S01 A4]`. States:
  - **Occupied:** billboard with name (Bone) + income (GoldBright) `[S01 B5]`.
  - **Unlocked, empty.**
  - **Locked:** BoneDim sigil + "$120 · Carve"; **Blood border when affordable** `[S01 B5]`.
  - **Sealed (7–12):** cracked sigil + "Sealed" (BoneDim) `[S02 §3]`.
- **Silhouette** `[PROPOSED]`: a low, sunken ritual circle; a thick corroded-gold ring with an engraved slate disc, flush to the floor (≤ 0.6 studs tall).
- **Build:** **Parts + materials**. Cylinder parts + a SurfaceGui/Decal for the sigil.
- **Budget:** **≤ 6 parts per pad** (×96 per server ≈ 576) `[PROPOSED]`; diameter **10 studs** (max fit ≈ 14.5) `[PROPOSED]`.
- **Materials/colours:** CorrodedMetal Gold, Slate Soot `[S01]`; sigil BoneDim / Blood border `[S01]`; cracked overlay for sealed.
- **Lives:** `Workspace.Plots.Plot<i>`, attribute `beingStolen` on each pad `[S02 §8]`.
- **Depends on:** UITheme tokens, billboard style, sigil artwork (TBD), altar footprint.

## 3. Bone Altar
- **STATUS (2026-11-03): v1.0 BUILT, box-side only.** `art/models/BoneAltar.rbxmx`, **39 parts** (L0 14 / Tier1 12 / Tier2 13), Ø14 × 9.8. Tier sub-Models carry attribute `Tier`. 4 candles with Glass flames; `FillLightMount` for the fill light. **PENDING:** Studio read, flame look, screenshots. Handoff: `art/handoff/BoneAltar.md`.
- **Spec facts:** at plot-local **(0, 0, −4)**, centre of the pad ring `[S02 §3]`. Goal 5 "Raise the Bone Altar", **+25% income per level** `[S01 B3/B4]`. **Levels show as extra bone tiers** `[S02 §3]`. Levels 0, I, II in this build (III+ deferred) `[S01 B4]`.
- **Silhouette** `[PROPOSED]`: a squat black basalt plinth that grows a **stacked crown of bones/ribs** per level, visible over the pads from the gate.
  - L0: bare plinth.
  - L1: ring of bones.
  - L2: taller rib spire.
- **Build:** **Parts + materials** (cylinders/wedges for bones). A mesh only if the bone shapes blow the budget.
- **Budget:** **≤ 60 parts across all tiers** (L0 ≤ 15, each tier ≤ 20); footprint **≤ 16 studs** diameter, so the pad-ring walkway stays clear `[PROPOSED]`.
- **Materials/colours:** base **Basalt** Soot; bones **Limestone** Bone/BoneDim; trim **CorrodedMetal** Gold; 2–4 candle models `[PROPOSED]`. Spot for the **altar fill light** (style guide §4).
- **Lives:** `Workspace.Plots.Plot<i>`; tier models toggled by `upgrades.boneAltar` `[S01 B6]`.
- **Depends on:** pad ring spacing, lighting plan, guide-beam target `[S01 B5]`.

## 4. Fresno Nightcrawler
- **STATUS (2026-11-03): v1.0 BUILT, box-side only.** `art/models/FresnoNightcrawler.rbxmx`, **15 parts**, 1.7 × 6.2 × 3.3. **PENDING:** Studio read, screenshots. Handoff: `art/handoff/FresnoNightcrawler.md`. **Size check (Batch 02):** L 3.3 vs roster 2 (+65%); see BATCH-02.
- **Spec facts:** Common, first guaranteed Rift buy **$50**, **$3/s**, placed on Pad 2, id `fresno_nightcrawler`, Pedlar $90. Flagged as a **proposed grimoire entry** `[S01 B3, note] [S03 §4.3]`.
- **Silhouette** `[PROPOSED]` (folklore: a pale walking pair of legs): **two tall, thin, bone-white legs with a tiny or no torso**, an eerie stride pose. Reads instantly as "legs only".
- **Build:** **Parts + materials**. Very simple, a few long cylinders/blocks.
- **Budget:** **≤ 15 parts**; ~3 × 6 × 2 studs `[PROPOSED]`.
- **Materials/colours** `[PROPOSED]`: **Fabric** or **Limestone** in Bone (the brightest cryptid, which helps readability), BoneDim joints, faint Soot grime at the feet.
- **Lives:** first on the **Rift Fissure** belt (Basalt, Rift Neon trim; plot-local x = −50) `[S02 §3]`, then Pad 2 and inventory.
- **Depends on:** Rift Fissure belt height/width (not specced), pad model, grimoire entry.

## 5. Hidebehind
- **STATUS (2026-11-03): v1.0 BUILT, box-side only.** `art/models/Hidebehind.rbxmx`, **27 parts**, 4.9 × 8.2 × 5.1. Stump is **Wood** BoneDim. 2 redesign passes used. **PENDING:** dark-body readability in Play, screenshots. Handoff: `art/handoff/Hidebehind.md`. **Size check (Batch 02):** L 5.1 vs roster 4 (+28%); see BATCH-02.
- **Spec facts:** Common, second guaranteed Rift buy **$75**, **$4/s**, placed on Pad 3, id `hidebehind`, Pedlar $120. A **proposed grimoire entry** `[S01 B3] [S03 §4.3]`.
- **Silhouette** `[PROPOSED]` (folklore: never seen, always hiding behind something): a **tall, gaunt, stooped shape half-hidden behind a dead tree stump**; long fingers curling round the bark. The stump is part of the model.
- **Build:** **Parts + materials** (WoodPlanks/Wood stump, thin Basalt limbs).
- **Budget:** **≤ 35 parts**; ≤ 6 × 9 × 6 studs `[PROPOSED]`.
- **Materials/colours** `[PROPOSED]`: body **Basalt/Slate** Soot, **Bone eye-glints** + BoneDim claws (the light contrast part); stump **Wood** dark brown-grey.
- **Lives:** Rift belt → Pad 3 → inventory.
- **Depends on:** pad model, §4 lighting (dark body is the hardest readability case), grimoire entry.

## 6. Hodag
- **STATUS (2026-11-03): v1.0 BUILT, box-side only.** `art/models/Hodag.rbxmx`, **35 parts**, Parts only (**no mesh needed**), 2.9 × 3.1 × 6.0 (scaled to 2/3 to fit the Common 6 × 6 footprint). Eyes GoldBright Glass. **PENDING:** Wilds lighting read, screenshots. Handoff: `art/handoff/Hodag.md`. **Size check (Batch 02):** H 3.1 vs roster 4 (−22%); see BATCH-02.
- **Spec facts:** wild Common, id `hodag`, **$5/s**, tutorial spawn **20 studs outside the player's Wild Gate**, caught with the **L1 tool / lantern** (3 s catch, ≤ 12 studs) `[S01 B3 #6, B7]`. Placed in goal 7. Pedlar $150. Needs a grimoire entry `[S01 open questions]`.
- **Silhouette** `[PROPOSED]` (folklore: a horned, spiny beast with a wide grin): a **low, wide quadruped**, **two horns**, a **ridge of back spikes**, an oversized grinning jaw.
- **Build:** **Parts + materials** (wedges for spikes/horns). Fallback: one generated MeshPart if the spike ridge exceeds budget.
- **Budget:** **≤ 40 parts** or **≤ 2,000 tris** as a mesh; ~6 × 4 × 8 studs `[PROPOSED]`.
- **Materials/colours** `[PROPOSED]`: hide **Slate/Basalt** Soot; horns/spikes **Limestone** Bone; mouth **Blood**.
- **Lives:** **The Wilds** (r > 330), behind the plot's Wild Gate `[S02 §2]`; then a pad and inventory. Must read **outside** lair lighting, through fog.
- **Depends on:** Wilds terrain/lighting (not specced yet), guide beam `[S01 B5]`, catch tool feedback, a possible Keen Eye outline `[S04 h3]`.

## 7. Placeholder silhouette kit (added 2026-11-04, launch plan change)
- **STATUS: v1.0 BUILT, box-side only.** `art/tools/build_placeholder.py` → `art/models/placeholders/<Name>_PH.rbxmx` (`IsPlaceholder = true`). 4 archetypes (winged, lurker, beast, serpent) × Common/Uncommon/Rare/Epic trims, 10–15 parts, crimson Glass eyes, scale or `--height/--length` sizing, `--roster` mode. **2026-11-04: all 12 roster `_PH` files built at roster sizes, PASS** (sheet `qa/screenshots/RosterPlaceholders_2026-11-04_preview-sheet.png`); 16 samples in `placeholders/samples/` PASS. Sheet: `qa/screenshots/Placeholders_2026-11-04_preview-sheet.png`. Doc: `art/handoff/PLACEHOLDER-KIT.md`.
- **Why:** 12 launch cryptids are due ~Mon 9 Nov (freeze Fri 13, launch Fri 20 Nov) and the roster isn't final; every unbuilt roster entry gets a placeholder with its real `CryptidId`.

**Batch 01 summary:** `art/handoff/BATCH-01.md` (Rojo mapping, pending Studio checks).

---

## Creator Store asset log `[DECIDED D6]`
Every Creator Store asset must be logged here before use: free to use, every script stripped and checked.

| Asset | Store ID | Creator | Licence / free? | Scripts stripped + checked (who, date) | Used in |
|---|---|---|---|---|---|
| *(none yet)* | – | – | – | – | – |

## Shared dependencies / blockers
- **Pad size, Rift belt dimensions and Wilds look aren't specced.** The pad diameter (10 studs) is proposed here; cryptid sizes depend on it.
- **Grimoire list file doesn't exist**; all four species are pending entries `[S01] [S03 §4.4]`.
- **Sigil/rune artwork** (pads, altar, UI) is TBD in every spec.

## 8. Uncommons (Batch 02, 2026-11-04)
- **Jackalope** (`jackalope`). **STATUS: v1.0 BUILT, box-side only.** `art/models/Jackalope.rbxmx`, **26 parts**, H 3.0 × L 3.8 (roster 3 × 4). **PENDING:** Studio read, antler thickness on a phone, screenshots. Handoff: `art/handoff/Jackalope.md`.
- **Dover Demon** (`dover_demon`). **STATUS: v1.0 BUILT, box-side only.** `art/models/DoverDemon.rbxmx`, **24 parts**, H 4.05 × L 2.85 (roster 4 × 3). Eyes are GoldBright Glass, not Neon (D10). **PENDING:** Studio read, screenshots. Handoff: `art/handoff/DoverDemon.md`.
- **Snallygaster** (`snallygaster`). **STATUS: v1.0 BUILT, box-side only.** `art/models/Snallygaster.rbxmx`, **33 parts**, H 5.1 × L 7.6 (roster 5 × 7). Wing membranes are wedge triangles. **PENDING:** wedge facing, Studio read, screenshots. Handoff: `art/handoff/Snallygaster.md`.
- **Loveland Frogman** (`loveland_frogman`). **STATUS: v1.0 BUILT, box-side only.** `art/models/LovelandFrogman.rbxmx`, **24 parts**, H 4.8 × L 3.1 (roster 5 × 3). 1 redesign pass. **PENDING:** Studio read, screenshots. Handoff: `art/handoff/LovelandFrogman.md`.
- Rares / Epics (#9–12): **not started**; the `_PH` placeholders ship until full models exist.
