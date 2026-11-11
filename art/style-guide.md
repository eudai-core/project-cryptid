# Project Cryptid: Living Art Style Guide

**Version:** v0.2 (2026-11-03, Master Controller decisions folded in) · **Owner:** Art · **Reads from:** Specs 01–04
**Tags:** `[S01]`–`[S04]` = rule taken from that spec. **`[FIXED]`** = fixed art direction from the project brief. **`[PROPOSED]`** = **Proposed default (needs Eudai sign-off)**: the specs say nothing, so this is my suggestion. **`[DECIDED]`** = settled, see the decision log.

> **Superseded (director ruling, 11 Nov 2026).** This whole file is style guide v0.2, kept on purpose and superseded by [`style-guide-v0.8.md`](style-guide-v0.8.md). Where its world-look rules conflict with spec 15, spec 15 wins: a purple night, coloured flames, and Neon on flames, portals, runes, signs, and eyes, within the budgets in [`docs/VISUAL_REFERENCES.md`](../docs/VISUAL_REFERENCES.md). Spec 01 A2 palette tokens still apply to UI. The Neon Rift conveyor trim in §2 of this file stays superseded as well: D38 and D41 removed it, and main uses RiftDim on the fissure. Spec 15 does not put that Neon trim back.

## Decision log

| # | Date | By | Decision | Where |
|---|---|---|---|---|
| D1 | 2026-11-03 | Master Controller | **Brighter Ambient minimums approved.** Readability beats spec 01's "Ambient near-black" | §4 |
| D2 | 2026-11-03 | Master Controller | **Light every third wall candle** (candle models every 20 studs stay) | §4, §6 |
| D3 | 2026-11-03 | Master Controller | **Onboarding seal glows without Neon** | §4 |
| D4 | 2026-11-03 | Master Controller | **Mobile budgets approved** | §6 |
| D5 | 2026-11-03 | Master Controller | **Generated meshes allowed only through the guarded official-MCP wrapper** | §2, §7 |
| D6 | 2026-11-03 | Master Controller | **Creator Store assets allowed only if free to use, every script stripped and checked, and logged in `asset-list.md`** | §7 |
| D7 | 2026-11-03 | Master Controller | **Bone white = `#E8E0CF`** | §1 |
| D8 | 2026-11-03 | Master Controller | **Highlight 31-limit is UNVERIFIED**; check in Studio before relying on it | §6 |
| D9 | 2026-11-03 | Master Controller / Growth Strategist | **Fog set in spec 03 v1.2 (line 59):** FogStart 250, FogEnd 1100, FogColor #1A1719 (legacy fallback; Atmosphere governs, verify in Studio). Atmosphere Density 0.18 / Haze 0.3 max over gameplay areas | §4 |
| D10 | 2026-11-03 | Master Controller | **Neon exception: cryptid eyes, Mothman Hatchling only, 2 parts (`Eye_R`, `Eye_L`), Blood `#7A0F12`.** No other cryptid gets Neon without a new decision | §2, §6 |
| D11 | 2026-11-04 | Master Controller | **Rare silver `#8C9AA3` approved** as a rarity-trim exception outside the fixed palette (rarity trims/labels only) | §1 |
| D13 | 2026-11-04 | Master Controller | **Neon exception extended: Dover Demon eyes, 2 parts (`Eye_R`, `Eye_L`), GoldBright `#C9A55A`.** Those 2 parts only; placeholders stay Glass. No other cryptid gets Neon without a new decision | §2, §6 |
| D12 | 2026-11-04 | Master Controller | **Game icon + thumbnails use real Studio captures.** Box renders are a fallback only if Studio imports slip past **Mon 9 Nov** | §9, store art brief |

**One-line direction:** grim, weathered, occult. A **candle-lit ritual ledger** `[S01 A1]`, a **fog-drowned market town** `[S03 §1]`. Dark and heavy, but **always readable**.

**Never:** bright purple, saturated blue, pastel, cartoony, toy-like, glossy, rounded "bubble" shapes `[FIXED] [S01 A2] [S03 §3]`. **World look superseded where it conflicts** with spec 15 (director ruling 1, 11 Nov 2026): purple night, coloured flames, and Neon on flames, portals, runes, signs, and eyes. The A2 ban still applies to UI.

---

## 1. Palette swatches

