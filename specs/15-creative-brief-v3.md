# Spec 15: Creative Brief v3 (Eudai direction, 5 Nov 2026), the single source for look, feel and hunt
Status: APPROVED DIRECTION. Supersedes conflicting look rules in style-guide v0.8 / specs 01 and 03 (Neon, palette). Gameplay numbers in specs 01–13 still stand unless changed here.
References: art/concepts/v3-*.jpg, art/ART-DIRECTION-V2.md (v3 section).

## 1. Feel (one line)
"A haunted mythological town where every hunt is a glowing duel." Spooky-cute, never gory; bright magic against dark nights; quick to read on phones.

## 2. Look
- Authentic Roblox: smooth rounded meshes, blocky avatars. Not Minecraft voxels, not muddy Diablo browns.
- Timeless haunted MYTHOLOGY, not Halloween (no pumpkins, witch hats or cauldron buildings). Seasons stay cosmetic (spec 13).
- Purple night sky, mist, saturated glowing accents, budgeted bloom. Signature VFX: coloured magic flames (green, purple, blue, crimson, orange).
- Neon allowed for flames, portals, runes, signs and eyes, within budgets: a light cap per area, ≤6 emitters / 120 particles per effect, and a Low-quality fallback (no bloom, fewer flames).

## 3. Town (Hollowmere)
- Central well with teal spirit mist, ringed by glowing runestones. Crooked clock tower with a moon-phase face that changes colour at events (spec 14 §6).
- Shops as mythic objects: Apothecary = hollow rune-carved tree (green); Tavern/food = overturned longship hull with a serpent figurehead (blue fire); Tarot = purple tent with an eye sigil; Pedlar = veiled figure with caged cryptids and a green lantern. Each one is readable from across the plaza.
- Biome portals as mythic arches with a swirling vortex, a floating name sign and a lock/level icon: Whispering Woods (gnarled tree, green), Sunken Marsh (stone serpent head, teal), Bone Quarry (beast ribcage, orange).
- Decorative life: crows, creaking signs, drifting runes. No fake players or hidden purchases.

## 4. Hunt
Launch (spec 11): hold-to-bind, 3 s at 12 studs, contested, first to finish wins, assist cash.
Launch VFX: rarity ring under the cryptid; your lantern fires a beam in YOUR colour; a rune circle draws on the ground; chains; burst + wax-seal "BOUND!", then the Stat Card.
Update 1, Sigil Trace duel (skill, autoclicker-proof):
- While binding, a random sigil path appears with an orb moving at varying speed; you trace it. Accuracy pushes your beam's clash point; perfect streaks push harder; drifting pulls back.
- Clicks or taps do nothing alone. The path is randomised per catch. The server validates trace samples (reject impossibly perfect or robotic input; rate-limit; flag outliers).
- Tools never change push strength (skill decides). Mobile gets a wider path; a hold-only accessibility mode gets the base 3 s bind but cannot win contested duels faster.
- Loser gets assist cash (spec 11). No exclusive species locked behind the minigame.

## 5. Tools (Lanternwright; deterministic, never odds)
L1 Rusty Lantern (free, orange beam, base bind) · L2 Ember Lantern (green beam, -10% bind time) · L3 Spirit Compass (blue arrow and wisp trail to the nearest spawn) · L4 Binding Chains (purple chains, 16-stud range, harder to steal) · L5 Silver Censer (silver smoke, bind 2 at once). The tool is not named Moonlit; Moonlit is a variant (section 6). Each tool's beam colour = its identity.

## 6. Variants
Normal, Spectral, Gilded, Shadow, Moonlit. Cosmetic + small earned stat flavour, earn-only, odds disclosed (spec 10 rules). Never sold for Robux/cash directly.

## 7. Currencies
Cash (earned + bundles) and Essence (earned + fixed Rites amounts). NO Robux-only gem currency (paid-random-items policy). Premium = direct Robux products (passes, cosmetics, Moon Pass, Server Luck).

## 8. Cases
Rarity-coloured card reel (grey/green/blue/purple/gold), golden needle, motion blur, sparkles; earned tokens only; real odds per spec 10.

## 9. Launch scope
LAUNCH: town v3 look (shell + 3 portals, 1 open), hold-to-bind with beam VFX, Stat Card, seasons. UPDATE 1: Sigil Trace duel, tools L2–L5, variants, Hollow Clock event changes. JANUARY: cases/reel, expeditions.

## 10. Cryptid identity + catch conditions (proposal, Eudai 5 Nov 22:22)
Every cryptid = unique look + unique behaviour (how it moves/flees) + an optional spawn condition. Conditions are deterministic and shown in the Bestiary (no hidden requirements).
| Cryptid | Rarity | Behaviour | Spawn condition |
|---|---|---|---|
| Mothman Hatchling | C | flutters toward lights | any; more near lanterns |
| Fresno Nightcrawler | C | stiff-legged walk, freezes when watched | Woods, night |
| Hidebehind | C | hides behind trees; only visible when you look away | Woods |
| Hodag | C | charges then stops | tutorial / any |
| Jackalope | U | zig-zag hops, fast | Woods, day |
| Dover Demon | U | perches on walls, glowing eyes | Quarry, night |
| Snallygaster | U | swoops from the sky | Bone Quarry, storms/Fog Night |
| Loveland Frogman | U | dives into water, resurfaces | Sunken Marsh, rain |
| Flatwoods Monster | R | hovers, emits a pulsing hiss aura | Marsh, Fog Night or after a 50-catch streak |
| Beast of Bray Road | R | stalks players, bipedal sprint | Woods, full moon phase (clock tower) |
| Jersey Devil | E | flies a loop, screech telegraph | Quarry, Blood Moon only |
| Loch Ness Serpent | E | rises from the lake for 30 s | Marsh lake, needs the Lure Totem + Fog Night |
Set-ups (deterministic items): Lure Totem (moves the next already-rolled spawn closer), Reed Bait (the same move, for cash, in spec 17; it does not pick a species), Fog Lamp (see through Fog Night). None change rarity odds or the spawn interval.

## 11. Spectral variants: monetisation (compliant)
Eudai asked for variant crates plus a grind option. Paid random items are banned by Eudai's 4 Nov decision, so:
- Grind: Spectral and Shadow are earnable in-game (wild catches, earned readings, expeditions), odds shown. Gilded and Moonlit are look, odds, and source TBD (AD).
- Robux: (a) Server Luck (already approved, PolicyService-gated) raises variant odds server-wide; (b) fixed Spectral Rite bundles: a specific, pre-shown variant for a fixed price (e.g. a shown Jackalope; prices need approval). The old name was "Shiny Rite".
- NO paid crates with random variants.
