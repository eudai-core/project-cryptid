### ✅ APPROVED `[D39]`: Hodag tutorial-spawn lantern (spec 01 v2.0 goal 3) — approved design, nothing built yet
**Date:** Wed 4 Nov 2026 · **Owner:** Art · **Builder:** Systems Architect / Level · **Decision refs:** `[D33]`, **`[D39]`** · **Status: APPROVED by the Master Controller (4 Nov)**: plot light cap stays **8** (mobile first); the lantern is **lit only during goal 3**, and the **lit wall candle nearest the Wild Gate is off** for that window. Ready for the builder; sizes/brightness still tune in Studio. **No model change** (`art/models/Hodag.rbxmx` v1.0 untouched).

#### Why
Spec 01 v2.0 makes the Hodag the **first creature a new player hunts**: goal 3, guide beam out the Wild Gate, caught at **~0:33** (QA: caught ≤ 0:50, on Pad 3 ≤ 1:00). The Hodag is mostly **Soot** hide (dark) and is met **outside lair lighting**, in the Wilds, where fog wisps start `[S03]`. Lair candles light the inside of the walls, not the ground beyond the Wild Gate. So the first catch risks being a dark shape in fog on a phone.

#### Where (derived from specs; verify in Studio)
- Wild Gate: plot-local **(0, 0, −60)**, opening 12 wide `[S02]`. Tutorial spawn: **20 studs outside it** `[S01 v2 B3 #3]` → about plot-local **(0, 0, −80)** if "outside" means straight out the gate. `[VERIFY the real spawn CFrame in Studio]`
- Plot centre sits at r = 260 with local +Z toward the town `[S02]`, so the spawn is at about **r ≈ 340**, just inside the Wilds (r > 330).
- **Lantern position (proposal):** plot-local **(−5, 0, −76)**: beside the walk line from the gate, between the gate and the Hodag, ~6.4 studs from the spawn. It lights the Hodag's front three-quarter as the player walks out and doesn't sit on the guide beam's path or in the ≤ 12-stud hold circle's line of sight.
- **Hodag facing (proposal):** spawn it facing **back toward the Wild Gate** (model front is −Z, so rotate 180° about Y in plot space) so the first view is the face, eyes and horns. `[VERIFY in Studio]`

#### The fix (approved): a single warm lantern on a post (Parts + built-in materials only, ≤ 6 parts)
| Part | Shape / size (studs, proposal) | Material | Colour token | Notes |
|---|---|---|---|---|
| `Base` | block 1.6 × 0.4 × 1.6 | Slate | Ash | only part with CanCollide on |
| `Post` | block 0.5 × 7 × 0.5 | Wood | Soot | |
| `Arm` | block 2.0 × 0.3 × 0.3 at the top, pointing toward the spawn | Wood | Soot | |
| `Cage` | block 0.9 × 1.2 × 0.9, Transparency ~0.5 | CorrodedMetal | Gold | hangs from the arm end |
| `Flame` | block 0.4 × 0.6 × 0.4 inside the cage | Glass | GoldBright | **not Neon** (not on the Neon allow-list) |
| `Cap` | wedge or block 1.0 × 0.3 × 1.0 | CorrodedMetal | Gold | |

- **Light:** **one PointLight** inside `Flame`: Color **`#FFB36B`** (candle, lights only `[SG §1]`), **Shadows = false**, Range **14**, Brightness **1.0** (the town lamp values `[S03]`, chosen so it matches existing lamps; **tune in Studio**). No flicker (keeps it calm and cheap).
- **Textures:** none. **Scripts inside:** none. **Particles:** none. **Neon:** none. **Rift green:** none.
- **Physics:** all Anchored; CanCollide only on `Base`; CanTouch/CanQuery off; CastShadow off on all parts.
- **Fits the Town prop cap** (≤ 20 parts) with room to spare: 6 parts.

#### Light budget (why it stays within ≤ 8 per plot)
- Derived count: the plot is 120 × 120 (480 studs of wall) minus the gate openings (16 + 12) = 452 studs; a candle every 20 studs gives **~22 candles**, and lighting every third `[D2]` gives **~7–8 PointLights**. With the proposed altar fill light `[SG §4]` the plot is **at or 1 over the cap of 8 already**. `[VERIFY the real count in Studio]`
- So the lantern must be **net 0**: its PointLight is **on only during the owner's goal 3** (from goal 2 done until the Hodag is bound, ~0:17 → ~0:45), and for the same window the **lit wall candle nearest the Wild Gate has its PointLight disabled**. The player is outside the wall then, so nothing they look at gets darker. After that, the lantern's Parts stay as an unlit prop (or are removed); the wall candle comes back.
- It is part of the owner's plot (the tutorial spawn is per plot), so it counts against **that plot's** cap, not the town's 24. Other players' plots are unaffected.
- ~~Alternative: keep it lit permanently if the plot is at ≤ 7~~ — **not taken**: `[D39]` keeps the cap at 8 and approves the goal-3-only window.

#### What this does NOT change
- Lighting floors (Ambient / OutdoorAmbient), Atmosphere and fog: **unchanged** (the atmosphere pass is a separate task). One request for that task, not a change made here: keep fog-wisp emitters a few studs clear of the tutorial spawn so the Hodag's outline isn't covered `[VERIFY in Studio]`.
- The Hodag model, its materials (Slate / Limestone / Fabric / Glass eyes) and its 35-part budget.
- Shadows rule `[D2]`, Neon allow-list, reveal light `[D17]`.

#### Studio checks (Hodag is check #1 in `art/asset-list.md`)
1. Phone, low graphics, night: from the Wild Gate (~20 studs) the Hodag's body separates from fog and ground; Bone horns/spikes read; **GoldBright Glass eyes** catch the warm light (BATCH-01 #7 worried they may read dull).
2. During the 3 s hold at ≤ 12 studs: hold ring and Common reveal stay readable; the lantern doesn't wash out the gold guide beam (0.3 width `[S01 B5]`).
3. Compare **with and without** the lantern (screenshots both ways) before approving.
4. Count the plot's PointLights in Studio and confirm **≤ 8 at all times**, including during goal 3 `[D39]`.
5. Lantern parts use Gold/GoldBright/Soot/Ash only; **no Rift or RiftDim** on it `[D38]`.

#### Related (goal 3 rarity preview)
**Resolved `[D40]`:** goal 3's "3 dark rarity silhouettes" are **cut for launch** and replaced by **3 tier-colour pips** (BoneDim / Moss / Silver) + a text tease, built-in UI only, no ViewportFrames. UI spec: `vfx-audio-plan.md` §2.7. Silhouettes are P1.
