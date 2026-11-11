# Handoff: Atmosphere LAUNCH scope (for the Systems Architect)
**Wed 4 Nov 2026 · Art Director · rulings D41–D49 (style guide v0.8) · spec 12 v1.0.** Docs only; nothing tested in Studio. Every value is `[VERIFY in Play]`. Detail lives in `art/vfx/atmosphere-pass.md` v0.2 (§ refs "AP") and `art/vfx/atmosphere-events.md` v0.2 ("EV").
**Build order `[D49]`:** L1 → L2 → L3 → L4 (only if time allows) → L5. Out of launch: Blood Moon (+ paid gift), Rift Storm, Eclipse, Tolling, Witch-Lights, UI skin (Update 1); custom textures (P1, Eudai `[D23]`).

## L1 Lantern pools + night grade (AP §2)
- **Lighting:** ClockTime 0 · Brightness 1.5 · Ambient (60,62,70) · **OutdoorAmbient (95,98,108)** `[D43]` · Exposure +0.3 · ColorShift_Top (22,24,30) · Bottom (0,0,0) · EnvDiffuse 0.4 / Specular 0.2 · GlobalShadows true · FogStart 250 / FogEnd 1100 / FogColor `#282A30`.
- **Atmosphere:** Density 0.18 · Haze 0.3 · Offset 0 · Glare 0 · **Color `#282A30`** `[D44]` · Decay `#0B0A0C`.
- **Grade (CC):** +0.03 / +0.12 / −0.18, Tint (240,244,250). **Bloom** 0.45 / 28 / 1.5. SunRays off. No DoF/Blur.
- **Plot lights (cap 8):** lit D2 wall candles `#FFB36B` range 16 / 1.4; altar fill 32 / 0.7; gate exterior lantern (−9,7,+61) 16 / 1.4 replaces the candle nearest the gate (net 0); Hodag tutorial lantern 14 / 1.0 swaps with the Wild-Gate candle during goal 3 (net 0). All Shadows off. Far-plot light LOD: other plots' PointLights off beyond 200 studs.
- **Town lights = 24 of 24:** Well 1 (28 / 0.6) + inner ring ≤ 11 (16 / 1.2, every other post) + road mouths 8 (18 / 1.4) + live stalls 2 (14 / 1.2) + **Great Rift pit 1** (`#7FA34A`, 20 / 0.8; takes one inner-ring slot) + **Pedlar Rift lantern 1** (`#7FA34A`, **range 10, brightness 0.8, Shadows off**) `[D41]`.
- **Rift glow `[D41] [D42]`:** no Neon on belt / pit / Pedlar lantern. RiftDim `#4F6B34` Slate/Metal (SmoothPlastic only ≤ 0.3 thick), ≤ 10% of a surface. Fissure: the nearest lit wall candle (−59,7,0) recoloured `#7FA34A` 14 / 0.8 (net 0) + sparks Rate 2 Life 2 (4 alive). Pit sparks Rate 3 (6 alive); Pedlar cage sparks Rate 1 (2 alive).
- **Pass:** capture **#1 + #2 (NEXT)**; #2 verifies D44.

## L2 Tier smoke (AP §4)
`VFX_Emit_AshRise` moves to the flash (phase C), recoloured per tier, **texture set at runtime** to `rbxasset://textures/particles/smoke_main.dds` (the only allowlisted texture `[D46]`; templates keep no Content). Emit 6 / 10 / 16 / 24 (Common BoneDim→Ash · Uncommon Moss→Ash · Rare Silver→BoneDim · Epic Blood→BloodHover→Ash). Curve per AP §4. Same emitter, same counts: D14 unchanged.

