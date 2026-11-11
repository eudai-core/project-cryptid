# Plan: #17 Visual pass 1 — lighting, atmosphere and VFX (plan only)

**Status:** plan only. No code until #14 merges. Owner is the Architect (director ruling 19).  
**Baseline (QA, do not invent):** `qa/pr14-8522745-report.md` — Town **363 / 364 parts**, **24 / 24 lights**. Groups: Hollowmere 130/3, Districts 61/1, Lamps 36/14, Wall 56, Roads 16, WeepingWell 20/1. Lights are at the cap (0 spare). Parts have **1 spare**.  
**Later same counts:** #14 head `f939046` is also 363/24 after the D1 sign fix (rearrange only). Do not reopen D1.  
**Caps:** 364 parts, 24 lights, fewer than 31 Highlights, ≤6 emitters / 120 particles per effect, QualityLevel 1–4 fallback (no bloom, fewer flames). No Creator Store, no new map, no MeshParts/Unions that need uploaded assets. Spec 15 look wins (purple night, coloured flames, Neon only on flames / portals / runes / signs / eyes). UI keeps the spec 01 A2 palette. No fake players. Non-scriptable Lighting (Technology, and Sky textures if used) goes in `default.project.json` `$properties`.

**How to read the current town:** the v3 silhouettes are already blocked in `TownBuilder.luau` (tree, longship cylinder, tent poles, clock stack, well + 8 runestones, 3 crows in code). QA still does not *read* them vs `art/concepts/v3-town.jpg`, `v3-shops.jpg`, `pale-pedlar.jpg` and ART-DIRECTION-V2 (v3 section) / spec 15 §2–3. This pass is readability and VFX, not a rebuild.

**Issue #17 text (fetched):** still says “No Town geometry”, branch `gemini/visual-pass-1`, owner Gemini. Grok Bot later put the QA silhouette gaps in #17 and named the Architect as owner. Treat geometry-in-budget as in scope; ask Grok Bot to update the issue (open question A).

Derived part counts below come from reading TownBuilder at `f939046`. They are **derived**, not QA census rows.

---

## Per-item plan

