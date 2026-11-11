# Visual references

Each area below lists the concept images, the art-direction section, the architectural traits the specs ask for, the gameplay function, what main actually builds, and the QA line recorded for this index.

Main is `86202dd943f90b1e76a6b5c1950a2736abca0ccb`. "Not built" means there is no matching geometry or UI on that SHA. Pull request #14 is open and is not main.

## QA acceptance criteria recorded for this index

Use these when a scene is reviewed, until a human picks a look:

- Town-scale budgets: **24 lights or fewer**, **364 parts or fewer**, **fewer than 31 Highlights**.
- Palette: Void `#0B0A0C`, Blood `#7A0F12`, Gold `#9C7A3C`, bone white `#E8E0CF` (decision D7), rare sickly green Rift `#7FA34A`.
- No bright purple. Nothing cartoony.

Other caps exist and are not the same number. Plot lights stay at 8 (D39). Transient VFX stay at or under 6 emitters and 120 particles (D14). Cryptid handoffs use their own part caps. Spec 14 mentions a 4,000-part town ceiling for the clock proposal. Pull request #14 is the source of the 364-part town cap. Which cap a new mesh must meet is unresolved. See [`PROJECT_INDEX.md`](../PROJECT_INDEX.md).

Style guide v0.8, specs 01 and 03, and the line above forbid bright purple. Spec 15, [`art/ART-DIRECTION-V2.md`](../art/ART-DIRECTION-V2.md), and issue #17 ask for a purple night and coloured flames (green, purple, blue, crimson, orange) and allow Neon on flames, portals, runes, signs, and eyes. Several concept sheets are bright and cartoony on purpose. Both are recorded. Neither is dropped here.

The four `art/vfx/concepts/ATMOS_concept_*.png` sheets are labelled on the image: concept only, not in-game, not Studio proof, never store art.

## Town hub

- **Images:** [`art/concepts/town-hub.jpg`](../art/concepts/town-hub.jpg) (muted dusk, eight roads, well, belfry). [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) (mythic night plaza). [`art/concepts/v2-town-portals.jpg`](../art/concepts/v2-town-portals.jpg) (Witchwood, retired shop language). [`art/concepts/winter-town.jpg`](../art/concepts/winter-town.jpg).
- **Art direction:** Style guide v0.8 one-line direction (fog-drowned market). Spec 03 §1–§3. Art direction v3 update in [`art/ART-DIRECTION-V2.md`](../art/ART-DIRECTION-V2.md). Spec 15 §3.
- **Architectural traits:** Centre is the Weeping Well at the origin. Town radius 120. Eight roads, 16 studs wide, at the plot angles. Cobbled ground near Soot. Spec 03 buildings are dark wood and slate, leaning 2–4°, with Blood banners and gold sign trim. v3 adds a runestone ring and teal mist at the well, and forbids pumpkins, witch hats, and cauldron-shaped buildings.
- **Gameplay function:** Shared hub for eight players. Spend, show off, and see what is new. Roads lead to the lairs. Spawn after a cleared plot is the road mouth, not the well (spec 03).
- **On main:** Built as the spec 03 stall town. `src/server/TownBuilder.luau`, `src/shared/Config/Town.luau`, `src/shared/Logic/TownLayout.luau`, `src/client/TownDress.luau`, `src/server/LightingSetup.luau`, `src/server/Wisp.luau`. Not the v3 mythic shell.
- **QA:** The budgets and palette at the top of this file. Spec 03 also fixes fog: Atmosphere density 0.18, haze 0.3, colour `#282A30` in spec 03 v2.1. Main still uses Atmosphere colour Ash `#1A1719`.

## Hollowmere Apothecary

No approved document uses this exact name. The pictures that could be this shop:

- **Images:** [`art/concepts/stalls-morrow-nell.jpg`](../art/concepts/stalls-morrow-nell.jpg) signs the stall **Morrow Apothecary**. [`art/concepts/v3-shops.jpg`](../art/concepts/v3-shops.jpg) signs a hollow tree **APOTHECARY**. [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) signs **Runeheart Apothecary**. [`art/concepts/v2-shops.jpg`](../art/concepts/v2-shops.jpg) is a cauldron potion shop and is retired.
- **Art direction:** Art direction v3: apothecary in a hollow rune-carved tree, green. Spec 15 §3 says the same. Spec 14 §6 calls a potion-maker stall an undecided recommendation. Spec 03 has no apothecary district. The Lanternwright is the shuttered tool stall.
- **Architectural traits:** v3 tree must read from across the plaza. Rune carving, green glass, no witch hat, no cauldron building. Spec 03 stalls, if this stays a district stall, are wood, about 14 by 10 by 7 studs (`Town.STALL_*` on main).
- **Gameplay function:** Unspecified. Spec 03 does not give this building a shop. Tools L2–L5 belong to the Lanternwright and must be deterministic (spec 03, spec 15 §5).
- **On main:** Not built. `Town.luau` has no apothecary id.
- **QA:** The budgets and palette at the top of this file. The v3 sheets use bright green and a purple sky, which fails the "no bright purple" line.

