# Spec 18: Tools, capture twists, and aptitudes

**Status:** Draft v1 (11 Nov 2026). Design note only. This file does not change `src/`.
**Owner:** Growth Strategist tunes every number marked **PROPOSAL**. Art Director picks the Veil Lamp beam. Systems Architect builds the PRs below.
**Reads with:** [spec 17](17-pedlar-supplies.md) (shop, prices, policy, save version). Spec 15 §5 and §10, spec 14 §1, spec 16 §7 and §8, spec 01 B8, spec 09 §3. Picture: [art/concepts/v3-tools.jpg](../art/concepts/v3-tools.jpg).

## Goal

Tools are the backbone of the Pedlar's supplies ([spec 17](17-pedlar-supplies.md)). Each launch species has a capture twist so the tool matters, and a hold with the free lantern still works. Aptitudes are visible and small. They never move Tithe.

**Ruling:** L1–L5 and the UV lamp are deterministic (range, reveal, hold time, tether). They never change catch odds, rarity weights, spawn odds, or variant odds. No paid success boost. The server validates the catch.

## Price and gate

Prices are **N × H** from [spec 17](17-pedlar-supplies.md). **H = $787.50**, one 45 s spec-09 interval of the $17.50/s post-rite lair (`Species` bases 2+3+5+4, `BoneAltar.multiplier(1)` = 1.25). **PROPOSAL.**

Cash rows unlock at `Shop.GATE_STEP` (8) and `Monetisation.GATE_PLAY_SECONDS` (300). No row requires owning the previous tool. L1 is free at `Onboarding.CATCH_STEP` (3). You can catch every species below with L1 alone.

## Tools

Beam colours match spec 15 §5 and the concept sheet. Stack is 1. Duration is permanent. No charges. No expiry.

| Tool | Id | Beam | Price | Exact effect | Unlock | In code today |
|---|---|---|---|---|---|---|
| Rusty Lantern (L1) | `rusty_lantern` | Orange | $0 | Hold `Economy.CATCH_SECONDS` (3). Range `Economy.CATCH_DISTANCE_STUDS` (12). | Tutorial catch. Already granted by `PlayerSession` as a `Tool` named `"Lantern"`. | **Yes. Launch.** Not a cash sale. |
| Ember Lantern (L2) | `ember_lantern` | Green | $1,575 (N = 2) | Hold **3.0 s → 2.7 s** (−10%). Same delta as skill `h1` (`catchTime` 0.10, tooltip "3.0 s -> 2.7 s", cost $1,000). Range stays 12. | Shop gate. | The multiplier exists only on skills (`SkillEffects.catchSeconds`, floor `SkillConfig.CATCH_TIME_MIN` 2.25). No tool id. **Deferred, Update 1. Not sold.** |
| Spirit Compass (L3) | `spirit_compass` | Blue | $3,150 (N = 4) | Arrow and wisp to the nearest **already spawned** wild cryptid. Does not spawn, despawn, or reroll it. | Shop gate. | No nearest-spawn query. `h3` Keen Eye (outline, 40 studs) is sealed. **Deferred, Update 1. Not sold.** |
| Veil Lamp (UV) | `veil_lamp` | Unset. See below. | $4,725 (N = 6) | Information only. Shows server-placed tracks. Shows the variant rolled when that spawn was created. Does not roll, reroll, or change weights. | Shop gate. Variant half also waits on variants (spec 15 §9, Update 1). | No tracks. No variant field is rolled. `CryptidRecord.mutation` is an empty string. **Deferred, Update 1. Not sold.** |
| Binding Chains (L4) | `binding_chains` | Purple | $6,300 (N = 8) | Range **12 → 16** studs. While a hold is in progress, a tether keeps that cryptid from leaving the tool's range until the hold ends or fails. Spec 15's "harder to steal" is **not** in this effect (open question 2). | Shop gate. | `h2` Long Reach is +2 studs (12 → 14) on a skill. `StealGuard` is a gate, not a tool. **Deferred, Update 1. Not sold.** |
| Moonlit Censer (L5) | `moonlit_censer` | Silver | $12,600 (N = 16) | Smoke pulls the next landing or low point forward: the wait until the next bindable phase is halved, and that phase is still at least 4 s. If two cryptids are already inside range and already in a bindable phase, the player may hold both. The server checks each hold. | Shop gate. | Not in code. `settings.bindAtOnce` auto-places a shop cryptid on an empty pad. **Deferred, Update 1. Not sold.** |

