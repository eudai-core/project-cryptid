# Spec 11: Multiplayer loop, competition and economy pacing

**Owner:** Cryptid Growth Strategist · **Builder:** Cryptid Systems Architect · **Visuals:** Cryptid Art Director · **Status:** v1.1 (Wed 4 Nov 2026; approved as design base by Grok Bot) · **Freeze:** Fri 13 Nov · **Launch:** Fri 20 Nov
**Builds on:** specs 01–10. **This spec doesn't rewrite them.** Every value it changes is listed in §11 "Changes to earlier specs"; those files stay as they are until the owner approves.
> **Change note (v1.1, 4 Nov):** Grok Bot ruling: §4.2B Blood-marked hunts run **only in free-started Blood Moons** (random, Witching Hour, Blood Moon Night). A Robux-gifted Blood Moon is income + look only (spec 09 §8.1, spec 12 §6).

**Paid products touched:** none new. **Robux prices:** none here (all prices in spec 09 stay PROPOSED, pending Eudai approval).

> **Tarot decision note:** spec 11 holds **whichever way the tarot decision goes** (paid readings and paid Server Luck kept, or made earn-only). The pacing sims, the light-spender model and every competitive rule here use **no** paid readings and **no** paid Server Luck.

> **[A]** = design assumption. **All pacing numbers in §2 are MODEL OUTPUT from our own sim (`specs/tools/pacing_sim.py`) on our own spec numbers. They are not benchmarks** and must be re-tuned from playtest data. No outside statistics are used in this spec.

---

## 1. Goals (Eudai, 4 Nov) and the short answer

