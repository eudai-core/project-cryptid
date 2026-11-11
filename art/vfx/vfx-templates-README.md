# VFX templates (P0 set, built box-side)

**Folder:** `art/vfx/templates/` (box). **In game (proposed):** `ReplicatedStorage.Assets.VFX.<TemplateName>`, cloned by the `Vfx/*` client modules (`vfx-audio-plan.md` v0.2 §7). Handoff: `art/handoff/VFX-P0.md`.
**Status (4 Nov 2026):** 17 P0 templates built, validated and round-tripped through Rojo 7.7.1 and 7.4.4 (throwaway project, 0 property differences). **Not yet opened in Studio.** Built-in/Part-based only `[D23]`; no uploads, no asset IDs, no scripts.

## Naming
`VFX_<Group>_<Name>[_<Tier>]`, PascalCase, one effect per file. Groups: `Reveal`, `Emit` (one emitter on an Attachment), `Beam`, `Collect`, `Pad`, (P1) `Aura`.
Every template is a **Model** whose `PrimaryPart` is an invisible, non-colliding `Root` part; the pivot sits at ground level. Pivot the Model to the target and clone children as needed.
Child names the code relies on: `Root`, `Ring1_01…`, `Rune_01…`, `Seal_01…`, `CandleSocket1…n`, `RevealLight`, `FlameTip`, emitters named after the template (`AshRise`, `RevealBurst`…), `Bottom`/`Top` (beam attachments), `Pillar` / `PillarEdge` + `PillarCore` (beams), `Burst` + `CoinFlecks`, `GlowSurface`/`GlowRing`, `Chalk_01…`, `Crack_01…`.

## Attributes
| Where | Attribute | Type | Meaning |
|---|---|---|---|
| every template Model | `VFX_Version` | string | "1.0" for this set |
| every template Model | `Notes` | string | how to trigger it (one paragraph, plain English) |
| every template Model | `FallbackCut` | bool | true = in the fallback cut (P0-1, slim P0-2, P0-6) |
| circles | `Tier`, `RevealSeconds`, `PhaseA`, `PhaseB`, `HitStop`, `PhaseC`, `PhaseD`, `CandleCount`, `RingCount` | | timings from plan §2.2 |
| `RevealLight` | `PeakBrightness`, `MaxSeconds` (1.5) | number | `[D17]` |
| each ParticleEmitter | `EmitCount` or `EmitCount_Common/Uncommon/Rare/Epic` | number | burst size for `:Emit(n)` |
| `VFX_Emit_RevealBurst` | `TierColor_<Tier>` (hex), `LightEmission_<Tier>` | | set Color/LightEmission per tier before emitting |
| others | `Height`, `GrowSeconds`, `EmitSmall/Medium/Large`, `RiseStuds`, `Seconds`, `IntervalSeconds`, `MaxVisible`, `CarveSeconds`, `GlowSeconds`, `AshEmit`, `LeanDegrees`, `IgniteSeconds` | | per template, see Notes |

## Templates
| File | Parts | Contents |
|---|---|---|
| `VFX_Reveal_Circle_Common` | 19 | 1 Bone chalk ring r 3.6 (18 segments) |
| `VFX_Reveal_Circle_Uncommon` | 31 | ring + 12 Moss runes r 4.25, 3 CandleSockets, RevealLight (range 10) |
| `VFX_Reveal_Circle_Rare` | 67 | rings r 2.4 / 3.6 (Silver) / 4.8, Silver runes, 5 sockets, RevealLight (range 12, Silver) |
| `VFX_Reveal_Circle_Epic` | 74 | 3 rings (outer Gold), Gold runes, Blood {7/3} seal, 7 sockets, RevealLight (range 16) |
| `VFX_Reveal_Candle` | 6 | Part-based candle + flame parts, `FlameTip` attachment |
| `VFX_Emit_AshRise` / `RevealBurst` / `GoldLeaf` / `EmberRise` / `RiftSpark` / `CandleFlame` | 1 each | one ParticleEmitter (Shape Box, `Enabled=false`, Rate 0 except CandleFlame) parented to `Root`; reparent it to any Part/Attachment |
| `VFX_Beam_LightPillar_Rare` / `_Epic` | 1 each | `Bottom`/`Top` attachments + 1 Beam `Pillar` (Rare) / 2 Beams `PillarEdge`+`PillarCore` (Epic), `Enabled=false`, no texture |
| `VFX_Collect_CoinSigil` | 6 | Coin/Groove/Face/Sigil/SigilEye parts + `Burst` attachment with `CoinFlecks` |
| `VFX_Collect_PadPop` | 1 | BillboardGui + TextLabel "+$" (Oswald Bold, GoldBright) + UIStroke |
| `VFX_Pad_Carve` | 26 | chalk ring r 3.9 at pad top + 6 ticks + `GlowRing` SurfaceGui |
| `VFX_Pad_Deny` | 5 | 4 Void cracks |
Budgets per effect: `templates/effects.json` (checked by `validate_rbxmx.py --effects`).

## Rules (checked by the validator)
`--vfx`: `VFX_Version` + `Notes` present, `VFX_` name prefix, allowed classes only, **no Neon**, **no scripts**; emitters explicitly `Enabled=false`, Rate ≤ 10, Lifetime ≤ 2, every emitter declares its Emit count; ≤ 6 emitters and ≤ 120 particles per effect `[D14]`; ≤ 2 Beams; ≤ 1 light with Shadows off; palette colours only (no purple/blue); no custom Content (textures stay the built-in class default).

## Tools
`art/tools/build_vfx.py` (build) · `rbxlib.py` (writer, `Inst` class) · `rbx_vfx_schema.json` (property snapshot, rbx-dom db 0.741) · `test_vfx_encoding.py ROJO_BIN` (encoding vs Rojo) · `validate_rbxmx.py --vfx` / `--effects` · `vfx_budget.py` · `preview_parts.py` (`VIEWS=` override).
