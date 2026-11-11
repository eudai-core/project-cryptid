# Spec 03: Town Centre (Hollowmere) + Rotating Limited Shop

**Owner:** Cryptid Growth Strategist · **Builder:** Cryptid Systems Architect · **Status:** Draft v2.2 (2026-11-04: v2.2 audit fix, Pedlar policy reason + "Details" button. v2.1: Atmosphere Color #282A30; lair fog wisps with clear zones; Rift glow non-Neon (D38); Tarot Table earn-only (decision B). v2.0 2026-11-04: Tarot Table = free + paid readings (superseded). v1.2: fog numbers added to match the art style guide's lighting floor)
**Builds on:** Spec 01 v1.2, Spec 02. **Paid products:** none in this build. **Paid randomness:** none in this build. The Tarot Table (January) is **earn-only**; the only paid random item in the game is Server Luck (January, PolicyService-gated, spec 10 v2 §5). Server Luck and the Robux prices are still open, pending Eudai (director ruling 5).

> **Director ruling, 11 Nov 2026 (world look).** Where §3 conflicts with spec 15, spec 15 wins: a purple night, coloured flames, and Neon on flames, portals, runes, signs, and eyes, within the town budget of 364 parts and 24 lights (no map expansion). "No bright purple anywhere" and "Neon only for the two cryptid-eye exceptions" are superseded for those surfaces. The Great Rift pit and the Pedlar lantern stay RiftDim, not Neon. The #14 names are canonical for the mythic buildings (Runeheart Apothecary, The Howling Horn, Veil & Fate, Dusk & Dial); the town name stays Hollowmere. Atmosphere colour in the v2.1 note (`#282A30`) does not override main: main keeps Ash `#1A1719`, OutdoorAmbient `(95, 88, 82)`, and ClockTime 1 until visual pass #17 tunes them (ruling 8).

> **v2.2 change (Wed 4 Nov 2026), compliance audit (`compliance-audit-cash-random.md` §4; Grok Bot approved, 4 Nov; cash = paid currency):** §10 Pedlar policy reason rewritten (no "cash, not Robux" argument); the odds link is a **"Details"** button; Lanternwright stays shuttered (tools L2–L5 must be deterministic, never odds).

> **v2.1 change (Wed 4 Nov 2026), Grok Bot rulings + Eudai's decision B:**
> - **Atmosphere Color `#1A1719` → `#282A30`** (cool ash-grey, so distance fades to grey, not black; Art Director's atmosphere pass AP-10 / C4, `art/vfx/atmosphere-pass.md`). Legacy FogColor follows. Density 0.18 / Haze 0.3 / Decay `#0B0A0C` unchanged, so the readability floor is untouched.
> - **Ambient fog wisps are allowed on lairs** at a low rate, with **clear zones** around pads and the tutorial spawn, and **OFF on Low graphics quality** (§3 Fog row).
> - **No Neon Rift glow** (D38, spec 01 v2.1 A4): the Great Rift pit and the Pedlar's lantern are RiftDim `#4F6B34` surfaces with PointLight + particle glow and tiny `#7FA34A` accents. Neon only for the Mothman Hatchling and Dover Demon eyes (style guide D10, D13).
> - **Tarot Table is earn-only** (decision B): paid readings removed; Bound Rites are fixed bundles (spec 09 v3 §9.5).
> - **From spec 11 v1 §11 (approved by Grok Bot as the design base, 4 Nov):** the **Ledger of Tithes** slab (spec 07 §3, beside the Weeping Well) gets a second face, **"The Hunt Ledger · resets Monday 00:00 UTC"** (weekly Hunt board, **Update 1**). Added to §2 below.

> **[A]** = design assumption to tune after playtest. Eudai's playtest feedback: players expected **a town**. This is the shared hub every lair road leads to.

---

## 1. Goal and fantasy
A fog-drowned market town, **Hollowmere**, sits in the middle of the lairs. Lamps gutter, crimson banners hang off crooked stalls, and a strange pedlar sells creatures that are gone in five minutes. *"Town is where I go to spend, show off, and see what's new."*

## 2. Layout

- **Centre:** origin (0, 0, 0), the **Weeping Well** (spec 02 world map).
- **Town radius:** 120 studs. Cobbled, slightly sunken (y = −1) with a low ruined wall at r = 120 broken by the 8 road openings.
- **8 roads** enter at the plot angles `θ = (i − 1) × 45°` (spec 02), each 16 wide.
- **8 districts** sit **between** roads at `θ = 22.5° + (n − 1) × 45°`, building centre at **r = 75**.

```
                     Road P1 (0°)
        NW Skill Shrine   |   NE Pale Pedlar (LIMITED SHOP)
    Road P8 ─────────── WEEPING WELL ─────────── Road P2
        W Grimoire Lectern  (0,0,0)   E Lanternwright
    Road P7               |                Road P3
        SW Great Rift (reserved)   SE Tarot Table (reserved)
                Road P6   |   Road P4
          S-SW Bone Broker  Road P5  S-SE Expedition Board
```

The diagram is a rough sketch. **The angles in the table are authoritative.**

| # | District | Angle θ | Status in this build | What it is |
|---|---|---|---|---|
| 1 | **The Pale Pedlar** | 22.5° | **LIVE** | Rotating limited shop (§4) |
| 2 | **The Lanternwright** | 67.5° | Shuttered | Hunting tools L2–L5 (later spec; **stays shuttered**; tools must be deterministic, never rarity/spawn/variant odds, audit row 10) |
| 3 | **The Tarot Table** | 112.5° | Reserved spot, roped off | **Earn-only readings** (January; spec 09 v3 §5, reel in spec 10 v2; odds shown). Paid side = fixed **Bound Rites** (exact contents shown, no odds) |
| 4 | **Expedition Board** | 157.5° | Shuttered | Timed missions (later spec) |
| 5 | **The Bone Broker** | 202.5° | Shuttered | Sell cryptids (later spec) |
| 6 | **The Great Rift** | 247.5° | Reserved spot, fenced pit: **RiftDim `#4F6B34`** edge (non-Neon) with a Rift-tinted PointLight + particle glow, tiny `#7FA34A` accents (D38) | Shared Rift conveyor (later spec). The personal Rift Fissure stays in each lair (spec 02) |
| 7 | **Grimoire Lectern** | 292.5° | Shuttered | 34-cryptid journal (later spec) |
| 8 | **Skill Shrine** | 337.5° | **LIVE** | Opens the skill tree UI (spec 04) |

Position of district *n*: `x = 75 × sin θ`, `z = 75 × cos θ`, front facing the Well.

- **Ledger of Tithes** (spec 07 §3): stone slab beside the Weeping Well facing road P1. **Update 1 (spec 11 §5.2):** a second face, **"The Hunt Ledger · resets Monday 00:00 UTC"** (top 100 weekly Hunt Marks, cosmetic rewards only). Bone text on Soot, Gold rim; no purple.
- **Shuttered** = stall built and dressed, boarded with a crimson cloth, sign reads `"Shuttered until the next moon"` (`BoneDim`). No prompt.
- **Reserved** = empty marked footprint, **24 × 24 studs**, named `Reserved_TarotTable` / `Reserved_GreatRift`, so later builds drop in without moving anything.
- **Weeping Well:** 10-stud stone well, dripping dark water (particles), a ring of 8 candles. Spawn point for players teleported from a cleared plot (spec 02 edge case 5) is the road opening, not the Well.

## 3. Look (occult horror, not cartoon)

| Element | Choice |
|---|---|
| Ground | Cobblestone, colour near `Soot` `#2A2427` |
| Buildings | WoodPlanks (dark) + Slate roofs; crooked, leaning 2–4° |
| Trim | `Gold` `#9C7A3C` on signs only |
| Cloth/banners | `Blood` `#7A0F12` |
| Lamps | Iron posts every 18 studs on the inner ring, PointLight `#FFB36B`, range 14, brightness 1.0; 1 in 6 flickers (random 0.2–0.6 s dips) |
| Fog | `Atmosphere` Density **0.18**, Haze **0.3**, Offset **0**, Color **`#282A30`** (v2.1), Decay `#0B0A0C`, Glare **0**. **Legacy fog (v1.2):** `Lighting.FogStart` **250**, `FogEnd` **1,100**, `FogColor` **`#282A30`**. These are fallback values in case Atmosphere is ever removed. Assumption: Roblox ignores legacy fog while an Atmosphere exists, so check it in Studio. Distances: the Town edge is 120 studs out, and the plots run from r 200 to r 320, so every plot is 80–200 studs from the Town edge. From the Town, every plot sits inside FogStart and is fully clear. The opposite plot is about 640 studs from your own, so it fades slightly but stays visible, because it's well short of FogEnd. **Readability floor:** follow `art/style-guide.md` §4 (Ambient ≥ (60,55,52), OutdoorAmbient ≥ (95,88,82), Brightness 1.5, Exposure +0.3). Never set Haze > 0.3 or Density > 0.18 over plots or the Town. **Mood** comes from low **camera-local fog wisps** (the Art Director's `AmbienceRig`, `art/vfx/atmosphere-pass.md` §3), never from a global Density/Haze change. **v2.1 wisp rules:** Town 1.5/s, Road 1.5/s, Wilds 2.0/s, **Lairs 1.0/s (low rate, ≤ 8 alive)** [A]; every wisp stays ≥ 86% transparent, size ≤ 10 studs, lifetime ≤ 8 s, colour Ash/Soot tones lit by the scene. **Clear zones (no wisp spawns or drifts inside) [A]:** **8 studs around each pad centre** (pad ≤ 10 studs wide, so 3 studs of margin; the 12 pads on the radius-28 ring sit ~14.5 studs apart, so the zones merge into one clear band from r 20 to r 36), **12 studs around the tutorial wild spawn** (the Hodag, plot-local (0, 0, −80), during goal 3; AP-11) and **8 studs around the player spawn point** (0, 0, +48). Keeps every cryptid, pad and the Hodag above the readability floor (no wisp ever overlaps a cryptid). **Low graphics quality: wisps OFF** (Auto mode uses `settings.effectsQuality`, vfx-audio-plan §1) |
| Sky | Near-black, faint moon; no stars brighter than `BoneDim` |
| Rift green | Only at the Great Rift pit and the Pedlar's "new stock" lantern, as **RiftDim `#4F6B34`** surfaces + PointLight/particle glow + tiny `#7FA34A` accents; **no Neon** (D38). Neon anywhere only for the Mothman Hatchling / Dover Demon eyes (D10, D13) |
| Ambient sound | Wind, distant bell every 60 s, crows [asset IDs TBD] |

No bright purple anywhere. No cartoon shapes or bubbly signs.

## 4. The Pale Pedlar (rotating limited shop)

### 4.1 How it works
- **4 stock slots.** Each slot holds 1 cryptid offer for one **rotation**.
- **Rotation length: 5 minutes (300 s)**, aligned to UTC so **every server shows the same stock**:
  - `rotationId = floor(os.time() / 300)`
  - Stock is generated with `Random.new(rotationId + SALT)` (SALT = a fixed server-only constant).
- **Per-player limit:** each player may buy **each slot once per rotation**.
- **Currency:** in-game cash only. **No Robux.**
- Bought cryptids go to **inventory** (or the first empty unlocked pad if the player turns on "Bind at once", default off).
- Opens after onboarding step 8 (spec 01). Before that, the stall shows "The Pedlar ignores the unmarked." The Skill Shrine is gated the same way (spec 04 §2): "The shrine is silent to the unmarked."
- Server re-checks on each buy that the player is within **12 studs** of the stall.

### 4.2 Rarity odds per slot (each column sums to 100%)

| Rarity | Slot 1 "Cheap Cage" | Slot 2 "Odd Cage" | Slot 3 "Rare Cage" | Slot 4 "Pedlar's Curio" |
|---|---|---|---|---|
| Common | **100%** | 0% | 0% | 0% |
| Uncommon | 0% | **75%** | 0% | 0% |
| Rare | 0% | **25%** | **80%** | 0% |
| Epic | 0% | 0% | **20%** | **85%** |
| Legendary | 0% | 0% | 0% | **14%** |
| Mythic | 0% | 0% | 0% | **1%** |
| **Total** | 100% | 100% | 100% | 100% |

After rarity, the species is picked **uniformly** from that rarity's species pool. Mutation chance in the shop: **0%** (mutations come from weather, a later spec).

### 4.3 Base incomes and prices [A: seed values, the pacing spec will retune]

| Rarity | Base income | Payback time | **Shop price** |
|---|---|---|---|
| Common | $6/s | 30 s | **$180** |
| Uncommon | $15/s | 60 s | **$900** |
| Rare | $45/s | 150 s | **$6,750** |
| Epic | $160/s | 400 s | **$64,000** |
| Legendary | $600/s | 1,200 s | **$720,000** |
| Mythic | $2,500/s | 3,600 s | **$9,000,000** |

`price = that species' base income × the rarity's payback time`. Named species use their own income (Mothman Hatchling $2/s → **$60**, Fresno Nightcrawler $3/s → **$90**, Hidebehind $4/s → **$120**, Hodag $5/s → **$150**). Placeholder species use the rarity base income above. Income uses spec 01 multipliers (Bone Altar, later skills).

### 4.4 Species pools
The 34-cryptid grimoire list doesn't exist as a file yet. Until it does:
- Pools are read from a single config table `ShopPools[rarity] = { speciesId, ... }`.
- Seed with spec 01 species where they fit (Common: `fresno_nightcrawler`, `hidebehind`, `hodag`, `mothman_hatchling`) and **placeholder ids** for higher rarities (e.g. `uncommon_01`) clearly named as placeholders.
- A rarity with an **empty pool** falls back to the next lower rarity that has species (logged as a warning).

## 5. UI

**Opening:** ProximityPrompt at the stall, "Browse the Pedlar's cages" (range 10 studs).

**Shop panel** (spec 01 theme: `Ash` panel, `Gold` stroke, 4 px corners), 720 × 420 desktop / full-width mobile:
- Header: `The Pale Pedlar` (`GrenzeGotisch` 32, `Bone`).
- Sub-header: **`Restocks in 4:12`** (`Oswald`, `GoldBright`), counting down to the next `rotationId`.
- 4 cards in a row (2×2 on mobile). Each card shows: slot name, cryptid name and art, **rarity word + rarity colour** (spec 01 rarity tokens), `+$45/s`, price, and the button **`Buy`** (`Blood`) or **`Sold to you`** (`BoneDim`, disabled) or **`Need $X more`** (`BoneDim`, disabled).
- A **"Details"** button (the word, never a bare (i); `BoneDim`, underlined) opens the §4.2 table for all 4 slots, visible before any purchase (v2.2).
- When stock changes while the panel is open: cards fade out 0.15 s and fade in with the new stock; the Pedlar's lantern above the stall glows for 10 s: its PointLight (Rift-tinted) and particle glow brighten over the RiftDim cage; no Neon (D38).

**Honesty rules (no dark patterns):**
- The countdown is the real time to restock. No fake "only 1 left" or "others are buying".
- Price shown is the price charged.
- No pop-up that drags the player to the shop.

## 6. Data to save

| Key | Type | Notes |
|---|---|---|
| `shop.lastRotationId` | int | Rotation of the last purchase |
| `shop.boughtSlots` | array of 4 bools | Reset when `rotationId` ≠ `lastRotationId` |
| `settings.bindAtOnce` | bool | Default false |
| `cryptids[...]` | existing | New entries get `source = "pedlar"` |

Bump `dataVersion` by 1; migration adds the `shop` table and `settings.bindAtOnce = false`. Stock itself is **never saved** (always regenerated from `rotationId`).

## 7. Server vs client
- **Server owns:** `rotationId`, stock generation, odds, prices, the per-player limit, purchases, and the inventory grant.
- **Client owns:** the countdown display (from a replicated `NextRestockUnix`), cards and tweens.
- Remote: `RequestPedlarBuy(rotationId, slot)`. Server rejects if `rotationId` isn't current ("The Pedlar has moved on."), slot already bought, not enough cash, or onboarding isn't done.
- The client never generates stock (so the SALT stays secret and stock can't be predicted ahead).

## 8. Monetisation hooks
None in this build. Future options (need Eudai's approval and Bot 3 to create): a **cosmetic** Pedlar stall skin. **Never** sell rerolls or restock skips, for Robux **or cash** (v2.2, §10).

## 9. Edge cases
1. **Buy at the exact restock second:** server uses its own `os.time()`; if the client's `rotationId` is stale, reject with "The Pedlar has moved on." and refresh cards.
2. **Player rejoins in the same rotation:** `boughtSlots` still blocks re-buying.
3. **Inventory full:** no inventory cap exists yet; if one is added later, reject before charging.
4. **Server clocks differ slightly:** stock may switch a second apart across servers; acceptable.
5. **Empty species pool:** falls back a rarity (§4.4), never errors.
6. **Mythic roll:** shows for the whole rotation; announcing it server-wide is left for a later spec.
7. **Shuttered stalls:** no prompts, no remotes; can't be used by exploit.

## 10. Policy note
**v2.2:** cash is paid currency (it's sold in Robux bundles). The Pedlar isn't treated as a paid random item because stock comes from a **global UTC seed** (`Random.new(rotationId + SALT)`, the same in every server) and **restocks on a fixed 5-min timer** that buying never changes: you see the exact cryptid and price before paying, and buying never reveals, rerolls or brings forward the next stock. **No cash (or Robux) reroll, restock skip or mystery cage, ever.** Risk **Medium [A]**: Roblox staff said a preview-before-buy system is still a paid random item when "the only way to find out (or change) what comes next is to buy" ([DevForum #29](https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622/29)); our timed restock is the reason we read the Pedlar as outside that, and Roblox hasn't ruled on timed restocks. **The Tarot Table (reserved spot, January) is earn-only** (Eudai's decision B, 4 Nov, superseding the earlier paid-readings approval): readings come only from free tokens and earned decks, and the paid side is fixed **Bound Rites** with exact contents shown before payment (spec 09 v3 §5, §9.5; spec 10 v2). No reading is ever sold, so the Tarot Table needs no policy gate. The game's only paid random item is **Server Luck** (January, PolicyService-gated, spec 09 v3 §6). **Pedlar rule that keeps it safe:** Pedlar stock must never be re-rollable or restockable for cash or Robux (cash is sold for Robux, so a paid re-roll would make it a paid random item). Server Luck (spec 10) **does not** change Pedlar odds, because the Pedlar stock is one global UTC seed.

## 11. Acceptance tests (QA)

| # | Test | Pass if |
|---|---|---|
| 1 | Town layout | Well at (0,0,0); 8 road openings at the plot angles; 8 districts at r = 75 ± 1, θ = 22.5° + 45°·(n−1) |
| 2 | Live vs shuttered | Only the Pale Pedlar and Skill Shrine show prompts; others show the shuttered sign or reserved footprint |
| 3 | Reserved spots | `Reserved_TarotTable` and `Reserved_GreatRift` exist, 24×24 |
| 4 | Same stock everywhere | Two servers at the same UTC time show identical stock |
| 5 | Restock timing | Stock changes when `floor(os.time()/300)` changes; countdown hits 0:00 at that moment (±1 s) |
| 6 | Odds | Simulate 100,000 rotations server-side: each slot's rarity rates within ±0.5 percentage points of §4.2 (Mythic within ±0.1) |
| 7 | Prices | Every offer's price = that species' income × its rarity's payback (§4.3); Mothman Hatchling costs $60 |
| 8 | Buy once | Second buy of the same slot in the same rotation is refused; cash unchanged |
| 9 | Stale rotation | Buy with the previous `rotationId` is refused with "The Pedlar has moved on." |
| 10 | Onboarding gate | Before step 8, the Pedlar can't be used |
| 11 | No Robux | No MarketplaceService calls anywhere in the town |
| 12 | Details button | The button reads "Details" (not a bare icon) and shows all four slot tables, each adding to 100%; buying all 4 slots doesn't change stock until `floor(os.time()/300)` changes |
| 13 | Look | No purple; Rift only at the Great Rift pit and Pedlar lantern as RiftDim + light/particles, **no Neon** except the two cryptid-eye exceptions; Atmosphere Color `#282A30`; fog on |
| 15 | Lair wisps | Lairs ~1.0 wisps/s; none inside 8 studs of any pad centre or the spawn point, or 12 studs of the Hodag tutorial spawn; **none on Low quality** |
| 14 | Skill Shrine | Prompt opens the spec 04 skill tree UI |