| Goal | How this spec does it |
|---|---|
| **Not completable fast** (players who "finish" quit) | A 7-tier rebirth ladder at launch, with costs ×3 per tier and a multiplier that grows only +0.5 per tier. Sim: a free player needs **~6 weeks** (2 × 20 min a day) to reach the launch cap. Then come Spectral/Shadow variants (~10–13 weeks), mastery, and later layers (§2.6) |
| **Clear rules for how the 8 players interact** | Contested wild spawns (first to *finish* the catch wins; others get an assist). Co-op server rites. Plot likes. A non-toxic "Echo" steal that never takes a cryptid (§4–§5) |
| **Competition** | The existing Tithe board, plus a weekly global **Hunt** board (cosmetic rewards, can't be bought), plus short in-server races (§5) |

---

## 2. Pacing targets backed by the sim

### 2.1 The model (all [A])
- **Player:** greedy. Buys every skill, pad and altar level that pays back within 1 h, replaces the weakest pad whenever a better cryptid is offered, buys cheap new species for the Bestiary, then saves for the next rebirth.
- **Sessions:** **2 × 20 min a day** (16:00 and 20:00 UTC) [A]. Offline gaps are 3 h 40 m and 19 h 20 m; each haul is capped at 8 h (spec 06).
- **Real spec numbers used:**
  - **Onboarding end:** ~2:37 with pads 1–4 filled and Altar I (spec 01 v2).
  - **Rift belt:** 1 every 10 s, odds 72 / 24 / 3.6 / 0.4. **Wilds:** 1 every 45 s, odds 80 / 16.4 / 3.4 / 0.2, free. **Pedlar:** 4 slots every 300 s (spec 09 §4).
  - **Prices:** income × payback.
  - **Pads 3–8:** $120 / $400 / $1,200 / $3,000 / $15,000 / $40,000 (specs 02, 07).
  - **Ring 1:** $34,000 (spec 05).
  - **Rebirth 1:** $5M, ×1.5, Tithe gate (spec 07).
  - **Offline:** 20%, capped at 8 h. **Daily ladder:** 7 steps (spec 06).
- **F2P** = no purchases.
- **Light spender** = **Starter Pack 49 + 2x Cash 299 + +2 Pads 199 = 547 R$**, all bought in session 1. That's passes and the Starter Pack only: **no paid readings, no Server Luck, no cash bundles.**
- **Not modelled:**
  - Ring 2 (Update 2).
  - Mastery bonus (Update 1; max +5% on one species).
  - Events, likes, assists, races.
  - Wild catches as income: they're counted, but they only replace pads when better.

### 2.2 Formulas (proposed)

| Thing | Formula | Why |
|---|---|---|
| **Rebirth tier n cost** | `5,000,000 × 3^(n−1)` | Each tier costs 3× the last. Income grows far less (below), so each tier takes longer |
| **Rebirth multiplier** | `rebirthMult = 1 + 0.5 × n` (spec 07 formula, now used past n = 1) | Linear, so each tier's *relative* gain shrinks: +33%, +25%, +20%, +17%… This is the **soft cap** |
| **Tithe gate (unbuyable)** | Tier 1: Tithe ≥ $5M (spec 07). Tier 2: Tithe ≥ the sum of costs 1..2. Tier 3+: Tithe ≥ **0.75 ×** the sum of costs 1..n | Cash from bundles or 2x Cash can't skip tiers (keeps the light spender under ~2×, §2.5) |
| **Pad price after r rebirths** | `spec price × 1.5^r` (Masons' Rite −10% still applies) | Rebuild cost rises faster than the +0.5 multiplier |
| **Bone Altar** | Levels I–II as spec 01 (+0.25 each, or +0.30 with l3). **Level L ≥ 3 adds `0.25 × 0.75^(L−2)`** (×1.2 with l3). Cost table below, **× 1.5^r** after r rebirths | Diminishing returns (soft cap ×2.25, or ×2.7 with l3, as levels → ∞) |
| **Launch max rebirth** | **7** | ~6 weeks for F2P (§2.4) |
| **Ring 2 skill prices** (Update 2) | `$2.5M × 4^(k−1)` for the k-th Ring 2 node bought in a branch, and **Rebirth ≥ 2** to open | Ring 1 is a first-session toy ($34k); Ring 2 must sit at rebirth-era prices [A, not simulated] |

**Rebirth ladder (sim input):**

| Tier | Cost | Income mult after | Tithe gate | Pad price × |
|---|---|---|---|---|
| 1 | $5,000,000 | ×1.5 | $5M | ×1.50 |
| 2 | $15,000,000 | ×2.0 | $20M | ×2.25 |
| 3 | $45,000,000 | ×2.5 | $49M | ×3.38 |
| 4 | $135,000,000 | ×3.0 | $150M | ×5.06 |
| 5 | $405,000,000 | ×3.5 | $454M | ×7.59 |
| 6 | $1,215,000,000 | ×4.0 | $1,365M | ×11.39 |
| 7 (launch cap) | $3,645,000,000 | ×4.5 | $4,099M | ×17.09 |
| 8–10 | Update 2 (with Legendary roster + Ring 2), same formulas | ×5.0–×6.0 | same rule | same rule |

**Bone Altar III–X** (base cost before × 1.5^r):

| Level | I | II | III | IV | V | VI | VII | VIII | IX | X |
|---|---|---|---|---|---|---|---|---|---|---|
| Cost | $300 | $1,500 | $8,000 | $40,000 | $200,000 | $1M | $5M | $25M | $125M | $625M |
| Total mult | ×1.25 | ×1.50 | ×1.688 | ×1.828 | ×1.934 | ×2.013 | ×2.072 | ×2.117 | ×2.150 | ×2.175 |
| With l3 | ×1.30 | ×1.60 | ×1.825 | ×1.994 | ×2.120 | ×2.215 | ×2.286 | ×2.340 | ×2.380 | ×2.410 |

### 2.3 Rule to stop "pay = rank"
**Tithe** (spec 07) now also **excludes income from Relic pads 9–10** (the +2 Pads pass). It already excludes 2x Cash, Blood Moon, bundles and daily rewards. So both the Tithe board and the rebirth gate count **only play a free player could match**.

### 2.4 Sim output (MODEL OUTPUT, 200 seeds each; `python3 specs/tools/pacing_sim.py`, saved in `tools/pacing_sim_output.txt`)

| Milestone | F2P active hours (median, p10–p90) | ≈ day (2 × 20 min) | Light spender (547 R$) | ≈ day | F2P ÷ spender |
|---|---|---|---|---|---|
| Finish Ring 1 | 0.2 h (0.2–0.2) | 1 | 0.1 h (0.1–0.1) | 1 | 1.69× |
| Rebirth 1 | 0.7 h (0.6–0.7) | 2 | 0.6 h (0.3–0.7) | 2 | 1.18× |
| Full 12-cryptid launch Bestiary | 0.6 h (0.4–1.1) | 2 | 0.5 h (0.3–1.0) | 2 | 1.17× |
| Rebirth 2 | 1.3 h | 3 | 1.0 h | 3 | 1.33× |
| Rebirth 3 | 2.0 h | 4 | 1.3 h | 3 | 1.50× |
| Rebirth 4 | 3.3 h | 6 | 2.7 h | 5 | 1.26× |
| Rebirth 5 | 6.2 h | 10 | 4.7 h | 8 | 1.34× |
| Rebirth 6 | 12.7 h | 20 | 10.0 h | 16 | 1.27× |
| **Rebirth 7 (launch max)** | **28.7 h** (28.3–29.2) | **~44 (6 weeks)** | **23.0 h** (22.7–23.3) | **~36** | **1.25×** |
| All 12 **Spectral** | 45.3 h (24.8–71.2) | ~69 | 45.3 h | ~69 | 1.00× |
| All 12 **Shadow** | 60.6 h (41.6–76.1) | ~92 | 59.2 h | ~90 | 1.02× |

**Reading it:**
- **Day 1–2 feels fast on purpose:** Ring 1, Rebirth 1 and the full launch Bestiary (spec 07 goal: rebirth in the D1–D3 window).
- **Then each tier takes about twice as long as the last** (rebirth 4 → 5 → 6 → 7: about 3, 6, 13 and 29 active hours). That's the soft cap working.
- **The launch Bestiary of 12 is quick (day 2).** So the long tail comes from **variants** (§3.2, ~10–13 weeks), **mastery** (§3.4), and new species in weekly updates.
- **Pay-to-win check: PASS.** The light spender is faster at every milestone, but **never more than 1.69×** (worst case: Ring 1, which is minutes). It's **1.18–1.50× for every rebirth**, under the ~2× ceiling. The script exits 1 if any milestone goes over 2×.
- **Trade-off for Eudai:** the Tithe gate means 2x Cash speeds up late rebirths only ~1.25×. That's the honest price of "no pay-to-win". The passes still feel strong early on (Ring 1 1.7×, Rebirth 3 1.5×).

### 2.5 Things tried and rejected (sim)
- **Rebirth cost ×4 per tier, cap 6:** rebirth 6 took ~63 days, with a 42-day wall from tier 5 to tier 6. Too steep.
- **Tithe gate = 1.0 × costs for every tier:** the light spender's late speed-up fell to ~1.01×, so the passes did nothing late. **Gate 0.5–0.7× for every tier:** the spender hit **2.00× at Rebirth 2**, which fails the check. So the mixed rule was chosen: tier 2 at 1.0×, tier 3+ at 0.75×.

### 2.6 Later layers (outline, Update 2+)
- **Update 2:** rebirth tiers 8–10 (same formulas), Ring 2 (§2.2 prices), Legendary roster.
- **Ascension (second prestige, January or later) [A]:**
  - Available at Rebirth 10.
  - Resets rebirths to 0.
  - Grants **Ash Sigils** = `floor(sqrt(Tithe earned since the last Ascension ÷ 1e9))`.
  - Sigils buy **permanent, small** perks: +2% income per perk, max +20%. They also buy cosmetics.
  - **Sigils can never be bought with Robux.** This needs its own spec and its own sim before it's built.

---

## 3. Long-tail sinks

### 3.1 Rebirth layers
See §2.2 and §2.6. The rebirth panel (spec 07 UI) now shows the next tier's cost, the Tithe gate bar and the new multiplier. Tier 8+ tooltip: **"The eighth rite is not yet written."**

### 3.2 Bestiary variants: spec 15 names (true odds)

The `mutation` values are Normal, Spectral, Gilded, Shadow, and Moonlit. The weights below stay on Normal, Spectral, and Shadow. Gilded and Moonlit are named and have no separate column in this verified table.
- **Rolled by the server after** rarity and species, independently. **Luck never changes variant odds** (paid or free, now or later).
- **Cosmetic only:** the same income as the normal cryptid. Spectral and Shadow each add a Bestiary page. Gilded and Moonlit are named and are not in that page count. Variants count for mastery.
- **Seen before buying:** Rift belt and Pedlar offers show the variant before you pay, so buying one isn't a paid random item.

| Source | Normal | Spectral | Shadow | Total |
|---|---|---|---|---|
| Wild spawns | 98.6% | 1% | 0.4% | **100%** |
| Rift belt | 99.3% | 0.5% | 0.2% | **100%** |
| Pedlar (every slot) | 99.3% | 0.5% | 0.2% | **100%** |
| Tarot readings (January; free = paid) | 99.3% | 0.5% | 0.2% | **100%** |
| Daily ladder, Starter Pack, Essence crafts | 100% | 0% | 0% | **100%** (fixed, not random) |

- **Per species:** multiply by the spec 09 species odds. Example: a Shadow Jersey Devil from the Wilds is 0.1% × 0.4% = **0.0004%**.
- `verify_odds.py` now checks every variant table **and** every full species × variant table (36 outcomes for the Wilds) sums to exactly 100%.
- **Look (Art Director):**
  - **Spectral:** a pale **Bone `#E8E0CF` / GoldBright `#C9A55A`** sheen with a slow glint, every 3 s, never a strobe.
  - **Shadow:** a darker body with thin **Rift `#7FA34A`** veins and a faint Rift smoke trail.
  - **No purple.**
  - Badge on cards: "✦ Spectral" (GoldBright) or "☍ Shadow" (Rift).
- **Announcements (spec 08):** a **Shadow** catch from the Wilds or Rift belt, any rarity, gets the spec 08 server banner (same rate limits). Spectral gets only the catcher's toast.

### 3.3 Essence sinks (spec 10 §7; January, with the Tarot Table)
Essence stays **readings-only and never sold** (spec 10 §7.5). New deterministic sinks:

| Sink | Cost | Notes |
|---|---|---|
| **Spectral Rite:** turn one owned cryptid into its Spectral | 300 | Deterministic; you choose. Doesn't count toward the "found" Spectral Bestiary page, which needs a rolled Spectral, so the chase stays [A] |
| **Shadow Rite:** turn one into its Shadow | 1,000 | Same rule |
| Mastery frame dye (§3.4) | 50 | Cosmetic |
| Lair Ward Candle skins (Update 3) | 100 | Cosmetic |

- **Tarot fallback:** if readings become earn-only, these sinks are unchanged.
- **Also unchanged if readings stay paid:** Essence partly comes from paid readings, but these sinks are cosmetic and outside competitive metrics.

### 3.4 Per-cryptid mastery (Update 1)
- Each species counts **obtains**: catches, purchases, daily rewards and readings. **Echoes (§5.4) and assists don't count.**

| Level | Obtains | Bonus (that species only) | Cosmetic frame on its card and pad |
|---|---|---|---|
| 1 | 5 | +1% income | Bone `#E8E0CF` rim |
| 2 | 15 | +2% | Silver `#8C9AA3` rim |
| 3 | 40 | +3% | Gold `#9C7A3C` rim |
| 4 | 100 | +4% | Blood `#7A0F12` rim, Bone inner line |
| 5 | 250 | +5% (cap) | GoldBright `#C9A55A` filigree + Rift `#7FA34A` ember |

- Max effect: +5% on one species. That's too small to change the pacing above, so it's not simulated [A]. Mastery is **kept through rebirth**.

---

## 4. Server interaction (the 8-player rules)

### 4.1 Contested wild spawns
- **Spawns:** the spec 09 rate stays (1 every 45 s per player, max 3 alive per player) and they still appear behind each player's Wild Gate.
- **Anyone can hunt any spawn.**
- **The rule:** **whoever COMPLETES the catch timer first wins the cryptid.** That timer is the spec 05 catch time (3.0 s, down to 2.25 s with skills) while within catch range (12–14 studs).
- **Server-authoritative:**
  - `RequestStartChannel(spawnId)` makes the server record `startedAt` and check range.
  - The server checks range every 0.25 s; leaving range or taking damage cancels.
  - The catch completes **on the server** at `startedAt + catchTime`. The client never says "I finished".
- **Ties:** if two catches complete on the same server step, the winner is the **first `RequestStartChannel` received** (server receive order).
- **Assist:**
  - Who qualifies: any other player who channelled the same spawn for **≥ 1.0 s** and was **in range** when it was won.
  - What they get: an **assist** = **30 s of their own pre-2x income** (minimum $50) in cash. **No cryptid, no Essence.** Spec 10 keeps Essence readings-only so it can't flood [A].
  - Toast: "Assist · +$4.2K" (BoneDim text, Gold number).
- **First-sight window [A]:** a spawn behind *your* gate is visible to you **2 s** before it shows to others. That's a head start, not a lock, so the first-to-finish rule still decides. It stops other players camping your sector from beating you to every spawn.
- **Spawn placement:** each spawn appears **≥ 40 studs from every player except the gate's owner**, so nobody can stand on a spawn point.

### 4.2 Co-op events
**A) The Hollow Rite (server goal, Update 1)**
- **When:** every **30 min** of server uptime, a 10-minute rite starts. "The Hollow hungers: catch 40 cryptids together."
- **Counts:** wild catches only. Assists count **½**.
- **Tiers on the server total:** Ember 25, Flame 40, Inferno 60.
- **Reward to each qualifying contributor:**
  - Ember: 5 min of their own pre-2x income.
  - Flame: 10 min.
  - Inferno: 15 min + a cosmetic Rite Candle for the lair, once per tier per week.
- **Minimum contribution:** **3 catches** in that rite. **AFK players get nothing.** A catch needs an active channel and range checks, so idlers can't contribute.
- **Scaling with fewer players [A]:** 2–4 players → goals ×0.5; 5–6 → ×0.75; 7–8 → ×1.

**B) Blood Moon hunts (Update 1, with Server Blood Moon from spec 09 §8.1, and the free monthly Blood Moon Night)**
- During a **free-started** Blood Moon only (random, Witching Hour or Blood Moon Night; **never** a Robux-gifted one, spec 12 §6), **Blood-marked** wild spawns appear: 1 every 90 s, server-wide, contested by §4.1 rules.
- Catching one: the normal cryptid + **2 min of pre-2x income**. Assists: 30 s.
- Same for everyone in the server. A **gifted** (Robux) Blood Moon adds **no** spawns, focus or odds changes, only income + look. **Blood Moon income still doesn't count toward Tithe or any board.**

