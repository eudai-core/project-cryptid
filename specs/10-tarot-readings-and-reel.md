# Spec 10 v2: Earn-Only Tarot Readings, the Fate Reel, Server Luck, Ritual Essence + the Bestiary

> **Change note (v2, Wed 4 Nov 2026): EUDAI'S DECISION B** (12:57 UTC, 4 Nov, Eudai's own words in the Analytics Lead's chat, confirmed by Grok Bot). It **supersedes the earlier paid-crate approval** that v1.x was built on:
> - **Tarot readings are EARN-ONLY.** No paid crates, cases, readings or pulls. **Every reel is a free pull.** The paid side of the Tarot Table is the **Bound Rites** (fixed bundles, exact contents shown, no odds; spec 09 v3 §9.5).
> - **Paid-reel rules are DORMANT** (style guide D37): the fixed paid spin (5.0 s, slow-down at 3.8 s) and "no emphasis on paid reels" are kept **only as a dormant note** (§3.6). They are **not** a launch or January build item.
> - **Server Luck = Robux purchase** (Eudai's answer, option A, relayed by Grok Bot via the Analytics Lead). It is the **only paid random item** (a paid probability modifier), PolicyService-gated, with base vs boosted odds live (§5; gate in spec 09 v3 §6).
> - **Skip Animation** is **earnable** (40 earned cards, ~day 10 F2P in spec 11's pacing model [A]) **and** purchasable (99 R$); **Auto-Open** and **Open x3** are passes for **earned** readings only (§6).
> - **Readings are silent** (no announcements). Buyers of **server-wide** boosts get a named thank-you banner with no price or link; **personal Robux purchases never announce** (spec 08 v2.2, style guide D29/D36).
> - **Art aligned to [`/workspace/project-cryptid/art/style-guide.md`](../art/style-guide.md) v0.6 rulings (file now at v0.7, which keeps them and adds D38–D40):** Mythic = **GoldBright `#C9A55A` + Bone `#E8E0CF` flare + a thin Rift-green `#7FA34A` core** (D34), Rift green ≤ **2%** (≈ 2% of a card's area on cards; D35), Mythic sky ≤ **5% of the screen for 20 s**, fired by **every free source** (D26/D29 as amended; v2.1: nothing bought at a shop, with Robux or cash, is a free source; Rift belt catches are).
> - **Silhouettes are cut** (strip cards, Bestiary, onboarding goal 3; D40): replaced by **tier pips + a text tease** (§8, §9; spec 01 v2.1). Final goal-3 line: **"Three marks. Rarer things are watching."**
> - **Server Luck is a JANUARY item, NOT in the launch build** (§5, spec 09 v3 §11).
> - **v2.1 (compliance audit (`compliance-audit-cash-random.md` §4; Grok Bot approved, 4 Nov; cash = paid currency)):** §10 free-source rule: Nothing bought at a shop, with Robux or cash, counts as a free source. The Rift belt counts as a building, so its catches stay free sources; Pedlar buys don't.
> - **From spec 11 v1 §11 (approved by Grok Bot as the design base, 4 Nov):** §7.2 gains the Shiny Rite (300), Corruption Rite (1,000), mastery frame dyes (50) and Ward Candle skins (100, Update 3); all deterministic. Readings get the variant roll (99.3 / 0.5 / 0.2, spec 09 v3 §4).
>
> v1.2 history (superseded where it conflicts): paid spin approvals, ~37% free emphasis at Luck ×3 (still valid), Mythic sky on free sources.

**Owner:** Cryptid Growth Strategist · **Builder:** Cryptid Systems Architect · **Visuals:** Cryptid Art Director · **Status:** Draft **v2.1** (Wed 4 Nov 2026; v2.1 audit fix: free-source wording) · see also spec 11 (multiplayer and pacing, separate workstream)
**Companion:** spec 09 v3 keeps deck odds (§5.1), pity (§5.2), free routes (§5.4), the POLICY GATE (§6), Bound Rites (§9.5), the PRICE TABLE (§10) and the launch split (§11).
**Ships:** **January (post-launch)**, except the **NEW stamp + Bestiary record** (§8), a launch stretch.
**Prices:** every Robux price is **PROPOSED, pending Eudai's approval**. Nothing is created, priced live or published.

> **Overriding rule (from Eudai, via Grok Bot, 4 Nov):** **no visual may ever imply a higher tier than the one the server rolled.**
> **Design bible tension (for Eudai):** the bible says "no reel, no spinner, no near-miss" and "no paid luck boosts". The reel and honest near-miss were approved on 4 Nov (v1.x); **paid Server Luck** follows Eudai's option A. Readings themselves are now earn-only, which removes the bible's main concern. Eudai to confirm the bible is updated for Server Luck.
> **[A]** = design assumption, not measured data; **[A v2]** = new in this version, not yet approved. Odds: `specs/tools/verify_odds.py`; reel honesty: `specs/tools/reel_check.py`; Essence: `specs/tools/essence_math.py`; Skip earn goal: `specs/tools/skip_unlock_math.py`.

---

## 1. Goal
Make every reading feel like a ritual with real suspense, while staying **provably honest**: the result is fixed before anything moves, everything you see is drawn from the odds you were shown, and **no reading is ever sold**.

## 2. The reading flow (per card)
1. **Shuffle:** 0.8 s.
2. **Server roll:** from the posted odds (boosted if Server Luck applies to this player, Epic 100% on the pity card), **then** the strip is built (§3). The server checks the card came from an **earned** token or deck; anything else is refused and logged (safety net, D37).
3. **Fate Reel:** the strip slides under the marker and stops on the winner (§3).
4. **Charge-up:** the card pulses **up** through the rarity colours to its **true** tier (§4).
5. **Reveal:** design-bible ladder (Common 0.6 s, Uncommon 1.0 s, Rare 2.0 s, Epic 3.5 s), plus a **NEW** stamp if first-ever (§8).
6. **Readings never announce** (spec 08 v2.2). A Mythic may still trigger the sky (§10), with no name banner.

## 3. The Fate Reel (horizontal slider)

### 3.1 Honesty rules (all must hold)
| # | Rule |
|---|---|
| 1 | The **server rolls the result first**, from the posted odds |
| 2 | **Every other card on the strip is drawn independently at the same posted odds** that applied to this card (the boosted table if Server Luck applies; on the pity card the posted odds are Epic 100%, so the strip is all Epics). **Never** weight higher tiers next to the winner |
| 3 | The winner stops under the marker with a **random offset inside its own card** (±42% of card width). The marker may stop just short of or past a neighbour, but **always ends on the winner's card** |
| 4 | **Every reel is a free pull** (decision B). Honest near-miss emphasis (slow-down, marker glow, heartbeat, needle brighten) plays **only** when a card at W−1 or W+1 is **higher than the winner AND in the deck's band**: Pale (incl. boosted Pale) = **Rare or higher**; Blood = **Epic**. Nothing else triggers it. No "almost", "so close", "unlucky" copy, ever |
| 5 | The result **never changes** after the reel stops |
| 6 | **Skip Animation** jumps straight to the same result. **Open x3** runs 3 reels side by side, **each with its own server roll**, using 3 earned cards |
| 7 | Per-tier odds are shown before opening and update **live** when Server Luck applies (base vs boosted, §5.5) |

### 3.2 Numbers
| Setting | Value |
|---|---|
| Strip length | **50 cards** [A] |
| Winner index W | Random **38–44** (0-based) |
| Card size | 120 × 168 px desktop, 96 × 134 px phone; 8 px gap |
| Visible window | ~7 cards; marker centred |
| Start | 0.15 s ease-in |
| Normal spin | **4.0 s**, `Quint`, `Out` |
| Honest near-miss spin | **5.5 s**, `Exponential`, `Out`; final ~1.2 s crawl past the higher neighbour |
| Marker glow (near miss) | Gold → GoldBright over the last 1.2 s; never a rarity colour; on the marker, not a card |
| Heartbeat (near miss) | 2 beats, 0.6 s apart, last 1.2 s |
| Stop | 0.1 s settle |
| Expected emphasis rate | **Pale 17.3%**, **Blood 17.1%**, **Pale at Luck ×3 37.3%** (approved 4 Nov). Exact expectations from `reel_check.py` |
| Why Blood uses Epic | "Rare+" would fire on ~45% of Blood reels; the Epic band gives 0.9 × (1 − 0.9²) = **17.1%** |
| Strip card faces | Rarity **frame** + **tier pips** only (§9). No silhouettes, no species names |

### 3.3 Reduced Motion
No scrolling: the strip fades in already stopped (0.15 s). No slow-down or glow movement. Near miss: the heartbeat sound still plays (SFX toggle covers it). Charge-up: one 0.3 s fade to the true tier colour.

### 3.4 Sounds (placeholders; Art Director/audio, Roblox-licensed only per D31)
| Cue | When | Placeholder id |
|---|---|---|
| Whoosh | Spin start | `rbxassetid://TBD_reel_whoosh` (vol 0.4) |
| Tick | Each card passing (max 20/s) | `rbxassetid://TBD_reel_tick` |
| Heartbeat | Honest near miss only | `rbxassetid://TBD_reel_heartbeat` |
| Thunk | Stop | `rbxassetid://TBD_reel_stop` |
| Tier chime ×6 | Charge-up end, **true** tier | `rbxassetid://TBD_chime_common` … `_mythic` |

### 3.5 Server vs client
- **Server:** checks the source is earned, rolls, builds the full strip (`Random.new()`), picks W and offset, computes `nearMiss`, saves to `tarot.freeLog` **before** sending, then fires `ReelResult` to **that player only**: `{readingId, cardIndex, tableId, tableVersion, luckMult, strip[50], winnerIndex, offset, nearMiss}`.
- **Client:** animates only; timing comes only from `nearMiss`. **Rejoin:** the stored strip replays (or the result shows if skipped).

### 3.6 DORMANT: paid-reel rules (not built)
Kept only in case a paid random path ever returns (style guide D25/D37): every paid reel would get one **fixed 5.0 s spin with the slow-down at 3.8 s**, identical every time, with **zero** emphasis. **Not a launch or January build item.** The paid guard in the reveal module stays as a safety net (if a reel ever arrived flagged as bought: no emphasis, no sky, no banner).

## 4. Pre-reveal charge-up
Pulses **upward** through the rarity colours in order, **stops on the true tier**, never shows a colour above it.

| True tier | Steps shown | Total time |
|---|---|---|
| Common | BoneDim | **0.4 s** |
| Uncommon | BoneDim → Moss | **0.8 s** |
| Rare | … → Silver | **1.3 s** |
| Epic | … → Blood | **1.8 s** |
| Legendary (later) | … → GoldBright (plain) | **2.2 s** |
| Mythic (later) | … → GoldBright + **Bone flare** + **thin Rift-green core** (D34) | **2.5 s (cap)** |
- Soft pulses, ≤ 3 per second. The client builds steps from `TIERS[1..trueTier]` only. Skip Animation bypasses it.

## 5. Server Luck (Robux dev product) — Eudai option A — **JANUARY, not the launch build**
**Ships January** with the Tarot Table; nothing of it (product, chip, banner, odds panels, PolicyService gate) is in the launch build. Launch keeps only the optional PolicyService skeleton (spec 09 v3 §11).
**The only paid random item in the game** (a paid probability modifier). Policy gate: spec 09 v3 §6 (scope: Server Luck only).

### 5.1 What it does
For every **eligible** player in the server, **Rare and Epic weights (Legendary/Mythic later) ×L, Common absorbs the change**, Uncommon unchanged, so each table still sums to exactly 100%.
- **Affects:** Rift belt rolls, wild spawns, **Pale Deck** readings (earned) of eligible players in this server.
- **Doesn't affect:** the Blood Deck ("Server Luck doesn't change this deck"), the Pedlar (one global UTC seed), daily rewards, expedition loot, pity rules.
- **Restricted players (`ArePaidRandomItemsRestricted` true, or policy unknown):** **not affected** (conservative, [A v2], spec 09 v3 §6.3). Their rolls stay ×1, their panels show base odds, and they see **no** Luck chip, banner, chat line, product, prompt or link.

### 5.2 Live tables (verified by `verify_odds.py`, all 100%)
| Table | Base (C/U/R/E) | ×2 | ×2.5 | ×3 (cap) |
|---|---|---|---|---|
| Rift belt | 72 / 24 / 3.6 / 0.4 | 68 / 24 / 7.2 / 0.8 | 66 / 24 / 9 / 1 | 64 / 24 / 10.8 / 1.2 |
| Wild spawns | 80 / 16.4 / 3.4 / 0.2 | 76.4 / 16.4 / 6.8 / 0.4 | 74.6 / 16.4 / 8.5 / 0.5 | 72.8 / 16.4 / 10.2 / 0.6 |
| Pale Deck (per card) | 55 / 35 / 9 / 1 | 45 / 35 / 18 / 2 | 40 / 35 / 22.5 / 2.5 | 35 / 35 / 27 / 3 |
Species within a tier stay equal (e.g. Pale ×3: each Epic 1.5%, each Rare 13.5%). Free event luck ×1.5 (Rift Tide) multiplies in; combined cap ×3.

### 5.3 Stacking and caps
| Purchase while active | Multiplier | Time added | Cap |
|---|---|---|---|
| 1st | **×2** | 10:00 | – |
| 2nd | **×2.5** | +10:00 | – |
| 3rd | **×3** | +10:00 | **×3 max** |
| 4th+ | ×3 | +10:00 | **60:00 max**; button: "Luck is at its peak" (disabled) |
- Ends → ×1 (no step-down). Free **event** luck (Rift Tide ×1.5, scheduled, earn-only) multiplies with paid luck; **combined cap ×3**; panels show the **effective** multiplier.
- Per buyer: max **5 per UTC day** [A].

### 5.4 Price (PROPOSED)
- **First Server Luck per account: 49 R$** (shown as "Your first Server Luck: 49 R$ (once)"). **Standard: 199 R$.**
- Comparable: **Steal a Brainrot "2x Server Luck" 249 R$** (also 4x 999, 8x 2,999; spec 09 v3 §10).
- Two dev products (`ServerLuck_First`, `ServerLuck`), **unlisted**; the server picks which to prompt, only for eligible players.

### 5.5 Live display (eligible players)
- **Before purchase:** the card shows, for each affected table, **base vs boosted at the next step** (e.g. "Pale Deck: 55 / 35 / 9 / 1 → 45 / 35 / 18 / 2"), the time added, the cap, and **"Details"** with every species %. Both columns sum to exactly 100%.
- **While active, in the reading UI:** the Pale Deck panel shows **Base** and **Boosted (×2.5)** tables side by side, both summing to 100%, with "**Server Luck ×2.5 · 14:32 left**", updating every second; the same on Rift belt Details and Wilds odds. Reverts within 1 s of expiry.
- HUD chip (eligible players only): "**Luck ×2.5 · 14:32**".
- **Thank-you banner** (server-wide boost, spec 08 v2.2 §4b, D36), eligible players only: "**{DisplayName} summoned Server Luck ×2 over Hollowmere!**" No price, no Robux, no buy link.

### 5.6 Policy (verified 4 Nov 2026)
- Roblox lists "**Probability modifier items** | Luck boosts …" as paid random items and says paid items that "augment the odds of other random outcomes must also be explained before purchase … The new odds … must also be dynamically updated when these items are active to show the user's true odds" ([Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items)).
- So buying is gated by `PolicyService:GetPolicyInfoForPlayerAsync(player).ArePaidRandomItemsRestricted` ([PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService)): **fail closed**, hidden (never shown-then-blocked), rechecked before the prompt and in `ProcessReceipt`, product unlisted. Full rules: spec 09 v3 §6.3.
- **Restricted players benefiting:** the docs don't cover it. **Conservative call:** they don't benefit and don't see it (§5.1). **Flag for Eudai:** if Roblox confirms benefiting is fine, we could later let them benefit (still never see the product).
- **Restricted receipt edge case:** don't start the boost; grant a fixed Chest of cash instead, shown and logged.

## 6. Reading passes (January)

### 6.1 Skip Animation: earnable AND purchasable
| Part | Spec |
|---|---|
| What it does | Every reading (and reel) can jump straight to the same result, including first-time species. Everyone can already skip **seen** species |
| **Earn path** | **Open 40 earned tarot cards** (any deck, counted per card) [A v2] |
| Robux shortcut | **99 R$** (PROPOSED), a normal pass |
| Progress UI | Always visible on the Tarot Table: "**Cards read: 24 / 40 · Skip Animation unlocks at 40**". The shop card shows the same counter next to "See Price" |
| Fairness | The counter, the 40 target and every token rate are **fixed**. No hidden slowdowns, **no rate change after a purchase prompt** is shown or declined. Buying doesn't reset or alter the counter; earning after buying changes nothing |
| Data | `skip.cardsRead` (int), `skip.unlocked` (bool), `skip.source` = `"earned"` / `"purchased"`, `skip.unlockedAt` |

**Why 40 cards (the maths, [A v2]):** `tools/skip_unlock_math.py` uses **spec 11's pacing sim** (`tools/pacing_sim_output.txt`, 4 Nov; greedy F2P player, **2 × 20 min/day** [A], 200 seeds; model output, not data). Rebirth tiers per spec 11: cost **$5M × 3^(n−1)**, multiplier **1 + 0.5n**, launch max **R7**; Tithe gates $5M / $20M / $49M / $150M / $454M. F2P medians: Rebirth 1 ~day 2 (0.7 h), full Bestiary ~day 2, Rebirth 2 ~day 3 (1.3 h), **Rebirth 3 ~day 4 (2.0 h)**, Rebirth 4 ~day 6 (3.3 h), **Rebirth 5 ~day 10 (6.2 h)**. Each free route gives 3 cards (spec 09 v3 §5.4):

| Day (model) | Grants that day | Running total |
|---|---|---|
| 1 | Tithe $100K, Tithe $1M, Bestiary 50% | 9 |
| 2 | Rebirth 1 gate (Blood), Bestiary 100% (Blood) | 15 |
| 3 | Tithe $10M, Rebirth 2 gate, Moon Vigil wk 1 | 24 |
| 4–5 | Rebirth 3 gate, Tithe $100M | 30 |
| 6–7 | Rebirth 4 gate, Moon Rite wk 1 | 36 |
| **10** | Moon Vigil wk 2, **Rebirth 5 gate** | **42 → goal of 40 reached** |
| 14 | Moon Rite wk 2 | 45 |

| Goal | Reached (model) |
|---|---|
| 30 cards | ~day 5 (too quick) |
| 35 cards | ~day 7 |
| **40 cards** | **~day 10, the same window as Rebirth 5** (inside the 1–2 week brief) |
| 45 cards | ~day 14 |
| 300 cards | ~day 308: far too slow at ~6 free cards a week after week 2 |
- **Rebirth 2 alone** (~day 3) is too quick. **Rebirth 5** (~day 10) fits too, but a card count ties the reward to readings and shows steady progress ("Cards read: 24 / 40"). Players who rush rebirths reach 40 sooner; light readers later.
- If spec 11 retunes rebirth pacing or token rates, re-run the script and move the target so it stays ~day 10–14.

### 6.2 Auto-Open and Open x3 (passes, approved earlier per Grok Bot)
| Pass | Price (PROPOSED) | What it does | Rules | Comparable |
|---|---|---|---|---|
| **Auto-Open** | **149 R$** | Opens your **earned** card tokens one at a time | Visible **Stop** button. Stops on Rare+ (setting: Rare+ / Epic only) or when tokens run out. Never spends Robux or cash, never prompts. Fast reel (1.0 s) unless Skip is owned | PS99 Auto Farm 175, Auto Tap 350 |
| **Open x3** | **249 R$** | Three reels side by side, each with its own server roll | Uses 3 **earned** cards you already have; adds none | PS99 "+15 Eggs" 625 |

### 6.3 Policy finding for the passes
Probably **not** paid random items: they don't buy a random outcome, add cards or change odds, and every card still needs an earned token. Roblox's FAQ says earned random items are out of scope if players "cannot purchase (directly or indirectly) the random outcome". **But the docs never address convenience passes on earned random items**, and the FAQ example says "can only be opened through gameplay or earned currency". **Ambiguous: flagged for Eudai** (spec 09 v3 §6.2 F1). Fallback if Roblox disagrees: hide the three passes for restricted players. Skip Animation's earn path also gives every player a free way in.

## 7. Ritual Essence (duplicate meter, January)

### 7.1 Earning
| Source | Essence |
|---|---|
| Duplicate from an earned reading: Common / Uncommon / Rare / Epic | **1 / 3 / 10 / 40** (Legendary/Mythic later 120 / 400 [A]) |
| Bestiary milestones (§8) | 25 / 50 / 100 / 200 |
| **Bound Rites** (spec 09 v3 §9.5), fixed amounts | 30 / 60 / 60, **lifetime cap 150 paid Essence** |
- Wild and Rift catches don't give Essence [A].

### 7.2 Sinks (all deterministic)
| Craft | Cost |
|---|---|
| Bind a **chosen** Uncommon / Rare / Epic (you pick the species) | **30 / 120 / 400** |
| Gilded card back (cosmetic, per species) | **50** |
| **Shiny Rite**: turn one owned cryptid into its Shiny (you choose) | **300** (spec 11 §3.3; doesn't fill the "found" Shiny page, which needs a rolled Shiny [A]) |
| **Corruption Rite**: turn one owned cryptid into its Corrupted | **1,000** (same rule) |
| Mastery frame dye (Update 1) | **50** |
| Lair Ward Candle skin (**Update 3**, fresh review then) | **100** |
| **Banned forever:** "guaranteed tier" pulls with a random species, mutation/trait rerolls, any random craft, converting Essence into tokens or readings | – |
- Because Bound Rites put a small fixed amount of Essence behind Robux, **every Essence sink must stay non-random**: that keeps every Robux path ending in a chosen, known result. A guaranteed **chosen** cryptid is fine (non-random); a guaranteed **tier** with a random species inside would be a paid random item, so it doesn't exist.

### 7.3 Maths (`essence_math.py`, every card a duplicate)
| Deck | Essence per card | With pity | Cards to chosen Uncommon / Rare / Epic |
|---|---|---|---|
| Pale | 2.90 | **3.69** | **8 / 33 / 109** |
| Blood | 9.50 | **10.46** | **3 / 12 / 38** |
- Paid Essence (max 150 lifetime) covers one chosen Rare at most, **never** a chosen Epic (400), a Shiny Rite (300) or a Corruption Rite (1,000). A F2P player reaches a chosen Rare in ~6 weeks [A].

### 7.4 Pity and Essence are separate
Neither resets the other. The panel shows "**Pity: 12 / 40**" and "**Essence: 236**".

### 7.5 Not sold on its own [A v2]
Essence is **never** sold standalone and is not in cash bundles, the Starter Pack, Satchels or the Moon Pass paid track. Its **only** paid source is the fixed amount inside Bound Rites (150 lifetime).

## 8. NEW stamp + the Bestiary (grimoire)
- **NEW stamp:** the first time a player gets a species from any source, its reveal card gets a **NEW** wax seal and the species is recorded (first-seen date, source).
- **Onboarding tease (spec 01 v2.1 goal 3, D40):** 3 tier pips (Common, Uncommon, Rare) + "**Three marks. Rarer things are watching.**" in Bone `#E8E0CF`; static, shown once, never beside a result.
- **Unowned entries (v2, silhouettes cut):** **tier pips** (● Common, ●● Uncommon, ●●● Rare, ●●●● Epic; Mythic pips in GoldBright with a Bone glint) + a one-line **text tease** in Bone italics, e.g. "●●●● Epic · *Wings like torn sails over the Pine Barrens.*" No silhouette, no species name until caught.
- **Milestones** (% of the current roster; 12 at launch):

| Milestone | Launch (of 12) | Rewards |
|---|---|---|
| 25% | 3 | Title "**Lantern-Bearer**" + 25 Essence |
| 50% | 6 | 3 Pale card tokens + 50 Essence |
| 75% | 9 | Title "**Warden of the Hollow**" + Bestiary gilt edge + 100 Essence |
| 100% | 12 | Title "**Keeper of the Hollow**" + 3 Blood card tokens + 200 Essence |
- New cryptids lower the %; nothing claimed is lost.
- **Launch (stretch):** NEW stamp + record + titles + tier-pip teases; Essence/token rewards banked until January.

## 9. REEL VISUALS (Art Director owns these; style guide v0.6 rulings, file v0.7)
Palette tokens only. **Epic = Blood `#7A0F12`, never purple. Rift green ≤ 2%** (on cards: ≈ 2% of the card's area; D35).

| Element | Look |
|---|---|
| Strip backing | Ash `#1A1719`, Gold `#9C7A3C` 1 px rim at 40%, 4 px corners |
| Common / Uncommon / Rare frames | BoneDim `#A79F90` plain / Moss `#5E7A4A` one sigil / Silver `#8C9AA3` two sigils |
| Epic frame | Blood `#7A0F12` + Bone inner line, four sigils |
| Legendary frame (later) | Plain GoldBright `#C9A55A`, filigree |
| **Mythic frame (later)** | **GoldBright `#C9A55A` frame, distinct shape, Bone `#E8E0CF` flare, a THIN Rift-green `#7FA34A` core** (≤ ~2% of the card area). Not Rift-heavy (D34) |
| **Card face** | Soot `#2A2427` with **tier pips** (Bone) centred; no silhouette, no name |
| Marker | Thin Gold needle, bone-carved notches; near miss: brightens to GoldBright with an 8 px glow; never a rarity colour |
| Near-miss look | Marker glow pulses twice with the heartbeat; edge vignette −15%. **No glow on any card** |
| Charge-up | Frame glows each colour up to the true tier only; ≤ 3 pulses/s |
| NEW stamp | Wax seal, Rift-green accent within the 2% rule, "NEW" in Bone. UI only: **no Neon** anywhere in readings (D38) |
| Pity / Essence bars | Blood fill / GoldBright fill on Soot |
| Server Luck chip | Ash fill, Rift hairline accent |

## 10. Mythic server sky (January; Grok Bot ruling, style guide v0.6 D26/D35 as amended)
- **Trigger:** a real server-rolled Mythic from **every free source**: earned readings, wild catches, **Rift belt** catches, **expeditions**, free event/daily rewards. Nothing bought at a shop, with Robux or cash, counts as a free source. The Rift belt counts as a building, so its catches stay free sources; Pedlar buys don't. Bound Rites never contain a Mythic, and nothing bought fires it. Decided by the server from the roll's source.
- **Banners:** earned-reading Mythic → sky, **no** name banner (readings silent). Wild or Rift-belt Mythic → sky + the spec 08 banner. Expedition Mythic → sky only [A v2].
- **Look:** **Gold-led**: Atmosphere colour blends toward GoldBright `#C9A55A` with a Bone `#E8E0CF` flare at the horizon and a **thin Rift-green `#7FA34A` core** (light shaft/crack). **Rift green ≤ 5% of the screen**, the one exception to the 2% rule, **for the 20 s only** (D35). Keeps the readability floor: Ambient ≥ `(60,55,52)`, OutdoorAmbient ≥ `(80,74,70)`, Atmosphere Density ≤ 0.18, Haze ≤ 0.3. No flashes.
- **Duration:** 20 s (2 s in, 16 s hold, 2 s out) [A]. Reduced Motion: instant swap, 10 s.
- **Rate limit:** 1 per server per 10 min.

## 11. Data to save
| Key | Type | Notes |
|---|---|---|
| `tarot.essence` | int | Never negative |
| `tarot.essencePaid` | int | Lifetime Essence from Bound Rites, ≤ 150 |
| `tarot.crafted[]` | `{craft, species, t}` | Audit |
| `tarot.pity` | `{pale, blood}` | |
| `tarot.freeLog` | last 50 readings incl. strips | Replay on rejoin (no paid ledger: readings aren't sold) |
| `tarot.autoOpenStopAt` | "Rare" / "Epic" | |
| `skip.cardsRead`, `skip.unlocked`, `skip.source` (`earned`/`purchased`), `skip.unlockedAt` | int / bool / string / number | §6.1 |
| `bestiary[species]`, `bestiary.milestones`, `bestiary.sealedRewards` | | §8 |
| `titles.owned`, `titles.equipped` | | |
| `luck.firstBuyUsed`, `luck.boughtToday {utcDay, count}` | | §5.4, §5.3 |
| Server memory only | `serverLuck = {mult, endsAt, eventMult}`, `policy[userId]` | Not saved |

## 12. Edge cases
| Case | Behaviour |
|---|---|
| Luck ends mid-reel | The card already rolled at its luck; the panel shows the odds used |
| Pity card in a reel | Strip is all Epics; no near miss possible |
| Earned token used while Server Luck is active (eligible player) | Boosted Pale table; Rare+ emphasis band |
| Same, restricted player | Base table; no chip; normal emphasis rules |
| Server shuts down with luck active | Luck ends; copy said "for this server" |
| Auto-Open and a purchase prompt | Auto-Open never prompts; a manual purchase pauses it |
| Open x3 with 2 tokens left | Plays 2 reels |
| Player leaves mid-reel | Result saved; shown on rejoin |
| Essence craft spam | 0.5 s debounce; cost check inside the profile update |
| Skip bought at 39 / 40 | `source = "purchased"`; the counter keeps counting, nothing else changes |
| Policy call fails | Treated as restricted: no Server Luck anywhere for them; everything else works |

## 13. QA (17 tests)
| # | Test | Pass when |
|---|---|---|
| 1 | `python3 specs/tools/verify_odds.py` | All tables incl. 9 Server Luck tables OK; "ALL TABLES SUM TO EXACTLY 100%"; exit 0 |
| 2 | 10k-reel neighbour test: Studio dump, `reel_check.py --strips dump.json` | Every W±1 and other-card frequency within 4σ; "REEL CHECK PASSED" |
| 3 | `reel_check.py --cheat-demo` | "CHEAT DETECTED (good)" |
| 4 | Marker on winner, 10,000 reels | `|offset| < 0.5`; card under the marker = granted cryptid |
| 5 | Skip shows the same result (200 readings) | Shown = granted = server roll |
| 6 | Near-miss trigger | Emphasis only when W±1 is higher and in band; rates ≈ 17% |
| 7 | **Every reel is free** | `reel_check.py` fails any reel flagged paid; the server refuses a reading whose source isn't an earned token/deck |
| 8 | Charge-up ceiling (1,000 reveals) | No step above the server tier |
| 9 | Reduced Motion | No scroll; one 0.3 s fade |
| 10 | Copy audit | No "almost", "so close", "unlucky", "nearly" |
| 11 | Server Luck stacking | ×2 → ×2.5 → ×3 → ×3; 10 → 20 → 30 → 40 min; disabled at 60 |
| 12 | **Server Luck live odds** | During ×2.5 the Pale panel shows Base 55/35/9/1 and Boosted 40/35/22.5/2.5 side by side (both 100%), correct timer; reverts ≤ 1 s after expiry |
| 13 | **Restricted account** (Player Emulator, UK) | No Server Luck card, prompt, price, link, chip, banner or chat line; their rolls and panels stay ×1 while another player's boost is active |
| 14 | **Failed policy call** (mocked) | Same as restricted, all session |
| 15 | **Pre-purchase disclosure** | The card shows base vs next-step boosted for every affected table + "Details" before See Price |
| 16 | **Skip earn path** | Counter shows "Cards read: N / 40"; unlocks at 40 with `source = earned`; token rates identical before and after a declined prompt (logged over 100 sessions); buying sets `source = purchased` |
| 17 | Essence | Pity/Essence independence; Bound Rite Essence capped at 150 lifetime; no random craft exists |

## 14. Sources
- Roblox, **Paid random items** (probability modifiers; dynamic odds; earned-reward exemption; restricted treatments): https://create.roblox.com/docs/production/monetization/paid-random-items
- Roblox DevForum (official), **Clarifying requirements for paid random items**, 26 May 2026 (FAQ on earned-only items): https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622
- Roblox, **PolicyService**: https://create.roblox.com/docs/reference/engine/classes/PolicyService
- Roblox, **Community Standards** (bundles with a random item): https://about.roblox.com/community-standards
- Roblox, **Monetization** guidelines: https://create.roblox.com/docs/production/monetization
- Comparables: spec 09 v3 §10 and `specs/research/` snapshots (4 Nov 2026)
- Art: `/workspace/project-cryptid/art/style-guide.md` v0.7 (D25, D26, D29, D34–D38, D40); `art/vfx/vfx-audio-plan.md` §2.7 (goal-3 pips)
