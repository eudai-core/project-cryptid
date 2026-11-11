# Spec 18: Tools, capture twists, and aptitudes

**Status:** Draft v1.2 (11 Nov 2026). Design note only. This file does not change `src/`. Rulings from this afternoon are in [Rulings applied](#rulings-applied-11-nov).
**Owner:** Growth Strategist tunes every number marked **PROPOSAL**. The UV Lamp beam is `#CC3F8A` (Art Director, 11 Nov). Systems Architect builds the PRs below, including analytics v1.2.
**Reads with:** [spec 17](17-pedlar-supplies.md) (shop, prices, policy, expeditions, save version). Spec 15 §5 and §10, spec 14 §1 and §3, spec 16 §7 and §8, spec 01 B8, spec 06, spec 09 §3 and §9.4, spec 11 §4.2, spec 12 §0 and §7. Picture: [art/concepts/v3-tools.jpg](../art/concepts/v3-tools.jpg). Research: [2026-11-roblox-retention-monetisation-research.md](research/2026-11-roblox-retention-monetisation-research.md). Where that note marks **[A]**, this spec uses the cited config or spec instead.

## Goal

L2 through L5 and the UV Lamp are the Lanternwright's stock ([spec 17](17-pedlar-supplies.md)). L1 stays free. The Pedlar does not sell these tools. Each launch species has a capture twist so the tool matters, and a hold with the free lantern still works. Aptitudes are visible and small. They never move Tithe.

**Ruling:** L1–L5 and the UV lamp are deterministic (range, reveal, hold time, tether). They never change catch odds, rarity weights, spawn odds, or variant odds. No paid success boost. The server validates the catch.

## Price and gate

Prices are **N × H** from [spec 17](17-pedlar-supplies.md). **H = $787.50**, one 45 s spec-09 interval of the $17.50/s post-rite lair (`Species` bases 2+3+5+4, `BoneAltar.multiplier(1)` = 1.25). **PROPOSAL.**

Cash rows unlock at `Shop.GATE_STEP` (8) and `Monetisation.GATE_PLAY_SECONDS` (300). No row requires owning the previous tool. L1 is free at `Onboarding.CATCH_STEP` (3). You can catch every species below with L1 alone.

## Tools

Beam colours match spec 15 §5 and the concept sheet. Stack is 1. Duration is permanent. No charges. No expiry.

| Tool | Id | Beam | Price | Exact effect | Unlock | In code today |
|---|---|---|---|---|---|---|
| Rusty Lantern (L1) | `rusty_lantern` | Orange | $0 | Hold `Economy.CATCH_SECONDS` (3). Range `Economy.CATCH_DISTANCE_STUDS` (12). | Tutorial catch. Already granted by `PlayerSession` as a `Tool` named `"Lantern"`. | **Yes. Launch.** Not a cash sale. |
| Ember Lantern (L2) | `ember_lantern` | Green | $1,575 (N = 2) | Hold ×0.9, stacked with skill `h1` by multiplying. Alone: 3.0 s → 2.7 s. With `h1`: 3.0 × 0.9 × 0.9 = 2.43 s. Floor `BIND_TIME_MIN_SECONDS` = 1.5. Range stays 12. | Shop gate. | The −10% exists only as skill `h1`. No second tool. Today's skill floor is `SkillConfig.CATCH_TIME_MIN` (2.25). **Deferred, Update 1. Not sold.** |
| Spirit Compass (L3) | `spirit_compass` | Blue | $3,150 (N = 4) | Arrow and wisp to the nearest **already spawned** wild cryptid. Does not spawn, despawn, or reroll it. | Shop gate. | No nearest-spawn query. `h3` Keen Eye (outline, 40 studs) is sealed. **Deferred, Update 1. Not sold.** |
| UV Lamp | `uv_lamp` | `#CC3F8A` | $4,725 (N = 6) | Information only. Shows server-placed tracks. Shows the variant already rolled, using spec 15 §6 names: Normal, Spectral, Gilded, Shadow, Moonlit. Does not roll or change weights. | Shop gate. Variant half also waits on variants (spec 15 §9, Update 1). | No tracks. No variant field is rolled. `CryptidRecord.mutation` is an empty string. **Deferred, Update 1. Not sold.** |
| Binding Chains (L4) | `binding_chains` | Purple | $6,300 (N = 8) | Range **12 → 16** studs. While a hold is in progress, a tether keeps that cryptid from leaving the tool's range until the hold ends or fails. No steal bonus. | Shop gate. | `h2` Long Reach is +2 studs (12 → 14) on a skill. `StealGuard` is a gate, not a tool. **Deferred, Update 1. Not sold.** |
| Silver Censer (L5) | `silver_censer` | Silver | $12,600 (N = 16) | Smoke pulls the next landing or low point forward: the wait until the next bindable phase is halved, and that phase is still at least 4 s. If two cryptids are already inside range and already in a bindable phase, the player may hold both. The server checks each hold. | Shop gate. | Not in code. `settings.bindAtOnce` auto-places a shop cryptid on an empty pad. **Deferred, Update 1. Not sold.** |

**L2 and h1.** They stack by multiplying. `h1Factor` is 0.9 when Steady Hand is owned, else 1. `l2Factor` is 0.9 when the Ember Lantern is owned, else 1. Other `catchTime` skills stay a separate factor: `h4` Quiet Step is 0.15, so that factor is 0.85 when it is owned. Hold seconds = `max(BIND_TIME_MIN_SECONDS, Economy.CATCH_SECONDS × h1Factor × l2Factor × otherFactor)`. `BIND_TIME_MIN_SECONDS` is **1.5**. The code PR names that constant. It does not leave 1.5 written in the hold function. Today's `SkillConfig.CATCH_TIME_MIN` (2.25) is the skill-only floor until that PR. Worked check with no `h4`: 3 × 0.9 × 0.9 = **2.43 s**, which is above 1.5.

**UV Lamp colour.** The Art Director set the beam to **#CC3F8A**. The build PR adds `UvBeam = "CC3F8A"` to `UITheme.world`, not to the A2 `palette`. The beam is a widening fan: width 0.4 to 3.0 studs, length `Economy.WILD_SPAWN_STUDS` (20), `LightEmission` 0.5, no texture, no Neon. The PointLight is the same hex, brightness 0.8, range 12, shadows off, and it exists only on the holder's client while the lamp is on, so the town stays at 24 lights and a plot stays at 8 (D39). Other players see the beam without that light. A variant reveal uses that variant's own colour, not this rose. The lamp is not L4 purple and not the Moonlit variant.

**Where the lamp sits.** It is an information tool beside L3, not a power rung and not a replacement for L3. Order on the counter: L1, L2, L3, UV Lamp, L4, L5. Buying it never raises catch chance (director ruling 14: no catch-chance boosts).

**Aligned with the research (row 3).** The lamp stays information only, the same class as sealed `h3` Keen Eye (audit row 8). Spawns exist with the lamp off. Spec 15 §10 conditions stay the Bestiary text. The lamp does not create a spawn, change a weight, change hold time (that is L2), or change bind range (that is L4).

The research's cone (30°), duty cycle (6 s on / 12 s off), and four cash radii (20 / 28 / 36 / 44 studs, priced as 15 / 60 / 180 minutes of income) are **[A]**. They are not in config, and this note does not add tiers. One lamp. Its reveal distance is `Economy.WILD_SPAWN_STUDS` (20), the distance the tutorial cryptid already uses. Hidebehind's track, the Fresno freeze, and the Dover perch are the twists in the table below. The lamp shows the tell. The L1 hold still completes without it.

Beam skins are not sold here. The Pedlar takes cash only. A skin sits on a separate Robux tab. Its price is **PENDING EUDAI** and is not a config value ([spec 17](17-pedlar-supplies.md)). The lamp shows the value already stored in `mutation`: Normal, Spectral, Gilded, Shadow, or Moonlit (spec 15 §6).

**Details, every tool.** Before and after hold, before and after range, then the line "Catch odds unchanged. Rarity weights unchanged. Variant odds unchanged." Button label **Details** (spec 01 B8, spec 16 §8.5).

**Pull-forward.** Only L1 is in code as a tool, so only L1 is at launch. L2–L5 and the UV Lamp stay Update 1, which is also spec 15 §9. The effect numbers above are the spec those PRs implement. They are not sold early under a tooltip with no server check.

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
| Hidebehind | `hidebehind` | Common | The hold is accepted only when your look is more than 60° off it. | UV Lamp shows the track between trees. The hold rule does not change. | The prompt still exists inside 12 studs when you are looking away. You search without a track. Hold is 3 s. |
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

Research row 1 asked for a free weekly gathering and a calendar. Its guessed start, its guessed length, its luck ×2, and its spawn changes are **[A]** and are not used. Hollow Convergence is Saturday 18:00–20:00 UTC and adds no luck of its own.

**Two effects, one window.** Hollow Convergence is Saturday 18:00–20:00 UTC. The constants are `Convergence.WEEKDAY` = Saturday, `Convergence.START_HOUR_UTC` = 18, and `Convergence.END_HOUR_UTC` = 20. It adds no luck of its own: `Convergence.LUCK_MULTIPLIER` is 1. It does not change rarity weights, spawn interval, or max alive. Rift Tide is the separate spec 09 §9.4 luck of ×1.5 on that same Saturday window. Convergence does not add a second multiplier and does not remove the ×1.5. Launch still ships Fog Night only, and Fog Night is atmosphere only (spec 12 §0, director ruling 15). Convergence is Update 1.

**What it does.** It does not change rarity weights, spawn interval, or max alive. The shared goal during the window, once the rite exists, is the Hollow Rite (spec 11 §4.2, Update 1): server totals Ember 25, Flame 40, Inferno 60, in a 10-minute rite. Rewards are 5, 10, and 15 minutes of each contributor's own pre-2x income. Inferno also grants the Rite Candle once per tier per week. A player needs 3 catches. AFK players get nothing. Assists count one half. Those rewards are the rite's, not a new Convergence multiplier. Spec 12's rule stands: event income stays out of Tithe.

Rift Tide keeps that ×1.5. Convergence does not. Nobody can buy a start, a restock, or a longer window (spec 12: event starts other than the Blood Moon gift are not sold, and the gift does not start this hour).

**Moon Almanac.** The 7-day board spec 09 §9.4 and spec 12 §7.1 already call for. It shows the schedule in the player's local time (`os.date`). No push notification (spec 12 §7.1).

| Row on the board | Time | What the player reads |
|---|---|---|
| Rift Tide | Saturday 18:00–20:00 UTC | Spec 09 §9.4. Free luck ×1.5. This row is not Convergence. |
| Hollow Convergence | Saturday 18:00–20:00 UTC (`START_HOUR_UTC` 18, `END_HOUR_UTC` 20) | No luck bonus of its own. Next Saturday is listed if this one was missed. |
| Witching Hour | 19:00–20:00 UTC and 01:00–02:00 UTC daily | Update 1. Spec 12 §7.1. |
| Blood Moon Night | First Friday, 19:00–21:00 UTC | Update 1. Spec 09 §9.4. |
| Fog Night | Whenever the director rolls it | Launch. Atmosphere only (ruling 15). Odds stay the spec 12 §3 table, behind **Details**. |

The only clock is the real time until the next published start, in the same spirit as spec 06's "Next offering in …". Copy does not say "last chance", "only", "expires", or "hurry". Missing the hour has no penalty. The next row is already on the board. No cash catch-up. The Pedlar does not sell a seat ([spec 17](17-pedlar-supplies.md)).

## Daily Contracts

Research row 5 asked for three daily marks and no missed-day penalty. Spec 06 already pauses the Offering instead of resetting it. Contracts sit beside that ladder. A missed day does not wipe them. The weekly bonus below is a fixed reward for any 5 of 7 days, not a streak that breaks.

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

**Missed day.** Tomorrow's three marks are new. Nothing resets to zero, and nothing is labelled lost. Unclaimed contract cash waits. It is not deleted at midnight. The Offering ladder does not move. No "Revive Streak" (spec 06, spec 09 §8.2).

**Weekly bonus.** Any **5** of **7** days in the UTC week (Monday 00:00, the same week spec 09 uses for the Moon Vigil). The days need not be consecutive. Missing a day does not wipe the other days, and a week under 5 pays nothing and shows no loss line. The reward is fixed and listed on the panel before the week starts. It is never a roll.

| Constant | Proposed value | Why this value |
|---|---|---|
| `Contract.WEEKLY_QUALIFYING_DAYS` | 5 | The ruling. |
| `Contract.WEEKLY_SPAN_DAYS` | 7 | The ruling. |
| `Contract.WEEKLY_CASH_MINUTES` | 30 | Approved. Same minute count as Offering step 6 (`Return.STEPS`). Pre-2x income. |
| `Contract.WEEKLY_CASH_FLOOR` | 3000 | Approved. The floor on that same Offering step. |
| `Contract.WEEKLY_COSMETIC` | `vigil_wick` | One fixed cosmetic, disclosed. Not a tarot token and not a random draw. |

The cash is 30 minutes of pre-2x income, and the grant is at least $3,000. Both numbers are the named constants above. The Rite Candle stays the Inferno grant in spec 11 §4.2 and is not this cosmetic.

Roster incomes for the twist table, unchanged by this note: Commons 2 / 3 / 4 / 5; `uncommon_01` and `uncommon_02` and `loveland_frogman` are 15 (spec 09 writes Jackalope $12/s and Dover Demon $14/s; the file on this branch says 15); `snallygaster` uses `Return.SNALLYGASTER_INCOME` (16); `flatwoods_monster` uses `Return.FLATWOODS_INCOME` (40); `rare_01` / `rare_02` are 45; `epic_01` / `epic_02` are 160. Spec 09's $150/s and $170/s Epics are not what `Species.luau` stores. Do not "fix" that in a tools PR.

## Aptitudes

Spec 14 §1 recommended Courage, Instinct, and Attunement at 0–10, and said they should not change pad income. **This ruling changes the income sentence:** placed income may move, and the total from these stats is capped at **+10%**. Spec 14's other limits stay: no catch-contest bonus, no egg-odds bonus, no Tithe and no leaderboard points. Spec 14's expedition cap stays **5%** duration. Traits stay utility, not a second cash multiplier.

**PROPOSAL formulas**

- `courageBonus = courage / 10 * 0.10`. Courage 0 is +0%. Courage 10 is +10%. Instinct and Attunement add no income, so the cap cannot be exceeded by summing stats.
- Placed income, in `Income.perSecond` only: the current product (`baseIncome × altar × skill/wild factor`) **× (1 + courageBonus)**, then `Money.round`.
- `Income.tithePerSecond` does **not** multiply by `(1 + courageBonus)`. Cash-bundle quotes stay on the pre-2x rate and also ignore this factor.
- Instinct drives expedition speed and route fit. Speed is `duration × (1 − Aptitude.EXPEDITION_SPEED_CAP × instinct / 10)` with `EXPEDITION_SPEED_CAP` = 0.05. Instinct 10 is −5% time. Route fit uses the species' spec 15 §10 place: Woods (Fresno Nightcrawler, Hidebehind, Jackalope, Beast of Bray Road), Marsh (Loveland Frogman, Flatwoods Monster, Loch Ness Serpent), Quarry (Dover Demon, Snallygaster, Jersey Devil). On that route the full speed applies. On the other routes it is half, and the half still sits inside the 5% cap. Mothman Hatchling and Hodag are "any" in spec 15, so the full speed applies on every route, still capped at 5%. Instinct does not change catch time or income.
- Attunement drives bind and trait utility. It does not change income or expedition time. Bind utility lengthens the bindable phase by `attunement / 10 × Aptitude.BIND_PHASE_BONUS_AT_10_SECONDS`, and that constant is 1, so Attunement 10 adds 1 s of slack. It does not shorten the hold and it does not move `BIND_TIME_MIN_SECONDS`. Trait utility scales the trait's existing information effect by `attunement / 10`. A trait still reveals nothing the player has not already earned, and it still adds no income.
- Expeditions are not in code (January, spec 15 §9). The 4 s and 5 s twist windows, and the Attunement phase bonus on those windows, wait for the wild-spawner PR. Courage's income effect is live when the field ships. The Dossier still shows Instinct and Attunement before those systems exist.

**One trait** per cryptid, independent of species rarity. Rates sum to 100%. No income, no catch chance, no Tithe, no rarity.

| Trait id | Tier | Rate | Effect |
|---|---|---|---|
| `marshwise` | Familiar | 60% | Marks a landmark you have already visited. Reveals nothing new. |
| `keen_listener` | Unusual | 25% | Subtitles a cue the server has already decided you can hear. |
| `pathfinder` | Uncanny | 10% | Lists expedition routes you have already finished. No undiscovered route. |
| `runesight` | Occult | 4% | Shows one fixed lore line on the Stat Card. |
| `living_omen` | Singular | 1% | An idle and a pad sigil. Cosmetic. |

**Roll, on a free-source obtain** (wild, starter, rift belt, offering, earned reading, expedition). Each aptitude is an integer from 0 through 10, uniform, independent. Each value has weight 1. Details shows **1/11**, not a rounded percent that fails to sum. The trait roll is a separate 0–99 draw against the table above. Show that table in the same Details view (spec 01 B8, spec 16 §8.2). The roll is earned, not sold. We still show it.

The research's weighted row (0 through 10 as 3, 5, 8, 11, 14, 16, 15, 12, 8, 6, 2) is **[A]** and is not used.

**Prime.** A free roll whose three stats are each **≥ 9** gets a Dossier highlight named Prime. It changes no income, no hold, no Tithe, and no contest. On a uniform 0–10 roll the faces ≥ 9 are 9 and 10, so **2 of 11**. All three: **(2/11)³ = 8/1331** (about 0.60%). Details shows **8/1331**. A count of three faces, (3/11)³ = 27/1331 (about 2.03%), would be every stat ≥ 8. The mark is ≥ 9, so the odds QA asserts are 8/1331. A paid grant is 5/5/5, and 5 is below 9, so a paid grant is never Prime.

**Paid grants** (Relics bundles, including the Starter Pack's Hidebehind) use fixed disclosed values, written on the Dossier before purchase (spec 16 §8.4): Courage **5**, Instinct **5**, Attunement **5**, trait **Marshwise**. No reroll, no trait luck, no cash item that re-rolls a stat. The Pedlar does not sell these rolls ([spec 17](17-pedlar-supplies.md)). Bound Rite prices stay in spec 09. Ruling 5 leaves them **PENDING EUDAI**. This note does not copy a Robux figure into a field.

**Backfill.** Seeded from the instance id so a second migration cannot reroll. FNV-1a 32-bit, offset basis 2166136261, prime 16777619, over the bytes of the salt and then the instance id:

- `courage = hash("courage", id) % 11`
- `instinct = hash("instinct", id) % 11`
- `attunement = hash("attunement", id) % 11`
- `traitRoll = hash("trait", id) % 100`, then 0–59 `marshwise`, 60–84 `keen_listener`, 85–94 `pathfinder`, 95–98 `runesight`, 99 `living_omen`

Fill a number only when it is absent, except a cryptid with `source = "pedlar"`. That record is written to Courage 5, Instinct 5, Attunement 5 (`Aptitude.PAID_GRANT`), even when the fields were absent, and it is not hashed. If its `traits` array is empty, write `marshwise`, the same disclosed trait as a paid grant. If `traits` is already non-empty, leave it. Every other cryptid uses the hash above. Do not change `speciesId`, `source`, `mutation`, `acquiredAt`, or cash. Running the migration twice is a no-op the second time. The `dataVersion` bump that carries this step is in the code PR, chained after #15's version 10. This note does not edit `Save.luau`.

## Data

Same bump as [spec 17](17-pedlar-supplies.md). This branch is `Save.DATA_VERSION` **9**. #15 takes **10**. These fields take **11**, chained after `migrateToV10`, or **12** if the supplies PR has already taken 11. Do not merge ahead of #15.

`CryptidRecord` gains `courage`, `instinct`, `attunement` (integers 0–10). The existing `traits` array holds the one trait id. `profile.tools` holds owned and equipped tool ids. A pre-existing Pedlar cryptid stays that cryptid.

## UI

Spec 16 rule numbers: §7.2, §7.9, §8.1, §8.2, §8.5, §8.9. Targets are `UITheme.shape.touchPx` (44).

**Dossier, which is the Stat Card (§8.2).** `art/concepts/stat-card.jpg` is frame mood only. It is not this layout. A new Dossier concept is still to be drawn when this screen is scheduled. The panel is dark `Ash`, not parchment.

The first screen, including on a phone, shows the rarity word, a **NEW** seal on the first of that species, the three aptitudes, and the trait name. The seal is a Blood `#7A0F12` circle with Bone text, at the top right. The chip carries the rarity word, so colour is not the only signal. Aptitude bars share one fill, `GoldBright` on a `Soot` track, at least 8 px tall. Labels are 14 px Bone, values are 14 px Oswald, for example "Courage 7/10 · +7% income". Instinct and Attunement use the same fill. Words tell them apart, not extra hues. If Instinct's expedition effect is not live yet, that line is BoneDim and reads **"Expeditions are not open yet."** The trait line is text only. It does not use a rarity chip. The `mutation` word, when one exists, is Normal, Spectral, Gilded, Shadow, or Moonlit.

**Prime** sits beside the bars: a Bone ◇ and the word Prime, 14 px, outline on Soot. It is not a frame colour, not GoldBright, not a Rift core, and not a Blood fill. It is not a button. Odds on the card are **8/1331** (about 0.60%).

**Mythic** is not the same chip as Legendary. Both use GoldBright, and the build PR gives Mythic a distinct frame: Ash fill, a 2 px GoldBright stroke (Legendary stays 1 px), a ◆ before the word, and a 1 px Rift `#7FA34A` underline. A Bone sweep on reveal lasts 0.5 s and is skipped when Calm motion is on. That change is `UITheme.rarityChip` in the Dossier PR, not in this docs pass.

**Details** says "Each value from 0 to 10 is equally likely (1 in 11)." Then the trait table at 60 / 25 / 10 / 4 / 1, and Prime at 8/1331. A paid grant reads **"Fixed by the Bound Rite: 5 / 5 / 5"** here and on the Relics card before purchase (spec 16 §8.4). Bind / Place and Details are at least 44 px and at least 8 px apart. Text is at least 14 px. Rows that open nothing are not drawn as buttons. No Robux, no View Item, no offer card, no reroll. Compare, Keep, and Bond stay off this card. Hodag at Courage 10, before the altar, is $5/s × 1.10 = **$5.50/s**. Tithe uses $5/s.

**Tool HUD.** The tool name, the beam colour, the hold in seconds, and the range in studs. 44 px. The name is always there, not only a swatch. Beam swatches for L3 blue, L4 purple, and the other concept beams, including UV `#CC3F8A`, are an allowed exception to spec 01 A2. The rest of the UI keeps A2. Swatches live in the `ViewportFrame` or as a dot no wider than 16 px. No timer that is not a real phase. During the hold, the beam and the rune follow §8.1 and stop at the true tier.

**Twist cues.** One line for the server's phase, in Bone, for example "It has stopped." or "It is under the water." The line matches the phase. It does not say "almost" unless that phase is real (§7.2). Reduced motion: the line stays, and the beam tween shortens. No shop button on the cue (§8.9).

## Implementation plan

Small code PRs. Shop, schema, and expedition manifest are [spec 17](17-pedlar-supplies.md). The rest are here. None start ahead of #14. None take `DATA_VERSION` 10.

1. **Tool config.** Six rows, ids, prices, and `BIND_TIME_MIN_SECONDS` = 1.5. L2–L5 and the UV Lamp stay `forSale = false` until the effect PR. No odds field on a supply.
2. **Hold, tether, lamp (Update 1).** Hold is `CATCH_SECONDS × h1Factor × l2Factor × otherFactor`, then the 1.5 s floor. Chains change range and tether only. The UV Lamp reads tracks and the spec 15 variant name. Odds tables match with the lamp on and off.
3. **Wild spawner.** Owns the 4 s and 5 s twist windows, Reed Bait, and `Lure.ENCOUNTER_INTERVAL_SECONDS`. Each species still has a bindable phase of at least 4 s inside 12 studs on L1. The tutorial Hodag does not charge. Those windows are not live before this PR.
4. **Dossier and Prime.** Courage changes `Income.perSecond` only, cap +10%. Prime is a highlight when all three stats are ≥ 9. `tithePerSecond` ignores Courage. A `source = "pedlar"` migrate writes 5/5/5. A paid grant writes 5/5/5 and `marshwise` and has no reroll.
5. **Lanternwright counter.** L2 through L5 and the UV Lamp, no restock countdown, L1 not priced. The Pedlar does not list them. No new town mesh in this PR.
6. **Almanac.** Hollow Convergence is Saturday 18:00–20:00 UTC. Its luck constant is 1. Rift Tide's ×1.5 on that window stays spec 09 and is not a second Convergence bonus.
7. **Contracts.** Daily 5/10/15 minute steps. The weekly bonus is `Contract.WEEKLY_CASH_MINUTES` = 30 and `Contract.WEEKLY_CASH_FLOOR` = 3000, plus `vigil_wick`. A missed day does not move `daily.step`.
8. **Analytics v1.2.** The Systems Architect adds the seven names in the catalogue below. v1.1 is not edited in place. `Analytics.MAX_CUSTOM_NAMES` is 15 and v1.1 already uses 8, so these seven fill the cap. The server module is the only sender. Each event has at most three fields (`Analytics.MAX_FIELDS`). Field values are `Token - value` strings. No DisplayName, no username, and no user id in a field.

## QA

1. L1 catch of the tutorial Hodag still matches spec 01 (3 s, 12 studs, no charge).
2. With tools forced on in Studio, each species in the table can be caught with only L1 by waiting for the slow phase, and the counter-tool shortens that wait. A client that claims a shorter hold than the server is rejected.
3. Equipping L4 does not change a rarity roll (compare two forced spawns, same seed, tool on and off).
4. The first Dossier screen shows the rarity word, the NEW seal on a first species, the three aptitudes, and the trait. Details says each of 0 through 10 is 1 in 11, and Prime is 8/1331. A 9/9/9 roll shows a Bone ◇ and the word Prime, not a new frame colour, and income is only the Courage formula. A 5/5/5 grant says "Fixed by the Bound Rite: 5 / 5 / 5" and does not show Prime. Tithe does not move.
5. A save with `source = "pedlar"` loads the same species at 5/5/5. Cash is unchanged. A wild cryptid gets the hash, and a second load does not change it.
6. Phone width: Bind and Details are at least 44 px. No shop card on the catch.
7. The UV Lamp beam is `#CC3F8A`, with no Neon, and its PointLight exists only on the holder's client while the lamp is on. The variant word is one of Normal, Spectral, Gilded, Shadow, Moonlit, in that variant's own colour. With the lamp off, the same spawn is still there.
8. The Almanac lists Hollow Convergence as Saturday 18:00–20:00 UTC with no luck of its own. Rift Tide's ×1.5 on that window is still spec 09. Copy has no "last chance". The Lanternwright tool list has no "Restocks in".
9. Three contract marks can be finished with a hold, a place, and a return home. Skipping a UTC day leaves the Offering step where it was. Five days in a Monday–Sunday week grant the named cash minutes, the named floor, and `vigil_wick`, and a fourth day does not.
10. With Steady Hand and the Ember Lantern both owned, and no other catch-time skill, the server hold is 2.43 s. A client that claims 1.4 s is rejected.

## Rulings applied (11 Nov)

- The lamp's name is **UV Lamp**. The beam is `#CC3F8A`.
- L2 and skill `h1` multiply. The floor is `BIND_TIME_MIN_SECONDS` = 1.5.
- Chains do not grant a steal bonus.
- Variant names on the lamp and the Dossier are Normal, Spectral, Gilded, Shadow, and Moonlit (spec 15 §6).
- Rolls stay uniform, 1/11. Prime is a highlight when all three stats are ≥ 9. The faces ≥ 9 are 9 and 10, so the odds are (2/11)³ = 8/1331 (about 0.60%). (3/11)³ = 27/1331 would be every stat ≥ 8, and that is not this mark. A 5/5/5 grant cannot be Prime.
- Rift Tide keeps free ×1.5 luck on Saturday 18:00–20:00 UTC. Hollow Convergence is that same window and adds no luck of its own (`Convergence.LUCK_MULTIPLIER` = 1).
- Contracts pay 5/10/15 minute steps. Any 5 of 7 days pays 30 minutes of pre-2x income, floor $3,000, plus `vigil_wick`. The minute count and the floor are `Contract.WEEKLY_CASH_MINUTES` and `Contract.WEEKLY_CASH_FLOOR`.
- The UV Lamp beam is `#CC3F8A`. The build PR puts `UvBeam` on `UITheme.world`, not on the A2 palette. The lamp's light is client-local and only while it is on.
- Tool beam swatches, including L3 blue and L4 purple, are an allowed exception to spec 01 A2. The rest of the UI keeps A2.
- L5 is the Silver Censer, so the name does not collide with the Moonlit variant.
- The trait tier that was Rare is Uncanny. The trait line is text, not a rarity chip.
- Mythic gets a distinct GoldBright frame. Legendary keeps the plain chip.
- The Dossier's first screen shows aptitudes, the trait, the NEW seal, and the rarity word. Prime is a Bone ◇ and the word Prime, never a frame colour. Odds stay 8/1331 (about 0.60%).
- v1.2 analytics is a catalogue the Systems Architect owns. The Analytics Lead role is retired. The seven events are specified below.
- Pedlar-sourced cryptids migrate to 5/5/5. See spec 17 for the empty counter, the expedition constants, the single slot, and the Robux skin tab.
- Courage carries the placed-income bonus, capped at +10%. Instinct drives expedition speed and route fit, capped at 5% time. Attunement drives bind slack and trait utility, and it does not change income.
- The 4 s and 5 s twist windows wait for the wild-spawner PR.
- Hollow Convergence is Saturday 18:00–20:00 UTC. `Convergence.WEEKDAY` is Saturday, `START_HOUR_UTC` is 18, and `END_HOUR_UTC` is 20.
- The weekly bonus is 30 minutes of pre-2x income, floor $3,000 (`Contract.WEEKLY_CASH_MINUTES`, `Contract.WEEKLY_CASH_FLOOR`).
- v1.2 analytics is specified in this note. It is not waiting on the Analytics Lead.
- L2 through L5 and the UV Lamp are sold at the Lanternwright. They have no restock clock. L1 stays free.

## Open questions for Eudai and Grok Bot

None for a director. `Lure.ENCOUNTER_INTERVAL_SECONDS` is still filled in by the wild-spawner PR before that lure is sold. A drawn Dossier layout does not exist yet. `stat-card.jpg` is mood only.

## Analytics v1.2

Addendum to the v1.1 catalogue in `src/shared/Config/Analytics.luau`. The server sends these. The client does not. No field carries a name, a username, or a user id.

| Event | When the server fires it | Fields |
|---|---|---|
| `ConvergenceWitnessed` | The player is in the server at Saturday 18:00 UTC, once per window | none |
| `AlmanacOpened` | The server accepts the open | none |
| `ContractClaimed` | The server grants one daily mark | `Mark - 1`, `Mark - 2`, or `Mark - 3` |
| `WeeklyBonusClaimed` | The server grants the 5-of-7 bonus | none |
| `ExpeditionSent` | The server confirms Send | `Route - lantern_wood`, `Route - hollow_marsh`, or `Route - bell_quarry` |
| `DossierOpened` | The server has granted the catch and opens the card | `Species - {id}` from the server record |
| `PrimeAwarded` | A free roll has every stat ≥ 9 | `Species - {id}` from the server record |

v1.1 stays `OnboardingSkipped`, `OnboardingStepTime`, `SessionEnded`, `PlayerReturned`, `LedgerLoadFailed`, `PedlarOddsViewed`, `CatchCompleted`, `PlotAssigned`. These seven are the only names added. A paid 5/5/5 grant does not fire `PrimeAwarded`.