### 4.3 Plot visiting and likes (LAUNCH stretch)
- **What:** visitors (spec 02 §6 rules) see a **"Leave a candle"** prompt at the Lair Gate. A candle is a like.
- **Who can like:** one like per player per plot per UTC day.
- **Rewards:**
  - **Owner:** **1 min of pre-2x income per like**, rewarded likes capped at **10 per UTC day**. After that, likes still count on the board but pay nothing.
  - **Liker:** 15 s of income for each of their **first 5 likes** a day.
- **Anti-farm:** a liker's like only counts if the liker's account is **≥ 7 days old** and they have **≥ 30 min** of total playtime in Cryptid [A]. Likes between the **same pair** pay at most once a day either way.
- **Lair liked count:** lifetime candles, shown on the owner banner: "🕯 128" (Bone on Blood).

### 4.4 Social proof
- **Keep:** spec 08 announcements (Epic catches, boost buyers), the Ledger of Tithes slab, and the Mythic sky on every free source (spec 10 v1.2).
- **Top-lair beacon (LAUNCH stretch):** the plot with the most **candles received today (UTC)** in this server gets a tall **Gold `#9C7A3C`** light pillar with a GoldBright tip. Ties go to whoever reached the count first. It re-checks every 60 s and only moves when someone overtakes. No Rift green, no purple.