| Item | Concept + art direction | The change | Part Δ | Light Δ | Other instances | Highlights | Spec 16 | QA acceptance (screenshot) |
|---|---|---|---|---|---|---|---|---|
| A. Purple night sky | v3-town.jpg; spec 15 §2; ART-DIRECTION-V2 “purple night sky” | Add a `Sky` (not a BasePart). Prefer built-in `rbxasset` night textures + high StarCount, no sun. Keep Atmosphere NightMist / Decay NightSky. Only retune ClockTime 1, Brightness 1.5, Exposure 0.3, Fog 250/1100, Atmosphere 0.18/0.30, Bloom 0.45/28/1.5, Grade 0.02/0.08/0.16 if the Sky still leaves a black zenith (ruling 8 allows a tune). | 0 | 0 | 1 Sky | 0 | — (world, not UI) | Plaza, Q8 vs Q1: sky is purple, not a black void; bloom off at Q1. Compare to v3-town.jpg. |
| B. Ground cobbles | v3-town / v3-shops stone plaza; spec 15 “not muddy browns”. QA: lava-like cracks from Cobblestone + Soot (28,25,23)/(42,36,39) + warm lamps | Change cobble (and roads) off Cobblestone, e.g. Pavement / Slate / Rock, and shift the colour toward a cooler ash so Candle `#FFB36B` lamps do not redden the cracks. 0 new parts. | 0 | 0 | Material / colour only | 0 | — | Plaza-west and a portal approach: grey-violet stone, not lava. Signs and flames still read. |
| C. Well mist, stone, runes | v3-town central well; spec 15 §3 | Texture the existing Stone cylinder as brick/slate (not a flat black drum). Optional +2 rim/lip parts. Tall teal column = Beam + a stronger `SpiritMist` (parented to WellDrip; drop the invisible Well Centre, −1). Convert 8 `RuneMark` neon parts to SurfaceGui / Decal carvings on the stones (−8, and they finally read as carvings). Keep the 1 well light; do not add a second. | **est. −7 to −9** (or −5 if +2 rim) | 0 | 1 Beam, retuned emitters (WellSpirit group still ≤6 / 120) | 0 | — | Close well shot: brick lip, carved glowing runes, a tall teal column. Q1: column thinner / slower, still teal. |
| D. Clock belfry + numerals | v3-town Dusk & Dial; town-hub.jpg belfry note; v2-town-portals for a readable face only (shop shapes in that file are retired). Ruling 2/21: colour *change* is Update 1 | Keep the lean. Rebuild 5 shaft blocks as base + mid + a slightly wider belfry + a WedgePart cap (net ~0 to +2). Numerals and hands = SurfaceGui on ClockFace (0 parts). Launch face may be softly purple; do not animate event colours yet. Existing crow stays, but move it onto the cap so it silhouettes. | **est. 0 to +2** | 0 (use MoonGlow neon, no new light) | SurfaceGui numerals | 0 | — | Clock from the plaza: a tower with a belfry and readable numerals, not a block stack. |
| E. Runeheart tree, runes, bottles, door | v3-shops left; spec 15 §3; name is Runeheart Apothecary (ruling 3) | Keep trunk, canopy, green eye, two green flames. Drop canopy balls 5→3 (−2). Add a door in the hollow (+1). Hang the existing 3 bottles from branches on Beam “strings”; enlarge them. Trunk runes: Decals / SurfaceGui (the 3 neon Rune strips can stay if they still read, or become carvings). | **est. −1** | 0 | Beams for strings; rune Decals | 0 | — | Tree from the plaza: carved trunk, hanging bottles, a door, stained green eye. Sign still clear. |
| F. Howling Horn longship | v3-shops right; v3-town lower left; spec 15 §3 | Keep the hull cylinder and blue flame. Add a prow Wedge, two gunwales, a stern post (**est. +4**). Reshape the pale “blob” figurehead into a longer serpent neck, jaw and blue neon eyes. Optional shield / plank Decals on the hull. | **est. +4** | 0 | Decals | 0 | — | Tavern from the plaza: reads as an overturned longship with a serpent figurehead and blue fire. |
| G. Veil & Fate tent drapes | v3-town lower right; spec 15 §3 | Code already has 4 poles, a flat roof, 3 drapes and a rug, but TentCloth `#4C2878` dies on a black sky. Brighten the cloth token (world only, not UI). Replace the flat roof with a peaked pair of Wedges (**est. +1**). Split the front drape into two tied-back panels (**est. +1**). Let the existing violet flame and sign light the cloth. | **est. +2** | 0 | brighter Fabric / Texture | 0 | — | Tent from the plaza: peaked purple cloth, eye sigil, open doorway. Not a dark box. |
| H. Pedlar figure + cages | pale-pedlar.jpg; spec 15 §3; spec 16 rule 5 | Keep the stall, sign and green lantern (D1 already moved the lantern). Add a stylized hooded *statue* (hood + cloak + body, **est. +3**), not an avatar and not a hidden shop. Add 3 simple cage frames (**est. +6 to +9**) with a visible stock token / SurfaceGui portrait, variant badge and price *before* purchase. Odds stay behind “Details”. | **est. +9 to +12** | 0 (existing lantern light only) | SurfaceGui price / badge | 0 | **Rule 5** (and hard limit: no fake players, rule 8) | From the plaza: a veiled figure and cages in front of the stall; stock and price readable at the counter. |
| I. Portal arch forms + vortex swirl | v3-town three arches; ART-DIRECTION-V2 portals; spec 15 §3 | Woods: enlarge the two existing knots; add **est. +2** gnarled branches. Marsh: add **est. +2** stone coils around a pillar so the head reads as a serpent, not two posts + a ball. Quarry: thicken the 8 ribs; add **est. +1** sternum arch. Swirl: keep the Neon disc but fade it; add 2 Beams + retune Swirl/Sparks on the disc (drop VortexHost, −3 across 3 portals). Q1 disables Sparks. Signs stay above the arch (D1). | **est. +2 net** ( +5 form, −3 hosts ) | 0 (keep the 3 portal lights) | 2 Beams / portal, retuned emitters | 0 | — | Each portal from the plaza: tree / serpent / ribcage is obvious; the disc swirls; name + lock still clear. Q1: glow remains, swirl calmer. |
| J. Decorative life | v3-town / town-hub crows; spec 15 §3 | Three crows already exist (apothecary, tavern, clock) and were not seen (black on black, too small, too high). Enlarge slightly, park them on signs or the belfry, use a slightly lighter Void, optional tiny neon eye. Creaking signs: a small idle sway on sign parts, no new parts. Drifting runes: keep well `RuneDrift`; add a low-rate plaza drift parented to an existing part. No fake bystanders (ruling 22). | 0 | 0 | 1 extra emitter group, sign sway | 0 (no town Highlights) | Rule 8: no simulated crowd | Plaza overview: at least one crow and some drifting runes are visible. No extra humanoids. |
| K. Reusable catch / collect VFX | spec 15 §4; art/vfx/templates; ATMOS catch-beat | Pool, do not parent into the Town folder (those part caps are for Town). Modules: coloured-flame already in town; rune glow; portal swirl (item I); catch sparkle + rarity ring + wax-seal “BOUND!”; rare-cryptid aura; pad collect pop. Wire existing templates where they fit, but **do not** follow the old template README “no Neon / no purple” — that is superseded by rulings 1 and 9. Slim the 67–74-part Rare/Epic chalk circles; they are too heavy even as temps. Temporary reveal lights last <3 s and are not Town lights. | 0 Town parts | 0 Town lights | Pooled emitters / Beams / BillboardGui; ≤6 / 120 per effect | Rare aura only, **est. 0–8 pooled**, never a standing town Highlight | **Rules 1, 2, 3, 9** (rarity-scaled reveal, Stat Card after BOUND!, collect pop, honest lose-side). Reduced Motion shortens, never lies. | Clip: a Common catch is short; an Epic peaks on BOUND! then the Stat Card, no shop modal. Pad collect shows a small Gold burst. Q1 / Reduced Motion still clearly resolve. |

