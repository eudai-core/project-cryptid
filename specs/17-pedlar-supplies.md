# Spec 17: Pale Pedlar supplies shop

**Status:** Draft v1 (11 Nov 2026). Design note only. This file does not change `src/`.
**Owner:** Growth Strategist tunes every number marked **PROPOSAL**. Systems Architect builds it later, in the PRs named below.
**Reads with:** [spec 18](18-tools-capture-aptitudes.md) (tool ladder, capture twists, aptitudes). Specs 01 B8, 03, 09, 10, 15 §5 and §10, 16 §6–§8, and [compliance-audit-cash-random.md](compliance-audit-cash-random.md).

## Goal

The stall stops being a cryptid shop. It sells supplies that feed hunting, earn-only crates, and expedition eggs.

**Ruling:** The Pale Pedlar stops selling cryptids. Cryptids come from hunting, crates, and expedition eggs. The Pedlar is a supplies shop priced in in-game cash only. Tools are the core stock ([spec 18](18-tools-capture-aptitudes.md)). Their effects are deterministic. They never change odds.

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

## Core stock: tools

Full numbers, gates, and code support are in [spec 18](18-tools-capture-aptitudes.md). Short catalogue:

| Item | Effect | Duration / charges | Stack | Cash price | In code today | Sale |
|---|---|---|---|---|---|---|
| Rusty Lantern (L1) | Orange beam. Hold 3 s, range 12. | Permanent. No charges. | 1 | $0 (N = 0) | Yes. Session tool `"Lantern"`. | Not sold. Already granted at the tutorial catch. |
| Ember Lantern (L2) | Green beam. Hold 3.0 s → 2.7 s. Odds unchanged. | Permanent. | 1 | $1,575 (N = 2) | The −10% exists only as skill `h1`. No second tool. | **Deferred, Update 1. Not sold.** |
| Spirit Compass (L3) | Blue arrow to the nearest wild spawn. No spawn or rarity change. | Permanent. | 1 | $3,150 (N = 4) | No. `h3` Keen Eye is sealed. | **Deferred, Update 1. Not sold.** |
| Veil Lamp (UV) | Shows tracks and the variant the server already rolled. No new roll. | Permanent. | 1 | $4,725 (N = 6) | No tracks, no variants. | **Deferred, Update 1. Not sold.** |
| Binding Chains (L4) | Purple tether. Range 12 → 16. | Permanent. | 1 | $6,300 (N = 8) | No. `h2` is +2 studs on a skill, not a tool. | **Deferred, Update 1. Not sold.** |
| Moonlit Censer (L5) | Silver smoke. Grounds a flier into the bindable phase sooner. Can hold two cryptids that are already in a bindable phase. | Permanent. | 1 | $12,600 (N = 16) | No. `settings.bindAtOnce` places a bought cryptid on a pad. It is not a second bind. | **Deferred, Update 1. Not sold.** |

Until a row has a server effect, the card has no Buy button and charges nothing. The price stays in this note for the strategist.

## Lures and bait

An item that raises hunt odds or a rarity weight is **not sold**. Wild rarity weights in spec 09 are not implemented (the only wild spawn in code is the tutorial Hodag). `h5` Lure Craft (`spawnRate` +10%) and `h6` Blood Tracker (Uncommon-or-better ×1.05) stay sealed. A cash copy would be a paid probability modifier ([compliance audit](compliance-audit-cash-random.md) rows 6, 7, and 10; spec 16 §7.1 and §7.9; spec 15 §5).

| Item | Effect | Duration / charges | Stack | Cash price | Hooks into | In code | Sale |
|---|---|---|---|---|---|---|---|
| Reed Bait | When that species' published spawn condition is already true, the next wild spawn of that species appears at the bait. Interval stays 45 s. Rarity weights stay spec 09's table. | 1 charge, spent when that spawn is placed. | 3 | $787.50 (N = 1) | Spec 15 §10 bait. Wild spawner. | No. Only `Species.WILD_ID` (Hodag) at `Economy.WILD_SPAWN_STUDS` (20). | **Deferred. Not sold.** |
| Fog Lamp | See through Fog Night. No spawn, rarity, or income change. | Permanent. | 1 | $1,575 (N = 2) | Spec 15 §10. Fog Night is atmosphere only (director ruling 15) and is not in `src/`. | No. | **Deferred. Not sold.** |
| Odds lure | Would multiply a rarity weight or a spawn rate. | — | — | No price. | Would hook a wild table that does not exist, and the audit forbids the cash hook. | No. | **Not sold.** Not deferred into a later sale. |

