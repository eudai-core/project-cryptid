# Project Cryptid: VFX, Motion & Audio-Feel Plan (the "dopamine pass")

**Version:** v0.7 (Wed 4 Nov 2026: `[D41]` `[D45]` `[D46]` `[D48]`, goal-3 tease copy) · v0.6 ( `[D38]` RiftDim, `[D39]` lantern approved, `[D40]` goal-3 pips) · v0.5 (`[D34]` `[D35]` `[D37]`, D26/D29 amended; v0.4 onboarding `[D33]` + gift banners `[D36]`; v0.3/v0.2 same day) · **Owner:** Art · **Builder:** Systems Architect · **Status:** P0 templates built box-side (`art/vfx/templates/`, see `art/handoff/VFX-P0.md`); **nothing tested in Studio yet**
**Reads from:** `art/style-guide.md` v0.7 (D1–D40), **spec 01 v2.0** (onboarding B3), **spec 10 v1.1** (Tarot readings + Fate Reel), **spec 09 v2.1**, **"Project Cryptid: Feel & Wow Design Bible"** canvas (read 4 Nov via ReadCanvas), `art/roster-provisional.md`, specs 01–09, `specs/store-art-brief.md`.
**Tags:** `[Sxx]` = from that spec · `[SG]` = style guide · `[Dnn]` = decided (style-guide log) · `[BIBLE]` = from the design bible (a proposal there unless it says spec fact) · `[P]` = my proposal · **`[VERIFY]`** = verify in Studio before relying on it.
**No asset IDs appear in this file.** Sounds are chosen by the Integration Engineer and logged in `art/vfx/audio-licences.md`. Custom textures are P1 `[D23]`.
**Mock-ups:** the bible's concept images contain made-up labels; **no label or text in them is spec**.

**Goal:** Sol's RNG-level "wow" at the moment of binding a cryptid, but it should feel like a **binding rite**, not a slot machine: chalk sigil draws itself → candles lean in → shadow → one flash of bone/gold → the creature stands there, breathing ash. Rarity is shown by **drama, not colour spam** `[BIBLE]`. Mobile-safe.

---

## Changes in v0.7 (from v0.6)
1. `[D45]` fog-only exception row in §1.2. `[D41]` §1.5. `[D46]` §2.4: one allowlisted texture. `[D48]` §4: during events the Epic moment is Contrast + Bloom only. §2.7 tease text: Bone, final copy.

## Changes in v0.6 (from v0.5)
1. **`[D38]`**: canonical Rift is for small accents (particles, UI) only; world trim on Parts = **RiftDim `#4F6B34`**, Slate/Metal/SmoothPlastic, never Neon, no Bloom catch (§0). VFX already uses Rift only on particles (`RiftSpark`) and UI, so **no template change**.
2. **`[D39]`**: plot light cap stays 8; the Hodag lantern is **approved** (lit during goal 3 only, nearest Wild Gate wall candle off) — §2.7.
3. **`[D40]`**: goal 3's dark rarity silhouettes **cut for launch** → 3 tier-colour pips + text tease, built-in UI only; **pip spec added in §2.7**; §11.11 **CLOSED**. Silhouettes → P1.

## Changes in v0.5 (from v0.4)
1. **"Bought" = bought with Robux** (D26/D29 amended): Rift belt and expedition catches are **free sources** (they can announce and can trigger the Mythic sky); personal Robux purchases never announce. §0, §2.2, §2.6, §2.7, §4 updated.
2. **`[D34]`** Mythic = GoldBright + Bone flare + distinct frame shape + thin Rift core; Legendary plain GoldBright (§2.6 R2/R7, tier table).
3. **`[D35]`** Rift ≤ 2% of the screen everywhere; Mythic sky ≤ 5%, free sources only, lighting floor kept (§0, §4, R14).
4. **`[D37]`** tarot pulls earn-only; paid readings = fixed bundles shown before purchase. Paid guard kept as a safety net; paid-reel-only work marked **DORMANT** (R4/R5/R9 paid parts, reel tick row). Server Luck pending Eudai.
5. §11 items 1, 2, 3, 4 and 6 **CLOSED**; item 5 mostly closed (Server Luck pending Eudai); §10 item 1 re-decided.
6. Docs only: no template, budget or tool changed.

## Changes in v0.4 (from v0.3)
1. **Onboarding re-order** (spec 01 v2.0, `[D33]`): new **§2.7 onboarding beats**. The **first catch reveal is now the Hodag (Common) at ~0:33**, and the **first pad carve + bind for a caught cryptid is the Hodag on Pad 3 at ~0:45**; the Hidebehind moves to goal 7 (~1:56, Pad 4). §3 readability note puts the Hodag first.
2. **`[D36]`** gift thank-you banners: §11.5 updated (partly resolved).
3. New §11.11: spec 01 v2.0 goal 3 "3 dark rarity silhouettes" preview needs a no-texture build `[D23]`.
4. No template changed; no budget changed.

## Changes in v0.3 (from v0.2)
1. **Master Controller rulings logged as D27–D32** (style guide v0.4); §10 items 1–6 marked **DECIDED**.
2. **Reel = January P1, not launch** `[D27]`. §2.6 rewritten against **spec 10 v1.1**: the full reel/charge-up work and its P1 needs list moved to §7 P1; **no P0 budget** for it. P0 keeps only the guards: tier-colour table, paid-purchase guard (no banner / sky tint / near-miss), settle at the true tier. v0.2's `ReelEase` constant and `reel_tick`/`reel_settle` pair are **removed from P0** (spec 10 §3.2/§3.4 now define them, P1).
3. **Wording from spec 09 v2:** the reel is honest; honest near-misses happen on **free pulls only**; **no visual may imply a higher tier than the one rolled** (§0, §1.1). "Wild catches" removed from the near-miss allowance (they have no reel).
4. **Banners** `[D29]`: nothing bought announces, including Rift belt Epics; **wild-caught Epics still announce** (§2.2, §4).
5. New §11: conflicts between spec 10 / spec 09 v2 and D14–D32, budgets or house rules.
6. Note added (§7 P1): a **"richer realism" brief** is coming from a separate task. Nothing built here.
7. **No template changed** (spec 10 needs no P0 template); validator, budget check and Rojo round-trip re-run; preview sheet unchanged.