UI may use **only** these tokens `[S01 A2]`. World parts should stay inside them too `[PROPOSED]`.

| Token | Hex | `Color3.fromRGB` | Role | Source |
|---|---|---|---|---|
| **Void** (near-black) | `#0B0A0C` | `(11, 10, 12)` | Backgrounds, overlays (85% opacity), skill-tree backdrop | `[FIXED] [S01]` |
| **Ash** | `#1A1719` | `(26, 23, 25)` | Panel fill, fog colour | `[S01, derived]` |
| **Soot** | `#2A2427` | `(42, 36, 39)` | Raised cards, inputs, cobbles | `[S01, derived] [S03]` |
| **Blood** (dried-blood crimson) | `#7A0F12` | `(122, 15, 18)` | Primary buttons, "Buy", banners, cloth, owned nodes | `[FIXED] [S01]` |
| **BloodHover** | `#94171B` | `(148, 23, 27)` | Hover/press, vein glow | `[S01, derived]` |
| **Gold** (tarnished) | `#9C7A3C` | `(156, 122, 60)` | Currency, borders, sign trim, pad rings | `[FIXED] [S01]` |
| **GoldBright** | `#C9A55A` | `(201, 165, 90)` | Currency numbers, highlights, Legendary | `[S01, derived]` |
| **Bone** (bone white) | `#E8E0CF` | `(232, 224, 207)` | Main text, bones, parchment | `[S01]` **`[DECIDED D7]`** |
| **BoneDim** | `#A79F90` | `(167, 159, 144)` | Secondary/disabled text, Common | `[S01, derived]` |
| **Rift** (sickly green, rare) | `#7FA34A` | `(127, 163, 74)` | **Rare only**: Rift glow, mutations, "new" pips, Mythic | `[S01]` |

**Extra colours already in specs (not UI tokens):**
- Candle / lamp light `#FFB36B` → `(255, 179, 107)` `[S01 A4] [S03 §3]`.
- Rarity: Uncommon **Moss** `#5E7A4A` `(94, 122, 74)`, Rare **Tarnished silver** `#8C9AA3` `(140, 154, 163)` `[S01 A2, assumption]`. Epic = Blood, Legendary = GoldBright, Mythic = Rift + slow pulse, Common = BoneDim.

**Usage ratios (per screen or per view)** `[PROPOSED]`, except the Rift cap from `[S01]`:
- **Dominant ~65%**: Void / Ash / Soot (stone, night, panels).
- **Secondary ~20%**: Bone / BoneDim (bone, text, chalk) and weathered wood.
- **Action ~10%**: Blood (cloth, buttons, owned states).
- **Accent ~5%**: Gold / GoldBright (trim, money, borders).
- **Rare ≤5% of any UI screen** `[S01]`; **≤2% of a 3D view** `[PROPOSED]`: Rift green.

**Contrast rules** `[S01 A2]`: body text is always **Bone or BoneDim**. **Never Blood text on Void.** Colour is never the only signal (pair it with an icon or word). Parchment tooltips flip this: **Void text on Bone** `[S04 §7]`.

---

## 2. Materials

Build with **Parts + built-in `Enum.Material`** first. Use meshes only when Parts can't make the silhouette inside budget `[FIXED]`.
- **Generated meshes:** allowed **only through the guarded official-MCP wrapper** `[DECIDED D5]`. No meshes from other tools or sites.

| Surface | `Enum.Material` | Colour | Source |
|---|---|---|---|
| Lair floor, walls | **Slate** / **Basalt** | near Void/Soot | `[S01 A4] [S02 §7]` |
| Lair wall (14 studs, crenellated) | **Basalt** | Soot | `[S02 §2]` |
| Pad ring / centre | **CorrodedMetal** ring tinted Gold / **Slate** centre | Gold / Soot | `[S01 A4]` |
| Rift conveyor belt | **Basalt** belt + thin **Neon** trim | Rift | `[S01 A4] [S02 §3]` |
| Town ground, roads | **Cobblestone** | near Soot `#2A2427` | `[S03 §3] [S02 §2]` |
| Town buildings | **WoodPlanks** (dark) + **Slate** roofs | dark wood / Soot | `[S03 §3]` |
| Banners, cloth, shutter cloths | **Fabric** | Blood, Gold trim | `[S02 §7] [S03 §3]` |
| Lamp posts, iron fittings | **CorrodedMetal** (or **Metal**) | Soot | `[PROPOSED]` (S03 says "iron posts", no material) |
| Bone (altar tiers, horns, skulls) | **Limestone** or **Concrete** | Bone / BoneDim | `[PROPOSED]` |
| Old timber, dead trees | **Wood** / **WoodPlanks** | dark brown-grey | `[PROPOSED]` |
| Well, ruined town wall | **Cobblestone** / **Slate** | Soot | `[PROPOSED]` (S03 says "stone") |
| Cryptid hide / skin | **Slate**, **Basalt**, **Fabric** (fur/wings), **Leather** | per asset | `[PROPOSED]` |