---

## Consolidation bank (where parts get freed)

All figures **derived / estimated** from TownBuilder at `f939046`. Measure again in the census test before spending.

| Source | Change | Est. parts freed |
|---|---|---|
| Lamps 36 (18 posts + 18 heads, 14 lit) | Merge each head into the post; PointLight stays on the post | −18 |
| 5 `FlameHost` invisible parts (2 apothecary, tavern, tarot, brazier) | Parent emitters to the Neon Flame | −5 |
| 3 `VortexHost` | Parent emitters to the Vortex disc | −3 |
| WeepingWell invisible `Centre` | Stone becomes PrimaryPart | −1 |
| 8 `RuneMark` neon slabs | SurfaceGui / Decal on the runestone | −8 |
| 3 lock icons × 2 parts | SurfaceGui lock glyph on the sign (still 3 locks) | −6 |
| Apothecary 5 canopy balls | Keep 3 | −2 |
| **Bank** | | **est. −43** |
| Plus the 1 existing spare | | **est. 44 headroom** |

Use only what the spends need. Do not pre-emptively strip signs or shuttered stalls. Optional extras if a spend overruns: parent 8 Wisp hosts onto wall/lamp parts (est. −8); merge more Wall segments (est. −8, keep all 8 openings — measure, do not guess). **Do not touch Roads 16** (walkability).

---

## Budget ledger (running, estimates)

Start (QA): **363 parts, 24 lights, 0 Highlights** (0 Highlights is derived: none in TownBuilder). Caps 364 / 24 / 31.

| Step | Parts | Lights | Highlights | Notes |
|---|---|---|---|---|
| After bank | 363 − 43 = **320** | 24 | 0 | Headroom before spends |
| A Sky | 320 | 24 | 0 | |
| B Cobbles | 320 | 24 | 0 | |
| C Well | 320 − 7 = **313** | 24 | 0 | Uses bank runes / centre; column is a Beam |
| D Clock | 313 + 2 = **315** | 24 | 0 | |
| E Apothecary | 315 − 1 = **314** | 24 | 0 | Canopy already in bank |
| F Tavern | 314 + 4 = **318** | 24 | 0 | |
| G Tarot | 318 + 2 = **320** | 24 | 0 | |
| H Pedlar | 320 + 12 = **332** | 24 | 0 | Worst-case cages |
| I Portals | 332 + 2 = **334** | 24 | 0 | Hosts already in bank |
| J Life | 334 | 24 | 0 | |
| K VFX (not in Town) | **334** | **24** | 0 town; ≤8 pooled aura | Under 31 |
| **End (estimate)** | **334 / 364** (~30 spare) | **24 / 24** | **0 / 31** town | If Pedlar is +9, end is ~331 |

