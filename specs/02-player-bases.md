# Spec 02: Player Bases (one lair plot per player)

**Owner:** Cryptid Growth Strategist · **Builder:** Cryptid Systems Architect · **Status:** Draft v1.3 (2026-11-04: v1.3 audit fix, belt spawn independence + "Details" button + QA 16. v1.2: Rift Fissure trim is RiftDim, no Neon, per D38; pad prices × 1.5^r and steal hooks marked Update 3, from spec 11 §11. v1.1 2026-11-04: tutorial Hodag is now spec 01 v2 goal 3; v1 2026-11-03)
**Builds on:** Spec 01 v1.2. **Paid products:** none. **Paid randomness:** none.

> **v1.2 change (Wed 4 Nov 2026, Art Director D38–D40, relayed by Grok Bot; `/workspace/project-cryptid/art/style-guide.md` v0.7):** the Rift Fissure's Neon Rift-green trim is **removed**. It is now **RiftDim `#4F6B34`** trim (Slate / Metal / SmoothPlastic) with **PointLight + particle glow** and tiny Rift `#7FA34A` accents (spec 01 v2.1 A4). **No Neon in the plot** except the two cryptid-eye exceptions (Mothman Hatchling, Dover Demon; D10, D13).
> - **v1.3 (compliance audit (`compliance-audit-cash-random.md` §4; Grok Bot approved, 4 Nov; cash = paid currency)):** Rift Fissure spawns never depend on purchases; odds button "Details"; QA 16.
> - **From spec 11 v1 §11 (approved by Grok Bot as the design base, 4 Nov):** §3 pad prices become `price × 1.5^r` after r rebirths (Masons' Rite −10% still applies). §8 steal hooks will be filled by spec 11 §5.4 "Echo theft" in **Update 3 (Fri 11 Dec), which needs a fresh review then**; nothing about stealing is built or expanded now.

> **[A]** = design assumption to tune after playtest. Eudai's playtest feedback: players expected **separate bases**. This spec makes every player's lair its own walled plot.

---

## 1. Goal and fantasy
Each player owns a **walled occult lair** on the edge of a fog-bound town. You can see the other lairs, their candles and their pads. Later you'll be able to raid them and they'll be able to raid you. *"This is my lair, and it's worth guarding."*

## 2. World map (all specs share this)

```
                 THE WILDS (outer ring, r > 330 studs)
        ┌──────────────────────────────────────────────┐
        │   [P8]        [P1]        [P2]               │
        │        \        |        /                   │
        │  [P7] ── TOWN CENTRE (r ≤ 120, spec 03) ── [P3]
        │        /        |        \                   │
        │   [P6]        [P5]        [P4]               │
        └──────────────────────────────────────────────┘
```

- **Origin (0, 0, 0)** = centre of the Town (the Weeping Well, spec 03).
- **8 plots** in a ring. Plot *i* (1–8) centre: angle `θ = (i − 1) × 45°` (0° = +Z, clockwise seen from above), **radius 260 studs**.
  - Position: `x = 260 × sin θ`, `z = 260 × cos θ`, `y = 0`.
- Each plot's **Lair Gate faces the Town** (plot rotated so its local +Z points to origin).
- A cobbled **road** runs from each Lair Gate to the Town edge (r = 120).
- Each plot has a **Wild Gate** at the back, leading into the Wilds (r > 330), where hunting happens (spec 01 v2 goal 3 tutorial spawn = 20 studs outside the player's own Wild Gate).

| Setting | Value |
|---|---|
| `Players.MaxPlayers` | **8** (= plot count, so a player never lacks a plot) |
| Plot footprint | **120 × 120 studs** |
| Gap between neighbouring plots at r = 260 | ≈ 79 studs (chord 199 − 120) |
| Wall height | 14 studs (Basalt, crenellated) |

## 3. Plot layout (local coordinates)

Local origin = plot centre. **+Z = toward the Town (front)**, −Z = toward the Wilds (back). Units: studs.

```
            FRONT (toward Town)  +Z
   ┌───────────[ LAIR GATE ]───────────┐  z = +60
   │  Spawn (0, 0, +48)                │
   │  Owner banner on gate             │
   │                                   │
   │      P1    P12    P2              │
   │   P11    ╭───────╮    P3          │
   │ RIFT    │  BONE  │                │
   │ FISSURE │ ALTAR  │      P4        │  ring of 12 pads, r = 28
   │ (x=-50)  ╰───────╯                │  around altar at (0, 0, -4)
   │   P10                P5           │
   │      P9    P8     P6  [P7]        │
   │                                   │
   │ D1                            D2  │  defence sockets (later)
   └───────────[ WILD GATE ]───────────┘  z = -60
            BACK (toward Wilds)  −Z
   D3 / D4 = front corners (±54, +54); D1 / D2 = back corners (±54, −54)
```

| Element | Local position | Notes |
|---|---|---|
| **Lair Gate** (front) | (0, 0, +60), opening 16 wide | Owner banner + name, crimson cloth |
| **Spawn point** | (0, 0, +48), facing −Z | Player spawns here on join and on reset |
| **Bone Altar** | (0, 0, −4) | Spec 01 altar; levels show as extra bone tiers |
| **Pads 1–12** | ring radius 28 around altar. Pad *k* angle `(k − 1) × 30°`, 0° = toward the gate (+Z), clockwise | Pad 1 is nearest the gate |
| **Rift Fissure** (personal conveyor) | belt from (−50, 0, +40) to (−50, 0, −40), runs toward the back | Spec 01 onboarding conveyor lives here. Trim **`RiftDim` `#4F6B34`** (non-Neon, no Bloom catch) + 1 Rift-tinted PointLight (counts toward the 8-light plot cap, D39) + particle glow; tiny `Rift` `#7FA34A` accents only (v1.2, D38). **No Neon in the plot** except the Mothman Hatchling / Dover Demon eye parts (D10, D13). **Belt independence (audit fix):** the belt's spawn timer (1 every 10 s) and its rolls **never depend on purchases**: no refill-on-buy, no faster respawn after buying, no capacity block that a purchase frees. Buying only takes the shown cryptid. Odds button on the belt: **"Details"** (word, not a bare icon) opening the live spec 09 §4 table (v1.3) |
| **Wild Gate** (back) | (0, 0, −60), opening 12 wide | Leads to the Wilds |
| **Defence sockets D1–D4** | (−54, 0, −54), (54, 0, −54), (54, 0, 54), (−54, 0, 54) | Empty plinths now. Ward Candles go here (later spec) |
| **Reliquary** (steal target zone) | the pad ring itself | Hook only, see §8 |
| **Threshold** | invisible box filling the plot, 120 × 30 × 120 | Used for protection and intrusion events |

**Pad unlock costs** (same as spec 01, extended):

| Pad | Cost | Status in this build |
|---|---|---|
| 1 | owned (starter) | live |
| 2 | free | live |
| 3 | $120 | live |
| 4 | $400 | live |
| 5 | $1,200 | live |
| 6 | $3,000 | live |
| 7–8 | $15,000 / $40,000 (spec 07) | live after onboarding |
| 9–10 | +2 Pads pass only (spec 09) | "Sealed" without the pass |
| 11–12 | sealed | Cracked sigil and "Sealed" (`BoneDim`) |

**After r rebirths (v1.2, spec 11 §2.2):** every pad price is `price × 1.5^r` (rebirth 1 ×1.5, 2 ×2.25, 3 ×3.38 … 7 ×17.09); Masons' Rite −10% applies after the multiplier.

## 4. Plot assignment

**On join (server):**
1. Wait for profile load (spec 01 rules: retry 3×, kick on failure).
2. If the player had a plot **reserved** in this server (see Leave), give it back.
3. Else if a **friend** is in the server, take the free plot closest to that friend's plot (fewest steps around the ring). [A]
4. Else take the **lowest-numbered free plot**.
5. Build the plot from the saved profile (unlocked pads, cryptids on pads, altar level), set the owner banner, then spawn the player at the plot's spawn point.
6. Set the player attribute `PlotIndex` (1–8) so clients can find it.

**On leave (server):**
1. Save the profile (spec 01 save rules).
2. **Reserve** the plot for that UserId for **30 s** [A] (covers quick rejoin or a crash). The models stay but stop earning.
3. After 30 s: destroy the owner's models (cryptids, banner, altar tiers), reset pads to the empty template and mark the plot free.

**No plot data is saved.** Which plot you get can change between servers; your layout (pads, cryptids, altar) is saved and rebuilt on any plot.

## 5. Moving spec 01 onto the plot
- **Every spec 01 object** (pads, altar, Rift Fissure, spawn, tutorial wild spawn, gold guide beam targets) is now **per-plot**, parented under `Workspace.Plots.Plot<i>`.
- The guide beam points at objects **inside the player's own plot** (or out the Wild Gate for goal 3, spec 01 v2).
- The cash plaque, goal banner and income math are unchanged.
- Income is credited only while the owner is in the server (no offline earnings in this build).

## 6. Visiting and protection
- Players **can walk into other plots** after their own onboarding is done (spec 01 step 8 or 5:00).
- **Protection (spec 01 rule):** a player who hasn't finished onboarding (step < 8 and < 5:00 playtime) has a **sealed Threshold**: other players are pushed back at the Lair Gate with "A warding seal holds this lair." (`BoneDim` toast). Their gate shows a faint `Rift` green seal.
- Visitors can't interact with anything in another plot in this build (no prompts are shown to non-owners).

## 7. UI and look
- **Owner banner** above the Lair Gate: player display name in `GrenzeGotisch`, `Bone` on `Blood` cloth with `Gold` trim. Own plot shows "Your Lair".
- **HUD button "Return to Lair"** (bottom-left, `Soot` with `Gold` stroke): teleports you to your spawn point. Cooldown **10 s** [A].
- **Plot marker:** a thin `Gold` beam above your own Lair Gate, visible from the Town (so you can find home).
- Materials as spec 01 v2.1 A4: Slate/Basalt floor and walls, CorrodedMetal pad rings, candle PointLights on the walls every 20 studs (plot cap 8 lights, D39), RiftDim Fissure trim (no Neon).
- Plots that aren't owned show an **"Unclaimed Lair"** banner, gates shut, no lights.

## 8. Steal and defend hooks (no gameplay yet)
**Update 3 only (Fri 11 Dec), fresh review needed then.** Spec 11 §5.4 ("Echo theft": never takes an owned cryptid) is the approved outline that will fill these hooks; it is **not** built, priced or expanded before that review. Build these as stubs so the steal/defend spec only fills them in:

| Hook | Shape | Now |
|---|---|---|
| `Plot.Threshold` touched by a non-owner | server event `PlotIntruded(plotIndex, intruder)` | fires, logged only |
| `StealGuard.canSteal(thief, victim)` | returns false if either player is under protection (spec 01) | exists from spec 01; always false in this build |
| Defence sockets D1–D4 | `Attachment`s named `DefenceSocket1..4` | empty |
| Pad state `beingStolen` | bool attribute on each pad | always false |
| Saved `base.defences` | map socket → defenceId | saved empty `{}` |

## 9. Data to save (additions)

| Key | Type | Notes |
|---|---|---|
| `base.defences` | map int → string | `{}` for now |
| (existing spec 01 keys) | – | unchanged: `padsUnlocked`, `pads`, `cryptids`, `upgrades.boneAltar`… |

- Bump `dataVersion` by **1**; the migration adds `base.defences = {}`. Nothing else changes.
- **Not saved:** `PlotIndex`, reservation timers.

## 10. Server vs client
- **Server owns:** plot assignment and reservation, building/clearing plot models, Threshold seal, the teleport, all spec 01 economy.
- **Client owns:** reading `PlotIndex`, the HUD button, the home beam, toasts.
- `RequestReturnToLair()` is the only new remote. Server checks the cooldown.

## 11. Monetisation hooks
None in this build. Future (not now): cosmetic lair themes, extra defence sockets. Any paid item needs Eudai's approval first.

## 12. Edge cases
1. **Server full:** can't happen (`MaxPlayers` = 8 = plots). If it somehow does, kick with "No lair stands empty. Try another server."
2. **Rejoin within 30 s:** gets the same plot back, built from the saved profile.
3. **Rejoin after 30 s:** gets any free plot; layout identical.
4. **Player falls off the map / resets:** respawns at their own spawn point.
5. **Visitor inside a plot when its owner leaves:** after the 30 s clear, the visitor is teleported to the Town edge on that plot's road.
6. **Onboarding player sealed:** visitors pushed out; the onboarding player can still leave and come back.
7. **Two players join in the same frame:** server assigns plots in one queue, so no plot is given twice.
8. **Profile fails to load:** player is kicked before a plot is assigned; no plot is held.
9. **Friend logic:** the friend check is best-effort; if it fails, fall back to lowest free plot.

## 13. Acceptance tests (QA)

| # | Test | Pass if |
|---|---|---|
| 1 | 1 player joins | Gets Plot 1 at (0, 0, 260); spawns at its gate, facing the altar |
| 2 | 8 players join | Each has a different plot; all 8 banners show the right names |
| 3 | Plot positions | Plot *i* centre within 1 stud of `(260 sin θ, 0, 260 cos θ)`, θ = (i−1)×45° |
| 4 | Gate faces Town | Every Lair Gate's front points to (0, 0, 0) |
| 5 | Pad ring | 12 pads, radius 28 ± 0.5 around the altar; Pad 1 nearest the gate |
| 6 | Spec 01 run on Plot 5 | All spec 01 tests 1–20 pass on a plot other than Plot 1 |
| 7 | Leave and rejoin in < 30 s | Same plot, same pads, cash and cryptids |
| 8 | Leave and wait 35 s | Plot shows "Unclaimed Lair"; another joining player can get it |
| 9 | Layout carries across plots | Rejoin onto a different plot: identical pads, cryptids and altar level |
| 10 | Onboarding seal | A finished player can't walk past an onboarding player's Lair Gate; sees the toast |
| 11 | Visiting | Two finished players can walk into each other's plots but see no interaction prompts |
| 12 | Return to Lair | Teleports to own spawn; second press within 10 s is refused |
| 13 | Sealed pads | Pads 7–12 show "Sealed" and can't be bought |
| 14 | Hooks exist | `PlotIntruded` fires when a visitor enters; `DefenceSocket1..4` exist on every plot; `base.defences` saves as `{}` |
| 15 | Income only while present | Owner leaves: their income stops; rejoin resumes from saved cash |
| 16 | Belt independence (v1.3) | Buy every belt offer the moment it appears for 10 min, then 10 min without buying: spawn timestamps are every 10 s ± 0.1 s in both runs, and no spawn ever follows a purchase early |