**Material rules**
- **Neon = rare accent only.** In a lair, the **only** Neon is the Rift Fissure trim `[S01 A4] [S02 §3]`. In town, Rift glow only at the **Great Rift pit** and the **Pedlar's "new stock" lantern** `[S03 §3]`. **Exceptions:** the Mothman Hatchling's two eye parts are Neon Blood `[DECIDED D10]`; the Dover Demon's two eye parts are Neon GoldBright `[DECIDED D13]`. Placeholders, all other cryptids and all other glows use Glass. The validator enforces this allowlist by CryptidId.
- **No SmoothPlastic or Plastic** on visible surfaces. They look toy-like `[PROPOSED]`.
- **No Glass/ForceField** except where a spec asks for a glow and Neon is banned `[PROPOSED]`.
- **Dark parts get lighter than you'd think** `[PROPOSED]`. Roblox materials darken colour, so floors should be about **`#3A3436` `(58, 52, 54)`** (lighter than Soot) so cryptids and pads stand out. Keep pure Void for UI only.
- **Weathering:** break up big flat areas with small offset/rotated parts (chipped stones, slanted boards), not textures `[PROPOSED]`.

---

## 3. Silhouette & shape rules

### Cryptids `[PROPOSED unless tagged]`
- **Read at a glance:** recognisable from its **black silhouette alone** at **30 studs** on a phone screen.
- **One hero feature** per species, exaggerated (wings, horns, legs, eyes). Everything else stays simple.
- **Fits its pad.** 12 pads sit on a ring of radius 28 `[S02 §3]`, so neighbouring pad centres are ~14.5 studs apart. Pad diameter is **≤ 10 studs** and a cryptid footprint is **≤ 8 × 8 studs** (Commons ≤ 6 × 6).
- **Height ≤ 10 studs** on a pad, so the pad billboard (name + income) `[S01 B5]` stays clear above it.
- **Light contrast part:** every cryptid has at least one **Bone/BoneDim or Blood** area so it doesn't vanish on dark Slate.
- **Asymmetry and wear:** tilted heads, uneven limbs, chipped edges. No round "cute" proportions, no big shiny eyes.
- **Pose:** idle, slightly hunched, facing the Lair Gate (+Z) by default.
- **Rarity = shape, not saturation:** higher rarities get bigger or more complex shapes and a palette-token accent (Gold for Legendary, Rift for Mythic), never brighter colours.

### Buildings
- **Crooked and leaning 2–4°** `[S03 §3]`; dark WoodPlanks + Slate roofs `[S03 §3]`.
- **Town stall footprint ≤ 24 × 24 studs**, matching the reserved footprints `[S03 §2]` `[PROPOSED for live/shuttered stalls]`.
- **Front faces the Well** `[S03 §2]`. **Lair Gate faces the Town** `[S02 §2]`.
- **Shuttered stalls:** fully dressed, **boarded with crimson cloth**, sign "Shuttered until the next moon" in BoneDim `[S03 §2]`.
- **Lair walls:** 14 studs high, Basalt, crenellated `[S02 §2]`. Gate opening 16 wide (front), 12 wide (back) `[S02 §3]`.
- **Roofline first:** every building needs a distinct roof silhouette (steep, sagging, or broken) so districts read through fog `[PROPOSED]`.

### Town props
- **Lamp posts** every 18 studs on the inner ring `[S03 §3]`.
- **Weeping Well**: 10-stud stone well, ring of 8 candles, dripping dark water `[S03 §2]`.
- **Low ruined wall** at r = 120 with 8 road openings `[S03 §2]`.
- **No bubbly signs.** Signs are flat boards with Gold trim only `[S03 §3]`.
- Props stay **out of the 16-wide roads** and the 12-stud buy zone in front of live stalls `[S03 §4.1]` `[PROPOSED]`.

