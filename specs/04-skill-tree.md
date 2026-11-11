# Spec 04: Occult Skill Tree (full-screen UI)

**Owner:** Cryptid Growth Strategist · **Builder:** Cryptid Systems Architect · **Status:** Draft v1.1 (2026-11-04: audit fix, h5/h6 sealed until deterministic. v1 2026-11-03)

> **v1.1 change (compliance audit (`compliance-audit-cash-random.md` §4; Grok Bot approved, 4 Nov; cash = paid currency)):** `h5` Lure Craft (spawn rate) and `h6` Blood Tracker (rarity chance) are cash-bought probability modifiers, so they are **sealed until deterministic (U2)**: their effects must be replaced with fixed effects before Ring 2 ships. `h3` Keen Eye stays sealed (spec 05).
**Builds on:** Specs 01–03. **Paid products:** none. **Paid randomness:** none.

> **[A]** = design assumption to tune after playtest. Eudai's playtest feedback: they expected **a UI skill tree**. This is a **ScreenGui**, never world parts.

---

## 1. Goal and fantasy
You open a **ritual circle chalked on black stone**. Your **Hunter** rites spread left and your **Lair** rites spread right. Buying a rite **ignites** its sigil and the chalk path to it turns into a **glowing blood vein**. *"I'm carving my own path through forbidden knowledge."*

## 2. Opening and closing
- **HUD button "Rites"** (bottom-left, next to "Return to Lair", spec 02). Hotkey **K** (desktop) / gamepad **Select**.
- **Skill Shrine** prompt in Hollowmere (spec 03), "Kneel at the shrine".
- Both unlock after onboarding step 8 (spec 01). Before that, the button is hidden.
- **Close:** "Close the circle" button top-right, **Esc**, or gamepad **B**.
- Opening fades the HUD out and the circle in (0.25 s, spec 01 motion); character controls are disabled while it's open.

## 3. Screen structure

| Layer | Object | Setup |
|---|---|---|
| Root | `ScreenGui "SkillTree"` | `IgnoreGuiInset = true`, `ResetOnSpawn = false`, `DisplayOrder = 20`, `Enabled = false` |
| Backdrop | full-screen Frame | `Void` `#0B0A0C`, 0 transparency |
| Viewport | Frame, full-screen, `ClipsDescendants = true` | Receives pan/zoom input |
| Canvas | Frame **2800 × 2800 px**, `AnchorPoint (0.5, 0.5)`, + `UIScale` | Holds circle art, paths and nodes. Canvas centre = root node |
| Header | top-left | `Rites of the Circle` (`GrenzeGotisch` 36/28, `Bone`) + current cash (`Oswald`, `GoldBright`) |
| Branch labels | on canvas | `HUNTER` at (−700, −420), `LAIR` at (+700, −420), `GrenzeGotisch` 48, `Gold` 40% transparency |
| Tooltip | Frame above canvas (not scaled) | §6 |

**Circle art on the canvas:** chalk rings (`Bone`, 70% transparency, 3 px) at radius **240, 600, 960, 1240** around the centre; a ring of rune glyphs between 1180 and 1240; faint stone texture [asset TBD; flat `Ash` fill works].

## 4. Pan and zoom

| Setting | Value |
|---|---|
| Default zoom (`UIScale.Scale`) | **0.5** (whole circle visible on 1280 × 720) |
| Min / max zoom | **0.35 / 1.5** |
| Wheel step | ×1.1 per notch, zooms toward the cursor |
| Pinch (touch) | continuous, zooms toward the pinch centre |
| Pan | left-drag / one-finger drag / right stick (600 px/s at zoom 1) |
| Pan limit | root node can't move more than **1300 canvas px** from screen centre |
| Reset | double-click empty space or gamepad **Y** → back to default, 0.3 s Quad Out |
| Drag threshold | 6 px before a press counts as a drag (so taps still select nodes) |

## 5. Nodes

### 5.1 Node list and costs [A: seed costs, pacing spec retunes]
Canvas coordinates are px from the root, **x right, y down**.