## L3 Ground fog: `AmbienceRig` (AP §3)
- One client Part at camera XZ, 3 emitters (FogWisp, Mote, Firefly). Zones: Town r ≤ 120 · Lair · Road ≤ 330 · Wilds.
- **FogWisp** named `FogWisp`, attribute `AmbientFog = true`, Lifetime 6–8 s, **Rate ≤ 2/s** `[D45]`. Emitter `Rate` = 0; the rig spawns at the zone rate (Town 1.5 · **Lair 1.0** · Road 1.5 · Wilds 2.0) with `:Emit(1)` at a random point in the 80 × 80 box, **skipping points within 6 studs of any pad centre, and within 12 studs of the tutorial Hodag spawn (plot-local 0,0,−80) until the Hodag is caught** (G2). Rate ×0.5 with a wild creature within 20 studs. Rate ramps ≤ ±0.5/s.
- Mote Town 8 / Lair 6 / Road 4 / Wilds 5 (Life ≤ 2). Firefly Wilds 4, GoldBright.
- **Budget:** ambience ≤ 34 alive (worst zone), halved during reveals; world ≤ 200 (worst 180).
- Caveat: 6 studs clears the cryptid, not the pad rim (pad half-width 5.25). If capture E2 shows wisps on pads, raise to 9 (one constant).

## L4 Catch beat, only if time allows (AP §5)
Duck (Ambience ×0.6, Music ×0.4) → fog pulls in (`ShapeInOut` Inward, Emit 6) → ≤ 3 candles gutter (2 dips, < 3/s) → tier smoke + flash → circle burns in to tier colour → fog/sound return over 1.0 / 0.8 s. No new emitters, lights or Neon.

## L5 Fog Night, the only launch event (EV §1–§2, spec 12 §4–§5)
| Property | Baseline | **Fog Night** |
|---|---|---|
| Brightness / Exposure | 1.5 / +0.3 | 1.5 / +0.35 |
| Ambient / OutdoorAmbient | (60,62,70) / (95,98,108) | (62,64,70) / (98,100,108) |
| ColorShift_Top | (22,24,30) | (18,19,22) |
| Atmosphere Density / Haze / Color / Decay | 0.18 / 0.3 / **`#282A30`** / `#0B0A0C` | 0.18 / 0.3 / **`#34363C`** / `#282A30` |
| Sky StarCount / CelestialBodiesShown | 300 / true | 0 / false at peak |
| CC Bri / Con / Sat / Tint | +0.03 / +0.12 / −0.18 / (240,244,250) | +0.04 / +0.06 / −0.25 / (236,238,242) |
| Bloom | 0.45 / 28 / 1.5 | 0.55 / 36 / 1.4 |
| FogWisp Lair / Town / Wilds | 1.0 / 1.5 / 2.0 | **1.0 / 2.0 / 2.0** (Town/Wilds size 8–10, transp ≥ 0.84) |
| Mote / Firefly / bed | ≤ 16 / ≤ 8 / 0.5 | ≤ 12 / 0 / 0.45 (muffled wind, drips, low bell ~45 s) |
- **Phases:** OMEN **45 s** (bell sting; birds/wind → 0.2×; colour drifts 15%) → CROSSFADE **30 s** (Atmosphere 0–0.5 → Lighting 0.2–0.75 → CC 0.3–0.8 → sky booleans at 0.5 under a 1.2 s CC soften → Bloom/motes 0.6–1.0 → bed 0.4–1.0) → EVENT **5:00** (wisps "breathe" ±20% / 60 s, capped at 2.0) → RETURN **45 s** (reverse order). Abort/shutdown = RETURN from the current blend, never a snap.
- **Driver:** one client module, Heartbeat at 10 Hz (High) / 5 Hz (Low), from replicated `PhaseStart`/`PhaseLength` (`GetServerTimeNow`); join mid-event applies the blend during loading.
- **Epic moment during an event `[D48]`:** Contrast +0.06 and Bloom +0.1 for 4 s only; no tint, no Atmosphere change.
- **Captures E1–E3** (capture plan §3) when the build lands.

## effectsQuality Low and Reduced Motion (all layers)
| | Low (`effectsQuality` Low / Auto < 4) | Reduced Motion |
|---|---|---|
| Fog | **lair 0 (off)** `[D47]`; Town/Road/Wilds ×0.5, size ≤ 6 (Fog Night Low: 0 / 1.0 / 1.0) | Speed ×0.5; no breathing; no fog pull |
| Other | Bloom off; motes ×0.5; fireflies off; driver 5 Hz; no sky soften pulse; far-plot LOD 120 studs | colour crossfades still run; fireflies blink only; no catch-beat pull-in; titles fade only |
| Budget | Fog Night Low ambience ≤ 14 alive; world worst case 169 ≤ 200 | – |