---

## 4. Lighting & atmosphere

**Goal:** moody but **readable**. Eudai found the first lair too dark. Cryptids, pads and billboards must be **clearly visible on a dim phone (≈30% screen brightness)**. Spec 01 A4's "Ambient near-black" is **replaced** by the minimum values below **`[DECIDED D1]`**: readability beats near-black.

### Shared `Lighting` (whole place): minimums `[DECIDED D1]`, exact values tunable in Play
| Property | Value | Why |
|---|---|---|
| `Technology` | **ShadowMap** | Cheaper than Future on mobile |
| `ClockTime` | **0** (night) + faint moon | "near-black sky, faint moon" `[S03]` |
| `Brightness` | **1.5** | Moonlight still shapes forms |
| `Ambient` | **`(60, 55, 52)`** `#3C3734`, **never darker** | Floor so indoor/lair shadow isn't pure black |
| `OutdoorAmbient` | **`(95, 88, 82)`** `#5F5852`, **never darker than `(80,74,70)`** | Main readability lever |
| `ExposureCompensation` | **+0.3** (range 0.2–0.5) | Lifts mid-tones on phones |
| `ColorShift_Top` | `(40, 30, 20)` | Warm candle cast |
| `ColorShift_Bottom` | `(0, 0, 0)` | |
| `EnvironmentDiffuseScale` / `EnvironmentSpecularScale` | **0.4 / 0.2** | Soft fill, little shine |
| `GlobalShadows` | true | |
| `FogStart` / `FogEnd` | **250 / 1100**, FogColor `#1A1719` (legacy fallback; Roblox uses Atmosphere when present, verify in Studio). Atmosphere: Density 0.18, Haze 0.3 (never higher over gameplay), Offset 0, Glare 0, Color `#1A1719`, Decay `#0B0A0C`. Mood fog only via local wisp emitters at the town wall and past the Wild Gates `[S03 v1.2 §3, D9]` | |

### `Atmosphere` `[S03 §3]` (Eudai's values win)
- `Density` **0.18**, `Haze` **0.3**, `Color` **`#1A1719` `(26,23,25)`**, `Decay` **`#0B0A0C` `(11,10,12)`**.
- `Offset` **0.1**, `Glare` **0** `[PROPOSED]`.
- **Test:** your own plot's **Gold home beam** `[S02 §7]` must be visible from the Town edge. If not, brighten further `[S03 §3]`.

### Post-processing `[PROPOSED]`
- **ColorCorrection:** Brightness **+0.03**, Contrast **+0.1**, Saturation **−0.15**, TintColor **`(255, 242, 224)`**.
- **Bloom:** Intensity **0.4**, Size **24**, Threshold **1.6**, so only Neon and candles bloom.
- **No** DepthOfField, SunRays or Blur in gameplay (mobile cost, readability).

### Per area
| Area | Rules | Source |
|---|---|---|
| **Lair (S01/S02)** | Warm candle **PointLights** `#FFB36B`, range **12**, brightness **1.2** `[S01 A4]`, on walls every 20 studs `[S02 §7]`; **only every third candle has a PointLight** `[DECIDED D2]`. **Plus `[PROPOSED]`:** one **altar fill light** (PointLight `#FFB36B`, range **40**, brightness **0.8**, Shadows off) over the Bone Altar so the whole pad ring is lit. | S01, S02 |
| **Unclaimed lair** | Gates shut, **no lights** `[S02 §7]`. Ambient floor still applies, so it reads as dark, not invisible. | S02 |
| **Onboarding seal** | Faint Rift green on gate `[S02 §6]`. **Glows without Neon** `[DECIDED D3]`: a Beam or transparent part in Rift. | S02 |
| **Hollowmere town (S03)** | Lamps PointLight `#FFB36B`, range **14**, brightness **1.0**; **1 in 6 flickers** with random 0.2–0.6 s dips. Rift glow only at the pit and Pedlar lantern. | S03 |
| **Skill tree (S04)** | ScreenGui, no world lighting. Void backdrop, 0 transparency. | S04 |

**Readability tests (pass/fail)** `[PROPOSED]`: on a phone emulator at low brightness, (1) every cryptid's silhouette is visible against the floor, (2) pad states (locked/empty/occupied) are distinguishable, (3) billboard text is readable at 30 studs.

