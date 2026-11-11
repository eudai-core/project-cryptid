# Visual references

Each area below lists the concept images, the art-direction section, the architectural traits the specs ask for, the gameplay function, what main actually builds, and the QA line recorded for this index.

Main is `c576b0813643eefff1b22511fb20890fec456421` (pull request #18 merged). "Not built" means there is no matching geometry or UI on that SHA. Pull request #14 is open and is not main. The 11 Nov director rulings are in [`PROJECT_INDEX.md`](../PROJECT_INDEX.md).

## QA acceptance criteria recorded for this index

Use these when a scene is reviewed. The 11 Nov director rulings closed the look conflict:

- Town-scale budgets (ruling 17): **24 lights or fewer**, **364 parts or fewer**, no map expansion. Spec 14's 4,000-part ceiling does not raise this cap.
- Highlights (ruling 7): **fewer than 31**, until 255 is verified in Studio. The pool of 2 stays (D8).
- World look (ruling 1): spec 15. A purple night, coloured flames (green, purple, blue, crimson, orange), and Neon on flames, portals, runes, signs, and eyes, inside the budgets above. UI still uses the spec 01 A2 tokens: Void `#0B0A0C`, Blood `#7A0F12`, Gold `#9C7A3C`, bone white `#E8E0CF` (decision D7), rare sickly green Rift `#7FA34A`. The old "no bright purple / nothing cartoony" line is superseded for the world and still applies to UI.
- Lighting (ruling 8): keep main's values until visual pass #17 tunes them. OutdoorAmbient `(95, 88, 82)`, Atmosphere colour Ash `#1A1719`, ClockTime 1. Owner of that pass is the Cryptid World Builder (ruling 19).
- Tutorial catch (ruling 18): the Hodag (D33).
- Rebirth launch ladder (ruling 10): tiers 1–7. Pull request #15 must enforce 7.

Other caps are different objects, not a second town cap. Plot lights stay at 8 (D39). Transient VFX stay at or under 6 emitters and 120 particles (D14). Cryptid handoffs use their own part caps. The fissure belt, the Great Rift pit, and the Pedlar lantern stay RiftDim, not Neon (ruling 9).

Style guide v0.2, style guide v0.8, and the world-look rules in specs 01 and 03 are superseded where they conflict with the world look above. Spec 15 is the world look. Issue #17 starts after #14 merges (17a sky + cobbles, 17b building shapes, 17c life + VFX). Town geometry within the cap (364 parts / 24 lights, under 31 Highlights); no map expansion. Built-in rbxasset skyboxes only. 0 new lights. 0 standing town Highlights (only a pooled rare-cryptid aura). The pass names the spec 16 rule numbers it applies.

The four `art/vfx/concepts/ATMOS_concept_*.png` sheets are labelled on the image: concept only, not in-game, not Studio proof, never store art.

## Town hub

- **Images:** [`art/concepts/town-hub.jpg`](../art/concepts/town-hub.jpg) (muted dusk, eight roads, well, belfry). [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) (mythic night plaza). [`art/concepts/v2-town-portals.jpg`](../art/concepts/v2-town-portals.jpg) (Witchwood, retired shop language). [`art/concepts/winter-town.jpg`](../art/concepts/winter-town.jpg).
- **Art direction:** Style guide v0.8 one-line direction (fog-drowned market). Spec 03 §1–§3. Art direction v3 update in [`art/ART-DIRECTION-V2.md`](../art/ART-DIRECTION-V2.md). Spec 15 §3.
- **Architectural traits:** Centre is the Weeping Well at the origin. Town radius 120. Eight roads, 16 studs wide, at the plot angles. Cobbled ground near Soot. Spec 03 buildings are dark wood and slate, leaning 2–4°, with Blood banners and gold sign trim. v3 adds a runestone ring and teal mist at the well, and forbids pumpkins, witch hats, and cauldron-shaped buildings.
- **Gameplay function:** Shared hub for eight players. Spend, show off, and see what is new. Roads lead to the lairs. Spawn after a cleared plot is the road mouth, not the well (spec 03).
- **On main:** Built as the spec 03 stall town. `src/server/TownBuilder.luau`, `src/shared/Config/Town.luau`, `src/shared/Logic/TownLayout.luau`, `src/client/TownDress.luau`, `src/server/LightingSetup.luau`, `src/server/Wisp.luau`. Not the v3 mythic shell.
- **QA:** The budgets at the top of this file. World look is spec 15 (purple night, coloured flames). Director ruling 8 keeps main's night grade: Atmosphere density 0.18, haze 0.3, colour Ash `#1A1719`, OutdoorAmbient `(95, 88, 82)`, ClockTime 1. Spec 03 v2.1's `#282A30` and D43/D44 do not override that until visual pass #17 tunes it.

## Runeheart Apothecary

Director ruling 3: the apothecary is Runeheart Apothecary. "Hollowmere Apothecary" is not a name. Morrow and a bare "APOTHECARY" sign are placeholders. The pictures that could be this shop:

- **Images:** [`art/concepts/stalls-morrow-nell.jpg`](../art/concepts/stalls-morrow-nell.jpg) signs the stall **Morrow Apothecary**. [`art/concepts/v3-shops.jpg`](../art/concepts/v3-shops.jpg) signs a hollow tree **APOTHECARY**. [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) signs **Runeheart Apothecary**. [`art/concepts/v2-shops.jpg`](../art/concepts/v2-shops.jpg) is a cauldron potion shop and is retired.
- **Art direction:** Art direction v3: apothecary in a hollow rune-carved tree, green. Spec 15 §3 says the same. Spec 14 §6 calls a potion-maker stall an undecided recommendation. Spec 03 has no apothecary district. The Lanternwright is the shuttered tool stall.
- **Architectural traits:** v3 tree must read from across the plaza. Rune carving, green glass, no witch hat, no cauldron building. Spec 03 stalls, if this stays a district stall, are wood, about 14 by 10 by 7 studs (`Town.STALL_*` on main).
- **Gameplay function:** Unspecified. Spec 03 does not give this building a shop. Tools L2–L5 belong to the Lanternwright and must be deterministic (spec 03, spec 15 §5).
- **On main:** Not built. `Town.luau` has no apothecary id.
- **QA:** The budgets at the top of this file. Bright green flames and a purple sky match spec 15 (director ruling 1). They are not a fail against the superseded "no bright purple" world line.

## Pale Pedlar

- **Images:** [`art/concepts/pale-pedlar.jpg`](../art/concepts/pale-pedlar.jpg). Also the veiled figure implied by spec 15 §3. The Greyhaven sign on the image is a placeholder. The town's name is Hollowmere (director ruling 3).
- **Art direction:** Spec 03 §4. Style guide v0.8 D41: the "new stock" lantern is RiftDim plus a PointLight and particles, not Neon. Spec 15: veiled figure, caged cryptids, green lantern.
- **Architectural traits:** Four cages, one offer each. Crooked stall between road P1 and road P2 (district angle 22.5°). Veiled figure. Lantern cage in RiftDim `#4F6B34`.
- **Gameplay function:** Live. Global UTC stock every 300 seconds, same on every server. Cash only. Each player buys each slot once per rotation. Opens after onboarding step 8. Odds button reads "Details". Buying never rerolls stock. Director ruling 20: the restock stays earn-only, with the odds shown.
- **On main:** Built. `src/server/Pedlar.luau`, `src/client/PedlarShop.luau`, `src/server/ShopRoll.luau`, `src/server/ShopSalt.luau`, `src/shared/Config/Shop.luau`, `src/shared/Logic/ShopStock.luau`. Tests: `tests/town.spec.luau`.
- **QA:** The budgets and palette at the top of this file. Rift green at or under 2% of the view (D35). The concept's green lantern is the allowed rare accent if it stays small.

## Food shop / tavern

- **Images:** [`art/concepts/stalls-morrow-nell.jpg`](../art/concepts/stalls-morrow-nell.jpg) (Nell Night Cook). [`art/concepts/v3-shops.jpg`](../art/concepts/v3-shops.jpg) and [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) (The Howling Horn, overturned longship, blue fire). [`art/concepts/v2-shops.jpg`](../art/concepts/v2-shops.jpg) (pumpkin, retired).
- **Art direction:** Art direction v3 retires the jack-o'-lantern shop. Spec 15 §3: overturned longship hull, serpent figurehead, blue fire. Spec 14's food-shop character is an undecided recommendation. Spec 03 has no tavern district.
- **Architectural traits:** v3 hull must read from across the plaza. Serpent figurehead. The Howling Horn is the canonical name (director ruling 2). Nell Night Cook is a placeholder. Blue fire is the spec 15 coloured flame. No pumpkins (ruling 16).
- **Gameplay function:** Unspecified on a live stall. Spec 03 does not assign a purchase to a tavern.
- **On main:** Not built.
- **QA:** The budgets at the top of this file. Blue fire is a spec 15 coloured flame (director ruling 1). The style-guide ban on saturated blue in the world is superseded for that flame. The pumpkin shop on `v2-shops.jpg` stays retired (ruling 16).

## Tarot shop and the case UI

- **Images:** [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) (Veil & Fate tent, eye sigil, purple cloth). [`art/concepts/case-reveal.jpg`](../art/concepts/case-reveal.jpg) (Veil & Vesper, single card). [`art/concepts/v2-case-spin.jpg`](../art/concepts/v2-case-spin.jpg) (spinning reel, gem price). [`art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png`](../art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png).
- **Art direction:** Art direction v2 case reel, then the v3 tent. Spec 10. Style guide D24, D25, D27, D34, D37. Spec 15 §8.
- **Architectural traits:** Spec 03 reserves a 24 by 24 footprint, `Reserved_TarotTable`, roped off, at 112.5°. The canonical stall name is Veil & Fate (director ruling 2). Veil & Vesper is a placeholder. v3 asks for a tent with an eye sigil. The reel uses a golden needle. Mythic is D34 (ruling 6): GoldBright, a Bone flare, and a thin Rift core, not the Rift token and not a purple frame. Purple cloth on the tent is world look (ruling 1).
- **Gameplay function:** January. Earn-only readings. Never sold for Robux. Paid side is Bound Rites with exact contents shown first. Real odds shown before the pull. No visual may imply a higher tier than the server rolled.
- **On main:** Not built. The district is `status = "reserved"` in `src/shared/Config/Town.luau`. Profile fields exist and no UI does.
- **QA:** The budgets at the top of this file. The gem price on `v2-case-spin.jpg` is superseded (director ruling 4): there is no gem currency. Odds printed on that sheet (40/30/15/10/5) are the picture's numbers, not a quote from spec 10. Mythic follows D34, not a purple frame (ruling 6). A purple rare pip on `case-reveal.jpg` is the picture, not the Jackalope's rarity (ruling 13: Uncommon).

## Clock tower

- **Images:** [`art/concepts/town-hub.jpg`](../art/concepts/town-hub.jpg) (clock belfry, bone-white numerals). [`art/concepts/hollow-clock-bloodmoon.jpg`](../art/concepts/hollow-clock-bloodmoon.jpg). [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) (Dusk & Dial). [`art/concepts/winter-town.jpg`](../art/concepts/winter-town.jpg).
- **Art direction:** The canonical name is Dusk & Dial (director ruling 2). Spec 15 is approved and covers the Stat Card; the moon-face colour change is Update 1 (ruling 21). Pull request #14 does not change the moon face colour. Spec 14 §6 stays a recommendation for everything spec 15 did not adopt.
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
- **QA:** The budgets at the top of this file. `Town.SHRINE_BODY` on main still says "The carving is blank. The skill tree waits for a later rite." Ring 1 is merged. Director ruling 12 records that string as a code follow-up after #14. This file does not change `src/`. The billboard shows it only before onboarding step 8, beside "The shrine is silent to the unmarked."

## Portals and the Rift

- **Images:** [`art/concepts/v3-town.jpg`](../art/concepts/v3-town.jpg) and [`art/concepts/v2-town-portals.jpg`](../art/concepts/v2-town-portals.jpg). Whispering Woods (green tree arch), Sunken Marsh (teal serpent, the v3 sheet says Level 25+), Bone Quarry (orange ribcage). No separate Great Rift sheet.
- **Art direction:** Art direction v2, then the v3 arch update (v2 shop shapes retired; the three portals stay). Spec 15 §3. Spec 03 §2 district 6 and style guide D41 for the Great Rift pit. Spec 02 for the personal Rift Fissure.
- **Architectural traits:** Each portal is an arch, a swirling vortex, a floating name, and a lock or level icon. v3 arches: gnarled tree, stone serpent head, beast ribcage. The town pit is a fenced RiftDim edge with one PointLight and particles, not Neon. The lair belt is Basalt with thin RiftDim trim.
- **Gameplay function:** Spec 15 launch line: three portals, one open. Spec 11 and spec 15 do not yet define travel rules in a single section. Spec 03's Great Rift pit is a later shared conveyor. The personal fissure is the player's own conveyor and is not a portal.
- **On main:** Biome portals are not built. The Great Rift is a reserved pit in `TownBuilder` (`Reserved_GreatRift`). The personal fissure is built in `src/server/PlotBuilder.luau` and `src/server/RiftGlow.luau` with RiftDim.
- **QA:** The budgets at the top of this file. Teal, orange, and a purple sky match spec 15 (director ruling 1). Rift green stays at or under 2% (D35). RiftDim does not count toward that cap (D42). The pit and the fissure stay non-Neon (ruling 9). Named bystanders on the portal sheet are mood only (ruling 22).

## Lairs and bases

- **Images:** [`art/vfx/concepts/ATMOS_concept_lair-night_2026-11-04.png`](../art/vfx/concepts/ATMOS_concept_lair-night_2026-11-04.png). Store thumbnail A in [`specs/store-art-brief.md`](../specs/store-art-brief.md) describes the same room and is not a file in `art/concepts/`.
- **Art direction:** Spec 02. Style guide v0.8 §2 and §4. D2 (every third candle lit), D39 (8 lights, Hodag lantern only during goal 3), D47 (lair fog low, off on Low).
- **Architectural traits:** Walled plot, crenellated, Basalt and Slate, near Void and Soot. Lair Gate on the town side, Wild Gate on the back. Pads in a ring. Bone Altar at the centre. Blood banners. Candle pools `#FFB36B`. The concept sheet shows eight gold-rimmed pads and a bone altar.
- **Gameplay function:** One plot per player. Pads earn cash. The altar multiplies income. Other players can see the lair. Raiding is a later spec.
- **On main:** Built. `src/server/PlotBuilder.luau`, `src/server/Plot.luau`, `src/server/LairVisual.luau`, `src/shared/Config/Lair.luau`, `src/shared/Config/Plots.luau`, `assets/lair/Pad.rbxmx`, `assets/lair/BoneAltar.rbxmx`.
- **QA:** Plot light cap 8, which is tighter than the town's 24. Highlights under 31 until 255 is verified in Studio (director ruling 7). UI palette as above. The concept sheet is not Studio proof.

## Biomes and events

- **Images:** [`art/vfx/concepts/ATMOS_concept_wilds-hunt_2026-11-04.png`](../art/vfx/concepts/ATMOS_concept_wilds-hunt_2026-11-04.png) (tutorial Wilds). [`art/concepts/fog-night.jpg`](../art/concepts/fog-night.jpg). [`art/concepts/winter-town.jpg`](../art/concepts/winter-town.jpg). [`art/concepts/hollow-clock-bloodmoon.jpg`](../art/concepts/hollow-clock-bloodmoon.jpg). Portal arches under Portals above.
- **Art direction:** Spec 12 (Fog Night only at launch). Spec 13 (seasons, cosmetic). Atmosphere pass §2 and [`art/vfx/atmosphere-events.md`](../art/vfx/atmosphere-events.md). Spec 15 §3 for the three biomes. [`art/handoff/HODAG-ONBOARDING.md`](../art/handoff/HODAG-ONBOARDING.md) for the tutorial spawn.
- **Architectural traits:** Wilds are the ring outside the plots (spec 02, r > 330). The tutorial catch is the Hodag, about 20 studs beyond the Wild Gate, with a warm lantern during goal 3 (D39, director ruling 18). Fog Night stays inside density 0.18 and haze 0.3; extra fog is wisps, not a thicker Atmosphere (D9, D45). It is atmosphere only: no Wendigo and no survival frame (ruling 15). Winter is snow on roofs and paths and the spec 13 dark-green holly-like wreaths, with no holiday name in UI text (ruling 16). The red bows on `winter-town.jpg` are superseded. No pumpkins.
- **Gameplay function:** The Wilds are where the tutorial catch happens, and where later contested spawns happen. Fog Night is a free server event. Biome conditions in spec 15 §10 (Woods, Marsh, Quarry, night, Fog Night, Blood Moon) are a proposal on that page. Seasons do not change odds.
- **On main:** The tutorial Wilds exist as the space outside the gate (`src/server/Wisp.luau`, the Hodag goal in onboarding). Fog Night, seasons, and the three biomes are not built.
- **QA:** The budgets at the top of this file. `fog-night.jpg` names a Wendigo and Greyvale. The Wendigo is out of scope (director ruling 15). Greyvale is a placeholder; the town is Hollowmere (ruling 3). D1 readability floor still applies: Ambient at or above `(60, 55, 52)` per channel. Main's night grade stays until #17 tunes it (ruling 8).

## UI

- **Images:** [`art/concepts/stat-card.jpg`](../art/concepts/stat-card.jpg). [`art/concepts/case-reveal.jpg`](../art/concepts/case-reveal.jpg). [`art/concepts/v2-case-spin.jpg`](../art/concepts/v2-case-spin.jpg). [`art/concepts/v3-sigil-trace.jpg`](../art/concepts/v3-sigil-trace.jpg). [`art/concepts/v3-tug-of-war.jpg`](../art/concepts/v3-tug-of-war.jpg). [`art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png`](../art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png). The v3 town and v2 portal sheets also paint a full HUD, including a gem counter.
- **Art direction:** Spec 01 Part A (A2 tokens still apply to UI). Style guide v0.8 §1 and §5, except world-look lines superseded by spec 15. Spec 04 for the rite circle. Spec 10 for the reel. Spec 15 is approved and covers the Stat Card (director ruling 21). Spec 16 §8 is the UI rule list a pull request must name. The reel is January (spec 15 §9).
- **Architectural traits:** Candle-lit ledger. Corner radius 4 px. Fonts: Grenze Gotisch for titles, Garamond for headers, Merriweather for body, Oswald for numbers. Minimum 14 px. Bone or BoneDim text on Void. Parchment tooltips flip to Void text on Bone. Reduced motion drops slides and floats. No screen shake (D15).
- **Gameplay function:** The plaque shows server cash and income. The goal banner drives the rite. The skill tree buys ring 1 nodes. The Pedlar panel buys a known cryptid. The Stat Card, the reel, and Sigil Trace are not on main. Sigil Trace is Update 1. The tug-of-war sheet is a picture of a contested beam; spec 11's rule is "first to finish the 3 second hold", and the sheet's health bar is not specified.
- **On main:** `src/shared/UITheme.luau`, `src/client/UiFactory.luau`, `src/client/CashPlaque.luau`, `src/client/GoalBanner.luau`, `src/client/SkillTree.luau`, `src/client/PedlarShop.luau`, `src/client/HaulPanel.luau`, `src/client/OfferingPanel.luau`, `src/client/RelicsShop.luau`, `src/client/SealToast.luau`. Mythic's rarity token in `UITheme` is still Rift. Director ruling 6 says D34 wins; changing the token is a later code change. Stat card, reel, and Sigil Trace are not built. Launch rebirth is tiers 1–7 (ruling 10); `BoneAltar.MAX_REBIRTHS` is 40 until pull request #15.
- **QA:** Spec 01 A2 contrast rules for UI. Highlights under 31 until 255 is verified (director ruling 7). Gem counters on the v3 and v2 HUD sheets are superseded (ruling 4). The Jackalope is Uncommon (ruling 13); the Rare label on `stat-card.jpg` and the Legendary / tradeable labels on `v3-variants.jpg` are not the rule. There is no trading. Sigil Trace has no tap buffs and no catch boosts (ruling 14).

## VFX

- **Images:** [`art/vfx/concepts/ATMOS_concept_catch-beat-epic_2026-11-04.png`](../art/vfx/concepts/ATMOS_concept_catch-beat-epic_2026-11-04.png). [`art/concepts/v3-tools.jpg`](../art/concepts/v3-tools.jpg) for the five beam colours. [`art/concepts/v3-tug-of-war.jpg`](../art/concepts/v3-tug-of-war.jpg). Templates listed in [`art/vfx/vfx-templates-README.md`](../art/vfx/vfx-templates-README.md) and [`art/handoff/VFX-P0.md`](../art/handoff/VFX-P0.md).
- **Art direction:** [`art/vfx/vfx-audio-plan.md`](../art/vfx/vfx-audio-plan.md) v0.7. [`art/vfx/atmosphere-pass.md`](../art/vfx/atmosphere-pass.md) v0.2. [`art/handoff/ATMOSPHERE-LAUNCH.md`](../art/handoff/ATMOSPHERE-LAUNCH.md) (D49 order: lantern pools, tier smoke, ground fog, catch beat if time allows, Fog Night). Spec 15 §2 and §4.
- **Architectural traits:** P0 templates are Parts and built-in particles, no scripts, no uploaded textures. One allowlisted texture, `rbxasset://textures/particles/smoke_main.dds`, set at runtime (D46). Reveal light is one, under 3 seconds, catcher's client only (D17). Coloured flames in spec 15 are green, purple, blue, crimson, and orange, and Neon is allowed on flames, portals, runes, signs, and eyes (director ruling 1). The VFX plan §1.1 line "No purple, no blue" is superseded for those flames. The fissure, pit, and Pedlar lantern stay non-Neon (ruling 9).
- **Gameplay function:** The reveal plays after the server has already granted the catch. Tier colour must be the true tier. Nothing bought with Robux gets a server banner, a sky tint, or a near-miss effect (D26, D29, as amended). Tool beams are identity colours for L1–L5 and do not change odds.
- **On main:** Not built as the P0 set. The 17 `art/vfx/templates/*.rbxmx` models are reference files and are not mapped in `default.project.json`. Particles that do exist are coded in `src/server/Wisp.luau`, `src/server/RiftGlow.luau`, `src/server/TownBuilder.luau` (well), and `src/server/Pedlar.luau` (stock glow). Issue #17 is the planned pass, owned by the Cryptid World Builder (director ruling 19), and has no pull request. It starts after #14 merges: 17a sky + cobbles, 17b building shapes, 17c life + VFX. Town geometry stays inside the cap. Built-in rbxasset skyboxes only. 0 new lights. 0 standing town Highlights (only a pooled rare-cryptid aura).
- **QA:** The budgets at the top of this file, plus D14 (≤ 6 emitters, ≤ 120 particles per effect) and a Low-quality fallback with bloom off. Highlights stay under 31, and the pool stays at 2, until 255 is verified in Studio (director ruling 7). The epic catch sheet is not Studio proof.

## Tools sheet

- **Images:** [`art/concepts/v3-tools.jpg`](../art/concepts/v3-tools.jpg).
- **Art direction:** Spec 15 §5. The Lanternwright row in spec 03.
- **Architectural traits:** L1 Rusty Lantern, orange beam. L2 Ember Lantern, green beam. L3 Spirit Compass, blue arrow. L4 Binding Chains, purple chains, 16 stud range. L5 Silver Censer, silver smoke. The concept sheet's "Moonlit Censer" label is this tool. Moonlit is a variant name. The sheet matches those five names.
- **Gameplay function:** L1 is the free tutorial lantern. L2–L5 are deterministic tools. They never change rarity, spawn, or variant odds. Spec 15 says they do not change Sigil Trace push strength.
- **On main:** The tutorial tool is a Lantern created in `src/server/PlayerSession.luau` (`Economy.TOOL_NAME`). `src/shared/Config/Lanterns.luau` is the world-lantern and Rift-light budget, not the L2–L5 set. L2–L5 are not built. The Lanternwright stall is shuttered.
- **QA:** The budgets at the top of this file. Purple chains and a blue beam are the spec 15 tool colours (director ruling 1). They are not forbidden by the superseded world palette. Tools still do not change rarity, spawn, variant odds, or Sigil Trace push strength (ruling 14).
