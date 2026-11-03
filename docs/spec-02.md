# Spec 02: Player bases

Eight walled lairs stand in a ring around the town. Spec 01's altar, pads, Rift Fissure, spawn, and tutorial catch now live on the player's own plot. The server assigns the plot. The client never decides cash, ownership, or the teleport.

This depends on spec 01 (PR #2). Plot index is not saved. A rejoin on another server rebuilds the same pads, cryptids, and altar level on whichever plot is free.

## World

`Players.MaxPlayers` is 8, set on the place. Plot *i* is centred at `(260 sin θ, 0, 260 cos θ)` with `θ = (i − 1) × 45°` and `0°` along +Z, clockwise from above. The plot's local +Z points at the origin, so the Lair Gate faces the town. The Wild Gate opens away from town. The tutorial Hodag stands 20 studs outside that gate, which puts it in the Wilds (`r > 330`).

Local layout, in studs, with +Z toward the town:

| Piece | Position |
| --- | --- |
| Lair Gate | `(0, 0, 60)`, 16 wide |
| Spawn | `(0, 3, 48)` for the root, looking toward −Z (the altar) |
| Bone Altar | `(0, 0, −4)`, with a bone tier per altar level |
| Pads 1–12 | radius 28 around the altar, pad *k* at `(k − 1) × 30°`, pad 1 nearest the gate |
| Rift Fissure | `x = −50`, from `z = 40` to `z = −40` |
| Wild Gate | `(0, 0, −60)`, 12 wide |
| Defence sockets | D1 `(−54, −54)`, D2 `(54, −54)`, D3 `(54, 54)`, D4 `(−54, 54)` |

Pads 7–12 show a sigil and "Sealed" and cannot be bought. Pads 1–6 keep the spec 01 prices. Walls are 14 studs of basalt with crenellations. Candle lights stay at range 18 and brightness 2. Floor, wall, and altar colours stay the brightened tokens from the spec 01 playtest (`Floor`, `Wall`, `Altar`). The only neon in a plot is the Rift trim, plus a faint Rift seal on a protected Lair Gate.

Unclaimed plots show "Unclaimed Lair", shut both gates, and turn the candles off. Your own banner reads "Your Lair". Everyone else sees the owner's display name.

## Assignment

After the profile loads (the spec 01 retry and kick rules):

1. Give back a plot reserved for that user.
2. Otherwise, if a friend already has a plot, take the free plot the fewest steps around the ring from any friend. Ties use the lowest index.
3. Otherwise take the lowest free plot.

The join queue is serial, so two players in the same frame cannot receive the same plot. If the friend check errors, assignment uses the lowest free plot. If no plot is free, the player is kicked with `No lair stands empty. Try another server.` A failed profile load kicks before a plot is taken.

On leave the profile is saved, then the plot is reserved for 30 seconds. The models stay and income stops. At 30 seconds the cryptids, banner name, and altar tiers are cleared, the pads return to the empty template, and the plot is free. A visitor still inside is moved to the town edge of that plot's road.

`RequestReturnToLair` is the only new remote. The server teleports you to your own spawn and refuses a second call within 10 seconds.

## Protection

A player who has not finished onboarding (step under 8 and under 5:00) has a sealed threshold. Other players are pushed back at the Lair Gate and see `A warding seal holds this lair.` The owner can still walk out and back. Two finished players can walk into each other's plots. Prompts stay owner-only, so a visitor gets no interaction.

`PlotIntruded` fires on the server when a non-owner enters an open plot. It is logged and sent on the `PlotIntruded` bindable under `PlotSignals`. `beingStolen` stays false. `base.defences` saves as `{}`. `StealGuard.canSteal` is unchanged from spec 01; there is still no steal action.

## How to test in Studio

1. `rojo build -o ProjectCryptid.rbxlx` and open the place. Turn on **Studio access to API services** when the rejoin tests should persist cash.
2. Use **Test → Start Server** with 1 player, then add players from the server window. Stopping a solo Play session also stops the server, which drops the in-memory 30 second reservation.
3. One player: the server log is quiet, the player stands on Plot 1 at the north gate looking toward the altar, and the banner reads "Your Lair". The gold beam rises above that gate.
4. Walk the spec 01 rite on that plot: claim, carve, altar, lantern, catch outside the Wild Gate, bind. The guide beam stays inside the plot except for the catch, which points through the Wild Gate.
5. Pads 7–12 read "Sealed". Pressing them does nothing. Carving still follows pads 3, then 4, at the spec 01 prices.
6. **Return to Lair** (bottom left, left of Steady gaze) puts you on your spawn. Press it again within 10 seconds and you stay put.
7. Start a second player who has finished nothing. They cannot walk through the first player's gate while the first player is still in the rite; the toast is bone-dim. After both have skipped or finished, each can enter the other's plot and no prompt appears.
8. Leave with the server still running and rejoin within 30 seconds: same plot, same cash and creatures. Leave again, wait 35 seconds: the banner reads "Unclaimed Lair", the gates are shut, and the next player can receive that plot.
9. For eight players, start a local server with 8 players. Banners show eight names and the plots are the eight ring positions. A server output line `PlotIntruded <index> <userId>` appears when a finished player walks into another finished player's plot.
10. In the Explorer, each plot has `DefenceSocket1` through `DefenceSocket4` on the corner plinths, and `Threshold` fills the footprint.

## QA test mapping

| # | Test | Where it is proved |
| --- | --- | --- |
| 1 | First player gets Plot 1 at `(0, 0, 260)` and faces the altar | Lune `QA1 and QA3 plot 1 sits at the town's north edge` (centre and first assignment). Studio step 3 for the spawn facing. |
| 2 | Eight players, eight plots, eight names | Lune `QA2 eight joins`. Studio step 9 for the banners. |
| 3 | Centres match the ring formula within 1 stud | Lune `QA3 every plot centre`. |
| 4 | Lair Gates face the origin | Lune `QA4 each lair gate's front points at the origin`. Studio: stand in the gate and look at the town disc. |
| 5 | 12 pads, radius 28, pad 1 nearest the gate | Lune `QA5`. Studio: read the pad plates. |
| 6 | Spec 01 tests 1–20 on a plot other than Plot 1 | Lune `QA6` plus the existing spec 01 suite, which never reads a plot index. Studio: fill plots 1–4, then run the rite on the fifth player. |
| 7 | Rejoin within 30 seconds keeps the plot and the save | Lune `QA7`. Studio step 8 with API access on. |
| 8 | After 35 seconds the plot is unclaimed and reusable | Lune `QA8`. Studio step 8. |
| 9 | Layout survives a move to another plot | Lune `QA9`. Studio: rejoin after the hold and compare pads, cash, and altar level. |
| 10 | A finished player cannot pass an onboarding gate | Lune `QA10 and QA11` (`blocksWithSeal`). Studio step 7 for the push and the toast. |
| 11 | Finished players may enter and see no prompts | Lune `QA10 and QA11` (`mayEnter`). Prompts require `OwnerUserId` in `Interactions`. Studio step 7. |
| 12 | Return to Lair, then a refusal inside 10 seconds | Lune `QA12`. Studio step 6. |
| 13 | Pads 7–12 say Sealed and cannot be bought | Lune `QA13`. Studio step 5. |
| 14 | `PlotIntruded`, four sockets, `base.defences = {}` | Lune `QA14`. Studio step 9 and step 10. The saved map is empty until a later spec writes a defence. |
| 15 | Income stops on leave and resumes from saved cash | Lune `QA15` (`earns` is true only while present). The income loop ends when the session ends, before the hold. Studio: read the plaque, leave, rejoin, and confirm cash did not tick while away. |

## Known gaps / stubs

- `PlotIntruded` is a log line plus a bindable. Nothing raids the plot.
- Defence sockets are empty attachments. `beingStolen` is always false. `base.defences` is always `{}` in normal play.
- `StealGuard.canSteal` still follows spec 01. No steal remote exists, so a steal cannot succeed.
- No offline income. The Wilds past the tutorial clearing are empty. The town centre is a ground disc; the Weeping Well is spec 03.
- Ward Candles still cannot be bought. That remains the spec 01 gap.
- The sealed mark uses the existing sigil glyph. There is no cracked-sigil image.

## Open questions

- Several friends at once: the free plot with the fewest ring steps to any of them, and the lowest index on a tie.
- A friend whose profile is still loading is not an anchor until their plot is claimed.
- During the 30 second hold the candles stay lit and the gates stay open, with the owner's name still on the cloth. At 30 seconds it becomes an unclaimed lair.
- The same seal toast is used when a protected visitor tries to enter a finished lair. It repeats at most every 3 seconds.
- Return to Lair is the leftmost bottom button. Steady gaze sits to its right so the two do not overlap.
- Roads use dark slate rather than the Cobblestone material. Wall thickness stays 2 studs, carried from spec 01. The character root is 3 studs above the floor, same as spec 01.
- The two rift offers sit on the fissure, slot 1 toward the gate. The spec fixed the belt ends, not the slot offsets.
- Fog end stays 380 from the lighting playtest. The far side of the ring is about 520 studs away, so it stays veiled.
- Defence keys are accepted from 1 to 32 so a later socket is not treated as a corrupt save. This build only writes `{}`.
- The threshold is checked about four times a second. The seal part is Rift neon at transparency 0.8 so Future bloom stays faint.