---

## 5. UI frame & font rules

### Fonts: Roblox built-in only `[S01 A3]` (verify each renders in Studio before locking)
| Role | `Enum.Font` | Desktop / Mobile |
|---|---|---|
| Display titles, banner headline | **GrenzeGotisch** | 36 / 28 |
| Panel headers | **Garamond** (bold, set via `FontFace` weight Bold) | 24 / 20 |
| Body, buttons | **Merriweather** | 18 / 16 |
| Numbers (cash, timers, costs) | **Oswald** | Plaque cash 28/22, income 16/14, else 18/16 |

- **Minimum 14 px** text anywhere. `TextScaled = false`, fixed sizes, `UITextSizeConstraint` max = table value `[S01 A3]`.
- **Never** use the Gothic font for numbers or body text `[S01 A3]`.

### Frames `[S01 A4]`
- **Panel:** Ash fill, **1 px UIStroke Gold at 40% transparency**, **UICorner 4 px** (sharp, not bubbly).
- **Primary button:** Blood fill, 1 px Gold stroke, Bone text; hover → BloodHover.
- **Secondary button:** Soot fill, BoneDim stroke.
- **Disabled:** BoneDim text + lock icon/word.
- **Vignette (optional):** UIGradient Void, opaque edges → clear centre.
- Texture art (parchment grain, cracked-gold 9-slice) is **TBD**. **Everything must work with flat colours** if assets are missing `[S01 A4]`.
- **HUD:** cash plaque top-centre, 320×72 / 240×60, Ash + **2 px Gold** stroke, sigil left; `ScreenInsets = CoreUISafeInsets` `[S01 A6]`. "Return to Lair" + "Rites" bottom-left, Soot + Gold stroke `[S02 §7] [S04 §2]`.

### Mobile readability `[PROPOSED unless tagged]`
- **Tap targets ≥ 44 × 44 screen px** (buttons, cards, nodes, close).
- Keep UI out of the thumb zones used by Roblox's jump and joystick controls (bottom-right, bottom-left lower third). The HUD buttons sit **above** the joystick.
- Shop cards **2 × 2** on mobile, panel full-width `[S03 §5]`.
- **Motion:** respect **Reduced Motion** `[S01 A5]`. No screen shake. **No flashing faster than 3×/s** `[S01 A5]`.

### 5a. Ritual-circle skill tree art direction `[S04]`
**Fantasy:** a ritual circle **chalked on black stone**. Hunter rites on the left, Lair rites on the right. Buying **ignites** a sigil, and its chalk path turns into a **glowing blood vein** `[S04 §1]`.

**Canvas** `[S04 §3]`
- Backdrop **Void**, opaque. Canvas 2800 × 2800 px. Stone texture is TBD; a flat **Ash** fill works.
- **Chalk rings:** Bone, **70% transparency, 3 px**, at radius **240 / 600 / 960 / 1240**.
- **Rune band** between radius 1180 and 1240. Glyphs Bone at ~70% transparency, angular hand-chalked strokes, no Latin letters `[PROPOSED style]`.
- **Branch labels** HUNTER / LAIR: GrenzeGotisch 48, Gold at 40% transparency.

**Node states** `[S04 §5.3]`
| State | Disc | Stroke | Sigil | Extra |
|---|---|---|---|---|
| **Locked** (cracked stone) | Soot | BoneDim 2 px | 60% transparent | Crack overlay (fallback: 2 thin Void lines) + small lock glyph |
| **Available** (pulsing candle) | Ash | **Gold 3 px**, transparency pulses 0.2 ↔ 0.6, 1.6 s sine | Bone | Small flickering flame |
| **Owned** (ember red) | **Blood** | **GoldBright 3 px** | Bone | Ember sparks |

**Paths** `[S04 §6]`
- **Chalk** (child locked): Bone 70% transparency, 4 px, dashed 12/8.
- **Bright chalk** (child available): Bone 35% transparency, 4 px, solid.
- **Blood vein** (both owned): Blood 6 px core + BloodHover 12 px glow at 60% transparency; gradient flows outward from the root every 2 s.

