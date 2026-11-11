# Spec 06: Offline Earnings, Welcome-Back Haul, Offering Bowl + Free Daily Reward

> **4 Nov 2026:** all [A] assumptions are approved by the owner as starting values, to be tuned from playtest data. Robux prices are still pending Eudai's approval.

**Owner:** Cryptid Growth Strategist · **Builder:** Cryptid Systems Architect · **Status:** Draft v2 (Wed 4 Nov 2026: day 1 claimable in session 1, no Revive Streak, tarot wording; v1 same day) · **Due:** Thu 5 Nov
**Builds on:** Specs 01, 02, 07, 09. **Paid products touched:** Auto-Collect, 2x Cash (pending Eudai approval). **Paid randomness:** none. **Not sold:** Revive Streak (spec 09 v2 §8.2).

> **[A]** = design assumption, not measured data. Grounding (research canvas): "Capped offline earnings and a welcome-back haul" is a launch must-have ("Grow a Garden's core hook"); "Free daily reward, no streak loss" is a must-have; loss aversion should be used gently ("your Mothman earned 1,200 while you were away"), avoiding "scary streak-loss and countdown pressure". Targets: D1 12%+, D7 3%+ (canvas §3, our own gates). Roblox's [Monetization](https://create.roblox.com/docs/production/monetization) page says timers that can be "removed or brought forward" are unpopular with Roblox players, so nothing here can be skipped with Robux.

---

## 1. Goal
Give every returning player a **warm, honest reason to come back**: "your lair kept earning", plus a small daily gift. No loss for missing a day, no fake timers.

## 2. Offline earnings