---

## 5. Competition

### 5.1 Server Tithe board (spec 07)
Unchanged, except that Tithe now also excludes Relic pads 9–10 (§2.3).

### 5.2 Weekly global Hunt board (Update 1)
- **Metric: Hunt Marks** = **1 per completed wild catch.** Rarity doesn't matter, and assists, Echoes and purchases don't count.
  - **Why this metric:** it can't be bought.
    - Luck (free or paid) only changes rarity, so it doesn't change Marks.
    - 2x Cash, +2 Pads and Blood Moon don't speed up catching.
    - Catch-speed skills are free (Ring 1).
  - Daily cap **150 Marks** [A], so it rewards regular play, not 10-hour grinds or bots.
- **Reset:** **Monday 00:00 UTC.** OrderedDataStore `HuntWeek_<yyyyww>`, top 100. The player writes at most every 120 s.
- **Rewards: cosmetic only.**
  - Top 10: a "Master of the Hunt" title and a GoldBright banner trim for the next week.
  - Top 100: a "Hunter of the Week" title.
  - Everyone with ≥ 100 Marks that week: a dated Hunt seal in the Bestiary.
- **No cash, cryptids or boosts.**
- **Place:** a second face on the Ledger of Tithes slab: **"The Hunt Ledger · resets Monday 00:00 UTC."**
- **Bracket decision:** we **exclude** paid effects rather than using separate spender/F2P brackets. Brackets split an 8-player community into tiny boards and label payers. A metric that money can't move is simpler and fairer.