The Robux **Lure Totem** (spec 09, 49 R$, moves spawns, does not change odds) stays a Relics product. This stall does not sell it, and this note does not change that Robux price.

## Cages and incubators

| Item | Effect | Duration / charges | Stack | Cash price | Hooks into | In code | Sale |
|---|---|---|---|---|---|---|---|
| Witness Cage | Would raise a holding cap by 1. | Permanent. | 1 | No price until a cap exists. | `profile.cryptids` | The map has no cap (instance id length ≤ 64). Pads full already sends the cryptid to inventory (spec 01 B9). A cage with nothing to expand is an empty effect. | **Deferred. Not sold.** |
| Salt Cradle | Would run a hatch. Spec 14's later idea is a free 5-minute timer with no paid speed-up. | — | — | No price. | Eggs | No egg, no timer. A paid speed-up of a random hatch is out of this catalogue. | **Deferred. Not sold.** |

The four names in `Shop.SLOTS` are cryptid offers, not these items. Implementation stops offering species. It does not reuse those four names as supply SKUs.

## Expedition egg tickets

| Item | Effect | Duration / charges | Stack | Cash price | Hooks into | In code | Sale |
|---|---|---|---|---|---|---|---|
| Veil Egg Ticket | One egg for a named route. The hatch is a random cryptid. | 1 charge. | 1 | No price until a hatch table exists. | Expedition Board, eggs | Board is shuttered. Spec 14: eggs are not a specified system. No hatch odds exist in spec or code. | **Deferred. Not sold.** |

Do not invent a hatch table in the shop. When a table is approved it must sum to 100% and the Details view must show every row (spec 01 B8, spec 16 §8.5). Until then the ticket is absent from the counter.

Tarot cases, readings, and the Fate Reel stay earn-only (spec 10, decision B). They are not rows here. No tokens on this stall.

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

Restock stays as it is. `Shop.ROTATION_SECONDS` is 300. `ShopStock.rotationId` is `floor(unix / 300)`. The label stays `Shop.RESTOCK_PREFIX` ("Restocks in ") plus `ShopStock.formatCountdown`. The note under Details stays "Buying never changes the stock." The lantern glow stays `Shop.GLOW_SECONDS` (10). No "last chance", "only N left", or "deal of the day" (spec 16 §7.3 and §7.4). Director ruling 20.

Permanent tools are always on the counter. The clock still ticks, and a tick does not remove an unsold tool. That keeps the real timer without turning it into scarcity. Open question 4 records the alternative.

**Egg tickets and the policy gate.** Cash is paid currency because it is sold in Robux bundles (audit ruling, spec 09 §8). A ticket that rolls a cryptid after a cash purchase is a paid random item. `PolicyGate.allows` reads `ArePaidRandomItemsRestricted` and fails closed: it returns true only when that field is explicitly false. `MonetisationService.paidRandomAllowed` calls it. Nothing in the Pedlar calls it today, because the stall sells a cryptid that was already rolled onto the card. If a ticket is ever sold, the server must call `paidRandomAllowed` and the row must be absent for a restricted player, not shown and then blocked. This note does not sell the ticket. Decision B and spec 09 still say nothing random is sold. Open question 3: do not implement the ticket until Eudai overrides that sentence in writing.

No paid random item ships from this stall at launch. The launch counter charges cash for nothing, because no supply effect beyond the free lantern exists yet.

## Data

`Save.DATA_VERSION` on this branch is **9**. Pull request #15 (`cursor/rebirth-r1-r7`) sets it to **10** and adds `migrateToV10`. This design does not take 10.

The next free version after #15 merges is **11**. One migration, chained after v10, adds:

- `profile.tools = { owned = { rusty_lantern = true }, equipped = "rusty_lantern" }`
- `profile.supplies = { charges = {} }`
- On each cryptid: `courage`, `instinct`, `attunement` (0–10) and, when `traits` is empty, one trait id. The fill rule is in [spec 18](18-tools-capture-aptitudes.md).

A save still at 9 runs v10, then v11. Do not merge the schema PR before #15. If the tool fields and the aptitude fields ship in two PRs, the second takes **12**. Prefer one PR so there is one step.

