# Handoff — PR #39

Branch: `cursor/town-integration-17b`

## Done

- Pass 4 is on this branch: EnumItem tint, census nature counts, tonal clock bricks.
- Pass 5 item 1 (`7647a67`, push `0a39d89`, CI `44242984885` green): lighting sits halfway between `e5c3330` and `4799e39`. Clock face is SmoothPlastic DuskViolet with a mid light. Pedlar supply lantern is brighter green.
- Pass 5 item 2 (`be3019d`, CI `44243565904` green): portals scale 2.25x, thicker quarry ribs, SurfaceGui sign when the board has no label.
- Pass 5 item 3 (`2bff851`, CI `44244020639` green): Pale Pedlar statue is a cylinder robe, wedge hood and folds, and a faceless ball head.
- Pass 6 item 1: portal scale uses `CFrame.Position` and `CFrame.Rotation`. The Lune CFrame mock throws on unknown fields such as `r00`. Quality 10 must report more than 800 portal parts.

## Next

- Pass 6 item 2: rebuild the Pedlar statue, Veil & Fate tent, apothecary trunk, and the Lanternwright and Horn cottages so they stop reading as boxes.
- Pass 6 item 3: carved wooden shop signs, and a rough leaning well.

## Head

`2bff851ea560284d27db23156b6c6932e9c37037` until this portal fix is pushed. Exposure and the clock face stay as accepted.