## Pale Pedlar

- **Images:** [`art/concepts/pale-pedlar.jpg`](../art/concepts/pale-pedlar.jpg). Also the veiled figure implied by spec 15 §3. The Greyhaven sign on the image is not the town's name.
- **Art direction:** Spec 03 §4. Style guide v0.8 D41: the "new stock" lantern is RiftDim plus a PointLight and particles, not Neon. Spec 15: veiled figure, caged cryptids, green lantern.
- **Architectural traits:** Four cages, one offer each. Crooked stall between road P1 and road P2 (district angle 22.5°). Veiled figure. Lantern cage in RiftDim `#4F6B34`.
- **Gameplay function:** Live. Global UTC stock every 300 seconds, same on every server. Cash only. Each player buys each slot once per rotation. Opens after onboarding step 8. Odds button reads "Details". Buying never rerolls stock.
- **On main:** Built. `src/server/Pedlar.luau`, `src/client/PedlarShop.luau`, `src/server/ShopRoll.luau`, `src/server/ShopSalt.luau`, `src/shared/Config/Shop.luau`, `src/shared/Logic/ShopStock.luau`. Tests: `tests/town.spec.luau`.
- **QA:** The budgets and palette at the top of this file. Rift green at or under 2% of the view (D35). The concept's green lantern is the allowed rare accent if it stays small.

## Food shop / tavern

- **Images:** [`art/concepts/stalls-morrow-nell.jpg`](../art/concepts/stalls-morrow-nell.jpg) (Nell Night Cook). [`art/concepts/v3-shops.jpg`](../art/concepts/v3-shops.jpg) and [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) (The Howling Horn, overturned longship, blue fire). [`art/concepts/v2-shops.jpg`](../art/concepts/v2-shops.jpg) (pumpkin, retired).
- **Art direction:** Art direction v3 retires the jack-o'-lantern shop. Spec 15 §3: overturned longship hull, serpent figurehead, blue fire. Spec 14's food-shop character is an undecided recommendation. Spec 03 has no tavern district.
- **Architectural traits:** v3 hull must read from across the plaza. Serpent figurehead. Blue fire is in spec 15 and is outside the muted palette.
- **Gameplay function:** Unspecified on a live stall. Spec 03 does not assign a purchase to a tavern.
- **On main:** Not built.
- **QA:** The budgets and palette at the top of this file. Blue fire fails "no bright purple" only if it reads purple; saturated blue is also forbidden by style guide v0.8 and required by spec 15. Unresolved.

## Tarot shop and the case UI

- **Images:** [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) (Veil & Fate tent, eye sigil, purple cloth). [`art/concepts/case-reveal.jpg`](../art/concepts/case-reveal.jpg) (Veil & Vesper, single card). [`art/concepts/v2-case-spin.jpg`](../art/concepts/v2-case-spin.jpg) (spinning reel, gem price). [`art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png`](../art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png).
- **Art direction:** Art direction v2 case reel, then the v3 tent. Spec 10. Style guide D24, D25, D27, D34, D37. Spec 15 §8.
- **Architectural traits:** Spec 03 reserves a 24 by 24 footprint, `Reserved_TarotTable`, roped off, at 112.5°. v3 asks for a tent with an eye sigil. The reel uses a golden needle. Frames: style guide D24 is bone, moss, silver, blood, gold, with no purple. Art direction v2 and spec 15 §8 say grey, green, blue, purple, and gold.
- **Gameplay function:** January. Earn-only readings. Never sold for Robux. Paid side is Bound Rites with exact contents shown first. Real odds shown before the pull. No visual may imply a higher tier than the server rolled.
- **On main:** Not built. The district is `status = "reserved"` in `src/shared/Config/Town.luau`. Profile fields exist and no UI does.
- **QA:** The budgets and palette at the top of this file. `v2-case-spin.jpg` fails them: purple frames, a gem price, and odds printed on the sheet (40/30/15/10/5) that are the picture's numbers, not a quote from spec 10. `case-reveal.jpg` uses a purple rare pip.

## Clock tower