### 5.3 In-server races (Update 1)
- **"The Uncommon Chase":** 5 min, inside a Hollow Rite or Blood Moon. First to **catch 3 Uncommons** wins.
  - **Why Uncommons:** Server Luck multiplies only Rare+ and Common absorbs the change (spec 10 §5), so **Uncommon odds are identical with or without any luck.** A paid boost can't tilt the race.
  - **If no one finishes:** the most Uncommons wins. Ties go to whoever reached the count first.
- **Prize:** a title for the session + 3 min of pre-2x income. Cosmetic and cash only.
- **Needs ≥ 3 players in the server.** At most 1 race per 15 min.

### 5.4 Stealing → "Echo theft" (Update 3, Fri 11 Dec, per the fast-ship plan)
This fills the spec 02 §8 hooks (`PlotIntruded`, `StealGuard.canSteal`, defence sockets, `beingStolen`) and keeps the promise **"non-toxic: you never lose an owned cryptid".**

| Rule | Value |
|---|---|
| **What the thief does** | Enters an unprotected lair and channels **5 s** [A] on an occupied pad. The pad glows faint Blood and `beingStolen = true` |
| **What the thief gets** | An **Echo**: a translucent copy of that cryptid on the thief's first free pad (or an Echo slot). It earns **50% of that cryptid's base income for 15 min**, then fades. Not saved past the timer, can't be sold, no Bestiary entry, no mastery, no Tithe |
| **What the victim loses** | **Nothing owned.** That one pad is **"Shaken": −25% income for 5 min.** **Cap:** at most 1 Shaken pad at a time, so the victim loses at most **75 s of one pad's income** per theft. No cash is taken, so payers with Auto-Collect and players with a full bowl are treated alike |
| **Cooldowns** | Thief: 1 theft per 10 min overall, and the same victim once per 30 min. Victim: a **20 min shield** after being robbed |
| **New-player protection** | Can't be robbed (or rob) before onboarding is done **and** 60 min of total playtime (extends spec 01 protection) |
| **Opt-out** | Settings → **"Sanctuary"**: you can't rob and can't be robbed. Toggle at most once per 30 min, and it only takes effect when you're inside your own Threshold [A] |
| **Defences** | Ward Candles in D1–D4, bought with **cash only, never Robux**. Each adds +1 s to the channel (max +4 s). Any owner within 30 studs cancels the channel by touching the thief |
| **Notification + revenge** | Victim toast: **"{DisplayName} stole an echo of your Jersey Devil."** (Bone text, Blood edge). A **"Reclaim"** button teleports the victim to their own lair. For 10 min the victim can Echo-steal from that thief, ignoring the thief's shield, once |
| **Competition** | Echo income never counts in Tithe or Hunt Marks |