**L2 and h1.** Proposal: they do not stack. The hold multiplier is the better of the two 0.10 sources, then other `catchTime` skills (`h4` is 0.15). Floor stays 2.25 s. Open question 1.

**Veil Lamp colour.** Placeholder token `UvBeam`, unset. It must not use L1 orange, L2 green, L3 blue, L4 purple, or L5 silver. The Art Director chooses it. No new Neon until that choice, and none on the Pedlar's stall lantern (director ruling 9).

**Where the lamp sits.** It is an information tool beside L3, not a power rung and not a replacement for L3. Order on the counter: L1, L2, L3, Veil Lamp, L4, L5. Buying it never raises catch chance (director ruling 14: no catch-chance boosts).

**Details, every tool.** Before and after hold, before and after range, then the line "Catch odds unchanged. Rarity weights unchanged. Variant odds unchanged." Button label **Details** (spec 01 B8, spec 16 §8.5).

**Pull-forward.** Only L1 is in code as a tool, so only L1 is at launch. L2–L5 and the Veil Lamp stay Update 1, which is also spec 15 §9. The effect numbers above are the spec those PRs implement. They are not sold early under a tooltip with no server check.

## Capture twists

On top of hold-to-bind. One twist per launch species (spec 09 §3). Ids are the ones in `Species.luau`. `rare_01` and `rare_02` are both the Beast of Bray Road; one twist covers both. Placeholder Legendary and Mythic ids are not in this table and are not given a twist.

**Rules**

- The server owns the phase, the distance, and the clock. The client sends begin-hold and complete-hold. A complete is accepted only if the phase is bindable, the distance is within the equipped tool's range, the elapsed time meets the tool's hold, and the profile owns that tool.
- **L1 path:** every species has a recurring phase of at least **4 s** inside **12 studs**, so the 3 s hold fits with a second of slack. Tools shorten the wait or widen the phase. They do not delete this phase.
- A late press that starts with less than 3 s left fails. The next phase still comes. No cash penalty and no cash offer on the failure (spec 16 §7.2 and §8.9).
- The tutorial Hodag (`Onboarding.CATCH_STEP`, `Species.WILD_ID`) uses the plain 3 s hold. No charge. Spec 01's timing stays.
- Today the only wild spawn in code is that tutorial Hodag. The other eleven species are not spawned in the wild. The table is the design for when they are. **The twist system is deferred to Update 1** with the tools. Launch catch behaviour stays the current hold.

