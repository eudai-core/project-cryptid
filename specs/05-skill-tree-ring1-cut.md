# Spec 05: Skill Tree Ring 1 Cut (spec 04 addendum)

> **4 Nov 2026:** all [A] assumptions are approved by the owner as starting values, to be tuned from playtest data. Robux prices are still pending Eudai's approval.

**Owner:** Cryptid Growth Strategist · **Builder:** Cryptid Systems Architect · **Status:** Draft v1.2 (Wed 4 Nov 2026: v1.2 audit fix, h5/h6 sealed until deterministic. v1.1: Ring 2 prices from spec 11 §11. v1 same day) · **Due:** Wed 4 Nov
**Amends:** Spec 04 v1. Everything in spec 04 stands **unless this file says otherwise**. **Paid products:** none. **Paid randomness:** none.

> **[A]** = design assumption, not measured data. Source for the cut: the fast-ship plan (research canvas, "Fast-ship plan (revised 3 Nov)") lists "Rites skill tree, first ring only" as a launch must-have and puts "skill tree ring 2" in **Update 2, Fri 4 Dec**. Raiding/defences ship in Update 3 (Fri 11 Dec); Expeditions in January.

---

> **v1.1 change (Wed 4 Nov 2026), from spec 11 v1 §11 (approved by Grok Bot as the design base, 4 Nov):** Ring 2 (Update 2, Fri 4 Dec) no longer uses spec 04's $6K–$75K costs. The k-th Ring 2 node bought in a branch costs **`$2.5M × 4^(k−1)`** ($2.5M, $10M, $40M, $160M…) and Ring 2 opens only at **Rebirth ≥ 2** [A, not simulated]. Ring 1 (§4) is unchanged. Nodes tied to stealing (`l5` Ward Lore, `l7` Grim Vigil) stay sealed until **Update 3, which needs a fresh review**.

