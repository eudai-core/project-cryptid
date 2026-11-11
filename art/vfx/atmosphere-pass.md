# Project Cryptid: Atmosphere Pass ("make it feel real")

**Version:** v0.2 (Wed 4 Nov 2026: Master Controller rulings **D41–D49** folded in; AP list turned into decisions, §9) · v0.1 (same day, proposal) · **Owner:** Art · **Builder:** Systems Architect (+ Integration Engineer for sound) · **Status:** **DECIDED scope, docs only. Nothing built, nothing tested in Studio.** No template was added. **Launch build sheet for the Architect: `art/handoff/ATMOSPHERE-LAUNCH.md`.**
**Brief:** Master Controller, 4 Nov (Eudai wants a richer, more realistic, atmospheric look): items (a)–(g) below.
**Reads from:** `art/style-guide.md` (**v0.8: D1–D49**), `art/vfx/vfx-audio-plan.md` (v0.4), specs 01 v2.0, 02, 03 v2.0 (fog), 09, 10, `specs/store-art-brief.md`, `art/handoff/HODAG-ONBOARDING.md`, `art/vfx/templates/effects.json`, `art/tools/vfx_budget.py`.
**Companion files:** `art/vfx/atmosphere-events.md` (event atmosphere profiles + transitions) · `art/vfx/atmosphere-studio-capture-plan.md` (Studio captures) · concept frames in `art/vfx/concepts/`.
**Tags:** `[Dnn]` decided · `[SG]` style guide · `[Sxx]` spec · `[P]` my proposal · **`[VERIFY]`** check in Studio before relying on it. The v0.1 proposals **AP-1…AP-14** are now decided, folded or rejected: see §9.
**v0.2 also edited:** `style-guide.md` (v0.8, D41–D49), `vfx-audio-plan.md` (v0.7), `handoff/VFX-P0.md` (rev. 5), validator v4 (`validate_rbxmx.py` + `vfx_budget.py`, test `art/tools/test_validator_rules.py`).

---

## 0. One-paragraph pitch
Cold, desaturated **blue-grey moonlight** fills the gaps; **warm candle/lantern pools** (`#FFB36B`) are the only warm light; **knee-high fog** drifts through everything; **ash and dust motes** hang near the camera; **gold fireflies** blink at the edge of the woods. A catch becomes a held breath: the fog leans in, the candles gutter, the world goes quiet, then **tier-coloured smoke** curls up out of a chalk circle that **burns in** ember-hot and cools to chalk. All of it built-in, all of it inside the existing budgets, and the readability floor `[D1]` never moves down.

---

## 1. Scope by release (`[D49]`) with hours
Hours are rough estimates (not measured), same scale as vfx-audio-plan §7. "Art" = me (data, values, docs); "Code" = Architect / Integration Engineer; "Studio" = tuning in Play.

**Launch, in this build order, after the core build order** `[D49]`:
| # | Item | What ships | h |
|---|---|---|---|
| L1 | **(b) Lantern pools + night grade** | Lighting / CC / Bloom / Atmosphere `#282A30` `[D44]` values (§2.1–2.3); **one new light (the Pedlar Rift lantern, Town 24th; the pit light swaps an inner-ring lamp)**, otherwise retuned D2 candles + altar fill, gate exterior lantern (net 0), Town 24 of 24 incl. pit + Pedlar Rift lights (§2.4–2.5); far-plot light LOD; RiftDim + PointLight/particle glow at the Fissure, pit and Pedlar lantern `[D41] [D42]` (§2.7) | 3.5 (art 0.5 / code 1.5 / Studio 1.5) |
| L2 | **(d) Tier smoke** | `AshRise` recoloured per tier, built-in `smoke_main.dds` `[D46]` set at runtime, moved to the flash (§4). Same emitter, same counts | 1.5 (validator part done) → **1.0** |
| L3 | **(a) Ground fog (+ motes)** | Camera-local `AmbienceRig` (FogWisp + Mote; Firefly in the Wilds), D45 fog exception; **lair fog = one low-rate band, clear of pads, Fissure, spawn; off at Low** `[D47]`; tutorial-spawn clear zone (§3) | 2.5 + 1.5 (motes/fireflies) = **4** |
| L4 | **(e) Catch beat, if time allows** | Fog pull, candle gutter, duck, smoke burst, chalk burn-in (§5) | 3 |
| L5 | **Fog Night event** (the only launch event `[D49]`) | Profile + transition driver (`atmosphere-events.md` §1–§3) | ≈ 6 (driver 3.5 + Fog Night 1.5 + captures 1) |
| | **Launch total** | | **≈ 17.5 h** (≈ 14.5 h without L4) |

