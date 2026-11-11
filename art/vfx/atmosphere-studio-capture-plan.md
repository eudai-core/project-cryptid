# Atmosphere Pass: Studio Capture Plan (veqtro)

**Version:** v0.1 (Wed 4 Nov 2026) · **Owner:** Art · **Runs on:** veqtro (Eudai's PC), Roblox Studio + its built-in MCP, **only when Studio and the MCP are available and Eudai approves the session**. Load the `roblox-studio-ops` skill first. **Nothing here has been captured yet. No results are claimed.**
**For:** `art/vfx/atmosphere-pass.md` (baseline, lanterns, rig, smoke, catch beat, UI) and `art/vfx/atmosphere-events.md` (Fog Night, Blood Moon).
**Save to:** `/workspace/project-cryptid/qa/screenshots/` as **`<Name>_<YYYY-MM-DD>_<view>.png`** (date = capture day; `<view>` = `before`, `after`, `omen`, `peak`, `return`, `mobile`…).
**Never** use these captures as store art unless the store-art task picks them under `[D12]`; never publish or upload anything.

---

## 0. Setup (once per session)
1. Open the place from the current Rojo build (Architect's branch). **Solo Play (F5)**, own plot claimed, onboarding finished unless the capture says otherwise.
2. **"Before" state** = the lighting/atmosphere currently in the build (style guide v0.5 values). **"After" state** = `atmosphere-pass.md` §2 values + `AmbienceRig`. The Architect provides one toggle (e.g. a `VfxConfig.atmospherePass` flag or a command-bar snippet that applies the profile table), so each pair is the **same camera, same frame, one switch**.
3. **Resolution:** desktop captures **1920 × 1080**; phone captures via Studio **Device Emulator → a small Android phone at 1280 × 720** (or the smallest landscape preset).
4. **Quality:** desktop Rendering Quality **Automatic → set to level 10** for desktop pairs; phone pairs at **level 1** (Low path in the rig: fireflies off, Bloom off).
5. **Dim-phone proxy:** every `mobile` capture also gets a box-side copy at **30% brightness** (`*_mobile30.png`, made on the box with Python, clearly labelled as a proxy). Readability pass/fail is judged on that copy.
6. Camera: use the default third-person camera unless "free camera" (Shift+P) is stated. Write the camera CFrame into the capture note.
7. Log every capture in a short table at the bottom of this file (name, date, pass/fail, note) after the session.

---

## 1. Must-do first
### #1 Hodag at the tutorial spawn (first catch ~0:33) — **NEXT: run when the Architect's build lands**
- **Scene:** fresh profile (onboarding at goal 3), own plot, **Wilds just outside the Wild Gate**. Hodag at its tutorial spawn, ≈ plot-local **(0, 0, −80)** `[VERIFY real CFrame]`. Hodag lantern (`HODAG-ONBOARDING.md`) **on if built**, and the fog clear zone (AP-11) on in "after".
- **Cameras:** (a) third-person, player standing in the Wild Gate opening (plot-local (0, 0, −60)) looking at the Hodag (≈ 20 studs); (b) player at 12 studs during the 3 s hold.
- **Settings / pairs:** before vs after, desktop + phone (level 1), and **after + Fog Night peak** (the worst case).
- **Files:** `ATMOS_HodagSpawn_<date>_before.png`, `…_after.png`, `…_mobile.png` (+ `_mobile30` proxy), `…_fognight.png`, `…_hold12.png`.
- **Pass if (all):** in the `_mobile30` proxy, (1) the Hodag's **outline** is separable from ground and fog along its whole back (box-side: mean luma of the body region differs from the 10-px surround by **≥ 12/255** `[P threshold]`); (2) the Bone horns/spikes and GoldBright eyes are visible; (3) **no fog wisp overlaps the Hodag** in any frame of a 10 s clip at 20 studs; (4) the gold guide beam stays visible; (5) the Common reveal at the hold still reads. **Fail →** raise the lantern brightness 1.0 → 1.3 first, then widen the clear zone, then OutdoorAmbient luminance +5. Never lower anything below D1.

### #2 Town platform → Town and lairs (QA near-black report) — **NEXT, verifies D44 (`#282A30`)**
- **Scene:** standing on the Town platform near the Well, looking (a) across the Town to a road mouth and (b) down a road to your own lair (r ≈ 200, front gate) with 2 other occupied plots in view.
- **Camera:** third-person at the Well's edge, camera ~12 studs behind, pitched slightly down; second shot aimed along Road P1 toward Plot 1.
- **Pairs:** before vs after (Atmosphere `#282A30`, Town lanterns §2.5, gate exterior lanterns). Desktop + phone.
- **Files:** `ATMOS_TownPlatform_<date>_before.png`, `…_after.png`, `ATMOS_TownToLair_<date>_before.png`, `…_after.png`, `…_mobile.png`.
- **Pass if:** (1) the lair **wall silhouettes** at 80–200 studs read against the sky/fog (luma difference wall vs. backdrop ≥ 10/255 `[P]`); (2) paths between lantern pools are never pure black (path mean luma ≥ 35/255 in `_mobile30` `[P]`) but the pools still read as separate warm areas; (3) your own Gold home beam is visible from the Town edge `[S03 test]`; (4) **PointLights in the Town ≤ 24** (count in Explorer) and each plot ≤ 8.

### #3 Dark-bodied cryptids on pads (don't let the grade swallow them)
- **Scene:** own lair at night, pads occupied by **Hidebehind, Beast of Bray Road, Jersey Devil, Loch Ness Serpent, Snallygaster, Jackalope, Loveland Frogman** + Hodag.
- **Camera:** spawn view (plot-local (0, 5, +48) looking −Z) and a 30-stud three-quarter view of each dark one.
- **Pairs:** before vs after, phone level 1 + `_mobile30`.
- **Files:** `ATMOS_DarkCryptids_<date>_before.png`, `…_after.png`, `…_mobile.png`, then `ATMOS_<CryptidName>_<date>_after30.png` per cryptid.
- **Pass if:** each silhouette recognisable in the 30% proxy (SG §4 tests 1–3); pad states (locked / empty / occupied) distinguishable; fog wisps never cover a cryptid's head/face.

---

## 2. Atmosphere pass captures
| # | Name / files | Scene + camera | Settings / pair | Pass if |
|---|---|---|---|---|
| 4 | `ATMOS_LairNight_<date>_before/after/mobile.png` | own lair, free camera high three-quarter from the front-left corner (as concept frame 1) | before vs after; desktop + phone | warm pools visible at the D2 candles with **cool gaps** between them; floor never black; ≤ 8 PointLights in the plot (Explorer count in the note); no Neon except the eyes; Rift trim shows **RiftDim** (not highlighter) |
| 5 | `ATMOS_GateLantern_<date>_before/after.png` | outside your Lair Gate on the road, 30 studs out | before vs after | the gate approach and banner read; plot light count unchanged (swap, net 0) |
| 6 | `ATMOS_WildsHunt_<date>_after.png`, `…_mobile.png` | Wilds near trees, third-person | after only (no "before" rig exists); phone level 1 shows fireflies off | fog wisps drift, never pop; fireflies GoldBright, no green; ambience alive ≤ 40 (Developer Console / particle count script) |
| 7 | `ATMOS_FogClearZone_<date>_after.png` | same as #1 (a), 10 s clip → 3 frames | after | no wisp within 12 studs of the spawn |
| 8 | `ATMOS_CatchBeat_<Tier>_<date>_A/C/D.png` for Common, Uncommon, Rare, Epic | wild catch near the Wild Gate; frames at A (fog pull), C (smoke + burn-in), D (smoke curling) | after; plus Epic with Reduced Motion on (`…_EpicRM_…`) | smoke colour matches tier (ash / moss / silver / blood), fades in and out (no popping sprite in any frame), chalk burns candle-orange → tier colour; candle gutter ≤ 3 dips/s; creature fully readable by the end of D; RM: no pull-in, no flicker beyond one dip |
| 9 | `ATMOS_UISkin_<date>_desktop/mobile.png` | Pedlar panel + a tooltip + the case wax seal before and mid-crack | after (built-in skin) vs current flat UI (`…_before`) | text ≥ 14 px and readable (Void on parchment); buttons ≥ 44 px; seal crack plays in ≤ 0.5 s; UI particles ≤ 60 |
| 10 | `ATMOS_RiftTrim_<date>_before/after.png` | Rift Fissure belt, 15 studs | before (Neon Rift) vs after (RiftDim, D38) | no yellow-green "highlighter" read; no Bloom on the trim; Rift ≤ 2% of the frame |

---

## 3. Event captures (`atmosphere-events.md` §6; spec 12 §14: **LAUNCH = E1–E3, Fog Night only** `[D49]`)
Use a debug command (Architect) that starts an event with **short timings**: omen 30 s, crossfade 20 s, event 60 s, return 30 s, so a full cycle fits in ~2.5 min. Same camera for every frame of one sequence.
| # | Files | Scene / camera | When | Pass if |
|---|---|---|---|---|
| E1 | `ATMOS_FogNight_<date>_before.png`, `…_omen.png`, `…_peak.png`, `…_return.png` | Town platform → own lair (camera from #2 b) | before = baseline; omen = end of omen; peak = 10 s into EVENT; return = end of RETURN | omen shift is subtle (≈ 15%); peak reads as **fog**, not darkness (luma of mid-ground ≥ baseline's); D1 values unchanged or higher (check Lighting in Properties); return matches before within tolerance (same values) |
| E2 | `ATMOS_FogNight_<date>_hodag.png`, `…_pads.png` | #1 camera (a) at peak; own lair with occupied pads | peak | #1 still passes; no wisp spawns within 12 studs of the Hodag spawn or 6 studs of a pad centre (G2); lair rate 1.0 (Low: 0) |
| E3 | `ATMOS_Crossfade_<date>_frametime.png` (MicroProfiler / Stats overlay screenshot) + numbers in the log | phone emulator, quality level 1, own lair with 10 occupied pads | during CROSSFADE_IN of Fog Night | see §4 |
| E3b | `ATMOS_JoinMidEvent_<date>_peak.png` | second Play client joining during EVENT | first frame after loading | snaps straight to the event look (no visible tween from baseline), no particle burst |

| U1-a (Update 1) | `ATMOS_BloodMoon_<date>_before/omen/peak/return.png` | own lair spawn view + one sky shot (`…_sky.png`) | as E1 | crimson, **no purple/magenta anywhere** (box-side: no pixel cluster with R > G and B > G by > 15 `[P]`); cryptids and pads readable in `_mobile30`; moon larger, no texture pop |
| U1-b (Update 1) | `ATMOS_BloodMoon_<date>_epic.png` | Epic catch during the Blood Moon peak | peak | the Epic sky moment is still noticeable (Contrast + Bloom only, `[D48]`); no stacking into a darker scene |
---

## 4. Low-end mobile frame-time check
- **Honest limit:** Studio's Device Emulator changes **screen size and input, not the phone's GPU/CPU**. So:
  1. **Studio proxy (always):** Rendering quality level 1, phone emulator, **MicroProfiler** and the **render stats overlay** (open them from Studio's View menu; keyboard shortcuts differ between Studio and the client `[VERIFY]`). Record frame time for 30 s in each of: (a) baseline before the pass, (b) after the pass held, (c) during a Fog Night crossfade, (d) during an Epic catch beat in the after state.
  2. **Real low-end phone (only if Eudai approves):** the same four runs in the existing private Cryptid TEST place on Eudai's phone. Syncing code into that place is Eudai-gated per the `roblox-studio-ops` skill; nothing is published to the public game.
- **Files:** `ATMOS_FrameTime_<date>_baseline.png`, `…_after.png`, `…_crossfade.png`, `…_catchbeat.png` (overlay screenshots) + numbers in the log below.
- **Pass if:** (1) the after state adds **≤ 2 ms** median frame time vs the baseline; (2) a crossfade adds **≤ 1 ms** vs the held profile; (3) **no frame > 50 ms** during a crossfade or catch beat; (4) on the real phone (if run): ≥ 30 fps p95 in the lair with 10 occupied pads; (5) world particles ≤ 200 and ambience ≤ 40 (Low: ≤ 20) at all times. **Fail →** Low-quality rig values become the phone default, then fog size ≤ 6, then far-plot light LOD at 120 studs.

---

## 5. Capture log (fill in after the session; empty until a real capture exists)
| File | Date | Pass/Fail | Notes |
|---|---|---|---|
| – | – | – | – |