**Glow rules**
- Glow means **owned or actionable only**. Locked nodes never glow `[PROPOSED]`.
- Sparks: GoldBright/BloodHover, 2/s per owned node, **max 6 per node, max 60 on screen**, paused when closed `[S04 §5.4]`.
- Ignite burst 0.9 s, **only after the server confirms** `[S04 §8]`.
- **Rift green is not used in the tree** `[PROPOSED]`. It stays "supernatural/rare", and the tree is Blood/Gold.
- Reduced Motion: colour swaps with a 0.15 s fade only `[S04 §8]`.

**Sizes and tap targets**
- Node **96 × 96**, capstone/root **128 × 128** canvas px; hit area = node + 16 px `[S04 §5.3]`.
- ⚠️ At default zoom 0.5 a normal node's hit area is **56 screen px** (fine). At **min zoom 0.35 it drops to ~39 px**, below the 44 px minimum. **Proposed:** scale the hit padding so the hit area never drops below **44 screen px** at any zoom `[PROPOSED]`.
- **Tooltip** 340 × 220, not zoomed. Bone parchment with **Void text**, 1 px Gold stroke, ragged edge. **Wax-seal BUY** is a 76 px circle (above the 44 px minimum) `[S04 §7]`.

---

## 6. Performance budgets (mobile first) `[DECIDED D4]`

| Asset class | Parts (max) | Triangles if mesh (max) | Textures |
|---|---|---|---|
| **Small cryptid** (Common/Uncommon) | **40** | **2,000** | none, or 1 × 256² |
| **Large cryptid** (Rare+) | **80** | **5,000** | 1 × 512² |
| **Pad** (×12 per plot, ×8 plots = 96) | **6** | 300 | none |
| **Bone Altar** (all tiers) | **60** | 3,000 | none |
| **Building / stall** | **150** | **10,000** | ≤ 2 × 512² |
| **Town prop** (lamp, crate, sign) | **20** | **1,000** | none, or 1 × 256² |
| **Whole lair plot** (built, no cryptids) | **1,200** | – | – |
| **Whole town** | **4,000** | – | – |

**Texture limits:** world **≤ 512 × 512**, UI **≤ 1024 × 1024** (9-slice frames, skill-tree stone). Reuse textures; no unique texture per prop.

**Effects limits**
- **Neon:** ≤ **2% of a view**; only where specs allow (Fissure trim, Great Rift pit, Pedlar lantern) `[S01] [S03]`, plus the Mothman eyes (2 parts) `[D10]` and the Dover Demon eyes (2 parts) `[D13]`.
- **Transparency:** ≤ **4 semi-transparent parts per asset**. No big overlapping transparent planes (overdraw).
- **ParticleEmitters:** ≤ **2 per asset**, Rate ≤ **10/s**, Lifetime ≤ 2 s; ≤ **200 world particles on screen**.
- **Lights:** **Shadows = false** on all PointLights except one key light per area. ≤ **8 lights per plot**, ≤ **24 in town**.
  - Wall candles `[S02 §7]`: a candle model every 20 studs, a **PointLight on every third** only `[DECIDED D2]`.