- **Images:** [`art/concepts/town-hub.jpg`](../art/concepts/town-hub.jpg) (clock belfry, bone-white numerals). [`art/concepts/hollow-clock-bloodmoon.jpg`](../art/concepts/hollow-clock-bloodmoon.jpg). [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) (Dusk & Dial). [`art/concepts/winter-town.jpg`](../art/concepts/winter-town.jpg).
- **Art direction:** Spec 14 §6, "Undecided: recommendation — the Hollow Clock". Spec 15 §3 cites "spec 14 §6" and treats a moon-phase face that changes colour at events as part of the town. Art direction v3: clock tower with a moon-phase face. Pull request #14's description says the moon face does not change colour.
- **Architectural traits:** Crooked tower. Bone numerals in the town-hub sheet. Spec 14 suggests a narrow belfry that does not block the eight roads, and no new lights. The blood-moon sheet is a red sky and a red clock face.
- **Gameplay function:** Spec 15 puts event colour changes in Update 1. Spec 12's Blood Moon is Update 1, not launch. No approved spec gives the clock a purchase.
- **On main:** Not built. The spec 03 well has candles. There is no clock model.
- **QA:** The budgets and palette at the top of this file. A red moon is the Blood event tint, which D48 keeps off the Epic catch moment. The blood-moon sheet is a full red sky.

## Other spec 03 districts

Lanternwright, Expedition Board, Bone Broker, Grimoire Lectern, Skill Shrine, and the Ledger of Tithes slab.

