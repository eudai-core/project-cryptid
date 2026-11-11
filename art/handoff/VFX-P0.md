# Handoff: VFX P0 set (v1.0 templates, handoff rev. 5, Wed 4 Nov 2026: D38 RiftDim, D39 lantern, D40 goal-3 pips; rev. 3: D34, D35, D37 + D26/D29 amended ("bought" = Robux); rev. 2: reel unblocked as January P1, D27–D32)
**Rev. 5 (4 Nov):** validator v4 (D41 no Neon on Rift trim, D42 RiftDim SmoothPlastic ≤ 0.3, D45 FogWisp ≤ 8 s / ≤ 2/s, D46 one allowlisted texture `smoke_main.dds`). AshRise sets that texture **at runtime**; templates keep no Content property.
- **What:** 17 client-side VFX templates for the P0 "dopamine pass": the binding reveal (4 tiers), collect, pad carve/place/deny. Spec: `art/vfx/vfx-audio-plan.md` v0.3 · naming/attributes: `art/vfx/vfx-templates-README.md`.
- **Files (box):** `/workspace/project-cryptid/art/vfx/templates/*.rbxmx` (17). Preview data `*.parts.json` and `effects.json` sit beside them: **do NOT map the `.json` files into Rojo** (Rojo would turn them into ModuleScripts). Generator: `art/tools/build_vfx.py` (lib `rbxlib.py`).
- **Proposed place path:** `ReplicatedStorage.Assets.VFX.<TemplateName>`, cloned by client `Vfx/*` modules (plan §7). Nothing here runs on the server.
- **Scripts inside:** none ✅ · **Neon:** none ✅ · **Custom textures / asset IDs:** none (built-in class defaults only, `[D23]`) ✅ · **Uploads needed:** none · **Source & licence:** self-built by Grok Bot (Parts + built-in instances), project-owned.
- **Every template:** a Model, `PrimaryPart = Root` (invisible, anchored, no collision/touch/query, flat), pivot at ground level: `template:Clone():PivotTo(cf)`. Attributes `VFX_Version = "1.0"`, `Notes` (how to trigger it), `FallbackCut` (bool). All ParticleEmitters/Beams/Lights/GUIs ship **disabled** (`Enabled = false`).
- **Screenshots:** `qa/screenshots/VFX_P0_2026-11-04_preview-sheet.png`: box-side geometry preview, **NOT Studio proof**. Particles, Beams, GUIs and lights: **PENDING Studio**.