---

## 6. Anti-grief and anti-exploit

| Risk | Rule |
|---|---|
| **Spawn camping** | Spawns appear ≥ 40 studs from non-owners. The owner gets a 2 s first sight. A player standing in another player's sector for 5+ min gets no first-sight there (it's only ever for your own gate) |
| **Alt-account like farming** | Likers need account age ≥ 7 days and ≥ 30 min playtime. Same pair pays at most once a day. Owner pay capped at 10 rewarded likes a day. Likes give no board points |
| **Assist farming** | Assists need ≥ 1.0 s of channel, in range, at completion. Cap **20 assists an hour** per player and **3 an hour per player pair** |
| **Race collusion** | Prizes are a title and a small cash amount. Races need ≥ 3 players. A player can win at most 2 races a UTC day |
| **Remote spam** | Server token bucket per player: channel start 4/s, like 1/s, steal 1/s, others 10/s. Extra calls are dropped and logged. 3 floods in 60 s → that player's remotes are ignored for 30 s |
| **Bots on the Hunt board** | 150 Marks/day cap. A catch must pass server range + movement-speed checks |
| **F2P protection (pay-to-win)** | **Chosen: exclude paid effects** (not brackets). Tithe excludes 2x Cash, Blood Moon, bundles and Relic pads. Hunt Marks and races use metrics that no purchase or luck can move. Robux never buys Ward Candles, Essence, Sigils, Echo slots or steal immunity (Sanctuary is free) |

---

## 7. Data to save

| Key | Type | Notes |
|---|---|---|
| `rebirths` | int 0–7 | Spec 07 key, range widened |
| `upgrades.boneAltar` | int 0–10 | Spec 01 key, range widened |
| `variants[species]` | `{shiny: bool, corrupted: bool, firstAt}` | Bestiary variant pages ("found" = rolled, not crafted) |
| `mastery[species]` | int obtains | Level from §3.4 thresholds |
| `likes.received` | int | Lifetime candles |
| `likes.given` | `{utcDay, list of UserIds}` | One per plot per day |
| `likes.paidToday` | `{utcDay, count}` | Owner reward cap |
| `hunt.week` | `{weekId, marks, todayMarks, utcDay}` | Weekly board |
| `assist.hour` | not saved | Server memory |
| `steal` (Update 3) | `{sanctuary, lastToggle, shieldUntil, lastTheftAt}` | Echoes are never saved |
| `base.defences` | spec 02 key | Ward Candles (Update 3) |

Bump `dataVersion`. Migration: `variants = {}`, `mastery = {}` (seeded from `bestiary` = 1 each), `likes.received = 0`, `hunt.week = current`.

## 8. Server vs client
- **Server owns:**
  - spawn placement, channels, catch completion, tie order, assists;
  - rite and race counters, likes and caps;
  - Hunt Marks, OrderedDataStore writes;
  - variant rolls, mastery;
  - steal rules, shields, Echo timers;
  - all costs and gates (rebirth n, altar L, pads × 1.5^r).
- **Client:** prompts, channel bar (display only), toasts, beacons, boards from replicated lists.
- **New remotes:** `RequestStartChannel(spawnId)`, `RequestCancelChannel()`, `RequestLike(plotIndex)`, `RequestSteal(padIndex)` (Update 3), `RequestSetSanctuary(bool)` (Update 3). Every remote is rate-limited (§6).

## 9. UI text (palette tokens only, no purple)

