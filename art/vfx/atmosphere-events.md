# Project Cryptid: Event Atmosphere Profiles + Transitions

**Version:** v0.2 (Wed 4 Nov 2026) · **Owner:** Art · **Builder:** Systems Architect (client driver) · Integration Engineer (sound beds, Roblox-licensed only `[D31]`) · **Status:** docs only. Nothing built, nothing tested in Studio. No template added (the profiles reuse the `AmbienceRig` from `atmosphere-pass.md` §3).
**Aligned with spec 12 v1.0** (`specs/12-world-events.md`, Growth Strategist): timings **omen 45 s / crossfade 30 s / return 45 s**; lengths **Fog Night 5:00**, Blood Moon 10:00 (Update 1); **Fog Night is the only launch event** `[D49]`. The spec 12 §5 diff is §7 below.
**Reads from:** `atmosphere-pass.md` v0.2, style guide **v0.8** (D1, D9, D14, D23, D28, D31, D38, **D41–D49**), spec 03 (fog), spec 10 (Mythic sky), spec 12 v1.0, vfx-audio-plan §4.
**Tags:** `[P]` proposal · `[VERIFY]` check in Studio · **LAUNCH** / **Update 1** / **DRAFT** scope marks.
**v0.2 changes:** D43 baseline OutdoorAmbient (95,98,108); D45 fog rate ≤ 2/s; G3 lair wisps 1.0 (0 on Low); G2 clear zones; G5 no `#1A1719` as fog colour; D48 Epic during events; D49 scope (Fog Night only at launch); captures E1–E3 for launch; G1 drafts for **The Tolling** and **Witch-Lights** (§1.8).

---

