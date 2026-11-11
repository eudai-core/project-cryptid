# Spec 16: UI psychology — engagement and purchase (visual pass #17)

**Owner:** Studio lead · **Builder:** Cryptid World Builder · **Status:** Draft v1 (Wed 11 Nov 2026) · **For:** UI and visual pass [#17](https://github.com/eudai-core/project-cryptid/issues/17)
**Builds on:** specs 06–10, 14, 15, `compliance-audit-cash-random.md`, `ops/handoff-growth-strategist.md`. Does **not** change gameplay numbers, prices or economy formulae.
**[A]** = assumption or design judgement, not a measured result. Every research claim has a URL. Do not invent conversion rates or cite unsourced figures.

This brief tells the World Builder how to make Hollowmere's UI feel good and convert honestly. The science explains *why* a moment should feel a certain way; approved specs 01–15 still decide *what* the game does.

---

## Hard limits (policy + our specs)

Roblox policy and Eudai's 4 Nov decision already ban the dark patterns this research is often used to justify. This brief never overrides them.

- **No paid random items** except January **Server Luck**, PolicyService-gated, live odds shown ([paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items); specs 09, 15). Cash is paid currency (`compliance-audit-cash-random.md`). Variants, readings and cases stay earn-only.
- **No fake urgency:** no invented stock limits, no inaccurate or restarting countdowns, no "always on sale" fake discounts, no "expires" / "last chance" copy ([Monetization](https://create.roblox.com/docs/production/monetization); [Presenting Experience Items](https://en.help.roblox.com/hc/en-us/articles/47965051378324-Presenting-Experience-Items-and-Subscriptions)).
- **No pressure language toward minors.** Prefer "**View Item**", "**See Price**", "**Open Shop**" — never "GET IT NOW", "LAST CHANCE, ACT NOW", "BUY BEFORE IT'S GONE!" ([Promoting Items to Younger Audiences](https://en.help.roblox.com/hc/en-us/articles/47965190783892-Promoting-Items-to-Younger-Audiences)).
- **No fake players**, hidden purchases or decorative NPCs that are secretly shops (spec 15 §3).
- **No shop prompts** on the welcome-back haul, Nightly Offering, Rite of Rebirth, bind/reveal, or world-event omen (specs 06, 07, 09; spec 14 §11). Shop nudges wait until onboarding step 8 **and** 5:00 of play.
- **No streak-loss products.** The daily ladder pauses, it never resets; Revive Streak is not sold (spec 06, handoff).

---

## 1. Reward anticipation and dopamine loops

Dopamine neurons fire most when a reward is **better than predicted**, stay quiet when it arrives exactly as expected, and dip when a predicted reward is missing. The cue that *predicts* a reward also starts to carry that signal ([Schultz, 1998](https://journals.physiology.org/doi/full/10.1152/jn.1998.80.1.1)). During the wait before an uncertain reward, activity rises with uncertainty and is strongest when the outcome is most unpredictable ([Fiorillo, Tobler & Schultz, 2003](https://www.science.org/doi/10.1126/science.1077349)).

**Use in Cryptid**

- The **3-second hold-to-bind** (beam in the player's colour, rune circle, rarity ring; spec 15 §4) is the anticipation window. Keep the cue language consistent so the brain learns "this hold predicts a BOUND!".
- **Variable earned rewards** (wild rarity, later variants, earned readings) supply honest uncertainty. Paid offers must stay fully known: exact contents on the card before Robux is spent (spec 09 §9.5).
- **Escalate juice with rarity**, not with every catch equally, or common binds will habituate (Schultz: fully predicted rewards stop surprising). Spec 14 already times reveals: Common 0.6 s, Uncommon 1 s, Rare 2 s, Epic 3.5 s. Keep those proportions in the bind burst and wax-seal.
- **Collect juice:** every successful action (bind, pad collect, daily claim, haul take) needs clear, lively feedback — squash, particles, a short sound — "maximum output for minimum input" ([Jonasson & Purho, GDC, *Juice It or Lose It*](https://www.gdcvault.com/play/1016487/juice-it-or-lose)). Stay inside spec 15 VFX budgets (≤6 emitters / 120 particles per effect; Low-quality fallback; Reduced Motion shortens, never lies).
- **Near-miss tension, honestly only.** Near-misses feel unpleasant but raise desire to continue, and they recruit some of the same circuitry as wins ([Clark et al., 2009](https://doi.org/10.1016/j.neuron.2008.12.031)). We allow two honest forms: (1) a contested bind you lose, followed by **assist cash** (spec 11 / 15); (2) an earned Fate Reel that settles with a real higher-tier neighbour in the strip (spec 09 §5.5, spec 10). **Never** animate a paid offer as "almost" a better item, and **never** invent a near-miss the server did not roll. Overriding rule, unchanged: **no visual may imply a higher tier than the one rolled.**

---

## 2. Emotion in reveals and catch moments

People judge an episode mainly by its **peak** and its **end**, and they neglect how long it lasted ([Kahneman, Fredrickson, Schreiber & Redelmeier, 1993](https://journals.sagepub.com/doi/10.1111/j.1467-9280.1993.tb00589.x)). Roblox UX guidance is the practical twin: missing or weak feedback leaves players unsure whether an action worked ([UI and UX design](https://create.roblox.com/docs/production/game-design/ui-ux-design)).

**Use in Cryptid**

- The catch episode should peak on the **wax-seal "BOUND!"** and *end* on the **Stat Card**, not on a shop modal. The card is the "dossier" (spec 14 §1): portrait, name, rarity *word* (not colour alone), income, source, NEW seal on a first species. Let the player dismiss it; do not auto-queue Relics.
- Rarity is felt in colour, sound and duration (Blood crimson for Epic banners, spec 08; no false Mythic tease). Common catches stay short and quiet; Epic earns the bell and the longer seal (spec 14).
- A lost contest still needs a clean end: the other player's bind resolves, you see assist cash, no "you missed it!" (spec 08).

---

## 3. Progress goals and completion drive

Giving people a head start on a goal raises completion: a car-wash card that needed 10 stamps but started with two was redeemed at **34%**, versus **19%** for an 8-stamp card with no head start ([Nunes & Drèze, 2006](https://academic.oup.com/jcr/article-abstract/32/4/504/1787425); PDF: [Wharton copy](https://faculty.wharton.upenn.edu/wp-content/uploads/2012/04/PSC.pdf)). Effort also rises as the goal gets closer ([Kivetz, Urminsky & Zheng, 2006](https://journals.sagepub.com/doi/10.1509/jmkr.43.1.39)). Collectors are specifically motivated to **finish a set** ([Carey, 2008](https://doi.org/10.1016/j.joep.2007.08.002)).

**Use in Cryptid**

- Nightly Offering already uses endowed progress: day 1 is claimable in session 1, leaving the player at **1 of 7**, with every future step shown in advance (spec 06). Keep the current card pulsing Gold and claimed cards marked.
- Rebirth and pad unlocks need a **visible remainder**: cash toward the rite, Tithe gate bar, next pad price (spec 07). The bar should move during play, not only when the panel opens [A].
- Bestiary / Grimoire should always show **X of 12 bound**, NEW stamps, and the next cryptid's spawn condition (spec 15 §10). Completion is the hook; do not hide remaining species behind a paywall.

---

## 4. Gently used loss aversion

People weigh losses more heavily than equal gains ([Kahneman & Tversky, 1979](https://web.mit.edu/curhan/www/docs/Articles/15341_Readings/Behavioral_Decision_Theory/Kahneman_Tversky_1979_Prospect_theory.pdf)). Used badly, this becomes streak-loss and countdown pressure, which our design bible and spec 06 already reject. Used gently, it means **framing real gains** and being honest about real irreversible choices.

**Use in Cryptid**

- Welcome-back haul: **"While you were gone…" / "Your menagerie fed the coffers"** — a gain you cannot lose, even if you close the panel (spec 06).
- Offering Bowl plaque: **"In the bowl: $X"** is money waiting, not money about to vanish. The bowl has no cap, no decay, and never expires (spec 06 §5).
- Rebirth lists **"You keep"** and **"You lose"** in plain language, shows post-rite income for the chosen familiar, and requires a second confirm with **Yes / Not yet**. No timer on the confirm (spec 07).
- Never copy "you missed it", "only X left", or "your streak is broken". Missed daily: **"The offering waited for you."**

---

## 5. Social proof

When people can see what others chose, popular options become more popular ([Salganik, Dodds & Watts, 2006](https://www.science.org/doi/10.1126/science.1121066)). Roblox players also respond to social, immediately visible items ("tourists" want effects others will notice; "locals" want lasting benefits) ([Monetization](https://create.roblox.com/docs/production/monetization)).

A survey of concrete purchase reasons found **unobstructed play**, **social interaction** and **economical rationale** positively associated with how much players spent; competition was identified as a separate dimension and was not reported among those positive associations ([Hamari et al., 2017](https://doi.org/10.1016/j.chb.2016.11.045)). That is why Tithe excludes bought cash, passes and Relic pads (spec 07): a pay-to-rank board would cost trust for no evidenced spend gain.

**Use in Cryptid**

- Server banners for **real** Epic / Shadow wild or Rift-belt catches, and thank-you banners for **server-wide** boosts, naming DisplayName only, with **no price and no buy link** (spec 08). The old word was Corrupted.
- The **Ledger of Tithes** in the plaza is the always-on popularity signal. It must stay play-earned.
- Cosmetics (Founder's Candle, nameplate, auras) should be readable in town, so social proof is the item itself, not a fake crowd.

---

## 6. Shop and purchase psychology

Roblox's own foundations: a shop should be **integrated** (easy to find, jump in and out without breaking play), **contextual** (name + price is not enough; say what the item does next to alternatives), and **inviting** (a place to browse). Item copy must be accurate so players know exactly what they are buying. Merchandising should **preview** rewards. A starter pack is defined as an early offer of a known bundle ([Monetization foundations](https://create.roblox.com/docs/production/game-design/monetization-foundations)). Contextual prompts belong at the *right item, right time*; do not stack modals; do **not** put a starter pack on the very first load screen ([Contextual purchases](https://create.roblox.com/docs/production/game-design/contextual-purchases)). Skippable appointment timers are unpopular with Roblox players ([Monetization](https://create.roblox.com/docs/production/monetization)).

Hamari's three spend-linked motives map onto our catalogue without new products:

- **Economical rationale:** honest framing only. Cash bundles may label the Vault **"Most cash per Robux"** because the minutes-per-Robux maths is literally true; no fake "% bonus" or "was" prices (spec 09 §8). **2x Cash** shows income now and income with the pass (spec 09).
- **Unobstructed play:** Auto-Collect, Instant Expedition Return (January, only after the loot is already shown). Do not invent a blocker in order to sell the removal.
- **Social interaction:** gifts of cosmetic/convenience passes, nameplates, server-wide Blood Moon (no "buy one too" on the thank-you banner).

**First purchase.** Relics header already states: *"Your first Relic also lights a Founder's Candle."* Combined with the 49 R$ Starter Pack at the **top of Relics on first visit**, until owned, this is the low-friction first purchase (spec 09 §9.1). No timer, no "expires". Preview the Hidebehind and the $5,000 on the card. [A] Naming the gift in the header is enough; do not add a countdown or a blocking modal.

**Placement.** Relics / Pedlar / Lanternwright are the shops. HUD shop entry is persistent and on-brand, but prompts never interrupt a bind, reveal, haul, daily claim, rite or omen. After step 8 + 5:00, a quiet pip on the shop button is enough [A]. Pedlar stock is previewed in the cages before cash is spent (spec 09 §4).

---

## 7. What we will not do

1. Sell random crates, mystery cages, luck boosts (except gated Server Luck), or any bundle whose result is not shown first.
2. Fake a near-miss, tease a higher rarity, or play a win fanfare on a loss.
3. Use fake scarcity, restarting timers, or "deal of the day" that never ends.
4. Use "GET IT NOW" / "LAST CHANCE" / "only X Robux" pressure copy, or "only" / "just" to shrink a price in front of younger players ([Advertising Standards](https://en.help.roblox.com/hc/en-us/articles/13722260778260-Advertising-Standards) spirit, applied to in-experience merchandising).
5. Punish a missed day, sell a streak repair, or imply the haul or bowl will be lost if you close the panel.
6. Announce personal Robux purchases, or put a buy link on a catch or boost banner.
7. Staff the plaza with fake players or bots to simulate a crowd.
8. Auto-prompt the shop during the first session's onboarding, on first load, or on top of another modal.
9. Change rarity, spawn or variant odds with a cash tool or lantern (spec 15 §5).

---

## 8. UI rules for the World Builder (apply in Studio)

Each rule is for a named screen. If a rule and a numbered gameplay spec conflict, the gameplay spec wins and the conflict is flagged, not silently patched.

1. **Bind and BOUND! reveal.** During the 3 s hold, play the lantern beam, ground rune and rarity ring as one rising cue. Burst and wax-seal **"BOUND!"** scale with rarity (Common short/quiet; Epic longer, low bell at 0.4). Charge colour and VFX **stop at the true tier**. Reduced Motion: shorter motion, same seal and tier. Then open the Stat Card; never open Relics here.
2. **Stat Card.** After every catch (and later every earned reading), show portrait, name, rarity word + symbol, base and placed income, source, and a **NEW** seal on first species. Primary button **Bind / Place**. No Robux, no "View Item", no offer card on this panel.
3. **Pad collect and Offering Bowl.** Bank or collect with a 0.6 s GoldBright count-up (instant under Reduced Motion) and a small budgeted burst. Copy is a gain: "Your Hodag earned **$X**" / "In the bowl: **$X**". No decay, cap or "claim now or lose it" wording.
4. **Relics shop.** After step 8 + 5:00, Starter Pack sits at the top until owned, with Hidebehind + $5,000 + Founder's Candle previewed on the card. Every product uses **View Item**, a live preview, and exact contents. **2x Cash** shows current income vs income with ×2. Only genuine value labels (Vault = "Most cash per Robux"). Buttons say **View Item** / **See Price** / **Open Shop**. No auto-modal, no stacked prompts, no restarting sale timer.
5. **Pedlar and cash offers.** The caged cryptid, variant badge and price are visible before purchase. Odds sit behind a button labelled **"Details"**. Buying never rerolls, restocks or plays a rarity reveal fanfare. No sky, no banner (not a free source).
6. **Rite of Rebirth.** Show cost, Tithe gate bar, next multiplier, **"You keep"** / **"You lose"**, and the familiar's post-rite income before confirm. **Begin the Rite** then **Yes / Not yet**. No countdown, no shop card, no "act now". After the rite, a short toast: "You are reborn. Income ×{mult}."
7. **Nightly Offering and welcome-back haul.** Seven cards in a row (two rows on mobile); current step pulses Gold; later rewards stay visible (endowed progress). Claim copy: **"Accept the offering."** Missed day: **"The offering waited for you."** Countdown is only the real time to 00:00 UTC ("Next offering in 7h 12m"). Haul title **"While you were gone…"** with count-up; close = claim. Neither panel links to the shop.
8. **Social proof surfaces.** Epic/Shadow banners and Blood Moon thank-yous fire only for server-authoritative events, use DisplayName, last 4 s, and never include a price or shop link. The Ledger of Tithes in the plaza is the standing social signal. No simulated player counts, no ghost avatars.
9. **Contested bind, lose side.** If another player finishes first, resolve their BOUND! in world, then toast the loser's **assist cash**. No "you almost had a Jersey Devil" unless that species was actually on the pad. No shop offer on the loss toast.
10. **Bestiary / next-goal HUD.** Keep a compact **X of 12 bound** (or current roster size) and the next rebirth or pad remainder in view during play. Tapping the collection chip opens the Grimoire at the next unfound species and its published spawn condition. Never gate that information behind Relics.

**Verification:** QA compares these screens to the rules above and to `docs/VISUAL_REFERENCES.md`. A pass needs a clip or screenshot of each named moment, plus a check that no shop modal appears on haul, daily, rite, bind or event screens.