- **Images:** The stall ring in [`art/concepts/town-hub.jpg`](../art/concepts/town-hub.jpg). No sheet is labelled with these five names. Skill shrine UI is spec 04, not a separate concept file.
- **Art direction:** Spec 03 §2. Spec 04 for the shrine. Spec 07 §3 for the Tithe slab.
- **Architectural traits:** Shuttered stalls wear a crimson cloth and the sign "Shuttered until the next moon". Reserved footprints are 24 by 24 and named. The shrine opens the rite circle. The Tithe slab sits beside the well, facing road P1, Bone text on Soot, gold rim.
- **Gameplay function:** Lanternwright, Expedition Board, Bone Broker, and Grimoire Lectern do nothing yet. The Skill Shrine opens the ring 1 tree after step 8. The Tithe slab is spec 07 and is not on main (pull request #15).
- **On main:** Stalls and the shrine are built in `src/server/TownBuilder.luau` from `Town.DISTRICTS`. The tree is `src/client/SkillTree.luau`. The Tithe slab is not built.
- **QA:** The budgets and palette at the top of this file. Shrine copy `Town.SHRINE_BODY` still says the tree waits for a later rite.

## Portals and the Rift

- **Images:** [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) and [`art/concepts/v2-town-portals.jpg`](../art/concepts/v2-town-portals.jpg). Whispering Woods (green tree arch), Sunken Marsh (teal serpent, the v3 sheet says Level 25+), Bone Quarry (orange ribcage). No separate Great Rift sheet.
- **Art direction:** Art direction v2, then the v3 arch update (v2 shop shapes retired; the three portals stay). Spec 15 §3. Spec 03 §2 district 6 and style guide D41 for the Great Rift pit. Spec 02 for the personal Rift Fissure.
- **Architectural traits:** Each portal is an arch, a swirling vortex, a floating name, and a lock or level icon. v3 arches: gnarled tree, stone serpent head, beast ribcage. The town pit is a fenced RiftDim edge with one PointLight and particles, not Neon. The lair belt is Basalt with thin RiftDim trim.
- **Gameplay function:** Spec 15 launch line: three portals, one open. Spec 11 and spec 15 do not yet define travel rules in a single section. Spec 03's Great Rift pit is a later shared conveyor. The personal fissure is the player's own conveyor and is not a portal.
- **On main:** Biome portals are not built. The Great Rift is a reserved pit in `TownBuilder` (`Reserved_GreatRift`). The personal fissure is built in `src/server/PlotBuilder.luau` and `src/server/RiftGlow.luau` with RiftDim.
- **QA:** The budgets and palette at the top of this file. Teal, orange, and a purple sky fail the muted palette and match spec 15. Rift green stays at or under 2% (D35). RiftDim does not count toward that cap (D42).

## Lairs and bases

- **Images:** [`art/vfx/concepts/ATMOS_concept_lair-night_2026-11-04.png`](../art/vfx/concepts/ATMOS_concept_lair-night_2026-11-04.png). Store thumbnail A in [`specs/store-art-brief.md`](../specs/store-art-brief.md) describes the same room and is not a file in `art/concepts/`.
- **Art direction:** Spec 02. Style guide v0.8 §2 and §4. D2 (every third candle lit), D39 (8 lights, Hodag lantern only during goal 3), D47 (lair fog low, off on Low).
- **Architectural traits:** Walled plot, crenellated, Basalt and Slate, near Void and Soot. Lair Gate on the town side, Wild Gate on the back. Pads in a ring. Bone Altar at the centre. Blood banners. Candle pools `#FFB36B`. The concept sheet shows eight gold-rimmed pads and a bone altar.
- **Gameplay function:** One plot per player. Pads earn cash. The altar multiplies income. Other players can see the lair. Raiding is a later spec.
- **On main:** Built. `src/server/PlotBuilder.luau`, `src/server/Plot.luau`, `src/server/LairVisual.luau`, `src/shared/Config/Lair.luau`, `src/shared/Config/Plots.luau`, `assets/lair/Pad.rbxmx`, `assets/lair/BoneAltar.rbxmx`.
- **QA:** Plot light cap 8, which is tighter than the town's 24. Highlights under 31. Palette as above. The concept sheet is not Studio proof.

## Biomes and events

- **Images:** [`art/vfx/concepts/ATMOS_concept_wilds-hunt_2026-11-04.png`](../art/vfx/concepts/ATMOS_concept_wilds-hunt_2026-11-04.png) (tutorial Wilds). [`art/concepts/fog-night.jpg`](../art/concepts/fog-night.jpg). [`art/concepts/winter-town.jpg`](../art/concepts/winter-town.jpg). [`art/concepts/hollow-clock-bloodmoon.jpg`](../art/concepts/hollow-clock-bloodmoon.jpg). Portal arches under Portals above.
- **Art direction:** Spec 12 (Fog Night only at launch). Spec 13 (seasons, cosmetic). Atmosphere pass §2 and [`art/vfx/atmosphere-events.md`](../art/vfx/atmosphere-events.md). Spec 15 §3 for the three biomes. [`art/handoff/HODAG-ONBOARDING.md`](../art/handoff/HODAG-ONBOARDING.md) for the tutorial spawn.
- **Architectural traits:** Wilds are the ring outside the plots (spec 02, r > 330). Tutorial Hodag stands about 20 studs beyond the Wild Gate and needs a warm lantern during goal 3 (D39). Fog Night stays inside density 0.18 and haze 0.3; extra fog is wisps, not a thicker Atmosphere (D9, D45). Winter is snow on roofs and paths, dark-green wreaths, no holiday name in UI text (spec 13). The winter concept uses red-bow wreaths.
- **Gameplay function:** The Wilds are where the tutorial catch happens, and where later contested spawns happen. Fog Night is a free server event. Biome conditions in spec 15 §10 (Woods, Marsh, Quarry, night, Fog Night, Blood Moon) are a proposal on that page. Seasons do not change odds.
- **On main:** The tutorial Wilds exist as the space outside the gate (`src/server/Wisp.luau`, the Hodag goal in onboarding). Fog Night, seasons, and the three biomes are not built.
- **QA:** The budgets and palette at the top of this file. `fog-night.jpg` names a Wendigo and Greyvale, which are not in the roster or the town name. D1 readability floor still applies: Ambient at or above `(60, 55, 52)` per channel.

## UI

- **Images:** [`art/concepts/stat-card.jpg`](../art/concepts/stat-card.jpg). [`art/concepts/case-reveal.jpg`](../art/concepts/case-reveal.jpg). [`art/concepts/v2-case-spin.jpg`](../art/concepts/v2-case-spin.jpg). [`art/concepts/v3-sigil-trace.jpg`](../art/concepts/v3-sigil-trace.jpg). [`art/concepts/v3-tug-of-war.jpg`](../art/concepts/v3-tug-of-war.jpg). [`art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png`](../art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png). The v3 town and v2 portal sheets also paint a full HUD, including a gem counter.
- **Art direction:** Spec 01 Part A. Style guide v0.8 §1 and §5. Spec 04 for the rite circle. Spec 10 for the reel. Spec 14's Stat Card is an undecided recommendation. Spec 15 §4 and §8 treat the Stat Card and the reel as launch or January scope (reel is January in §9).
- **Architectural traits:** Candle-lit ledger. Corner radius 4 px. Fonts: Grenze Gotisch for titles, Garamond for headers, Merriweather for body, Oswald for numbers. Minimum 14 px. Bone or BoneDim text on Void. Parchment tooltips flip to Void text on Bone. Reduced motion drops slides and floats. No screen shake (D15).
- **Gameplay function:** The plaque shows server cash and income. The goal banner drives the rite. The skill tree buys ring 1 nodes. The Pedlar panel buys a known cryptid. The Stat Card, the reel, and Sigil Trace are not on main. Sigil Trace is Update 1. The tug-of-war sheet is a picture of a contested beam; spec 11's rule is "first to finish the 3 second hold", and the sheet's health bar is not specified.
- **On main:** `src/shared/UITheme.luau`, `src/client/UiFactory.luau`, `src/client/CashPlaque.luau`, `src/client/GoalBanner.luau`, `src/client/SkillTree.luau`, `src/client/PedlarShop.luau`, `src/client/HaulPanel.luau`, `src/client/OfferingPanel.luau`, `src/client/RelicsShop.luau`, `src/client/SealToast.luau`. Mythic's rarity token in `UITheme` is Rift, which disagrees with D34. Stat card, reel, and Sigil Trace are not built.
- **QA:** The palette at the top of this file, plus the spec 01 contrast rules. Highlights under 31. The gem counters on the v3 and v2 HUD sheets fail spec 15 §7 (no gem currency). `stat-card.jpg` calls the Jackalope Rare; spec 15's roster table calls it Uncommon.

## VFX

- **Images:** [`art/vfx/concepts/ATMOS_concept_catch-beat-epic_2026-11-04.png`](../art/vfx/concepts/ATMOS_concept_catch-beat-epic_2026-11-04.png). [`art/concepts/v3-tools.jpg`](../art/concepts/v3-tools.jpg) for the five beam colours. [`art/concepts/v3-tug-of-war.jpg`](../art/concepts/v3-tug-of-war.jpg). Templates listed in [`art/vfx/vfx-templates-README.md`](../art/vfx/vfx-templates-README.md) and [`art/handoff/VFX-P0.md`](../art/handoff/VFX-P0.md).
- **Art direction:** [`art/vfx/vfx-audio-plan.md`](../art/vfx/vfx-audio-plan.md) v0.7. [`art/vfx/atmosphere-pass.md`](../art/vfx/atmosphere-pass.md) v0.2. [`art/handoff/ATMOSPHERE-LAUNCH.md`](../art/handoff/ATMOSPHERE-LAUNCH.md) (D49 order: lantern pools, tier smoke, ground fog, catch beat if time allows, Fog Night). Spec 15 §2 and §4.
- **Architectural traits:** P0 templates are Parts and built-in particles, no Neon, no scripts, no uploaded textures. One allowlisted texture, `rbxasset://textures/particles/smoke_main.dds`, set at runtime (D46). Reveal light is one, under 3 seconds, catcher's client only (D17). Coloured flames in spec 15 are green, purple, blue, crimson, and orange. The VFX plan §1.1 says "No purple, no blue."
- **Gameplay function:** The reveal plays after the server has already granted the catch. Tier colour must be the true tier. Nothing bought with Robux gets a server banner, a sky tint, or a near-miss effect (D26, D29, as amended). Tool beams are identity colours for L1–L5 and do not change odds.
- **On main:** Not built as the P0 set. The 17 `art/vfx/templates/*.rbxmx` models are reference files and are not mapped in `default.project.json`. Particles that do exist are coded in `src/server/Wisp.luau`, `src/server/RiftGlow.luau`, `src/server/TownBuilder.luau` (well), and `src/server/Pedlar.luau` (stock glow). Issue #17 is the planned code pass and has no pull request.
- **QA:** The budgets and palette at the top of this file, plus D14 (≤ 6 emitters, ≤ 120 particles per effect) and a Low-quality fallback with bloom off. Highlights under 31, with the project still using a pool of 2 because D8 is unverified. The epic catch sheet is not Studio proof.

## Tools sheet

- **Images:** [`art/concepts/v3-tools.jpg`](../art/concepts/v3-tools.jpg).
- **Art direction:** Spec 15 §5. The Lanternwright row in spec 03.
- **Architectural traits:** L1 Rusty Lantern, orange beam. L2 Ember Lantern, green beam. L3 Spirit Compass, blue arrow. L4 Binding Chains, purple chains, 16 stud range. L5 Moonlit Censer, silver smoke. The sheet matches those five names.
- **Gameplay function:** L1 is the free tutorial lantern. L2–L5 are deterministic tools. They never change rarity, spawn, or variant odds. Spec 15 says they do not change Sigil Trace push strength.
- **On main:** The tutorial tool is a Lantern created in `src/server/PlayerSession.luau` (`Economy.TOOL_NAME`). `src/shared/Config/Lanterns.luau` is the world-lantern and Rift-light budget, not the L2–L5 set. L2–L5 are not built. The Lanternwright stall is shuttered.
- **QA:** The palette at the top of this file. Purple chains and a blue beam are what spec 15 asks for and what the muted QA line forbids.