If any spend overruns, take optional Wisp or Wall merges before cutting a silhouette. **Never add a light** unless one ring lamp is switched off (open question C). Flames, eyes, runes and portals glow with Neon, Beams and particles.

---

## Suggested PR split (after #14 merges)

1. **#17a Atmosphere** — items A and B only. Sky + cobble material/colour. 0 / 0 town delta. Proof: plaza Q1 and Q8 shots, lighting tests, `stylua` / `selene` / `lune` tests, rojo build. Smallest PR, unblocks the look.
2. **#17b Silhouettes** — bank consolidations + items C–I in **one** PR so the branch never exceeds 364/24 mid-way. Update the census test. Proof: one shot per building and each portal vs the concept, plus the cap test printout.
3. **#17c Life + VFX modules** — items J and K. Particle / emitter cap tests, QualityLevel fallback, no Town cap change. Proof: catch clips (Common + Epic), pad collect pop, plaza life shot.

Each PR stays inside the caps on its own. No town or ledger work until #14 is merged.

---

## Open questions for Grok Bot

A. Confirm Town geometry (within the cap) is in #17, and that issue #17 should be updated (owner Architect; drop or qualify “No Town geometry”).  
B. Purple Sky: may we use only built-in `rbxasset` skyboxes, or will Eudai upload a custom six-face sky? No Creator Store either way.  
C. Stay at 0 new lights (recommended), or may one of the 14 ring lamps go dark to light the well column or clock face?  
D. Pedlar “veiled figure” as a hooded statue (not an avatar, not a prompt-on-NPC) — allowed under “no fake players”?  
E. Catch sparkle / rare aura in #17c (as the issue asks) or wait for a hunt VFX PR?  
F. May we slim the 67–74-part Rare/Epic chalk-circle templates, or must #17 use them as authored?  
G. First pass: Sky only, or a small lighting tune if the zenith stays black?  
H. Highlights: keep 0 in Town and only pool a rare-cryptid aura, or also outline crows / eyes?

**Already decided (do not re-open):** no gems; town is Hollowmere; no pumpkins; no map expansion; 364/24; no fake players; UI palette stays spec 01 A2; Server Luck and Robux prices still wait on Eudai (not this pass).

## Grok Bot rulings (11 Nov, 06:29), now decided
Split 17a sky + cobbles / 17b building shapes / 17c life + VFX approved; start after #14 merges.
- A: Town geometry within 364/24 is in scope; issue #17 now says "Town geometry within the cap; no map expansion".
- B: built-in rbxasset skyboxes only (a custom sky needs Eudai; not this pass).
- C: 0 new lights; Neon/Beams/particles; never take a light from a ring lamp.
- D: hooded Pedlar statue OK: static, no name tag, no avatar, no chat or player-like behaviour.
- E: catch sparkle + rare aura in 17c, within emitter/particle caps, with QualityLevel fallback.
- F: slim the Rare/Epic chalk-circle templates, keeping the silhouette readable vs the concept.
- G: sky first; a small lighting tune only if the zenith still reads black in QA shots, starting from main's values.
- H: 0 standing Highlights in town; pool only the rare-cryptid aura; no outlines on crows or eyes.
Handover note: a World Builder bot may take over #17 visual work; keep this file current.
OWNER: Cryptid World Builder (a73259d6) from 11 Nov 06:30. Handed over by the Architect.

## 17b-3 Runeheart Apothecary (kit stack)

The blockout cylinder is replaced by `src/server/TownKits/ApothecaryTree.luau`, registered after the longship and the well. `TownBuilder` is not edited. The model name stays `RuneheartApothecary`. The sign, the two green flames, the crow, and the invisible `Root` pivot stay. A `DoorAnchor` (`TownAnchor = Door`) receives any proximity prompt.

Later rulings on this stack replace the 364/24 budget and the 6-emitter town cap with runaway guards: 20000 parts, 200 lights, 200 emitters. Per-effect particle weight stays 120. Quality 1–4 drops ornament, the extra lights, and the three life emitters (spores, fireflies, door steam). Those emitters are also `TownFlame = extra`, so the client quality pass disables them. No spec 16 screen changes. Rule 8 is kept by not adding a figure.