| Where | Text | Style |
|---|---|---|
| Rebirth panel (tier n) | "The Rite of Rebirth · **Rite II**. Offer **$15,000,000**. All income ×**2.0**, forever." Gate bar: "Tithe $12.4M / $20M" | Ash panel, Bone text, Gold bar on Soot |
| Max tier | "The eighth rite is not yet written." | BoneDim italic |
| Contest lost | "**Mara** bound the Jackalope first. Assist · +$4.2K" | BoneDim / Gold |
| Contest won | "You bound the Jackalope." | Bone |
| Hollow Rite HUD | "The Hollow hungers · 27 / 40 · 6m 10s · you: 4" | Blood bar on Soot, Bone text |
| Rite AFK note | "Catch 3 to share the rite's reward." | BoneDim |
| Like prompt | "Leave a candle" / after: "Your candle burns at Mara's lair." | Gold button, Bone text |
| Liked count | "🕯 128" on the owner banner | Bone on Blood |
| Hunt board | "The Hunt Ledger · resets Monday 00:00 UTC" | GoldBright title, Bone rows |
| Race | "The Uncommon Chase · first to 3 Uncommons · 4m 12s" | Moss `#5E7A4A` accent, Bone text |
| Steal toast (victim) | "{DisplayName} stole an echo of your Jersey Devil. Nothing was lost. **Reclaim**" | Bone text, Blood edge |
| Sanctuary | "Sanctuary: no one can steal from you, and you can't steal." | BoneDim |
| Variant badges | "✦ Spectral" / "☍ Shadow" | GoldBright / Rift |