| Setting | Value |
|---|---|
| Efficiency | **20%** of your income per second at the moment you left [A] |
| Cap | **8 hours** of away time (covers a night's sleep or a school day) [A] |
| Minimum away | **60 s** (less = no haul, stops server-hop farming) |
| Formula | `haul = floor(rateAtLeave × 0.20 × min(awaySeconds, 28,800))` |
| Includes | Bone Altar, skills, rebirth multiplier, **2x Cash pass** (so a payer's haul doubles) |
| Excludes | Daily rewards, bundles; the Offering Bowl isn't involved |
| Available | Only after onboarding step 8 (new players have no haul) |

**Why these numbers (pacing sim, spec 07 §4) [A, model not data]:**
- Median simulated player has **~$630/s after 20 min** of play. Overnight haul: 630 × 0.20 × 28,800 = **$3,628,800**, worth ~96 min of their live income. That's big enough to feel like a real welcome-back gift and buys 2–3 Rares or most of an Epic on return.
- With one ~20-min session a day, the sim puts the **first rebirth ($5M) at the start of session 3**. So the haul pulls the rebirth goal into the D1–D3 window without making it instant.
- 20% (not 100%) keeps active play worth ~5× more than idling, so session length (10+ min target) isn't undercut.

## 3. Welcome-back haul screen
Shows on join if `haul ≥ $1` and away ≥ 5 min. Centre panel (spec 01 theme: `Ash`, `Gold` stroke, 4 px corners), 560 × 360 desktop / full-width mobile.

| Line | Text | Style |
|---|---|---|
| Title | **"While you were gone…"** | `GrenzeGotisch` 32, `Bone` |
| Body | "Your menagerie fed the coffers for **7h 42m**." | `Merriweather` 18, `Bone` |
| Haul | **+$3.63M** | `Oswald` 40, `GoldBright`, count-up 0.6 s (Reduced Motion: instant) |
| Detail | "Lairs earn at 20% while you're away, for up to 8 hours." | `Merriweather` 14, `BoneDim` |
| Cap note (only if away > 8 h) | "Your lair stops gathering after 8 hours away." | `Merriweather` 14, `BoneDim` |
| Button | **"Take the haul"** | `Blood` primary |

- Closing the panel any way (button, Esc, tap outside) **also claims**. The haul can never be lost.
- No shop link, no pass card, no offers on this screen (spec 09 v2 §7 global rules).
- Haul is added to `totalEarned` and to the Tithe (spec 07, using the pre-2x amount).

## 4. Free daily reward ("The Nightly Offering")

**Ladder (7 steps, then it turns back to step 1)**. "Income" = your current income per second **before** the 2x Cash pass.

| Step | Reward | Floor | Example at $630/s |
|---|---|---|---|
| 1 | 5 min of income | $250 | $189,000 |
| 2 | 10 min of income | $500 | $378,000 |
| 3 | **1 Snallygaster** (Uncommon, $16/s) | – | fixed |
| 4 | 15 min of income | $1,000 | $567,000 |
| 5 | 20 min of income | $2,000 | $756,000 |
| 6 | 30 min of income | $3,000 | $1,134,000 |
| 7 | **1 Flatwoods Monster** (Rare, $40/s) + 30 min of income | $5,000 | creature + $1,134,000 |

- Rewards are **fixed and shown in full in advance**. Nothing random, so no odds are needed. The ladder **never** grants tarot cards or tokens: free readings come from milestones, expeditions and events (spec 09 v2 §5.4, design bible).
- Scaling by minutes of income keeps the gift meaningful at every stage; floors cover a player with nothing placed.

**Rules**
- **Reset: 00:00 UTC.** `today = floor(os.time() / 86400)`. One claim per UTC day.
- **Missed day = pause, never reset.** You come back on the step you were on. No streak counter to lose. (Canvas: "Free daily reward, no streak loss".)
- **First session (v2): day 1 of 7 is claimable in session 1.** The HUD **"Offering"** button (bottom-left) appears once onboarding step 8 is shown **and** 3:00 of playtime have passed (~3:00 on a normal run, spec 01 v2 B3). It carries a small `Gold` pip. **In the first session the panel never opens by itself**, so nothing stacks on top of onboarding banners. The player taps when ready and leaves at **1 of 7** (design bible: endowed progress). At $17.50/s, day 1 pays 5 min = **$5,250**, enough for Pad 5 ($1,200) and Pad 6 ($3,000) before 5:00.
- If the button appears during a reveal or with a goal banner animating, it waits until that finishes [A].
- **From session 2:** the panel opens on join **after** the welcome-back screen closes (0.5 s gap), only if a claim is ready. Always also available from the HUD button with its `Gold` pip.

**No streak to revive.** A missed day only pauses the ladder, so there is nothing to lose and nothing to restore. **No "Revive Streak" product is sold** (spec 09 v2 §8.2), and this panel never shows a shop link.
- Countdown text is real: **"Next offering in 7h 12m"** (to 00:00 UTC). No "expires", no "last chance", no notifications in this build.
- Creature rewards go to inventory (or first empty pad if "Bind at once" is on, spec 03).

**UI text:** title **"The Nightly Offering"**; 7 parchment cards in a row (2 rows on mobile); current card pulses `Gold`; claimed cards show a burnt mark. Button **"Accept the offering"**. After claim: "Return tomorrow for the next offering." Missed-day note (shown once): **"The offering waited for you."**

## 5. Offering Bowl and the Auto-Collect pass
Auto-Collect needs something to collect, because spec 01 auto-credits income. Minimal mechanic [A]:
- After onboarding step 8, while your character is **outside your own lair's Threshold** (spec 02 §3), income goes into the **Offering Bowl** on your Bone Altar instead of your plaque.
- **Entering your Threshold banks the whole bowl instantly.** "Return to Lair" (spec 02) gets you there in one tap.
- **No cap, no decay, never lost.** On leave, the bowl banks to cash before saving.
- Plaque shows a 3rd line when the bowl > 0: **"In the bowl: $12.4K"** (`BoneDim`, 14 px).
- **Auto-Collect (149 R$, pending approval):** the bowl banks every 1 s wherever you are, so you can spend at the Pedlar right away.
- Auto-Collect has **no effect** on offline hauls or daily rewards.
- **Fallback:** if the Architect can't build the bowl before the 13 Nov freeze, **drop Auto-Collect from launch** and keep plain auto-credit. Don't sell a pass that does nothing.

## 6. Data to save
| Key | Type | Notes |
|---|---|---|
| `lastSeenUnix` | int | Written on every save (autosave 60 s, leave) |
| `offline.rate` | number | Income/s at last save, **with** 2x pass |
| `offline.rateNoPass` | number | Same without 2x, for Tithe |
| `bowl` | number | Server only; banked on Threshold enter / leave |
| `daily.step` | int 1–7 | Next step to claim |
| `daily.lastClaimDay` | int | UTC day number of last claim |
| `daily.totalClaims` | int | Analytics |

Bump `dataVersion` by 1; migration sets `daily.step = 1`, `daily.lastClaimDay = -1`, `bowl = 0`, `lastSeenUnix = now`.

## 7. Server vs client
- **Server:** computes the haul on load from `os.time()` (never client time), grants it, runs the bowl, checks the daily day number, grants rewards. Remotes: `RequestClaimHaul()`, `RequestClaimDaily()` (both idempotent).
- **Client:** panels, count-up, countdown display from a replicated `NextDailyUnix`.

## 8. Edge cases
1. **Clock oddities:** `away < 0` → 0. Haul uses `lastSeenUnix` from the session-locked save, so two servers can't both pay.
2. **Crash:** last autosave ≤ 60 s old, so at most ~60 s of `lastSeen` drift. Acceptable.
3. **Join at 23:59 UTC, claim, again at 00:00:** allowed (it's a new day).
4. **Rebirth:** `daily.step` kept; offline rate updates at next save.
5. **Income $0 at leave:** no haul screen; daily floors still pay.
6. **Pass bought mid-session:** next save updates `offline.rate`.
7. **Player in the Wilds when the server shuts down:** bowl banks on leave.

## 9. QA acceptance tests
| # | Test | Pass if |
|---|---|---|
| 1 | Offline maths | Leave at $100/s, set lastSeen 2 h back: haul = 100 × 0.2 × 7,200 = **$144,000** |
| 2 | Cap | Away 20 h at $100/s: haul = **$576,000** (8 h cap) and cap note shows |
| 3 | Short away | Away 45 s: no haul, no screen |
| 4 | Close = claim | Closing with Esc credits the haul once |
| 5 | Daily pause | Claim step 2, skip 3 UTC days, rejoin: step 3 offered, no reset |
| 6 | Daily reset | Claim at 23:59 UTC; at 00:00:05 UTC a new claim is ready |
| 7 | Double claim | Firing `RequestClaimDaily` twice in a day grants once |
| 8 | Day 1 in session 1 | Fresh account, normal run: Offering button + `Gold` pip appear at step 8 shown + 3:00; **no panel auto-opens** in session 1; tapping lets you claim step 1 and the ladder shows 1 of 7 |
| 9 | No streak sale | No Revive Streak product exists; daily panel has no shop link or Robux text |
| 8 | No offers | No MarketplaceService prompt or shop card on the haul or daily panel |
| 9 | Bowl | Walk into town at $100/s for 60 s: bowl ≈ $6,000; stepping into own Threshold banks all of it |
| 10 | Auto-Collect | With the pass, bowl stays $0 and plaque rises each second in town |