> **v1.2 change (compliance audit (`compliance-audit-cash-random.md` §4; Grok Bot approved, 4 Nov; cash = paid currency)):** `h5` and `h6` are **sealed until deterministic (U2)** (cash-bought odds changes aren't allowed); `h3` stays sealed.

## 1. Goal
Ship the **full-screen ritual-circle UI exactly as spec 04 describes** (ScreenGui, 2800 × 2800 canvas, pan/zoom, ignite burst, parchment tooltip). Only the **number of buyable nodes** shrinks. Every node a player can buy at launch **does something on day one**. No dormant purchases.

## 2. What "Ring 1" means
- Ring 1 = **the root plus the first three steps of each branch**, the nodes inside or touching spec 04's second chalk ring (r = 600 canvas px).
- **7 buyable nodes** + the free root. All 17 node positions are still drawn, so the circle looks complete.

## 3. Keep / cut table

| Id | Name | Spec 04 cost | Launch | Reason |
|---|---|---|---|---|
| `root` | The Kindling | free | **KEEP** (owned) | Anchor of the circle |
| `h1` | Steady Hand | $1,000 | **KEEP** | Catch time works now (tutorial + wild spawns ship) |
| `h2` | Long Reach | $2,500 | **KEEP** | Catch range works now |
| `h3` | Keen Eye | $6,000 | **SEAL** | Outline effect relies on Highlight, whose limit is UNVERIFIED (style guide D8). Its child h5 is also sealed |
| `h4` | Quiet Step | $15,000 → **$6,000** | **KEEP** | Works now. Now the 3rd Hunter node, so it takes the 3rd-tier price |
| `h5` | Lure Craft | $30,000 | **SEAL: sealed until deterministic (U2)** | Only reachable via h3; spawn-rate effect is a cash probability modifier (audit row 6) |
| `h6` | Blood Tracker | $75,000 | **SEAL: sealed until deterministic (U2)** | Outer node; rarity-chance effect is a cash probability modifier (audit row 7) |
| `h7` | Expedition Lore | $150,000 | **SEAL** | Dormant hook: Expeditions ship in January |
| `h8` | The Hunter's Mark | $400,000 | **SEAL** | Needs h7 |
| `l1` | Warm Hearth | $1,000 | **KEEP** | Income +5% |
| `l2` | Masons' Rite | $2,500 | **KEEP** | Pad cost −10% |
| `l3` | Altar Devotion | $6,000 | **KEEP** | Altar +0.30/level |
| `l4` | Deep Coffers | $15,000 | **KEEP** | Income +10% |
| `l5` | Ward Lore | $30,000 | **SEAL** | Dormant hook: defences ship Update 3 (11 Dec) |
| `l6` | Bound Pact | $75,000 | **SEAL** (Ring 2) | Outer node; Ring 2 ships Update 2 |
| `l7` | Grim Vigil | $150,000 | **SEAL** | Dormant hook: stealing ships Update 3 |
| `l8` | Heart of the Lair | $400,000 | **SEAL** | Needs l7 |

**Rule:** no node whose effect is a dormant hook is buyable at launch. Spec 04's "Dormant until…" tooltip line is not used in this build.

## 4. Ring 1 nodes (exact launch values)

| Id | Name | Branch | Prerequisite | Cost | Currency | Effect value |
|---|---|---|---|---|---|---|
| `h1` | Steady Hand | Hunter | `root` | **$1,000** | in-game cash | Catch time **−10%** (3.0 s → 2.7 s) |
| `h2` | Long Reach | Hunter | `h1` | **$2,500** | in-game cash | Catch range **+2 studs** (12 → 14) |
| `h4` | Quiet Step | Hunter | `h2` | **$6,000** (was $15,000) | in-game cash | Catch time **−15%** more (total −25%: 3.0 s → 2.25 s) |
| `l1` | Warm Hearth | Lair | `root` | **$1,000** | in-game cash | All income **+5%** |
| `l2` | Masons' Rite | Lair | `l1` | **$2,500** | in-game cash | Pad unlock costs **−10%** (rounded to $1) |
| `l3` | Altar Devotion | Lair | `l1` | **$6,000** | in-game cash | Bone Altar **+0.30** per level instead of +0.25 |
| `l4` | Deep Coffers | Lair | `l2` | **$15,000** | in-game cash | All income **+10%** (stacks with l1: +15%) |

| Total | Value |
|---|---|
| Hunter Ring 1 | **$9,500** |
| Lair Ring 1 | **$24,500** |
| **All of Ring 1** | **$34,000** |

- Robux: **never**. No node, respec or skip is sold (spec 04 §11 stands).
- Formulas from spec 04 §5.2 are unchanged. With Ring 1 only: `skillIncome` max = **0.15**; `catchTime` min = **2.25 s**; `catchRange` max = **14**.
- Pacing check (sim, see spec 07 §4): a median active player has **~$380/s at 15 min** [A, model], so Ring 1 is affordable in session 1. That is intended: the tree teaches the UI now, and Ring 2 adds the longer chase in Update 2.

### 4.1 Ring 2 prices (Update 2; v1.1 from spec 11 §2.2)
| k-th Ring 2 node in a branch | 1 | 2 | 3 | 4 |
|---|---|---|---|---|
| Cost (cash) | $2.5M | $10M | $40M | $160M |
- Opens at **Rebirth ≥ 2**. Never sold for Robux. Not simulated [A].

## 5. How sealed nodes look
**Sealed, not hidden** (shows the circle has more to come, which is a reason to return, and costs no extra layout work).

| Part | Look |
|---|---|
| Disc | Spec 04 **Locked** cracked stone (`Soot`, `BoneDim` 2 px stroke, crack overlay) |
| Seal | A `Blood` wax-seal glyph over the sigil (sigil 80% transparent). No lock glyph |
| Paths into sealed nodes | Chalk, dashed, **85% transparency** (fainter than normal chalk) |
| Glow / pulse | None, ever (style guide: locked nodes never glow) |
| Tooltip | Title + branch line + **"Sealed. This rite wakes in a later moon."** (`Merriweather` 14 italic, `Soot`). **No price, no effect line, no BUY seal** |

- We show **no date** in-game (if Update 2 slips, nothing is a broken promise).

## 6. Respec
**No respec at launch** (decision, matches the Architect's lean). Reasons: Ring 1 has no exclusive choices (all 7 nodes cost $34,000 total and can all be owned), so there is nothing to undo. **[A]** Revisit when Ring 2's "or" nodes ship. Never sold for Robux without a new spec and Eudai's approval.

## 7. Data to save
- **No new keys.** `skills` (spec 04 §9) unchanged.
- Config: add `ring` (1, 2 or 3) and `sealed` (bool) to each node in `SkillConfig`. Launch: Ring 1 nodes `sealed = false`; all others `true`.
- Skills **survive rebirth** (spec 04 §9; confirmed in spec 07).

## 8. Server vs client
- **Server:** `RequestBuySkill(nodeId)` also rejects when `SkillConfig[nodeId].sealed == true` ("This rite is sealed."). h4 checks `h2` only. Costs come from server config; h4 = 6,000.
- **Client:** renders sealed state from config; never shows a BUY seal on a sealed node.

## 9. Edge cases
1. **Forced remote for a sealed node:** refused, cash unchanged, logged.
2. **Test-place profile already owns a sealed node** (from earlier builds): keep the id in `skills`, show it as sealed (not owned), apply no effect; no refund. Live place has no prior data, so this only affects test saves.
3. **Ring 2 unseals later:** flipping `sealed` to false makes nodes available under spec 04 rules; no migration needed.
4. **h4 after h2 with h3 sealed:** allowed (h3 is not a requirement for h4).
5. **Everything owned:** tree shows 8 ember nodes + 9 sealed; header still shows cash.

## 10. QA: what happens to spec 04's 18 tests

| Spec 04 test | Status | Launch version |
|---|---|---|
| 1 It's UI | **Applies** | – |
| 2 Gate | **Applies** | – |
| 3 Open/close | **Applies** | – |
| 4 Layout | **Changes** | 17 nodes drawn at §5.1 positions (±2 px); 9 of them sealed |
| 5 Pan/zoom | **Applies** | – |
| 6 States | **Changes** | Fresh profile: root owned; h1, l1 available; h2, h4, l2, l3, l4 locked; h3, h5–h8, l5–l8 sealed |
| 7 Buy h1 | **Changes** | As spec 04, but only **h2** becomes available (h3 stays sealed) |
| 8 Or-rule | **Dropped** | h5/h6 sealed |
| 9 Can't afford | **Applies** | – |
| 10 Effects | **Applies** | l1+l4 ×1.15; h1+h4 = 2.25 s; l2 → Pad 5 $1,080 |
| 11 Altar Devotion | **Applies** | – |
| 12 Hunter's Mark | **Dropped** | h8 sealed |
| 13 Dormant notes | **Dropped** | Replaced by new test A below |
| 14 Ignite | **Applies** | – |
| 15 Reduced Motion | **Applies** | – |
| 16 Persist | **Applies** | – |
| 17 Palette | **Applies** | – |
| 18 Totals | **Changes** | Buying all 7 Ring 1 nodes costs exactly **$34,000** |

**New tests**

| # | Test | Pass if |
|---|---|---|
| A | Sealed tooltip | Tapping any of the 9 sealed nodes shows "Sealed. This rite wakes in a later moon.", no price, no BUY seal |
| B | Sealed remote | Firing `RequestBuySkill("h3")` (or any sealed id) with ample cash is refused; cash unchanged |
| C | h4 price/prereq | With h1+h2 owned, h4 is available at **$6,000**; after buying it, a catch takes **2.25 s** (3.0 × (1 − 0.10 − 0.15)) |
| D | No glow on sealed | Sealed nodes never pulse or spark, at any zoom |
| E | No Robux | No MarketplaceService call from the tree |
