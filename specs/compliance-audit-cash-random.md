# Compliance audit: cash-bought randomness (all specs 01–12)

**Owner:** Cryptid Growth Strategist · **Status:** Draft v1 (Wed 4 Nov 2026) · **Read:** specs 01–12, incl. spec 11 v1.1 and spec 12 v1.1 · **No other spec or analytics/ edited.**
**Ruling (Grok Bot, 4 Nov):** in-game cash is **paid currency**, because it's sold in Robux bundles (spec 09 §8). `[A]` = judgement call where Roblox's docs are silent.

## 1. Policy basis (paid-random-items page re-fetched 4 Nov; the other sources were read earlier on 4 Nov)
- **Paid random items page:**
  - "certain requirements may apply to random items purchased directly or indirectly with Robux. This includes random items purchased with paid in-game currency."
  - Probability modifier items include "Luck boosts · Pity systems · **Enhanced resource drops** · Rate-up scrolls".
  - "Paid items that augment the odds of other random outcomes must also be explained before purchase… The new odds… must also be dynamically updated."
  - Earned exemption: "an action that does not involve the payment of Robux or other in-game currency" needs no odds disclosure.
  - Link: https://create.roblox.com/docs/production/monetization/paid-random-items
- **PolicyService:** `GetPolicyInfoForPlayerAsync()` returns `ArePaidRandomItemsRestricted`. Restricted users need a treatment such as "Removing or hiding the paid random item". https://create.roblox.com/docs/reference/engine/classes/PolicyService
- **DevForum, official, 26 May 2026:** https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622
  - **Staff reply #29:** a preview-before-buy crate "still falls under the Paid Random Items policy… the underlying system is still randomly generating future outcomes, and **the only way to find out (or change) what comes next is to buy**."
  - **Staff reply #54:** "The purchasable item that reloads its content every minute is considered a paid random item because the player pays without knowing what they'll receive."
  - **Staff reply #60:** luck passes are probability modifiers.
  - **Staff reply #30:** "It does not apply to skill-based gameplay variance."
  - A question about Grow a Garden-style timed restocks (#32, #56) got **no staff answer**.
- **Community Standards:** a paid pack bundling a random item makes "the entire bundle a paid random item". https://about.roblox.com/community-standards
- **Where the docs are silent:**
  - whether a permanent cash upgrade that raises spawn **rate** counts as "enhanced resource drops" (we treat it as yes `[A]`);
  - whether a **timer-driven** shop, whose next stock comes whether or not you buy, falls under #29 (we treat it as no, *if* buying never changes or brings forward a roll `[A]`).

## 2. Summary table
| # | Item | Spec § | Classification | Risk | Minimum fix | Before 13 Nov freeze? |
|---|---|---|---|---|---|---|
| 1 | **Rift belt** cash buys (LAUNCH) | 01 B; 02 §3; 09 §4 | Building: a lair fixture rolls free on a fixed 10 s timer; cash buys a **shown** cryptid | **Med** (fails #29 if buying frees a slot that triggers the next roll) | Spec rule: spawn cadence is **independent of purchases** (no refill-on-buy, no capacity block); the belt "**Details**" odds panel stays | **YES** (spec text + QA, no new feature) |
| 2 | **Pale Pedlar** cash buys (LAUNCH) | 03 §4, §10; 09 §4 | Not random at purchase: global UTC seed, restocks on a timer, buying never rerolls | **Med** `[A]` (staff #32 unanswered) | Rewrite 03 §10's reason: drop "cash, not Robux", keep "shown before you pay + fixed timer". Slot odds behind a "**Details**" word button. **No** cash restock or reroll, ever | **YES** (text + label) |
| 3 | Variants on belt and Pedlar offers (U1) | 11 §3.2; 09 §4 | Not random **if** rolled at offer creation and shown | Low → **High** if rolled at buy | Roll the variant at spawn or stock time; show the badge on the card | U1 |
| 4 | Pads, Bone Altar III–X, rebirth tiers, Ring 1 l1–l4 | 01 B4; 02 §3; 07 §2; 05 §4 | Deterministic upgrades | Low | None | – |
| 5 | Catch speed/range h1, h2, h4; contested catches | 05 §4; 11 §4.1 | Skill race, not system random (#30) `[A]` | Low | None | – |
| 6 | **h5 Lure Craft** (wild spawn rate +10%) | 04 §5.1; 05 §3 (sealed, U2) | **Cash probability modifier** ("enhanced resource drops") `[A]` | **High** | Change to a deterministic effect (e.g. wild-source income +5%), or make it an earn-only unlock | Keep sealed; fix before U2 |
| 7 | **h6 Blood Tracker** (Uncommon+ ×1.05) | 04 §5.1; 05 §3 (sealed, U2) | **Cash probability modifier** | **High** | Change to deterministic (e.g. Hunter's catch time −5% or wild income +5%) | Keep sealed; fix before U2 |
| 8 | h3 Keen Eye (outline) | 04 §5.1 | Information only, odds unchanged | Low | None | – |
| 9 | Expeditions + h7 Expedition Lore (−10% time) + Instant Return (Robux) | 09 §8; 12 §6.2; 05 §3 | Loot shown at send-off (09) = not random. **But** 12 §6.2 rolls the 10% relic **on return** | **Med** | Roll relics **at send-off** and show them; expedition sends stay **free** (no cash fee) | January |
| 10 | Hunting tools L2–L5 (Lanternwright) | 03 §2 (shuttered, "later spec") | Undefined | **High** if they touch rarity or catch odds | Rule for the later spec: tools are deterministic only (time, range), **never rarity, spawn or variant odds** | Stays shuttered |
| 11 | Weather mutations | 03 §4.2 ("later spec"); 01 data | Free weather rolls on placed cryptids = earned | Low → **High** if cash raises the chance | No cash item, upgrade or reroll touches mutation odds (spec 10 §7 already bans rerolls) | Later spec |
| 12 | Pedlar relics (cash, U1) | 12 §6.1, §8 | Deterministic (atmosphere + income) | Low | Keep spec 12's QA 15 | – |
| 13 | Bestiary-milestone tarot tokens (January) | 09 §5.4; 10 §8 | Random reward reachable by **buying** species with cash `[A]` | **Med** | Count only free-source obtains (wild, starter, daily, reading, event) toward token milestones | January |
| 14 | Free event luck (Rift Storm, Eclipse, Rift Tide) | 12 §2.2; 09 §9.4 | Free; not purchasable | Low | None (odds shown anyway) | – |
| 15 | Server Luck (Robux, January) | 10 §5; 09 §6.3 | Paid probability modifier, already gated | Low (already handled) | Keep: fail closed, odds updated live | – |
| 16 | Essence (paid via Bound Rites); mastery; cash bundles; Lure Totem | 10 §7; 11 §3.4; 09 §8 | Deterministic sinks and effects | Low | Keep Essence crafts deterministic; Lure Totem never changes rate or odds | – |
| 17 | Lure Totem (49 R$) and Pedlar's Satchel (149–299 R$): spec 09 lines 14 and 16, the price-approval condition | 09 §8 (Lure Totem), 09 §9.3 | Lure Totem only moves where your wild spawns appear (within 25 studs of the totem). The 45 s interval, max alive of 3 and odds stay the same. Satchel contents are fixed and shown before buying, with no tokens, Essence or random items | Low | None. **Both PASS**, so the approval condition is met. QA: during a Lure Totem, the spawn interval, cap and rarity table match the baseline | – |

No belt upgrades or pad "trait" upgrades exist in any spec. If one is added, the rule in row 6 applies.

## 3. (d) Sky and announce triggers
- **Recommendation: keep the Rift belt triggers, because the belt counts as a building.**
  - It's an owned lair fixture.
  - It rolls on a fixed timer whether or not you buy, at no per-roll cost.
  - The random outcome is produced by play; cash only buys a cryptid already shown.
  - This holds only while row 1's cadence rule holds. Fire the trigger from the **roll's source** (`rift_roll`) when the cryptid is bound.
- **Pedlar purchases are not a free source.** The stall is a shop and the purchase itself is the acquisition, so they get no sky and no banner (already excluded in specs 08 and 10; keep it that way).
- **Edit spec 10 §10 / spec 08 edge case 5:** replace "'Bought' means Robux only; cash-bought Rift catches count as free" with: "A free source is a roll made by play or a lair building (wilds, Rift belt roll, earned readings, expeditions, free events). Anything bought at a shop, with Robux or cash, is not a free source."
- Policy note: Roblox doesn't regulate announcements. This is our D26/D29 fairness rule.

## 4. Proposed per-spec edits (owners apply)
| Spec | Edit |
|---|---|
| 02 §3 / 01 B | Belt rule: "spawns every 10 s regardless of purchases; buying never spawns, rerolls or brings forward the next offer" (onboarding's fixed first two stay as they are, being deterministic) |
| 03 §10, 09 §4 | Policy reason = preview + fixed global timer (cash is paid currency). The odds button is labelled "**Details**" |
| 04 §5.1 / 05 §3 | h5 and h6 become deterministic before Update 2 |
| 12 §6.2 | Expedition relics are rolled at send-off and shown |
| 09 §5.4 | Bestiary token milestones count only free-source obtains |
| 08 edge case 5 / 10 §10 | New free-source definition (§3) |
| 03 §2 | Lanternwright note: tools are deterministic only |

## 5. QA acceptance tests
1. **Belt cadence:** buy every belt offer the instant it appears for 10 min, then repeat without buying. Spawn timestamps are identical (every 10 s ± 0.1 s), and no spawn ever follows a purchase early.
2. **Pedlar:** buying all 4 slots doesn't change the stock until `floor(os.time()/300)` changes; two servers show the same stock.
3. **Variant shown (U1):** in 1,000 forced offers, the badge on the card equals the bound cryptid's variant in 100% of cases.
4. **No cash odds:** grep product, skill and upgrade config for any cash or Robux item writing `luck`, `spawnRate`, `rarityMult`, `variant` or `mutation` multipliers. The only hit is Server Luck (January, gated).
5. **Details panels:** the belt and every Pedlar slot have a button labelled with the word "Details" (not a bare (i)) that shows live odds summing to 100%, and they update during Rift Storm.
6. **Sky source (January):** a forced Mythic from a belt roll fires the sky; a forced Mythic bought at the Pedlar or through any Robux path doesn't.