## 10. Edge cases
1. **Two catches finish on the same step:** first `RequestStartChannel` received wins; the other gets an assist.
2. **Winner leaves before the server step completes:** the catch isn't granted; the next channeller still in range continues their own timer.
3. **Spawn owner leaves:** their live spawns stay for 30 s (plot reservation, spec 02), then despawn.
4. **Rebirth during a Hollow Rite:** contributions stay; the reward uses post-rebirth income.
5. **Like on an Unclaimed Lair:** prompt hidden.
6. **Server shuts down mid-rite or mid-race:** no reward, no loss.
7. **UTC Monday rollover mid-session:** a new `weekId` starts; the old week's last write is flushed within 120 s.
8. **Variant + Mythic (later):** a Shadow Mythic from a free source fires both the sky (spec 10) and the banner.
9. **Steal on a pad holding an Echo:** not allowed (Echoes can't be stolen).
10. **Victim toggles Sanctuary mid-channel:** the channel completes only if Sanctuary hadn't taken effect when it started.
11. **Old profiles above the new caps** (test saves with altar > 10): clamp to 10, no refund.

## 11. Changes to earlier specs (not edited; approve to apply)

| Spec | Section | Was | Now (spec 11) |
|---|---|---|---|
| 01 | B4 Bone Altar | III+ "deferred to pacing spec" | Levels III–X, gain `0.25 × 0.75^(L−2)`, costs §2.2, × 1.5^r after rebirth |
| 02 | §3 pad costs | Same prices every climb | `price × 1.5^r` after r rebirths |
| 02 | §8 steal hooks | Stubs | Filled by §5.4 (Update 3) |
| 05 | §4 Ring 2 | Spec 04 costs ($6k–$75k) | `$2.5M × 4^(k−1)`, Rebirth ≥ 2 (Update 2) |
| 07 | §2 tiers | Tier 2 sealed; `rebirths` 0–1 | Tiers 1–7 at launch: cost `5M × 3^(n−1)`, mult `1 + 0.5n`, Tithe gate §2.2; tier 8+ sealed |
| 07 | §2 pad prices | "Same prices apply again" | × 1.5^r |
| 07 | §3 Tithe | Excludes 2x, Blood Moon, bundles | **Also excludes Relic pads 9–10** |
| 08 | §2 triggers | Epic catches | **Plus Shadow catches** (Wilds / Rift belt, any rarity) |
| 09 | §4 odds | Rarity + species | **Plus variant tables** (§3.2) |
| 09 | §12 F2P rules | — | Add: Robux never buys Ward Candles, Essence, Sigils or steal immunity |
| 10 | §7.2 sinks | 4 crafts | Plus the Spectral Rite (300), Shadow Rite (1,000), dyes, candle skins |
| 03 | Ledger of Tithes | One board | Second face: Hunt Ledger (Update 1) |

## 12. Launch cut vs Update 1 (freeze Fri 13 Nov)

| Item | Ship | Why |
|---|---|---|
| Rebirth tiers 1–7 + Tithe gate formula + pad price × 1.5^r | **LAUNCH (must)** | Without it the game "ends" at Rebirth 1 on day 2. It's mostly config plus one loop (spec 07 already does tier 1) |
| Bone Altar III–X | **LAUNCH (must)** | Config rows only |
| Tithe excludes Relic pads | **LAUNCH (must)** | One condition in the Tithe sum |
| Contested catch rule (server-complete, tie order, assist cash) | **LAUNCH** | Wild catching already ships. This is the rule for when two players meet; first-sight and spawn spacing included |
| Remote rate limits (§6) | **LAUNCH** | Small, protects everything else |
| Plot likes + liked count + top-lair beacon | **LAUNCH stretch** | Small. First to cut if the week is tight |
| Variants (Spectral, Shadow) | **Update 1** | Needs art (2 looks × 12) + variant data |
| Mastery levels + frames | Update 1 | Needs frames art |
| Hollow Rite, Uncommon Chase, Blood Moon hunts | Update 1 | Event framework + Blood Moon (already Update 1) |
| Weekly Hunt board | Update 1 | Second OrderedDataStore + slab face |
| Rebirth 8–10, Ring 2 | Update 2 (Fri 4 Dec) | With the Legendary roster |
| Echo theft + Ward Candles + Sanctuary | Update 3 (Fri 11 Dec) | Matches the plan's raiding slot |
| Essence sinks | January | Ships with the Tarot Table |
| Ascension (second prestige) | January+ | Needs its own spec and sim |

## 13. QA (18 tests)

| # | Test | Pass when |
|---|---|---|
| 1 | `python3 specs/tools/pacing_sim.py` | Exits 0; prints "Worst light-spender speed-up … OK <= 2x"; F2P Rebirth 7 median ≥ 20 active h |
| 2 | `python3 specs/tools/verify_odds.py` | "ALL TABLES SUM TO EXACTLY 100%" including every variant and species × variant table; exit 0 |
| 3 | Rebirth tier 2 | With Rebirth 1, $15M cash and Tithe $19.9M: button locked "Tithe $19.9M / $20M"; at $20M it works; income ×2.0 after |
| 4 | Tier cap | At Rebirth 7 the panel shows "The eighth rite is not yet written."; server rejects tier 8 |
| 5 | Pad price after rebirth | After Rebirth 2, Pad 3 costs $270 (120 × 2.25); with l2 $243 |
| 6 | Altar III | Altar III costs $8,000 at r = 0; total mult ×1.6875 (×1.825 with l3) |
| 7 | Tithe excludes Relic pads | Jersey Devil on Pad 9: plaque rises, Tithe doesn't move for that pad |
| 8 | Contest win | Two clients channel one spawn; the one whose timer completes first on the server gets the cryptid; the other gets an assist toast |
| 9 | Tie | Forced same-step completion: the first `RequestStartChannel` in the server log wins |
| 10 | Client can't finish | Firing a fake "complete" event or cancelling range checks grants nothing |
| 11 | Assist caps | 21st assist in an hour and 4th assist with the same partner in an hour pay $0 |
| 12 | Likes | Same liker, same plot, twice in a UTC day: 1 like. 11th rewarded like for an owner pays $0 but the count rises. A 3-day-old account's like doesn't count |
| 13 | Beacon | The plot with most candles today has the Gold pillar; it moves within 60 s of being overtaken |
| 14 | Remote flood | 100 `RequestLike` calls in 1 s: at most 1 processed; flood logged |
| 15 | Variants (Update 1) | 100,000 forced wild rolls: Spectral 1% ± 4σ, Shadow 0.4% ± 4σ; Server Luck ×3 on doesn't change them |
| 16 | Hollow Rite AFK (Update 1) | Idle player in the server gets no reward; a player with 3 catches gets the tier reward |
| 17 | Uncommon Chase under luck (Update 1) | Uncommon rate in the Wilds stays 16.4% with Server Luck ×3 (spec 10 formula) |
| 18 | Echo theft caps (Update 3) | Victim keeps every cryptid; only one pad Shaken (−25%, 5 min); thief can't hit the same victim again for 30 min; Sanctuary player can't be targeted |

## 14. Requests for Analytics (nothing under `analytics/` was edited)

> **11 Nov 2026.** The Analytics Lead role is retired. The Systems Architect owns the v1.2 catalogue in spec 18. The requests below were not added to that catalogue.
Please consider adding:
- **Events:**
  - `rebirth_tier` {n, activeHoursToTier, daysSinceInstall, spenderFlag}
  - `wild_contest` {spawnId, winner, assisters, tieByOrder}
  - `assist_paid` {amount, capHit}
  - `like_given` {counted, paid, capReason}
  - `beacon_moved`
  - `hollow_rite` {tier, contributors, afkCount}
  - `race_result`
  - `hunt_marks_week` {marks}
  - `variant_obtained` {source, variant}
  - `mastery_level`
  - `echo_theft` (Update 3) {victimLoss}
  - `sanctuary_toggle`
- **Metrics:**
  - median active hours and days to Rebirth 1 / 3 / 5 / 7, split F2P vs spender (to check the sim's ≤ 2× ratio against live data);
  - share of players at the launch cap;
  - like-farm flags;
  - assists per hour p99.
- **Dashboard:** a "pacing vs sim" table, tracked weekly against §2.4.

## 15. Sources
- Our specs 01–10 (all numbers above trace to them) and `specs/tools/pacing_sim.py` output (model, not benchmarks).
- Roblox **Paid random items** policy (why variants seen before purchase aren't paid random items; why luck-invariant metrics matter): https://create.roblox.com/docs/production/monetization/paid-random-items
