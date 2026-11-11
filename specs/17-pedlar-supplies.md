# Spec 17: Pale Pedlar supplies shop

**Status:** Draft v1.2 (11 Nov 2026). Design note only. This file does not change `src/`. Rulings from this afternoon are in [Rulings applied](#rulings-applied-11-nov).
**Owner:** Growth Strategist tunes every number marked **PROPOSAL**. Systems Architect builds it later, in the PRs named below.
**Reads with:** [spec 18](18-tools-capture-aptitudes.md) (tool ladder, capture twists, aptitudes, Hollow Convergence, Dossier, Daily Contracts). Specs 01 B8, 03, 06, 09, 10, 12, 14 §3, 15 §5 and §10, 16 §6–§8, [compliance-audit-cash-random.md](compliance-audit-cash-random.md), and the research note [2026-11-roblox-retention-monetisation-research.md](research/2026-11-roblox-retention-monetisation-research.md). Where that note marks **[A]**, this spec uses the cited config or spec instead.

## Goal

The stall stops being a cryptid shop. It sells supplies that feed hunting, earn-only crates, and expedition eggs.

**Ruling:** The Pale Pedlar stops selling cryptids. Cryptids come from hunting, crates, and expedition eggs. The Pedlar sells lures, cages, and cosmetics for in-game cash only. The Lanternwright is the tool shop: L2 through L5 and the UV Lamp ([spec 18](18-tools-capture-aptitudes.md)). L1 stays free. Tool effects are deterministic. They never change odds.

Nothing in this note deletes a species id. `Species.luau` and `ShopPools.luau` stay intact, including `uncommon_01`, `rare_01`, `epic_01`, and the empty Legendary and Mythic pools.

## What the code does today

The live stall rolls four cryptid slots in `Shop.SLOTS` (Cheap Cage, Odd Cage, Rare Cage, Pedlar's Curio) on `Shop.ROTATION_SECONDS` (300). `ShopRoll` picks a rarity, then a species. `Transactions` grants it with `source = "pedlar"`. Buying does not reroll (`Shop.ODDS_NOTE`: "Buying never changes the stock."). The client is the #25 card layout: `UITheme.shape.touchPx` (44), a **Details** button, rarity chips, and a `ViewportFrame` portrait.

There is one hunt tool: a session `Tool` named `Economy.TOOL_NAME` (`"Lantern"`), range `Economy.CATCH_DISTANCE_STUDS` (12), hold `Economy.CATCH_SECONDS` (3). No bait, cage-capacity, incubator, egg, or cosmetic renderer exists. `profile.cosmetics.owned` is written by Relics grants and is not read by the lair. The Expedition Board and the Lanternwright are `shuttered` in `Town.luau`. Tarot is reserved and has no reel.

## Price unit (PROPOSAL)

Every cash price below uses the same unit. The Growth Strategist can change **N** without a new formula.

The wallet is the post-rite lair from spec 01 acceptance test 7, rebuilt from config:

- Bases in `Species.luau`: `mothman_hatchling` 2 + `fresno_nightcrawler` 3 + `hodag` 5 + `hidebehind` 4 = **14**.
- `BoneAltar.multiplier(1, false)` = 1 + `LINEAR_BONUS` (0.25) = **1.25**.
- **R0 = 14 × 1.25 = $17.50/s.** Skills and `wildIncome` are not in R0.

Spec 09's wild interval is **45 s**. That interval is not a field on `Economy`. One interval of this lair is **H = 17.50 × 45 = $787.50**. A price is **N × H**. Supplies do not print cash. N is how many intervals of R0 the price costs. `Money.round` keeps the cent.

| N | Price |
|---|---|
| 1 | $787.50 |
| 2 | $1,575 |
| 4 | $3,150 |
| 6 | $4,725 |
| 8 | $6,300 |
| 16 | $12,600 |

Compare: `Economy.PAD_COST[5]` is $1,200, Pad 7 is $15,000, and skill `h1` (the same −10% hold as the Ember Lantern) costs $1,000. `Shop.RARITIES` payback stays the cryptid formula (`baseIncome × paybackSeconds`) and is not reused as a supply price.

## Tools live at the Lanternwright

The Pedlar does not sell tools. L2 through L5 and the UV Lamp are the Lanternwright's counter. L1 stays free and is not a row there. Numbers, gates, and what the code can do today are in [spec 18](18-tools-capture-aptitudes.md). The Lanternwright shows no restock clock. Those tools are always in stock. `Town.luau` still marks the stall `shuttered`. The tool-shop PR sets it live and does not add town parts. A new mesh waits for the World Builder.

Short catalogue, sold at the Lanternwright, not here:

| Item | Effect | Duration / charges | Stack | Cash price | In code today | Sale |
|---|---|---|---|---|---|---|
| Rusty Lantern (L1) | Orange beam. Hold 3 s, range 12. | Permanent. No charges. | 1 | $0 (N = 0) | Yes. Session tool `"Lantern"`. | Not sold. Already granted at the tutorial catch. |
| Ember Lantern (L2) | Green beam. Hold 3.0 s → 2.7 s. Odds unchanged. | Permanent. | 1 | $1,575 (N = 2) | The −10% exists only as skill `h1`. No second tool. | **Deferred, Update 1. Not sold.** |
| Spirit Compass (L3) | Blue arrow to the nearest wild spawn. No spawn or rarity change. | Permanent. | 1 | $3,150 (N = 4) | No. `h3` Keen Eye is sealed. | **Deferred, Update 1. Not sold.** |
| UV Lamp | Shows tracks and the variant the server already rolled. No new roll. | Permanent. | 1 | $4,725 (N = 6) | No tracks, no variants. | **Deferred, Update 1. Not sold.** |
| Binding Chains (L4) | Purple tether. Range 12 → 16. | Permanent. | 1 | $6,300 (N = 8) | No. `h2` is +2 studs on a skill, not a tool. | **Deferred, Update 1. Not sold.** |
| Silver Censer (L5) | Silver smoke. Grounds a flier into the bindable phase sooner. Can hold two cryptids that are already in a bindable phase. | Permanent. | 1 | $12,600 (N = 16) | No. `settings.bindAtOnce` places a bought cryptid on a pad. It is not a second bind. | **Deferred, Update 1. Not sold.** |

Until a row has a server effect, the card has no Buy button and charges nothing. The price stays in this note for the strategist.

## Lures and bait

A lure never changes rarity odds or mutation odds. Reed Bait and the Spirit Compass are the proof: the spec 09 rarity table is byte-identical with the item on or off. Two lure effects are allowed, each fixed and written on the card before cash is spent. One sets the next spawn wait to `Lure.ENCOUNTER_INTERVAL_SECONDS` (the first PR sets that constant; the card shows 45 s, the spec 09 interval, and the new wait). The other attracts the named species on the card. `h5` and `h6` stay sealed.

| Item | Effect | Duration / charges | Stack | Cash price | Hooks into | In code | Sale |
|---|---|---|---|---|---|---|---|
| Reed Bait | When that species' published spawn condition is already true, the next wild spawn of that species appears at the bait. Interval stays 45 s. Rarity weights stay spec 09's table. | 1 charge, spent when that spawn is placed. | 3 | $787.50 (N = 1) | Spec 15 §10 bait. Wild spawner. | No. Only `Species.WILD_ID` (Hodag) at `Economy.WILD_SPAWN_STUDS` (20). | **Deferred. Not sold.** |
| Fog Lamp | See through Fog Night. No spawn, rarity, or income change. | Permanent. | 1 | $1,575 (N = 2) | Spec 15 §10. Fog Night is atmosphere only (director ruling 15) and is not in `src/`. | No. | **Deferred. Not sold.** |
| Odds lure | Would change a rarity weight or a mutation weight. | — | — | No price. | Rarity and mutation tables. | No. | **Not sold.** |

The Robux **Lure Totem** (spec 09, 49 R$, moves spawns, does not change odds) stays a Relics product. This stall does not sell it, and this note does not change that Robux price.

## Cages and incubators

| Item | Effect | Duration / charges | Stack | Cash price | Hooks into | In code | Sale |
|---|---|---|---|---|---|---|---|
| Witness Cage | Would raise a holding cap by 1. | Permanent. | 1 | No price until a cap exists. | `profile.cryptids` | The map has no cap (instance id length ≤ 64). Pads full already sends the cryptid to inventory (spec 01 B9). A cage with nothing to expand is an empty effect. | **Deferred. Not sold.** |
| Salt Cradle | Would run a hatch. Spec 14's later idea is a free 5-minute timer with no paid speed-up. | — | — | No price. | Eggs | No egg, no timer. A paid speed-up of a random hatch is out of this catalogue. | **Deferred. Not sold.** |

The four names in `Shop.SLOTS` are cryptid offers, not these items. Implementation stops offering species. It does not reuse those four names as supply SKUs.

## Expeditions: the yield is on the card before Send

Research row 2 asked for expeditions whose haul is known when you send them. Route length is spec 14: Lantern Wood 10 minutes, Hollow Marsh 1 hour, Bell Quarry 4 hours. They pay 15, 45, and 150 minutes of pre-2x income, Courage excluded. Those lengths are not the Instant Return skip brackets. The Board is shuttered in `Town.luau` (`ExpeditionBoard`). This is January, not launch (spec 15 §9).

| Route | Duration constant | Cash constant | Cash shown |
|---|---|---|---|
| Lantern Wood | `LANTERN_WOOD_DURATION_MINUTES` = 10 | `LANTERN_WOOD_CASH_MINUTES` = 15 | 15 min of pre-2x income, Courage excluded |
| Hollow Marsh | `HOLLOW_MARSH_DURATION_MINUTES` = 60 | `HOLLOW_MARSH_CASH_MINUTES` = 45 | 45 min of pre-2x income, Courage excluded |
| Bell Quarry | `BELL_QUARRY_DURATION_MINUTES` = 240 | `BELL_QUARRY_CASH_MINUTES` = 150 | 150 min of pre-2x income, Courage excluded |

One free slot (spec 14 §3). The chosen cryptid leaves its pad. The card states that income trade-off before Send. Server time advances while you are offline (spec 14). Skill `h7` Expedition Lore (−10% time) is sealed in `SkillConfig` and does not apply until it is unsealed. Aptitude time stays inside the 5% cap in [spec 18](18-tools-capture-aptitudes.md) and does nothing until expeditions exist.

**Before Send, the card shows the whole manifest.** Return delivers that card once. A disconnect does not reroll it (spec 14).

- **Cryptid or egg.** A free egg is allowed only when the card already shows its species, Courage, Instinct, Attunement, and trait (spec 14). There is no second reveal on the way home. A cash egg ticket is not sold.
- **Cash.** Minutes of the player's pre-2x income, Courage excluded, the same rate cash bundles use. The constants are above. `Expedition.CASH_CAP_MINUTES` is **300** per UTC day. The card shows `Expedition cash today 150/300` with the real numbers. Cash past the cap is not granted. This cash is **not Tithe** and not a leaderboard point (spec 11 §2.3). Instant Return only delivers a send that already exists. It never creates a send, never adds a roll, and never pays past the cap. A paid extra slot does not add a roll either.
- **Relic.** Rolled when the card is built, not when the party returns (audit row 9, spec 12 §6.2). Details shows the table before the roll: Fog Lantern 50%, Cracked Bell 20%, Wisp Jar 20%, Blood Chalice 7%, Rift Shard 2%, Black Sun Coin 1% (100%). The card then names the relic that was rolled. Cap 5 of each (spec 12 §6.2).
- **No tarot token** (spec 09 v3). No Essence.

The research's second slot (rebirth) and third slot (Robux) are **[A]**. This note keeps one free slot. A paid extra slot is **PENDING EUDAI**. It is not a config value, and it must not add a roll (audit: enhanced drops). Instant Expedition Return stays the spec 09 product. Its Robux figures are not copied here. Director ruling 5: those prices are still open (**PENDING EUDAI**). The skip may deliver only the manifest already shown (spec 09 §8). Spec 14 recommends shipping expeditions without the skip until that re-audit.

### Egg tickets are not on the counter

| Item | Effect | Duration / charges | Stack | Cash price | Hooks into | In code | Sale |
|---|---|---|---|---|---|---|---|
| Veil Egg Ticket | Would sell a random hatch for cash. | 1 charge. | 1 | No price. | Eggs | No egg system (spec 14). No hatch table. | **Not sold.** |

A cash ticket is a random-for-currency item. The stall does not sell it. An egg that appears on an expedition card is free, and its contents are already shown. Tarot cases, readings, and the Fate Reel stay earn-only (spec 10, decision B). They are not rows here. No tokens on this stall.

## Cosmetics

`profile.cosmetics.owned` can store a flag. Nothing in the lair reads it. `founders_candle` and `lair_cosmetics` stay Relics grants. Selling a look that does not render fails the "working effect" rule.

| Item | Effect | Duration / charges | Stack | Cash price | Hooks into | In code | Sale |
|---|---|---|---|---|---|---|---|
| Keeper's Rim | Pad rim material. Income unchanged. | Permanent. | 1 | $3,150 (N = 4) | `cosmetics.owned` plus a lair renderer | Flag only. No renderer. | **Deferred. Not sold.** |
| Veil Mantle | Lantern glass tint. No range, hold, or odds change. | Permanent. | 1 | $1,575 (N = 2) | Same | No renderer. | **Deferred. Not sold.** |

No pumpkins, wreaths, or holiday names. Robux cosmetics in spec 09 (VIP Lair 299 R$, and the rest) stay on Relics at those figures.

## Odds and Details

- Any row that changes a number shows the exact before and after. A hold tool shows `3.0 s → 2.7 s`. A range tool shows `12 → 16 studs`. Under that line: "Catch odds unchanged. Rarity weights unchanged. Variant odds unchanged."
- The Reed Bait's Details, when it is eventually sold, shows the spec 09 wild table unchanged (Common 80%, Uncommon 16.4%, Rare 3.4%, Epic 0.2%) and says the bait does not edit those weights.
- An egg ticket's Details shows the full hatch table. No ticket is shown before that table exists.
- Aptitude and trait distributions live on the Stat Card Details ([spec 18](18-tools-capture-aptitudes.md)).
- The button is the word **Details** (`Shop.DETAILS`). Never a bare (i). Spec 01 B8. Spec 16 §8.5.
- Buying does not reroll, restock, or play a rarity fanfare. No sky and no banner (a shop grant is not a free source).

## Policy

Cash only. No Robux button, no product id, no edit to `Monetisation.luau` or to spec 09's Robux figures. Server Luck and those Robux prices stay open (director ruling 5).

If a list cannot change, its countdown is hidden. There is no idle "Restocks in" timer. `Shop.ROTATION_SECONDS` stays in config for a list that really rotates. Buying still does not reroll. No "last chance", "only N left", or "deal of the day" (spec 16 §7.3 and §7.4). The launch stalls do not rotate, so they show no clock.

**Cash and the policy gate.** Cash is paid currency because it is sold in Robux bundles (audit ruling, spec 09 §8). `PolicyGate.allows` reads `ArePaidRandomItemsRestricted` and fails closed: it returns true only when that field is explicitly false. `MonetisationService.paidRandomAllowed` calls it. Nothing in the Pedlar calls it today. This stall does not need the gate, because it sells no random item. A future random cash row would have to call it and hide the row when it returns false. That row is not in this catalogue.

No paid random item ships from this stall. Until Update 1 the counter shows the free lantern as already owned and charges nothing. That empty cash counter is accepted.

**Not sold, from the 11 Nov research as well as the earlier rulings.** No luck boost. No paid restock and no paid reroll (`Shop.ROTATION_SECONDS` stays 300, and buying does not change `rotationId`). No cash crate, case, or other random-for-currency row. Reed Bait, when it eventually exists, still does not change the spec 09 wild weights, and it is not sold now.

**Robux prices the research wrote down.** None of them are approved here, and none are written as a config value.

| Research row | What it priced | This note |
|---|---|---|
| 2 | A third expedition slot | **PENDING EUDAI.** One free slot only. The figure is not recorded here. |
| 13 | A lantern or UV beam skin | **PENDING EUDAI.** Robux **Cosmetics** tab only. Not cash. No stat and no odds change. No figure in config. Not sold before approval. |

Moon Pass, Bound Rites, and Instant Expedition Return stay in spec 09. Ruling 5 leaves those Robux prices open. This note does not copy them into a new field.

The stall also does not sell a start, a skip, or a luck item for Hollow Convergence, and it does not sell aptitude rerolls. Those systems are in [spec 18](18-tools-capture-aptitudes.md).

## Data

`Save.DATA_VERSION` on this branch is **9**. Pull request #15 (`cursor/rebirth-r1-r7`) sets it to **10** and adds `migrateToV10`. This design does not take 10.

The next free version after #15 merges is **11**. One migration, chained after v10, adds:

- `profile.tools = { owned = { rusty_lantern = true }, equipped = "rusty_lantern" }`
- `profile.supplies = { charges = {} }`
- On each cryptid: `courage`, `instinct`, `attunement` (0–10) and, when `traits` is empty, one trait id. The fill rule is in [spec 18](18-tools-capture-aptitudes.md).

A save still at 9 runs v10, then v11. Do not merge the schema PR before #15. If the tool fields and the aptitude fields ship in two PRs, the second takes **12**. Prefer one PR so there is one step.

A cryptid with `source = "pedlar"` keeps its `speciesId`, instance id, `mutation`, `source`, and `acquiredAt`. It is not deleted. The migration writes Courage, Instinct, and Attunement to **5 / 5 / 5** (`Aptitude.PAID_GRANT`). That is a +5% Courage bonus, not a hash, and it cannot be Prime (spec 18). Other cryptids still use the hash. The version bump is in the code PR, chained after #15's v10. This note does not edit `Save.DATA_VERSION`.

## UI

Reuse the #25 Pedlar card. Do not invent a second panel.

- Targets: `UITheme.shape.touchPx` (44), including Buy, Details, and Leave.
- Header stays `Shop.HEADER` ("The Pale Pedlar").
- Prompt copy changes from "Browse the Pedlar's cages" to **"Browse the Pedlar's wares"** when the offers stop being cryptids.
- Icon: scripted parts in a `ViewportFrame`, same path as `PedlarShop` portraits. No new image asset. Tool beams use the concept colours: L1 orange, L2 green, L3 blue, L4 purple, Silver Censer silver, UV Lamp `#CC3F8A`. Those swatches are an allowed exception to spec 01 A2, because they come from the tool concept art. They sit in the `ViewportFrame` or as a dot no wider than 16 px. Flat UI chrome stays on A2 tokens. A variant shown by the lamp uses the variant's own colour, not the beam.
- Chip: reuse `UiFactory.rarityChip` for layout only. On the Pedlar the label is **Bait**, **Cage**, or **Look**. On the Lanternwright it is **Tool**. Colour is Gold when it can be bought, BoneDim when it cannot. Do not mark a lantern Common or Epic.
- A card that can be bought shows name, the numeric effect, and the price before cash is spent (spec 16 §6 and §8.5).
- A deferred card shows the name and the line **"Not on the counter."** No price, no Buy.
- Spec 16 rules this shop applies: §6 (say what it does), §7.1, §7.3, §7.4, §7.9, §8.5. §8.5 still says "caged cryptid". That sentence is stale once this ships. This note does not edit spec 16. The follow-up edit is: show the supply and its effect, not a caged cryptid.
- No shop modal during a bind, reveal, haul, offering, or rite (spec 16 verification line). The gate stays `Shop.GATE_STEP` (8) and `Monetisation.GATE_PLAY_SECONDS` (300) before any cash row can be bought. L1 is already in the player's hands from the tutorial and is not a purchase.

The Lanternwright is the tool shop. The Pedlar does not list L2 through L5 or the UV Lamp. A new building mesh is the World Builder's, after #14. This note does not edit `TownBuilder`.

## Implementation plan

The first code PR is specified in [spec 18](18-tools-capture-aptitudes.md). It is the launch stock: Pedlar cages, lures, and cosmetics, plus Lanternwright L2 and the UV Lamp, plus `qa:N:clock+<sec>`. This note does not schedule a separate empty-stall PR. Schema still waits on #15. Expeditions stay January. A save newer than the running `DATA_VERSION` is refused and not overwritten, which is what `Schema.migrate` does today.

**Launch cards.** Pedlar: Witness Cage, Reed Bait, Keeper's Rim, Veil Mantle. Lanternwright: Ember Lantern, UV Lamp. No cryptid name, no "Bind at once" toggle, no four-column cryptid odds table. **Details** on a supply shows the fixed effect. `PedlarOddsViewed` still fires, with the item id, not a species roll. The prompt becomes "Browse the Pedlar's wares" in that same PR. The server refuses a buy unless `onboarding.step` is at least 8 and saved `onboarding.playSeconds` is at least 300.

**Relic at the cap.** The expedition card rolls the spec 12 table when it is built. A relic the player already holds 5 of is skipped. If every relic is at 5, the card says no relic and still shows the cash. Cancel before Send does not keep a roll. Disconnect after Send does not roll again.

**Details lines.** L2: "Hold 3.0 s → 2.7 s" or "2.7 s → 2.43 s" when `h1` is owned. Compass: "Points within 80 studs. Rarity odds unchanged." UV Lamp: "Shows the variant already rolled. Odds unchanged." Chains: "Range 12 → 16." Silver Censer: "The wait until the next landing is halved. The landing stays at least 4 s." Reed Bait: "Next spawn is the named species. Rarity odds unchanged."

## QA

1. Fresh profile after the gate: the Pedlar sells Witness Cage, Reed Bait, Keeper's Rim, and Veil Mantle. The Lanternwright sells the Ember Lantern and the UV Lamp. L1 is already owned. No cryptid is for sale. There is no "Bind at once" toggle and no four-column cryptid odds table.
2. A profile that already owns a Pedlar cryptid still owns that species after load, at Courage 5, Instinct 5, Attunement 5.
3. Details on a Lanternwright tool says the odds are unchanged, with the before and after hold or range. A lure's Details shows the encounter interval or the named species, and the spec 09 rarity table unchanged.
4. Neither stall shows "Restocks in". Copy has no "last chance" or "only".
5. Touch targets are 44 px on a phone width (`UITheme.shape.mobileWidthBreakpoint` 700).
6. No Marketplace prompt, and no new product id.
7. Tutorial Hodag still completes with the free lantern (spec 01). The charge twist does not run on that spawn (spec 18).
8. The counter has no luck row, no restock skip, no crate, and no egg ticket. An expedition card lists species, aptitudes, cash, and relic before Send. A second send with the same id does not reroll. The cash is absent from Tithe. A day already at 300 minutes grants no more expedition cash. Instant Return does not create a send. A stall that cannot rotate has no countdown. There is no "Not on the counter" row at launch.

## Rulings applied (11 Nov)

- Expedition cash is the sent cryptid's pre-2x income for 15, 45, and 150 minutes on the 10 min, 1 h, and 4 h routes. Those six numbers are named constants.
- The third expedition slot stays **PENDING EUDAI**. One free slot.
- Beam skins are not on the Pedlar. They belong on a separate Robux tab. Prices **PENDING EUDAI**. No figure is stored here.
- An empty cash counter until Update 1 is accepted.
- A Pedlar-sourced cryptid migrates to 5/5/5. The version bump is in the code PR, chained after #15.
- Lures that change rarity or mutation odds stay off the stall. A lure may raise the encounter rate, or attract a named species, as a fixed effect shown before purchase.
- A free expedition egg is allowed only when its contents are already on the send card.
- A cash offer and a Rift belt offer roll aptitudes when the offer is created. Details shows them before purchase. Only a Robux grant stays 5/5/5 and Marshwise.
- Expedition cash is not Tithe. `Expedition.CASH_CAP_MINUTES` is 300. Instant Return does not add a send.
- The first code PR sells Pedlar cages, lures, and cosmetics, and Lanternwright L2 and the UV Lamp.
- Reed Bait and the Spirit Compass do not change rarity odds.
- Studio tests move time with `qa:N:clock+<sec>`.
- Permanent tools have no 5-minute restock clock. They are always in stock at the Lanternwright.
- The Lanternwright sells L2 through L5 and the UV Lamp. L5 is the Silver Censer. L1 stays free. The Pedlar sells lures, cages, and cosmetics only.
- The UV Lamp beam is `#CC3F8A`. Tool beam swatches, including L3 blue and L4 purple, are an allowed exception to spec 01 A2. The rest of the UI keeps A2.

## Open questions for Eudai and Grok Bot

None for a director. `Lure.ENCOUNTER_INTERVAL_SECONDS` lands with the wild-spawner PR. The UV Lamp's track and variant capture land with the build PR. The Dossier layout mock is coming from the Art Director. `stat-card.jpg` stays mood only.