## Changes in v0.2 (from v0.1)
1. **Decisions D14–D26 logged** (style guide v0.3) and the matching open questions closed (§9). D8/D21 updated: Highlight limit reportedly 255, **unverified**; pool of 2 kept; no-Highlight fallback optional.
2. **Reveal lengths aligned to the bible ladder:** Common/Uncommon/Rare/Epic **0.6 / 1.0 / 2.0 / 3.5 s** (was 1.5 / 2.5 / 3.5 / 5.0). Name card holds 1.2 s after, without blocking play.
3. **Hit-stop added** (bible): Rare 0.1 s, Epic 0.15 s, off in Reduced Motion.
4. **Rare = three rings** drawing (bible); Epic = three rings + Gold outer ring + rune band + 7-point seal. Common = one ring "snaps shut"; Uncommon = ring + moss rune band.
5. **Skip rule:** any reveal of a species you have seen before can be tapped away at any time; first-of-species reveals play in full (bible, Sol's RNG-style). Replaces v0.1's "skip after N s".
6. **Wild catches:** phase A runs **during the 3 s hold-to-bind**, one ring per third of the hold, heartbeat speeding up; fail = rings crack and fizzle, 1 s grace (bible §1). New §2.5.
7. **Vignette tints:** Rare = Silver-tinted edges; Epic = **screen to black** then blood-moon edges (bible), UI only, ≤ 1.2 s at full dark.
8. **Epic sounds:** **3 heartbeats** (was 2), deep bell, choir; Uncommon adds a **low bell**; Rare adds a **breathy choir swell**; Common = chalk scratch + match strike (bible).
9. **Candle flames are Part-based**; only the **lead candle** gets the `CandleFlame` emitter, so the Epic reveal stays at ≤ 6 emitters `[D14]`. Epic peak recomputed: **≈ 102 particles (106 with Rift sparks)** (was 116).
10. **Ritual circle is Part-based** (thin chalk Parts, transient), not SurfaceGui/Beam: per the build brief and `[D23]`. The bible's "flat decals or a Beam, not parts" conflicts, see §10.
11. **Auras:** particle glow via `LightEmission`, **never Neon** (ruling); counts aligned to the bible **3 / 6 / 8 / 24** alive per cryptid; own plot only `[D19]`; per-plot cap raised 60 → **80**, halved during a reveal.
12. **Epic server moment:** sky tint lengthened to **4 s** and turned **off in Reduced Motion** (bible); the sigil-in-the-clouds and the 10 s lair pillar are **P1** (texture / if time).
13. **Nothing bought ever triggers a server banner** (ruling): paid tarot readings are buyer-only; Rift belt buys are flagged (§10, conflicts with spec 08 wording).
14. **Collect/pads:** one shared, moved emitter for bursts (bible); bowl pitch steps up for quick repeats, resets after 2 s; place-cryptid glow **0.5 s** (was 0.3); purchase seal press **0.12 s** (was 0.25); can't afford = **dull wood knock**.
15. **Sound sourcing:** free, Roblox-licensed audio only, chosen by the **Integration Engineer**, logged in `art/vfx/audio-licences.md` (§6.5 now points there). Settings keys `settings.sfx`, `settings.music`, `settings.effectsQuality` added to the save table by the Architect.
16. **Case-opening reels (D24–D26):** new §2.6 with the reel rules and the cheap P0 items.
17. **Legendary/Mythic colour = Gold** `[D24]` (the bible had Mythic = Rift; superseded).
18. Template names/attributes now match the build: `VFX_Version` + `Notes` on every template (README updated).

---

## 0. Ground rules (specs and decisions win over this plan)
| Rule | Source | Effect on this plan |
|---|---|---|
| **No true screen shake.** No flashing faster than 3×/s | `[S01 A5] [SG §5] [D15]` | Shake = **0** at every tier. Escalation uses **FOV zoom punch**, vignette punch, hit-stop and light. Max **1 flash per sequence** |
| Reduced Motion: no slide/scale/float, fades ≤ 0.15 s | `[S01 A5]` | Every effect has a Reduced Motion row; no hit-stop, no zoom punch, no sky tint; sound still plays `[BIBLE]` |
| Lighting floors (Ambient ≥ (60,55,52), OutdoorAmbient ≥ (80,74,70), Density ≤ 0.18, Haze ≤ 0.3) | `[SG §4] [S03] [D1, D9]` | Pulses only **brighten/tint**. Darkening = **UI vignette only** |
| Neon only on the allow-list | `[SG §2] [D10] [D13]` | **VFX adds zero Neon.** Glow = `LightEmission` on particles/Beams + 1 transient light `[D17]`. Neon stays only on Mothman and Dover Demon eyes; **Rift Fissure trim is now RiftDim, non-Neon** `[D38]` |
| Rift green ≤ 2% of the screen, everywhere | `[SG §1] [D20] [D35] [D38]` | Canonical Rift only on small accents: 2–4 sparks on Rift-source reveals, UI. World trim on Parts = RiftDim, never Neon `[D38]`. Only exception: the Mythic sky ≤ 5%, free sources only, lighting floor kept `[D35]` |
| Cash purchases show the cryptid before paying | `[S09 §8] [D16]` | The silhouette is a **materialise** beat. Nothing paid gets a mystery reveal |
| **Nothing bought with Robux triggers a server banner** | `[D29 amended] [D36]`; `[S09 §5.5]` | "Bought" = Robux. Cash is earned, so **Rift belt and expedition Epics announce** like wild-caught ones `[S08]`. Readings play for the reader only. Personal Robux purchases never announce; server-wide gift thank-yous may name the buyer, no price or buy link `[D36]` |
| **No visual may imply a higher tier than the one rolled** | `[S09 v2] [S10]` (Eudai) | Charge-up / glow / colour never above the true tier; near-miss emphasis only on free reels and never on a card |
| Reels (January P1) | `[D25] [D27] [D37] [S10 §3]` | Honest strip; tarot pulls are **earn-only** `[D37]`, so honest near-miss emphasis applies to every reel pull. Paid-pull rules (fixed slow-down, no emphasis) are **DORMANT unless a paid random path returns** (§2.6) |
| Highlight limit unverified | `[D8] [D21]` | Pool of 2; optional no-Highlight fallback |

---

## 1. Principles & mobile budgets

### 1.1 Principles
1. **Ritual over fireworks.** Draw, ignite, hush, then **one** decisive flash. Higher rarity = longer build-up, more sound layers, more people who see it `[BIBLE]`.
2. **Readable first.** The creature is clearly visible by the end. Particles never sit on the body > 0.5 s.
3. **Palette only** `[D24]`: Void, Ash, Soot, Bone, BoneDim, Blood, BloodHover, Gold, GoldBright, candle `#FFB36B` (lights/particles only), Moss (Uncommon), Silver (Rare). Rift only per §0. **No purple, no blue.**
4. **Honest by design** `[BIBLE] [S10]`: the server decides the result before any animation, and **no visual may imply a higher tier than the one rolled**. The only near-miss emphasis is spec 10's honest one on **free** reels (true neighbours, marker only, never on a card) `[D27]`.
5. **Client-only, server-trusted.** Nothing waits on VFX; skipping changes nothing in game state.
6. **One sequence at a time per client.**
7. **Sigil shapes are invented** (angular runes, 7-point {7/3} seal, concentric rings). No pentagrams or inverted crosses `[P]`.

### 1.2 Particle budgets
Alive ≈ `Rate × max Lifetime` (continuous) + `:Emit(n)` (burst). Checked box-side by `validate_rbxmx.py --effects`.
| Scope | Cap | Source |
|---|---|---|
| Per continuous emitter | Rate ≤ **10/s**, Lifetime ≤ **2 s** | `[SG §6]` |
| Ambient fog only (`FogWisp`, `AmbientFog = true`) | Lifetime ≤ **8 s**, Rate ≤ **2/s**, counted in ambience ≤ 20 (40 cap, halved in reveals) | `[D45]` |
| Per model (cryptid / pad / altar) | ≤ **2 emitters** | `[SG §6]` |
| **Per transient effect** | ≤ **6 emitters**, ≤ **120 alive** | `[D14]` |
| Idle auras, own plot | ≤ **80 alive**; halved during a reveal | `[P]`, `[D19]` |
| World particles on screen | ≤ **200** = auras 80 (40 during a reveal) + reveal 120 + ambience ≤ 20 (during a reveal: 40+120+20 = 180) | `[SG §6]` |
| UI particles | ≤ **60** on screen | `[S04 §5.4]` |

### 1.3 Beams, Trails, Lights
| Type | Cap | Notes |
|---|---|---|
| Beam | ≤ **2 per effect** | plus the gold guide beam `[S01 B5]` and home beam `[S02 §7]` |
| Trail | **0 at launch** | P2 (expedition footprints, January) |
| PointLight (VFX) | **1 per reveal**, catcher only, Shadows off, **< 3 s** (templates: ≤ 1.5 s) | `[D17]` exception to the ≤ 8 per plot cap |
| Glow without Bloom | must read without Bloom: Bloom needs a higher graphics level on mobile and Neon glow can vanish at low settings `[BIBLE, VERIFY]` | |

### 1.4 Highlight `[D8] [D21]`
- Limit: 31 per older docs; **reportedly raised to 255** (Master Controller / bible citing a DevForum post). **Not verified by us.**
- **Pool of 2 per client**, created once, reparented on use (mobile GPU cost: the bible reports the first visible Highlight can cost up to ~1 ms on mobile `[VERIFY]`).
- Uses: only the transient reveal silhouette. Never on auras, pads, other players' catches or anything always-on.
- **No-Highlight fallback = optional switch** `VfxConfig.useHighlight` (default true): skip phase B; the creature fades in under the flash.

### 1.5 Neon
VFX templates contain **no Neon** (validator rejects it). Glow = `LightEmission` 0.5–1. **No Neon on the Fissure belt, Great Rift pit or Pedlar lantern**: PointLight + particles over RiftDim `[D41]`.

### 1.6 Quality fallback
| Setting | High (default) | Low |
|---|---|---|
| Emitter rates / Emit counts | 100% | **50%** (round down, min 1) |
| Auras (own plot) | on | tier emitter only |
| Beams | on | off |
| ColorCorrection / sky / Bloom pulses | on | off |
| Reveal PointLight | on | off |
| Hit-stop | on | on |
| UI sparks cap | 60 | 24 |
- Saved setting **`settings.effectsQuality`** ("Auto"/"High"/"Low"); with **`settings.sfx`** and **`settings.music`** these are **added to the save table by the Architect** (resolves v0.1 Q4). Auto reads `UserGameSettings.SavedQualityLevel` `[VERIFY readable + meaning of automatic]`, Low below level 4 `[P, tune]`.

### 1.7 Reduced Motion (spec 01 A5)
No FOV change, no hit-stop, no slide/scale/float, no draw-on rings, no sky tint. Particles: only the reveal burst at 50%. Sequence: circle fades in 0.15 s → creature fades in 0.15 s → name card fades 0.15 s. Sound unchanged.

### 1.8 Durations (summary)
| Effect | Length | Skip |
|---|---|---|
| Reveal Common / Uncommon / Rare / Epic | **0.6 / 1.0 / 2.0 / 3.5 s** + name card 1.2 s (non-blocking) | repeat species: tap any time; first-of-species: plays in full |
| Hold-to-bind (wild) | 3 s (2.25 s with Steady Hand/Quiet Step) `[S05]` | – |
| Epic banner | 4.0 s `[S08]` | passive |
| Epic sky tint | 4.0 s | off in RM |
| Collect pop | 0.8 s | – |
| Purchase seal / deny | 0.12 s / 0.4 s | – |
| Pad carve / place glow | 0.6 s / 0.5 s | – |
| Skill ignite | 0.9 s `[S04]` | – |

---

## 2. Catch / reveal ("Binding") sequence

**One reveal module** for wild catches, Rift buys, Pedlar buys, daily creature, Starter Pack and (January) tarot cards and expedition loot `[BIBLE]`. **Catcher's client only.** Circle at the catch point (wild/Rift) or 6 studs in front of the player.

### 2.1 Phases
A **Build-up** (circle draws, candles lean in and ignite, vignette, FOV in) → B **Silhouette / materialise** (`[D16]`; Uncommon+) → **hit-stop** (Rare/Epic) → C **Flash** (one flash, burst) → D **Settle** (aura on, name card, FOV/vignette out).

### 2.2 Escalation table
| | **Common** | **Uncommon** | **Rare** | **Epic** |
|---|---|---|---|---|
| Rarity colour `[D24]` | BoneDim `#A79F90` | Moss `#5E7A4A` | Silver `#8C9AA3` | Blood `#7A0F12` (+GoldBright) |
| **Total** | **0.6 s** | **1.0 s** | **2.0 s** | **3.5 s** |
| A / B / hit-stop / C / D (s) | 0.25 / – / – / 0.10 / 0.25 | 0.45 / 0.20 / – / 0.10 / 0.25 | 0.90 / 0.50 / 0.10 / 0.15 / 0.35 | 1.20 / 1.20 / 0.15 / 0.25 / 0.70 |
| Circle (template) | 1 ring r 3.6 "snaps shut" | + Moss rune band r 4.25 | 3 rings r 2.4 / 3.6 (Silver) / 4.8 + Silver runes | 3 rings, outer Gold + Gold runes + Blood 7-point seal (→ BloodHover at C) |
| Candles (lean in, ignite) | 0 | 3 | 5 | 7 |
| Vignette (UI) | none | Void edges 0.75 | **Silver-tinted** edges 0.6 | **screen to black** (edges 0.1, centre 0.35) over A, then **Blood "blood-moon" edges** 0.45 in B |
| FOV zoom punch `[D15]` (base = saved FOV) | none | −2 over A, back 0.3 s Quad Out | −4 over A, back 0.4 s Back Out | −6 over A+B; at C +8 in 0.12 s Quad Out; back 0.5 s Sine Out |
| Screen shake | 0 | 0 | 0 | 0 |
| Hit-stop (freeze tweens + emitter `TimeScale` 0) | – | – | 0.10 s | 0.15 s |
| Flash (full-screen Frame → transparent) | Bone 0.85, 0.1 s | Bone 0.75, 0.1 s | Silver 0.70, 0.15 s | GoldBright 0.60 → BloodHover 0.85, 0.25 s Expo Out |
| Burst `RevealBurst :Emit` | 12 | 20 (moss spores) | 30 | 36 + GoldLeaf 20 |
| AshRise `:Emit` (A) | 6 | 10 | 16 | 24 |
| EmberRise `:Emit` (C–D) | – | – | 8 | 15 |
| Light pillar Beam (catcher) | – | – | Silver, h 12, grow 0.8 s | Blood core + Gold edge, h 16, grow 1.2 s |
| Reveal PointLight `[D17]` | – | Range 10, peak 1.0 | Range 12, peak 1.3, Silver | Range 16, peak 1.5 |
| CC pulse (`VfxPulse`) | – | – | Contrast +0.05 | Contrast +0.10, Sat +0.10, Tint (255,232,220) |
| Who sees it `[BIBLE]` | you | you | you (P1: pillar for nearby players) | you + **server banner `[S08]` + 4 s sky tint for free sources** (wild, Rift belt, expeditions); personal Robux purchases never announce `[D29 amended]` |
| Sound layers | chalk scratch + match strike | + low bell | + breathy choir swell | + **3 heartbeats** (B), deep bell, choir |
| Rift source `[D20]` | + 2–4 Rift sparks in A | same | same | same |
| Name card | Bone name + tier word | + Moss sigil | + Silver stroke | Blood plate, GoldBright name, GrenzeGotisch |

**Budget per effect (validator, `effects.json`):** Common 2 emitters / 18 particles; Uncommon 4 / ~41; Rare+Rift 5 / ~65; **Epic 5 / ~102; Epic+Rift 6 / ~106** — all within `[D14]`.
**Tarot (January):** the "orbiting tarot silhouettes" (Rare) and "card turns" (Epic) beats from the bible need card art → **P1/January** `[D23]`; at launch the circle carries the drama.

### 2.3 Tween recipes
| Element | Recipe |
|---|---|
| Circle draw-in | Part-based chalk segments, `Transparency` 1→0 **in name order** (`Ring1_01`… then `Rune_`… then `Seal_`…), spread over A, Linear. Wild catches: driven by hold progress (§2.5) |
| Candles | clone `VFX_Reveal_Candle` onto `CandleSocket1..n`, lean 12° toward centre, ignite one by one in A (body 0.1 s Quad Out, then flame parts); flicker = FlameTop size Y 0.20↔0.24. Lead candle (socket 1) gets `CandleFlame` |
| Vignette | 4 edge Frames + `UIGradient`; tier colour per §2.2 |
| FOV | `Camera.FieldOfView`; restore the **saved** FOV |
| Silhouette | Highlight from pool: Fill Void 0, Outline tier colour 0.6, `DepthMode` Occluded; model `LocalTransparencyModifier` 1→0 over B `[VERIFY]` |
| Hit-stop | pause running tweens + set reveal emitters `TimeScale` 0 for 0.10/0.15 s `[VERIFY TimeScale feel]` |
| Reveal (C) | Fill 0→1 Expo Out; flash; `RevealBurst` colour = tier → Bone |
| Settle | creature +0.5 studs → 0 over 0.35 s Back Out (skip in RM) |
| Circle out | fade 0.4 s Quad In in the last part of D; lead candle snuff `AshRise :Emit(2)` |
| Skip | jump to end state in 0.15 s; name card 0.8 s |

### 2.4 Emitter templates (built: `art/vfx/templates/VFX_Emit_*`; all `Enabled=false`; texture = class default built-in `rbxasset://textures/particles/sparkles_main.dds` per the rbx-dom database `[VERIFY look]`; **the only other allowed texture is `rbxasset://textures/particles/smoke_main.dds`** (AshRise, set at runtime) `[D46]`; anything else fails the validator; custom textures P1 `[D23]`)
| Template | Rate / Emit | Lifetime | Speed | Size NS | Transparency NS | Colour | LightEmission | Other |
|---|---|---|---|---|---|---|---|---|
| `AshRise` | Emit 6/10/16/24 (+2 snuff, 8 carve, 4 deny/fail) | 1.2–1.8 | 1–2 | 0:0.15, 0.5:0.3, 1:0 | 0:1, 0.2:0.4, 1:1 | Ash → BoneDim | 0 | Accel (0,1.5,0), Drag 1, Spread 20 |
| `CandleFlame` (lead candle only) | Rate 6, Emit 3 flare | 0.4–0.6 | 0.5 | 0:0.15, 1:0.05 | 0:0.2, 1:1 | `#FFB36B` → GoldBright | 1 | LockedToPart, Spread 5 |
| `RevealBurst` | Emit 12/20/30/36 | 0.5–0.9 | 6–10 | 0:0.35, 1:0 | 0:0, 0.7:0.3, 1:1 | tier → Bone (set by code) | 0.6 (Epic 1) | Drag 4, Spread 180 |
| `GoldLeaf` (Epic) | Emit 20 | 1.5–2.0 | 3–5 | 0:0.25, 1:0.2 | 0:0, 0.8:0, 1:1 | Gold → GoldBright | 0.3 | Accel (0,−4,0), RotSpeed ±180, Drag 1.5 |
| `EmberRise` | Emit 8 (Rare) / 15 (Epic) | 1.0–1.6 | 1.5–3 | 0:0.1, 1:0 | 0:0, 1:1 | BloodHover → Gold | 1 | Accel (0,2,0), Spread 35 |
| `RiftSpark` | Emit 2–4 | 0.6–1.0 | 2 | 0:0.12, 1:0 | 0:0.2, 1:1 | Rift | 1 | Rift source only `[D20]` |

### 2.5 Hunt: hold-to-bind `[BIBLE §1]`
| Beat | VFX | Sound | Notes |
|---|---|---|---|
| Track (P1 polish) | fog wisp near the creature; footprints need decals → P1 `[D23]` | whisper, twig snaps | rarer cryptids get an **honest** taller wisp |
| Hold (3 s) | circle draws **one ring per third of the hold** (Common: a third of its ring each third); candles lean in; ash rises | heartbeat speeds up; pitch +1 step per ring | circular hold meter on the button |
| Catch (server confirms) | phases B → D of the tier; hit-stop on Rare/Epic | wax-seal thud + rarity stinger | banner "Bound: <name>" |
| Fail (leave range) | rings tint Soot, crack and fizzle (`AshRise :Emit(4)`); **1 s grace** to step back in | dull snap, no buzzer | "The binding slips" BoneDim, no penalty |
Budget: ≤ 2 emitters on the creature + 1 on the sigil while holding `[BIBLE]`.

### 2.6 Case-opening / Fate Reel `[D24]–[D27]` `[D34]` `[D37]` — **reel is January P1**; P0 = guards only
**`[D37]`:** tarot pulls are **earn-only**; paid readings are **fixed bundles with exact contents shown before purchase**; no paid random items. Everything below marked **DORMANT** is paid-reel-only work, kept on file but **not built unless a paid random path returns**. Server Luck: **pending Eudai**.
Source: **spec 10 v1.1** §2–§4, §9–§10 (read in full 4 Nov) and spec 09 v2.1 §5.5/§11. Spec 09 v2 §11 puts the Fate Reel, charge-up and reel QA tool in **January**; the Master Controller confirmed **P1, not launch** `[D27]`.

**P0 (launch) — no extra budget, inside P0-1:**
| Guard | Implementation |
|---|---|
| Tier-colour table `[D24] [D28]` | `VfxConfig.TierColor`: Common BoneDim `#A79F90`, Uncommon Moss `#5E7A4A`, Rare Silver `#8C9AA3`, Epic Blood `#7A0F12`, Legendary **plain GoldBright `#C9A55A`**; Mythic **GoldBright + Bone flare + thin Rift core** with its own frame shape `[D34]` (both later). No purple. Matches `VFX_Emit_RevealBurst` `TierColor_*` |
| Paid-purchase guard `[D26] [D29]` (amended) — **safety net** `[D37]` | in the reveal module: `if result.paid then announce=false; skyTint=false; nearMissFx=false end`. **`paid` = bought with Robux**, set by the server from the source, never the client `[S10 §3.5]`. Covers the Starter Pack and any other Robux product with a reveal. **Rift belt, expeditions and other in-game-cash sources are free** (`paid=false`): they can announce and trigger the Mythic sky. Paid readings are fixed bundles `[D37]`, so they shouldn't reach the reel; the guard stays in case one does |
| Settle at the true tier `[D25]` | the reveal starts only after the server result; `RevealBurst` colour = **true** tier, never a higher tier's colour, chime or effect |

**January P1 — what spec 10 needs from art/VFX (not built; UI only, so no textures except where marked):**
| # | Item | Spec 10 | Notes / budget |
|---|---|---|---|
| R1 | **Strip UI**: Ash backing, Gold 1 px rim 40% transparent, 4 px corners; 50 cards, ~7 visible; card 120×168 desktop / 96×134 phone, 8 px gap | §3.2, §9 | Frames + UIStroke + UICorner, no texture |
| R2 | **Card frames** per tier: Common plain BoneDim; Uncommon Moss + 1 corner sigil; Rare Silver + 2; Epic Blood + Bone inner line + 4; Legendary **plain GoldBright**; Mythic **GoldBright + Bone flare + distinct frame shape + thin Rift-green core** `[D34]` (Rift core within ≤ 2% of the screen `[D35]`) | §9 | sigils as small UI frames/glyph text at P1; **filigree / sigil art → textures (P1, upload gate)** |
| R3 | **Card face**: dark silhouette on Soot | §9 | **needs per-species silhouette images → textures** (P1, upload gate) or a ViewportFrame `[VERIFY cost]` |
| R4 | **Marker**: 4 px Gold needle with bone notches; near miss (every pull is earned `[D37]`) → GoldBright + soft 8 px glow, scale 1.0→1.05 twice with the heartbeat; never a rarity colour. *Paid: never brightens* — **DORMANT** | §9 | UIStroke/UIGradient glow, no texture |
| R5 | **Spin timings** (code): normal 4.0 s Quint Out; near-miss 5.5 s Exponential Out; *paid fixed 5.0 s, slow-down from 3.8 s* — **DORMANT** `[D37]`; 0.15 s ease-in; 0.1 s settle, no bounce | §3.2 | values are spec 10's `[A]`, tune in playtest |
| R6 | **Free near-miss emphasis**: only when W±1 is higher than the winner **and** in the band (Pale Rare+, Blood Epic); marker glow + 2 heartbeats 0.6 s apart + strip-edge vignette −15%; **no glow on any card** | §3.1, §9 | |
| R7 | **Charge-up**: steps `TIERS[1..trueTier]` only, soft pulses ≤ 3/s; 0.4 / 0.8 / 1.3 / 1.8 s (Leg 2.2, Myth 2.5 later; Mythic step adds the Bone flare + thin Rift core `[D34]`); RM = one 0.3 s fade | §4, §9 | frame glow = UIStroke colour/transparency tweens; then hands over to the §2.2 reveal at the true tier |
| R8 | **Reel sounds** (Integration Engineer, `audio-licences.md`): whoosh 0.4, tick (≤ 20/s), heartbeat (free near miss only), thunk, tier chime ×6 (true tier only) | §3.4 | Roblox-licensed only `[D31]` |
| R9 | **Reduced Motion**: no scroll; strip fades in stopped (0.15 s); no marker glow motion; near-miss heartbeat sound still plays; *never on paid* — **DORMANT** | §3.3 | |
| R10 | **Shuffle** 0.8 s + **card flip** before the reveal ladder | §2 | card art → textures (P1) |
| R11 | **Open x3**: 3 reels side by side; budget = UI only, the §2.2 reveal still plays one at a time | §6 | |
| R12 | **NEW stamp**: Rift-green wax seal, "NEW" in Bone, top-right of the reveal card | §8 | **launch stretch** per spec 09 v2 §11; UI Frame + text, no texture; small (Rift accent) |
| R13 | Pity / Essence bars: Blood / GoldBright fills on Soot, BoneDim labels | §7.4, §9 | UI only |
| R14 | **Mythic server sky** (**free sources**: free readings, wild catches, **Rift belt, expeditions** `[D26 amended]`; 20 s, 1 per server / 10 min) | §10 | Gold family per `[D34]`; Rift green **≤ 5% of the screen** `[D35]`, lighting readability floor kept (no Ambient/OutdoorAmbient below §4 floors) |
Particle budget: the reel itself is UI (0 world particles); the reveal after it stays inside the §2.2 budgets `[D14]`. Every check in spec 10 §13 tests 4–8 and 15–16 is a code/QA test for the Architect.

---

### 2.7 Onboarding beats (spec 01 v2.0 B3, `[D33]`) — uses existing P0 templates only
| Time | Goal | Beat | VFX / sound (existing modules) | Notes |
|---|---|---|---|---|
| 0:00 | – | Mothman Hatchling already on Pad 1 earning | Collect + PadPop `[D22]` | unchanged |
| ~0:17 | 2 | **First Rift buy**: Fresno Nightcrawler → **Pad 2** | Rift-buy reveal (Common; cash = free source, `paid=false` `[D29 amended]`), `VFX_Pad_Carve` | Hidebehind starts waiting on the belt here |
| ~0:17–0:33 | 3 | **First hunt**: guide beam out the **Wild Gate** to the Hodag 20 studs outside it `[S02]` | gold guide Beam `[S01 B5]`; §2.5 hold-to-bind (3 s, ≤ 12 studs) | **Hodag must read in the Wilds**: spawn lantern **APPROVED** `[D39]` (lit during goal 3 only; nearest Wild Gate wall candle off), `art/handoff/HODAG-ONBOARDING.md` |
| **~0:33** | 3 | **First catch reveal = Hodag, Common, 0.6 s** | Common tier of §2.2 (phases B → D), wax-seal thud, "Bound: Hodag" | then the **rarity tease: 3 tier-colour pips + text** (replaces the spec's 3 dark silhouettes for launch `[D40]`; silhouettes P1), **never shown as a near-miss** — spec below |
| **~0:45 (on pad ≤ ~0:50)** | 4 | Buy **Pad 3** ($120) + place the Hodag: **first carve + bind of a caught cryptid**, first "+$" pop from it ($5/s) | `VFX_Pad_Carve` + place glow, PadPop `[D22]` | QA: caught ≤ 0:50, on Pad 3 ≤ 1:00 `[S01 v2]` |
| ~1:12 | 5 | Bone Altar I | Upgrade (Bone Altar) feedback, §5 | was ~1:53 |
| ~1:44 | 6 | Pad 4 | `VFX_Pad_Carve` | |
| **~1:56** | 7 | **Hidebehind** Rift buy → **Pad 4** | Rift-buy reveal (Common; cash = free source) | was goal 4 / Pad 3 |
| ~1:56 → ~3:00 | 8 | Ward Candles shown, bar fills | – | |
**Goal-3 rarity tease `[D40]` — UI spec** (built-in UI only: `Frame`, `UICorner`, `UIStroke`, `UIListLayout`, `UIPadding`, `TextLabel`; **no ViewportFrame, no ImageLabel, no texture**). Sizes are `[PROPOSED]`, tune in Studio.
| Element | Desktop | Mobile | Notes |
|---|---|---|---|
| **Placement** | top **104 px**, centred | top **92 px**, centred | the **D18 banner slot** (below the cash plaque); the goal banner hides while it shows, as for D18. An Epic banner has priority: the tease waits until it clears `[PROPOSED]` |
| Plate `RarityTease` | 420 × 44 px | 360 × 38 px (widened for the final copy `[VERIFY fit]`) | Ash fill, 1 px UIStroke Gold at 40% transparency, UICorner 4 px (§5 panel rule); UIPadding 12 / 10 px left-right |
| Row | pips, then text, horizontal | same | UIListLayout Horizontal, VerticalAlignment Center, Padding **12 px** (pips → text) |
| **Pips** ×3, order Common → Uncommon → Rare | **16 × 16 px** | **14 × 14 px** | Frame, UICorner `UDim.new(0.5, 0)` (round), no stroke; spacing **8 px** desktop / **6 px** mobile |
| Pip colours | Common **BoneDim `#A79F90`** · Uncommon **Moss `#5E7A4A`** · Rare **Silver `#8C9AA3`** | same | tier tokens `[D24]`; **no Epic/Legendary/Mythic pip**, no Rift |
| **Text** | **"Three marks. Rarer things are watching."** (final) | same | **Merriweather** (§5 body) **18 / 16 px**, **Bone `#E8E0CF`**, left-aligned, `TextScaled=false`; never Gothic font |
| Timing | appears with the Hodag name card (after the 0.6 s reveal): fade in **0.2 s**, hold **2.5 s**, fade out **0.3 s** | same | **Reduced Motion:** fades ≤ 0.15 s. Once per player (goal 3 only). Non-blocking, no input |
| **Honesty rules** | static: **no pulse, glow, scale, sound or highlight** on any pip; pips never sit beside the result as "almost" | same | `[S09 v2]` no visual implies a higher tier than rolled; colour is never the only signal (text present) |
Budget: 0 particles, 0 lights, **12 UI instances** (plate Frame + UIStroke + UICorner + UIPadding + UIListLayout, 3 pip Frames + 3 UICorners, 1 TextLabel; pips sit in a small inner row Frame with its own UIListLayout if needed, +2). **P1:** the dark silhouettes, once textures exist `[D23]`.

Order of the Studio readability checks follows this table: **Hodag (Wilds, then Pad 3) first, Hidebehind after** (`art/asset-list.md`).

## 3. Idle auras at bases (P1, own plot only `[D19]`)
**Rules:** ≤ 2 emitters per cryptid (tier + flavour). **Glow = particle `LightEmission`, never Neon.** No lights, no Highlight. Never over the face. **Readability checks, in order `[D33]`: Hodag first** (first catch, ~0:33), then the **Hidebehind** (Starter Pack `[S09]`).
| Tier | Look `[BIBLE]` | Emitters | Max alive / cryptid |
|---|---|---|---|
| Common | faint grey dust motes | flavour Rate 1.5, Life 2 | **3** |
| Uncommon | drifting moss spores | tier Rate 1.5 Life 2 (Moss, LE 0.3) + flavour Rate 1.5 Life 2 | **6** |
| Rare | slow orbiting silver glints (rune-glyph texture P1 `[D23]`) | tier Rate 2 Life 2 (Silver, LE 0.7) + flavour Rate 2 Life 2 | **8** |
| Epic | ember halo + candle smoke (+ ground sigil: P1; a SurfaceGui ring is possible at P1 without a texture) | embers Rate 6 Life 2 (LE 1) + smoke Rate 6 Life 2 | **24** |
**Per-plot check:** up to 10 occupied pads at launch `[S07 §2]`. Bible example (6C+4U+1R+1E) = 74 alive. Cap **80** on your own plot; the aura manager scales rates by `80 / total` above that and halves auras during a reveal. Other plots: off `[D19]` (the bible's "two plots in view" assumption does not apply at launch).
| # | Cryptid | Tier | Flavour twist (one line) |
|---|---|---|---|
| 1 | Mothman Hatchling | C | Drifting **ash moths**: BoneDim flecks fluttering upward (RotSpeed ±90, slight sideways Accel) |
| 2 | Fresno Nightcrawler | C | Pale **stride dust**: low BoneDim puffs at the feet, slow, ground-hugging |
| 3 | Hidebehind | C | Thin **shadow peel**: Ash wisps peeling off the edges at transparency ≥ 0.7, never over the body (readability) |
| 4 | Hodag | C | **Back-spine embers**: tiny BloodHover sparks from the spines |
| 5 | Jackalope | U | **Antler dust**: Bone motes falling off the antler tips in short arcs |
| 6 | Dover Demon | U | **Eye glints**: one GoldBright glint from each Neon eye every ~3 s (Emit 1) |
| 7 | Snallygaster | U | **Wing downdraft**: Ash feathers drifting down under the wings |
| 8 | Loveland Frogman | U | **Wet drips + wand spark**: Bone drips falling; one Gold spark at the wand tip every ~4 s |
| 9 | Flatwoods Monster | R | **Metallic vapour**: thin Silver mist hissing upward from the hood |
| 10 | Beast of Bray Road | R | **Cold breath**: Bone breath puffs from the muzzle every ~2.5 s |
| 11 | Jersey Devil | E | **Ember wings**: Blood/GoldBright embers shed from the wingtips |
| 12 | Loch Ness Serpent | E | **Low mist ripple**: flat Bone mist rings spreading at the waterline (`Orientation` flat, Transp ≥ 0.75) |

Attachment names on models (art will add): `AuraTier`, `AuraFlavour` (+ `Eye_R`/`Eye_L`/`Muzzle`/`WandTip` where used). Existing models have **0 emitters** today, so all auras are additive. Flavour emitters count inside the per-tier totals above.

---

## 4. Epic server-wide moment (builds on spec 08)
**Spec 08 facts:** Epic from Wilds/Rift only, this server, ≤ 1 banner / 20 s, queue 3, 1 per catcher / 60 s, 4 s on screen, one low bell at 0.4, Blood fill, Gold border.
**`[D29]` (amended):** nothing **bought with Robux** triggers a server banner; readings are reader-only. In-game cash is earned, so **Rift belt and expedition Epics announce** just like **wild-caught Epics**. **`[D36]`:** spec 08 §4b thank-you banners for server-wide gifts may name the buyer, but never show a price or a buy link.
| Element | Spec |
|---|---|
| Placement `[D18]` | top **104 px desktop / 92 px mobile**; goal banner hidden while it shows |
| Frame | UICorner 4 px, Gold 2 px UIStroke, one GoldBright sweep after slide-in |
| Crack glyph | Rift, ≤ 5% of the banner area and **≤ 2% of the screen** `[D35]` |
| UI embers | 8 ImageLabels (60 UI cap) |
| **Sky tint (all clients)** `[BIBLE]` | 4 s: `VfxPulse` Tint → blood-moon red (255,226,218), Contrast +0.06, Atmosphere Color → `#241719`; 0.6 s in, 2.2 s hold, 1.2 s out. Density/Haze unchanged. **During an atmosphere event: Contrast +0.06 and Bloom +0.1 only, no tint, no Atmosphere change** `[D48]`. **Off with Reduced Motion and Low quality.** ≤ 1 per 60 s per client. "If time allows" at launch `[BIBLE]` |
| Sigil in the clouds | **P1** (needs a texture `[D23]`) |
| Lair pillar for others | **P1** (if time): `VFX_Beam_LightPillar_Epic` from the catcher's lair for 10 s `[BIBLE]` |
| Mythic (January) | sky **only for free sources** (free readings, wild catches, Rift belt, expeditions) `[D26 amended]`, spec 10 §10 (20 s, 1 per server / 10 min); Gold family `[D34]` with Rift green **≤ 5% of the screen**, lighting readability floor kept `[D35]` |
Anti-spam: hold the banner while the local player is mid-reveal (≤ 5 s); one banner visible at a time.

---

## 5. Click & collect feedback
Income auto-credits every 1 s `[S01 B2]`; outside the lair it fills the Offering Bowl, banked on re-entering the Threshold `[S06 §5]`.
| Event | Visual | Reduced Motion | Sound `[BIBLE]` |
|---|---|---|---|
| Button tap | spec press-scale; 1 px gold stroke brightens | colour only | soft bone click |
| Income tick | "+$X" GoldBright Oswald over the plaque, 0.8 s | fade only | none |
| **Per-pad "+$" pop** `[D22]` | `VFX_Collect_PadPop`: own plot, every 5 s per pad, staggered, max 4 | fade only | none |
| **Bowl bank** | `VFX_Collect_CoinSigil` (**one shared instance, moved** `[BIBLE]`): coin rises + fades 0.6 s, `CoinFlecks :Emit` 8/16/24 by bank size (<30 s / 30–300 s / >300 s of income); gold motes fly to the plaque (UI) | no rise, emit 50% | coins into a brass bowl; **pitch +1 step for quick repeats, resets after 2 s** |
| Confirm / buy | wax seal pressed into the button **0.12 s** | colour swap | wax-seal stamp thud |
| Can't afford | `VFX_Pad_Deny` cracks 0.4 s on a pad + UI nudge, "Need $X more" BoneDim | fade only | **dull wood knock** (≤ 1 / 0.5 s) |
| Unlock a pad | `VFX_Pad_Carve`: chalk draws 0.6 s, `AshRise :Emit(8)` dust | fade 0.15 s | stone grind + chalk scratch |
| Place a cryptid | GlowRing (SurfaceGui stroke) glows gold **0.5 s** | fade | low thrum |
| Goal complete | gold flash on the banner `[S01]` | – | candle snuff `[S01]` |
| Upgrade (Bone Altar) | bones rise 0.6 s Back Out; `CandleFlame :Emit(3)` ×4; `AshRise :Emit(16)` | fade 0.15 s | bone rattle + flare |
| Skill ignite `[S04 §8]` | as specced | spec 04 | match strike + whoosh |
| Streak (P1) | catch chain within 15 s | – | +1 semitone per step |

---

## 6. Sound palette
### 6.1 Event table
Volume tiers `[P]`: V1 0.2 · V2 0.35 · V3 0.5 · V4 0.7 (Epic only). UI sounds < 1 s `[BIBLE]`.
| Event | Vibe | Length | Pitch var. | Vol. | Layering |
|---|---|---|---|---|---|
| Button tap | soft bone click | 0.05–0.1 s | ±5% | V1 | – |
| Panel open/close | parchment rustle | 0.2–0.4 s | ±4% | V1 | – |
| Hold-to-bind | heartbeat speeding up, pitch +1 step per ring | 3 s | stepped | V2 | – |
| Reveal base (all tiers) | chalk scratch + match strike | 0.4–0.6 s | ±3% | V2 | Common |
| + low bell | low bell | 1–2 s | none | V2 | Uncommon+ |
| + choir swell | breathy choir | 1.2–2 s | none | V3 | Rare+ |
| + heartbeats ×3, deep bell, choir | Epic | 1.2 s (B) + 2–3 s | none | V3–V4 | Epic |
| Catch confirm | wax-seal thud + rarity stinger | 0.3–0.6 s | ±3% | V2 | per tier |
| Bind fail | dull snap | 0.2 s | ±3% | V1 | – |
| Epic banner bell `[S08]` | single low bell | 2–3 s | none | **0.4** | – |
| Bowl bank | coins into a brass bowl | 0.3–1.0 s | +1 step per quick repeat, resets after 2 s | V2–V3 | by size |
| `VFX_Pad_Carve` | stone grind + chalk scratch | 0.6 s | ±5% | V2 | – |
| Place cryptid | low thrum | 0.4 s | ±4% | V2 | – |
| Purchase | wax-seal stamp thud | 0.3 s | ±5% | V2 | – |
| Can't afford | dull wood knock | 0.15 s | ±2% | V1 | – |
| Goal complete | candle snuff `[S01]` | 0.3 s | ±4% | V1 | – |
| Skill ignite `[S04]` | match strike + low whoosh | 0.9 s | ±4% | V2 | – |
| Reel tick / settle `[D25]` | dry wooden tick / soft thud | 0.05 / 0.3 s | none on paid pulls (**DORMANT** `[D37]`) | V1 / V2 | identical every paid pull (**DORMANT**) |
| Town ambience `[S03]` | wind, distant bell every 60 s, crows | loop | – | Ambience | – |

### 6.2 Search terms (for the Integration Engineer)
`church bell low`, `match strike`, `chalk scratch`, `heartbeat slow`, `dark choir`, `choir swell`, `bone click`, `wax seal`, `wood knock`, `coins bowl`, `stone grind`, `candle snuff`, `whisper`, `twig snap`, `wind howl`, `crow caw`, `horror drone`.

### 6.3 Sourcing (ruling 4 Nov)
- **Free, Roblox-licensed audio only**, picked by the **Integration Engineer**, each one logged in **`art/vfx/audio-licences.md`** (Event | AssetId | Name | Source | Licence | Checked by | Date | Notes) before use. Cross-reference in `art/asset-list.md` per `[D6]`.
- No copyrighted music or ripped game sounds. If a candidate arrives as a Model: no scripts, no `require`, no Remotes `[SG §7]`.
- The bible's other route ("generate our own SFX, uploaded from Eudai's account") is **not** used at launch (§10).

### 6.4 Inspection checklist
1. Audio asset, free, Roblox-licensed; licence recorded. 2. Previewed in Studio at the planned volume. 3. Length ±50% of §6.1. 4. Occult tone, no cartoon. 5. Logged in `audio-licences.md` first.

### 6.5 Audio asset log → **moved to `art/vfx/audio-licences.md`** (empty until a real check).

### 6.6 SoundGroups
```
SoundService
├─ Master (1.0)
│  ├─ Music (0.35)     ← settings.music; ducks ×0.4 during Rare/Epic reveals
│  ├─ Ambience (0.5)   ← ducks ×0.6 during reveals
│  └─ SFX (0.8)        ← settings.sfx (spec 08 toggle)
│     ├─ SFX_UI (0.7)
│     ├─ SFX_World (0.8)  ← RollOffMaxDistance ~60 [VERIFY feel]
│     └─ SFX_Reveal (1.0)
```
Max 8 simultaneous SFX per client. One slow dark drone loop at launch.

---

## 7. Build list for the Architect
Sizes: S ≈ 1–2 h · M ≈ 2–4 h · L ≈ 4–8 h (rough, not measured).
### P0 (Fri 13 Nov freeze)
| # | Item | From art (built) | Size | Fallback cut |
|---|---|---|---|---|
| P0-1 | **VFX core:** `VfxConfig` (tier table §2.2/§2.6, D14 budget counter, quality + RM gates, Highlight pool 2 + `useHighlight` switch, paid-purchase guard §2.6) | `effects.json` budgets | S (1.5) | **YES** |
| P0-2 | **Binding reveal, 4 tiers** incl. hold-to-bind draw, hit-stop, skip rule | `VFX_Reveal_Circle_*`, `VFX_Reveal_Candle`, `VFX_Emit_*`, `VFX_Beam_LightPillar_*` | L (5) | **SLIM**: circles, candles, AshRise, RevealBurst, CandleFlame, FOV/vignette/flash; drop pillars, GoldLeaf, EmberRise, RiftSpark, CC pulse |
| P0-3 | **Collect:** bowl bank + plaque punch + per-pad "+$" `[D22]` | `VFX_Collect_CoinSigil`, `VFX_Collect_PadPop` | M (3) | no |
| P0-4 | **Epic layer** on the spec 08 banner (sweep, glyph, UI embers; sky tint if time) | none | S (2) | no |
| P0-5 | **Purchase / carve / place / deny** | `VFX_Pad_Carve`, `VFX_Pad_Deny` | M (2) | no |
| P0-6 | **Sound set + mix** (SoundGroups, player, ~18 keys) | §6 + `audio-licences.md` | M (3) | **YES** |
| | **Total** | | **≈ 16.5 h** | cut ≈ 8–9 h |
Onboarding goal-3 **rarity tease pips** `[D40]` (§2.7) are launch UI, built-in only, owned by the onboarding/UI build (size not estimated here). The case-opening guards (§2.6) ride inside P0-1 with **no extra budget**; the reel itself is January P1 `[D27]`. If the cut ships, thumbnail A must not show "+$".
### P1 (launch week)
Idle auras (M–L) · Rare/Epic pillar for other players + Epic lair pillar 10 s · sky sigil, footprints, tarot card art, leaf/glyph textures after Eudai uploads `[D23]` · streaks · area music beds.
**January P1 — Fate Reel (spec 10):** items R1–R14 in §2.6 (strip, frames, marker, timings (paid timing **DORMANT** `[D37]`), near-miss emphasis, charge-up, sounds, RM, shuffle/flip, Open x3, pity/Essence bars, Mythic sky). Needs textures: card silhouettes, card art/flip, frame filigree/sigil art (upload gate). NEW stamp (R12) is a launch **stretch** (UI only).
**Coming (separate task, not built here):** a **"richer realism" brief** (volumetric smoke and fog, colour grading, light shafts, embers). This plan does not touch the atmosphere pass.
### P2
Rebirth ritual · Legendary/Mythic tiers (Legendary plain GoldBright, Mythic per `[D34]`; Mythic sky free sources only `[D26 amended]`, ≤ 5% Rift `[D35]`) · expeditions (Trail) · Keen Eye outline after the Highlight check.

---

## 8. Art assets
**Built (P0, box-side):** 17 templates in `art/vfx/templates/` (list and triggers in `art/handoff/VFX-P0.md`). No uploads needed.
**P1 (uploads are a human gate for Eudai, `[D23]`):** circle decal sheet, gold leaf, rune glyph, ember, footprint, sky sigil, tarot card art. I only make PNGs on the box.

---

## 9. Open questions (v0.1 list, now closed)
| v0.1 Q | Status |
|---|---|
| 1 Shake | **Closed `[D15]`**: shake 0; FOV/vignette punches OK |
| 2 Silhouette | **Closed `[D16]`** |
| 3 Reveal light | **Closed `[D17]`** |
| 4 Settings keys | **Closed**: Architect adds `settings.sfx`, `settings.music`, `settings.effectsQuality` |
| 5 Banner position | **Closed `[D18]`** |
| 6 Transient budget | **Closed `[D14]`** |
| 7 Other players' auras | **Closed `[D19]`** |
| 8 Rift sparks | **Closed `[D20]`** |
| 9 Sound owner | **Closed**: Integration Engineer, `audio-licences.md` |
| 10 Uploads | **Closed `[D23]`**: P1 |
| 11 Highlight | **Closed `[D21]`** (updated: pool 2, fallback optional) |
| 12 "+$" | **Closed `[D22]`** |
| Case-opening palette / paid reels / Mythic sky | **Closed `[D24]` `[D25]` `[D26]`**; reel scope **`[D27]`** |

## 10. Flagged conflicts (v0.2 list; items 1–6 DECIDED 4 Nov)
1. **Rift belt Epics vs "nothing bought triggers a banner".** Spec 08 announces Epics "from the Wilds or the Rift"; Rift belt buys are cash purchases. Plan default follows the newer ruling (**no banner for Rift buys**) until confirmed; spec 08 would need an edit. — **DECIDED `[D29]`:** no banner for anything bought, Rift belt Epics included; wild-caught Epics still announce. **Re-decided 4 Nov (D29 amended):** "bought" = Robux; Rift belt (cash) Epics **announce**, matching spec 08.
2. **Bible hunt budget "sigil rings are flat decals or a Beam, not parts"** vs the build brief ("Part-based chalk ring") and `[D23]` (no custom textures at launch, so no decals). Built Part-based (19–74 transient parts). A Beam-ring fallback is possible if Studio shows a cost problem. — **DECIDED `[D30]`:** Part-built rings are fine for launch.
3. **Spec 09 §5.5 says "no reel, no spinner, no near-miss, no fake slow-down"** for tarot readings, while D25 defines paid reels and allows near-miss emphasis on free pulls and wild catches. The bible also says "we do NOT use near-miss". Spec 09 / the bible need updating to match D25, and **spec 10 is not on the box**. — **DECIDED `[D27]`:** reel approved (spec 10 v1.1, January P1); spec 09 v2 points to it; the old §5.5 wording and the bible's near-miss ban are void; honest near-miss emphasis on free pulls only; D25 governs paid pulls.
4. **Sound sourcing:** bible allows generated SFX uploaded from Eudai's account and logging in `asset-list.md`; the ruling says free Roblox-licensed only, logged in `audio-licences.md`. Plan follows the ruling. — **DECIDED `[D31]`:** Roblox-licensed sounds only.
5. **Highlight 255:** the bible states it as a fact; D8 treats it as unverified. Plan follows D8/D21. — **DECIDED `[D32]`:** D8 stays unverified until Studio confirms.
6. **Bible Mythic colour = Rift** vs `[D24]` Gold. Plan follows D24. — **DECIDED `[D28]`:** Mythic is Gold.
7. **Bible Epic "screen to black"**: done as a UI vignette (lighting floors untouched). Studio readability check needed.
8. **Bible aura example (74 alive, "two plots in view")** assumes other plots' auras; `[D19]` = own plot only. Cap set at 80 for your own plot.
9. **Font:** the rbx-dom migration table maps `Enum.Font.Garamond` (spec 01 / style guide panel headers) to `Guru.json`. VFX uses Oswald/GrenzeGotisch only; check the panel-header look in Studio.

## 11. New conflicts from spec 10 v1.1 / spec 09 v2.1 (items 1–4, 6 and 11 CLOSED 4 Nov by D34, D35, D37, D40 and the D26/D29 amendment)
1. **Mythic colour.** Spec 10 §4 (charge-up "→ Rift + slow pulse"), §9 (Mythic card frame "Rift `#7FA34A` … the only Rift-heavy card") and §10 (sky "sickly Rift green") vs **`[D28]` Mythic is Gold** and `[D24]`. Plan follows D28; spec 10 needs the edit (January, so no launch impact). — **CLOSED `[D34]`:** Mythic = GoldBright + Bone flare + distinct frame shape + thin Rift-green core. Spec 10's Rift-heavy Mythic frame/sky need editing to match (January).
2. **Legendary vs Mythic token.** D24/D28 say "Gold"; the style guide §1 palette already assigns **GoldBright `#C9A55A`** to Legendary, and spec 10 §9 uses the same hex for Legendary, so the table uses GoldBright for both. With Legendary and Mythic the same colour, the charge-up's last step can't show the difference by colour; spec 10 §9 says higher tiers differ by frame **shape**, which would carry it. Confirm Mythic = GoldBright (+ a different frame shape), not plain Gold `#9C7A3C`. — **CLOSED `[D34]`:** Legendary plain GoldBright; Mythic told apart by the Bone flare, frame shape and thin Rift core.
3. **Rift share.** Spec 10 §9 allows Rift "≤ ~5% of screen"; the style guide / `[D20]` say **≤ 2% of a view**. The 20 s Rift-green Mythic sky exceeds both (spec 10 §10 says it needs an Art Director decision). Plan default: 2% rule stands; Mythic sky colour per item 1. — **CLOSED `[D35]`:** ≤ 2% of the screen everywhere; only the Mythic sky may reach 5% (free sources only, lighting floor kept). Spec 10 §9's "~5% of screen" for cards needs editing to 2%.
4. **Mythic sky triggers disagree between specs.** Spec 10 §10: free readings + wild catches only, **not** Rift belt or expeditions. Spec 09 v2.1 §11 (launch-split row): "free sources only: free readings, wild catches, **Rift belt, expeditions**". Rift belt rolls are bought with cash, so including them also clashes with `[D26]`/`[D29]` ("nothing bought"). Plan follows spec 10 + D26. — **CLOSED (D26 amended):** "bought" = Robux, so spec 09 v2.1 §11's list stands: free readings, wild catches, Rift belt, expeditions. Spec 10 §10 needs the Rift belt + expeditions added.
5. **Boost-buyer banners.** Spec 08 v2 §4b and spec 09 v2 §8 / spec 10 §5.5 name the buyer server-wide for **Server Luck** (January) and **Blood Moon** (Update 1). That contradicts `[D29]` "no banner for anything bought". Not a launch item; needs a ruling before Update 1. **Partly resolved by `[D36]`** (Growth Strategist, relayed 4 Nov): spec 08 §4b thank-you banners for **server-wide gifts may name the buyer, but never show a price or a buy link**; D36 refines D29. Still open: whether the Blood Moon bought sky tint counts as such a gift. (The Blood Moon red sky is a bought sky tint too: the P0 guard is scoped to reveals, not to that product.) — **Mostly CLOSED:** `[D36]` + D29 amended: personal Robux purchases never announce; server-wide gift thank-yous may name the buyer, no price or buy link. **Server Luck still pending Eudai** `[D37]`.
6. **Charge-up "identical on every pull" (`[D25]`) vs spec 10 §4** per-tier lengths (0.4–2.5 s, steps up to the true tier). Read literally, a longer charge-up already tells you the tier, and the pulse is not identical across pulls. Plan reading: the **rules** are identical on every pull (same steps, same timing per tier, paid or free) and it never goes above the true tier. Confirm. — **CLOSED `[D37]`:** there are no paid random pulls, so the paid "identical" rule is **dormant**; the charge-up steps to the true tier only, same rules on every pull.
7. **Flash rule.** Plan §0 allows max 1 flash per sequence; spec 10 §9 charge-up pulses up to 6 times (≤ 3/s). These are soft frame glows, not full-screen flashes, so treated as compatible; flag for the photosensitivity check.
8. **Card faces and card flip need images** (silhouettes, card art, filigree/sigils): all textures → P1 upload gate `[D23]`; a ViewportFrame silhouette is the no-texture option `[VERIFY cost on mobile]`.
9. **Sound placeholders.** Spec 10 §3.4 lists `rbxassetid://TBD_…` ids "TBD by the Art Director/audio"; per `[D31]` the Integration Engineer picks them (Roblox-licensed only) and logs them in `audio-licences.md`.
10. **Bible tension** noted by spec 10 itself ("no reel / no paid luck boosts"): the reel part is settled by `[D27]`; **Server Luck vs the bible's "no paid luck boosts"** is still marked "Eudai should confirm" in spec 09 v2 §5.2 and spec 10. Not an art decision. — **Still open:** Server Luck is pending Eudai `[D37]`; the reel part is settled.
11. **Goal 3 "3 dark rarity silhouettes" preview** (spec 01 v2.0, after the Hodag reveal) vs `[D23]` (no custom textures at launch) and `[D16]` (silhouette used as the materialise beat). A no-texture build is possible: 3 small **ViewportFrames** showing placeholder-kit models (`art/models/placeholders/*_PH.rbxmx`) as near-black shapes on tier-colour frame rims `[VERIFY cost on mobile in Studio]`. It must sit **after** the name card, never next to the result as an "almost" `[S09 v2]`. Not a P0 template; needs an owner (UI) and Master Controller sign-off. — **CLOSED `[D40]`:** silhouettes cut for launch; replaced by 3 tier-colour pips + a text tease, built-in UI only, **no ViewportFrames** (spec in §2.7). Silhouettes → P1 once textures exist.