#### Templates
| Template | Parts | Purpose | Trigger (summary; full text in `Notes`) | Fallback cut |
|---|---|---|---|---|
| `VFX_Reveal_Circle_Common` | 19 | 1 Bone chalk ring r 3.6 | clone on catcher's client; parts Transparency 1 → 0 in name order over phase A | ✅ |
| `VFX_Reveal_Circle_Uncommon` | 31 | ring + 12 Moss runes, 3 `CandleSocket`s, `RevealLight` | same + candles on sockets; light at C | ✅ |
| `VFX_Reveal_Circle_Rare` | 67 | 3 rings (middle Silver), Silver runes, 5 sockets, light | same; hit-stop 0.1 s before C | ✅ |
| `VFX_Reveal_Circle_Epic` | 74 | 3 rings (outer Gold), Gold runes, Blood {7/3} seal, 7 sockets, light | same; hit-stop 0.15 s; seal → BloodHover at C | ✅ |
| `VFX_Reveal_Candle` | 6 | Part-based candle + Part flame, `FlameTip` attachment | clone per socket, lean 12°, ignite one by one in A | ✅ |
| `VFX_Emit_AshRise` | 1 | ash/dust burst | `:Emit(EmitCount_<Tier>)` in A; also carve 8, deny/fail 4, snuff 2 | ✅ |
| `VFX_Emit_RevealBurst` | 1 | the one flash burst | set Color/LightEmission from `TierColor_<Tier>` / `LightEmission_<Tier>`, `:Emit` at C | ✅ |
| `VFX_Emit_CandleFlame` | 1 | lead-candle flame (Rate 6) | parent to socket-1 candle's `FlameTip`; Enabled on ignite + `:Emit(3)` | ✅ |
| `VFX_Emit_GoldLeaf` | 1 | Epic gold leaf | `:Emit(20)` at C | ✗ |
| `VFX_Emit_EmberRise` | 1 | rising embers | Rare 8 / Epic 15 at C–D | ✗ |
| `VFX_Emit_RiftSpark` | 1 | Rift sparks `[D20]` | Rift-source reveals only, `:Emit(2–4)` in A | ✗ |
| `VFX_Beam_LightPillar_Rare` | 1 | Silver pillar h 12 | C–D, Width0 0 → value over 0.8 s, catcher only | ✗ |
| `VFX_Beam_LightPillar_Epic` | 1 | Blood core + GoldBright edge h 16 | C–D, grow 1.2 s, catcher only | ✗ |
| `VFX_Collect_CoinSigil` | 6 | bowl-bank coin + `CoinFlecks` | **one shared instance, moved**; rise 1 stud/0.6 s; Emit 8/16/24 by bank size | ✗ |
| `VFX_Collect_PadPop` | 1 | "+$" BillboardGui `[D22]` | own plot, every 5 s per pad, staggered, max 4 visible | ✗ |
| `VFX_Pad_Carve` | 26 | chalk ring r 3.9 at pad top + `GlowRing` SurfaceGui | carve draw 0.6 s + AshRise 8; place-cryptid glow 0.5 s | ✗ |
| `VFX_Pad_Deny` | 5 | 4 Void cracks | can't afford: fade in/out over 0.4 s | ✗ |

#### Emit counts per tier (`:Emit(n)`, High quality; Low = 50 %, min 1)
| Emitter | Common | Uncommon | Rare | Epic |
|---|---|---|---|---|
| AshRise | 6 | 10 | 16 | 24 |
| RevealBurst | 12 | 20 | 30 | 36 |
| CandleFlame (flare + Rate 6 while lit) | – | 3 | 3 | 3 |
| GoldLeaf | – | – | – | 20 |
| EmberRise | – | – | 8 | 15 |
| RiftSpark (Rift source only) | 4 | 4 | 4 | 4 |

#### Timings (s) — from the design bible, attributes on each circle
| Tier | Total | A build-up | B materialise | Hit-stop | C flash | D settle | Candles | Name card after |
|---|---|---|---|---|---|---|---|---|
| Common | 0.6 | 0.25 | – | – | 0.10 | 0.25 | 0 | 1.2 (non-blocking) |
| Uncommon | 1.0 | 0.45 | 0.20 | – | 0.10 | 0.25 | 3 | 1.2 |
| Rare | 2.0 | 0.90 | 0.50 | 0.10 | 0.15 | 0.35 | 5 | 1.2 |
| Epic | 3.5 | 1.20 | 1.20 | 0.15 | 0.25 | 0.70 | 7 | 1.2 |
Wild catches: phase A plays **during the 3 s hold** (one ring per third). Skip: repeat species only. `RevealLight` peak 1.0 / 1.3 / 1.5, always off within 1.5 s (`[D17]` < 3 s). Shake 0 `[D15]`; FOV/vignette per plan §2.2.