A cryptid with `source = "pedlar"` keeps its `speciesId`, instance id, `mutation`, `source`, and `acquiredAt`. It is not deleted or replaced. The migration only fills the new fields. See spec 18 open question 5 if that fill must not move income.

## UI

Reuse the #25 Pedlar card. Do not invent a second panel.

- Targets: `UITheme.shape.touchPx` (44), including Buy, Details, and Leave.
- Header stays `Shop.HEADER` ("The Pale Pedlar").
- Prompt copy changes from "Browse the Pedlar's cages" to **"Browse the Pedlar's wares"** when the offers stop being cryptids.
- Icon: scripted parts in a `ViewportFrame`, same path as `PedlarShop` portraits. No new image asset. Colours from `UITheme` tokens. Beam colours for the tools are the spec 15 identities (orange, green, blue, purple, silver). The Veil Lamp's colour is unset (spec 18).
- Chip: reuse `UiFactory.rarityChip` for layout only. The label is **Tool**, **Bait**, **Egg**, or **Look**. Colour is Gold when it can be bought, BoneDim when it cannot. Do not mark a lantern Common or Epic.
- A card that can be bought shows name, the numeric effect, and the price before cash is spent (spec 16 §6 and §8.5).
- A deferred card shows the name and the line **"Not on the counter."** No price, no Buy.
- Spec 16 rules this shop applies: §6 (say what it does), §7.1, §7.3, §7.4, §7.9, §8.5. §8.5 still says "caged cryptid". That sentence is stale once this ships. This note does not edit spec 16. The follow-up edit is: show the supply and its effect, not a caged cryptid.
- No shop modal during a bind, reveal, haul, offering, or rite (spec 16 verification line). The gate stays `Shop.GATE_STEP` (8) and `Monetisation.GATE_PLAY_SECONDS` (300) before any cash row can be bought. L1 is already in the player's hands from the tutorial and is not a purchase.

The Lanternwright stall stays shuttered. Stock is on the Pedlar. Opening the Lanternwright is town geometry and waits for the World Builder after #14.

## Implementation plan

This note is not one of these PRs.

1. **Stop the cryptid counter.** `Pedlar` publishes supply rows instead of `ShopRoll` species. Buy is enabled only when the server has an effect. L1's card says it is already yours and does not charge. `Species` ids are untouched. Tests: a buy request for a slot no longer grants a species; rotation id does not change on buy; existing `source = "pedlar"` records still load.
2. **Schema, after #15.** Version 11 as above. Tests: the same instance id fills the same aptitudes twice; species id and `source` stay put; cash is unchanged; L2 is not granted.
3. **Update 1 tools.** Spec 18 PRs. Prices live in config, not literals in the shop script. Details shows before and after. A grep test rejects `luck`, `spawnRate`, `rarityMult`, `variant`, and `mutation` on any supply SKU.
4. **Deferred rows stay unwired.** Egg ticket only after a written override of decision B, an approved hatch table that sums to 100%, and `paidRandomAllowed`.

## QA

1. Fresh profile: the stall shows the Rusty Lantern as owned. No cryptid name, no species price, no Buy that spends cash.
2. A profile that already owns a Pedlar cryptid still owns that species after load.
3. Details on a tool says the odds are unchanged, with the before and after hold or range.
4. The countdown uses the real 300 s boundary. Copy has no "last chance" or "only".
5. Touch targets are 44 px on a phone width (`UITheme.shape.mobileWidthBreakpoint` 700).
6. No Marketplace prompt, and no new product id.
7. Tutorial Hodag still completes with the free lantern (spec 01). The charge twist does not run on that spawn (spec 18).

## Open questions for the director

1. The first supplies brief asked for lures that raise hunt odds. This note does not sell those, because the later tools ruling and the cash-random audit forbid them. Confirm that withdrawal.
2. Launch then has a stall that charges nothing until Update 1. Confirm the cryptid counter still closes on that day, rather than staying until one supply can be charged.
3. Egg tickets contradict spec 09's "Nothing random is ever sold." Confirm they stay deferred until you override that sentence. The policy gate would apply.
4. Permanent tools never leave the counter, while the 5-minute clock still runs (ruling 20). Confirm, or say the clock should hide when the list cannot change.
5. Stock stays on the Pedlar. The Lanternwright stays shuttered. Confirm.