- **Highlight instances:** a **31-at-once limit is UNVERIFIED** `[D8]`. **Check it in Studio before relying on it.** Until then, don't use Highlight for always-on effects, and don't plan Keen Eye outlines `[S04 h3]` around it.
- **UI particles:** follow the S04 caps (60 sparks) `[S04]`.
- **Unions/CSG:** avoid; prefer plain Parts or one MeshPart (fewer draw calls, no collision surprises).
- **Collision:** decorative parts get `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, and `CollisionFidelity = Box` on meshes.
- **Anchored = true** for every static part.

---

## 7. Asset checklist (pass/fail; every asset, every time)

| # | Check | Pass if |
|---|---|---|
| 1 | **Palette** | Every colour is a §1 token (or a documented material tint). **No purple**, no saturated blue, no pastel |
| 2 | **Rift green** | ≤ 5% of a UI screen, ≤ 2% of a 3D view; only in spec-approved places |
| 3 | **Neon** | Only where §2 allows |
| 4 | **Materials** | Uses §2 materials; no SmoothPlastic/Plastic on visible faces |
| 5 | **Silhouette** | Recognisable in pure-black silhouette at 30 studs (cryptids) / through fog (buildings) |
| 6 | **Not toy-like** | No bubbly rounding, no glossy, no saturated colours. Weathered and asymmetric |
| 7 | **Fit** | Cryptid ≤ 8×8×10 studs on pad; stalls ≤ 24×24; faces the right way (pads/cryptids → gate, stalls → Well) |
| 8 | **Budget** | Part/tri/texture/effect counts ≤ §6 |
| 9 | **Readability** | Visible on a phone emulator at low brightness under §4 lighting |
| 10 | **UI** | Built-in fonts only (§5), text ≥ 14 px, tap targets ≥ 44 px, works with flat colours |
| 11 | **Physics hygiene** | Anchored; decorative collisions off; no unions where Parts work |
| 12 | **Naming** | Model named `<AssetName>`, parts named meaningfully (no "Part" ×40) |
| 13 | **Screenshot proof** | PNGs saved to **`/workspace/project-cryptid/qa/screenshots/<asset>_<YYYY-MM-DD>_<view>.png`** (views: `front`, `threequarter`, `top`, `mobile`), e.g. `mothman_hatchling_2026-11-04_threequarter.png` |
| 14 | **Creator Store safety** `[DECIDED D6]` | Allowed only if **free to use** **and** **logged in `asset-list.md`**. Inspected: **no Scripts/LocalScripts/ModuleScripts**, **no `require()`**, **no RemoteEvents/RemoteFunctions**, no hidden/oddly named objects, no `getfenv`/`loadstring`, no obfuscated strings (backdoor patterns). Strip all scripts before use |
| 15 | **Licence** | Source + licence noted in the handoff (self-built / Creator Store asset ID + creator + logged / generated via the guarded official-MCP wrapper `[D5]`) |
| 16 | **Handoff** | §8 note filled in |

---

## 8. Handoff note template (for the Systems Architect)

```markdown
### Handoff: <Asset name>
- **Asset id / model name:** <e.g. mothman_hatchling>
- **File / place path:** <where the model lives, e.g. ReplicatedStorage.Assets.Cryptids.mothman_hatchling>
- **Goes in game at:** <e.g. cloned onto Workspace.Plots.Plot<i> pads (spec 02 §3)>
- **Counts:** <N> parts · <N> triangles (meshes) · <N> textures (sizes) · <N> lights · <N> emitters · Neon yes/no
- **Materials used:** <Enum.Material list>
- **Colours used:** <tokens>
- **Pivot / facing:** <PrimaryPart, pivot at base centre, faces +Z>
- **Size (studs):** <X × Y × Z>
- **States / variants:** <e.g. locked / empty / occupied; altar tiers 0–II>
- **Scripts inside:** none (art only) ✅
- **Source & licence:** <self-built | Creator Store ID + creator + licence (free to use, logged in asset-list.md) | generated via guarded official-MCP wrapper>
- **Screenshots:** qa/screenshots/<asset>_<YYYY-MM-DD>_<view>.png (list)
- **Checklist (§7):** all pass / failures + reason
- **Notes for code:** <attachments, attribute names, anything the system must set>
```

Proposed default: art assets live under **`ReplicatedStorage.Assets.<Category>.<assetId>`** and are cloned into place by code `[PROPOSED]` (the specs only fix runtime parents like `Workspace.Plots.Plot<i>` `[S02 §5]`).

---

## 9. Open questions for Eudai

**Still open**
1. ~~**Extra rarity colours:** keep Moss and Tarnished silver?~~ **RESOLVED:** Silver `#8C9AA3` approved by **D11**. Moss `#5E7A4A` is used for the Uncommon trim as given in spec 01 A2 / spec 09 §2 (spec assumption [A]); no separate decision logged.
2. **Skill-tree tap targets:** OK to enlarge hit areas at low zoom so they never drop below 44 px?
3. **Cryptid look:** the specs name the species but don't describe them. OK to base designs on folklore (see asset list)?
4. **Bone material:** Limestone vs Concrete for bone surfaces? (MothmanHatchling v0.1 uses Limestone.)
5. ~~**Cryptid eyes:** allow a tiny Neon exception for eyes?~~ **RESOLVED by D10** (Mothman eyes only, 2 parts, Neon Blood).

**Pending input**
- Highlight limit: verify in Studio `[D8]`.

**Resolved 2026-11-03 (Master Controller):** Ambient floor (D1), candle lights (D2), seal glow (D3), budgets (D4), meshes (D5), Creator Store (D6), bone hex (D7), Mothman eye Neon (D10). 2026-11-04: Rare silver (D11), icon/thumbnail capture source (D12), Dover Demon Neon eyes (D13).