## 0. Rules every profile keeps
1. **Readability floor (D1, hard per channel, `[D43]`):** `Ambient` every channel ≥ (60,55,52); `OutdoorAmbient` every channel ≥ (80,74,70); Brightness ≥ 1.5; Exposure 0.2–0.5. Luminance is shown for information only. **Every profile below passes**, so no per-event floor exception is requested.
2. **Fog limits (D9):** Atmosphere Density ≤ 0.18, Haze ≤ 0.3 **in every profile**. "More fog" comes from the camera-local `FogWisp` emitter and the Atmosphere **colour**, never from Density/Haze (see conflict E1 for the alternative).
3. **Palette:** reds keep **G ≥ B** (never magenta/purple); cool tints keep **R ≤ G** (never purple). Blood Moon = Blood crimson. Rift green: canonical `#7FA34A` only on small accents (particles/UI) and ≤ 2% of a view; world trim = **RiftDim `#4F6B34`**, never Neon, no Bloom catch (`[D38] [D41] [D42]`). The only exception is the Mythic sky (spec 10, free sources only `[D26]`), and that sky is **Gold** under `[D28]`.
4. **Sky:** P0 uses the **built-in `Sky`** only (default textures; numeric properties `StarCount`, `MoonAngularSize`, `SunAngularSize`, `CelestialBodiesShown`). Any custom skybox, moon or sun texture is a **P1 upload (Eudai's call `[D23]`)**.
5. **Light caps unchanged:** 8 per plot, 24 in Town; events change existing light colours/brightness, never add lights (the Town is at 24 of 24, `atmosphere-pass.md` §2.5).
6. **Sound:** beds are described by mood only. The Integration Engineer picks **Roblox-licensed** IDs and logs them in `art/vfx/audio-licences.md` `[D31]`.
7. **Server owns the event; clients only render it.** Nothing waits on VFX.

---

## 1. Profiles (exact values, all `[VERIFY in Play]`)
### 1.1 Lighting
| Property | **Baseline** (atmosphere pass) | **Fog Night** (LAUNCH) | **Blood Moon** (Update 1) | **Rift Storm** (Update 1) | **Eclipse** (Update 1) |
|---|---|---|---|---|---|
| `ClockTime` | 0 | 0 | 0 | 0 | 0 (P0 fallback, see §1.3) |
| `Brightness` | 1.5 | 1.5 | 1.6 | 1.5 | 1.5 |
| `Ambient` | `(60,62,70)` #3C3E46 | `(62,64,70)` #3E4046 | `(80,56,54)` #503836 | `(60,63,58)` #3C3F3A | `(66,60,54)` #423C36 |
| – luminance (info) | 62.2 ✓ | 64.0 ✓ | 61.0 ✓ | 62.0 ✓ | 60.8 ✓ |
| `OutdoorAmbient` | **`(95,98,108)` #5F626C** `[D43]` | `(98,100,108)` #62646C | `(112,88,84)` #705854 | `(94,100,92)` #5E645C | `(100,92,84)` #645C54 |
| – luminance (info) | 98.1 ✓ | 100.2 ✓ | 92.8 ✓ | 98.1 ✓ | 93.1 ✓ |
| `ExposureCompensation` | +0.3 | +0.35 | +0.3 | +0.3 | +0.35 |
| `ColorShift_Top` | `(22,24,30)` | `(18,19,22)` | `(44,14,12)` | `(20,26,18)` | `(40,30,16)` |
| PointLights (existing ones) | `#FFB36B` | `#FFB36B`, Bloom halo bigger | `#FFB36B` (warm stays warm against the red) | `#FFB36B`; 1 in 4 town lamps flicker | `#FFB36B` brightness ×1.15 |

### 1.2 Atmosphere (Density / Haze capped by D9)
| Property | Baseline | Fog Night | Blood Moon | Rift Storm | Eclipse |
|---|---|---|---|---|---|
| `Density` | 0.18 | 0.18 | 0.18 | 0.18 | 0.16 |
| `Haze` | 0.3 | 0.3 | 0.25 | 0.3 | 0.2 |
| `Offset` / `Glare` | 0 / 0 | 0 / 0 | 0 / 0 | 0 / 0 | 0 / 0 |
| `Color` | `#282A30` | **`#34363C`** (pale cold grey: the "fog") | **`#3A2222`** (dried-blood haze) | `#2A3026` (sick grey-green, low sat) | `#30281E` (bruised amber) |
| `Decay` | `#0B0A0C` | **`#282A30`** (G5: was `#1A1719`) | `#1A0B0C` | `#0B0A0C` | `#0B0A0C` |

### 1.3 Sky (built-in only at P0)
| Property | Baseline | Fog Night | Blood Moon | Rift Storm | Eclipse |
|---|---|---|---|---|---|
| Textures | default | default | default (moon can't be tinted without an upload `[VERIFY]`; red comes from CC + Atmosphere) | default | default |
| `StarCount` | 300 `[S03 faint]` | 0 | 150 | 0 | 0 |
| `MoonAngularSize` | 11 | 11 | **18** (big moon) | 11 | 11 |
| `CelestialBodiesShown` | true | **false at peak fog** (§2.3) | true | false at peak | false (P0); **P1:** custom sun-and-corona Sky upload at ClockTime 12 |
| P1 upload | – | – | blood-red moon texture | storm-cloud skybox | eclipse skybox |

### 1.4 ColorCorrection ("Grade") and Bloom
| | Baseline | Fog Night | Blood Moon | Rift Storm | Eclipse |
|---|---|---|---|---|---|
| CC Brightness | +0.03 | +0.04 | +0.02 | +0.03 | +0.03 |
| CC Contrast | +0.12 | +0.06 (flatter, foggy) | +0.12 | +0.14 | +0.16 |
| CC Saturation | −0.18 | −0.25 | −0.08 | −0.20 | −0.25 |
| CC TintColor | `(240,244,250)` | `(236,238,242)` | **`(255,226,218)`** (G ≥ B; the Epic moment adds no tint during events `[D48]`) | `(242,248,238)` | `(255,240,220)` |
| Bloom Intensity / Size / Threshold | 0.45 / 28 / 1.5 | 0.55 / 36 / 1.4 (lantern halos in fog) | 0.5 / 28 / 1.5 | 0.45 / 28 / 1.5 | 0.6 / 40 / 1.3 |
| Flashes | none | none | none | **lightning:** CC Brightness +0.12 for 0.10 s, ≤ 1 per 8 s, never twice within 1 s (< 3/s rule); off in RM and Low | none |

### 1.5 Ambience rig (`atmosphere-pass.md` §3), per event
Rates are for the zone the camera is in (script spawn rate, `atmosphere-pass.md` §3.1); alive = Rate × max Lifetime. **Event cap: ≤ 48 alive, 3 emitters** (`AmbienceRig` only; see §3 for low-end). **FogWisp Rate ≤ 2/s and Lifetime ≤ 8 s in every profile** `[D45]`; **lair rate 1.0 max, 0 on Low** (`[D47]`, spec 12 G3).
| | Baseline | Fog Night | Blood Moon | Rift Storm | Eclipse |
|---|---|---|---|---|---|
| **FogWisp** Rate (Lair / Town / Wilds) × Life 8 | 1.0 / 1.5 / 2.0 → ≤ 16 | **1.0 / 2.0 / 2.0** → ≤ 16 (Town/Wilds size **8–10**, transparency ≥ 0.84; lair size ≤ 6). The extra fog comes from bigger, paler wisps + `#34363C`, not rate `[D45]` | 1.0 / 1.5 / 2.0 → ≤ 16 | **1.0 / 2.0 / 2.0** → ≤ 16 | 0.5 / 1.0 / 1.0 → ≤ 8 |
| FogWisp colour | Ash → Soot | Soot → BoneDim at 0.9 transp. (pale) | Soot → Blood (`#2A2427` → `#7A0F12`) | Soot → RiftDim `#4F6B34` | Ash → Gold `#9C7A3C` |
| **Mote** (Rate × 2) | ≤ 16 ash/dust | ≤ 12 (wet dust, slower) | ≤ 16, **embers**: BloodHover → GoldBright, LightEmission 0.5 | ≤ 16 ash + **`RiftSpark`-style specks: max 4 alive, canonical Rift** (≤ 2% of view) | ≤ 12 GoldBright specks, LE 0.3 |
| **Firefly** (Wilds) | ≤ 8 GoldBright | 0 (gone in fog) | 0 (hiding) | 0 | 0 |
| **Total alive (worst zone)** | ≤ 34 | ≤ 28 | ≤ 32 | ≤ 36 | ≤ 20 |
| Clear zones (`[D47]`, G2) | yes | **yes**: no wisp spawns within **6 studs of any pad centre**, or within **12 studs of the tutorial Hodag spawn** (0,0,−80) until the Hodag is caught | yes | yes | yes |

### 1.6 World trim and accents
| | Baseline | Fog Night | Blood Moon | Rift Storm | Eclipse |
|---|---|---|---|---|---|
| Rift world trim (D38) | RiftDim Parts | RiftDim | RiftDim | RiftDim (no brightening, no Neon) | RiftDim |
| Rift canonical accents | sparks/UI only | same | same | ≤ 4 specks + reveal sparks; ≤ 2% of view | same |

### 1.7 Ambient sound bed (mood only; IDs by the Integration Engineer `[D31]`)
| Profile | Bed | Volume (Ambience group) | Notes |
|---|---|---|---|
| Baseline | wind, crows, distant bell every 60 s `[S03]`, light night birds | 0.5 | |
| Fog Night | muffled low wind, dripping, far-off foghorn-like low bell every ~45 s, no birds | 0.45 | high-shelf feel by choosing muffled sounds (no EQ effects needed) |
| Blood Moon | low droning hum, slow distant drum (~every 8 s, never in sync with reveal heartbeats), distant choir murmur, no birds | 0.5 | ducks under reveals as normal |
| Rift Storm | gusting wind, distant thunder rolls (paired with lightning, sound ≥ 0.4 s after), electric crackle | 0.55 | |
| Eclipse | near silence: one long low tone, sparse wind | 0.35 | silence is the effect |
| **Omen sting** (all events) | a single distant bell (Fog Night, Eclipse), a low horn (Blood Moon), thunder roll (Rift Storm); Tolling and Witch-Lights per §1.8 | SFX_World 0.4 | once per omen |

### 1.8 Update 1 drafts: The Tolling and Witch-Lights (spec 12 G1) — **Update 1 / DRAFT**
Uncommon events, 4:00 each (spec 12 §2.1). Same table format as §1.1–1.7. Not tuned, not in the launch build. All values pass rule 1 (per-channel floor) and rule 3 (cool tints R ≤ G).
| Property | **The Tolling** (Update 1 / DRAFT) | **Witch-Lights** (Update 1 / DRAFT) |
|---|---|---|
| Mood | still, cold dusk; a bell no one rings; the Rift belt quickens | pale lights drifting at the Wilds edge; quiet, watchful |
| `Brightness` / `ExposureCompensation` | 1.5 / +0.3 | 1.5 / +0.3 |
| `Ambient` | `(60,62,68)` (lum 62.1) | `(60,62,68)` (lum 62.1) |
| `OutdoorAmbient` | `(95,97,104)` (lum 97.2) | `(95,98,106)` (lum 98.0) |
| `ColorShift_Top` | `(20,22,28)` | `(22,24,28)` |
| Atmosphere Density / Haze / Color / Decay | 0.18 / 0.3 / **`#2C2E34`** / `#0B0A0C` | 0.18 / 0.28 / **`#2A2C30`** / `#0B0A0C` |
| Sky StarCount / Moon / CelestialBodiesShown | 100 / 11 / true | 200 / 11 / true |
| CC Brightness / Contrast / Saturation / Tint | +0.03 / +0.14 / −0.22 / `(238,242,248)` | +0.03 / +0.12 / −0.20 / `(240,242,246)` |
| Bloom Intensity / Size / Threshold | 0.45 / 28 / 1.5 | 0.5 / 32 / 1.45 (soft halos on the lights) |
| FogWisp Lair / Town / Wilds | 1.0 / 1.5 / 2.0 (Low: 0 / 0.75 / 1.0) | 1.0 / 1.5 / 2.0 (Low: 0 / 0.75 / 1.0) |
| Mote | ≤ 16 ash, falling slower (Speed ×0.7) | ≤ 12 ash |
| Signature effect | **Toll pulse:** on each bell toll (every 12 s), CC Contrast +0.03 for 0.4 s, Sine; no flash, no shake; off in RM and Low | **Witch-lights:** the Firefly emitter recoloured **Bone `#E8E0CF` → Silver `#8C9AA3`**, LightEmission 0.5, Size 0.3, Speed 0.3 (slow wander), Wilds only, **≤ 8 alive** (replaces fireflies, so net 0 particles); **no PointLights**; Low ≤ 4; RM Speed 0 |
| Rift | RiftDim trim; belt `RiftSpark` rate unchanged (the spawn speed-up is gameplay, not VFX) | RiftDim only; no canonical Rift |
| Sound bed | low wind, one deep bell toll every 12 s (counted, never in sync with reveal heartbeats), no birds / 0.45 | near-silent wind, faint high chimes, distant frogs / 0.4 |
| Omen sting | a single deep toll | a soft rising chime |
| Total alive (worst zone, High) | ≤ 32 | ≤ 36 |
| Open | `[VERIFY]` toll pulse not read as a flash | `[VERIFY]` lights don't read as cryptid eyes or loot; colour stays off canonical Rift |

---

## 2. Transition system
### 2.1 State machine (server-owned, client-rendered)
```
BASELINE ──(spec 12 §3 director)──► OMEN (45 s; range 30–60) ──► CROSSFADE_IN (30 s; range 20–45)
   ▲                                                                                     │
   │                                                                                     ▼
   └── RETURN (45 s; range 30–60) ◄── (event ends) ◄──────── EVENT (Fog Night 5:00; Blood Moon 10:00, Update 1; spec 12 §2.1)
Any state ──(admin abort / server shutdown)──► RETURN (from the current blend, never a snap)
```
- **Replicated state** (e.g. attributes on `ReplicatedStorage.WorldEvent`): `EventId`, `Phase`, `PhaseStart` (from `workspace:GetServerTimeNow()`), `PhaseLength`, `FromProfile`, `ToProfile`. Clients compute `alpha = clamp((now − PhaseStart) / PhaseLength)` and blend; no client timers decide anything.
- **One driver:** a single client module blends **profile tables** (`Lerp(From, To, ease(alpha))` per property) on **Heartbeat at 10 Hz** (High) / **5 Hz** (Low) for Lighting/Atmosphere/CC/Bloom. Using one lerp instead of many `TweenService` tweens makes join-mid-event and abort trivial. Colours lerp in RGB (all endpoints are low-saturation, so no hue swing through purple; reds keep G ≥ B at both ends) `[P]`.
- One event at a time. **During an event the Epic server moment adds only Contrast +0.06 and Bloom +0.1 (4 s), never a sky tint or Atmosphere change** `[D48]` (vfx-audio-plan §4).

### 2.2 Timings, easing and order
**OMEN (45 s, spec 12 §4):**
| t (fraction of omen) | What | Easing |
|---|---|---|
| 0.00 | **Omen sting** (one sound, §1.7) | – |
| 0.00 → 0.60 | Baseline bed: **birds and wind fade out** (volume → 0.2×) | Sine Out |
| 0.10 → 1.00 | **Subtle colour drift:** Atmosphere Color and CC Tint move **15%** of the way to the event | Linear |
| 0.30 → 1.00 | FogWisp/Mote rates move 25% toward the event (Fog Night: fog creeps in) | Linear |
| whole omen | Fireflies ramp out (Rate → 0; live ones finish their life) | Linear |

**CROSSFADE_IN (30 s, spec 12 §4):** each group blends over its own window inside the crossfade, in this **order** (cover first, then colour, then glow):
| Order | Window (fraction of crossfade) | Properties | Easing |
|---|---|---|---|
| 1 | 0.00 → 0.50 | Atmosphere `Color`, `Decay`, `Haze`/`Density` (only downward changes, Eclipse); FogWisp rate → event; FogWisp colour | Sine InOut |
| 2 | 0.20 → 0.75 | `Ambient`, `OutdoorAmbient`, `ColorShift_Top`, `ExposureCompensation`, `Brightness` | Sine InOut |
| 3 | 0.30 → 0.80 | CC Tint / Saturation / Contrast / Brightness | Sine InOut |
| 4 | **0.50** (peak fog) | **Sky booleans** (`CelestialBodiesShown`), any texture swap (P1). Masked by a 1.2 s CC soften (Saturation −0.10, Contrast −0.06 extra, Quad InOut, then back). **Never darkens below the floor** | – |
| 4b | 0.20 → 0.90 | Sky numerics: `StarCount`, `MoonAngularSize` | Sine InOut |
| 5 | 0.60 → 1.00 | Bloom Intensity/Size/Threshold; Mote colour/rate; PointLight brightness factor | Quad Out |
| 6 | 0.40 → 1.00 | Event sound bed fades in (0 → target) | Sine In |

**EVENT:** hold the profile. Fog Night "breathing": FogWisp ±20% over 60 s, Sine, **capped at Rate 2.0** `[D45]`; off in RM. Rift Storm lightning per §1.4.

**RETURN (45 s, spec 12 §4):** the same groups in reverse order (5 → 1), each over the mirrored window, **Sine InOut**; sky booleans flip back at 0.5 while fog is still high; baseline bed fades in over the last 60%, birds last (0.7 → 1.0). Fireflies come back last (Rate ramps over 10 s after the return ends).

### 2.3 Emitter ramps (no particle spikes, ever)
- Rates change **only through the driver**, linearly, max **±0.5 Rate per second** per emitter; **no bursts**: the only `:Emit()` is the FogWisp scripted spawn, **1 particle per call** at the ramped rate (`atmosphere-pass.md` §3.1).
- Because alive = Rate × Lifetime, a ramp between profiles can never overshoot the higher profile's cap.
- Colour changes apply to **new** particles; existing ones finish their life (`[VERIFY whether changing ParticleEmitter.Color re-colours live particles; if it does, the lerp is already gradual]`).
- During a catch reveal, ambience halves as in `atmosphere-pass.md` §3.3, on top of the event profile.

### 2.4 Reduced Motion, Low quality, join mid-event
| Case | Behaviour |
|---|---|
| **Reduced Motion** `[S01 A5]` | Colour/lighting crossfades still run (they're slow colour changes, not motion). **No lightning flashes**, no sky-boolean soften pulse (swap at peak fog anyway), FogWisp Speed ×0.5, fireflies stay off, no Fog Night "breathing". Sounds unchanged |
| **Low quality** | Driver at 5 Hz; **Bloom off** (Bloom steps skipped); **lair FogWisp 0 (off)** `[D47]`, Town/Road/Wilds FogWisp ×0.5 and size ≤ 6; Motes ×0.5; fireflies off; sky soften pulse skipped; lightning off (thunder sound kept) |
| **Join mid-event** | During loading (before the loading screen is removed), the client reads `Phase`/`PhaseStart`, computes `alpha` for that phase and **applies the blended profile instantly** (no tween), sets emitter Rates directly (particle counts start from 0, so no spike), starts the event bed at target volume with a 2 s fade-in, and skips the omen sting. Join during OMEN or a crossfade = snap to the current blend, then continue the timeline from there |
| **Leave during event** | nothing to clean up server-side; client state dies with the session |

---

## 3. Per-event budgets for a low-end phone (Low quality)
| Profile | Emitters (ambience) | Alive particles (ambience, Low) | Bloom | Lightning | Driver |
|---|---|---|---|---|---|
| Baseline | 3 (fireflies off → 2 active) | ≤ 13 | off | – | 5 Hz |
| **Fog Night (LAUNCH)** | 2 active | **≤ 14** (fog 1.0 × 8 = 8 at size ≤ 6, lair 0; motes ≤ 6) | off | – | 5 Hz |
| Blood Moon (U1) | 2 active | ≤ 16 | off | – | 5 Hz |
| Rift Storm (U1) | 2 active | ≤ 18 (incl. ≤ 2 Rift specks) | off | off | 5 Hz |
| Eclipse (U1) | 2 active | ≤ 10 | off | – | 5 Hz |
- **World check:** worst Low case during a reveal = auras 40 (own plot, already halved) + reveal 120 + ambience ≤ 9 = **169 ≤ 200**.
- **Frame-time target:** a crossfade adds **≤ 1 ms** per frame vs the held profile on low-end mobile (the 10/5 Hz driver sets ~25 properties per tick) `[VERIFY]`. Capture plan **E3**.

---

## 4. Scope and hours `[D49]`
Rough estimates, not measured. Spec 12 §14 holds the full launch cut (≈ 19 h incl. director and UI).
| Item | Scope | Hours |
|---|---|---|
| Baseline + **Fog Night** profile tables as data | **LAUNCH** | 1 (art) |
| Client event driver: state read, 10/5 Hz blend, ordered windows, emitter ramps, RM/Low, join-mid-event snap | **LAUNCH** | 4 (code, spec 12 §14) |
| Sky boolean swap at peak + CC soften mask | **LAUNCH** | 0.5 |
| Fog Night tuning in Studio, clear zones (G2) + Low lair-off (G3) | **LAUNCH** | 1.5 + 1 |
| Fog Night bed + bell sting (find, log under D31, wire) | **LAUNCH** | 0.5 (Integration Engineer) |
| Studio captures **E1–E3** (Fog Night) | **LAUNCH** | 1 |
| **Launch total (art/VFX side)** | | **≈ 9.5 h** |
| Blood Moon profile + tuning (ships with its paid boost) | **Update 1** `[D49]` | 1.5 |
| Rift Storm profile + lightning + storm bed | **Update 1** | 3 |
| Eclipse profile (P0-style fallback) | **Update 1** | 2 |
| The Tolling, Witch-Lights (§1.8 drafts → tuned) | **Update 1** | 2 |
| Custom skies: blood moon texture, storm skybox, eclipse sky (uploads = Eudai's call `[D23]`) | **P1** | 4 (art 3 / code 1) |
| Rain for Rift Storm / weather moods | **P1** (`atmosphere-pass.md` (g)) | in the 8 h there |

---

## 5. Conflicts
| # | Item | Conflicts with | Proposed resolution |
|---|---|---|---|
| **E1** | "Fog Night" usually means thicker fog (still open; no ruling asked) | D9 / spec 03: Density ≤ 0.18, Haze ≤ 0.3 over plots and Town | Profile stays inside D9: the fog is the **paler Atmosphere colour** (`#34363C`) + more/larger wisps. **Alternative needing a decision:** an event-only exception (Density 0.22, Haze 0.45) with Exposure +0.4 and a QA readability pass; I don't recommend it for launch |
| **E2** | Spec 12 missing | everything timing-related | **RESOLVED:** spec 12 v1.0 landed; timings 45/30/45, Fog Night 5:00 (§7 diff) |
| **E3** | Blood Moon red light | SG "Never Blood text on Void" etc. are about UI; lighting red tint isn't covered | Lighting-only reds, G ≥ B, luminance ≥ floor; UI untouched. Needs a line in AP-1 (lighting tints) |
| **E4** | Epic sky tint (vfx plan §4) during an event | The Epic tint would hide or fight the event sky | **DECIDED D48:** during an event the Epic moment adds only Contrast +0.06 and Bloom +0.1 for 4 s; no tint, no Atmosphere change. vfx-audio-plan §4 updated (v0.7) |
| **E5** | Mythic sky (spec 10 v1.2 "Mythic sky on every free source", Rift-coloured in spec 10) | D28 Mythic = Gold; D26 / spec 10 free sources only | Mythic sky is Gold and overrides any event profile for its duration, then hands back to the event's blend. Flagged before in the vfx plan (spec 10's Rift Mythic frame/sky) |
| **E6** | Rift Storm sparks | Rift ≤ 2% of a view | Max 4 canonical-Rift specks alive, trim RiftDim (D38), Atmosphere only faintly green (sat ≤ 21%) |
| **E7** | D38 removes the Fissure Neon | SG §2 / spec 02 §3 "only Neon in the plot" | **DECIDED D41:** no Neon on the belt, pit or Pedlar lantern; glow = PointLight + particles over RiftDim |
| **E8** | Lightning flashes | `[S01 A5]` no flashing > 3/s; D15 shake 0 | ≤ 1 per 8 s, 0.10 s, no shake, off in RM and Low |
| **E9** | Omen fades out birds | spec 03 ambient bed (wind, bell, crows) | Only during events; the baseline bed comes back in RETURN |
| **E10** | Sky boolean swap | "never snap the skybox" | Swap only at peak fog (crossfade 0.5) under the CC soften; P0 never swaps textures. `[VERIFY it isn't noticeable]`; fallback: keep `CelestialBodiesShown` true |
| **E11** | Freeze capacity | Fri 13 Nov | **DECIDED D49:** launch = Fog Night only (≈ 9.5 h art/VFX side); Blood Moon, Rift Storm, Eclipse, Tolling, Witch-Lights are Update 1. The baseline ships either way |

## 6. Studio captures
In `art/vfx/atmosphere-studio-capture-plan.md` §3, numbered as spec 12 §14:
- **LAUNCH, E1–E3 (Fog Night):** E1 Fog Night sequence (before / omen / peak / return, Atmosphere Color `#282A30` → `#34363C` → `#282A30`); E2 clear zones + readability under Fog Night (Hodag at the tutorial spawn, pads with cryptids, 30% phone brightness); E3 low-end crossfade frame-time + join mid-event.
- **Update 1:** E4 Blood Moon sequence; E5 Epic moment during Blood Moon (`[D48]`: contrast + Bloom only); E6 Tolling / Witch-Lights / Rift Storm / Eclipse peaks.

## 7. Spec 12 §5 vs this file §1 (diff, 4 Nov)
Everything else in spec 12 §5 matches §1 (Brightness, Ambient, Exposure, ColorShift, Density/Haze, Color `#282A30` → `#34363C`, sky, CC, Bloom, beds, stings, Blood Moon / Eclipse wisp rates).
| # | Spec 12 says | This file (v0.2) | Why | Who changes |
|---|---|---|---|---|
| M1 | Baseline OutdoorAmbient (92,96,108) | **(95,98,108)** | D43 | Strategist (spec 12 §5) |
| M2 | Fog Night Town / Wilds FogWisp 2.5 / 3.0 ("AD"), §5.1 | **2.0 / 2.0** (bigger, paler wisps instead) | D45: fog rate ≤ 2/s | Strategist (§5, §5.1) |
| M3 | Low: Town 1.25 / Wilds 1.5 (§5.1, QA test 12) | **1.0 / 1.0** | M2 × 0.5 | Strategist (§5.1, §18 #12) |
| M4 | Fog Night Atmosphere.Decay `#1A1719` | **`#282A30`** | G5: no `#1A1719` as a fog colour | Strategist (§5) |
| M5 | Rift Storm FogWisp 1.5 / 2.0 / 2.5 (U1) | **1.0 / 2.0 / 2.0** | D45 + lair 1.0 max | Strategist (§5) |
| M6 | §4 layer order: "Epic reveal tint (additive during events)" | Contrast + Bloom only, **no tint** | D48 (spec §15 #11 already says this) | Strategist (§4 wording) |
| M7 | §5.1 tutorial zone: "rate-0 window per atmosphere-pass §3.4" | **scripted-spawn skip** within 12 studs until the Hodag is caught | G2 method | Strategist (§5.1 wording) |
| M8 | §5.1 / QA #11: "no wisp sprite over any occupied pad" at 6 studs | 6 studs keeps wisps off the cryptid, **not the pad rim** (pad half-width 5.25) | geometry | QA #11 should read "no wisp over a pad's cryptid"; or raise the radius to 9 after capture E2 |
| M9 | §5 / §16 G1: "no AD profile" for Tolling / Witch-Lights | drafts in §1.8 | G1 | Strategist (§5 note) |