| Species | Id | Rarity | Twist | Counter-tool | Without that tool |
|---|---|---|---|---|---|
| Mothman Hatchling | `mothman_hatchling` | Common | Drawn to lantern light. With any lit lantern equipped it closes from `Economy.WILD_SPAWN_STUDS` (20) to 12. | L1 (any later lantern still counts) | Unequipped, it does not approach. Walk into 12 and hold 3 s. The phase does not expire. |
| Fresno Nightcrawler | `fresno_nightcrawler` | Common | Freezes when your look is within 30° of it (server look, not a client flag). Frozen inside 12, it can be held. Outside 12 it stays frozen until you look away, then walks. | L3, so you can close in while looking away | Look away, walk in, look back to freeze, hold 3 s. Extra walk, same hold. |
| Hidebehind | `hidebehind` | Common | The hold is accepted only when your look is more than 60° off it. | Veil Lamp shows the track between trees. The hold rule does not change. | The prompt still exists inside 12 studs when you are looking away. You search without a track. Hold is 3 s. |
| Hodag | `hodag` | Common | Charges (hold rejected), then stops. | L2 makes the hold 2.7 s, so a later start still fits the stop. | Stop lasts **4 s** inside 12. Start within the first 1 s. Miss it and the next stop comes. Tutorial spawn: no charge. |
| Jackalope | `uncommon_01` | Uncommon | Bolts for 2 s (hold rejected), then pauses. | L3 keeps the heading during the bolt so you are in range when the pause starts. | Pause lasts **4 s** inside 12 once you are there. You chase without the arrow. |
| Dover Demon | `uncommon_02` | Uncommon | Perches at **15 studs** (outside 12, inside 16), then drops. | L4 binds on the perch. | Drop puts it inside 12 for **5 s**. Hold 3 s then. |
| Snallygaster | `snallygaster` | Uncommon | Swoops. The low point is the bindable phase. | L5 lengthens the low point from 4 s to 6 s. | Low point lasts **4 s** inside 12. Next swoop if you miss. |
| Loveland Frogman | `loveland_frogman` | Uncommon | Dives (hold rejected), then surfaces. | L4, if the hold has started, keeps it on the surface until the hold ends. | Surface lasts **4 s** inside 12. |
| Flatwoods Monster | `flatwoods_monster` | Rare | The hiss pushes you out to **14 studs** (outside 12, inside 16), then the push drops. | L4 binds during the push. | The gap lasts **4 s** inside 12. |
| Beast of Bray Road | `rare_01`, `rare_02` | Rare | Sprint rejects the hold. The stalk that follows is bindable, and it comes to you. | L3 shows the stalk path so you are already in the grove. | Stalk lasts **5 s** inside 12 when it reaches you. |
| Jersey Devil | `epic_01` | Epic | Flies a loop (hold rejected) and lands. | L5 halves the wait until the next landing. The landing is still at least 4 s. | Landing lasts **4 s** inside 12. |
| Loch Ness Serpent | `epic_02` | Epic | On the surface it drifts out to **14 studs**. A calm at the end brings it inside 12. | L4's tether holds it inside 16 for the whole surface, so the hold can start immediately. | Calm lasts **5 s** inside 12, after the drift. Spec 15's 30 s rise is the whole surface, not the calm. |

Code incomes, unchanged by this note: Commons 2 / 3 / 4 / 5; `uncommon_01` and `uncommon_02` and `loveland_frogman` are 15 (spec 09 writes Jackalope $12/s and Dover Demon $14/s; the file on this branch says 15); `snallygaster` uses `Return.SNALLYGASTER_INCOME` (16); `flatwoods_monster` uses `Return.FLATWOODS_INCOME` (40); `rare_01` / `rare_02` are 45; `epic_01` / `epic_02` are 160. Spec 09's $150/s and $170/s Epics are not what `Species.luau` stores. Do not "fix" that in a tools PR.

## Aptitudes

Spec 14 §1 recommended Courage, Instinct, and Attunement at 0–10, and said they should not change pad income. **This ruling changes the income sentence:** placed income may move, and the total from these stats is capped at **+10%**. Spec 14's other limits stay: no catch-contest bonus, no egg-odds bonus, no Tithe and no leaderboard points. Spec 14's expedition cap stays **5%** duration. Traits stay utility, not a second cash multiplier.

**PROPOSAL formulas**

- `courageBonus = courage / 10 * 0.10`. Courage 0 is +0%. Courage 10 is +10%. Instinct and Attunement add no income, so the cap cannot be exceeded by summing stats.
- Placed income, in `Income.perSecond` only: the current product (`baseIncome × altar × skill/wild factor`) **× (1 + courageBonus)**, then `Money.round`.
- `Income.tithePerSecond` does **not** multiply by `(1 + courageBonus)`. Cash-bundle quotes stay on the pre-2x rate and also ignore this factor.
- Instinct: expedition duration × (1 − 0.05 × instinct / 10). Instinct 10 is −5%. No effect on catch time.
- Attunement does not add a second reduction. It picks the route family (woods, marsh, quarry) that receives the Instinct reduction. Other routes get half of that reduction, still inside the 5% cap. Attunement 0 means the Instinct reduction applies equally on every route.
- Expeditions are not in code (January, spec 15 §9). Instinct and Attunement are stored and shown. Their duration effect waits for the expedition system. The card says so, in plain words, until then. Courage's income effect is live when the field ships.

