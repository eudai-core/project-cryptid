# Spec 18: Tools, capture twists, and aptitudes

**Status:** Draft v1.1 (11 Nov 2026). Design note only. This file does not change `src/`.
**Owner:** Growth Strategist tunes every number marked **PROPOSAL**. Art Director picks the Veil Lamp beam. Systems Architect builds the PRs below.
**Reads with:** [spec 17](17-pedlar-supplies.md) (shop, prices, policy, expeditions, save version). Spec 15 §5 and §10, spec 14 §1 and §3, spec 16 §7 and §8, spec 01 B8, spec 06, spec 09 §3 and §9.4, spec 11 §4.2, spec 12 §0 and §7. Picture: [art/concepts/v3-tools.jpg](../art/concepts/v3-tools.jpg). Research: [2026-11-roblox-retention-monetisation-research.md](research/2026-11-roblox-retention-monetisation-research.md). Where that note marks **[A]**, this spec uses the cited config or spec instead.

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

**Aligned with the research (row 3).** The lamp stays information only, the same class as sealed `h3` Keen Eye (audit row 8). Spawns exist with the lamp off. Spec 15 §10 conditions stay the Bestiary text. The lamp does not create a spawn, change a weight, change hold time (that is L2), or change bind range (that is L4).

The research's cone (30°), duty cycle (6 s on / 12 s off), and four cash radii (20 / 28 / 36 / 44 studs, priced as 15 / 60 / 180 minutes of income) are **[A]**. They are not in config, and this note does not add tiers. One lamp. Its reveal distance is `Economy.WILD_SPAWN_STUDS` (20), the distance the tutorial cryptid already uses. Hidebehind's track, the Fresno freeze, and the Dover perch are the twists in the table below. The lamp shows the tell. The L1 hold still completes without it.

No Robux skin. A research price for a beam colour is **PENDING EUDAI** and is not a config value ([spec 17](17-pedlar-supplies.md)). The stall does not sell it.

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

## Hollow Convergence and the Moon Almanac

Research row 1 asked for a free weekly gathering and a calendar. Its Saturday 17:00 UTC slot, 30-minute length, luck ×2, spawn change (45 s → 30 s), and max-alive change (3 → 4) are **[A]**. They are not added. This note does not add a luck boost.

**When.** The weekly window already written is **Saturday 18:00–20:00 UTC** (spec 09 §9.4, spec 12 §7.1). Hollow Convergence is that window, under this name. It is Update 1, with the calendar. Launch ships Fog Night only (spec 12 §0), and Fog Night is atmosphere only (director ruling 15).

**What it does.** It does not change rarity weights, spawn interval, or max alive. The shared goal during the window, once the rite exists, is the Hollow Rite (spec 11 §4.2, Update 1): server totals Ember 25, Flame 40, Inferno 60, in a 10-minute rite. Rewards are 5, 10, and 15 minutes of each contributor's own pre-2x income. Inferno also grants the Rite Candle once per tier per week. A player needs 3 catches. AFK players get nothing. Assists count one half. Those rewards are the rite's, not a new Convergence multiplier. Spec 12's rule stands: event income stays out of Tithe.

Spec 09 §9.4 still says Rift Tide carries free event luck ×1.5. This note does not use that line. Open question 8 asks Grok Bot which sentence wins. Nobody can buy a start, a restock, or a longer window (spec 12: event starts other than the Blood Moon gift are not sold, and the gift does not start this hour).

**Moon Almanac.** The 7-day board spec 09 §9.4 and spec 12 §7.1 already call for. It shows the schedule in the player's local time (`os.date`). No push notification (spec 12 §7.1).

| Row on the board | Time | What the player reads |
|---|---|---|
| Hollow Convergence | Saturday 18:00–20:00 UTC | The weekly gathering. Next Saturday is listed if this one was missed. |
| Witching Hour | 19:00–20:00 UTC and 01:00–02:00 UTC daily | Update 1. Spec 12 §7.1. |
| Blood Moon Night | First Friday, 19:00–21:00 UTC | Update 1. Spec 09 §9.4. |
| Fog Night | Whenever the director rolls it | Launch. Atmosphere only (ruling 15). Odds stay the spec 12 §3 table, behind **Details**. |

The only clock is the real time until the next published start, in the same spirit as spec 06's "Next offering in …". Copy does not say "last chance", "only", "expires", or "hurry". Missing the hour has no penalty. The next row is already on the board. No cash catch-up. The Pedlar does not sell a seat ([spec 17](17-pedlar-supplies.md)).

## Daily Contracts

Research row 5 asked for three daily marks and no missed-day penalty. Its pool size, its 5-of-7 candle, and its "Contract Seal" are **[A]**. Spec 06 already has the daily gift, and it pauses instead of resetting. Contracts sit beside that ladder. They do not add a streak.

