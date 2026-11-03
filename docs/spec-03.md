# Spec 03: Town centre (Hollowmere)

Hollowmere is the shared market at the origin. Eight roads leave it on the same angles as the eight lairs. The Pale Pedlar sells four caged cryptids for in-game cash. The stock is the same on every server for five minutes, then it changes. The Skill Shrine is the door the next spec will open onto the skill tree.

This depends on spec 02 (PR #3) and spec 01 (PR #2). Nothing here is sold for Robux.

## World

The town radius is 120. The cobble surface sits at y = −1. The ground outside the wall stays at y = 0, which is the playtest height under the lairs. A low basalt wall follows the circle and breaks for a 16-stud road at each plot angle `θ = (i − 1) × 45°`. Those are the same angles as `PlotRing.townEdge`.

The Weeping Well is centred on the origin: a 10-stud stone cylinder, dark water, a drip, and eight candles. District *n* stands at radius 75 on `θ = 22.5° + (n − 1) × 45°`, facing the well.

| District | Status |
| --- | --- |
| The Pale Pedlar | Live. Prompt: "Browse the Pedlar's cages" |
| The Lanternwright | Shuttered. Sign: "Shuttered until the next moon" |
| The Tarot Table | `Reserved_TarotTable`, 24 × 24, roped off |
| Expedition Board | Shuttered |
| The Bone Broker | Shuttered |
| The Great Rift | `Reserved_GreatRift`, 24 × 24, fenced pit, faint Rift ring |
| Grimoire Lectern | Shuttered |
| Skill Shrine | Live. Prompt: "Open the skill tree" |

Shuttered stalls have no prompt. Reserved footprints have no prompt. Iron lamps stand on an inner ring, 18 studs apart, candle light at range 14 and brightness 1. Every sixth lamp dips for 0.2–0.6 seconds. Rift green is the pit ring, and the Pedlar's lantern for 10 seconds after a restock.

The atmosphere in the live place uses spec 03: density 0.38, color `#1A1719`, decay `#0B0A0C`, haze 1.5. Brightness, exposure, clock, fog start 140, and fog end 380 stay the playtest values. `UITheme.lighting` still records the playtest atmosphere (density 0.18, haze 0.3) so the spec 02 fog-band check remains true of that table. `LightingSetup` overwrites the four atmosphere fields after applying the theme.

There is no skybox and no ambient bed. Asset ids for the moon, wind, bell, and crows are not chosen yet.

The bottom-left HUD is unchanged. Return to Lair, then Steady gaze. The slot to the right of both stays empty for the later Rites button.

## The Pale Pedlar

`rotationId = floor(os.time() / 300)`. The server rolls four offers with a seeded RNG whose seed is `rotationId + SALT`. `SALT` lives in `ServerScriptService` (`ShopSalt`). The client never receives it and never rolls. Stock is replicated on `ReplicatedStorage.PedlarBoard` as the offers the server already rolled, plus `nextRestockUnix`.

Each column of odds sums to 100. After the rarity, the species is uniform in that rarity's pool. An empty pool falls back to the next lower rarity that has species and warns. The shop never rolls a mutation.

Prices are base income times payback, from the seed table: Common $180, Uncommon $900, Rare $6,750, Epic $64,000, Legendary $720,000, Mythic $9,000,000. The card shows that price and the creature's real income (`species base × Bone Altar`), not a second number.

`RequestPedlarBuy(rotationId, slot)` is refused unless the slot is an integer 1–4, the rotation is the server's current one, the slot is not already bought, the player can pay, and onboarding step is at least 8. The remote is on the same per-second cap and 0.25 second purchase debounce as the other spends. A stale rotation answers "The Pedlar has moved on." and refreshes the snapshot. Before step 8 the stall reads "The Pedlar ignores the unmarked." and the prompt stays off.

Bought cryptids are stored with `source = "pedlar"`. If Bind at once is on, the server places the creature on the first empty unlocked pad. Otherwise it stays in inventory. There is still no inventory cap. Bind at once defaults off and is saved.

The Odds control draws the four columns from the same config the roll uses. The countdown is `nextRestockUnix - os.time()`, clamped at 0 until the server publishes the next window.

## Save

`dataVersion` is 4. A version 1, 2, or 3 document gains `shop = { lastRotationId = 0, boughtSlots = { false, false, false, false } }` and `settings.bindAtOnce = false`. Cash, cryptids, defences, and reduced motion are kept. The loaded table is not edited in place. A version 4 document with a broken shop or a non-boolean `bindAtOnce` is corrupt and is not written. Stock is never saved.

## How to test in Studio

1. `rojo build -o ProjectCryptid.rbxlx` and open the place. Turn on **Studio access to API services** when a rejoin should keep a purchase.
2. Play. Walk a lair road into town. The road meets a gap in the wall. The cobble is a step below the outer ground. The well sits on the origin. Eight districts ring it. Only the Pale Pedlar and the Skill Shrine show an E prompt.
3. In the Explorer, `Town.Reserved_TarotTable` and `Town.Reserved_GreatRift` are 24 × 24. The rift pit has a dim green ring. Nothing else in town is that green until the Pedlar restocks.
4. Before the rite is finished, the Pedlar prompt is hidden and the stall reads "The Pedlar ignores the unmarked." Skip the rite or finish step 8. The prompt appears. Open it. Four cards, a real countdown, and Odds. Each odds column adds to 100.
5. Buy a cage you can afford. The button becomes "Sold to you". Buy it again. Cash does not move. Turn on Bind at once and buy a different cage: it stands on the first empty pad. With the toggle off, the next purchase stays in inventory.
6. Leave and rejoin in the same five-minute window. The same slot stays sold. Start a second server (or wait until the countdown hits 0:00). The cards change together, and the lantern above the stall goes green for about ten seconds.
7. The Skill Shrine opens a small panel that says the carving is blank. Close it. Shuttered stalls do nothing. The slot to the right of Steady gaze is still empty.

## QA test mapping

| # | Test | Where it is proved |
| --- | --- | --- |
| 1 | Well at the origin, roads on the plot angles, districts at r = 75 | Lune `QA1`. Studio step 2. |
| 2 | Only the Pedlar and the shrine prompt | Lune `QA2`. Studio step 2 and step 7. |
| 3 | Reserved parts exist and are 24 × 24 | Lune `QA3` (name and size constant). Studio step 3 for the instances. |
| 4 | Same stock at the same time | Lune `QA4` (two generates, salt absent from client and shared). Studio step 6 with two servers. |
| 5 | Restock on the 300 second boundary, countdown 0:00 | Lune `QA5`. Studio step 6. |
| 6 | 100,000 rolls inside the odds tolerance | Lune `QA6`. |
| 7 | Price = base income × payback | Lune `QA7`. |
| 8 | Second buy in the same rotation does not charge | Lune `QA8`, including a migrate/rejoin. Studio step 5 and step 6. |
| 9 | Previous rotation id is refused | Lune `QA9` (the exact sentence). The server sets `PedlarNotice` from `ShopStock.refusal`. |
| 10 | Step before 8 cannot buy | Lune `QA10`. Studio step 4. |
| 11 | No MarketplaceService | Lune `QA11` over `src`. |
| 12 | Odds view sums to 100 | Lune `QA12`. The panel calls `ShopStock.oddsColumns`. Studio step 4. |
| 13 | No purple, rift green only in the two places, fog on | Lune `QA13`. Studio step 3. The live atmosphere is spec 03; the theme table still holds the playtest fog distances. |
| 14 | Shrine opens the skill-tree hook | Lune `QA14`. Studio step 7. The panel is a stub until spec 04. |

## Known gaps / stubs

- The Skill Shrine opens a themed panel and does nothing else. Spec 04 replaces that body.
- Lanternwright, Expedition Board, Bone Broker, and Grimoire Lectern are dressed and shuttered. They have no remotes.
- The Tarot Table and the Great Rift are empty footprints. The personal rift in each lair is unchanged.
- Higher-rarity species are placeholders (`uncommon_01` and so on) until the grimoire list exists.
- Common shop prices use the rarity table. Common incomes on the card still use the spec 01 species rates, so a Mothman Hatchling shows +$2/s and costs $180.
- No creature portraits. The card shows the sigil in the rarity colour.
- No wind, bell, crow, or moon assets.
- No inventory cap, so a full inventory cannot be rejected yet.
- A mythic offer is not announced server-wide.
- Ward Candles still cannot be bought.

## Open questions

- The stock RNG is a server-side xorshift, seeded with `rotationId + SALT`, shared by every server and by the Lune tests. It is not Roblox `Random`, because Lune cannot reproduce that generator and the odds test has to be the same code the server runs.
- `SALT` is 9031841. It is only in `ShopSalt` under ServerScriptService.
- The town atmosphere (density, color, decay, haze) follows spec 03 in the live place. Fog start, fog end, brightness, and exposure stay the playtest numbers. The theme table still stores atmosphere density 0.18 and haze 0.3 so spec 02's home-beam check keeps reading those fields.
- Town roads are 16 studs wide. The lair approach roads stay 14, from spec 02.
- The cobble is at y = −1 and the outer ground stays at y = 0, with a short ramp in each gate.
- Lamps use 18 posts so that every sixth one is exactly one in six. The radius is whatever makes the spacing 18 studs.
- Bind at once is a toggle inside the Pedlar panel, not a new HUD button. The rites slot stays empty.
- A buy does not re-check distance after the panel is open. The server still checks the slot, the rotation, the previous purchase, the price, the step, the rate limit, and the debounce.
- Placeholder display names say "Placeholder" so they are obvious until the grimoire replaces them.
- The shrine is available during the rite. The Pedlar is not.
