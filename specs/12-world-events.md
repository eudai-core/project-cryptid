# Spec 12: World Events (Omens, Fog Night, Blood Moon and the rest)

> **Change note (v1.2, 4 Nov):** **AD signed off the launch look (Baseline → Fog Night)** with fixes M1–M8 applied: baseline OutdoorAmbient (95,98,108) (D43); Fog Night Town/Wilds wisps 2.0/2.0 and 1.0/1.0 on Low (D45 cap); Fog Night Decay #282A30; Epic beat adds no tint during events (D48); tutorial clear-zone method; pad zone 6 → 9 studs if capture E2 shows rim intrusion.
> **Change note (v1.1, 4 Nov):** Spec 11 §4.2B conflict resolved (free-started Blood Moons only). Pedlar relics kept (deterministic only, cash = paid currency). AD confirmed G2 (6 studs), G3 (lair 1.0, 0 on Low), G5 (#282A30), Pedlar lantern PointLight range 10 / brightness 0.8 #7FA34A; G1 drafts coming. Blood Moon gift price still with Eudai.

**Owner:** Cryptid Growth Strategist · **Builders:** Cryptid Systems Architect (server director, client driver, UI), Art Director (profiles, emitters, captures), Integration Engineer (sound beds, Roblox-licensed only `[D31]`), Bot 3 (the Blood Moon dev product, **only after Eudai approves the price**) · **Status:** Draft v1.0 (Wed 4 Nov 2026, 01:15 UK time) · **Freeze:** Fri 13 Nov · **Launch:** Fri 20 Nov
**Builds on:** spec 03 (Town, fog), spec 06 (offline, daily), spec 07 (Tithe, pacing), spec 08 (banners), spec 09 (roster, odds, Blood Moon product §8.1, calendar levers §9.4), spec 10 (luck tables §5, Mythic sky §10), spec 11 v1 (multiplayer and pacing: Hollow Rite §4.2, variants §3.2, Tithe exclusions; it appeared on the box during drafting and was read before this version), and the Art Director's **[`art/vfx/atmosphere-events.md`](../art/vfx/atmosphere-events.md) v0.1** (profiles, omen/crossfade/return system), plus **[`art/vfx/atmosphere-pass.md`](../art/vfx/atmosphere-pass.md)** (baseline, `AmbienceRig`, clear zones).
**Paid randomness:** **none** (decision B, Eudai, 4 Nov). **Robux in this spec:** one product only, the **server-wide Blood Moon gift** (spec 09 #15, **199 R$ PROPOSED, pending Eudai**, Update 1). Its effect is fixed and deterministic.
**Checker:** `python3 specs/tools/events_check.py` (output saved in `specs/tools/events_check_output.txt`). The script lives in `specs/tools/` next to `verify_odds.py`, which is the house convention.

> **[A]** = design assumption, to be tuned from playtest data. **[AD]** = value taken from the Art Director's file. **[GAP]** = gameplay needs a value the Art Director's file doesn't give yet (listed in §16). Monte Carlo numbers are **model output on our own assumptions**, not benchmark data.

---

## 0. Launch in one line (Grok Bot ruling, 4 Nov)
**LAUNCH ships ONLY Fog Night** (plus the event director it runs on). **Blood Moon (natural and the paid gift), Rift Storm, Eclipse, The Tolling, Witch-Lights, the Witching Hour and Pedlar relics are Update 1.** Expedition relics are January. Full table in §14.

## 1. Goal and player fantasy
*"Hollowmere is alive. Sometimes the birds stop singing, a bell tolls somewhere, and the whole server goes still. Then the fog rolls in and things come out of it."*
- **Dread, then excitement.** Every event is announced by an omen, eases in over half a minute, plays, then eases out. Nothing ever snaps.
- **A shared moment.** Events are server-wide, so everyone in the server sees them together. That gives strangers something to talk about.
- **Retention.** Events add a reason to stay in a session ("one more Fog Night"), a reason to come back at a known time (the Witching Hour, Update 1), and a collection hook (the Bestiary *Omens* page).
- **Fair.** Events are free. Late joiners get the same sky and their share of the rewards. Money can only buy one fixed, shared gift (the Blood Moon), and never randomness.

## 2. The events

### 2.1 Roster
| Event | Tier | Ships | Active length [A] | Income while active | Spawn effects (free rolls only) | Spec 11 Hollow Rite (catches count) |
|---|---|---|---|---|---|---|
| **Fog Night** | Common | **LAUNCH** | **5:00** | **×1.1** | **Wild spawn interval 45 s → 30 s.** Species focus: **Hidebehind** (Common) and **Dover Demon** (Uncommon) at 2:1:1:1 inside their rarity. Rarity odds unchanged | ×1.5 [A] |
| **The Tolling** | Uncommon | Update 1 | 4:00 | ×1.1 | Rift belt interval **10 s → 7 s**. Focus **Mothman Hatchling**, **Snallygaster** (2:1:1:1) | ×1.5 [A] |
| **Witch-Lights** | Uncommon | Update 1 | 4:00 | ×1.1 | Wild interval **45 s → 30 s**, max alive **3 → 4**. Focus **Fresno Nightcrawler**, **Loveland Frogman** (2:1:1:1) | ×1.5 [A] |
| **Blood Moon** | Rare | Update 1 | **10:00** (= spec 09 §8.1) | **×1.5** (= spec 09 §8.1) | Focus **Beast of Bray Road** (Rare) and **Jersey Devil** (Epic) at 3:1. Rarity odds unchanged | ×1 + spec 11 Blood-marked hunts |
| **Rift Storm** | Very Rare | Update 1 | 6:00 | ×1.25 | Rift belt interval **10 s → 6 s** and **free event luck ×1.5** on the Rift belt (spec 10 §5.1 method) | ×2 [A] |
| **Eclipse** | Very Rare | Update 1 | 5:00 | ×1.25 | **Free event luck ×2** on Wild spawns (spec 10 §5.2 table). Focus **Flatwoods Monster** (Rare), **Loch Ness Serpent** (Epic) at 3:1 | ×2 [A] |

- **Species focus** changes *which* species you get inside a rarity, never the rarity odds, so pacing and income stay the same. Focus weights: 2:1:1:1 = **40% / 20% / 20% / 20%**; 3:1 = **75% / 25%** (checked by the script).
- **Spec 11 Hollow Rite tie-in (Update 1) [A]:** while a **free-started** event is **active**, each wild catch counts ×1.5 (Common/Uncommon events) or ×2 (Very Rare) toward the running Hollow Rite total (spec 11 §4.2: goals 25/40/60). Assists still count ½ of that. The rite's own rules (3-catch minimum, AFK gets nothing, rewards in pre-2x income) are unchanged. Events started by **cash or Robux** count ×1 (§6), so money can't speed up a shared goal. Launch has no Hollow Rite (spec 11: Update 1), so Fog Night at launch has no rite effect.
- **RESOLVED (Grok Bot ruling, 4 Nov; spec 11 v1.1 edited):** Blood-marked hunts run only in free-started Blood Moons. Original flag: **Conflict for spec 11 §4.2B:** spec 11 says Blood-marked wild spawns appear during **any** Blood Moon, "whoever paid". Extra cryptid spawns caused by a **Robux** purchase read as a paid "enhanced resource drop" and contradict spec 09 §8.1 ("no odds or spawn changes"). **Proposal:** Blood-marked hunts run only in **free-started** Blood Moons (random, Witching Hour, Blood Moon Night); the gifted Blood Moon stays income + look only. Confirmed.
- **Tithe excludes all event income multipliers** (same rule as spec 07 v2 for Blood Moon). Tithe stays pure play at base rates.

### 2.2 Boosted odds during events (all free rolls; verified, each sums to exactly 100%)
| Table | Base C / U / R / E | During the event |
|---|---|---|
| Rift belt, **Rift Storm** (luck ×1.5) | 72 / 24 / 3.6 / 0.4 | **70 / 24 / 5.4 / 0.6** |
| Wild spawns, **Eclipse** (luck ×2) | 80 / 16.4 / 3.4 / 0.2 | **76.4 / 16.4 / 6.8 / 0.4** (spec 10 §5.2's ×2 row) |
| Any focus table | uniform inside the rarity | 40/20/20/20 (4 species) or 75/25 (2 species) |

- Every odds panel (Rift belt Details, Bestiary wild odds) shows the **live** table plus a line, e.g. "*Rift Storm: Rare and Epic ×1.5 · 4:12 left*". These are free rolls, so Roblox doesn't require disclosure, but we show it anyway (house honesty rule).
- **If Server Luck ever ships** (ON HOLD, spec 10 §5), event luck × Server Luck stays capped at **×3 total** (spec 10 §5.3).

### 2.3 Event-only variants (Update 1)
During an event, free Wild and Rift rolls can produce an **event variant**. Its odds come out of **Normal**. Spec 11's Shiny and Corrupted odds are untouched. All tables are verified to sum to 100%.

| Event | Variant | Source | Normal / Shiny / Corrupted / Event variant |
|---|---|---|---|
| Fog Night | **Fogbound** | Wilds | 96.6 / 1 / 0.4 / **2** |
| Fog Night | Fogbound | Rift belt | 97.3 / 0.5 / 0.2 / **2** |
| The Tolling | **Knelled** | Rift belt | 97.3 / 0.5 / 0.2 / **2** |
| Witch-Lights | **Wisp-lit** | Wilds | 96.6 / 1 / 0.4 / **2** |
| Blood Moon | **Blood-touched** | Wilds / Rift | 95.6 / 1 / 0.4 / **3** · 96.3 / 0.5 / 0.2 / **3** |
| Rift Storm | **Riftborn** | Rift belt | 95.3 / 0.5 / 0.2 / **4** |
| Eclipse | **Umbral** | Wilds | 94.6 / 1 / 0.4 / **4** |

- **Cosmetic only**, like spec 11 §3.2's Shiny and Corrupted: the same income as the normal cryptid, plus one Bestiary page per event variant. **Luck never changes variant odds** (spec 11 rule); Rift Storm and Eclipse luck moves rarity only.
- **Only from free rolls** in a **free-started** event (§6). Never from the Pedlar, readings, cash or Robux.
- **Fog Night at launch has no variant.** Fogbound arrives in Update 1, so the launch build needs no variant code.

## 3. Random schedule (the event director)

### 3.1 Roll tables (per roll; verified)
| Outcome | **LAUNCH** | Update 1, normal hours | Update 1, Witching Hour |
|---|---|---|---|
| No event | **68%** | 51.5% | 34% |
| Fog Night (Common) | **32%** | 32% | 36% |
| The Tolling (Uncommon) | – | 6% | 12% |
| Witch-Lights (Uncommon) | – | 6% | 12% |
| Blood Moon (Rare) | – | 3% | **0%** (guaranteed at :30 instead, §5) |
| Rift Storm (Very Rare) | – | 0.9% | 3.6% |
| Eclipse (Very Rare) | – | 0.6% | 2.4% |
| **Total** | **100%** | **100%** | **100%** |
| **By tier** | C 32 | C 32 · U 12 · R 3 · VR 1.5 | C 36 · U 24 · R 0 · VR 6 |

The scheduler is a free system. Its odds are shown on the Bestiary *Omens* page anyway: "*Each omen roll: no event 51.5%, Fog Night 32%, …*".

### 3.2 Timing, caps and cooldowns
| Rule | Value |
|---|---|
| Roll interval | Every **4:00** (Witching Hour **3:00**) while the server is idle and the gap rule is met [A] |
| Max active | **1 event at a time.** Omen, crossfade, active and return all count as "busy" |
| Min gap (random and scheduled) | **6:00** from the end of RETURN to the next OMEN (Witching Hour **4:00**) [A] |
| Rare+ cap | Max **1 random Rare-or-rarer start per rolling 60 min.** A capped roll becomes "no event". The guaranteed Witching Hour Blood Moon doesn't count |
| Relic triggers (Update 1) | Max **3 relic-started events per server per rolling 60 min** (max 2 from Pedlar relics). Their own min gap is **2:00** after the previous return ends [A] |
| Blood Moon gift (Update 1) | Spec 09 §8.1 rules: one at a time, **5:00 cooldown** after it ends, max **3 per buyer per UTC day**. It ignores the random min gap, but the scheduler never starts anything while a gift is busy, and the normal 6:00 gap follows it |
| Empty server | The director pauses at 0 players and resets the roll timer on the next join |

### 3.3 What players will see (Monte Carlo, `events_check.py`, model output [A])
| Build | Fog Night | Any event | Rare+ | Time in an ACTIVE event | Any phase (omen to return) | Avg live income |
|---|---|---|---|---|---|---|
| **LAUNCH** (Fog Night only) | **2.79/h, every ~21.5 min** | 2.79/h | 0 | 23.3% | 32.6% | **+2.33%** |
| Update 1, normal hours | 2.33/h (~26 min) | 3.44/h (~17 min) | 0.25/h (~4 h) | 28.7% | 40.2% | +4.10% |
| Update 1, full UTC day incl. 2 Witching Hours | 2.27/h | 3.53/h | 0.33/h (~3 h) | 29.9% | 41.6% | +4.68% |
| Inside one Witching Hour | 2.01 | **4.57 events** | Blood Moon 1.00 + VR 0.24 | – | – | – |

- **Very Rare per server:** Rift Storm about every **16–20 h**, Eclipse about every **25–31 h** of server time. A player on 40 min a day sees one about every 2–3 weeks, more often on Witching Hours and Rift Tide [A]. That's rare enough to talk about.
- **Median start-to-start gap:** 17 min at launch (p10 13, p90 33), so a **10-minute session usually sees one Fog Night**, and the First Night rule (§7.3) makes sure a new player does.

### 3.4 Economic impact (vs spec 07/11 pacing)
- **Launch:** +2.33% live income for a player who stays all hour. That's about **28 s of extra income per 20-min session**, and the first rebirth (0.7 active h in the spec 11 sim) arrives **~1 min sooner**. That's negligible.
- **Update 1:** +4.1–4.7%, about 1 min of extra income per 20-min session, and the first rebirth comes ~2 min sooner. Still inside the pacing tolerance.
- **Worst case, gifted Blood Moons back to back:** 10 min at ×1.5, then a 5 min cooldown, plus 2 min of phases, gives 58.8% uptime and an average of **×1.29**. That is bounded by 3 gifts per buyer per UTC day and is shared with everyone.
- **Caps hold:** only one event at a time, and the biggest single event is ×1.5, so spec 09 §12's **×2 combined temporary income cap** is never reached.
- **Offline, bundles, daily, relic prices, Tithe:** all use the **pre-event** income rate (§11). Events can't inflate a haul, a bundle quote or the Tithe.

## 4. Telegraphing: omen, crossfade, event, return
**Timing base = the Art Director's transition system ([`atmosphere-events.md`](../art/vfx/atmosphere-events.md) §2), used unchanged.**

| Phase | Length | What happens (AD §2.2 order and easing) | Gameplay layer (this spec) |
|---|---|---|---|
| **OMEN** | **45 s** default (AD range 30–60) [AD] | t 0: **omen sting** (Fog Night: a single distant bell, AD §1.7). 0→0.6: **birds and wind fade** to 0.2× (Sine Out). 0.1→1.0: Atmosphere Color and CC Tint drift **15%** toward the event (Linear). 0.3→1.0: wisp/mote rates move 25% toward the event. Fireflies ramp out | **Chat omen line** + **HUD omen line** (§9). **No gameplay effect yet** |
| **CROSSFADE_IN** | **30 s** default (AD 20–45) [AD] | Ordered windows: (1) Atmosphere 0–0.5 → (2) Lighting 0.2–0.75 → (3) ColorCorrection 0.3–0.8 → (4) sky booleans at 0.5 under the CC soften, numerics 0.2–0.9 → (5) Bloom/motes 0.6–1.0 (Quad Out) → (6) event sound bed 0.4–1.0 (Sine In). All Sine InOut unless noted | Still no gameplay effect. The HUD chip shows "*Fog Night rises…*" |
| **EVENT** | Per §2.1 (Fog Night **5:00**) | Hold the profile. Fog Night "breathing": FogWisp ±20% over 60 s (AD §2.2, off in Reduced Motion) | **Effects ON** at the first frame of EVENT; title line; HUD chip timer |
| **RETURN** | **45 s** default (AD 30–60) [AD] | The same groups in reverse (5 → 1), Sine InOut. Birds come back last (0.7–1.0). Fireflies ramp back over 10 s after the return ends | **Effects OFF** at the first frame of RETURN. End line |

- **Never snap.** Admin abort or server shutdown goes **into RETURN from the current blend** (AD §2.1).
- **One driver** (AD §2.1): the client blends profile tables on Heartbeat at **10 Hz (High) / 5 Hz (Low)** from replicated `PhaseStart` / `PhaseLength` (server time `workspace:GetServerTimeNow()`), using `TweenService:GetValue(alpha, style, direction)` for the easing curve. There are **no per-property Tweens**, so late joins and aborts need no special cases.
- **Order of layers:** baseline < event profile < Mythic sky overlay (January; Gold per D28, then it hands back to the event blend, AD E5) < Epic reveal beat. **During events the Epic beat adds no tint, only an additive Contrast/Bloom pulse** (AD D48, E4).

## 5. Atmosphere profiles (exact values; all from the AD file, `[VERIFY in Play]`)
Baseline **Atmosphere Color is `#282A30`** (atmosphere pass; replaces spec 03's `#1A1719`, Grok Bot 4 Nov). **Fog Night starts from `#282A30` and RETURN goes back to `#282A30`.** All profiles keep the readability floor (Ambient ≥ (60,55,52), OutdoorAmbient ≥ (80,74,70), Brightness ≥ 1.5, Exposure 0.2–0.5) and D9 (**Density ≤ 0.18, Haze ≤ 0.3**) (AD §0).

| Property | **Baseline** | **Fog Night (LAUNCH)** | Blood Moon (U1) | Rift Storm (U1) | Eclipse (U1) |
|---|---|---|---|---|---|
| Lighting.Brightness | 1.5 | 1.5 | 1.6 | 1.5 | 1.5 |
| Lighting.Ambient | (60,62,70) | (62,64,70) | (80,56,54) | (60,63,58) | (66,60,54) |
| Lighting.OutdoorAmbient | (95,98,108) (AD D43) | (98,100,108) | (112,88,84) | (94,100,92) | (100,92,84) |
| ExposureCompensation | +0.3 | +0.35 | +0.3 | +0.3 | +0.35 |
| ColorShift_Top | (22,24,30) | (18,19,22) | (44,14,12) | (20,26,18) | (40,30,16) |
| Atmosphere.Density / Haze | 0.18 / 0.3 | 0.18 / 0.3 | 0.18 / 0.25 | 0.18 / 0.3 | 0.16 / 0.2 |
| Atmosphere.Offset / Glare | 0 / 0 | 0 / 0 | 0 / 0 | 0 / 0 | 0 / 0 |
| **Atmosphere.Color** | **`#282A30`** | **`#34363C`** | `#3A2222` | `#2A3026` | `#30281E` |
| Atmosphere.Decay | `#0B0A0C` | `#282A30` (AD M4) | `#1A0B0C` | `#0B0A0C` | `#0B0A0C` |
| Sky.StarCount | 300 | 0 | 150 | 0 | 0 |
| Sky.MoonAngularSize | 11 | 11 | **18** | 11 | 11 |
| Sky.CelestialBodiesShown | true | false at peak fog | true | false at peak | false |
| CC Brightness / Contrast / Saturation | +0.03 / +0.12 / −0.18 | +0.04 / +0.06 / −0.25 | +0.02 / +0.12 / −0.08 | +0.03 / +0.14 / −0.20 | +0.03 / +0.16 / −0.25 |
| CC TintColor | (240,244,250) | (236,238,242) | (255,226,218) | (242,248,238) | (255,240,220) |
| Bloom Intensity / Size / Threshold | 0.45 / 28 / 1.5 | 0.55 / 36 / 1.4 | 0.5 / 28 / 1.5 | 0.45 / 28 / 1.5 | 0.6 / 40 / 1.3 |
| FogWisp rate Lair / Town / Wilds | 1.0 / 1.5 / 2.0 | **see §5.1** (lair 1.0; Town / Wilds **2.0 / 2.0**, capped at 2 per second by AD D45) | 1.0 / 1.5 / 2.0 | 1.5 / 2.0 / 2.5 | 0.5 / 1.0 / 1.0 |
| Sound bed (Ambience vol.) | wind, crows, bell / 0.5 | muffled wind, drips, low bell ~45 s, no birds / 0.45 | drone, distant drum, choir / 0.5 | gusts, thunder / 0.55 | near silence / 0.35 |
| Omen sting | – | distant bell | low horn | thunder roll | distant bell |

The Tolling and Witch-Lights have **no AD profile yet** ([GAP] G1). They don't ship until the AD writes them.

### 5.1 Fog Night's extra fog: clear zones and Low quality (Grok Bot rule, 4 Nov)
Lair wisps are allowed at a **low rate**, with **clear zones around pads and the tutorial spawn**, and they're **off on Low quality**. So:

| Zone | High/Medium quality | **Low quality** |
|---|---|---|
| **Lair** | FogWisp stays at the **baseline lair rate 1.0**. **Fog Night does not raise it** (this differs from AD §1.5's 2.0, [GAP] G3). The "fog" in lairs comes from the Atmosphere colour `#34363C` only | **0 (off)**. Colour only |
| Pads | **Clear zone**: no wisp sprite over any pad or its cryptid. Radius **6 studs** from pad centre (**AD confirmed**, 4 Nov); the wisp script skips spawning inside it. **Raise to 9 studs** if capture E2 shows wisps reaching the pad rim (AD M8) | n/a (lair wisps are off) |
| Tutorial Hodag spawn, plot-local (0,0,−80) | **Clear zone 12 studs**, kept during Fog Night (AD §1.5). **Method (AD M7):** the wisp script skips any spawn point within 12 studs of (0,0,−80) until the Hodag is caught; nothing is carved from the camera-local box | Off |
| Near a wild creature (20 studs) | Rate ×0.5 (atmosphere-pass §3.4) | Same rule on the ×0.5 Low rate |
| **Town / Roads** | Fog Night **2.0** (AD D45 cap of 2 wisps per second) | **1.0**, size ≤ 6 (AD §2.4) |
| **Wilds** | Fog Night **2.0** (AD D45 cap) | **1.0**, size ≤ 6 |
| Ramps | ≤ ±0.5 Rate per second, never `:Emit()` (AD §2.3) | Same |

**QA hook:** a pad's cryptid silhouette and billboard must stay readable during Fog Night at 30% phone brightness (style guide readability tests).

## 6. Triggers and who can start what

| Source | Ships | What it can start | Effects applied | Counts toward caps |
|---|---|---|---|---|
| **Random director** | LAUNCH | Roll table §3.1 | **Full** (income, spawn interval, focus, luck, variants, Hollow Rite weighting) | Yes |
| **First Night** (§7.3) | LAUNCH (stretch) | Fog Night only | Full | Yes |
| **Witching Hour / calendar** (§7) | Update 1 | Guaranteed Blood Moon at :30; Rift Tide extras | Full | Rare+ cap exempt for the guaranteed one |
| **Expedition relic** (earned) | January | Its event (any tier) | **Full.** Earned for free, so Roblox's "locates a key that opens a treasure chest" case applies (no disclosure needed) | Yes; refused if capped, relic kept |
| **Pedlar relic** (cash) | Update 1 | Fog Night, The Tolling, Witch-Lights only | **Deterministic only:** atmosphere + income multiplier. **No** spawn-interval change, focus, luck, variants or Hollow Rite weighting (§8) | Yes (max 2/h) |
| **Blood Moon gift** (Robux) | Update 1 | Blood Moon only | **Deterministic only:** atmosphere + **×1.5 income for 10:00**, everyone. **No** focus, variants, odds, spawn or Hollow Rite change (= spec 09 §8.1 and spec 11 v1.1 §4.2B) | Own rules (§3.2) |

### 6.1 Pedlar relics (Update 1, cash)
A fixed **Relic Shelf** at the Pale Pedlar. It isn't random, doesn't rotate and has no stock limit. Buying a relic is **buy-and-light**: you pay and it starts (or queues). There's no inventory.

| Relic | Starts | Price (cash, pre-event, pre-2x income) [A] | Example at $631/s (20-min median, spec 07) | Example at $1,748/s (60 min) |
|---|---|---|---|---|
| **Pedlar's Fog Lantern** | Fog Night (called) | **5 min of your income**, min **$25,000** | $189,300 | $524,400 |
| **Pedlar's Cracked Bell** | The Tolling (called) | **10 min**, min **$75,000** | $378,600 | $1,048,800 |
| **Pedlar's Wisp Jar** | Witch-Lights (called) | **10 min**, min **$75,000** | $378,600 | $1,048,800 |

- **Why income-scaled:** spec 11's rebirth tiers multiply income many times over (tier 7 ×4.5 plus pad growth), so fixed prices would be pocket change by day 10. Scaling keeps relics a **real sink** (5–10 min of income for +10% for 5 min shared with everyone). It's a social, atmosphere purchase, not an investment.
- **Unlock:** onboarding done **and** Tithe ≥ **$1,000,000** [A]. **Per player:** 1 relic per **30 min** [A].
- **Never sold for Robux, never inside any Robux bundle, satchel or pass** (Grok Bot: a Robux trigger is OK only as the fixed Blood Moon gift).
- **KEPT (Grok Bot ruling, 4 Nov).** Pedlar relics stay, cash-priced. Because cash is also sold in Robux bundles, Roblox treats cash as paid currency, so the §8 rule stands: Pedlar relics start **deterministic effects only** (no spawn, focus, luck, variant or Hollow Rite changes).

### 6.2 Expedition relics (January, earned)
On an expedition return: **10%** chance of a relic [A]. If one drops: Fog Lantern **50%**, Cracked Bell **20%**, Wisp Jar **20%**, Blood Chalice **7%**, Rift Shard **2%**, Black Sun Coin **1%** (verified 100%). You can hold up to **5 of each**. They're never sold, traded or bundled. The chance is shown on the Expedition Board, although it's a free reward.

### 6.3 Queue and refusal (relics and gifts)
- **Queue length 1** per server. A queued trigger starts **2:00** after the current RETURN ends.
- A **Pedlar relic is charged when the server accepts it** (starts now or queues). If the queued start is cancelled (the buyer leaves, or the server shuts down), the **cash is refunded at once**, before the leave-save.
- An **earned relic is consumed at OMEN start**, never before.

| Situation | Text (Bone on Ash, `BoneDim` detail) |
|---|---|
| Queued | "*The veil is stirring. Your lantern will be lit in 3m 10s.*" |
| Queue full | "*The veil is already stirring. Try again in 6m.*" |
| Rare+ cap (earned Rare+ relic) | "*The sky will not bear another omen yet · 23m.*" (relic kept) |
| Pedlar relic limit | "*Your last lantern still smoulders · 18m.*" |
| Server relic cap | "*Hollowmere has seen enough omens this hour · 12m.*" |
| Blood Moon gift while any event is busy | Button disabled: "*The sky is already turning · 4m*". The time is real: the end of the current RETURN, plus the 5:00 cooldown after a Blood Moon |

## 7. Retention design

### 7.1 Witching Hour (scheduled event hour, Update 1)
| Slot (fixed UTC) [A] | UK | US Eastern / Pacific | Why |
|---|---|---|---|
| **19:00–20:00 UTC** daily | 19:00 GMT (20:00 in BST) | 14:00 / 11:00 | UK after school and tea |
| **01:00–02:00 UTC** daily | 01:00 (UK asleep) | **20:00 / 17:00** | US evening |

- During the hour: the Witching Hour roll table (§3.1), 3:00 rolls, a 4:00 gap and a **guaranteed Blood Moon whose OMEN starts at :30**. If an event is busy at :30, it starts after that RETURN ends. Model: **~4.6 events per Witching Hour**.
- Shown on the Expedition Board's 7-day calendar (spec 09 §9.4) and in the HUD in the player's **local time** (client `os.date`): "*Witching Hour · 7:00 pm*". **No push notifications** in this build.
- **Calendar events (spec 09 §9.4) run on this director:** **Rift Tide** (Sat 18:00–20:00 UTC) uses the Witching Hour table, with a guaranteed **Rift Storm at 18:30** and a Blood Moon at 19:30. **Blood Moon Night** (first Friday, 19:00–21:00 UTC) has a guaranteed Blood Moon at 19:30 and 20:30. Calendar days replace that day's 19:00 Witching Hour.
- **Assumption:** UTC slots, so UK players see the hour move by 1 h at the clock change. That's acceptable and shown honestly in local time.

### 7.2 Positive-only hooks
- **Bestiary "Omens" page** (LAUNCH: Fog Night entry only): each event type is listed with its tier, times witnessed and a silhouette until first seen. Witnessing all 6 gives the title **"Omen-Reader"** (Update 1).
- **Spec 06 has no daily quests** (it has the Nightly Offering ladder, which stays fixed and non-random). So there's no daily-quest hook at launch. If a quest list ships later, the templates are: "Witness a world event", "Catch a cryptid during Fog Night", "Help a Hollow Rite during an event".
- **Omen Watch (Update 1, weekly, positive only) [A]:** witness **3 events** in a UTC week (Mon 00:00 reset) for a fixed chest of **30 min of income**. Nothing to lose, no streak and no reminders, the same rules as Moon Vigil (spec 09 §9.4).
- **Moon Rite / Moon Vigil** (spec 09) are unchanged. Events don't double them, apart from Rift Tide as spec 09 already says.
- **Never:** "you missed it" copy, fake countdowns, FOMO pop-ups, or a shop link inside any event UI.

### 7.3 First Night (LAUNCH, stretch: one rule in the director)
A player who has **never witnessed an event**, has finished onboarding step 8 **and** has played **6:00** forces a **Fog Night** if the server is idle and the gap rule is met. Otherwise they get the next one. Max **1 forced per server per 20 min**. Goal: **every new player sees one omen in session 1** (D1 lever, design bible "wow in the first session") [A].

### 7.4 Late joiners and fairness
| Rule | Value |
|---|---|
| Visual state | **Before the loading screen is removed**, the client reads `Phase`, `PhaseStart` and `PhaseLength`, computes alpha and **applies the blended profile at once**. Emitter rates are set directly and particles start from 0. The event bed fades in over 2 s. The omen sting is skipped (AD §2.4). **A late joiner never sees the default sky first** |
| Mid-event toast | "*A Fog Night hangs over Hollowmere · 3m 40s left.*" No omen replay |
| Income multiplier | Applies for the seconds you're present (naturally pro-rated) |
| **Witness credit** (Bestiary, Omen Watch, quests) | Present for **≥ 50% of the EVENT phase or ≥ 120 s of it**, whichever is shorter [A] |
| Hollow Rite contribution (U1) | Catches while present, at the event weighting (§2.1) |
| Variants and focus | Apply to your rolls while present. Nothing is back-dated |
| Onboarding players (before step 8) | The atmosphere and sounds still play (sounds at 50%). **HUD omen lines and the title are hidden** until step 8 is shown; they get chat only [A]. The tutorial clear zone stays on |

## 8. POLICY GATE (paid random items)
Verified **4 Nov 2026** from official Roblox docs.

**What Roblox says**
1. Paid random items include random items bought **directly or indirectly** with Robux, "**including random items purchased with paid in-game currency**". ([Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items))
2. **Probability modifier items** are paid random items: "**Luck boosts, Pity systems, Enhanced resource drops, Rate-up scrolls**". Paid items that "augment the odds of other random outcomes" must be explained numerically and the odds updated live. (same page)
3. Randomised rewards for actions "that do not involve the payment of Robux or other in-game currency" need no odds disclosure. Example given: "a user locates a key that opens a treasure chest". (same page)
4. `PolicyService:GetPolicyInfoForPlayerAsync()` returns **`ArePaidRandomItemsRestricted`**. Restricted users must get a treatment such as hiding the item. ([PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService); paid random items page)

**What we do (decision B: no paid random items at all)**
| Rule | Spec |
|---|---|
| Cash is paid currency | Cash is sold in Robux bundles (spec 09 §8), so **anything bought with cash counts as paid**. Pedlar relics therefore start **deterministic effects only**: atmosphere, a fixed income multiplier for a fixed time. **No** spawn-rate change (which could be read as "enhanced resource drops"), no focus, no luck, no variants, no Hollow Rite weighting |
| **Blood Moon gift is deterministic** | Fixed **×1.5 income** for everyone, fixed **10:00**, fixed look. **No** odds, focus, spawn, variant or Hollow Rite change. The server code path for a gift-started Blood Moon **must not call** the focus/variant/luck hooks (QA 14). It's labelled "*Blood Moon (gifted): every lair +50% · 9m 12s*" so nobody thinks it changes catches |
| Earned relics | A free reward found in play (Roblox's "key" example), so they may start the **full** event |
| Random director | Free. Odds shown anyway (Bestiary *Omens* page) |
| PolicyService | **Not needed for this spec**, because nothing here is a paid random item. The gift is **not hidden** for restricted players (it isn't random), and everyone gets its benefit. The existing spec 09 policy wrapper is untouched |
| Robux bundles | **Never** contain relics, event starts or variants |
| Off-site purchase | Blood Moon gift dev product **not Listed** [A] (it only makes sense inside a server; [Developer products](https://create.roblox.com/docs/production/monetization/developer-products)) |
| Prices | **PROPOSED, pending Eudai.** Created only by Bot 3 after approval |

## 9. UI text and palette
Palette: Void `#0B0A0C`, Blood `#7A0F12`, Gold `#9C7A3C`, GoldBright `#C9A55A`, Bone `#E8E0CF`, Rift `#7FA34A` **sparingly** (≤ 2% of a view; world trim RiftDim per D38). **No purple** (reds keep G ≥ B, cool tints keep R ≤ G, AD §0). Nothing cartoony: no bouncing text, no emoji, no confetti.

| Where | Fog Night (LAUNCH) | Blood Moon (U1) | Rift Storm (U1) | Eclipse (U1) | Tolling / Witch-Lights (U1) |
|---|---|---|---|---|---|
| **Chat omen** (`[Omen]` in Gold; `TextChannel:DisplaySystemMessage` on the client from a server RemoteEvent) | "The lamps gutter. A fog is rolling off the marsh." | "The moon is bleeding over Hollowmere." | "The Rift groans beneath the town." | "Something is swallowing the moon." | "A bell tolls where no bell hangs." / "Pale lights gather at the edge of the Wilds." |
| **HUD omen line** (top-centre, Merriweather 18 italic, BoneDim; fades in 1.5 s, holds 6 s) | "*The birds have gone quiet…*" | "*Hold your candles close.*" | "*Stand clear of the fissures.*" | "*Do not look up.*" | "*Count the tolls.*" / "*Do not follow them.*" |
| **Title at EVENT** (GrenzeGotisch 36, Bone, 1 s fade; RM: fade only) | **FOG NIGHT** | **BLOOD MOON** | **RIFT STORM** | **ECLIPSE** | THE TOLLING / WITCH-LIGHTS |
| Effect line under the title (Bone 16) | "Hidebehinds stir in the mist · lairs +10%" | "Jersey Devils hunt · lairs +50%" | "The Rift spills faster · Rare+ ×1.5 on the belt" | "Rare+ ×2 in the Wilds · lairs +25%" | "The belt quickens · lairs +10%" / "More wanderers in the Wilds · lairs +10%" |
| **HUD chip** (Ash fill, Gold 1 px rim; Blood fill for Blood Moon) | "Fog Night · 4m 12s" | "Blood Moon · 7m 12s" | "Rift Storm · 5m 02s" (Rift hairline accent) | "Eclipse · 3m 50s" | "The Tolling · …" |
| **End line** (chat + HUD) | "The fog lifts from Hollowmere." | "The moon pales." | "The Rift falls quiet." | "The moon returns." | "The bell is still." / "The lights go out." |

- **Gift banner (Update 1, final wording, Grok Bot):** "**{DisplayName} summoned a Blood Moon over Hollowmere!**" (spec 08 queue, Blood fill, Gold border). Chat: `[The Moon] {DisplayName} summoned a Blood Moon over Hollowmere.` **No price, no Robux symbol, no buy link.** It shows at **OMEN start** of the gifted Blood Moon. **Personal Robux purchases never announce.**
- **Pedlar relic (Update 1):** no banner. Chat only: `[Omen] A lantern was lit at the Pedlar's stall.` (no name, no price) [A].
- **The HUD chip never links to a shop.** Tapping it opens an info card with the effects and the live odds lines.
- Banned words (spec 09 §13.1) apply: no "FREE!", "Last chance", "Lucky", "Boost your odds".

## 10. Data to save (player profile, session-locked)
| Key | Type | Notes |
|---|---|---|
| `events.witnessed[eventId]` | int | Bestiary *Omens* page (LAUNCH: `fog_night`) |
| `events.firstNightDone` | bool | §7.3 |
| `events.omenWatch` | `{utcWeek, count, claimed}` | Update 1 |
| `relics.earned[relicId]` | int 0–5 | January |
| `relics.lastPedlarRelicUnix` | int | Update 1, 30-min limit |
| `bloodMoon.boughtToday` | existing (spec 09) | Gift cap |
| **Not saved** | – | Event state, queue, caps history (server memory only; a new server starts BASELINE) |

Bump `dataVersion`. The migration adds `events = {witnessed = {}, firstNightDone = false}`.

## 11. Server vs client
- **Server owns:** the director (rolls, caps, gaps, queue, First Night), the phase state, every effect (income multiplier, spawn interval, focus/luck/variant tables, Hollow Rite weighting), witness credit, relic charging and refunds, and gift receipts (spec 09 `ProcessReceipt` ledger).
- **Replicated state** (attributes on `ReplicatedStorage.WorldEvent`, AD §2.1): `EventId`, `Phase`, `PhaseStart`, `PhaseLength`, `FromProfile`, `ToProfile`, `StartedBy` (`random | first_night | event_hour | calendar | relic_earned | relic_pedlar | gift`), `EndsAt`.
- **Client owns:** the blend driver, emitters, sounds, omen lines, chip and title. **The server never writes Lighting, Atmosphere or Sky during events** (a server write would replicate as a snap).
- **Rates for economy maths use the pre-event rate:** `offline.rate` / `offline.rateNoPass` (spec 06), cash bundle quotes (spec 09 §8), daily ladder minutes, Pedlar relic prices and Tithe all **exclude** the event multiplier.
- **Remotes:** `RequestLightRelic(relicId)` (Update 1). The server checks onboarding, Tithe, cooldowns, caps and cash, and that the player is within 12 studs of the Pedlar. Clients **can't** start, end or extend an event.

## 12. Analytics (draft; the Analytics Lead owns the register)
The Analytics Lead's rule (`analytics-events-spec.md` §5): "new variants go in **custom fields**, not new event names". So the stages share **one event name** with the stage in a field. All events are server-side, ≤ 3 custom fields, string values, no PII.

| # | Name | When | CF01 | CF02 | CF03 | value | Ships |
|---|---|---|---|---|---|---|---|
| W1 | `WorldEventStage` | Per player in the server at each stage | `Stage - warning_start / crossfade_start / event_start / event_end / fade_end` | `Event - fog_night / …` | `Source - random / first_night / event_hour / calendar / relic_earned / relic_pedlar / gift` | players in server | **LAUNCH** |
| W2 | `WorldEventLateJoin` | A player finishes loading during any phase | `Event - …` | `Phase - omen / crossfade / active / return` | `Left - <1m / 1-3m / 3-5m / 5m+` | seconds left | **LAUNCH** |
| W3 | `WorldEventWitness` | At `event_end` for players present, or on leave during EVENT | `Event - …` | `Source - …` | `Credit - full / partial / left_during` | seconds present in EVENT | **LAUNCH** |
| W4 | `WorldEventTrigger` | A relic or gift is used, queued or refused | `Result - started / queued / refused_busy / refused_cap / refused_cooldown / cancelled_refunded` | `Event - …` | `Source - relic_pedlar / relic_earned / gift` | wait seconds | Update 1 |
| W5 | *(no new name)* | Event variant bound | reuse spec 11's requested `variant_obtained` {source, variant} with variant `fogbound / knelled / wisp_lit / blood_touched / riftborn / umbral` | | | | Update 1 |
| W6 | `RelicFound` | Expedition return drops a relic | `Relic - …` | `Expedition - <tier>` | – | 1 | January |
| E6 add | `LogEconomyEvent` Sink, `Cash`, `Shop` | Pedlar relic bought (Source on refund) | itemSku `Relic_FogLantern / Relic_CrackedBell / Relic_WispJar` | | | amount | Update 1 |
| E13 add | IAP | Blood Moon gift (`Gift_BloodMoon`) | per E13 (blocked until Eudai approves) | | | | Update 1 |

- **Budget:** launch adds **3 names** (W1–W3). W1 is 5 stages × ~2.8 events/h = **~14 calls per player per hour** (0.23/min), well under the 6 per player per minute budget.
- **Metrics this feeds [A]:** % of sessions with ≥ 1 event; D1 for players who **witnessed in session 1** vs not (First Night test); session length in sessions with vs without an event; **leave rate during OMEN/CROSSFADE** (does dread annoy?); Witching Hour CCU lift (U1).

## 13. Monetisation hooks
- **Blood Moon gift** (Update 1): spec 09 #15, **199 R$ PROPOSED, pending Eudai**. It now uses the omen → crossfade → return system and the final banner. Its effect is fixed (§8).
- **Cosmetics, not power:** event-themed lair cosmetics (e.g. a Fog Lantern lair prop, a Blood Moon banner) may sit on the **Moon Pass paid track** or in a **Pedlar's Satchel** as fixed, listed contents (spec 09 §9.2–9.3). Free-track versions are earned by witnessing events.
- **Not sold, ever:** event starts other than the Blood Moon gift, relics, event odds or focus, variants, Witching Hour access, witness credit or the Omen Watch.
- **No shop prompt** during an omen, crossfade or event, or from the HUD chip. The spec 09 global rules apply (step 8 + 5:00, max 1 proactive card per session).

## 14. LAUNCH CUT and build cost
| Item | Ships | Who builds | Cost [A] |
|---|---|---|---|
| Event director: state machine, replication, roll table (Fog Night only), caps, gap, empty-server pause | **LAUNCH** | Systems Architect | 4 h |
| Client blend driver (10/5 Hz, ordered windows, emitter ramps, RM/Low, join mid-event) | **LAUNCH** | Systems Architect (AD §4 estimate) | 4 h |
| Baseline + **Fog Night** profile data, sky boolean swap + CC soften, Fog Night tuning | **LAUNCH** | Art Director + Architect (AD §4) | 3 h |
| Fog Night clear zones + Low-quality lair-off rule (§5.1) | **LAUNCH** | Art Director spec, Architect wire | 1 h |
| Fog Night sound bed + bell sting (Roblox-licensed, logged) | **LAUNCH** | Integration Engineer | 0.5 h |
| Fog Night gameplay: ×1.1 income, wild 30 s, Hidebehind/Dover Demon focus | **LAUNCH** | Systems Architect | 1.5 h |
| Omen chat line, HUD line, title, chip, end line; Bestiary *Omens* entry | **LAUNCH** | Systems Architect | 2 h |
| Analytics W1–W3 | **LAUNCH** | Architect, after the Analytics Lead registers them | 1 h |
| Studio captures E1–E3 (Fog Night) + QA pass | **LAUNCH** | Art Director + QA | 2 h |
| **First Night** rule | **LAUNCH stretch** | Systems Architect | 0.5 h (cut first) |
| **LAUNCH total** | | | **≈ 19 h ≈ 2.5 dev days** (of which ≈ 8 h is the AD's own P0 estimate) |
| Blood Moon (natural) + **Blood Moon gift** product + final banner | Update 1 | Architect; **Bot 3 creates the product only after Eudai approves** | ~4 h + AD 1.5 h |
| Rift Storm, Eclipse | Update 1 | AD profiles exist (AD §1); Architect effects | AD 5 h + 3 h |
| The Tolling, Witch-Lights | Update 1 | **AD profiles needed first** ([GAP] G1) | ~4 h |
| Witching Hour, calendar hooks, Omen Watch | Update 1 | Architect | 3 h |
| Pedlar Relic Shelf | Update 1 | Architect | 3 h |
| Event variants (2.3) | Update 1 | Architect + AD (variant look) | 4 h |
| Expedition relics | January | with Expeditions | 2 h |

**Freeze risk:** medium. If the Architect is full in the week of 9 Nov, cut in this order: First Night → Bestiary *Omens* entry → (last resort) the whole event layer. The atmosphere-pass baseline ships either way (AD E11).

## 15. Edge cases
1. **Server shutdown mid-event:** clients go into RETURN from the current blend if they're still connected. Nothing is saved, and the next server starts BASELINE.
2. **Admin abort:** RETURN from the current blend, never a snap.
3. **Player joins during OMEN:** the snap-to-blend happens during loading; the omen line shows if more than 10 s remain [A].
4. **Player leaves mid-event:** witness credit is logged as `left_during`; client state dies with the session.
5. **Relic queued, then the buyer leaves:** the queue is cancelled and the cash refunded before the leave-save. An earned relic isn't consumed.
6. **Two relic uses in the same second:** the first wins, the second queues if the queue is empty, otherwise it's refused (§6.3).
7. **Gift receipt arrives while busy** (button raced): it queues after the current RETURN plus any Blood Moon cooldown. The buyer is told the real time (spec 09 §16).
8. **Rare+ rolled while capped:** it becomes "no event" (no reroll), logged.
9. **Witching Hour's :30 Blood Moon while an event is busy:** it starts when that event's RETURN ends, even past the hour's end.
10. **Mythic sky (January) during an event:** a Gold overlay for 20 s, then it hands back to the event blend (AD E5).
11. **Epic reveal during Blood Moon:** an additive Contrast/Bloom pulse only (AD E4), so the Epic moment stays visible.
12. **Rebirth during an event:** the multiplier applies to the new income at once.
13. **Event across 00:00 UTC:** the daily ladder resets normally; the event isn't affected.
14. **Low-end device:** 5 Hz driver, Bloom off, **lair wisps off**, Town/Wilds 1.0 (§5.1). AD worst case ≤ 169 particles ≤ 200.
15. **Reduced Motion:** colour crossfades still run (slow colour, not motion); no breathing, no lightning, no soften pulse; titles fade only.
16. **Player in onboarding (steps 1–8):** HUD lines are hidden and the tutorial clear zone holds (§7.4).
17. **Solo server:** events run the same. Witness credit works.
18. **Clock drift:** all phase maths uses `workspace:GetServerTimeNow()`.

## 16. Gaps and conflicts for the Art Director (from `atmosphere-events.md` v0.1)
| # | Gap / conflict | Needed for | Ask |
|---|---|---|---|
| **G1** | No profile for **The Tolling** or **Witch-Lights** | Update 1 | Two profile columns (same format as AD §1) |
| **G2** | **Pad clear-zone radius** isn't given (atmosphere-pass §3.4 has the tutorial 12 studs and "lowest rate" for pads only) | LAUNCH (Grok Bot rule) | A radius and a method (camera-local box can't carve holes; e.g. rate-0 while the camera is within N studs of an occupied pad?). Working value **6 studs [A]** |
| **G3** | AD §1.5 raises the Fog Night **lair** FogWisp to 2.0, and AD §2.4 / atmosphere-pass §3.5 set Low to ×0.5 | Grok Bot rule: lair wisps low rate, **off on Low** | **RESOLVED:** AD confirmed lairs at 1.0 during Fog Night and 0 on Low (4 Nov) |
| G4 | Event **active lengths** | – | Set by this spec (§2.1). AD §2.1 marked them `[S12?]`; now resolved |
| G5 | Spec 03 §3 and the style guide still say Atmosphere Color `#1A1719` | Doc consistency | Baseline is **`#282A30`** (Grok Bot). Spec 03 (my spec) and the style guide (AD) need the wording change |
| G6 | Blood Moon red moon texture | Update 1 | P1 upload, Eudai's call `[D23]` (AD §1.3). P0 = big default moon + grade |
| G7 | Per-event omen length within 30–60 s | – | All events use the AD default 45/30/45. If the AD wants Very Rares longer (e.g. 60 s omen), that's an AD call; the script parameter is ready |

## 17. Changes requested in other specs (owners make them; not edited here)
- **Spec 03 §3** (mine, next revision): baseline Atmosphere Color `#282A30`; lair wisps allowed at a low rate with clear zones (AD C5); Pedlar Relic Shelf (Update 1).
- **Spec 08 §4b** (decision B executor, v2.2): Blood Moon banner text "**{DisplayName} summoned a Blood Moon over Hollowmere!**"; it fires at OMEN start.
- **Spec 09 §8.1 / §9.4:** the Blood Moon gift runs through this director (45/30/45 phases, disabled while any event is busy); Rift Tide and Blood Moon Night run as calendar events here.
- **Spec 11 §4.2B:** Blood-marked hunts only in free-started Blood Moons (see §2.1). §4.2A: event catch weighting for the Hollow Rite.
- **Spec 06 / spec 09 bundles:** rates exclude event multipliers (§11).
- **Analytics:** change request to the Analytics Lead (W1–W6 + SKUs). **Their files are not edited.**

## 18. QA acceptance tests
| # | Test | Pass if |
|---|---|---|
| 1 | `python3 specs/tools/events_check.py` | Prints "ALL SPEC 12 TABLES SUM TO EXACTLY 100%", exit 0 |
| 2 | Launch roster | Over 3 h in a test server, only Fog Night ever starts; no Blood Moon, Tolling, Witch-Lights, Rift Storm or Eclipse code paths fire |
| 3 | Frequency | Forced fast-clock sim (or 6 h soak): Fog Night starts **2.3–3.3 per hour**; gap from RETURN end to next OMEN ≥ 6:00 every time |
| 4 | One at a time | Forcing a second event while one is busy is refused/queued; never two profiles blending |
| 5 | Phase timings | Logged phase lengths: OMEN 45 s, CROSSFADE 30 s, EVENT 300 s, RETURN 45 s (±0.5 s) |
| 6 | Never snaps | Frame capture of Atmosphere.Color through OMEN → RETURN: no frame-to-frame jump > 2 RGB units on any channel (sky boolean swap only at crossfade 0.5 under the soften) |
| 7 | Base colour | Before OMEN and 1 s after RETURN ends, Atmosphere.Color = **#282A30** exactly; at Fog Night peak = **#34363C** |
| 8 | Floors | At every frame of Fog Night: Density ≤ 0.18, Haze ≤ 0.3, Ambient and OutdoorAmbient ≥ floors, Brightness ≥ 1.5, Exposure 0.2–0.5 |
| 9 | Late joiner | Join at EVENT 2:00: the first rendered frame after loading already shows Fog Night values (no default-sky frame); chip shows the correct time left ±1 s |
| 10 | Late joiner in crossfade | Join at crossfade 50%: Atmosphere.Color is within 2 units of the expected blend on the first frame, then continues smoothly |
| 11 | Clear zones | During Fog Night (High quality): no wisp sprite over any occupied pad or within 12 studs of the Hodag spawn; lair FogWisp rate = 1.0, not 2.0 |
| 12 | Low quality | Graphics Low: lair FogWisp = 0 during baseline and Fog Night; Town 1.0, Wilds 1.0; Bloom off; driver 5 Hz |
| 13 | Fog Night effects | During EVENT only: income ×1.1 (Jersey Devil familiar 150 × 1.1 = **165/s** before other mults); wild interval 30 s; 10,000 forced wild Common rolls: Hidebehind 40% ± 1.5 pts; rarity odds unchanged (80/16.4/3.4/0.2 ± 0.5) |
| 14 | Gift is deterministic (U1) | Gifted Blood Moon: 10,000 wild and Rift rolls match **base** tables (no focus, no variant); income ×1.5 for exactly 600 s; banner "{DisplayName} summoned a Blood Moon over Hollowmere!" with no price, Robux symbol or link |
| 15 | Pedlar relic deterministic (U1) | Called Fog Night: income ×1.1 only; wild interval stays 45 s; focus off; Hollow Rite catches count ×1 |
| 16 | Tithe and offline | Earn for 60 s during Fog Night: Tithe rises at the base rate; a save during the event writes `offline.rate` without the ×1.1 |
| 17 | Rare+ cap (U1) | Force two Rare rolls 20 min apart: the second becomes "no event" |
| 18 | Queue and refund (U1) | Light a Pedlar relic while busy: charged, queued with the real time; leave before it starts: cash refunded once |
| 19 | First Night | Fresh account: after step 8 + 6:00 in an idle server, a Fog Night starts within 1 roll window; never more than once per 20 min per server |
| 20 | Onboarding players | A player at step 3 during Fog Night: no HUD omen/title; chat line visible; Hodag clear zone intact |
| 21 | Reduced Motion | No breathing, no flashes; colour crossfade still gradual |
| 22 | Palette | No purple anywhere (reds G ≥ B, cool tints R ≤ G); Rift colour ≤ 2% of the view in every capture |
| 23 | No shop | No MarketplaceService prompt, shop card or link during any phase or from the chip |
| 24 | Client spoof | Firing any event remote from a client can't start, end or extend an event |
| 25 | Analytics | In a published test place, one full Fog Night logs W1 ×5 stages per present player, W3 once per player, W2 for a mid-event joiner; ≤ 3 fields, no PII |
| 26 | Server shutdown | `BindToClose` during EVENT: clients begin RETURN; no errors; next server starts at BASELINE |

## 19. Sources
- Art Director, **Event Atmosphere Profiles + Transitions** v0.1: `art/vfx/atmosphere-events.md` (§0 rules, §1 profiles, §2 transition system, §2.4 join mid-event, §3 budgets, §4 hours, §5 conflicts)
- Art Director, **Atmosphere Pass**: `art/vfx/atmosphere-pass.md` (§2 baseline, §3.4 clear zones, §3.5 Low quality)
- Roblox, **Paid random items**: https://create.roblox.com/docs/production/monetization/paid-random-items (read 4 Nov 2026)
- Roblox, **PolicyService**: https://create.roblox.com/docs/reference/engine/classes/PolicyService
- Roblox, **Developer products**: https://create.roblox.com/docs/production/monetization/developer-products
- Roblox, **TweenService** (`GetValue`): https://create.roblox.com/docs/reference/engine/classes/TweenService
- Roblox, **Workspace** (`GetServerTimeNow`): https://create.roblox.com/docs/reference/engine/classes/Workspace
- Roblox, **TextChannel** (`DisplaySystemMessage`): https://create.roblox.com/docs/reference/engine/classes/TextChannel
- Roblox, **Sky** (`MoonAngularSize`, `StarCount`, `CelestialBodiesShown`): https://create.roblox.com/docs/reference/engine/classes/Sky
- Specs 03, 06, 07, 08, 09 v2.2, 10, 11 v1; `specs/tools/pacing_sim.py` and `verify_odds.py` (spec 11 numbers)