**Update 1** `[D49]`: Blood Moon (ships with its paid boost; 3 h), the **UI skin** (f) (§6; 5 h built-in), Rift Storm (3 h), Eclipse (2 h). **P1 (textures, Eudai's upload call `[D23]`):** custom wisp card (2 h), light shafts (2 h), firefly sprite (0.5 h), Legendary/Mythic gold embers (1 h, January `[D27]`), sigil scorch decal (1 h), parchment/leather textures (6 h), weather moods (8 h), custom skies (4 h).

**Capacity.** Freeze is **Fri 13 Nov**. Launch atmosphere ≈ 17.5 h on top of VFX P0 (≈ 16.5 h). If time runs short the catch beat (L4) drops first, as D49 already says.

---

## 2. Exact values (b): launch night grade `[D49]`
Values to **tune in Play** `[VERIFY]` inside the decided limits. Old style-guide v0.7 value in brackets.

### 2.1 `Lighting`
| Property | Value | (SG v0.7) | Check vs floor `[D1]` (per channel `[D43]`) |
|---|---|---|---|
| `Technology` | ShadowMap | (ShadowMap) | – |
| `ClockTime` | 0 | (0) | – |
| `Brightness` | **1.5** | (1.5) | = minimum ✓ |
| `Ambient` | **`(60, 62, 70)` `#3C3E46`** | (`(60,55,52)`) | every channel ≥ (60,55,52) ✓; luminance 62.2 vs 55.8 ✓ (brighter) |
| `OutdoorAmbient` | **`(95, 98, 108)` `#5F626C`** `[DECIDED D43]` | (`(95,88,82)`) | every channel ≥ (95,88,82) ✓ and ≥ hard floor (80,74,70) ✓; luminance 98.1 vs 89.1 ✓ |
| `ExposureCompensation` | **+0.3** | (+0.3) | ✓ (range 0.2–0.5 kept) |
| `ColorShift_Top` | **`(22, 24, 30)`** cool moon cast | (`(40,30,20)` warm) | warmth now comes from PointLights only |
| `ColorShift_Bottom` | `(0, 0, 0)` | (0,0,0) | – |
| `EnvironmentDiffuseScale` / `Specular` | 0.4 / 0.2 | (same) | – |
| `GlobalShadows` | true | (true) | – |
| Legacy fog | FogStart 250 / FogEnd 1100 / FogColor **`#282A30`** | (was `#1A1719`, superseded by D44) | fallback only `[D9]` |

**The blue-grey night tint:** **`#5F626C` (95, 98, 108)** `[D43]`, saturation ≈ 12%. Rules: **R ≤ G** always (keeps it off purple), **lighting and atmosphere only** (never a Part colour, UI colour or particle colour). It is a lighting value, not a palette token (AP-1, §9).

### 2.2 `Atmosphere` (D9 limits untouched)
| Property | Value | (SG v0.7) |
|---|---|---|
| `Density` | **0.18** (max, unchanged) | (0.18) |
| `Haze` | **0.3** (max, unchanged) | (0.3) |
| `Offset` | **0** | (spec 03: 0; SG §4 said 0.1 proposed → spec 03 wins) |
| `Glare` | 0 | (0) |
| `Color` | **`#282A30` (40, 42, 48)** `[DECIDED D44]` cool ash-grey, so far things fade to grey, not black (§2.6). **Verified by capture #2** | (was `#1A1719`, superseded by D44) |
| `Decay` | `#0B0A0C` | (`#0B0A0C`) |

### 2.3 Post-processing (launch night grade `[D49]`)
| Effect | Property | Value | (SG v0.7) |
|---|---|---|---|
| `ColorCorrectionEffect` "Grade" | Brightness | **+0.03** | (+0.03) |
| | Contrast | **+0.12** | (+0.10) |
| | Saturation | **−0.18** | (−0.15) |
| | TintColor | **`(240, 244, 250)` `#F0F4FA`** (very faint cool) | (`(255,242,224)` warm) |
| `BloomEffect` | Intensity / Size / Threshold | **0.45 / 28 / 1.5** (candle flames, LightEmission particles and the 2 Neon eye sets bloom; nothing else) | (0.4 / 24 / 1.6) |
| `SunRaysEffect` | Enabled | **false** (Intensity 0, Spread 1). At ClockTime 0 there's no sun, so SunRays can't make moon shafts `[VERIFY: assumption that SunRays track the sun only]`. If a dawn/menu scene ever uses it: Intensity 0.04, Spread 0.5 | (none in gameplay) |
| `DepthOfField`, `Blur` | – | **none** in gameplay (mobile cost, readability) | (none) |
| `VfxPulse` (separate CC used by reveals) | – | unchanged (vfx-audio-plan §2.2) | – |

"Dark gaps" come from the **contrast between the warm pools and the cool floor**, not from lowering Ambient. Contrast is capped at +0.12 so post-processing can't undo the D1 floor (conflict C3).

### 2.4 Warm pools: PointLights (within the 8-per-plot cap `[D39]`), launch `[D49]`
| Light | Colour | Range | Brightness | Shadows | Count |
|---|---|---|---|---|---|
| **Wall candle pool** (the D2 lit candles) | **`#FFB36B`** | **16** (was 12) | **1.4** (was 1.2) | false | ~7 (every third of ~22 candles `[D2]`, derived, `[VERIFY count]`) |
| **Altar fill** (SG §4 proposal) | `#FFB36B` | 40 → **32** | 0.8 → **0.7** | false | 1 |
| **Gate lantern pool (front)** | `#FFB36B` | 16 | 1.4 | false | **0 new**: the lit D2 candle nearest the Lair Gate is the pool |
| **Hodag tutorial lantern** (`HODAG-ONBOARDING.md`) | `#FFB36B` | 14 | 1.0 | false | **net 0**: on only during goal 3, the lit wall candle nearest the Wild Gate is off for that window (as proposed there) |
| Town lamps `[S03]` | `#FFB36B` | 14 | 1.0 → **1.2** | false | ≤ 24 (unchanged cap); 1 in 6 flickers (unchanged) |
| Reveal light `[D17]` | tier | per plan | per plan | false | catcher only, < 3 s (unchanged exception) |

- **Per-plot cap: stays 8** `[D39]`. The plot is already at (or one over) the cap with ~7 D2 lights + the altar fill, so **this pass adds no PointLights**. The pools come from a longer range and slightly higher brightness on lights that already exist; the cold ambient between them makes the pools read. The lantern colour stays the spec value `#FFB36B` (no new orange).
- **Range 16 keeps the "dark gaps":** lit candles are ~60 studs apart along the wall (every third of a 20-stud spacing), so 16-stud pools leave ~28 studs of cool, Nightfall-lit wall between them. The floor there never drops below D1.
- **Far-plot light LOD (client, launch):** other players' plots switch their PointLights off beyond **200 studs** from the camera, and their Glass flame parts stay visible (spec 02 "you can see the other lairs, their candles"). This keeps lights in view at roughly own 8 + ≤ 2 neighbour plots × 8 + town 24 ≤ ~48 `[VERIFY frame time]`. Without it, the worst case is 8 plots × 8 + 24 = 88 lights.

### 2.5 Town and lair-exterior lanterns (QA: "Town and lair exterior read near-black from the Town platform")
The Architect is adding warm lantern PointLights. Tuned launch values `[D49]` (all **`#FFB36B`**, **Shadows = false**, Parts + built-in materials, flame = Glass GoldBright, **no Neon**) `[VERIFY in Play]`:

| Lantern | Where (spec 02/03 geometry; positions derived) | Range | Brightness | Spacing → dark gap | Count |
|---|---|---|---|---|---|
| **Well fill** | over the Weeping Well (0, 9, 0) | 28 | 0.6 | – (soft centre pool) | 1 |
| **Inner-ring lamps** `[S03]` | iron posts every 18 studs on the inner ring; **light every other post** (D2-style) → lit every ~36 studs | 16 | 1.2 | pools 32 wide, ~4-stud cool gap between them: the path never goes black, the posts still read as separate pools | ≤ 12 (radius of the inner ring isn't specced; at r ≈ 40 there are ~14 posts → 7 lit; cap 12 `[VERIFY]`) |
| **Road-mouth lanterns** | one per road opening in the ruined wall, r ≈ 118, on the left post | 18 | 1.4 | 8 openings ~92 studs apart → wide dark gaps along the wall (that's the mood), lit mouths show the way out | 8 |
| **Live stall lanterns** | Pale Pedlar + Skill Shrine fronts | 14 | 1.2 | – | 2 (plus the Pedlar's separate Rift lantern light, §2.7) |
| **Lair-gate exterior lantern** (one per plot) | outer face of the Lair Gate pillar, plot-local (−9, 7, +61) | 16 | 1.4 | lights the gate approach and the banner from the road | **net 0 per plot**: it **replaces the lit D2 candle nearest the Lair Gate** (that candle keeps its Glass flame, loses its light). Stays inside the 8-per-plot cap |
| **Road lanterns (between town and lairs)** | optional, P1 | 16 | 1.2 | every 40 studs | 0 at launch (the Gold home beam `[S02]` + gate lanterns do the wayfinding) |

- **Town light budget: ≤ 24 PointLights** (unchanged cap): Well 1 + inner ring **≤ 11** (was 12: the lamp nearest the Great Rift pit gives its slot to the pit light) + road mouths 8 + live stalls 2 + **Great Rift pit 1** = **23**, **+ 1 Pedlar Rift lantern** `[D41]` = **24 of 24** (§2.7). The Tarot Table (January) needs a swap (net 0). Shuttered stalls: **no lights**. Flicker: 1 in 6 town lamps `[S03]`, dips ≥ 0.2 s.
- **Lights in view from the Town platform (worst case):** town ≤ 24 + 8 gate lanterns (inside plot caps) + other plots' D2 lights cut by the far-plot LOD (§2.4) `[VERIFY frame time]`.
- **Unclaimed lairs** keep **no lights** `[S02]` (gate lantern off too); the ambient floor keeps them dark, not invisible.

### 2.6 Does the baseline meet D1 at the Town platform?
- **On paper, yes.** `Ambient`/`OutdoorAmbient`/`Brightness`/`ExposureCompensation` are **global Lighting properties**, so the D1 floors hold everywhere, the Town platform included, with both today's values and the §2.1 values. Nothing local can push them lower.
- **But D1 alone doesn't make the far view readable.** Likely cause of QA's near-black read (**hypothesis, not verified on the box**): the lairs are **80–200 studs** from the Town edge `[S03]`, and at Density 0.18 the Atmosphere blends distant surfaces toward its **`Color` `#1A1719` (near-black)** and `Decay` `#0B0A0C`. So distant lair walls fade *into black* even though the ambient floor is met. Plus, the lair exterior walls (Basalt, Soot) face outward, away from every candle (candles light the inside of the walls).
- **Fix (no D9 limit touched):** (1) Atmosphere `Color` **`#282A30`** `[DECIDED D44]` (lighter cool grey) so distance fades to grey, silhouettes against a lighter backdrop; `Decay` stays `#0B0A0C` (sky top) `[VERIFY]`; (2) the **gate exterior lantern** per plot (net 0); (3) road-mouth lanterns; (4) the per-plot **Gold home beam** stays the "where's my lair" cue `[S03 test]`.
- **Pass/fail** is the Studio capture `ATMOS_TownPlatform_*` (capture plan #2). If it still fails: ExposureCompensation 0.3 → 0.4 (inside the 0.2–0.5 range) before anything else.

### 2.7 Rift green on Parts `[D38] [D41] [D42]`
- **No Neon** on the Rift Fissure belt, the Great Rift pit or the Pedlar lantern `[D41]`. Neon stays only on the Mothman and Dover Demon eyes `[D10] [D13]`.
- **Surfaces:** world trim = **RiftDim `#4F6B34`** in Slate or Metal; SmoothPlastic only for **thin strips** (≤ 0.3 studs; validator-enforced) `[D42]`. Trim stays thin, **≤ 10% of any surface**. RiftDim **doesn't count** toward the 2% bright-Rift cap `[D35] [D42]`.
- **Glow = PointLight + particles** `[D41]`, with tiny canonical **Rift `#7FA34A`** accents (sparks) that do count toward the 2%:

| Where | Glow light (PointLight, Shadows off) | Particles (`RiftSpark`-style, canonical Rift, LightEmission 0.6) | Light count |
|---|---|---|---|
| **Rift Fissure belt** (own plot, x = −50) | **none new**: the lit D2 wall candle nearest the belt mid-point (−59, 7, 0) swaps colour to `#7FA34A`, range 14, brightness 0.8 (net 0) `[P]` `[VERIFY it reads as Rift, not as a candle]` | Rate 2, Lifetime 1.5–2, size 0.12, along the belt (Box 2 × 0.5 × 80) → 4 alive | 0 new (cap 8 kept) |
| **Great Rift pit** (Town) | 1 × `#7FA34A`, range 20, brightness 0.8, at the pit floor | Rate 3, Lifetime 2, size 0.15, rising → 6 alive | 1 (takes one inner-ring lamp's slot, net 0) |
| **Pedlar lantern** (Town, inside the Town box) | **RiftDim surface** (cage panes RiftDim Slate, or SmoothPlastic if ≤ 0.3 thick `[D42]`) **+ 1 PointLight: range 10, brightness 0.8, Shadows off, `#7FA34A`**, inside the cage. The stall's own candle lantern (14 / 1.2) is separate and stays warm | Rate 1, Lifetime 2, size 0.08 inside the cage → 2 alive | **1 (the Town's 24th)** |

- **Town light budget:** Well 1 + inner ring ≤ 11 + road mouths 8 + live stalls 2 + pit 1 = 23, **+ Pedlar lantern 1 = 24 of 24** = the cap. The pit gets its slot from one inner-ring lamp (the one nearest the pit, which the pit's green pool replaces). The Tarot Table (January) then needs a swap (net 0).
- Rift sparks `[D20]` and UI pips keep `#7FA34A`. Every event profile (`atmosphere-events.md`) uses RiftDim for world trim.

---

## 3. Ambient emitters (a)(c): budgets and fallbacks
### 3.1 The rig
- **`AmbienceRig`** (client-only, created by code; P0 needs no template): one invisible anchored Part (CanCollide/CanTouch/CanQuery off), moved every frame to the camera's XZ at **ground height + 0.5**. It holds **3 ParticleEmitters**, `Shape = Box`, so the whole ambience costs **3 emitters per client**, wherever you are.
- **Zones** (by distance from the origin, spec 02/03): **Town** r ≤ 120 · **Lair** inside your own or any Threshold box · **Road** otherwise ≤ 330 · **Wilds** r > 330. The zone sets rates. Rate changes ramp over 2 s (never instant), so counts never spike.
- It replaces spec 03's "local fog wisp emitters at the town wall and past the Wild Gates": same mood, one rig.
- **Scripted spawn (clear zones, `[D47]`, spec 12 G2):** the FogWisp emitter's own `Rate` stays **0**. The rig spawns wisps itself at the zone rate: each spawn picks a random point in the 80 × 80 box around the camera and **skips it** (no retry, no burst) if it is **within 6 studs of any pad centre** (all 12 pads of every plot in range) or **within 12 studs of the tutorial Hodag spawn** (plot-local (0,0,−80)) until that player's Hodag is caught. Otherwise it moves a spawn `Attachment` there and calls `:Emit(1)`. One particle per call at the ramped rate, so there are never bursts (`atmosphere-events.md` §2.3). Cost: one distance check per pad within 46 studs of the camera, a few times a second.
- **Lair rate** `[D47]`: **1.0** at High/Medium in every profile, Fog Night included (spec 12 §5.1, G3); **0 on Low**. Lair wisps max size **6** (radius 3) and Speed 0.1–0.3, so a wisp spawned at 6 studs stays off the cryptid (footprint ≤ 8 × 8, half-width 4).
- **Naming for the validator** `[D45]`: the fog emitter is named **`FogWisp`** and carries the attribute **`AmbientFog = true`** (bool). Only it may live > 2 s (≤ 8 s, Rate ≤ 2).

### 3.2 Emitter settings
| Emitter | Box (studs) | Rate (zone) | Lifetime | Size NS | Transparency NS | Colour | Speed / motion | LightEmission | Texture |
|---|---|---|---|---|---|---|---|---|---|
| **FogWisp** (rig) | 80 × 1 × 80 | Town 1.5 · **Lair 1.0** (size ≤ 6) · Road 1.5 · Wilds 2.0 (script rate, emitter `Rate` 0) | **6–8 s** (fog exception `[D45]`) | 0:6, 0.5:9, 1:10 | 0:1, 0.2:0.86, 0.8:0.88, 1:1 (fades in and out, never pops) | Ash `#1A1719` → Soot `#2A2427` (lit by the scene) | Speed 0.2–0.5, Drag 0.5, `WindAffectsDrift` true (`Workspace.GlobalWind` (2, 0, 1) `[P]`), RotSpeed ±8 | 0 | `smoke_main.dds` built-in **[VERIFY]** |
| **Mote** (ash/dust) | 40 × 14 × 40 | Town 8 · Lair 6 · Road 4 · Wilds 5 | 1.6–2.0 | 0:0.06, 1:0.04 | 0:1, 0.3:0.4, 0.7:0.5, 1:1 | BoneDim `#A79F90` → Ash | Speed 0.1–0.3, Accel (0, −0.15, 0), WindAffectsDrift | 0 | class default (sparkle reads as a speck at 0.05 size `[VERIFY]`) |
| **Firefly** | 60 × 6 × 60, only when the camera is within 40 studs of a `WoodsEdge`-tagged area (or anywhere in the Wilds if untagged) | Wilds 4, else 0 | 1.8–2.0 | 0:0.14, 1:0.10 | 0:1, 0.25:0.1, 0.55:0.9, 0.75:0.2, 1:1 (two slow blinks per life, < 3/s `[S01 A5]`) | **GoldBright `#C9A55A`** (not green: Rift stays rare) | Speed 0.3–0.6, Drag 1, RotSpeed 0, Accel (0, 0.1, 0) | **1** | class default |

### 3.3 Budgets (alive ≈ Rate × max Lifetime)
| Zone | FogWisp | Mote | Firefly | **Ambience alive** |
|---|---|---|---|---|
| Lair | 1.0 × 8 = 8 | 6 × 2 = 12 | 0 | **20** |
| Town | 1.5 × 8 = 12 | 8 × 2 = 16 | 0 | **28** |
| Road | 1.5 × 8 = 12 | 4 × 2 = 8 | 0 | **20** |
| Wilds | 2.0 × 8 = 16 | 5 × 2 = 10 | 4 × 2 = 8 | **34** |
| **Cap** | ≤ 16 | ≤ 16 | ≤ 8 | **≤ 40**, counted in the 200 world budget `[D45]` |

- **World total check `[SG §6]` ≤ 200:** own-plot auras 80 + ambience 20 = 100 normally; **during a reveal** auras 40 + reveal 120 + ambience halved (≤ 20) = **180** ✓. In the Wilds no auras show (own plot only `[D19]`), so 34 + 120 = 154 ✓.
- **Overdraw** (big transparent sprites are the real mobile cost): FogWisp size ≤ 10, transparency ≥ 0.86, ≤ 16 alive. Frame-time check in the capture plan.

### 3.4 Clear zones (fog never hides what you must read)
- **Hodag tutorial spawn:** no FogWisp particles within **12 studs of plot-local (0, 0, −80)** (the derived spawn, `HODAG-ONBOARDING.md`) for the owner, from goal 2 done until the Hodag is bound. Implementation: the scripted spawn (§3.1) skips any point within 12 studs of it until the Hodag is caught; wisps already alive drift and fade naturally (no pop). Kept during Fog Night. `[VERIFY the real spawn CFrame]`
- **Pads** `[D47]`, spec 12 G2: **6-stud clear radius** around every pad centre (scripted-spawn skip, §3.1), High/Medium only (lair wisps are off on Low). **Caveat:** the Pad model is **10.5 studs wide** (half-width 5.25, measured from `Pad.parts.json`), so 6 studs keeps wisps off the cryptid but **not off the pad rim**. Spec 12 QA test 11 ("no wisp sprite over any occupied pad") needs **≈ 9 studs** (5.25 + wisp radius 3 + drift). Ship 6 as ruled; if capture #3 shows sprites on pads, raise it to 9 (one constant). `[VERIFY]`
- **Every wild spawn (launch rule):** wisps never spawn on a creature: the rig's FogWisp rate drops to 50% while a wild creature is within 20 studs of the camera, so outlines stay readable.

### 3.5 Low quality and Reduced Motion
| Setting | FogWisp | Mote | Firefly | Other |
|---|---|---|---|---|
| **High** (default) | as §3.2 | as §3.2 | as §3.2 | Bloom on |
| **Low** (`settings.effectsQuality` Low / Auto below level 4, plan §1.6) | Town/Road/Wilds Rate ×0.5, max size 6; **Lair 0 (off)** `[D47]` | Rate ×0.5 | **off** | Bloom off; far-plot light LOD at 120 studs |
| **Reduced Motion** `[S01 A5]` | Speed ×0.5, no catch-beat pull-in (§5) | Rate ×0.5 | Rate ×0.5, Speed 0 (blink only, no wander) | colour/lighting values unchanged (they aren't motion) |

---

## 4. Per-tier smoke (d): launch L2 `[D49]`
- **Mechanism:** the reveal already fires `VFX_Emit_AshRise :Emit(6/10/16/24)` in phase A. **P0 change:** move that emit to the flash (phase C), set its colour per tier, switch its texture to built-in `smoke_main.dds` (the one allowlisted texture `[D46]`; **set at runtime** so the template keeps no Content property and still builds on Rojo 7.4.4), and lengthen the curl. **Same emitter, same counts**, so `[D14]` totals are unchanged (Epic 5 emitters / ~102 particles; Epic+Rift 6 / ~106).
- **Smoke curve (all tiers):** Lifetime 1.6–2.0 · Speed 1–2 · SpreadAngle 25 · Accel (0, 1.2, 0) · Drag 1.5 · Rotation 0–360 · RotSpeed ±30 · Size NS 0:0.8, 0.4:2.2, 1:3.5 (grows) · **Transparency NS 0:1, 0.12:0.55, 0.6:0.7, 1:1** (fades in over ~0.2 s, never pops; fades out, never cuts) · WindAffectsDrift true · LightEmission 0 (Epic 0.15).

| Tier | Smoke ColorSequence | `:Emit` | Notes |
|---|---|---|---|
| Common | BoneDim `#A79F90` → Ash `#1A1719` ("ash grey") | 6 | |
| Uncommon | Moss `#5E7A4A` → Ash | 10 | |
| Rare | Silver `#8C9AA3` → BoneDim ("silver mist") | 16 | |
| Epic | Blood `#7A0F12` → BloodHover `#94171B` → Ash ("blood red") | 24 | + existing EmberRise/GoldLeaf |
| Legendary / Mythic (January `[D27]`) | GoldBright `#C9A55A` → Gold `#9C7A3C` → Ash, plus EmberRise Gold ("gold embers") | 24 | P1, Gold per `[D28]` |

- Rift-source reveals keep 2–4 Rift sparks `[D20]`; the smoke is never green.

---

## 5. Catch beat timeline (e), mapped to P0 templates: launch L4, **if time allows** `[D49]`
Shown for **Epic (3.5 s total)**, with phases A/B/hit-stop/C/D from vfx-audio-plan §2.2. Other tiers scale the same steps to their phase lengths (Common has no candles and no hit-stop). **Wild catches:** steps 1–3 run during the 3 s hold-to-bind; the rest starts when the server confirms.

| # | t (s) | Phase | Beat | How (existing P0 piece) |
|---|---|---|---|---|
| 1 | 0.00 | A | **Sound ducks** | SoundGroups (plan §6.6): Ambience ×0.6, Music ×0.4 over 0.3 s Sine Out. Common/Uncommon: ×0.8 only |
| 2 | 0.00–1.20 | A | **Fog pulls inward** | `AmbienceRig.FogWisp` (ambience budget, not the effect's): continuous Rate → 0; a second attachment at the circle centre emits from `Shape = Cylinder` r 10, **`ShapeInOut = Inward`**, Speed 2–3, `:Emit(6)` (Common 3). Net ambience alive stays ≤ 12. RM: skipped |
| 3 | 0.00–1.20 | A | **Chalk circle draws** | `VFX_Reveal_Circle_<Tier>` segments Transparency 1→0 in name order (unchanged); candles `VFX_Reveal_Candle` ×7 lean in and ignite; lead candle `VFX_Emit_CandleFlame` |
| 4 | 0.60–1.40 | A→B | **Candles gutter** | Up to **3** of the plot's lit D2 candle PointLights within 40 studs (no new lights): Brightness 1.4 → 0.8 → 1.3 → 0.9 → 1.4, two dips over 0.8 s (2.5 dips/s, under the 3/s rule); reveal candle `FlameTop` flicker (plan §2.3). Outside a lair (Wilds): reveal candles only. RM: one 0.15 s dip |
| 5 | 1.20–2.40 | B | Materialise | Unchanged (silhouette from the Highlight pool of 2, heartbeats) |
| 6 | 2.40–2.55 | hit-stop | – | Unchanged |
| 7 | 2.55–2.80 | C | **Coloured smoke burst** + flash | `VFX_Emit_AshRise` as tier smoke `:Emit(24)` (§4) + `VFX_Emit_RevealBurst :Emit(36)` + `VFX_Emit_GoldLeaf` (Epic) |
| 8 | 2.55–3.15 | C→D | **Chalk circle burns in** | Runtime tween on the circle parts: Color candle `#FFB36B` → tier colour (Epic seal Blood → BloodHover, outer ring Gold) over 0.6 s Quad Out; reveal PointLight `[D17]` peaks here. RM: instant colour, 0.15 s fade |
| 9 | 2.80–3.50 | D | Smoke curls up and fades | Smoke lives 1.6–2.0 s, so it trails ~1.5 s past D without blocking play; `VFX_Emit_EmberRise :Emit(15)`; name card |
| 10 | 3.50–4.50 | after D | **Fog and sound return** | FogWisp Rate ramps back over 1.0 s Linear; duck releases over 0.8 s Sine Out; circle fades 0.4 s (plan §2.3) |

Budget per effect: **unchanged** (no new emitter, no new light, no Neon). The fog pull and gutter come out of the ambience and plot budgets, which already exist. In a lair the fog pull uses the rig's pull attachment (skipped on Low, where lair wisps are off). **During an atmosphere event** this local beat is unchanged; only the server-wide Epic moment changes (contrast + Bloom, no sky tint `[D48]`, vfx-audio-plan §4).

---

## 6. UI skin (f): what built-in UI can do before textures: **Update 1** `[D49]`, not launch
| Element | Built-in recipe (P0) | Looks like the concept? | Needs a texture (P1) |
|---|---|---|---|
| **Parchment card / tooltip** | Frame Bone `#E8E0CF`; `UIGradient` Bone → BoneDim (Rotation 90, plus Transparency NS 0:0, 0.85:0, 1:0.15 for an aged bottom edge); `UICorner` 2 px; `UIStroke` Gold 1 px at 40%; **Void text** (S04 tooltip rule); Merriweather body, Garamond headers | **~70%**: clean, aged tone, no grain | paper grain, stains, **ragged/torn edges** (9-slice) |
| **Leather frame / panel** | Outer Frame Soot `#2A2427` + `UIGradient` Soot → Ash (Rotation 45); inner inset Frame 6 px smaller with `UIStroke` Gold 1 px at 40% (the "tooled line"); `UICorner` 4 px (SG §5) | ~60% | leather grain, **stitching** (doable as Frames but ~40 instances per panel → not worth it) |
| **Ink-stamp button** | Blood fill; `UIStroke` BloodHover 2 px; Rotation −1.5° (hand-stamped); text Bone, GrenzeGotisch for 1–2 word labels / Merriweather otherwise; press = scale 0.96 + UIStroke 2 → 4 px ("ink spreads") in **0.12 s** (plan §5 seal press). RM: colour swap only | ~65% | rough ink edge, ink bleed |
| **Wax seal on cases** | 76 px circle (`UICorner` 1, 0) Blood + `UIStroke` BloodHover 3 px + `UIGradient` Blood → Void (Void stop at 30% transparency) for the rim shade, palette only; Gold sigil from 3–5 rotated thin Frames | ~60% | real wax texture, embossed sigil |
| **Wax-seal crack** (case open) | Reuse the `VFX_Pad_Deny` idea in UI: 3–4 thin Void Frames (2 px) appear one by one (0.08 s apart), then the seal splits: two half Frames with `ClipsDescendants`, each holding a copy of the seal, tween apart ±10 px and rotate ±12° over 0.35 s Back In, fading out; 6 UI ember ImageLabels inside the 60 UI-particle cap. RM: crack lines appear, seal fades 0.15 s | ~75% | crumbling wax fragments |
- **Fonts:** stays the SG §5 four (GrenzeGotisch, Garamond, Merriweather, Oswald). `Enum.Font.Fondamento` (calligraphic) would suit ink labels; it's a **proposal only** `[VERIFY it exists and renders]` (AP-8).
- **Where:** parchment for cards, tooltips, tarot readings and the case screen; leather for outer frames. The HUD (cash plaque, buttons) stays as is (Ash + Gold). Everything still works with flat colours `[S01 A4]`.
- **Overall:** about **65–70% of the concept look** is reachable with built-in UI. Grain, torn edges and real wax need P1 textures (Eudai's upload call `[D23]`).

---

## 7. Conflicts (v0.1 list) and how they were settled
**v0.2 status:** **C2 → D43** (fallback (95,98,108), per-channel floor kept) · **C4 / C26 → D44** (`#282A30`, verify in capture #2) · **C5 → D47** (lair fog, low rate, clear zones, off at Low; spec 03 wording is the Strategist's) · **C6 / C7 → D45** (≤ 8 s fog only, counted in the budget) · **C13 → D46** (exactly one texture allowlisted; validator v4 done) · **C16 → D49** (UI skin is Update 1) · **C22 → D41** (no Neon on belt, pit, lantern: PointLight + particles; Strategist edits specs 01/02) · **C23 / C24 → D42** (SmoothPlastic thin RiftDim strips only; RiftDim added to both validator palettes) · **C21 → D49** (launch order; catch beat if time allows). **Still open:** C1 (cool tint as a lighting-only value: folded, no token, AP-1), C15 light shafts (P1), C17 frame time (capture plan §4), C19/C20 (captures #1, concepts stay concepts).

| # | Item | Conflicts with | Resolution proposed in v0.1 (see status above) |
|---|---|---|---|
| **C1** | Cold blue-grey night (b) | SG "Never: saturated blue"; vfx plan "No purple, no blue"; §7 checklist #1 | Blue-grey is **desaturated** (15%) and **lighting/atmosphere only**. Add a lighting-only token **Nightfall `#5C606C`** with rules R ≤ G and saturation ≤ 15%; never on Parts, UI or particles (AP-1). Needs Master Controller OK |
| **C2** | OutdoorAmbient `(92,96,108)` | D1 "OutdoorAmbient (95,88,82)" (red channel 92 < 95) | It's **brighter overall** (luminance 96 vs 89) and above the hard floor (80,74,70) on every channel. Reword D1 as "luminance ≥ the D1 value **and** every channel ≥ the hard floor" (AP-2). Fallback if refused: OutdoorAmbient `(95, 98, 108)` meets both readings |
| **C3** | "Dark gaps between pools" | D1 readability floor | Gaps come from **pool contrast**, never from lowering Ambient. CC Contrast capped at +0.12. Readability tests §4 SG on the dim-phone check |
| **C4** | Atmosphere Color `#282A30` | D9 / spec 03 v1.2 fixes `#1A1719` (Eudai's values) | Density and Haze **unchanged** (0.18 / 0.3). Colour change needs the Growth Strategist's spec 03 edit + Master Controller OK. Fallback: keep `#1A1719` (the cool look then comes only from ambient + CC) |
| **C5** | Ground fog on lair plots (a) | Spec 03: "Mood comes only from low fog wisps at the town wall and past the Wild Gates" | Camera-local wisps everywhere, with the **lowest rate in lairs** and clear zones (§3.4). Needs a spec 03 wording change |
| **C6** | FogWisp Lifetime 6–8 s | SG §6 "Rate ≤ 10/s, Lifetime ≤ 2 s" per continuous emitter | Exception for **ambient fog only**: Lifetime ≤ 8, Rate ≤ 2, ≤ 16 alive, size ≤ 10 (AP-5) |
| **C7** | Ambience 40 alive | vfx plan §1.2 "ambience ≤ 20" | Recomputed: during a reveal ambience halves to ≤ 20, so the 200 world cap still holds (180) |
| **C8** | Lantern pools (b) | ≤ 8 PointLights per plot; plot already ~8 (`HODAG-ONBOARDING.md`) | **No new lights.** Retune existing D2 lights (range 16 / brightness 1.4); altar fill trimmed to 32 / 0.7. The Hodag lantern stays **net 0** (swaps with the Wild Gate candle during goal 3). Far-plot light LOD (AP-4). **No cap raise requested** |
| **C9** | D2 "every third candle" | – | Kept. Pools reuse the D2 lights |
| **C10** | Catch-beat gutter + reveal light | D17 one reveal light < 3 s | Gutter **dims existing lights**; no extra light. D17 unchanged |
| **C11** | Smoke on catches (d) | D14 ≤ 6 emitters / 120 | Reuses `AshRise` (same counts). Fog pull uses the ambience rig. Epic+Rift stays 6 / ~106 |
| **C12** | Ambience rig | D19 auras own plot only | Not an aura: one per client, around the camera. No conflict |
| **C13** | Smoke/fog texture `smoke_main.dds` | D23 (custom textures P1); validator rejects any non-default Content | It's a **built-in client texture, not an upload**, so D23 isn't touched. The validator needs an **allowlist of `rbxasset://textures/particles/*`** (AP-6). If refused: fog → P1 (the default sparkle texture won't read as fog) |
| **C14** | Fireflies (c) | Rift green ≤ 2% | Fireflies are **GoldBright**, not green |
| **C15** | Light shafts (Eudai's brief) | SG §4 "No SunRays in gameplay"; no sun at night | P1 (textured Beam shafts). Not in P0 |
| **C16** | Parchment panels (f) | SG §5 "Panel: Ash fill" | Parchment for cards/tooltips/readings only (S04 already uses Bone parchment for tooltips); panels keep Ash/leather. AP-7 |
| **C17** | Mobile budget | Overdraw from big fog sprites; light count | Size/transparency caps (§3.4), Low quality halves fog, far-plot LOD; **frame-time check** in the capture plan (pass: ≤ +2 ms vs before) |
| **C18** | Neon | allowlist (D10/D13) | None added |
| **C19** | Hodag first catch (~0:33) | Fog + cold grade could hide a Soot-bodied creature | Clear zone at plot-local (0,0,−80) (§3.4); Hodag lantern net 0; **capture #1 in the Studio plan** |
| **C20** | Concept frames | Spec details | The catch-beat image shows **8 candles and an 8-point star** (spec: Epic 7 candles, 7-point {7/3} seal); the UI image shows **textured parchment (P1 look)**; the Wilds image shows a non-roster silhouette and a held lantern. **Concepts only**, never store art (store art must be real Studio captures `[D12]`) |
| **C21** | Freeze capacity | Fri 13 Nov | Cut order in §1 |
| **C22** | **D38 RiftDim, no Neon on Rift trim** | SG §2 + spec 02 §3: "the **only Neon** in a lair is the Rift Fissure trim"; spec 03: Rift glow at the Great Rift pit and Pedlar lantern; D3 onboarding seal | D38 supersedes: Fissure trim, pit edge and lantern become RiftDim Parts; "glow" there (if wanted) = a few `RiftSpark` particles in canonical Rift. Spec 02/03 wording needs the Growth Strategist's edit |
| **C23** | D38 allows **SmoothPlastic** | SG §2 "No SmoothPlastic or Plastic on visible surfaces" (toy-like) | Allow SmoothPlastic **only** for thin RiftDim trim strips (≤ 0.3 studs wide); prefer Slate/Metal. Needs to be written as an exception in AP-13 |
| **C24** | RiftDim `#4F6B34` | Palette tokens (§1); validators' palette sets (`vfx_budget.py` PAL) | Add RiftDim as a token (world trim only); the validators need it added to their allowed colours, or Rift trim models fail the palette check |
| **C25** | Town lanterns | Town ≤ 24 lights | Proposed allocation ≤ 23 (§2.5); gate lanterns count against plot caps, net 0 |
| **C26** | Atmosphere Color lighter (`#282A30`) | spec 03 / D9 colour `#1A1719` | Same as C4; this is the main proposed fix for the near-black far read, so it's worth the spec edit |

---

## 8. Studio checks needed
See `art/vfx/atmosphere-studio-capture-plan.md`. **NEXT, when the Architect's L1–L3 build lands:** **#1 Hodag readability at the tutorial spawn** and **#2 Town platform before/after** (also verifies D44). Then #3 dark-bodied cryptids on pads (+ D47 lair-fog clearances), then #4–#10, event captures E1–E6 and the low-end frame-time check.

## 9. AP proposals → decisions (v0.2)
All of these are now in `style-guide.md` v0.8 where decided. **DECIDED** = an explicit ruling · **FOLDED** = covered by a ruling's scope (values tunable in Play) · **DEFERRED** · **REJECTED**.
| # | Proposal (v0.1) | Outcome |
|---|---|---|
| **AP-1** | Nightfall `#5C606C` palette token | **REJECTED as a token, FOLDED as a value:** D43 sets OutdoorAmbient `(95,98,108)`; it's a lighting value (R ≤ G, lighting only), not a §1 token |
| **AP-2** | D1 read as luminance + hard floor; OutdoorAmbient (92,96,108) | **REJECTED (luminance reading) → DECIDED D43:** fallback `(95,98,108)`; the hard per-channel floor stays. Ambient `(60,62,70)` and ColorShift_Top `(22,24,30)` pass per channel → FOLDED into the D49 night grade |
| **AP-3** | Candle pools 16 / 1.4, altar 32 / 0.7, town lamps 1.2, cap 8 | **FOLDED into D49** (lantern pools ship first) and `[D39]` (cap 8) |
| **AP-4** | Far-plot light LOD 200 studs (Low 120) | **FOLDED into D49** (part of the lantern pools; in SG §6) |
| **AP-5** | Fog exception, ambience ≤ 40 | **DECIDED D45:** fog only, ≤ 8 s, low rate (≤ 2/s), counted in the particle budget |
| **AP-6** | Allow `rbxasset://textures/particles/*` | **DECIDED D46, narrowed:** exactly **one** id, `smoke_main.dds`; any other texture fails. Validator v4 + test done |
| **AP-7** | Parchment / leather / ink-stamp / wax-seal UI skin | **DEFERRED to Update 1** `[D49]` (§6 recipes kept) |
| **AP-8** | Test `Enum.Font.Fondamento` | **DEFERRED** with the UI skin (Update 1); still a proposal |
| **AP-9** | CC +0.12 / −0.18 / (240,244,250); Bloom 0.45 / 28 / 1.5; SunRays off | **FOLDED into D49** (the launch night grade; in SG §4) |
| **AP-10** | Atmosphere Color `#282A30` | **DECIDED D44** (Strategist edits spec 03; verify in capture #2) |
| **AP-11** | Tutorial-spawn clear zone; fog halves near wild creatures | **DECIDED D47** (plus pad / Fissure / spawn clearances in lairs, §3.4) |
| **AP-12** | Event profiles in `atmosphere-events.md` | **DECIDED D49 (scope):** Fog Night only at launch; Blood Moon, Rift Storm, Eclipse → Update 1. Epic moment in events = contrast + Bloom only `[D48]` |
| **AP-13** | D38 RiftDim (then "proposed") | **DECIDED D38 + D41 + D42** (no Neon on belt/pit/lantern; RiftDim not in the 2% cap; SmoothPlastic thin strips only; validator palettes updated) |
| **AP-14** | Town lights ≤ 24, gate lantern net 0 | **FOLDED into D49** (lantern pools); with the pit light (swapped for one inner-ring lamp) and the Pedlar lantern light `[D41]` the Town is at **24 of 24** (§2.5, §2.7) |

## 10. Concept frames (CONCEPT ONLY, not in-game, not Studio proof, never store art)
AI-generated mock-ups (GenerateImage), stamped on the image. They show mood, not exact geometry.
- `art/vfx/concepts/ATMOS_concept_lair-night_2026-11-04.png`: lair plot at night, lantern pools, ground fog
- `art/vfx/concepts/ATMOS_concept_wilds-hunt_2026-11-04.png`: Wilds hunt, gold fireflies, motes, town lamps far off
- `art/vfx/concepts/ATMOS_concept_catch-beat-epic_2026-11-04.png`: Epic catch, blood-red smoke, burning chalk circle (see C20 for deviations)
- `art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png`: parchment/leather panel, ink-stamp buttons, wax seal (the crack isn't shown; textured look = P1)