**One trait** per cryptid, independent of species rarity. Rates sum to 100%. No income, no catch chance, no Tithe, no rarity.

| Trait id | Tier | Rate | Effect |
|---|---|---|---|
| `marshwise` | Familiar | 60% | Marks a landmark you have already visited. Reveals nothing new. |
| `keen_listener` | Unusual | 25% | Subtitles a cue the server has already decided you can hear. |
| `pathfinder` | Rare | 10% | Lists expedition routes you have already finished. No undiscovered route. |
| `runesight` | Occult | 4% | Shows one fixed lore line on the Stat Card. |
| `living_omen` | Singular | 1% | An idle and a pad sigil. Cosmetic. |

**Roll, on a free-source obtain** (wild, starter, rift belt, offering, earned reading, expedition). Each aptitude is an integer from 0 through 10, uniform, independent. Each value has weight 1. Details shows **1/11**, not a rounded percent that fails to sum. The trait roll is a separate 0–99 draw against the table above. Show that table in the same Details view (spec 01 B8, spec 16 §8.2). The roll is earned, not sold. We still show it.

**Paid grants** (Relics bundles, including the Starter Pack's Hidebehind) use fixed disclosed values, written on the card before purchase (spec 16 §8.4): Courage **5**, Instinct **5**, Attunement **5**, trait **Marshwise**. No reroll, no trait luck, no cash item that re-rolls a stat. The Pedlar no longer sells cryptids, so it does not sell these rolls.

**Backfill.** Seeded from the instance id so a second migration cannot reroll. FNV-1a 32-bit, offset basis 2166136261, prime 16777619, over the bytes of the salt and then the instance id:

- `courage = hash("courage", id) % 11`
- `instinct = hash("instinct", id) % 11`
- `attunement = hash("attunement", id) % 11`
- `traitRoll = hash("trait", id) % 100`, then 0–59 `marshwise`, 60–84 `keen_listener`, 85–94 `pathfinder`, 95–98 `runesight`, 99 `living_omen`

Fill a number only when it is absent. If `traits` is empty, write the one id. If `traits` is already non-empty, leave it. Do not change `speciesId`, `source`, `mutation`, `acquiredAt`, or cash. Running the migration twice is a no-op the second time.

## Data

Same bump as [spec 17](17-pedlar-supplies.md). This branch is `Save.DATA_VERSION` **9**. #15 takes **10**. These fields take **11**, chained after `migrateToV10`, or **12** if the supplies PR has already taken 11. Do not merge ahead of #15.

`CryptidRecord` gains `courage`, `instinct`, `attunement` (integers 0–10). The existing `traits` array holds the one trait id. `profile.tools` holds owned and equipped tool ids. A pre-existing Pedlar cryptid stays that cryptid.

## UI

Spec 16 rule numbers: §7.2, §7.9, §8.1, §8.2, §8.5, §8.9. Targets are `UITheme.shape.touchPx` (44).

**Stat Card (§8.2).** After the true-tier reveal. Portrait in a `ViewportFrame` of the scripted model. Name, real rarity chip (`UiFactory.rarityChip` and `UITheme.rarity`), base income and placed income as numbers, source. Three bars labelled Courage, Instinct, Attunement with the text `7/10`. Trait name and its one-line effect. If Instinct's duration effect is not live, the Instinct line reads **"Expeditions are not open yet."** Primary button **Bind / Place**. **Details** (the word) opens the 1/11 rows and the trait table. Phone: portrait, name, chip, income, and Bind first; Details holds the bars. No Robux, no View Item, no offer card. Spec 14's Compare / Keep / Bond / mastery are not on this card.

**Tool HUD.** Equipped tool name, beam colour, current hold seconds, current range studs. 44 px. No timer that is not a real phase. During the 3 s hold, the beam and the rune follow §8.1 and stop at the true tier.

**Twist cues.** One line for the server's phase, in Bone, for example "It has stopped." or "It is under the water." The line matches the phase. It does not say "almost" unless that phase is real (§7.2). Reduced motion: the line stays, and the beam tween shortens. No shop button on the cue (§8.9).

## Implementation plan

After the spec 17 PRs that stop cryptid sales and land version 11. Still not ahead of #14's town work, and not ahead of #15 for the save.

1. **Tool config.** A frozen module of the six rows: id, price, hold multiplier, range, flags. L2–L5 and the lamp stay `forSale = false` until their effect PR. Test: every `forSale` row has a non-empty effect, and none of them write an odds field.
2. **L2–L5 and the lamp (Update 1).** Server applies hold, range, tether, compass target, and variant display from the equipped id. Compass and lamp are read-only. Test: restricted distance rejects the hold; L1 still passes the 12-stud, 3 s case; odds tables are byte-identical with the tool equipped and unequipped.
3. **Phases (Update 1).** One pure function from species id + server clock → phase. Test, per row above: a bindable phase of at least 4 s exists inside 12 studs for `rusty_lantern`, and the named reject phase returns false. Tutorial Hodag never enters the charge phase.
4. **Aptitudes.** Multiply Courage into `Income.perSecond` only. Test: Courage 10 is +10% and not more; Courage 0 matches today's income; `tithePerSecond` ignores Courage; the FNV fill is stable for a fixed id; a second migrate does not change it; a `source = "pedlar"` record keeps its species id.

## QA

1. L1 catch of the tutorial Hodag still matches spec 01 (3 s, 12 studs, no charge).
2. With tools forced on in Studio, each species in the table can be caught with only L1 by waiting for the slow phase, and the counter-tool shortens that wait. A client that claims a shorter hold than the server is rejected.
3. Equipping L4 does not change a rarity roll (compare two forced spawns, same seed, tool on and off).
4. Stat Card shows the three numbers, the trait, and Details at 1/11. Tithe on the plaque does not move when Courage changes and the altar and pads do not.
5. A save from before the migration loads the same Pedlar species, with aptitudes filled, cash unchanged.
6. Phone width: Bind and Details are at least 44 px. No shop card on the catch.
7. Veil Lamp, if previewed, uses a colour the Art Director has signed, and it is not one of the five tool beams.

## Open questions for the director

1. L2 and skill `h1` are the same −10%. This note takes the better of the two and does not add them. Confirm, or say they stack under the 2.25 s floor.
2. Spec 15 says the chains are "harder to steal." This note leaves that out, so cash does not buy a PvP edge. Confirm.
3. Veil Lamp beam colour is unset on purpose. Art Director to choose a colour that is not orange, green, blue, purple, or silver.
4. The lamp's copy says Shiny / Corrupted, which is spec 09 and spec 14. Spec 15 §6 names Spectral, Gilded, Shadow, and Moonlit. Which set does the lamp display? Either way it only displays a roll that already happened, and variants stay earn-only (ruling 13).
5. Backfill gives old cryptids a real Courage, so their placed income can rise by up to 10%. The first supplies ruling said a Pedlar cryptid already in a save is unaffected. Confirm the income may move, or say pre-migration cryptids are stored at Courage 0 so the rate does not jump.
6. Spec 14 said these three stats do not change pad income. This ruling puts the whole +10% on Courage and leaves Instinct and Attunement off income. Confirm that split.
7. Twist timings (the 4 s and 5 s windows) are proposals. They wait on a wild spawner for all 12 species, which is not in code.
