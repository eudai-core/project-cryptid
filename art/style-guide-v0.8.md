# Project Cryptid: Living Art Style Guide

**Version:** v0.8 (2026-11-04, D41–D49 Master Controller rulings on the atmosphere pass: Neon/RiftDim, OutdoorAmbient fallback, Atmosphere `#282A30`, fog exception, smoke texture allowlist, lair fog, Epic beat in events, launch scope) · v0.7 (2026-11-04, D38 RiftDim, D39 light cap + Hodag lantern, D40 goal-3 pips) · v0.6 (2026-11-04, D34–D35 and D37 Master Controller rulings; D26/D29 amended: "bought" = Robux) · v0.5 (2026-11-04, D33 onboarding re-order, D36 gift banners) · v0.4 (2026-11-04, D27–D32 Master Controller rulings on the VFX plan §10 conflicts) · v0.3 (2026-11-04, D14–D26 + D8/D21 Highlight update) · v0.2 (2026-11-03) · **Owner:** Art · **Reads from:** Specs 01–04
**Tags:** `[S01]`–`[S04]` = rule taken from that spec. **`[FIXED]`** = fixed art direction from the project brief. **`[PROPOSED]`** = **Proposed default (needs Eudai sign-off)**: the specs say nothing, so this is my suggestion. **`[DECIDED]`** = settled, see the decision log.