| Id | Name | Branch | Position (x, y) | Requires | Cost | Effect |
|---|---|---|---|---|---|---|
| `root` | **The Kindling** | – | (0, 0) | – | owned free | Starts the circle |
| `h1` | Steady Hand | Hunter | (−240, 0) | root | $1,000 | Catch time **−10%** |
| `h2` | Long Reach | Hunter | (−420, −140) | h1 | $2,500 | Catch range **+2 studs** (12 → 14) |
| `h3` | Keen Eye | Hunter | (−420, 140) | h1 | $6,000 | Wild cryptids within **40 studs** get a faint outline (hook if the Wilds aren't built) |
| `h4` | Quiet Step | Hunter | (−600, −200) | h2 | $15,000 | Catch time **−15%** more (total −25%: 3 s → 2.25 s) |
| `h5` | Lure Craft | Hunter | (−600, 200) | h3 | $30,000 | ~~Wild spawn rate +10%~~ **Sealed until deterministic (U2)** |
| `h6` | Blood Tracker | Hunter | (−780, 0) | h4 **or** h5 | $75,000 | ~~Wild Uncommon-or-better chance ×1.05~~ **Sealed until deterministic (U2)** |
| `h7` | Expedition Lore | Hunter | (−960, 0) | h6 | $150,000 | Expedition time **−10%** (hook) |
| `h8` | **The Hunter's Mark** (capstone) | Hunter | (−1160, 0) | h7 | $400,000 | Income from cryptids with `source = "wild"` **+25%** |
| `l1` | Warm Hearth | Lair | (240, 0) | root | $1,000 | All income **+5%** |
| `l2` | Masons' Rite | Lair | (420, −140) | l1 | $2,500 | Pad unlock costs **−10%** (rounded to nearest $1) |
| `l3` | Altar Devotion | Lair | (420, 140) | l1 | $6,000 | Bone Altar per level **+0.30** instead of +0.25 |
| `l4` | Deep Coffers | Lair | (600, −200) | l2 | $15,000 | All income **+10%** |
| `l5` | Ward Lore | Lair | (600, 200) | l3 | $30,000 | Defence strength **+10%** (hook) |
| `l6` | Bound Pact | Lair | (780, 0) | l4 **or** l5 | $75,000 | All income **+15%** |
| `l7` | Grim Vigil | Lair | (960, 0) | l6 | $150,000 | Time for thieves to steal from you **+20%** (hook) |
| `l8` | **Heart of the Lair** (capstone) | Lair | (1160, 0) | l7 | $400,000 | All income **+25%** |

**Total to own everything:** $679,500 per branch, **$1,359,000** total.

**"Hook"** means the effect is saved and exposed as a value (e.g. `SkillEffects.wildSpawnRateMult = 1.10`) but does nothing until its system ships. The tooltip says **"Dormant until the Wilds awaken"** (or the Expeditions / Defences equivalent) in `BoneDim`, so players know before buying.

### 5.2 Effect stacking (server)
- `income = Σ pad base income × altarMult × (1 + skillIncome)`
  - `altarMult = 1 + perLevel × boneAltarLevel`, `perLevel` = 0.25, or 0.30 with `l3`
  - `skillIncome` = sum of owned `l1 l4 l6 l8` = up to **0.55**
  - `h8` adds +0.25 **only** to wild-source cryptids, added inside `(1 + skillIncome + 0.25)` for those pads
- `catchTime = 3.0 × (1 − 0.10·h1 − 0.15·h4)`, minimum 2.25 s
- `catchRange = 12 + 2·h2`
- Pad cost with `l2`: `round(cost × 0.9)` → Pad 5 $1,080, Pad 6 $2,700

### 5.3 Node states and look

| State | When | Look |
|---|---|---|
| **Locked** | Requirement not owned | **Cracked stone**: `Soot` disc, `BoneDim` 2 px stroke, crack overlay [asset TBD; fallback 2 thin `Void` lines], sigil glyph at 60% transparency, small lock glyph |
| **Available** | Requirement owned, node not owned | **Pulsing candle**: `Ash` disc, `Gold` stroke 3 px pulsing transparency 0.2 ↔ 0.6 (1.6 s sine loop), small flame ImageLabel flickering, sigil `Bone`. If unaffordable, the pulse stays but the price in the tooltip shows `Need $X more` |
| **Owned** | Bought | **Ember red with sparks**: `Blood` `#7A0F12` fill, `GoldBright` 3 px stroke, sigil `Bone`, ember sparks (§5.4) |

| Size | Value |
|---|---|
| Normal node | 96 × 96 px (canvas px) |
| Capstone / root | 128 × 128 px |
| Hit area | node size + 16 px padding |

### 5.4 Particles (UI, not ParticleEmitters)
- **Owned sparks:** `GoldBright`/`BloodHover` ImageLabels, spawn **2 per second** per owned node, rise 30 px while fading over 1.2 s, **max 6 alive per node**, max **60 sparks on screen** (oldest removed).
- Pause all spark loops when the tree is closed.

## 6. Paths

| Path state | When | Look |
|---|---|---|
| **Chalk** | Child locked | `Bone` 70% transparency, 4 px, dashed (12 px dash / 8 px gap) |
| **Bright chalk** | Child available | `Bone` 35% transparency, 4 px, solid |
| **Blood vein** | Parent **and** child owned | `Blood` 6 px core + `BloodHover` 12 px glow at 60% transparency; `UIGradient` offset loops 0 → 1 every 2 s so light "flows" outward from the root |

- Paths are straight lines drawn as rotated Frames between node centres (parent → child).
- `h6` and `l6` have **two** incoming paths; each turns to vein when its own parent and the child are owned.

## 7. Tooltip (parchment + wax-seal BUY)
- Shows on **hover** (desktop) or **tap** (mobile/gamepad select). Tap elsewhere to close.
- Sits beside the node, flips to stay on screen. Size **340 × 220 px**, not affected by zoom.
- **Parchment:** fill `Bone` `#E8E0CF` with paper texture [asset TBD], ragged edge, 1 px `Gold` stroke. **Text is `Void`** (dark on light).

| Line | Content | Font |
|---|---|---|
| Title | e.g. `Quiet Step` | `GrenzeGotisch` 26 |
| Branch | `Hunter rite` / `Lair rite` | `Merriweather` 14, `Blood` |
| Effect | e.g. `Catch time −15% (total −25%)` | `Merriweather` 16 |
| Dormant note (hooks only) | `Dormant until the Wilds awaken` | `Merriweather` 14 italic, `Soot` |
| Requires (locked only) | `Requires: Long Reach` | `Merriweather` 14 |
| Cost | `$15,000` | `Oswald` 22, `Void` |

**Wax-seal BUY button:** a 76 px circle at the tooltip's bottom-right.

| State | Look | Text |
|---|---|---|
| Can buy | `Blood` wax disc, irregular edge, `Gold` sigil stamp | `BUY` (`GrenzeGotisch` 20, `Bone`) |
| Can't afford | `Soot` disc, cracked | `Need $X more` below the seal (`Merriweather` 14) |
| Locked | seal hidden | – |
| Owned | seal replaced by a burnt mark | `Bound` |
| Waiting for server | seal dims to 50% | – (blocks double buy) |

## 8. Ignite burst (on server confirm only)
Total **0.9 s**:
1. 0.00 s: node scales 1.0 → 1.25 → 1.0 (0.30 s, Back Out) and switches to **Owned**.
2. 0.00 s: `GoldBright` ring expands from 96 to 220 px while fading (0.45 s).
3. 0.05 s: **12 ember images** shoot outward 60–90 px at even angles ±10° jitter, fading (0.5 s).
4. 0.20 s: the incoming path fills from parent to child, turning from chalk to vein (0.6 s Linear).
5. Sound: match strike + low whoosh [asset IDs TBD].
6. Any child nodes that just became **Available** start pulsing after 0.9 s.

**Reduced Motion (spec 01):** skip scale, ring, embers, flowing gradient and sparks; just swap colours with a 0.15 s fade.

## 9. Data to save

| Key | Type | Notes |
|---|---|---|
| `skills` | array of node ids | `root` implied; e.g. `{"h1","l1","l2"}` |

Bump `dataVersion` by 1; migration adds `skills = {}`. Skills **survive rebirth** in this build [A: rebirth spec may change this].

## 10. Server vs client
- **Server owns:** costs, requirements (including the h6/l6 "or" rule), the onboarding gate, cash deduction, the `skills` list and **all effects** (`SkillEffects` module read by income, catch and pad cost code).
- **Client owns:** rendering, pan/zoom, tooltip, tweens and particles.
- Remote: `RequestBuySkill(nodeId)`. Server rejects if unknown id, already owned, requirement missing, not enough cash, onboarding not done, or within **0.25 s** of the last purchase (spec 01 debounce).
- On success, the server replicates the new `skills` list; the client plays the ignite burst **only after** that confirmation.

## 11. Monetisation hooks
None in this build. Do **not** sell skill nodes or respecs for Robux without a new spec and Eudai's approval.

## 12. Edge cases
1. **Buy with exactly enough cash:** allowed; cash goes to $0.
2. **Two quick taps:** seal is disabled while waiting; server debounce also blocks.
3. **Cash changes while tooltip open:** affordability updates live.
4. **h6 with only h5 owned:** allowed (either parent counts).
5. **Screen resize / rotate phone:** canvas stays centred on the same point; tooltip re-flips to stay on screen.
6. **Opening during a cutscene/death:** button does nothing until the character is alive.
7. **Unknown id in save (removed later):** ignore it, keep the rest, log a warning.
8. **Hook effects:** buying a dormant node is allowed and saved; its value is applied the moment the system ships.
9. **Low-end devices:** spark cap (60) and pausing on close keep it light.

## 13. Acceptance tests (QA)

| # | Test | Pass if |
|---|---|---|
| 1 | It's UI | The tree is a `ScreenGui`; no new parts appear in `Workspace` when it opens |
| 2 | Gate | Before onboarding step 8, "Rites" is hidden and the shrine refuses |
| 3 | Open/close | K, the HUD button and the shrine open it; Esc, B and the close button close it |
| 4 | Layout | 17 nodes at the §5.1 positions (±2 px at zoom 1) |
| 5 | Pan/zoom | Zoom clamps at 0.35 and 1.5; root can't be dragged more than 1300 px away; double-click resets |
| 6 | States | Fresh profile: `root` owned; `h1` and `l1` available (pulsing); all others locked (cracked) |
| 7 | Buy h1 for $1,000 | Cash −$1,000; h1 ember red with sparks; root→h1 path is a blood vein; h2 and h3 become available |
| 8 | Or-rule | Own h5 but not h4: h6 is available |
| 9 | Can't afford | Seal shows cracked with `Need $X more`; server refuses a forced remote |
| 10 | Effects | With l1 + l4: income ×1.15 vs without. With h1 + h4: catch takes 2.25 s. With l2: Pad 5 costs $1,080 |
| 11 | Altar Devotion | Altar II with l3: multiplier 1.60 instead of 1.50 |
| 12 | Hunter's Mark | +25% applies only to pads holding `source = "wild"` cryptids |
| 13 | Dormant notes | h3, h5, h6, h7, l5, l7 tooltips show the dormant line |
| 14 | Ignite | Burst plays only after server confirms; total ≈ 0.9 s |
| 15 | Reduced Motion | No scale, embers, sparks or flowing veins; colour fade only |
| 16 | Persist | Leave and rejoin: owned nodes and veins restored |
| 17 | Palette | Only theme tokens; no purple; parchment text is dark on light |
| 18 | Totals | Buying all 16 nodes costs exactly $1,359,000 |