**Gate.** `Return.GATE_STEP` (8) and `Return.BUTTON_PLAY_SECONDS` (3 minutes), the Offering's gate. The panel does not open over a bind, reveal, haul, or rite (spec 16 §8.7). No shop button and no Robux line (spec 06).

**Day.** `floor(os.time() / 86400)`, the Offering's UTC day (spec 06). Three marks, all completable with what the server can already check:

| Mark | Check | Why it is always possible |
|---|---|---|
| Finish one hold | Server accepts a complete-hold | L1 and the tutorial Hodag exist today. Later species use the same hold. |
| Place one cryptid | A pad gains an instance id from inventory | Spec 01 already places from inventory. |
| Come home | The player enters their own lair threshold once | Spec 02 return. If a Fog Night is active, witnessing it satisfies this mark instead (spec 12). It is never required. |

**Pay.** Minutes of pre-2x income, with the floors already in `Return.STEPS`:

| Marks done today | Minutes | Floor | Source |
|---|---|---|---|
| 1 | 5 | $250 | `Return.STEPS` step 1 |
| 2 | 10 | $500 | `Return.STEPS` step 2 |
| 3 | 15 | $1,000 | `Return.STEPS` step 4 |

At the post-rite **$17.50/s** (spec 17), the first mark is 5 × 60 × 17.50 = **$5,250** before the floor, the same worked example as spec 06 day 1. Cash only. No Essence, no token, no reading, no crate.

**Missed day.** Tomorrow's three marks are new. Nothing resets to zero, and nothing is labelled lost. Unclaimed contract cash waits. It is not deleted at midnight. The Offering ladder is a separate counter and does not move. There is no 5-of-7 reward and no candle on this panel. The Rite Candle stays the Inferno grant in spec 11 §4.2. No "Revive Streak" (spec 06, spec 09 §8.2).

Roster incomes for the twist table, unchanged by this note: Commons 2 / 3 / 4 / 5; `uncommon_01` and `uncommon_02` and `loveland_frogman` are 15 (spec 09 writes Jackalope $12/s and Dover Demon $14/s; the file on this branch says 15); `snallygaster` uses `Return.SNALLYGASTER_INCOME` (16); `flatwoods_monster` uses `Return.FLATWOODS_INCOME` (40); `rare_01` / `rare_02` are 45; `epic_01` / `epic_02` are 160. Spec 09's $150/s and $170/s Epics are not what `Species.luau` stores. Do not "fix" that in a tools PR.

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

The research's weighted row (0 through 10 as 3, 5, 8, 11, 14, 16, 15, 12, 8, 6, 2) and its "Prime" mark (total ≥ 24, about 1.77%) are **[A]**. No config defines that table. This note keeps the uniform 1/11 roll. It does not add a Prime mark.