> **World look superseded where it conflicts (director ruling, 11 Nov 2026).** This file stays the living guide for decisions that do not conflict. Spec 15 wins the world look: a purple night, coloured flames, and Neon on flames, portals, runes, signs, and eyes, within the budgets in [`docs/VISUAL_REFERENCES.md`](../docs/VISUAL_REFERENCES.md). Spec 01 A2 palette tokens still apply to UI. Sentences below that ban bright purple, saturated blue, or cartoony shapes in the world, or that limit Neon to the Mothman Hatchling's eyes and the Dover Demon's eyes, are superseded where they conflict with that. The fissure belt, the Great Rift pit, and the Pedlar lantern stay RiftDim, not Neon (D38, D41, ruling 9). D34 still wins for Mythic. The Highlight cap stays 31 until 255 is verified in Studio (ruling 7). Main's lighting values stay until visual pass #17 tunes them (ruling 8).

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
| D8 | 2026-11-03, **updated 2026-11-04** | Master Controller | **Highlight limit UNVERIFIED.** Update 4 Nov: the Master Controller reports Roblox raised the limit from 31 to **255** (design bible cites a Nov 2025 DevForum post); **we have not verified this ourselves**. Keep the **pool of 2** per client for mobile GPU cost (bible: first visible Highlight can cost up to ~1 ms GPU on mobile, also unverified). Verify in Studio | §6, vfx-audio-plan §1.4 |
| D9 | 2026-11-03 | Master Controller / Growth Strategist | **Fog set in spec 03 v1.2 (line 59):** FogStart 250, FogEnd 1100, FogColor ~~#1A1719~~ → **`#282A30`** (superseded by D44 for FogColor and Atmosphere Color; legacy fallback; Atmosphere governs, verify in Studio). Atmosphere Density 0.18 / Haze 0.3 max over gameplay areas | §4 |
| D10 | 2026-11-03 | Master Controller | **Neon exception: cryptid eyes, Mothman Hatchling only, 2 parts (`Eye_R`, `Eye_L`), Blood `#7A0F12`.** No other cryptid gets Neon without a new decision | §2, §6 |
| D11 | 2026-11-04 | Master Controller | **Rare silver `#8C9AA3` approved** as a rarity-trim exception outside the fixed palette (rarity trims/labels only) | §1 |
| D13 | 2026-11-04 | Master Controller | **Neon exception extended: Dover Demon eyes, 2 parts (`Eye_R`, `Eye_L`), GoldBright `#C9A55A`.** Those 2 parts only; placeholders stay Glass. No other cryptid gets Neon without a new decision | §2, §6 |
| D12 | 2026-11-04 | Master Controller | **Game icon + thumbnails use real Studio captures.** Box renders are a fallback only if Studio imports slip past **Mon 9 Nov** | §9, store art brief |
| D14 | 2026-11-04 | Master Controller | **Transient VFX budget: ≤ 6 emitters and ≤ 120 particles per effect** (particles = Rate × max Lifetime for continuous emitters + `:Emit` burst counts). §6 "≤ 2 emitters per asset" still applies to models | §6, vfx-audio-plan §1.2 |
| D15 | 2026-11-04 | Master Controller | **True screen shake stays at 0.** FOV ("zoom punch") and vignette punches are allowed instead (off with Reduced Motion) | §5, vfx-audio-plan §2 |
| D16 | 2026-11-04 | Master Controller | **Silhouette = a "materialise" beat only.** Nothing paid ever gets a mystery reveal (cash purchases show the cryptid before paying, spec 09) | vfx-audio-plan §2 |
| D17 | 2026-11-04 | Master Controller | **One reveal light**, catcher's client only, **< 3 s**, Shadows off: an exception to the ≤ 8 lights-per-plot cap | §6, vfx-audio-plan §1.3 |
| D18 | 2026-11-04 | Master Controller | **Epic banner top at 104 px desktop / 92 px mobile** (below the cash plaque); the goal banner hides while it shows | spec 08, vfx-audio-plan §4 |
| D19 | 2026-11-04 | Master Controller | **Idle auras on your own plot only at launch** | vfx-audio-plan §3 |
| D20 | 2026-11-04 | Master Controller | **Rift sparks (2–4) on Rift-source reveals**, within the ≤ 2% Rift rule | §1, vfx-audio-plan §2 |
| D21 | 2026-11-04, **updated 2026-11-04** | Master Controller | Was: ship the no-Highlight fallback unless QA confirms 31. **Now:** the Highlight silhouette ships with the pool of 2 (limit reportedly 255, unverified, see D8); the **no-Highlight fallback stays as an optional switch** (`VfxConfig.useHighlight`) | vfx-audio-plan §1.4 |
| D22 | 2026-11-04 | Master Controller | **Per-pad "+$" pop stays in P0** (thumbnail A stays honest) | vfx-audio-plan §5 |
| D23 | 2026-11-04 | Master Controller | **Custom textures are P1.** Launch uses built-in and Part-based effects only (no uploads before launch for VFX) | §6, vfx-audio-plan §8 |
| D24 | 2026-11-04 | Master Controller | **Rarity palette kept** (case-opening conflict closed): Common bone/grey (`#A79F90`), Uncommon Moss `#5E7A4A`, Rare silver `#8C9AA3`, Epic Blood crimson `#7A0F12`, Legendary/Mythic Gold (`#C9A55A`). **No purple** | §1, vfx-audio-plan §2 |
| D25 | 2026-11-04 | Master Controller | **Paid reels (case-opening conflict closed):** one fixed slow-down curve on every paid pull; no extra glow or heartbeat when a higher tier lands near the marker; the strip shows the true random neighbours; near-miss emphasis only on free pulls and wild catches; the charge-up pulse is identical on every pull and settles on the true tier. **Since `D37`: the paid-pull parts are DORMANT unless a paid random path returns** (honest strip, true-tier settle and near-miss-on-free still apply) | vfx-audio-plan §2.6 |
| D26 | 2026-11-04 | Master Controller | **Mythic sky flicker fires only for free or wild catches** (never for anything bought). **Amended 4 Nov (Master Controller):** "bought" means **bought with Robux**. In-game cash is earned, so **Rift belt and expedition catches are free sources** and can trigger the Mythic sky; personal Robux purchases never do | vfx-audio-plan §4 |
| D27 | 2026-11-04 | Master Controller (Eudai asked for it) | **Fate Reel approved** per **spec 10 v1.1** (spec 09 v2 points to it); the old spec 09 §5.5 "no reel / no near-miss" wording and the bible's near-miss ban are **void**. The reel is honest; **honest near-miss emphasis on free pulls only**; **no visual may imply a higher tier than the one rolled**; D25 governs paid pulls. **Scope: January P1, not launch.** P0 keeps only the guards (tier-colour table, paid guard: no banner / sky tint / near-miss, settle at the true tier) with no extra budget | vfx-audio-plan §2.6, §7 |
| D28 | 2026-11-04 | Master Controller | **Mythic is Gold** (Gold family; Legendary token GoldBright per §1). Supersedes the bible's Mythic = Rift; spec 10's Rift Mythic frame/sky is flagged. **Refined by `D34`** | §1, vfx-audio-plan §11 |
| D29 | 2026-11-04 | Master Controller | **No server banner for anything bought**, ~~Rift belt Epics included~~. **Wild-caught Epics still announce** (spec 08). **Amended 4 Nov (Master Controller):** "bought" means **bought with Robux**. In-game cash is earned, so **Rift belt and expedition catches are free sources and can announce**. **Personal Robux purchases never announce** (gift thank-yous: `D36`) | vfx-audio-plan §0, §4 |
| D30 | 2026-11-04 | Master Controller | **Part-built ritual rings are fine for launch** (instead of the bible's decals/Beam) | vfx-audio-plan §2.3 |
| D31 | 2026-11-04 | Master Controller | **Roblox-licensed sounds only**, logged in `art/vfx/audio-licences.md` (no self-generated uploads at launch) | vfx-audio-plan §6.3 |
| D32 | 2026-11-04 | Master Controller | **D8 stays UNVERIFIED** (Highlight limit, reportedly 255) until Studio confirms it | §6, vfx-audio-plan §1.4 |
| D33 | 2026-11-04 | Master Controller (spec 01 v2.0 onboarding) | **Hodag is the top early-readability priority.** Onboarding now: Hodag wild catch = goal 3 (~0:33, 20 studs outside the Wild Gate), bound on Pad 3 = goal 4 (~0:45); Hidebehind = goal 7 (~1:56, Pad 4). The Hodag must be **lit and readable in the Wilds near the gate**; Studio readability checks run **Hodag first, then Hidebehind**. Lighting fix is a proposal only (`handoff/HODAG-ONBOARDING.md`); model unchanged | asset-list (re-rank + check order), vfx-audio-plan §2.7, handoff notes |
| D34 | 2026-11-04 | Master Controller | **Mythic = GoldBright `#C9A55A` with a Bone flare, a distinct frame shape and a thin Rift-green core. Legendary stays plain GoldBright.** Refines `D28` (tells the two apart by shape + flare + core, not by a new colour) | §1, vfx-audio-plan §2.6, §11.1–11.2 |
| D35 | 2026-11-04 | Master Controller | **Rift green ≤ 2% of the screen everywhere** (UI and 3D). **One exception: the Mythic sky, up to 5%, free sources only** (`D26` as amended), with the lighting readability floor (§4) kept | §1, §7, vfx-audio-plan §0, §4, §11.3 |
| D36 | 2026-11-04 | Growth Strategist (relayed by the Master Controller) | **Gift thank-you banners:** the spec 08 §4b thank-you banners for **server-wide gifts may name the buyer, but they never show a price or a buy link.** Refines `D29` ("no banner for anything bought"): this is the one allowed bought-item banner, and it thanks rather than sells | vfx-audio-plan §4, §11.5 |
| D37 | 2026-11-04 | Master Controller | **Tarot pulls are earn-only.** Paid readings are **fixed bundles with exact contents shown before purchase**; **no paid random items**. The paid guard stays as a **safety net**. All paid-reel-only work (fixed slow-down, paid timing, paid wiring notes) is **DORMANT unless a paid random path returns**. **Server Luck: pending Eudai** | vfx-audio-plan §2.6, §7, §11; handoff/VFX-P0 |
| D38 | 2026-11-04 | Master Controller (approved) | **Canonical Rift `#7FA34A` is for small accents only** (particles, UI). **World trim on Parts uses `RiftDim #4F6B34`**, in **Slate, Metal or SmoothPlastic**. **Never Neon, and no Bloom catch** | §1 swatches, §2 materials, §7 checklist #1–#4 |
| D39 | 2026-11-04 | Master Controller | **Plot light cap stays at 8** (mobile first). **Hodag lantern APPROVED:** lit only during goal 3; the lit wall candle nearest the Wild Gate is off for that window (net 0) | §4, §6, `handoff/HODAG-ONBOARDING.md` |
| D40 | 2026-11-04 | Master Controller | **Goal 3's 3 dark rarity silhouettes are cut for launch.** Replaced by **3 tier-colour pips** (Common BoneDim, Uncommon Moss, Rare Silver) + a short text tease (e.g. "Rarer things stir..."). **Built-in UI only** (Frame, UICorner, UIStroke); **no ViewportFrames**. Silhouettes are **P1**, once textures exist | §5, vfx-audio-plan §2.7 (pip spec), §11.11 |
| D41 | 2026-11-04 | Master Controller | **No Neon on the Rift Fissure belt, the Great Rift pit or the Pedlar lantern.** Their glow = **PointLight + particles** over **RiftDim** surfaces, with tiny canonical Rift `#7FA34A` accents (sparks). **Neon stays limited to the Mothman and Dover Demon eyes** `[D10] [D13]`. Strategist updates specs 01/02 | §2, §6, §7 #3, `vfx/atmosphere-pass.md` §2.7 |
| D42 | 2026-11-04 | Master Controller | **RiftDim does not count toward the 2% bright-Rift cap** `[D35]`. RiftDim trim stays **thin, ≤ 10% of any surface**. **SmoothPlastic is allowed only for thin RiftDim trim strips** (validator: RiftDim colour and min side ≤ 0.3 studs) | §1, §2, §7 #2/#4, validator v4 |
| D43 | 2026-11-04 | Master Controller (AP-2) | **OutdoorAmbient = the fallback `(95, 98, 108)` `#5F626C`.** The **hard per-channel D1 floor stays** (no luminance-only reading): Ambient never below `(60,55,52)` per channel, OutdoorAmbient never below `(80,74,70)` per channel | §4 |
| D44 | 2026-11-04 | Master Controller | **Atmosphere `Color` `#1A1719` → `#282A30` `(40,42,48)`** (fixes the near-black far read). Density/Haze unchanged `[D9]`. **Verified by capture #2** (Town platform before/after). Strategist edits spec 03 | §4, capture plan #2 |
| D45 | 2026-11-04 | Master Controller (AP-5) | **Fog-only lifetime exception:** ambient fog wisps may live **up to 8 s** at a **low rate (≤ 2/s)**, **counted in the particle budget**. Every other emitter keeps the **2 s** cap. Validator: only an emitter named `FogWisp` with attribute `AmbientFog = true` | §6, validator v4 |
| D46 | 2026-11-04 | Master Controller (AP-6) | **Exactly ONE built-in texture is allowlisted: `rbxasset://textures/particles/smoke_main.dds`** (Roblox client texture, not an upload). No uploads; **any other texture fails** the validator (empty = class default is still fine). Test: `art/tools/test_validator_rules.py` | §6, validator v4 |
| D47 | 2026-11-04 | Master Controller | **Lair fog at a low rate, with clear zones around the pads and the tutorial spawn. Off when `effectsQuality` is Low** | §4 per area, `vfx/atmosphere-pass.md` §3 |
| D48 | 2026-11-04 | Master Controller | **During an atmosphere event, the Epic server moment adds only contrast and Bloom, never a sky tint** (events own the sky) | vfx-audio-plan §4, `vfx/atmosphere-events.md` |
| D49 | 2026-11-04 | Master Controller | **Launch atmosphere scope, after the core build order:** (1) lantern pools + night grade, (2) tier smoke, (3) ground fog, (4) catch beat **if time allows**. **Fog Night is the only launch event.** **Update 1:** Blood Moon (ships with its paid boost), the UI skin, Rift Storm, Eclipse | §4, `handoff/ATMOSPHERE-LAUNCH.md` |

**One-line direction:** grim, weathered, occult. A **candle-lit ritual ledger** `[S01 A1]`, a **fog-drowned market town** `[S03 §1]`. Dark and heavy, but **always readable**.

**Never:** bright purple, saturated blue, pastel, cartoony, toy-like, glossy, rounded "bubble" shapes `[FIXED] [S01 A2] [S03 §3]`. **World look superseded where it conflicts** with spec 15 (director ruling 1, 11 Nov 2026): purple night, coloured flames, and Neon on flames, portals, runes, signs, and eyes. The A2 ban still applies to UI. The fissure, pit, and Pedlar lantern stay non-Neon (ruling 9).

---

## 1. Palette swatches

UI may use **only** these tokens `[S01 A2]`. World parts should stay inside them too `[PROPOSED]`.

| Token | Hex | `Color3.fromRGB` | Role | Source |
|---|---|---|---|---|
| **Void** (near-black) | `#0B0A0C` | `(11, 10, 12)` | Backgrounds, overlays (85% opacity), skill-tree backdrop | `[FIXED] [S01]` |
| **Ash** | `#1A1719` | `(26, 23, 25)` | Panel fill (no longer the fog colour: Atmosphere is `#282A30` `[D44]`, a lighting value, not a token) | `[S01, derived]` |
| **Soot** | `#2A2427` | `(42, 36, 39)` | Raised cards, inputs, cobbles | `[S01, derived] [S03]` |
| **Blood** (dried-blood crimson) | `#7A0F12` | `(122, 15, 18)` | Primary buttons, "Buy", banners, cloth, owned nodes | `[FIXED] [S01]` |
| **BloodHover** | `#94171B` | `(148, 23, 27)` | Hover/press, vein glow | `[S01, derived]` |
| **Gold** (tarnished) | `#9C7A3C` | `(156, 122, 60)` | Currency, borders, sign trim, pad rings | `[FIXED] [S01]` |
| **GoldBright** | `#C9A55A` | `(201, 165, 90)` | Currency numbers, highlights, Legendary; Mythic base `[D34]` | `[S01, derived]` |
| **Bone** (bone white) | `#E8E0CF` | `(232, 224, 207)` | Main text, bones, parchment | `[S01]` **`[DECIDED D7]`** |
| **BoneDim** | `#A79F90` | `(167, 159, 144)` | Secondary/disabled text, Common | `[S01, derived]` |
| **Rift** (sickly green, rare) | `#7FA34A` | `(127, 163, 74)` | **Small accents only** `[D38]`: particles and UI (Rift sparks, mutations, "new" pips, Mythic core `[D34]`). **Not** for world trim on Parts | `[S01]` |
| **RiftDim** (world trim) | `#4F6B34` | `(79, 107, 52)` | **World trim on Parts** (e.g. Rift Fissure belt trim) in **Slate or Metal** (SmoothPlastic only for thin strips `[D42]`); **never Neon**, must not catch Bloom `[D38]`. Thin trim, **≤ 10% of any surface**; **not counted** in the 2% Rift cap `[D42]` | **`[DECIDED D38, D42]`** |

**Extra colours already in specs (not UI tokens):**
- Candle / lamp light `#FFB36B` → `(255, 179, 107)` `[S01 A4] [S03 §3]`.
- Rarity: Uncommon **Moss** `#5E7A4A` `(94, 122, 74)`, Rare **Tarnished silver** `#8C9AA3` `(140, 154, 163)` `[S01 A2, assumption]`. Epic = Blood, Legendary = plain GoldBright, **Mythic = GoldBright + Bone flare + distinct frame shape + thin Rift-green core** `[DECIDED D34]` (was "Rift + slow pulse"), Common = BoneDim.

**Usage ratios (per screen or per view)** `[PROPOSED]`, except the Rift cap from `[S01]`:
- **Dominant ~65%**: Void / Ash / Soot (stone, night, panels).
- **Secondary ~20%**: Bone / BoneDim (bone, text, chalk) and weathered wood.
- **Action ~10%**: Blood (cloth, buttons, owned states).
- **Accent ~5%**: Gold / GoldBright (trim, money, borders).
- **Rift green ≤ 2% of the screen everywhere**, UI and 3D `[DECIDED D35]` (was ≤ 5% UI per S01). Only exception: the **Mythic sky up to 5%**, free sources only, lighting floor kept.

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
| Rift conveyor belt | **Basalt** belt + thin trim in **Slate / Metal** (SmoothPlastic thin strips only `[D42]`), **not Neon** `[D38] [D41]`; glow = PointLight + particles `[D41]` | **RiftDim** `#4F6B34` | `[S01 A4] [S02 §3]` (specs say Neon Rift trim; superseded by D38) |
| Town ground, roads | **Cobblestone** | near Soot `#2A2427` | `[S03 §3] [S02 §2]` |
| Town buildings | **WoodPlanks** (dark) + **Slate** roofs | dark wood / Soot | `[S03 §3]` |
| Banners, cloth, shutter cloths | **Fabric** | Blood, Gold trim | `[S02 §7] [S03 §3]` |
| Lamp posts, iron fittings | **CorrodedMetal** (or **Metal**) | Soot | `[PROPOSED]` (S03 says "iron posts", no material) |
| Bone (altar tiers, horns, skulls) | **Limestone** or **Concrete** | Bone / BoneDim | `[PROPOSED]` |
| Old timber, dead trees | **Wood** / **WoodPlanks** | dark brown-grey | `[PROPOSED]` |
| Well, ruined town wall | **Cobblestone** / **Slate** | Soot | `[PROPOSED]` (S03 says "stone") |
| Cryptid hide / skin | **Slate**, **Basalt**, **Fabric** (fur/wings), **Leather** | per asset | `[PROPOSED]` |

**Material rules**
- **Neon = rare accent only.** In a lair, **no world Neon**: the Rift Fissure trim is now **RiftDim, non-Neon** `[D38]` (S01 A4 / S02 §3 said Neon). In town, Rift glow only at the **Great Rift pit** and the **Pedlar's "new stock" lantern** `[S03 §3]`, and **not Neon there either** `[D41]`: glow = a PointLight + particles over RiftDim surfaces with tiny `#7FA34A` accents. **Exceptions:** the Mothman Hatchling's two eye parts are Neon Blood `[DECIDED D10]`; the Dover Demon's two eye parts are Neon GoldBright `[DECIDED D13]`. Placeholders, all other cryptids and all other glows use Glass. The validator enforces this allowlist by CryptidId.
- **No SmoothPlastic or Plastic** on visible surfaces. They look toy-like `[PROPOSED]`. **Exception:** thin RiftDim trim strips only (≤ 0.3 studs, ≤ 10% of any surface) `[D38] [D42]`.
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
- **Rarity = shape, not saturation:** higher rarities get bigger or more complex shapes and a palette-token accent (GoldBright for Legendary; GoldBright + Bone flare + thin Rift core for Mythic `[D34]`), never brighter colours.

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
| `Ambient` | **`(60, 62, 70)`** `#3C3E46` night grade `[D49]`; **hard floor `(60, 55, 52)` per channel, never darker** `[D1] [D43]` | Floor so indoor/lair shadow isn't pure black |
| `OutdoorAmbient` | **`(95, 98, 108)`** `#5F626C` `[DECIDED D43]` (was `(95,88,82)`); **hard floor `(80,74,70)` per channel** `[D1]` | Main readability lever. Cool tint for lighting only: R ≤ G (never purple) |
| `ExposureCompensation` | **+0.3** (range 0.2–0.5) | Lifts mid-tones on phones |
| `ColorShift_Top` | `(22, 24, 30)` cool moon cast `[D49 night grade]` (was `(40,30,20)`) | Warmth comes from the candle/lantern PointLights only |
| `ColorShift_Bottom` | `(0, 0, 0)` | |
| `EnvironmentDiffuseScale` / `EnvironmentSpecularScale` | **0.4 / 0.2** | Soft fill, little shine |
| `GlobalShadows` | true | |
| `FogStart` / `FogEnd` | **250 / 1100**, FogColor `#282A30` (legacy fallback; Roblox uses Atmosphere when present, verify in Studio). Atmosphere: Density 0.18, Haze 0.3 (never higher over gameplay), Offset 0, Glare 0, Color **`#282A30`** `[D44]`, Decay `#0B0A0C`. Ground fog = the camera-local `AmbienceRig` + low-rate lair fog `[D45] [D47]`, see `vfx/atmosphere-pass.md` §3 `[S03 v1.2 §3, D9]` | |

### `Atmosphere` `[S03 §3]` (Eudai's values win)
- `Density` **0.18**, `Haze` **0.3**, `Color` **`#282A30` `(40,42,48)`** `[DECIDED D44]` (was `#1A1719`; verify in capture #2), `Decay` **`#0B0A0C` `(11,10,12)`**.
- `Offset` **0** (spec 03 wins over the old 0.1 proposal), `Glare` **0**.
- **Test:** your own plot's **Gold home beam** `[S02 §7]` must be visible from the Town edge. If not, brighten further `[S03 §3]`.

### Post-processing: launch night grade `[D49]` (tune in Play)
- **ColorCorrection:** Brightness **+0.03**, Contrast **+0.12** (cap), Saturation **−0.18**, TintColor **`(240, 244, 250)`** (was +0.1 / −0.15 / `(255,242,224)`).
- **Bloom:** Intensity **0.45**, Size **28**, Threshold **1.5**, so only candle flames, LightEmission particles and the 2 Neon eye sets bloom (was 0.4 / 24 / 1.6). Off at `effectsQuality` Low. RiftDim trim must stay below the Bloom threshold (non-Neon, dark) `[D38]` `[VERIFY in Studio]`.
- **No** DepthOfField, SunRays or Blur in gameplay (mobile cost, readability).
- **Events:** Fog Night is the only launch event `[D49]`; profiles in `vfx/atmosphere-events.md`. Every profile keeps the per-channel D1 floor `[D43]`.

### Per area
| Area | Rules | Source |
|---|---|---|
| **Lair (S01/S02)** | Warm candle **PointLights** `#FFB36B`, range **16**, brightness **1.4** (launch lantern pools `[D49]`; spec value 12 / 1.2 `[S01 A4]`), on walls every 20 studs `[S02 §7]`; **only every third candle has a PointLight** `[DECIDED D2]`. **Plus:** one **altar fill light** (PointLight `#FFB36B`, range **32**, brightness **0.7**, Shadows off) over the Bone Altar `[D49 pools]`. **Lair-gate exterior lantern** (16 / 1.4) = the lit candle nearest the Lair Gate moved outside (net 0). **Lair fog:** low rate, clear of pads and the tutorial spawn, **off at Low** `[D47]`. | S01, S02 |
| **Unclaimed lair** | Gates shut, **no lights** `[S02 §7]`. Ambient floor still applies, so it reads as dark, not invisible. | S02 |
| **Onboarding seal** | Faint Rift green on gate `[S02 §6]`. **Glows without Neon** `[DECIDED D3]`: a Beam or transparent part in Rift. | S02 |
| **Hollowmere town (S03)** | Lamps PointLight `#FFB36B`, range **16**, brightness **1.2**, every other inner-ring post lit; Well fill 28 / 0.6; road-mouth lanterns 18 / 1.4 ×8; 2 live stalls 14 / 1.2; **≤ 23 of 24** (`vfx/atmosphere-pass.md` §2.5, `[D49]`); **1 in 6 flickers** with random 0.2–0.6 s dips. Rift glow only at the pit and Pedlar lantern, **PointLight + particles, no Neon** `[D41]`. | S03 |
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
- **Goal-3 rarity tease** `[D40]`: 3 tier-colour pips + text, built-in UI only; spec in `vfx/vfx-audio-plan.md` §2.7.
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
- **Neon:** **only** the Mothman eyes (2 parts) `[D10]` and the Dover Demon eyes (2 parts) `[D13]` `[D41]`. **No Neon** on the Fissure belt, Great Rift pit or Pedlar lantern (glow = PointLight + particles over RiftDim) `[D38] [D41]`.
- **Transparency:** ≤ **4 semi-transparent parts per asset**. No big overlapping transparent planes (overdraw).
- **ParticleEmitters:** ≤ **2 per asset**, Rate ≤ **10/s**, Lifetime ≤ 2 s; ≤ **200 world particles on screen**.
  - **Fog-only exception** `[DECIDED D45]`: ambient fog wisps (`FogWisp`, attribute `AmbientFog = true`) Lifetime ≤ **8 s**, Rate ≤ **2/s**, counted in the 200 budget (ambience ≤ 40 alive, halved during reveals). Nothing else exceeds 2 s.
  - **Textures** `[DECIDED D46]`: class default or **exactly** `rbxasset://textures/particles/smoke_main.dds`; anything else fails the validator. Custom textures stay P1 `[D23]`.
  - **Transient VFX** (one reveal, one burst): ≤ **6 emitters and ≤ 120 particles per effect** `[DECIDED D14]`. Glow comes from particle/Beam `LightEmission`, **never Neon** (auras included).
- **Lights:** **Shadows = false** on all PointLights except one key light per area. ≤ **8 lights per plot**, ≤ **24 in town**. Client light LOD: other plots' PointLights off beyond **200 studs** (Low: 120); flame parts stay visible. Exception: **one reveal light**, catcher's client only, < 3 s `[DECIDED D17]`.
  - Wall candles `[S02 §7]`: a candle model every 20 studs, a **PointLight on every third** only `[DECIDED D2]`.
  - **Plot cap stays at 8** (mobile first) `[DECIDED D39]`. Hodag tutorial lantern: lit only during goal 3, with the lit wall candle nearest the Wild Gate off for that window (net 0) `[D39]`, `handoff/HODAG-ONBOARDING.md`.
- **Highlight instances:** limit **UNVERIFIED** `[D8]` (31 per the old docs; reportedly raised to 255, not verified by us). **Pool of 2** per client for mobile GPU cost; never on always-on effects; the no-Highlight fallback stays optional `[D21]`. Check in Studio before planning Keen Eye outlines `[S04 h3]` around it.
- **UI particles:** follow the S04 caps (60 sparks) `[S04]`.
- **Unions/CSG:** avoid; prefer plain Parts or one MeshPart (fewer draw calls, no collision surprises).
- **Collision:** decorative parts get `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, and `CollisionFidelity = Box` on meshes.
- **Anchored = true** for every static part.

---

## 7. Asset checklist (pass/fail; every asset, every time)

| # | Check | Pass if |
|---|---|---|
| 1 | **Palette** | Every colour is a §1 token (incl. **RiftDim** `[D38]`) (or a documented material tint). **No purple**, no saturated blue, no pastel |
| 2 | **Rift green** | ≤ 2% of the screen, UI and 3D `[D35]` (Mythic sky ≤ 5%, free sources only); only in spec-approved places. **Canonical Rift only on small accents (particles, UI); world trim on Parts = RiftDim** in Slate/Metal (SmoothPlastic thin strips), never Neon, no Bloom catch `[D38]`; RiftDim thin (≤ 10% of a surface) and **not counted** in the 2% `[D42]` |
| 3 | **Neon** | Only the Mothman/Dover Demon eyes `[D41]`; **never on Rift/RiftDim world trim, pit or lantern** `[D38] [D41]` |
| 4 | **Materials** | Uses §2 materials; no SmoothPlastic/Plastic on visible faces (except thin RiftDim strips `[D42]`) |
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
