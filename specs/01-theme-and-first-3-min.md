# Spec 01: Occult UITheme + First 3 Minutes

**Owner:** Cryptid Growth Strategist · **Builder:** Cryptid Systems Architect · **Status:** Draft v2.2 (2026-11-04: v2.2 audit fix, belt independence + "Details" odds button. v2.1: Neon Rift trim removed (D38–D40); goal-3 silhouettes cut → tier pips + final tease line; Bone Altar III–X from spec 11. v2.0 2026-11-04: Hodag catch moved to ~0:35, bound ~0:45; goal chain re-ordered; Nightly Offering day 1 in session 1. v1.2: PR #2 answers)
**Paid products in this feature:** none. **Paid randomness:** none.

> **Director ruling, 11 Nov 2026.** Where this spec's world-look rules conflict with spec 15, spec 15 wins: a purple night, coloured flames, and Neon on flames, portals, runes, signs, and eyes, within the budgets in [`docs/VISUAL_REFERENCES.md`](../docs/VISUAL_REFERENCES.md). **A2 palette tokens still apply to UI**, including "no bright purple, no saturated blue, no pastel, no rounded bubble UI" on screens. The world rule that Neon is only the Mothman Hatchling's eyes and the Dover Demon's eyes is superseded for flames, portals, runes, signs, and eyes. The Rift Fissure stays RiftDim, not Neon (D38, D41). The assumption line below that says the tutorial wild catch is "any Common" is superseded: the tutorial catch is the Hodag (D33, ruling 18).

> **v2.1 change (Wed 4 Nov 2026, Art Director decisions D38–D40, relayed by Grok Bot; source: `/workspace/project-cryptid/art/style-guide.md` v0.7 decision log + `art/vfx/vfx-audio-plan.md` §2.7):**
> - **No Neon Rift trim anywhere** (A4): the Rift Fissure belt, the Great Rift pit and the Pedlar's lantern become **RiftDim `#4F6B34`** surfaces (Slate / Metal / SmoothPlastic), lit by **PointLight + particle glow**, with only **tiny Rift `#7FA34A` accents** (D38). **Neon is allowed only for the two eye exceptions:** the **Mothman Hatchling's eyes** (`Eye_R`, `Eye_L`, Neon Blood `#7A0F12`, D10) and the **Dover Demon's eyes** (`Eye_R`, `Eye_L`, Neon GoldBright `#C9A55A`, D13).
> - **Goal 3** (B3): the 3 dark rarity silhouettes are **cut** (D40). In their place: **3 tier-colour pips** (Common BoneDim, Uncommon Moss, Rare Silver) + the final tease line **"Three marks. Rarer things are watching."** in Bone. Silhouettes are P1 (once textures exist).
> - **B4 Bone Altar III–X** (from spec 11 v1 §11 (approved by Grok Bot as the design base, 4 Nov)): levels I–II unchanged; level L ≥ 3 adds `0.25 × 0.75^(L−2)` (×1.2 with l3), costs $8K → $625M, all × 1.5^r after r rebirths.
> - **v2.2 (compliance audit (`compliance-audit-cash-random.md` §4; Grok Bot approved, 4 Nov; cash = paid currency)):** Rift belt spawns never depend on purchases; the belt's odds button is labelled **"Details"**.
> - Palette QA (C15) and A2 rules now use the style guide's **Rift ≤ 2%** rule (D35); Mythic token = GoldBright + Bone flare + thin Rift core (D34).

> **v2 change (4 Nov 2026):** the design bible's first-5-minutes proposal asked to move the guaranteed Hodag catch from ~2:25 to ~0:50 and start the daily ladder at 1 of 7. The maths holds (B3), so this spec adopts it. The catch now comes **before** Pad 3, and the Hodag fills Pad 3 when it's carved. Every step stays affordable from income alone. The 5:00 / step-8 purchase rule and steal protection are unchanged.

> **Assumption labels.** Anything marked **[A]** is a design assumption (not measured data) to be tuned after playtests. No grimoire list file exists yet, so Fresno Nightcrawler and Hidebehind are **proposed entries** that need adding to the 34-cryptid grimoire as Commons. The tutorial wild catch is still any Common.

---

## Part A: Shared occult UITheme

### A1. Goal and fantasy
Every screen should feel like a **candle-lit ritual ledger**: dark, heavy, a little worn, with gold for money and crimson for action. One shared `UITheme` module so every bot builds the same look.

### A2. Palette tokens (the only colours UI may use)

| Token | Hex | Use | Source |
|---|---|---|---|
| `Void` | `#0B0A0C` | Screen backgrounds, overlays (85% opacity) | Brief |
| `Ash` | `#1A1719` | Panel fill | Derived [A] |
| `Soot` | `#2A2427` | Raised cards, inputs, row hover | Derived [A] |
| `Blood` | `#7A0F12` | Primary buttons, danger, "Buy" | Brief |
| `BloodHover` | `#94171B` | Primary button hover/press | Derived [A] |
| `Gold` | `#9C7A3C` | Currency, borders, plaque frame | Brief |
| `GoldBright` | `#C9A55A` | Currency numbers, highlights, Legendary | Derived [A] |
| `Bone` | `#E8E0CF` | Main text | Brief ("bone white") |
| `BoneDim` | `#A79F90` | Secondary text, disabled labels | Derived [A] |
| `Rift` | `#7FA34A` | **Rare use only, small accents** (D38): particles, mutations, "new" pips, Mythic core. Never world trim on Parts, never Neon | Brief ("sickly green") |

**Rules**
- **No bright purple, no saturated blue, no pastel, no rounded "bubble" UI.**
- `Rift` green max **2% of any screen's area** (style guide D35; the Mythic sky may reach 5% for 20 s). It means "supernatural / rare".
- Contrast (computed): `Bone` on `Void` ≈ 15:1; `Gold` on `Void` ≈ 5:1; `Bone` on `Blood` ≈ 11:1. All body text must be `Bone` or `BoneDim`; never `Blood` text on `Void` (too dark).
- Colour is never the only signal: pair with an icon or word (e.g. disabled = `BoneDim` + lock icon).

**Rarity tokens (proposed for later specs, no purple):**

| Rarity | Token colour |
|---|---|
| Common | `BoneDim` `#A79F90` |
| Uncommon | Moss `#5E7A4A` [A] |
| Rare | Tarnished silver `#8C9AA3` [A] |
| Epic | `Blood` `#7A0F12` (with `Bone` text) |
| Legendary | `GoldBright` `#C9A55A` |
| Mythic | `GoldBright` `#C9A55A` + `Bone` flare + distinct frame shape + **thin** `Rift` core (style guide D34) |

### A3. Fonts [A: verify each `Enum.Font` renders in Studio before locking]

| Role | Font | Size (desktop / mobile) |
|---|---|---|
| Display titles, goal banner headline | `Enum.Font.GrenzeGotisch` | 36 / 28 |
| Panel headers | `Enum.Font.Garamond` (bold weight) | 24 / 20 |
| Body, buttons | `Enum.Font.Merriweather` | 18 / 16 |
| Numbers (cash, timers, costs) | `Enum.Font.Oswald` | Plaque cash 28 / 22, plaque income 16 / 14, elsewhere 18 / 16 |

- Minimum text size **14 px** on any device. Use `TextScaled = false` + fixed sizes from the table; `UITextSizeConstraint` max = table value.
- Never use Gothic display font for numbers or body text (readability).

### A4. Materials and frames

**UI (2D)**
- Panels: `Ash` fill, 1 px `UIStroke` in `Gold` at 40% transparency, `UICorner` **4 px** (sharp, not bubbly).
- Primary button: `Blood` fill, 1 px `Gold` stroke, `Bone` text. Secondary: `Soot` fill, `BoneDim` stroke.
- Optional vignette: `UIGradient` from `Void` 0% transparency at edges to 100% at centre.
- Texture art (parchment grain, cracked-gold 9-slice frame): **asset IDs TBD**; build must work with flat colours if assets are missing.

**World (3D)**
- Lair floor/walls: `Enum.Material.Slate` / `Basalt`, colours near `Void`/`Soot`.
- Pads: `CorrodedMetal` ring tinted `Gold`, centre `Slate`.
- Rift conveyor (Rift Fissure belt): `Basalt` belt with thin trim in **`RiftDim` `#4F6B34`** (`Slate`, `Metal` or `SmoothPlastic`; **never Neon**, must not catch Bloom), lit by **1 `PointLight`** (Rift-tinted, range 10, brightness 0.8 [A]) + **particle glow** (`LightEmission`, ≤ 6 alive [A]), with **tiny `Rift` `#7FA34A` accents** only (sparks, seal pips) (D38). The PointLight sits **inside the 8-light plot cap** (D39): if the plot is at 8, one wall candle goes [A].
- **Same rule in the Town** (spec 03 to follow): the **Great Rift pit** edge and the **Pedlar's "new stock" lantern** cage are **RiftDim** surfaces with **PointLight + particle glow** and tiny `#7FA34A` accents, **no Neon**.
- **Neon: two exceptions only, both cryptid eyes:** the **Mothman Hatchling** (`Eye_R`, `Eye_L`, Neon `Blood` `#7A0F12`, style guide D10) and the **Dover Demon** (`Eye_R`, `Eye_L`, Neon `GoldBright` `#C9A55A`, D13). No other Neon in the world or UI (`/workspace/project-cryptid/art/style-guide.md` v0.7, §2 + D38).
- Lighting [A]: `Ambient` near-black, warm candle `PointLight`s (colour `#FFB36B`, range 12, brightness 1.2).

### A5. Motion

| Event | Tween | Duration | Notes |
|---|---|---|---|
| Button hover | colour to `BloodHover` | 0.10 s Linear | |
| Button press | scale 1.00 → 0.96 → 1.00 | 0.12 s Quad Out | |
| Panel open | fade 1→0 + slide up 12 px | 0.25 s Quad Out | |
| Panel close | fade 0→1 | 0.15 s Quad In | |
| Cash count-up | number rolls to new value | 0.40 s Quad Out | Skip roll if change < 1% of balance; just set |
| Income tick "+$X" | floats up 20 px, fades | 0.80 s | Spawns over plaque once per tick |
| Goal banner in | slide down from top | 0.35 s Back Out | |
| Goal complete | gold flash on banner + candle "snuff" sound | 0.50 s | |

- **Reduced Motion** setting (saved): disables slide/scale/float; keeps fades ≤ 0.15 s.
- No screen shake, no flashing faster than 3 times per second.

### A6. HUD cash plaque

- **Position:** top-centre, 24 px from top (below Roblox top bar safe area: use `ScreenGui.ScreenInsets = CoreUISafeInsets`).
- **Size:** 320 × 72 desktop, 240 × 60 mobile.
- **Look:** `Ash` fill, `Gold` 2 px stroke, small sigil icon left.
- **Line 1:** cash, `GoldBright`, `Oswald` 28: e.g. `$1,240`
- **Line 2:** income, `BoneDim`, 16: e.g. `+$11/s`
- **Number format:**

| Range | Format | Example |
|---|---|---|
| < 10,000 | full with commas | `$9,999` |
| 10,000 – 999,999 | 1 decimal + K | `$12.3K` |
| 1e6 – 1e9 | 2 decimals + M | `$1.23M` |
| then | B, T, Qa, Qi, Sx, Sp, Oc, No, Dc (Dc covers 1e33) | `$4.50B` |
| ≥ 1e34 | scientific | `$1.0e34` |

Rounding promotes to the next tier: `999,999` shows `$1.00M`, never `$1000.0K`.

- Plaque is **display only**: value comes from a server-replicated attribute/value; client never computes balance.

---

## Part B: First 3 minutes (onboarding hook)

### B1. Goal and fantasy
Within **5 seconds** the player sees **their own cryptid already making money**. Every 15–40 seconds they hit a new goal, and at 3:00 they can see a bigger goal (defences) worth staying for. Fantasy: *"I'm the keeper of a growing occult menagerie."*

### B2. Starting state (new player only)

| Item | Value |
|---|---|
| Starting cash | **$25** |
| Free starter cryptid | 1× Common **Mothman Hatchling** (set by Grok Bot; Eudai delegated the choice), no mutation, no trait |
| Starter placement | Already on **Pad 1**, earning from second 0 |
| Starter income | **$2/s** |
| Pads unlocked | Pad 1 (occupied), **Pad 2 (unlocked, empty)** |
| Tool | Hunting tool **L1** (free, equipped from goal 3) |
| Income credit | Server adds income to cash **every 1.0 s** (auto-credit, no collect button during onboarding) [A] |

### B3. Onboarding goal chain (exact numbers, v2 order)

Times assume ~12 s per purchase (8 s walk + ~4 s reading and placing) and a 16 s hunt trip (8 s walk + 3 s hold + 1 s reveal + 4 s reading) **[A]**. Income maths is exact. Recomputed with `specs/tools/onboarding_sim.py` (step-by-step simulation, earning while walking).

| # | Goal banner text | Requirement | Cost | Reward / effect | Income after | Est. time done |
|---|---|---|---|---|---|---|
| 1 | "Your first familiar stirs. Watch it feed your coffers." | Auto-completes after 5 s | – | Plaque pulses | $2/s | 0:05 |
| 2 | "The Rift offers a creature. Claim it." | Buy guaranteed Rift Common #1: **Fresno Nightcrawler** | **$50** | Place on Pad 2, earns **$3/s** | **$5/s** | ~0:17 |
| 3 | "Take up your lantern. Something waits in the wild." | Catch the tutorial **Hodag** (wild Common, id `hodag`) with L1 tool (free, tutorial spawn 20 studs from lair exit, catch time 3 s) | – | Common reveal (0.6 s, design-bible rarity ladder), then the **rarity tease** (v2.1, D40): **3 tier-colour pips** (Common BoneDim `#A79F90`, Uncommon Moss `#5E7A4A`, Rare Silver `#8C9AA3`) + **"Three marks. Rarer things are watching."** in `Bone` `#E8E0CF`, Merriweather 18/16 px; fade in 0.2 s, hold 2.5 s, fade out 0.3 s; static (no pulse/glow/sound), never beside the result as a near-miss; built-in UI only (`art/vfx/vfx-audio-plan.md` §2.7). Hodag goes to inventory (pads full); sub-line "Carve a circle to bind it." | $5/s | **~0:33** |
| 4 | "Carve a third circle and bind your catch." | Unlock Pad 3 **and** the Hodag is on any pad | **$120** | Hodag earns **$5/s** | **$10/s** | **~0:45** |
| 5 | "Raise the Bone Altar." | **First upgrade:** Bone Altar I | **$300** | **+25% all pad income** | **$12.50/s** | ~1:12 |
| 6 | "Carve a fourth circle." | Unlock Pad 4 | **$400** | Empty pad | $12.50/s | ~1:44 |
| 7 | "Bind another from the Rift." | Buy guaranteed Rift Common #2: **Hidebehind** | **$75** | On Pad 4, earns **$4/s** base | **$17.50/s** | ~1:56 |
| 8 | "Others hunger for your menagerie. Light the Ward Candles." | **Visible next goal** (open loop): Ward Candles I. Shown with `$X / $1,200` progress but **not buyable in this build**; at ≥ $1,200 the button reads "The wax is not yet cast" (`BoneDim`, disabled). Must become buyable when the defences spec ships | **$1,200** | Unlocks defence (later spec) | – | shown ~1:56; bar full ~3:00 |

**Check of the maths (v2):**
- Goal 2: at 0:05 the player has $35; after a 12 s walk, $59. Buys at ~0:17 with **$9 left**.
- Goal 3 (hunt, 16 s): earns $80 while hunting → **$89** at ~0:33.
- Goal 4: needs $120. A 12 s walk back earns $60 → $149, buys at **~0:45 with $29 left**. The Hodag lands on Pad 3 by ~0:50, as the design bible asked.
- Goal 5: needs $300 at $10/s; ready ~1:12.
- Goal 6: needs $400 at $12.50/s; ready ~1:44.
- Goal 7: needs $75 and earns $150 during the walk, so ~1:56 with $75 left.
- Goal 8: the $1,200 bar fills ~3:00.
- Gaps between goals are 12–32 s (target 15–40 s; the 12 s gap is the satisfying catch → bind pair).
- Old v1.2 end state reached the same **$17.50/s**, but at ~2:37; v2 reaches it at ~1:56.

**Why the new order works:** the Hodag (best Common, $5/s) earns from 0:45 instead of 2:37, so Altar I and Pad 4 come sooner. The hunt also happens while the player is saving for Pad 3, so no time is wasted. The Hidebehind waits on the belt (it never despawns in onboarding) until a pad is free.

**Guarantees during onboarding (server-enforced):**
- Conveyor's first two spawns for a new player are the fixed Rift Commons above, priced $50 and $75. Each stays on the belt until bought (no despawn during onboarding). The Hidebehind waits on the belt from ~0:17 until step 7; its belt card shows "Needs a free circle" until Pad 4 exists.
- Tutorial wild spawn is guaranteed, cannot be stolen, and respawns if the player leaves it.
- **No stealing from or by** this player until onboarding step 8 is shown, or 5:00 of playtime, whichever first [A].

### B4. Early cost tables (seed values for the pacing spec)

| Pad | Unlock cost |
|---|---|
| 1 | Owned (starter) |
| 2 | Free |
| 3 | $120 |
| 4 | $400 |
| 5 | $1,200 [A] |
| 6 | $3,000 [A] |

| Bone Altar level | Cost | Total income multiplier |
|---|---|---|
| 0 | – | ×1.00 |
| I | $300 | ×1.25 |
| II | $1,500 [A] | ×1.50 |
| III | $8,000 | ×1.688 |
| IV | $40,000 | ×1.828 |
| V | $200,000 | ×1.934 |
| VI | $1,000,000 | ×2.013 |
| VII | $5,000,000 | ×2.072 |
| VIII | $25,000,000 | ×2.117 |
| IX | $125,000,000 | ×2.150 |
| X | $625,000,000 | ×2.175 |

Levels I–II are **additive**: +0.25 each (+0.30 with skill l3). **v2.1 (spec 11 §2.2):** each level L ≥ 3 adds `0.25 × 0.75^(L−2)` (×1.2 with l3), a soft cap near ×2.25 (×2.7 with l3). With l3: ×1.30 / ×1.60 / ×1.825 / ×1.994 / ×2.120 / ×2.215 / ×2.286 / ×2.340 / ×2.380 / ×2.410. **After r rebirths every altar cost is × 1.5^r.** Applied to the sum of pad base incomes.

### B5. UI text and placement
- **Goal banner:** top-centre under cash plaque, `Ash` panel, `GrenzeGotisch` headline + `Merriweather` sub-line showing progress, e.g. `$38 / $50`.
- **World arrow:** a thin `Gold` beam (Beam, 0.3 width) from player to the current goal target. Hidden after step 8.
- **Pad billboard:** above each occupied pad: cryptid name (`Bone`) + income **after** the Bone Altar multiplier (`GoldBright`), so billboards add up to the plaque.
- **Locked pad:** `BoneDim` sigil + `"$120 · Carve"`; turns `Blood`-bordered when affordable.
- **Skip:** small `BoneDim` text button "Skip the rite" in banner corner → jumps to step 8, keeps all grants.

### B6. Data to save (per player)

| Key | Type | Notes |
|---|---|---|
| `cash` | number | Server only |
| `totalEarned` | number | Lifetime **income only** (excludes the $25 starting grant), for analytics/rebirth later |
| `padsUnlocked` | int (1–N) | Starts 2 |
| `pads` | map padIndex → cryptidInstanceId \| nil | |
| `cryptids` | map instanceId → {speciesId, mutation, traits, acquiredAt, source} | `source` ∈ starter/rift/wild |
| `upgrades.boneAltar` | int | Starts 0 |
| `onboarding.step` | int 0–8 | 8 = done |
| `onboarding.starterGranted` | bool | Grant only once, ever |
| `onboarding.skipped` | bool | Analytics |
| `firstJoinUnix` | int | |
| `settings.reducedMotion` | bool | |
| `dataVersion` | int | Starts 1, for migrations |

Save: on purchase/unlock (throttled), every 60 s autosave, and on leave. Session locking is the Architect's call.

### B7. Server vs client
- **Server owns:** cash, income tick, all purchases/unlocks, pad assignment, onboarding step advance, starter grant, wild-catch validation (distance ≤ 12 studs, catch time ≥ 3 s), purchase debounce (≥ 0.25 s between purchase requests per player).
- **Client owns:** display only: plaque, count-up, banner, arrow, tweens, reduced-motion.
- Client sends **intents only** (`RequestBuyRift(slotId)`, `RequestUnlockPad(index)`, `RequestUpgrade("boneAltar")`, `RequestPlace(instanceId, pad)`); server validates cost and state.

### B8. Monetisation hooks
- **None in this feature.** Rule (v2 wording, same intent): **no purchase prompt, shop pop-up, paid-item card or Relics pip before onboarding step 8 is shown AND 5:00 of playtime have passed** (both). Spec 09 v2 uses the same rule.
- **Nightly Offering (spec 06 v2):** the Offering HUD button appears once step 8 is shown **and** 3:00 of playtime have passed, with a gold pip, never a pop-up. Day 1 (of 7) can be claimed in the first session.
- Policy gate: not required (no paid random items here). The onboarding conveyor's first spawns are fixed and deterministic. After onboarding: **Belt independence (audit fix):** the belt's spawn timer (1 every 10 s) and its rolls **never depend on purchases**: no refill-on-buy, no faster respawn after buying, no capacity block that a purchase frees. Buying only takes the shown cryptid (spec 02 §3). The belt's odds button says **"Details"** (a word, never a bare (i)).

### B9. Edge cases
1. **Leaves mid-onboarding:** resumes at saved `onboarding.step`; cash and pads persist.
2. **Data fails to load:** do **not** start with defaults (would overwrite save). Retry 3× with backoff, then kick with "The ledger would not open. Rejoin." If the session is locked by another server, kick with "The ledger is open elsewhere. Rejoin." Studio without API access may use a never-written ephemeral profile.
3. **Returning player (step 8 or `starterGranted`):** no starter re-grant, no onboarding.
4. **Player sells/moves starter during onboarding:** selling disabled until step 8; moving between pads allowed.
5. **Can't afford:** button shows `BoneDim` + "Need $X more"; server rejects silently-safe (no cash change).
6. **Pad full on catch:** cryptid goes to inventory; banner says "Carve a circle to bind it." (This is the normal path at step 3.)
7. **Skip pressed:** grants every unclaimed guaranteed cryptid to inventory (Fresno Nightcrawler, Hidebehind, **and the Hodag**). Grants no cash, pads or altar levels. Sets step 8.
8. **Spam clicks:** debounce prevents double charge.
9. **Very large cash:** formatter handles up to 1e33 (`Dc`); beyond shows scientific `1.0e34`.
10. **Rejoin on new server mid-step:** guaranteed conveyor items re-spawn for that player.

---

## Part C: Acceptance tests (QA)

| # | Test | Pass if |
|---|---|---|
| 1 | Fresh account joins | Cash $25, starter on Pad 1, plaque shows `+$2/s` within 5 s of spawn |
| 2 | Idle 10 s after join | Cash = 25 + 2 × 10 = **$45** (±$2 for tick timing) |
| 3 | Buy Rift #1 | Cost $50 deducted once; income `+$5/s` |
| 4 | Catch the Hodag (step 3), then unlock Pad 3 and place it | Hodag goes to inventory at catch; Pad 3 costs $120; income `+$10/s` after placing; Pad 4 still locked at $400 |
| 5 | Bone Altar I | Costs $300; income `+$12.50/s` |
| 6 | Unlock Pad 4 | Costs $400; income unchanged `+$12.50/s` |
| 7 | Buy Rift #2 (Hidebehind) onto Pad 4 | Costs $75; income `+$17.50/s` |
| 8 | Step 8 shown | Ward Candles goal shows `$1,200`; arrow hidden after |
| 9 | Full run, no skip, normal play | Hodag caught by **≤ 0:50** and on Pad 3 by **≤ 1:00**; steps 1–7 done in **≤ 2:45**; target ~1:56 |
| 10 | Leave at step 4, rejoin | Resumes step 4 with same cash/pads |
| 11 | Second join after completion | No second starter; no onboarding |
| 12 | Client exploit: fire buy remote with $0 | Rejected; cash unchanged |
| 13 | Double-click buy | Charged once |
| 14 | No purchase prompts | Zero MarketplaceService prompts before step 8 / 5:00 |
| 15 | Palette audit | Every UI colour matches a token in A2; no purple; Rift green ≤ 2% of screen (style guide D35); no Neon except the Mothman Hatchling and Dover Demon eyes |
| 16 | Fonts | Numbers use Oswald; no text < 14 px on a phone emulator |
| 17 | Reduced Motion on | No slide/scale/float tweens; fades ≤ 0.15 s |
| 18 | Number format | 9,999 → `$9,999`; 12,345 → `$12.3K`; 1,234,567 → `$1.23M` |
| 19 | Skip the rite | Jumps to step 8; unclaimed Fresno Nightcrawler, Hidebehind and Hodag appear in inventory; cash unchanged |
| 20 | Stealing protection | Player can't be stolen from before step 8 / 5:00 |
| 21 | Nightly Offering day 1 (spec 06 v2) | Offering button + gold pip appear at step 8 shown + 3:00 playtime; no pop-up; claiming gives day 1 of 7 in session 1 |
| 22 | Every step affordable | Playing with no skips, no step waits on cash for more than 35 s |

---

## Open questions for Eudai (not blockers)
- Wild tutorial catch: **Hodag** (Common, $5/s). Like the Rift pair, it needs adding to the grimoire.
- Post-onboarding: income keeps auto-crediting; Bone Altar II ($1,500) buyable, III+ rejected until the pacing spec.
- Species decided: starter is Mothman Hatchling ($2/s); Rift Commons are Fresno Nightcrawler ($50, $3/s) and Hidebehind ($75, $4/s). Both need confirming as grimoire entries when the list is written.
- Auto-credit vs "walk to collect" after onboarding: this spec uses auto-credit; collection mechanics can come in the pacing spec.
