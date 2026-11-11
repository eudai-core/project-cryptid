# Spec 09 v3.1: Launch Roster (12 cryptids) + Full Monetisation Plan

> **Change note (v3, Wed 4 Nov 2026): EUDAI'S DECISION B.** At **12:57 UTC on 4 Nov** Eudai chose option B in their own words (in the Analytics Lead's chat; confirmed by Grok Bot). It **supersedes** the earlier paid-crate approval that v2 was built on:
> - **Tarot readings are EARN-ONLY. No paid crates, cases, readings or pulls exist anywhere in the game.** The **only** paid odds item is **Server Luck** (see below).
> - The old paid readings (Single / Three / Great Spread / Blood Reading) are **removed**. In their place: **Bound Rites**, fixed bundles whose **exact contents** (a named cryptid + a fixed Essence amount + a named cosmetic) are shown before payment (§9.5).
> - **Nothing paid is hidden.** Every purchase result is shown to the buyer. The old "paid pulls never announce / buyer-only paid reel" rules are gone because paid pulls no longer exist.
> - **Skip Animation** is **earnable** (40 earned cards, ~day 10 of F2P play in spec 11's pacing model, the Rebirth 5 window [A v3]) **and** purchasable (99 R$). **Auto-Open** and **Open x3** are passes (approved earlier per Grok Bot). All three work **only on earned readings** (§6, spec 10 v2 §6).
> - **Revenue shifts** to passes, cosmetics (new lair themes, auras, card backs), cash bundles and the **Moon Pass** (§9).
> - **Server Luck = Robux purchase, JANUARY only (not the launch build)** (Eudai's answer, option A, relayed by Grok Bot via the Analytics Lead, 4 Nov). It is a **paid probability modifier**, so it is a paid random item under Roblox policy and is **PolicyService-gated** (§6). It is the **only** paid random item.
> - The **policy gate is scoped to Server Luck only** (§6).
>
> **Grok Bot rulings recorded (4 Nov, final):** buyers of **server-wide boosts** are named in a server banner (e.g. "**{DisplayName} summoned a Blood Moon over Hollowmere!**"); **personal Robux purchases never announce**. Mythic sky: fires on **every free source** (free readings, wild catches, Rift belt, expeditions, free events). Nothing bought at a shop, with Robux or cash, counts as a free source. The Rift belt counts as a building, so its catches stay free sources; Pedlar buys don't. (v3.1) Look per [art/style-guide.md](../art/style-guide.md) v0.6 D34/D35: GoldBright with a Bone flare and a thin Rift-green core, Rift green ≤ 5% of the screen for 20 s (spec 10 v2 §10). Onboarding goal-3 silhouettes are **cut** (tier pips + text tease, spec 01 v2.1).
>
> **v3.1 audit fix (4 Nov, compliance audit (`compliance-audit-cash-random.md` §4; Grok Bot approved, 4 Nov; cash = paid currency)):** §4 Pedlar/belt policy reason rewritten (global UTC seed, timed restock, belt spawns independent of purchases, DevForum #29 = Medium risk [A]); odds buttons say "Details"; free-source wording aligned (§rulings, §11).

> **Spec 11 cross-spec edits (4 Nov, spec 11 v1 §11 (approved by Grok Bot as the design base, 4 Nov)):** §4 gains the **variant tables** (Spectral / Shadow, Update 1; readings row is earn-only, not "free = paid"); §11 points to spec 11 §12's launch cut; §12 adds "Robux never buys Ward Candles, Sigils or steal immunity, and never buys Essence except the fixed, capped amount in Bound Rites" (decision B wins over spec 11's blanket "never Essence"). Stealing stays **Update 3, fresh review then**.

> **Supersedes the v2 change note** (v2 was built on the earlier paid-crate approval, which decision B replaces). Kept from v2: the roster, launch odds, reading passes, Server Luck maths, Essence, the Bestiary NEW stamp, the Mythic sky and retention levers. **Overriding rule kept: no visual may imply a higher tier than the one rolled.**
>
> **v1 note kept (4 Nov):** all [A] assumptions are approved by the owner as starting values, to be tuned from playtest data. New v3 [A]s are marked **[A v3]** and are **not** yet approved.

**Owner:** Cryptid Growth Strategist · **Builder:** Cryptid Systems Architect · **Status:** Draft **v3** (Wed 4 Nov 2026, decision B). v2.2: gift inbox design §15. · **Due:** Mon 9 Nov · **Freeze:** Fri 13 Nov · **Launch:** Fri 20 Nov
**Companion:** [spec 10 v2](10-tarot-readings-and-reel.md) (earn-only readings, Fate Reel, charge-up, reading passes, Server Luck (paid, gated), Ritual Essence, Bestiary/NEW stamp, Mythic sky). **Builds on:** Specs 01–08, the design bible. **Roster status:** **PROVISIONAL (~70% sure)**.
**Paid random items: Server Luck only** (a server-wide probability modifier, January, PolicyService-gated, §6 and spec 10 v2 §5). No other Robux path, direct or through cash, bundles, passes or season tracks, ends in a random outcome.

> **[A]** = design assumption, not measured data. Comparable-game prices in §10 come from Roblox's public catalog data, read on 4 Nov 2026 (snapshots in `specs/research/`). Roblox rules are cited inline and in §18.

---

## 1. Goal
Earn well from players who want to pay, without ever making free players feel second-class:
- Sell **time, convenience, looks, generosity and surprise**. Never sell **rank** (the Tithe leaderboard) or **exclusive power**.
- Every price is fixed and visible, and **every paid item shows its exact, fixed contents before payment**. **Nothing random is ever sold** (decision B). Random things (readings, wild spawns, the Rift belt) are earned through play, and we still show their odds.
- Design bible rule: nothing pops up before **onboarding step 8 and 5:00 of play**, and there is never a timer, "only 2 left" or "expires" that isn't literally true.

## 2. Launch rarities
**4 rarities at launch** (fast-ship plan: "12 cryptids across 4 rarities"): Common, Uncommon, Rare, Epic. **Legendary and Mythic pools are empty** and ship in weekly updates (3–4 cryptids per update, per the plan's cut list).
- Payback times from spec 03 §4.3: Common 30 s, Uncommon 60 s, Rare 150 s, Epic 400 s.
- Rarity colours from spec 01 A2: Common `BoneDim`, Uncommon Moss `#5E7A4A`, Rare silver `#8C9AA3`, Epic `Blood` with `Bone` text.

## 3. Roster (12)

| # | Name | CryptidId | Rarity | Body type | Size H × L (studs) [A] | Income | Price (income × payback) | Status |
|---|---|---|---|---|---|---|---|---|
| 1 | Mothman Hatchling | `mothman_hatchling` | Common | winged | 4.6 × 3.6 (built v0.1) | $2/s | $60 | Spec 01 starter |
| 2 | Fresno Nightcrawler | `fresno_nightcrawler` | Common | biped | 6 × 3.3 | $3/s | $90 | Spec 01 |
| 3 | Hidebehind | `hidebehind` | Common | biped | 8 × 5 (incl. stump) | $4/s | $120 | Spec 01 |
| 4 | Hodag | `hodag` | Common | quadruped | 3 × 6 | $5/s | $150 | Spec 01 (wild tutorial) |
| 5 | Jackalope | `jackalope` | Uncommon | quadruped | 3 × 4 | $12/s | $720 | Proposed |
| 6 | Dover Demon | `dover_demon` | Uncommon | biped | 4 × 3 | $14/s | $840 | Proposed |
| 7 | Snallygaster | `snallygaster` | Uncommon | winged | 5 × 7 | $16/s | $960 | Proposed |
| 8 | Loveland Frogman | `loveland_frogman` | Uncommon | biped | 5 × 3 | $18/s | $1,080 | Proposed |
| 9 | Flatwoods Monster | `flatwoods_monster` | Rare | biped | 9 × 5 | $40/s | $6,000 | Proposed |
| 10 | Beast of Bray Road | `beast_of_bray_road` | Rare | quadruped | 6 × 7 | $50/s | $7,500 | Proposed |
| 11 | Jersey Devil | `jersey_devil` | Epic | winged | 8 × 7 | $150/s | $60,000 | Proposed |
| 12 | Loch Ness Serpent | `loch_ness_serpent` | Epic | serpent | 9 × 8 | $170/s | $68,000 | Proposed |

- **Sizes** follow the style guide caps (height ≤ 10; Commons ≤ 6 × 6 footprint; others ≤ 8 × 8). The Hodag's asset-list estimate (~8 long) is trimmed to **6** to fit the Common cap.
- **Incomes:** named Commons keep spec 01 values. Other rarities spread around the spec 03 base ($15 Uncommon avg, $45 Rare avg, $160 Epic avg). Within a rarity, higher income = slightly bigger, more complex model (style guide: "rarity = shape, not saturation").
- **Onboarding exceptions stay:** Fresno Nightcrawler $50 and Hidebehind $75 on the onboarding belt only (spec 01).
- **Folklore rule [A]:** American/British cryptid folklore only. Skip figures sacred to living Indigenous cultures (for example wendigo, skinwalker).
- Body-type mix: winged 3, biped 5, quadruped 3, serpent 1.

## 4. Odds per source (verified)
After rarity is rolled, species is **uniform within the rarity** (spec 03 §4.2). Verified with `specs/tools/verify_odds.py` (exact fractions): **every rarity table and every species table sums to exactly 100%.**

**Rift Fissure conveyor** (each player's lair belt, after onboarding; 1 spawn every **10 s**, each stays **30 s** [A]; cash price = §3 price)

| Rarity | Odds | Each species |
|---|---|---|
| Common | 72% | 18% |
| Uncommon | 24% | 6% |
| Rare | 3.6% | 1.8% |
| Epic | 0.4% | 0.2% |
| **Total** | **100%** | **100%** |

**Wild spawns** (behind each Wild Gate; 1 spawn every **45 s**, max **3** alive per player [A]; free to catch)

| Rarity | Odds | Each species |
|---|---|---|
| Common | 80% | 20% |
| Uncommon | 16.4% | 4.1% |
| Rare | 3.4% | 1.7% |
| Epic | 0.2% | 0.1% |
| **Total** | **100%** | **100%** |

**Pale Pedlar slots** (launch override of spec 03 §4.2, because Legendary/Mythic pools are empty; showing their old odds would be untrue)

| Rarity | Slot 1 Cheap Cage | Slot 2 Odd Cage | Slot 3 Rare Cage | Slot 4 Pedlar's Curio |
|---|---|---|---|---|
| Common | **100%** (25% each) | 0% | 0% | 0% |
| Uncommon | 0% | **75%** (18.75% each) | 0% | 0% |
| Rare | 0% | **25%** (12.5% each) | **80%** (40% each) | **70%** (35% each) |
| Epic | 0% | 0% | **20%** (10% each) | **30%** (15% each) |
| **Total** | 100% | 100% | 100% | 100% |

- Slot 4 was Epic 85 / Legendary 14 / Mythic 1. Now **Rare 70 / Epic 30**, so Epics stay a chase (about one Epic offer every ~10 min across slots 3–4) [A, from the pacing sim in spec 07].
- When Legendary/Mythic ship, this table gets a new version and the in-game Odds view updates the same day.

- **Why the Pedlar and Rift belt are not paid random items (v3.1):** cash is paid currency, so the reason is **not** the currency. Pedlar stock comes from a **global UTC seed** and **restocks on a fixed timer** (`floor(os.time()/300)`, spec 03); the Rift belt spawns on a fixed 10 s timer whose rolls **never depend on purchases** (no refill-on-buy, no faster respawn; spec 02 §3). You see the exact cryptid, variant and price before you pay, and buying never reveals, rerolls or brings forward what comes next. Both odds buttons say **"Details"**. Risk **Medium [A]**: Roblox staff said preview-before-buy is still a paid random item when "the only way to find out (or change) what comes next is to buy" ([DevForum #29](https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622/29)). So **never add** a cash-priced re-roll, restock skip, mystery cage, luck boost or tarot token. Roblox counts random items bought with "paid in-game currency" as paid random items ([policy](https://create.roblox.com/docs/production/monetization/paid-random-items)).


**Variants (Update 1, spec 11 §3.2; verified by `verify_odds.py`).** Rolled by the server **after** rarity and species, independently. Cosmetic only (same income). **Luck never changes variant odds.** Rift belt and Pedlar offers show the variant before you pay. The `mutation` field stores one of **Normal, Spectral, Gilded, Shadow, Moonlit** (spec 15 §6). This verified table keeps two non-Normal weights, on Spectral and Shadow. Gilded and Moonlit are legal values and do not have a separate percentage here.

| Source | Normal | Spectral | Shadow | Total |
|---|---|---|---|---|
| Wild spawns | 98.6% | 1% | 0.4% | **100%** |
| Rift belt | 99.3% | 0.5% | 0.2% | **100%** |
| Pedlar (every slot) | 99.3% | 0.5% | 0.2% | **100%** |
| Tarot readings (January, **earn-only**) | 99.3% | 0.5% | 0.2% | **100%** |
| Daily ladder, Starter Pack, Bound Rites, Essence crafts | 100% | 0% | 0% | **100%** (fixed) |
- Per species: multiply by the species odds (e.g. Shadow Jersey Devil from the Wilds = 0.1% × 0.4% = **0.0004%**).

---

## 5. Tarot readings: EARN-ONLY (POST-LAUNCH, January)
The Tarot Table (spec 03, SE plot) runs **readings**: the deck shuffles, 3 cards (or 1 or 10) slide out face down, and each card turns to reveal a cryptid (design bible §5). **Readings are earned through play only (decision B).** There is no Robux or cash price on any reading, token or deck. The paid side of the Tarot Table is the **Bound Rites** (§9.5): fixed bundles with exact contents and no odds.

**Why January, not launch:** the free path depends on Expeditions and events (January), the odds UI and reveal module are each a multi-day build, and the freeze is Fri 13 Nov. Readings also matter more once Legendary/Mythic cards exist, so the §5.1 tables get re-issued and re-verified with the January roster before anything ships.

### 5.1 Decks and odds (per card, launch roster)
Each card is rolled **independently** by the server. Within a rarity, species are equally likely. Verified by `specs/tools/verify_odds.py` (exact fractions). Roblox doesn't require odds for earned random rewards (§6), but **we show them anyway** (honesty).

**Pale Deck** (the everyday deck)

| Rarity | Per card | Each species |
|---|---|---|
| Common | 55% | 13.75% (Mothman Hatchling, Fresno Nightcrawler, Hidebehind, Hodag) |
| Uncommon | 35% | 8.75% (Jackalope, Dover Demon, Snallygaster, Loveland Frogman) |
| Rare | 9% | 4.5% (Flatwoods Monster, Beast of Bray Road) |
| Epic | 1% | 0.5% (Jersey Devil, Loch Ness Serpent) |
| **Total** | **100%** | **100%** |

**Blood Deck** (the rare deck; no Commons)

| Rarity | Per card | Each species |
|---|---|---|
| Uncommon | 50% | 12.5% |
| Rare | 40% | 20% |
| Epic | 10% | 5% |
| **Total** | **100%** | **100%** |

When **Server Luck** is active (§6, spec 10 v2 §5), the Pale Deck panel shows the **base and the boosted table side by side**, both summing to 100%, with the timer.

### 5.2 Transparent pity (shown on screen)
Pity on **earned** readings is not a paid item, so Roblox's disclosure rule doesn't strictly apply (§6, finding 3). We still explain it in numbers and keep the shown odds live.

| Deck | Rule (hard pity) | Pity card odds | Average Epic rate with pity | Chance a player reaches the pity card |
|---|---|---|---|---|
| Pale | The **40th** card in a row without an Epic is an Epic | Epic 100% (50% each) | **3.02%** | 67.6% |
| Blood | The **15th** card in a row without an Epic is an Epic | Epic 100% (50% each) | **12.59%** | 22.9% |

- One counter per deck. Counters never reset except on an Epic, and are kept through rebirth.
- **Live display:** the deck panel always shows "**Epic guaranteed within N cards**" plus a counter bar. When the next card is the pity card, the odds table itself switches to **Epic 100%**. In a 3- or 10-card reading containing the pity card, Details lists odds **card by card**.
- **Never sold:** pity skips, personal luck, rate-ups, tokens. The only odds item sold is **Server Luck** (server-wide, capped, PolicyService-gated; §6 and spec 10 v2 §5).

### 5.3 What replaced the old paid readings
The v2 dev products (Single Card 35, Reading of Three 99, Great Spread 299, Blood Reading 299) are **removed** (decision B). Their price slots are taken by the **Bound Rites** (§9.5): a named cryptid + a fixed Essence amount + a named cosmetic, contents shown before payment, nothing random, no odds needed.

### 5.4 Free-earn routes (every deck)
Free cards are stored as **Pale Card / Blood Card tokens**. Tokens are **never sold** for Robux or cash and are **never inside any paid bundle, pack, Bound Rite, Satchel or Moon Pass paid track**: Roblox counts a bundle that contains a random item as a paid random item ([Community Standards](https://about.roblox.com/community-standards)).

**Route hygiene (v3) [A v3]:** Roblox's FAQ says earned random items are out of scope when they can "only be opened through gameplay or earned currency" (§6). Our cash is **also sold** for Robux, so no token is ever granted **for spending cash**. Routes key off **Tithe** (play-earned only, spec 07), free wild catches, the Bestiary, time played or free events.

| Route | Pale cards | Blood cards | When |
|---|---|---|---|
| Bestiary milestones 25 / 50 / 75 / 100% (spec 10 v2 §8) | 3 at 50% | 3 at 100% | One-time (plus titles and Essence) |
| Tithe milestones: $100K / $1M / $10M / $100M | 3 each (12 total) | – | One-time |
| **Rebirth Tithe gates** (v3: granted when lifetime **Tithe** crosses each rebirth tier's Tithe gate, e.g. $5M for tier 1, **not** for spending the $5M cash) | – | 3 | Per tier gate |
| Weekly Moon Rite: bind **30 wild cryptids** in a UTC week (v3: wild catches only, which are free; resets Mon 00:00 UTC) [A] | 3 | – | Weekly |
| Moon Vigil (§9.4): play any 3 of 7 days | 3 | – | Weekly |
| ~~Expedition returns~~ | **Removed v3**: Instant Expedition Return (§8) is paid, so expeditions carry no tokens | – | – |
| Event tracks and the free Moon Pass track (post-launch) | 3–10 per event [A] | 3 per event [A] | Per event |
| **Never** | – | – | The daily ladder stays fixed and non-random (spec 06) |

**Rough free rate [A v3]:** with spec 11's pacing-sim medians (`tools/pacing_sim_output.txt`, 2 × 20 min/day; model output) and these routes, a F2P player has **~24 earned cards by day 3, ~36 by day 7, ~42 by day 10, ~45 by day 14**, then **~6 a week** (Moon Rite + Vigil) plus later rebirth Tithe gates. Worked in `tools/skip_unlock_math.py`. Removing expedition tokens costs ~1 card a week.

### 5.5 Honest reveal
- The **server rolls every card before any animation starts**. The animation only shows what was already decided.
- **Each card is revealed by the Fate Reel** and charge-up (spec 10 v2 §3–§4). **Every reel is a free pull**, so near-miss emphasis follows the free-pull rules only: it plays only when a **real** W±1 neighbour is higher than the winner and in the deck's band (Pale Rare+, Blood Epic). No "almost" copy; the charge-up never shows a colour above the true tier. **Overriding rule: no visual may imply a higher tier than the one rolled.**
- Unowned species show in the Grimoire as **tier pips + a text tease** (e.g. "●●● Rare · *Something tall hums in the Flatwoods.*"), never as the "almost" result of a reading. (v3: silhouettes are cut, matching spec 01 v2.1.)
- Skipping: free players skip **seen** species; **Skip Animation** (earnable or 99 R$, spec 10 v2 §6) skips everything.
- **Readings are silent:** they play only for the reader; no server banner or chat line (spec 08 v2.2).

### 5.6 Duplicates
- Every card is a **real cryptid** added to your inventory, including duplicates. A duplicate can earn on another pad, so no outcome is worthless.
- **Ritual Essence:** each duplicate from a reading also gives Essence (Common 1 / Uncommon 3 / Rare 10 / Epic 40), spent on **chosen-species** crafts and cosmetics only (spec 10 v2 §7). Pity and Essence are separate and never reset each other.
- **Satchel full:** the reveal says "**Your satchel is full: +$60,000**" and grants **100% of the §3 price** in cash instead, shown before the card is dismissed.

## 6. POLICY GATE (scope: Server Luck only)
Re-verified **4 Nov 2026** against official Roblox sources (links in §18). Under decision B **the only paid random item in the game is Server Luck** (a probability modifier, spec 10 v2 §5, Eudai chose paid, option A). Everything else sold is fixed and shown before payment, so it needs no odds and no gate.

### 6.1 What Roblox says (exact wording)
1. **Definition, incl. luck boosts.** "Due to regulations in various countries, certain requirements may apply to random items purchased directly or indirectly with Robux. This includes random items purchased with paid in-game currency." The item types listed include "**Probability modifier items** | Luck boosts Pity systems Enhanced resource drops Rate-up scrolls". ([Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items))
2. **Odds-modifier disclosure.** "Paid items that augment the odds of other random outcomes must also be explained before purchase … these impacts must be numerically explained. The new odds of the enhanced random items must also be dynamically updated when these items are active to show the user's true odds." (same page)
3. **Earned random rewards are exempt.** "If your game offers randomized virtual rewards in exchange for completing an action that does not involve the payment of Robux or other in-game currency, you aren't required to disclose the odds." (same page). DevForum FAQ: "Does this apply if my randomized items are only earned, not paid? **No.** If players cannot purchase (directly or indirectly) the random outcome, for example, a chest you earn through gameplay that can only be opened through gameplay or earned currency, it is not a Paid Random Item and is not subject to this policy." ([DevForum, 26 May 2026](https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622))
4. **Bundles.** "Bundling several items including a random item into a single paid 'pack' or single transaction would still make the entire bundle a paid random item." ([Community Standards](https://about.roblox.com/community-standards))
5. **Every outcome must give some benefit** ("there cannot be a possible outcome which results in the user simply losing their payment", Community Standards).
6. **PolicyService.** "use the PolicyService:GetPolicyInfoForPlayerAsync() method … the returned dictionary includes ArePaidRandomItemsRestricted and IsPaidItemTradingAllowed." Ineligible users must get one of: an unpaid earnable path; a pre-determined disclosed order; direct guaranteed purchase; "Removing or hiding the paid random item from the game"; blocking with an error message; or removing the user from those parts of the game (paid random items page). The DevForum calls hide/alternative the clean path and post-click blocking "technically compliant". **`IsPaidItemTradingAllowed`**: "creators must not allow them to access the ability to trade the resulting outcome of a paid random item **or other paid items**." ([PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService))
7. Regulated markets to test with Studio's **Player Emulator**: Australia, Belgium, the Netherlands, **the United Kingdom** and Brazil; Roblox may change the list centrally (DevForum). Declare Server Luck in the **Content Maturity questionnaire** before it ships. **On the launch checklist as an Eudai step** (Grok Bot ruling, 4 Nov).

### 6.2 Findings for decision B
| # | Question | Finding | Status |
|---|---|---|---|
| F1 | Are **Skip Animation / Auto-Open / Open x3** (passes that speed up opening **earned** readings) paid random items? | **Probably not, but the docs don't say so directly.** None of the four listed types fits: they don't buy a random outcome (capsule), add a random effect (enhancement), combine items for a better chance (combination) or change odds (modifier). The FAQ test is whether players can "purchase (directly or indirectly) the random outcome"; with these passes they can't, because every card still needs an **earned** token, the passes add **no** cards and change **no** odds. **Ambiguity:** the FAQ example says a chest that "can only be opened through gameplay or earned currency"; a paid Auto-Open pass is arguably a paid way to *open*. Roblox doesn't address convenience passes on earned random items anywhere we found | **RESOLVED (Grok Bot ruling, 4 Nov): convenience, not paid random items**, because they act only on earned readings. Guardrails: passes never grant, refill or speed up earning tokens; never change odds; Open x3 only groups tokens you already have; Skip Animation is also **earnable** (spec 10 v2 §6). If Roblox says otherwise, the fallback is to gate the three passes behind `ArePaidRandomItemsRestricted` (hide for restricted players) |
| F2 | Do **pity / luck on earned readings** need disclosed odds? | **Pity on earned readings: no** (finding 3: earned rewards are exempt). **Paid Server Luck: yes**, because it is a paid probability modifier and it changes the odds of free readings, wild spawns and the Rift belt: its effect must be explained numerically before purchase and boosted odds updated live (finding 2) | We show base + boosted odds live for everyone who can see Server Luck (§6.3) |
| F3 | Do **Bound Rites** (named cryptid + fixed Essence + cosmetic) need a gate? | **No.** Nothing in them is random, so they aren't paid random items. Essence is spent only on **chosen-species** crafts (spec 10 v2 §7), so no Robux path ends in a random result. A craft that pays for a **tier** with a random species inside is **banned** (it would become a paid random item via paid Essence) | No gate |
| F4 | Blood Moon, cash bundles, passes, Satchels, Moon Pass paid track, Instant Expedition Return | Fixed, non-random, shown before purchase (Moon Pass paid track holds **no tokens**; expedition loot is rolled free and shown at send-off) | No gate |
| F5 | Trading | Not at launch. **If** trading ever ships, `IsPaidItemTradingAllowed` applies to "other paid items" too (Bound Rite cryptids, Satchel items) | Wrapper reused then |

### 6.3 Server Luck gate (our implementation)
| Rule | Spec |
|---|---|
| Policy call | On join, server-side, `PolicyService:GetPolicyInfoForPlayerAsync(player)` in `pcall`, up to **3 tries** (1 s, 2 s, 4 s backoff), 0–2 s join jitter. Cached in server memory for the session (never saved: region and age can change) |
| **Fail closed** | Until a call **succeeds** and says `ArePaidRandomItemsRestricted == false`, the player is treated as **restricted**. If all 3 tries fail, one retry runs when the player next opens a panel that would show Server Luck |
| Restricted players **never see** it | No Server Luck product card, button, prompt, price, buy link, HUD "buy" affordance, Relics entry or proactive card. Never shown-then-blocked |
| **Do restricted players benefit from someone else's boost? (conservative decision) [A v3]** | **No.** Their own Rift-belt, wild-spawn and reading rolls stay at **×1**; their odds panels show the **base** tables only; they **don't see** the Luck HUD chip or the buyer banner/chat line (both would advertise, or misstate, a paid odds boost). Roblox doesn't address this case directly; this is the reading least likely to expose a restricted user to a paid random mechanic. Event luck (Rift Tide, free) **does** apply to them |
| Server checks twice | Before `PromptProductPurchase`, and again inside `ProcessReceipt` |
| Off-site sales | Server Luck dev products are **never "Listed"** (listed products can be bought from the experience page, homepage and search outside the game, [Developer products](https://create.roblox.com/docs/production/monetization/developer-products)) |
| Restricted receipt edge case | If a Server Luck receipt still arrives for a restricted buyer (policy changed mid-session): **don't start the boost**; grant a fixed, non-random cash equivalent (a Chest bundle, §8) and log it. Shown: "Server Luck isn't available for you. We've added a Chest of cash instead." |
| Becomes restricted mid-session | Hide Server Luck at once; their rolls drop to ×1 from the next roll; chip hidden |
| Disclosure before purchase | The Server Luck card shows, **for each affected table**, base vs boosted odds at the **next** step (e.g. Pale 55/35/9/1 → 45/35/18/2), the duration added, the cap, and "**Details**" for every species %. Both tables sum to exactly 100% (`verify_odds.py`) |
| Live while active | Every affected odds panel (Pale Deck, Rift belt Details, Wilds odds) shows **base and boosted** tables side by side, "Server Luck ×2.5 · 14:32 left", updating every second; reverts within 1 s of expiry |

### 6.4 What still needs PolicyService
Only **paid Server Luck** (now) and **trading** (if it ever ships). Nothing else in launch, Update 1 or January needs it. Keep the wrapper as a small shared module; build it with Server Luck in January (launch keeps only the skeleton).

## 7. Game passes (one-time, permanent)
**Global rules for every paid item:** no prompt, shop pop-up or paid-item card before onboarding **step 8 and 5:00 of play** (spec 01 B8). Never on the welcome-back screen, daily panel, rebirth confirm, during a catch or reveal. At most **one** proactive info card per session. Buttons use Roblox's recommended wording: "**See Price**", "**View Item**", "**Open Shop**" ([Monetization](https://create.roblox.com/docs/production/monetization)).

| Pass | Price (proposed) | What it does | Where offered | Earliest prompt | Anti-dark-pattern note |
|---|---|---|---|---|---|
| **Auto-Collect** | **149 R$** | Offering Bowl income (spec 06 §5) banks every second wherever you are | Relics; one info card the first time you bank a bowl worth ≥ 60 s of income | Step 8 **and** 5:00 | Nothing is lost without it. **Cut from launch if the bowl isn't built** |
| **2x Cash** | **299 R$** | Cryptid income ×2, live and offline. Not daily rewards, bundles or **Tithe** | Relics only | Step 8 + 5:00 | Card shows your income now and with ×2 |
| **+2 Pads** | **199 R$** | Unlocks Pads 9–10. Kept through rebirth | Relics; pads 9–10 billboards "Relic pad · View Item" (tap opens the shop page, never an auto-prompt) | Step 8 + 5:00 | Free players reach 8 pads. Re-review before raiding ships |
| **Lair Cosmetics** | **99 R$** | Gilded and Bone Rite banners, Bone-wax candles | Relics, live lair preview | Step 8 + 5:00 | Looks only |
| **VIP Lair** | **299 R$** | Full lair set: carved obsidian gate, gold-veined pad rims, VIP chat tag "**[Keeper]**" in Gold, a Hollowmere VIP bench by the Weeping Well | Relics | Step 8 + 5:00 | **No income, luck or cash.** Comparable VIPs include currency or perks; ours is looks only, hence below their 375–480 R$ |
| **Sigil Nameplate** | **149 R$** | A gothic nameplate over your head (Bone text, Gold rim) plus a soft ember aura around your avatar (≤ 6 particles, particles not Neon) | Relics, avatar preview | Step 8 + 5:00 | Looks only |
| **Starter Pack** | **49 R$** | **$5,000** + 1 **Hidebehind**, once (owner decision, 4 Nov) | Top of Relics on first visit (design bible) | Step 8 + 5:00 | No timer, no "expires", available until owned. Not re-granted on rebirth |

### 7.1 Gifting passes (Update 1)
**What Roblox allows (verified 4 Nov):**
- There is **no native gift API for game passes**. The documented paths are passes for one-time items and **developer products** for repeatable purchases, with `ProcessReceipt` for grants ([Passes](https://create.roblox.com/docs/production/monetization/passes), [Developer products](https://create.roblox.com/docs/production/monetization/developer-products)).
- Top games sell "**[GIFT]**" developer products that mirror passes: Steal a Brainrot "[GIFT] 2x Money" 299 R$, Grow a Garden "[GIFT] Season Pass" 749 R$, Blox Fruits "[GIFT] 2x Money" 450 R$ (§10 sources).
- Since **29–30 May 2026**, games may not sell **another game's** passes or products ([DevForum: cross-game sales](https://devforum.roblox.com/t/disabling-cross-game-sales-of-passes-and-dev-products-and-introducing-the-transfers-api/4618396)). Gifting our own items in our own game is unaffected.

**Our gifting design:**
- Each pass gets a mirror dev product "**Gift: <pass>**" at the **same price**. Gifts are cosmetic and convenience passes only (incl. the January reading passes); never anything random. Bound Rites (§9.5) are not giftable at first [A v3] (one-time-per-account ownership checks; revisit later).
- The gift button opens a list of **players in this server** (no typed names). The server checks the recipient **doesn't already own** the pass, either as a pass or a gift, then prompts the buyer.
- Grant goes to the recipient's profile `giftedPasses[passKey] = {fromUserId, purchaseId}`. Ownership = `UserOwnsGamePassAsync` **or** `giftedPasses`.
- Recipient sees "**{DisplayName} gifted you 2x Cash.**" No custom message text (avoids text-filter needs).
- **Known risk [A]:** the real pass is still a normal Roblox pass, so a gifted player could buy it again from the experience page. We hide our own in-game buy button for gifted owners and note it in the pass description: "Already gifted? You own it in-game."

## 8. Developer products (repeatable)

| Product | Price (proposed) | Effect | Rules | Ships |
|---|---|---|---|---|
| **Cash bundles** | **25 / 99 / 249 / 499 R$** | Pouch: **10 min** of your current income · Coffer: **45 min** · Chest: **2 h** · **Vault: 5 h** | Minimums $2,000 / $10,000 / $30,000 / $75,000. Exact $ quoted in the card. Quote locked 5 min; server grants `max(quote, current calc)`. **Scales with income, so it never goes worthless.** Income uses the pre-2x-pass rate [A], so the 2x pass doesn't double bundles | **Launch** |
| **Lure Totem** | **49 R$** | For **20 min**, your wild spawns appear within **25 studs** of a totem planted at your Wild Gate, so no fog-wandering | **No change** to spawn interval (45 s), max alive (3) or odds: pure convenience, not a probability modifier. Buying again extends +20 min, max 60 min queued | Update 1 |
| **Server Blood Moon** | **199 R$** | The sky turns blood-red; **every lair in the server earns +50% cryptid income for 10 min** | See §8.1 | Update 1 |
| **Revive Streak** | **Not recommended** (if Eudai insists: 25 R$) | – | See §8.2 | – |
| **Instant Expedition Return** | **19 / 49 / 99 R$** for ≤ 30 min / ≤ 2 h / ≤ 8 h remaining | Your expedition returns now | **v3 (decision B):** expedition loot is rolled **free at send-off** and **shown on the expedition card at send-off** ("Returns with: Dover Demon + $4,200"), so paying only speeds up a result the player already sees: a known, non-random outcome. **Expeditions never carry tarot tokens** (that route moved to the Moon Vigil, §5.4), so Robux can't speed up getting a random item. Max **1 per expedition** and **3 per UTC day** [A v3], no pop-up (Roblox says "brought forward" timers are unpopular, [Monetization](https://create.roblox.com/docs/production/monetization)). No policy gate needed | **January** |

**Bundle best-value anchor (honest maths):** minutes of income per Robux = 10/25 = **0.40**, 45/99 = **0.45**, 120/249 = **0.48**, 300/499 = **0.60**. Only the Vault gets the label "**Most cash per Robux**", which is literally true. No "% bonus" or "was" prices ([Monetization](https://create.roblox.com/docs/production/monetization): discounts must be genuine).

### 8.1 Server Blood Moon (Update 1)

| Rule | Value |
|---|---|
| Effect | +50% cryptid income for **everyone** in the server (×1.5, multiplies with altar, skills, rebirth, 2x pass). **No** odds, spawn-rate or mutation changes |
| Duration | **10 min** (real server clock; HUD shows "Blood Moon · 7m 12s") |
| Buyer named | Server banner (spec 08 v2.2 §4b, Grok Bot ruling 4 Nov: server-wide boosts name the buyer): "**{DisplayName} summoned a Blood Moon over Hollowmere!**" Sub-line: "Every lair earns +50% for 10 minutes." No price, no Robux, no "buy one too" link |
| One at a time | Can't be bought while one is active. Button reads "The moon is already red · 7m left". **No stacking, no queue** |
| Cooldown | **5 min** server cooldown after it ends [A]. Button: "The sky is resting · 3m left" |
| Per buyer | Max **3 per UTC day** [A] (spend guard for a young audience) |
| Tithe | Blood Moon income **doesn't count** toward Tithe (leaderboard stays unbuyable) |
| Offline | Doesn't affect offline hauls |
| Server shutdown | Ends early; no partial refund possible (Roblox handles refunds). Copy says "for this server" |

Comparable: Steal a Brainrot sells server-wide **2x / 4x / 8x Server Luck** at **249 / 999 / 2,999 R$** (§10). Blood Moon stays **income only**: it changes no odds, so it is **not** a paid random item and needs no policy gate. Server Luck (spec 10 v2 §5) is a separate item and is gated as a paid random item; the two never mix.

### 8.2 Revive Streak: recommendation, don't build
Spec 06's ladder **never loses progress**: a missed day pauses it, so there is **nothing to revive**. Inventing a streak just to sell its repair would add the streak-loss pressure our research (loss aversion, design bible) and spec 06 rule out. Grow a Garden sells "Recover Daily Streak" at 99 R$ (§10), so the hook exists in the genre, but it's a pressure mechanic. **Counter-proposal:** none for launch. If Eudai wants it later, it would have to be a **cosmetic-only** "Vigil" candle count with **one free relight per week**, no reminders, and never shown on the daily panel. Not specced here.

## 9. First purchase, Season Pass, rotating bundles

### 9.1 First-purchase gift (Launch)
- The **first** Robux purchase of anything also grants the **Founder's Candle** (lair cosmetic: a black candle with a Gold flame on the altar). One-time, permanent, stated in the Relics header: "*Your first Relic also lights a Founder's Candle.*"
- No timer. Combined with the 49 R$ Starter Pack, that gives a low-friction first purchase. Comparables: Pet Simulator 99 Starter Pack 79 R$, Steal a Brainrot StarterPack 189 R$ (§10).

### 9.2 Moon Pass: season pass (POST-LAUNCH, January) — v3: main revenue line
Decision B moves revenue from paid readings to the Moon Pass, so it gets a **premium cosmetic track** and a clear, honest value.

| Part | Outline |
|---|---|
| Season | **4 weeks**, starts and ends Mon **00:00 UTC**, dates shown in full |
| Tracks | **Free track** 30 tiers + **paid track** 30 tiers |
| Price | **399 R$** [A] (Grow a Garden Season Pass 749 R$, §10; our audience is new, so lower). Gift mirror at the same price (Grow a Garden "[GIFT] Season Pass" 749) |
| XP | From play only: catches, daily claims, Moon Rite. **No XP or tier skips for sale** (Grow a Garden sells "Skip Season Pass Quests" 99 R$; we don't) |
| Free track | Income-scaled cash, Pale and Blood card **tokens** (free = fine), 1 cosmetic, 25 Essence |
| Paid track (v3, fixed list shown up front) | Per season: **1 lair theme piece set** (e.g. "Winter Moon" altar + pad rims), **1 avatar aura**, **1 card-back set**, **1 nameplate style**, a season title, income-scaled cash (≈ 5 h of income total across tiers), and **tier 30: a named, season-themed Rare variant skin** (cosmetic skin on an owned species; no income change). **No tokens, no random items, no Essence, no exclusive power** |
| Late buyers | Buying mid-season unlocks every paid tier already reached. Nothing missed is ever re-sold as "last chance"; past cosmetics may return in a later Satchel |
| Preview | The full paid track is browsable before purchase with "**View Item**" (Roblox wording) |

### 9.3 Pedlar's Satchel: rotating limited bundles (Update 1)
- **One** bundle on sale at a time, rotating **every Monday 00:00 UTC** on a published schedule. Countdown text is real: "*Leaves Mon 00:00 UTC (3d 4h)*" ([Monetization](https://create.roblox.com/docs/production/monetization): no inaccurate or restarting countdowns).
- Contents are **fixed and listed**: one cosmetic + income-scaled cash (e.g. "Bone Rite candle set + 1 h of your income"). Price **149–299 R$** [A].
- **No random items.** No "never again" unless it is truly retired. Bundles may return later, and the shop says so: "*Satchels may return in later moons.*"

### 9.4 Retention and revenue levers (inside Roblox policy)
| Lever | Design | Guardrail |
|---|---|---|
| **Streaks (positive only)** | **Moon Vigil:** play on any **3 of 7 days** in a UTC week (Mon 00:00 reset) → fixed weekly chest (1 h of income + 3 Pale tokens). Plus the existing 7-step Nightly Offering that **pauses** and never resets (spec 06 v2) | No consecutive-day demand, nothing to lose, **no paid streak repair**, no reminders |
| **Limited-time events on a real UTC calendar** | **Rift Tide:** every **Saturday 18:00–20:00 UTC** [A] (UK evening, US afternoon), free **event luck ×1.5** for everyone (free event luck, not a purchase; spec 10 v2 §5.3) + Moon Rite double progress. **Blood Moon Night:** first Friday of each month 19:00–21:00 UTC (free; mutation auras when Update 1 adds them). **Seasonal decks** (design bible: Blood Moon, Winter) with fixed start/end dates | The Expedition Board shows the next **7 days** of events. Countdowns are real (Roblox: no inaccurate or restarting timers, [Monetization](https://create.roblox.com/docs/production/monetization)). No "never again" claims |
| **Stacking boosts with caps** | Event luck stacks with any other luck source, **capped at ×3 total**. Blood Moon income **×2 total cap** for temporary income boosts. Paid Server Luck steps ×2 → ×2.5 → ×3 (spec 10 v2 §5) | Caps shown on the HUD chip ("Luck ×3 · max"). Every boosted table is live and sums to 100% |
| **Bulk opening during events** | Players **save earned tokens** for Rift Tide; Open x3 and Auto-Open pair naturally with its free luck. Event tracks hand out extra **free** tokens | Passes work on **earned tokens only**, add no cards and change no odds; Auto-Open has a visible Stop button |
| **Collection** | Bestiary milestones, NEW stamps, Essence crafts (spec 10 v2 §7–§8) | Crafts are all chosen-species (non-random). Essence appears in paid items only as a small fixed amount inside Bound Rites (§9.5) |
| **Cosmetic collection (new v3)** | Lair themes, avatar auras, card-back sets (§9.6) and the Moon Pass cosmetic track | Looks only; fixed contents; previews before purchase |

### 9.5 Bound Rites: fixed tarot bundles (January, replaces paid readings) — v3
The paid side of the Tarot Table. Each Rite has **fixed, listed contents**, shown in full before "See Price". **Nothing random, so no odds** and no policy gate (§6.2 F3).

| Rite | Exact contents | Price (APPROVED, MC 4 Nov) | Limit | Unlock |
|---|---|---|---|---|
| **Rite of the Hare** | **Jackalope** (Uncommon) + **30 Essence** + **Antler card back** (cosmetic) | **99 R$** | 1 per account | Step 8 + 5:00 (global rule) |
| **Rite of the Beast** | **Beast of Bray Road** (Rare) + **60 Essence** + **Bray Road lair banner** (cosmetic) | **249 R$** | 1 per account | Step 8 + 5:00 |
| **Rite of the Devil** | **Jersey Devil** (Epic) + **60 Essence** + **Horned nameplate frame** (cosmetic) | **499 R$** | 1 per account | After the **Rebirth 1** Tithe gate [A v3] (so an Epic can't spike day-1 income) |

- **Card copy:** "You get: Jackalope · 30 Essence · Antler card back. **Nothing random.**" A duplicate species is stated before purchase ("You own one; this adds another").
- **Essence and guaranteed pulls (resolved):** Rite Essence is a **fixed amount**. Essence is spent only on **chosen-species** crafts and cosmetics (spec 10 v2 §7.2), so the Robux path ends in a cryptid the player picked: **non-random**. A "guaranteed **tier** pull" (e.g. "a random Rare for 120 Essence") is **banned permanently**, because Rite Essence would make it a paid random item. Essence can never be turned into tokens or readings.
- **Spend-to-power cap:** paid Essence is capped at **150 per account for life** (Rites are one-time; the Moon Pass paid track and Satchels hold **no** Essence). That's enough for one chosen Rare (120), never a chosen Epic (400).
- Bound Rite cryptids are **not** "paid random items" and aren't tradeable (no trading). Rotating January roster species can be swapped into **new** Rites later; existing Rites keep their contents.
- **Not announced** (personal purchase; spec 08 v2.2).

### 9.6 Cosmetic lines (January) — v3 revenue shift
All looks only, previewed live before purchase ("View Item"), sold as passes (permanent), each with a same-price gift mirror.

| Line | Items | Price (APPROVED, MC 4 Nov) | Notes |
|---|---|---|---|
| **Lair themes** | **Drowned Chapel**, **Bone Orchard**, **Witch-Light Hollow**: altar, pad rims, gate, ground decals, ambient sound | **199 R$ each** | Respect the style guide readability floor; **no Neon** (only the two cryptid-eye exceptions exist, style guide D10/D13/D38); Rift green ≤ 2% (D35) |
| **Avatar auras** | **Grave-Candle** and **Will-o'-Wisp** (≤ 6 particles); **Gilded Halo** (GoldBright, style guide D28) | **79 / 79 / 299 R$** | One aura equipped at a time (the Sigil Nameplate ember counts as an aura) |
| **Card-back sets** | 4 card backs per set for your readings (e.g. "Moth & Moon") | **49 R$ per set** | Separate from the Essence-crafted Gilded backs |

## 10. PRICE TABLE (v3.1, decision B)
> **APPROVED (Master Controller, 4 Nov 2026)**, relayed by Grok Bot as Eudai's delegation of Cryptid approvals: **launch lines 1–11**, **Update 1 lines 12–16** (incl. Blood Moon gift 199) and **January lines 17–24 and 26–30** (Bound Rites 99/249/499, lair themes, auras, card backs, Instant Expedition Return, Moon Pass 399, Skip 99, Auto-Open 149, Open x3 249, Server Luck 49/199). **Condition on lines 12–16:** the **Lure Totem (14)** and the **Satchel (16)** pass the cash-random compliance audit (`compliance-audit-cash-random.md`): deterministic or PolicyService-gated if they touch spawn or rarity odds. Line 25 (Revive Streak) is not recommended. **Account-only steps stay with Eudai** via Grok Bot: creating products, entering live prices, publishing, and the Content Maturity questionnaire. Bot 3 creates products only after that. Server Luck (lines 29–30) also needs the cash-random compliance audit closed first.
**Nothing here is created or priced live.** **v3 changes:** launch lines 1–11 **unchanged**; Update 1 lines 12–16 unchanged in price (line 13 now also covers the January reading passes; line 15 banner copy updated); **January lines rewritten**: paid readings (old 17–20) **removed**, Bound Rites, lair themes, auras and card backs **added**, Instant Expedition Return rules tightened, Server Luck kept as the **only paid random item** (Eudai option A, PolicyService-gated), Skip Animation also **earnable**. Prices are base Robux prices. Roblox's managed pricing and price optimisation can show players different regional prices ([Monetization](https://create.roblox.com/docs/production/monetization)), so these numbers are our starting base.

| # | Item | Type | **R$** (status above) | Ships | Comparables (verified 4 Nov 2026) | Why this price |
|---|---|---|---|---|---|---|
| 1 | Starter Pack ($5,000 + Hidebehind) | Pass (one-time) | **49** | **LAUNCH** | PS99 Starter Pack 79; Adopt Me Starter Pack 89; Grow a Garden Starter Pack 99; Steal a Brainrot StarterPack 189 | **Keep 49.** Below every comparable, so it's an easy first purchase for a new game |
| 2 | Lair Cosmetics | Pass | **99** | **LAUNCH** | No like-for-like cosmetic pass verified | **Keep 99** [A]; can't verify a direct comparable |
| 3 | Auto-Collect | Pass | **149** | **LAUNCH** (only if the bowl is built) | PS99 Auto Farm 175, Auto Tap 350 | **Keep 149.** Just under PS99's 175; our bowl is a smaller convenience |
| 4 | Sigil Nameplate + ember aura | Pass | **149** | **LAUNCH** (first cut if late) | VIP passes that include a chat tag: PS99 400, SAB 375, Adopt Me 480 (all also add perks). No tag-only pass verified | [A] Tag + aura alone is less than a VIP |
| 5 | +2 Pads | Pass | **199** | **LAUNCH** | Adopt Me +1 Pet Pen Slot 295; PS99 +15 Pets 375 | **Keep 199.** Cheaper than comparables, but it is our strongest power pass, so keep it modest |
| 6 | 2x Cash | Pass | **299** | **LAUNCH** | Steal a Brainrot 2x Money 299; Blox Fruits 2x Money 450 | **Keep 299.** Matches the closest genre twin (SAB) |
| 7 | Cash: Pouch (10 min income, min $2k) | Dev product | **25** | **LAUNCH** | SAB Cash Pack #1 59 | **Keep 25.** A tiny entry tier |
| 8 | Cash: Coffer (45 min, min $10k) | Dev product | **99** | **LAUNCH** | SAB Cash Pack #2 379 | **Keep 99** |
| 9 | Cash: Chest (2 h, min $30k) | Dev product | **249** | **LAUNCH** | SAB Cash Pack #3 659 | **Keep 249** |
| 10 | Cash: **Vault** (5 h, min $75k) "Most cash per Robux" | Dev product | **499** | **LAUNCH (new)** | SAB Cash Packs run to 1,249 and 2,499 | **New anchor tier.** SAB shows a top-tier ladder is normal; 0.60 min/R$ vs 0.40–0.48 is an honest best value |
| 11 | Founder's Candle | Free gift with 1st purchase | **0** | **LAUNCH** | – | Rewards the first purchase without a timer |
| 12 | VIP Lair (cosmetic set + [Keeper] tag) | Pass | **299** | Update 1 | VIP: SAB 375, PS99 400, Adopt Me 480 | Below comparables because ours has no power |
| 13 | Gift: <any pass> | Dev product | **Same as the pass** | Update 1 | SAB [GIFT] 2x Money 299 (= pass); Blox Fruits [GIFT] 2x Money 450 (= pass) | Same-price mirrors are the genre norm |
| 14 | Lure Totem (20 min) | Dev product | **49** | Update 1 | No verified comparable | [A] Unverifiable; a small convenience, so priced small |
| 15 | Server Blood Moon (10 min, +50% income, all players) | Dev product | **199** | Update 1 | SAB 2x Server Luck 249, 4x 999, 8x 2,999 | Below SAB's entry tier: income only, not luck |
| 16 | Pedlar's Satchel (weekly rotating bundle) | Dev product | **149–299** per bundle | Update 1 | No verified comparable for rotating cosmetic bundles | [A] Set per bundle at approval time |
| 17 | **Bound Rite: Rite of the Hare** (Jackalope + 30 Essence + Antler card back) | Dev product (fixed, 1 per account) | **99** | **January (new v3)** | PS99 Starter Pack! 79; Adopt Me Royal Butterfly Bundle 70; GaG Starter Pack 99 | Entry bundle; replaces the 35/99 paid readings |
| 18 | **Bound Rite: Rite of the Beast** (Beast of Bray Road + 60 Essence + Bray Road banner) | Dev product (fixed, 1 per account) | **249** | **January (new v3)** | PS99 Massive Potion Bundle! 250; PS99 Starter Diamond Pack! 240 | Mid bundle |
| 19 | **Bound Rite: Rite of the Devil** (Jersey Devil + 60 Essence + Horned nameplate frame; after Rebirth 1) | Dev product (fixed, 1 per account) | **499** | **January (new v3)** | PS99 Expert Starter Pack! 399; Bee Swarm Beginner's Bean Bundle 400; GaG Blacksmith Bundle 375; GaG Beach Bundle 699 | Top bundle; replaces the 299 Great Spread / Blood Reading |
| 20 | **Lair theme** ×3 (Drowned Chapel, Bone Orchard, Witch-Light Hollow) | Pass each | **199 each** | **January (new v3)** | Adopt Me Premium Plots 285; GaG Blacksmith Bundle 375 | Looks only, so below plot/bundle comparables |
| 21 | **Avatar aura**: Grave-Candle / Will-o'-Wisp / Gilded Halo | Pass each | **79 / 79 / 299** | **January (new v3)** | Blox Fruits Aura "Yellow Sunshine" etc. 88; Aura "Snow White" etc. 350 | Mirrors Blox Fruits' two aura tiers, slightly lower |
| 22 | **Card-back set** (4 backs) | Pass each | **49** | **January (new v3)** | GaG Rake Cosmetic 29; Blox Fruits Aura 88 | Small cosmetic impulse item |
| 23 | Instant Expedition Return | Dev product | **19 / 49 / 99** | **January** (rules changed v3) | SAB Skip Timer eggs 19/49/99/199; GaG Skip Harvest Moon Offering 39 | Loot shown at send-off; no tokens in expeditions; 3/day |
| 24 | Moon Pass (paid track, premium cosmetic track v3) | Dev product, per season | **399** | **January** | Grow a Garden Season Pass 749 (+ [GIFT] Season Pass 749) | [A] Lower for a newer game; now the main recurring line |
| 25 | Revive Streak | – | **Not recommended** (25 if forced) | – | Grow a Garden Recover Daily Streak 99 | No streak exists to lose (§8.2) |
| 26 | Reading pass: **Skip Animation** (also **earnable**: 40 earned cards, ~day 10 F2P [A], spec 10 v2 §6.1) | Pass | **99** | **January** | No verified comparable (unverifiable) | [A] Small convenience; also a real free goal |
| 27 | Reading pass: **Auto-Open** (earned tokens only, Stop button) | Pass | **149** | **January** | PS99 Auto Farm! 175, Auto Tap! 350 | Automation priced under PS99's cheapest |
| 28 | Reading pass: **Open x3** (earned tokens only) | Pass | **249** | **January** | PS99 "+15 Eggs!" 625 | Smaller step (3 at once), so far cheaper |
| 29 | Server Luck: **first buy** (once per account; **January, not launch**) | Dev product (**paid random: probability modifier**, PolicyService-gated, unlisted) | **49** | **January** | SAB 2x Server Luck 249 | Honest first-purchase price, not a fake sale |
| 30 | Server Luck (standard, **January, not launch**; stacks ×2 → ×2.5 → ×3, +10 min each, 60 min cap) | Dev product (**paid random**, gated, unlisted) | **199** | **January** | SAB 2x Server Luck 249, 4x 999, 8x 2,999 | Below SAB; smaller, capped steps |
| – | ~~Tarot: Single Card 35 / Reading of Three 99 / Great Spread 299 / Blood Reading 299~~ | – | **Removed** | – | – | Decision B: readings are earn-only |

**Comparable sources** (public Roblox catalog APIs, unauthenticated, read Wed 4 Nov 2026 ~00:30 GMT; raw snapshots saved in `specs/research/gamepasses-snapshot-2026-11-04.json` and `devproducts-snapshot-2026-11-04.json`):
- Game passes: `https://apis.roblox.com/game-passes/v1/universes/{universeId}/game-passes?passView=Full&pageSize=100`. Pass pages: [SAB 2x Money](https://www.roblox.com/game-pass/1228591447) · [SAB VIP](https://www.roblox.com/game-pass/1229510262) · [Blox Fruits 2x Money](https://www.roblox.com/game-pass/6028662) · [PS99 Auto Farm](https://www.roblox.com/game-pass/265320491) · [PS99 Auto Tap](https://www.roblox.com/game-pass/265324265) · [PS99 VIP](https://www.roblox.com/game-pass/257811346) · [PS99 +15 Pets](https://www.roblox.com/game-pass/259437976) · [Adopt Me VIP](https://www.roblox.com/game-pass/3196348) · [Adopt Me +1 Pet Pen Slot](https://www.roblox.com/game-pass/1585546290).
- Developer products: `https://apis.roblox.com/developer-products/v2/universes/{universeId}/developerproducts?limit=50`. Universe ids: Steal a Brainrot 7709344486, Grow a Garden 7436755782, Pet Simulator 99 3317771874, Adopt Me 383310974, Blox Fruits 994732206, Bee Swarm 601130232.
- **Caveats:** a listed developer product proves the price, not that it is shown in-game today. **Bundle comparables (v3):** the snapshot gives name and price only, not contents; some comparable bundles may include random items or currency, so they anchor the **price band**, not the value. Bee Swarm's and Grow a Garden's game passes are **not for sale**, so their prices are **unverifiable**. No revenue or conversion data for any game was available; **no benchmark conversion numbers are claimed**.

## 11. LAUNCH vs POST-LAUNCH

| Item | Tag | Build size [A] | Freeze risk (Fri 13 Nov) |
|---|---|---|---|
| 2x Cash, +2 Pads, Lair Cosmetics, Starter Pack | **LAUNCH** | Small (v1 scope) | Low |
| Auto-Collect | **LAUNCH, conditional** | Depends on the spec 06 Offering Bowl | **Cut if the bowl isn't built by Wed 11 Nov** |
| Cash bundles ×4 incl. Vault | **LAUNCH** | Small (one more config row) | Low |
| ProcessReceipt ledger + DataStore save | **LAUNCH** (required for bundles) | Medium | Must-have; build first |
| Founder's Candle | **LAUNCH** | Small | Low |
| Relics gold pip (§13.2) | **LAUNCH** | Small | Low |
| Sigil Nameplate | **LAUNCH** | Small (BillboardGui + 1 emitter) | **First cut** if the week is tight |
| VIP Lair | Update 1 | Medium (art set) | Too big for the freeze |
| Gifting mirrors | Update 1 | Medium (cross-profile grant) | **Too big** for the freeze |
| Server Blood Moon (+ spec 08 banner) | Update 1 | Medium (sky + server multiplier) | Too big for the freeze |
| Lure Totem | Update 1 | Small–medium | Not needed at launch |
| Pedlar's Satchel rotation | Update 1 | Medium (UTC schedule + config) | Not needed at launch |
| **Tarot readings (earn-only)**, pity, odds panels, tokens | **January** | **Large** (ritual, odds UI, tokens) | **Far too big**. Design bible also puts it in January. No paid readings exist (decision B) |
| Instant Expedition Return | January | Small, but needs Expeditions | Depends on Expeditions |
| Moon Pass season | Post-launch | Large | Far too big |
| **Spec 11 launch cut** (approved): rebirth tiers 1–7 + Tithe gate + pad × 1.5^r, Bone Altar III–X, Tithe excludes Relic pads, contested catch rule, remote rate limits (LAUNCH); plot likes (stretch); variants, mastery, Hunt board, races (Update 1); Rebirth 8–10, Ring 2 (Update 2); Echo theft (**Update 3, fresh review then**); Essence sinks (January) | See spec 11 §12 | – | Nothing in it is sold; no price changes here |
| PolicyService wrapper | **LAUNCH (skeleton)**; full in January | Small | Nothing is gated at launch. In January it gates **Server Luck** (the only paid random item); also `IsPaidItemTradingAllowed` if trading ever ships (§6) |
| **NEW stamp + Bestiary record + titles** (spec 10 §8) | **LAUNCH (stretch)** | Small–medium (~1–2 days [A]) | Fits only if the Grimoire/Bestiary panel already exists; otherwise Update 1. Essence/token rewards are banked until January |
| Fate Reel + charge-up + reel QA tool (spec 10 §3–§4) | **January** | Medium–large | Far too big; ships with readings |
| Reading passes (Skip, Auto-Open, Open x3) | **January** | Small each | Ships with readings |
| Server Luck + live base/boosted odds + policy gate | **January — NOT in the launch build** | Medium | Needs the wrapper + odds panels; ships with the Tarot Table |
| Skip Animation earn path (counter + unlock) | **January** | Small | Ships with readings |
| **Bound Rites ×3** (§9.5) | **January** | Small (fixed grants + preview) | Ships with the Tarot Table |
| Lair themes, auras, card-back sets (§9.6) | **January** (themes may slip to Feb) | Medium (art) | Art Director capacity |
| Ritual Essence + crafts | **January** | Medium | Ships with readings |
| Rift Tide / Moon Vigil events calendar | Update 1–2 | Medium | Not needed for launch |
| Mythic server sky (**every free source**: free readings, wild catches, Rift belt (a building), expeditions; not Pedlar buys; GoldBright + Bone flare + thin Rift core, ≤ 5% Rift for 20 s; style guide v0.6 D34/D35; spec 10 v2 §10) | **January** | Small–medium | Needs Mythics (January) |

## 12. F2P rules and spend-to-power caps
**Never sold, ever:**
- **Tithe** (the leaderboard number). Tithe counts only cryptid income earned by play. It excludes bundles, the 2x pass, Blood Moon, daily rewards and the Starter Pack $5,000.
- **Any cryptid you can't also earn free.** Every species is in the Rift, Wilds, Pedlar and tarot free paths. Bound Rites sell **named** cryptids that are all earnable free.
- **Anything random**, directly or indirectly (decision B): no readings, tokens, mystery items, re-rolls or random crafts for Robux or for cash.
- **Personal odds or luck**, pity skips, rate-ups. (The only odds product is **Server Luck**: server-wide, capped, PolicyService-gated, spec 10 v2 §5.) Also skill nodes, respecs, rebirth, the daily ladder or its days, and **Ritual Essence on its own** (it appears only as a small fixed amount inside Bound Rites, §9.5).
- **Free tarot tokens.**

**Spend-to-power caps:**
| Cap | Rule |
|---|---|
| Rebirth | Every tier needs its cash cost **AND** its Tithe gate (spec 07 v3: $5M, $20M, then 0.75 × the sum of costs), so bought cash can't skip a rebirth. Tithe excludes 2x Cash, Blood Moon, bundles, daily rewards and **Relic pads 9–10** |
| Never sold (spec 11) | Robux never buys **Ward Candles, Ash Sigils or steal immunity** (Update 3+ systems), and never buys **Essence** except the fixed amounts inside Bound Rites (lifetime cap 150, decision B) |
| Bundles | Grant **time-of-income**, not fixed piles, so they never jump a player past content their income couldn't reach in ≤ 5 h |
| Power passes | 2x Cash and +2 Pads are the only power passes (both ≤ 299 R$); every other pass is looks |
| Blood Moon | Shared with **everyone** in the server; never only the buyer |
| Readings | **Earn-only.** Bound Rites sell named cryptids, max one of each per account; the Epic Rite unlocks only after Rebirth 1 |
| Luck | Server-wide only, ×3 total cap (paid × free event), 60 min max, 5 buys per buyer per UTC day; never sold to restricted players and never applied to their rolls (§6.3) |
| Temporary income boosts | Combined cap **×2** (Blood Moon ×1.5 with any future event boost) [A] |
| Young-audience guards | Max 3 Blood Moons per buyer per UTC day. Relics spend summary per session. No prompts before step 8 + 5:00. At most 1 proactive card per session |

## 13. UI text and the Relics gold pip

### 13.1 Copy (palette from spec 01 A2)
| Where | Text | Colours |
|---|---|---|
| Relics button | "Relics" | Gold `#C9A55A` on Panel |
| Relics header | "Relics of the Hollow" / "*Your first Relic also lights a Founder's Candle.*" | Gold / BoneDim |
| Pass card | "2x Cash · Your cryptids earn double. Now $340/s → $680/s." | Bone text, Gold price |
| Bundle card | "Vault · 5 h of your income · $306,000 · Most cash per Robux" | Bone; tag Gold |
| Buttons | "See Price" · "View Item" · "Open Shop" | Panel, Gold rim |
| Owned | "Owned" (no button) | Moss `#5E7A4A` |
| Tarot deck header | "Pale Deck · Odds per card" + table + "**Details**" (shown for honesty; readings are earned) | Bone / BoneDim |
| Bound Rite card | "Rite of the Hare · You get: Jackalope · 30 Essence · Antler card back. Nothing random." | Bone; "Nothing random." BoneDim |
| Pity bar | "Epic guaranteed within 12 cards" / "Next card: Epic 100%" | Blood bar on Panel |
| Tarot Table footer | "*Readings here are earned through play.*" (everyone, not just restricted players) | BoneDim |
| Spend summary (Relics footer) | "This session: 2 Relics · 198 R$" | BoneDim |
| Blood Moon HUD | "Blood Moon · 7m 12s" / "The sky is resting · 3m left" | Blood / BoneDim |
| Gift toast | "{DisplayName} gifted you 2x Cash." | Gold |
| Satchel | "Leaves Mon 00:00 UTC (3d 4h) · Satchels may return in later moons." | Bone / BoneDim |

**Banned words anywhere:** "FREE!", "% OFF", "was", "Only X left", "Last chance", "Expires" (unless literally true), "Lucky", "Boost your odds".

### 13.2 Relics gold pip (LAUNCH)
- **Trigger:** the reveal of the player's **first Rare** (from any source) **finishes** (spec 08 Rare reveal 2.0 s).
- **Shows:** a **GoldBright `#C9A55A`** dot, 10 px, top-right of the Relics button, with a soft 1.5 s pulse ×2, then steady. Reduced Motion: no pulse.
- **No pop-up**, no sound, no text.
- **Clears** the moment Relics opens. **Never shows again** (one-time per account, survives rebirth).
- If onboarding step 8 + 5:00 haven't happened yet, the pip waits until they have (it's still a shop nudge).

## 14. Data to save (player profile, one DataStore key per player, session-locked)
| Key | Type | Notes |
|---|---|---|
| `purchases.ledger[PurchaseId]` | `{productId, grantedAt, grants}` | Idempotency. `grants` lists the fixed items given (no random results exist). Keep the last 500 entries |
| `purchases.ritesOwned` | set of rite ids | Bound Rites, one each per account (§9.5) |
| `cosmetics.owned[]` | set | Lair themes, auras, card-back sets (§9.6) |
| `purchases.firstPurchaseAt` | number/nil | Founder's Candle |
| `purchases.starterPackClaimed` | bool | Pass grant done |
| `giftedPasses[passKey]` | `{fromUserId, purchaseId}` | Update 1 |
| `giftsReceived[PurchaseId]` | true | Recipient-side dedupe |
| `tarot.tokens` | `{pale, blood}` | Free only |
| `tarot.pity` | `{pale, blood}` | Cards since last Epic |
| `tarot.marks[species]` | number | Duplicate marks |
| `tarot.milestonesClaimed` | set | Grimoire/Tithe/rebirth |
| `bloodMoon.boughtToday` | `{utcDay, count}` | Daily cap |
| `ui.relicsPipShown`, `ui.relicsPipCleared` | bool | §13.2 |
| `shop.proactiveCardShownSession` | session only (not saved) | 1 per session |
| **Not saved:** policy results (only if the wrapper is used) | – | Fetched every session |

## 15. Server vs client
**Server owns:** every price lookup, every grant, all free rolls (cards, pity), Blood Moon state, bundle quotes, policy checks if any. **Client owns:** showing panels, odds tables sent by the server, the reveal animation, the pip.

**`ProcessReceipt` rules** ([MarketplaceService.ProcessReceipt](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService#ProcessReceipt), [Developer products](https://create.roblox.com/docs/production/monetization/developer-products)):
1. Find the player by `receiptInfo.PlayerId`. If they're not in this server or their profile isn't loaded, return **`NotProcessedYet`**. Roblox retries on their next join or purchase.
2. If `ledger[PurchaseId]` exists, return **`PurchaseGranted`** right away (already given).
3. Check the product id is known and `CurrencySpent` matches the configured price ± regional pricing; log mismatches but still grant (the player paid).
4. Do the grant **inside the profile**, write `ledger[PurchaseId]`, then **save** (UpdateAsync / session-locked profile save).
5. Return **`PurchaseGranted` only after the save succeeds.** Any error → `NotProcessedYet`.
6. **No receipt ever rolls anything** (decision B). Bound Rites grant their fixed list; free readings are not receipts and keep their own log (spec 10 v2 §11). A test asserts no ProcessReceipt branch calls the RNG.
7. **Gifts (Architect design, accepted 4 Nov):** ProcessReceipt never writes the recipient's session-locked profile. Instead it uses UpdateAsync to append `{purchaseId, passKey, fromUserId}` to a separate per-recipient **gift inbox** key, deduped by purchaseId. Once that write succeeds, it records the buyer's ledger entry, saves, and returns PurchaseGranted. The recipient's server claims the inbox on profile load (or on a MessagingService ping if they're online elsewhere). It moves each gift into `giftedPasses` + `giftsReceived[purchaseId]`, saves the profile, then clears those inbox entries. The claim is idempotent. The buyer sees: "Your gift will reach {DisplayName} the next time they play." Data: one `GiftInbox_<userId>` key per recipient.
8. Session locking stops two servers granting the same receipt at once.
9. **Pass ownership:** `UserOwnsGamePassAsync` on join (pcall, cache), plus `PromptGamePassPurchaseFinished` for in-session grants, OR `giftedPasses`.

## 16. Edge cases
| Case | Behaviour |
|---|---|
| Bundle bought with 0 income | Minimum $ amount applies |
| Bound Rite bought while satchel is full | The named cryptid goes to the overflow stable (shown before purchase: "Your satchel is full; it will wait in the Stable") [A v3]. Never converted to a random item |
| Bound Rite for a species already owned | You get a second copy (shown before purchase: "You own one; this adds another") |
| Satchel full on a free reading | Cash at 100% price, shown on the card |
| Pity card inside a 10-card free spread | Details shows per-card odds; that card is Epic |
| Quote changed (income rose) between view and buy | Grant `max(quote, now)` |
| Starter Pack after rebirth | Not re-granted; Hidebehind already owned stays |
| Blood Moon bought, server shuts down at 2 min | Ends; copy said "for this server" |
| Two players buy Blood Moon in the same second | Server lock: first receipt starts it; the second purchase is blocked before prompt (button disabled). If a second receipt still arrives, queue it to start after cooldown and tell the buyer the time. No refund possible in code |
| Gift to someone who owns it already | Server blocks before the prompt |
| Price optimisation shows a regional price | Grant uses product id, never price |
| Founder's Candle with a gift purchase | The buyer gets it, not the recipient |

## 17. QA (16 tests)
| # | Test | Pass when |
|---|---|---|
| 1 | Run `python3 specs/tools/verify_odds.py` | Prints "ALL TABLES SUM TO EXACTLY 100%", exit 0, pity lines show 3.02% / 12.59% |
| 2 | New account, first 5:00 | No shop prompt, card or pip before step 8 **and** 5:00 |
| 3 | Buy Coffer twice quickly, kill the server between grant and return (Studio) | Rejoin: cash granted **exactly once** per PurchaseId |
| 4 | DataStore save forced to fail in ProcessReceipt | Returns NotProcessedYet; grant appears after the next successful run, once |
| 5 | **Restricted account** (Player Emulator: `ArePaidRandomItemsRestricted` on, e.g. United Kingdom), January build | No Server Luck card, button, prompt, price or link anywhere; Tarot Table, passes, Bound Rites and free readings all work |
| 6 | **Failed policy call** (mock `GetPolicyInfoForPlayerAsync` to error 3×) | Server Luck hidden all session; no error shown; everything else works |
| 7 | Unrestricted account opens the Server Luck card | Base vs boosted odds for each affected table + "Details" visible **before** See Price; both tables sum to 100% |
| 8 | Pity counter at 39 (Pale), earned tokens | Panel shows "Next card: Epic 100%"; the 40th card is an Epic; counter resets |
| 9 | **No paid randomness**: grep the product config + call graph | No dev product or pass grants a token, reading, random cryptid or random craft; no ProcessReceipt branch calls the RNG (Server Luck only starts a timer/multiplier; rolls happen later in normal play) |
| 10 | Honest reveal: log the server roll before the animation, 200 free readings | Revealed card = server roll every time |
| 11 | **Relics gold pip**: catch the first Rare after step 8 + 5:00 | GoldBright dot after the reveal, no pop-up; opening Relics clears it; never returns |
| 12 | Rebirth with $5M bought from bundles but Tithe $4M | Rebirth stays locked: "Tithe $4.0M / $5.0M" |
| 13 | Blood Moon (Update 1): buy, then try again | Banner "{DisplayName} summoned a Blood Moon over Hollowmere!" with no price; all players +50% for 10 min; real remaining time; 5 min cooldown; odds unchanged |
| 14 | Search the shop and all UI strings for banned words | None found |
| 15 | **Bound Rite** purchase (each of 3) | Card lists exact contents before See Price; the grant equals the list exactly, every time (200 Studio buys); Rite of the Devil hidden before the Rebirth 1 Tithe gate; second buy blocked; lifetime paid Essence ≤ 150; no banner |
| 16 | Reel, charge-up, Server Luck, Essence, Bestiary, Skip earn path | Spec 10 v2 §13 tests pass (January; NEW stamp at launch if built) |

## 18. Sources (all read 4 Nov 2026)
- Roblox Creator Hub, **Paid random items** (re-read 4 Nov 2026 for decision B): https://create.roblox.com/docs/production/monetization/paid-random-items
- Roblox **PolicyService** reference (`GetPolicyInfoForPlayerAsync`): https://create.roblox.com/docs/reference/engine/classes/PolicyService
- Roblox **Community Standards** (paid random items, economy): https://about.roblox.com/community-standards
- DevForum (official), **Clarifying requirements for paid random items**, 26 May 2026 (FAQ "only earned, not paid", re-read 4 Nov 2026): https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622
- Roblox **Monetization** guidelines (genuine discounts, accurate timers, "View Item / See Price / Open Shop", PolicyService duty): https://create.roblox.com/docs/production/monetization
- Roblox **Developer products** (ProcessReceipt, Listed external sales): https://create.roblox.com/docs/production/monetization/developer-products
- Roblox **Passes**: https://create.roblox.com/docs/production/monetization/passes
- DevForum (official), **Disabling cross-game sales of passes and dev products** (from 29 May 2026): https://devforum.roblox.com/t/disabling-cross-game-sales-of-passes-and-dev-products-and-introducing-the-transfers-api/4618396
- Design bible canvas: https://cursor.com/canvas/store-a63cf3f9-8205-497a-abd7-29e4e6dd2d41/f13730a8-df11-4f9b-b132-0a54a568d791
- Price comparables: §10 sources and `specs/research/` snapshots
