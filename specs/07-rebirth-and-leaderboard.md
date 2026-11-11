# Spec 07: Rebirth (Tier 1) + The Tithe Leaderboard

> **4 Nov 2026:** all [A] assumptions are approved by the owner as starting values, to be tuned from playtest data. Robux prices are still pending Eudai's approval.

**Owner:** Cryptid Growth Strategist · **Builder:** Cryptid Systems Architect · **Status:** Draft v3 (Wed 4 Nov 2026: rebirth tiers 1–7, Tithe gate formula, pad prices × 1.5^r, Tithe excludes Relic pads; from spec 11 §11. v2: rebirth also needs Tithe ≥ $5M; boosts excluded from Tithe. v1 same day) · **Due:** Sat 7 Nov
**Builds on:** Specs 01–05, 06, 09. **Paid randomness:** none. **Nothing here is sold.**

> **[A]** = design assumption. Grounding (research canvas): launch must-haves are "one rebirth tier with a permanent multiplier" and a leaderboard; Steal a Brainrot's rebirths grant income multipliers (canvas genre teardown); Hamari et al. 2017 found competition-type motivations are **not** linked to spending, so we make the leaderboard about play, not money; Salganik et al. 2006: visible popularity signals change what people do (social proof). The pacing below is a **simulation on our own numbers**, not benchmark data.

> **v3 change (Wed 4 Nov 2026), from spec 11 v1 §11 (approved by Grok Bot as the design base, 4 Nov), LAUNCH (must):**
> - **Rebirth tiers 1–7 at launch** (tier 8+ sealed, Update 2): cost `$5M × 3^(n−1)`, multiplier `1 + 0.5n`, **Tithe gate** = $5M (tier 1), the sum of costs 1..2 (tier 2), **0.75 ×** the sum of costs 1..n (tier 3+). Table in §2.1.
> - **Pad prices × 1.5^r** after r rebirths (was "same prices apply again"); Bone Altar costs too (spec 01 v2.1 B4).
> - **Tithe also excludes income from Relic pads 9–10** (the +2 Pads pass).
> - Pacing (§4) is now spec 11's sim (`tools/pacing_sim_output.txt`): F2P Rebirth 1 ~day 2, Rebirth 3 ~day 4, Rebirth 5 ~day 10, Rebirth 7 ~day 44 (2 × 20 min/day [A]); light spender ≤ 1.69× faster.

## 1. Goal
Give a D1–D3 player a big, clear goal ("the Rite of Rebirth") that they finish **around their 3rd session**, then restart faster and stronger. Give everyone one fair stat to climb.

## 2. Rebirth tier 1: "The Rite of Rebirth"