**Paid grants** (Relics bundles, including the Starter Pack's Hidebehind) use fixed disclosed values, written on the Dossier before purchase (spec 16 §8.4): Courage **5**, Instinct **5**, Attunement **5**, trait **Marshwise**. No reroll, no trait luck, no cash item that re-rolls a stat. The Pedlar does not sell these rolls ([spec 17](17-pedlar-supplies.md)). Bound Rite prices stay in spec 09. Ruling 5 leaves them **PENDING EUDAI**. This note does not copy a Robux figure into a field.

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

**Dossier, which is the Stat Card (§8.2).** Research row 4's dossier is this card, not a second screen. It opens after the true-tier reveal. Portrait in a `ViewportFrame` of the scripted model. Name, real rarity chip (`UiFactory.rarityChip` and `UITheme.rarity`), base income and placed income as numbers, source. Three bars labelled Courage, Instinct, Attunement with the text `7/10`. Trait name and its one-line effect. If Instinct's duration effect is not live, the Instinct line reads **"Expeditions are not open yet."** Primary button **Bind / Place**. **Details** (the word) opens the 1/11 rows and the trait table. Phone: portrait, name, chip, income, and Bind first; Details holds the bars. No Robux, no View Item, no offer card, no reroll button. Spec 14's Compare / Keep / Bond / mastery are not on this card. Hodag at Courage 10, before the altar, is $5/s × 1.10 = **$5.50/s**. Tithe uses $5/s.

**Tool HUD.** Equipped tool name, beam colour, current hold seconds, current range studs. 44 px. No timer that is not a real phase. During the 3 s hold, the beam and the rune follow §8.1 and stop at the true tier.

**Twist cues.** One line for the server's phase, in Bone, for example "It has stopped." or "It is under the water." The line matches the phase. It does not say "almost" unless that phase is real (§7.2). Reduced motion: the line stays, and the beam tween shortens. No shop button on the cue (§8.9).

## Implementation plan

After the spec 17 PRs that stop cryptid sales and land version 11. Still not ahead of #14's town work, and not ahead of #15 for the save.

1. **Tool config.** A frozen module of the six rows: id, price, hold multiplier, range, flags. L2–L5 and the lamp stay `forSale = false` until their effect PR. Test: every `forSale` row has a non-empty effect, and none of them write an odds field.
2. **L2–L5 and the lamp (Update 1).** Server applies hold, range, tether, compass target, and variant display from the equipped id. Compass and lamp are read-only. Test: restricted distance rejects the hold; L1 still passes the 12-stud, 3 s case; odds tables are byte-identical with the tool equipped and unequipped.
3. **Phases (Update 1).** One pure function from species id + server clock → phase. Test, per row above: a bindable phase of at least 4 s exists inside 12 studs for `rusty_lantern`, and the named reject phase returns false. Tutorial Hodag never enters the charge phase.
4. **Aptitudes and the Dossier.** Multiply Courage into `Income.perSecond` only. Test: Courage 10 is +10% and not more; Courage 0 matches today's income; `tithePerSecond` ignores Courage; the FNV fill is stable for a fixed id; a second migrate does not change it; a `source = "pedlar"` record keeps its species id. A paid grant writes 5 / 5 / 5 and `marshwise` and has no reroll remote.
5. **Almanac and Contracts (Update 1 for Convergence; Contracts can follow the Offering).** The board lists Saturday 18:00–20:00 UTC and does not change a rarity table while the hour is active. A missed UTC day leaves contract cash unclaimed and does not move `daily.step`. No new `Analytics.CUSTOM` name is added in these PRs.

## QA

1. L1 catch of the tutorial Hodag still matches spec 01 (3 s, 12 studs, no charge).
2. With tools forced on in Studio, each species in the table can be caught with only L1 by waiting for the slow phase, and the counter-tool shortens that wait. A client that claims a shorter hold than the server is rejected.
3. Equipping L4 does not change a rarity roll (compare two forced spawns, same seed, tool on and off).
4. The Dossier shows the three numbers, the trait, and Details at 1/11. Tithe on the plaque does not move when Courage changes and the altar and pads do not. There is no reroll control.
5. A save from before the migration loads the same Pedlar species, with aptitudes filled, cash unchanged.
6. Phone width: Bind and Details are at least 44 px. No shop card on the catch.
7. Veil Lamp, if previewed, uses a colour the Art Director has signed, and it is not one of the five tool beams. With the lamp off, the same spawn is still there, and the rarity roll matches a run with the lamp on.
8. The Almanac shows the next Saturday 18:00–20:00 UTC in local time. Copy has no "last chance". Skipping the hour does not charge cash and does not change Sunday's board.
9. Three contract marks can be finished with a hold, a place, and a return home. Skipping a UTC day leaves the Offering step where it was. Unclaimed contract cash is still there the next day.

## Open questions for Eudai and Grok Bot

1. L2 and skill `h1` are the same −10%. This note takes the better of the two and does not add them. Confirm, or say they stack under the 2.25 s floor.
2. Spec 15 says the chains are "harder to steal." This note leaves that out, so cash does not buy a PvP edge. Confirm.
3. Veil Lamp beam colour is unset on purpose. Art Director to choose a colour that is not orange, green, blue, purple, or silver.
4. The lamp's copy says Shiny / Corrupted, which is spec 09 and spec 14. Spec 15 §6 names Spectral, Gilded, Shadow, and Moonlit. Which set does the lamp display? Either way it only displays a roll that already happened, and variants stay earn-only (ruling 13).
5. Backfill gives old cryptids a real Courage, so their placed income can rise by up to 10%. The first supplies ruling said a Pedlar cryptid already in a save is unaffected. Confirm the income may move, or say pre-migration cryptids are stored at Courage 0 so the rate does not jump.
6. Spec 14 said these three stats do not change pad income. This ruling puts the whole +10% on Courage and leaves Instinct and Attunement off income. Confirm that split.
7. Twist timings (the 4 s and 5 s windows) are proposals. They wait on a wild spawner for all 12 species, which is not in code.
8. Hollow Convergence uses Saturday 18:00–20:00 UTC and adds no luck. Spec 09 §9.4 still gives Rift Tide free event luck ×1.5. Which sentence stands?
9. Aptitude rolls stay uniform, 1/11 each. The research's weighted table and Prime mark are not used. Confirm.
10. Daily Contracts pay the Offering's 5, 10, and 15 minute steps and do not add a 5-of-7 candle. Confirm.
11. The v1.1 analytics list is frozen: `OnboardingSkipped`, `OnboardingStepTime`, `SessionEnded`, `PlayerReturned`, `LedgerLoadFailed`, `PedlarOddsViewed`, `CatchCompleted`, `PlotAssigned` (`Analytics.CUSTOM_ORDER`, cap 15). This note adds none. May any of these be added later: a Convergence witness, an Almanac open, a contract claim, an expedition send, a Dossier open?