#### Budgets (`python3 art/tools/validate_rbxmx.py --effects art/vfx/templates/effects.json`, all PASS, `[D14]` ≤ 6 emitters / ≤ 120 particles)
| Effect | Emitters | Particles (peak est.) | Beams | Lights |
|---|---|---|---|---|
| Reveal_Common | 2 | 18 | 0 | 0 |
| Reveal_Common_Rift | 3 | 22 | 0 | 0 |
| Reveal_Uncommon (+Rift) | 4 | 40.6 | 0 | 1 |
| Reveal_Rare_Rift | 5 | 64.6 | 1 | 1 |
| Reveal_Epic | 5 | 101.6 | 2 | 1 |
| Reveal_Epic_Rift | 6 | 105.6 | 2 | 1 |
| Collect_BankLarge | 1 | 24 | 0 | 0 |
| Pad_Carve | 1 | 8 | 0 | 0 |
| Pad_Deny | 1 | 4 | 0 | 0 |
Peak parts on screen during a reveal: Epic circle 74 + 7 candles × 6 = **116 transient parts** (box count; frame cost **verify in Studio** on a phone).

#### Fallback cut (if P0 slips): items 1, slim 2, 6
- **P0-1 VFX core** (`VfxConfig`, budget counter, quality/RM gates, Highlight pool 2 + `useHighlight` switch, paid-purchase guard, kept as a **safety net** `[D37]`).
- **P0-2 slim:** the 4 circles, candles, `AshRise`, `RevealBurst`, `CandleFlame`, FOV/vignette/flash. **Dropped:** GoldLeaf, EmberRise, RiftSpark, both pillars, the CC/Bloom pulses. (`FallbackCut = true` marks the kept templates.)
- **P0-6 sound set + mix.** If the cut ships, thumbnail A must not show "+$".

#### Rules the code must keep
- Client-only, after the server has granted the result. Nothing waits on VFX.
- **Nothing bought with Robux triggers a server banner, sky tint or near-miss effect** `[D26] [D29]` (amended 4 Nov). In-game cash is earned, so **Rift belt and expedition catches are free sources**: their Epics **announce** like wild-caught ones (spec 08) and can trigger the Mythic sky. Personal Robux purchases never announce; server-wide gift thank-yous may name the buyer, never a price or buy link `[D36]`.
- **Rift green ≤ 2% of the screen everywhere**; only the Mythic sky may reach 5% (free sources only, lighting floor kept) `[D35]`.
- **Canonical Rift `#7FA34A` = small accents only** (particles such as `VFX_Emit_RiftSpark`, UI). Any world trim on Parts uses **RiftDim `#4F6B34`**, never Neon, no Bloom catch `[D38]`. The P0 templates already comply (no Rift on Parts, no Neon).
- **No visual may imply a higher tier than the one rolled** (spec 09 v2 / spec 10): colours, chimes and bursts always use the **true** tier.

#### Case-opening / Fate Reel (spec 10 v1.1) — **no longer on hold: unblocked as January P1** `[D27]`
**P0 (launch), inside P0-1, no extra budget:**
1. `VfxConfig.TierColor` = BoneDim / Moss / Silver / Blood (later: Legendary **plain GoldBright**; Mythic **GoldBright + Bone flare + distinct frame shape + thin Rift-green core** `[D34]`); same values as `VFX_Emit_RevealBurst` `TierColor_*`.
2. Paid guard in the reveal module: `if result.paid then announce=false; skyTint=false; nearMissFx=false end`. `paid` = **bought with Robux**, set by the server from the source, never from the client. Rift belt / expeditions / other cash sources are `paid=false`. **Safety net** `[D37]`: tarot pulls are earn-only and paid readings are fixed bundles shown before purchase, so nothing paid should reach a random reveal; keep the guard anyway.
3. Settle at the true tier: the reveal starts only after the server result, and the burst colour / sounds use the true tier.