| Setting | Value |
|---|---|
| Cost | **$5,000,000** in-game cash (spent) |
| Reward | Permanent **×1.5 income** (`rebirthMult = 1 + 0.5 × rebirths`) |
| Requirement | Onboarding done; `rebirths == 0` for tier 1 (tiers 2–7: §2.1); **Tithe ≥ $5,000,000** (v2 spend-to-power cap: cash bought with Robux bundles can't skip a rebirth, spec 09 v2 §12) |
| Where | Bone Altar → **"Rite of Rebirth"** button (shows once you've ever held $1M) |
| Full income formula | `Σ pad base × altarMult × (1 + skillIncome) × rebirthMult × passMult` |

### What resets / what's kept
| Resets | Kept |
|---|---|
| Cash → **$100** [A] (all cash, not just $5M) | Skills bought (Ring 1) |
| Pads → Pads 1–2 unlocked (3–8 relock) | **One "Bound Familiar"** of your choice, placed on Pad 1 |
| Bone Altar level → 0 | Grimoire discoveries |
| All other cryptids are released | All passes (incl. Pads 9–10), cosmetics |
| Offering Bowl (banked first, then reset with cash) | Daily ladder step, Tithe, `totalEarned`, settings |

**Pad prices (this is the "pacing spec" spec 02 §3 points to).** Pads 1–6 as spec 02. New: **Pad 7 $15,000 [A]**, **Pad 8 $40,000 [A]**. Pads 9–10 come only from the +2 Pads pass (spec 09, pending approval) and show "Sealed" without it. Pads 11–12 stay sealed. **v3: after r rebirths every pad price is × 1.5^r** (and Bone Altar costs, spec 01 v2.1 B4); Masons' Rite −10% still applies.

**Why keep one familiar + skills:** the second climb starts at real income (e.g. a kept Jersey Devil: 150 × 1.5 × 1.15 ≈ **$259/s** from second one, vs $2/s on day one). That's the "I came back stronger" feeling, and it protects the ~35-min skill investment.

### UI text
- Panel title: **"The Rite of Rebirth"**
- Body: "Offer **$5,000,000** to the Rift. Your lair returns to dust, but you return stronger: **all income ×1.5, forever.**"
- Lists: **"You keep:"** skills, one familiar, grimoire, passes, cosmetics, daily offering, Tithe. **"You lose:"** cash (**including your other $X**), pads 3–8, altar level, other cryptids.
- Familiar picker: "Choose one cryptid to follow you through the Rift."
- Confirm button: **"Begin the Rite"** → second confirm: "This can't be undone. Begin?" (**Yes / Not yet**). No timers, no shop offers on this screen (spec 09 v2 §7).
- Done toast: "You are reborn. Income ×{mult}." The panel shows the next tier's cost, the Tithe gate bar and the new multiplier. Tier 8+ sealed tooltip: **"The eighth rite is not yet written."**

### 2.1 Rebirth tiers 1–7 (v3, spec 11 §2.2; LAUNCH)
| Tier | Cost (cash) | Income mult after | Tithe gate | Pad/altar price × |
|---|---|---|---|---|
| 1 | $5,000,000 | ×1.5 | $5M | ×1.50 |
| 2 | $15,000,000 | ×2.0 | $20M | ×2.25 |
| 3 | $45,000,000 | ×2.5 | $49M | ×3.38 |
| 4 | $135,000,000 | ×3.0 | $150M | ×5.06 |
| 5 | $405,000,000 | ×3.5 | $454M | ×7.59 |
| 6 | $1,215,000,000 | ×4.0 | $1,365M | ×11.39 |
| 7 (launch cap) | $3,645,000,000 | ×4.5 | $4,099M | ×17.09 |
| 8–10 | Update 2, same formulas | ×5.0–×6.0 | same rule | same rule |
- Same resets/keeps as tier 1 at every tier. The Tithe gate is unbuyable (Tithe excludes 2x Cash, Blood Moon, bundles, daily rewards and Relic pads 9–10).

## 3. The leaderboard: one stat, "Tithe"

| Setting | Value |
|---|---|
| Stat | **Tithe** = lifetime income from cryptids, counted **before** the 2x Cash pass and **before** any Blood Moon boost (v2), and **excluding income from Relic pads 9–10** (v3) |
| Counts | Live income, bowl income, offline hauls (pre-2x) |
| Doesn't count | Daily rewards, Starter Pack, cash bundles, selling, refunds, **Relic pads 9–10 income (v3)**, Echo income (Update 3) |
| Resets | **Never** (survives rebirth) |
| In-server | `leaderstats` column **"Tithe"**, short format (`1.24M`) |
| Global | Top 50 **OrderedDataStore** "TitheBoard_v1"; write own value at most every 120 s; board reads every 120 s [A] |
| Place | Stone slab **"The Ledger of Tithes"** in Hollowmere, beside the Weeping Well facing road P1. Update 1: second face "The Hunt Ledger" (spec 11 §5.2, spec 03 v2.1) |

**Why Tithe (not cash, not rebirths):**
1. **Can't be bought.** Excluding the 2x pass and bundles means paying never moves you up. Hamari 2017: competition doesn't drive spending, so a pay-to-rank board costs trust for no gain.
2. **Always moving.** Every second of play adds to it, which suits a 10-minute session. Rebirth counts (0–7) bunch up at a few values.
3. **Never drops.** Rebirth doesn't punish you on the board (cash would crash to $100).
4. **Social proof** (Salganik 2006): a visible board in the town square signals "people are playing hard here".

## 4. Pacing: time to first rebirth (the maths)
> **v3:** the tier 1 maths below is kept as history. The approved pacing model for tiers 1–7, the new altar curve and pad × 1.5^r is spec 11 §2 (`tools/pacing_sim.py`, output in `tools/pacing_sim_output.txt`).

**Ceiling check (closed form).** Full launch lair = 8 cash pads × Epic (avg 160/s) × max Bone Altar 1.6 [spec 03] × Ring 1 skills 1.15:
`8 × 160 × 1.6 × 1.15 = $2,355/s` → `$5,000,000 ÷ 2,355 = 2,123 s ≈ **35 min** of saving` even at the cap. So rebirth can't happen in the first session's opening minutes.

**Monte Carlo (greedy active player, 400 seeded runs; script `/workspace/scratch/sim2.py`, our assumptions):**
| Active minutes | Median income/s |
|---|---|
| 10 | $198 |
| 20 | $631 |
| 30 | $1,067 |
| 60 | $1,748 |
| 80 | $2,245 |

| Bank target (active play only) | Median time |
|---|---|
| $1M | 39 min |
| $2.5M | 58 min |
| **$5M (Rebirth 1)** | **81 min** (p10 72, p90 92) |

**With real sessions:** 20-min daily sessions + spec 06 offline (8 h at 20%) → rebirth lands at the **start of session 3 (~40 active min)**, so roughly **day 3** for a daily player, or ~80 min for a binge player. That fits a D1→D3 goal and gives a D7 player one rebirth plus a stronger second climb. Tier 2 arrives with Update 2 (Fri 4 Dec, plan) to keep D7+ players moving.

## 5. Data to save
| Key | Type | Notes |
|---|---|---|
| `rebirths` | int | 0–7 at launch (v3) |
| `tithe` | number | Pre-2x lifetime cryptid income |
| `familiarId` | string | CryptidId kept through the last rebirth (analytics) |
| `everHeld1M` | bool | Shows the altar button |

Bump `dataVersion`; migration: `rebirths = 0`, `tithe = totalEarned` (best guess for testers), `everHeld1M = totalEarned ≥ 1e6`.

## 6. Server vs client
- **Server only:** cost check, the reset (one transaction inside the session-locked save), multiplier, Tithe sums, OrderedDataStore writes (`pcall`, retry next cycle). Remote `RequestRebirth(familiarUid)` with 0.25 s debounce.
- **Client:** panels, picker, board rendering from a replicated top-50 list.

## 7. Edge cases
1. **Purchase mid-rite:** lock purchases while the rebirth runs; queued receipts apply after.
2. **No cryptid placed:** picker shows inventory; if empty, rite still allowed with no familiar.
3. **Familiar is Uncommon or worse:** allowed; shows its post-rite income first so the choice is informed.
4. **OrderedDataStore fails:** keep the last good board; show "The ledger is being rewritten…".
5. **Tithe precision:** stored as an integer; fine below 2^53 (far beyond launch).
6. **Leaving during the confirm:** nothing happens until the server commits.

## 8. QA acceptance tests
| # | Test | Pass if |
|---|---|---|
| 1 | Gate | At $4,999,999 the "Begin the Rite" button is disabled with "Gather $1 more" |
| 2 | Reset | After the rite: cash $100, pads 1–2 only, altar 0, 1 familiar on Pad 1 |
| 3 | Kept | Skills, grimoire, passes, cosmetics, daily step, Tithe unchanged |
| 4 | Multiplier | A familiar Jersey Devil with all Ring 1 skills earns 150 × 1.15 × 1.5 = **$258.75/s** |
| 5 | Tiers 2–7 / tier 8 | Each tier needs its cost and Tithe gate (§2.1); at 7 the altar shows "The eighth rite is not yet written." and the server rejects an 8th rebirth |
| 6 | Tithe vs pass | Same player with 2x Cash: plaque gains $2/s per $1/s base, Tithe gains $1/s |
| 7 | Tithe excludes | Claiming daily cash or a bundle doesn't change Tithe |
| 7b | Tithe gate (v2) | $5M cash (some from bundles) but Tithe $4.0M: button shows "Tithe $4.0M / $5.0M" and stays locked |
| 7c | Boosts excluded (v2) | During a Blood Moon (spec 09 v2 §8.1) Tithe rises at the un-boosted rate |
| 8 | Board | Two test accounts appear in the right order within 240 s |
| 9 | Rejoin | Leave and rejoin after rebirth: `rebirths` kept, its multiplier still applied |
| 10b | Relic pads (v3) | Income from Pads 9–10 doesn't change Tithe; pad prices after rebirth r = price × 1.5^r |
| 10 | No offers | No MarketplaceService prompt during or right after the rite |