**January P1 reel wiring notes (from spec 10 §3.5, §3.2, §4; nothing built yet).** `[D37]`: tarot pulls are **earn-only**; anything marked **DORMANT** is paid-reel-only and is **dormant unless a paid random path returns**. Server Luck: **pending Eudai**.
- Server rolls first, builds the 50-card strip at the **same posted odds** (`Random.new()` on the server), picks winner index W (38–44) and offset (±42% of a card), sets `paid` from the source and `nearMiss` (always `false` when `paid`; *the `paid` branch is DORMANT*), saves it in the ledger, **then** fires `ReelResult` to that player only: `{readingId, cardIndex, tableId, tableVersion, strip[50], winnerIndex, offset, paid, nearMiss}`.
- Client picks timing **only** from `paid`/`nearMiss`: *paid → fixed 5.0 s, Quint Out, slow-down from 3.8 s, no glow/heartbeat/needle brighten* (**DORMANT** `[D37]`); **free + nearMiss** → 5.5 s Exponential Out + marker glow (Gold → GoldBright, never a rarity colour, never on a card) + 2 heartbeats 0.6 s apart + strip-edge vignette −15%; **free otherwise** → 4.0 s Quint Out. 0.15 s ease-in, 0.1 s settle, no bounce. Values are spec 10 `[A]`.
- Stop: the card under the marker = `strip[winnerIndex]` = the granted cryptid (spec 10 §13 test 4).
- Then **charge-up** from `TIERS[1..trueTier]` only (0.4 / 0.8 / 1.3 / 1.8 s; ≤ 3 pulses/s; same rules on every pull) → hand over to the binding reveal at the true tier (this handoff's circles/emitters, same budgets).
- Skip Animation / Reduced Motion: jump to / fade in the same stopped result (RM: strip fades in stopped 0.15 s; charge-up = one 0.3 s fade). Free near-miss heartbeat sound may still play in RM; *never on paid* (**DORMANT**).
- Reel is UI only: **0 world particles**; the reveal after it uses the P0 templates unchanged.
- Sounds (whoosh, tick ≤ 20/s, heartbeat free-only, thunk, true-tier chime ×6): Integration Engineer, Roblox-licensed only, `art/vfx/audio-licences.md` `[D31]`.
- Needs textures (P1 upload gate): card silhouettes / card art / flip, frame filigree and sigils. NEW stamp is a launch **stretch** (UI only, no texture).
- Conflicts **closed 4 Nov** (plan §11): Mythic colour and token `[D34]`, Rift share `[D35]`, Mythic sky triggers (D26 amended: free = wild, free readings, Rift belt, expeditions), charge-up "identical" (dormant, `[D37]`). Boost-buyer banners mostly closed `[D36]` + D29 amended; **Server Luck pending Eudai**. Still open: flash rule, card textures, sound ids, (§11.7–11.9). Goal-3 silhouette preview **closed by `[D40]`** (pips; silhouettes P1).
- Highlight: pool of 2 per client `[D8] [D21]`; `useHighlight = false` skips phase B.
- Reduced Motion: per each `Notes` (fades ≤ 0.15 s, no draw-on, no hit-stop, no FOV).

#### PENDING Studio checks (none of these can be checked on the box)
1. Particle look with the **built-in default texture** (`rbxasset://textures/particles/sparkles_main.dds` per rbx-dom db 0.741), sizes, colours, LightEmission at night lighting.
2. **Beam with no texture** reads as a solid pillar; FaceCamera behaviour.
3. **SurfaceGui on a fully transparent part** (`GlowSurface`) renders; **UIStroke on a transparent Frame** (`GlowRing`, BillboardGui "+$").
4. Highlight limit (31 vs reported 255) and its mobile GPU cost.
5. NumberSequence/ColorSequence keypoint limit (20) — templates use ≤ 3 keypoints.
6. Fonts: Oswald Bold resolves (`rbxasset://fonts/families/Oswald.json`); note: the rbx-dom font migration table maps `Enum.Font.Garamond` to **`Guru.json`**, so spec 01 / style guide §5 "Panel headers: Garamond" may not look like Garamond. Check in Studio; no VFX template uses it (flagged to the Master Controller).
7. Default camera FOV (plan assumes the saved value is restored, not a hard-coded 70).
8. `LocalTransparencyModifier` fade for the silhouette; emitter `TimeScale` 0 for hit-stop.
9. Frame time on a low-end phone during an Epic reveal (116 parts + ~106 particles + 2 beams + 1 light).
10. Rojo: templates set **no Content properties**, so they build on Rojo 7.4.4 and 7.7.1; if any later template sets a texture, the repo needs Rojo ≥ 7.7 (7.4.4 rejects the `<Content><uri>` form).
11. **Onboarding order (spec 01 v2.0, `[D33]`):** check the **first catch reveal = Hodag (Common, ~0:33) in the Wilds** first, then the **goal-3 rarity tease** (3 tier-colour pips + text, built-in UI only, no ViewportFrames `[D40]`; spec in plan §2.7), then its **Pad 3 carve + first "+$" pop (~0:45)**, then the **Hidebehind** Rift buy (goal 7, ~1:56, Pad 4). Beats: `vfx-audio-plan.md` §2.7; lantern **APPROVED** `[D39]` (lit during goal 3 only; plot cap stays 8): `HODAG-ONBOARDING.md`.

#### Verified box-side
- Encodings vs Rojo 7.7.1 rbx_xml: `art/tools/test_vfx_encoding.py` → 31 properties, 0 diffs.
- Validator `--vfx` on all 17: PASS; `--effects`: PASS; negative tests caught 7/7 injected faults.
- Rojo 7.7.1 **and** 7.4.4 build (`.rbxlx` + `.rbxl`) of a throwaway project: 17 templates, 4,892 properties compared, 0 problems (`art/tools/rojo_roundtrip_cmp.py`).
- Existing 14 models rebuild byte-identical after the `rbxlib.py` changes and still PASS the validator.

#### Trigger notes (verbatim `Notes` attribute)
- **`VFX_Beam_LightPillar_Epic`**: Light pillar, Epic: phase C-D. PivotTo the circle centre. Enable the beam(s), tween Width0 from 0 to its template value over 1.2 s Quad Out, hold, then tween Width0/Width1 to 0 over 0.4 s and disable. Catcher-only at P0. P1 (bible proposal, if time): the same pillar rises from the catcher's lair for 10 s for other players. Solid colour: no Beam texture (D23). Not in the fallback cut. Reduced Motion: fade in/out 0.15 s, no width tween.
- **`VFX_Beam_LightPillar_Rare`**: Light pillar, Rare: phase C-D. PivotTo the circle centre. Enable the beam(s), tween Width0 from 0 to its template value over 0.8 s Quad Out, hold, then tween Width0/Width1 to 0 over 0.4 s and disable. Catcher-only at P0. P1 (bible proposal, if time): nearby players also see it, via a server event. Solid colour: no Beam texture (D23). Not in the fallback cut. Reduced Motion: fade in/out 0.15 s, no width tween.
- **`VFX_Collect_CoinSigil`**: Bowl bank (entering your Threshold). One shared instance, moved, not one per pad (bible). PivotTo just above the Bone Altar top. Coin parts start Transparency=1: fade in 0.1 s, rise 1 stud + fade out over 0.6 s Quad Out. CoinFlecks :Emit by bank size (seconds of current income): <30 s EmitSmall 8, 30-300 s EmitMedium 16, >300 s EmitLarge 24. Pair with the plaque count-up (spec 01) and the 'coins into a brass bowl' sound (pitch +1 step per quick repeat, resets after 2 s). Reduced Motion: no rise, emit 50%. Not in the fallback cut.
- **`VFX_Collect_PadPop`**: Per-pad '+$' pop (D22, own plot only). Clone the PadPop BillboardGui, set Adornee = pad.CryptidMount, Text = '+$' .. amount, Enabled=true; every 5 s per occupied pad, staggered, max 4 visible. Tween StudsOffset Y 4.5->6 over 0.8 s Quad Out, TextTransparency/stroke 0->1 in the last 0.3 s, then Destroy. Reduced Motion: fade only. No sound. Not in the fallback cut (if cut, thumbnail A must not show '+$').
- **`VFX_Emit_AshRise`**: Ash rising from the circle in phase A: :Emit(EmitCount_<Tier>) 6/10/16/24, spread over A in 2-3 calls. Also: candle snuff :Emit(2), pad carve dust :Emit(8), hunt fail fizzle :Emit(4). Re-parent onto the circle Root (emits across its top face) or onto an Attachment for a point source. Reduced Motion: skip.
- **`VFX_Emit_CandleFlame`**: Lead candle flame (one per reveal, on VFX_Reveal_Candle.FlameTip of socket 1). Enabled=true when that candle ignites (+ :Emit(3) flare), Enabled=false at snuff. Also usable for the Bone Altar upgrade flare (:Emit(3)). Rate 6 x 0.6 s = ~4 alive.
- **`VFX_Emit_EmberRise`**: Rising embers, phase C-D: Rare :Emit(8), Epic :Emit(15). Glow = LightEmission (no Neon). Reduced Motion: skip.
- **`VFX_Emit_GoldLeaf`**: Epic only: :Emit(20) at phase C, after the hit-stop. Built-in default texture reads as gold flecks; a leaf texture is P1 (D23). Reduced Motion: emit 10.
- **`VFX_Emit_RevealBurst`**: The one burst at phase C. Before emitting set Color = ColorSequence(tier colour -> Bone) using the TierColor_<Tier> attribute (Uncommon = moss spores), LightEmission = LightEmission_<Tier>. :Emit(EmitCount_<Tier>) 12/20/30/36. Reduced Motion: emit 50%.
- **`VFX_Emit_RiftSpark`**: Rift-source reveals only (D20): :Emit(2..4) from the circle edge in phase A, any tier. Keep Rift green <= 2% of the view; never on wild or Pedlar catches.
- **`VFX_Pad_Carve`**: Pad unlock ('carve'). PivotTo the Pad's pivot (same ground-centre pivot as the Pad model). Chalk parts start Transparency=1 and draw in name order over 0.6 s Linear (stone grind + chalk scratch sound), then VFX_Emit_AshRise :Emit(8) as a dust puff. GlowRing (SurfaceGui on the invisible GlowSurface, top face): on carve finish and on 'place a cryptid', Enabled=true and tween the stroke Transparency 1->0->1 over 0.5 s (bible: pad ring glows gold 0.5 s). Reduced Motion: chalk fades in 0.15 s. Not in the fallback cut.
- **`VFX_Pad_Deny`**: World 'deny' on a pad you can't afford or that is Sealed. PivotTo the Pad pivot. Cracks start Transparency=1, appear in 0.1 s, hold 0.2 s, fade 0.1 s (0.4 s total). Pair with the UI deny: 'Need $X more' in BoneDim + gentle side-to-side nudge (spec 01 B9) and a dull wood knock (max 1 per 0.5 s). Optional VFX_Emit_AshRise :Emit(4) fizzle. Reduced Motion: cracks fade only. Not in the fallback cut.
- **`VFX_Reveal_Candle`**: Reveal candle. Clone onto each CandleSocket of the circle (3/5/7 for Uncommon/Rare/Epic). Start with all parts Transparency=1; ignite one by one in phase A: body+wick fade in 0.1 s Quad Out, then Flame parts fade in; flicker by tweening FlameTop size Y 0.2<->0.24 (skip in Reduced Motion). Lean 12 deg toward the circle centre (pivot at base). Only the lead candle (socket 1, front) gets the shared VFX_Emit_CandleFlame emitter on FlameTip, to stay within D14 (<= 6 emitters per effect). Snuff at the end: fade flame 0.15 s, AshRise :Emit(2) from FlameTip.
- **`VFX_Reveal_Circle_Common`**: Binding reveal circle, Common. Clone locally on the catcher's client only (server already granted the catch). PivotTo the catch point on the floor (wild/Rift) or 6 studs in front of the player (Pedlar/daily/pack). Set every visible part Transparency=1 on clone, then tween to 0 in name order (Ring1_01.. then Rune_.. then Seal_..) over phase A (0.25 s, Linear). Wild catches: draw during the 3 s hold, one ring per third of the hold (Common: one third of its single ring per third). Candles: clone VFX_Reveal_Candle onto each CandleSocket (0), lean 12 deg toward centre, ignite one by one in A. No light at this tier. Re-parent shared emitters (AshRise etc.) onto Root to emit across the circle. Out: fade all 0.4 s Quad In at the end of D. Hunt fail: tint segments Soot and fade 0.3 s ('the binding slips'). Reduced Motion: fade the whole circle in 0.15 s, no draw-on.
- **`VFX_Reveal_Circle_Epic`**: Binding reveal circle, Epic. Clone locally on the catcher's client only (server already granted the catch). PivotTo the catch point on the floor (wild/Rift) or 6 studs in front of the player (Pedlar/daily/pack). Set every visible part Transparency=1 on clone, then tween to 0 in name order (Ring1_01.. then Rune_.. then Seal_..) over phase A (1.2 s, Linear). Wild catches: draw during the 3 s hold, one ring per third of the hold (Common: one third of its single ring per third). Candles: clone VFX_Reveal_Candle onto each CandleSocket (7), lean 12 deg toward centre, ignite one by one in A. RevealLight (D17): Enabled=true at C, Brightness 0->1.5->0 within 1.5 s (always < 3 s), then Enabled=false. Seal turns BloodHover at C. Re-parent shared emitters (AshRise etc.) onto Root to emit across the circle. Out: fade all 0.4 s Quad In at the end of D. Hunt fail: tint segments Soot and fade 0.3 s ('the binding slips'). Reduced Motion: fade the whole circle in 0.15 s, no draw-on.
- **`VFX_Reveal_Circle_Rare`**: Binding reveal circle, Rare. Clone locally on the catcher's client only (server already granted the catch). PivotTo the catch point on the floor (wild/Rift) or 6 studs in front of the player (Pedlar/daily/pack). Set every visible part Transparency=1 on clone, then tween to 0 in name order (Ring1_01.. then Rune_.. then Seal_..) over phase A (0.9 s, Linear). Wild catches: draw during the 3 s hold, one ring per third of the hold (Common: one third of its single ring per third). Candles: clone VFX_Reveal_Candle onto each CandleSocket (5), lean 12 deg toward centre, ignite one by one in A. RevealLight (D17): Enabled=true at C, Brightness 0->1.3->0 within 1.5 s (always < 3 s), then Enabled=false. Re-parent shared emitters (AshRise etc.) onto Root to emit across the circle. Out: fade all 0.4 s Quad In at the end of D. Hunt fail: tint segments Soot and fade 0.3 s ('the binding slips'). Reduced Motion: fade the whole circle in 0.15 s, no draw-on.
- **`VFX_Reveal_Circle_Uncommon`**: Binding reveal circle, Uncommon. Clone locally on the catcher's client only (server already granted the catch). PivotTo the catch point on the floor (wild/Rift) or 6 studs in front of the player (Pedlar/daily/pack). Set every visible part Transparency=1 on clone, then tween to 0 in name order (Ring1_01.. then Rune_.. then Seal_..) over phase A (0.45 s, Linear). Wild catches: draw during the 3 s hold, one ring per third of the hold (Common: one third of its single ring per third). Candles: clone VFX_Reveal_Candle onto each CandleSocket (3), lean 12 deg toward centre, ignite one by one in A. RevealLight (D17): Enabled=true at C, Brightness 0->1.0->0 within 1.5 s (always < 3 s), then Enabled=false. Re-parent shared emitters (AshRise etc.) onto Root to emit across the circle. Out: fade all 0.4 s Quad In at the end of D. Hunt fail: tint segments Soot and fade 0.3 s ('the binding slips'). Reduced Motion: fade the whole circle in 0.15 s, no draw-on.
