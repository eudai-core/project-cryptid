# Project Cryptid — project index

This file is the map. It links to the design documents and the concept images. It does not copy them. Read it before any other project document.

Main at the time of this index: `c576b0813643eefff1b22511fb20890fec456421` (merge of pull request #18). Feature rows and evidence live in [`docs/FEATURE_STATUS.md`](docs/FEATURE_STATUS.md). Pictures and budgets live in [`docs/VISUAL_REFERENCES.md`](docs/VISUAL_REFERENCES.md). The 11 Nov director rulings are below.

## Precedence

When two sources disagree, use this order. Do not collapse them into one story, and do not pick a winner in a pull request unless a human explicitly authorises the change.

1. **Approved decisions and specs.** Specs under [`specs/`](specs/), style-guide decisions D1–D49 in [`art/style-guide-v0.8.md`](art/style-guide-v0.8.md), and directions marked approved (including [`specs/15-creative-brief-v3.md`](specs/15-creative-brief-v3.md) and [`art/ART-DIRECTION-V2.md`](art/ART-DIRECTION-V2.md)).
2. **Verified implementation and tests.** Code and Lune tests on `main`, at the SHA above, plus any later SHA a QA report names.
3. **Approved issues and acceptance criteria.** Open issue [#17](https://github.com/eudai-core/project-cryptid/issues/17) and the acceptance text on open pull requests [#14](https://github.com/eudai-core/project-cryptid/pull/14), [#15](https://github.com/eudai-core/project-cryptid/pull/15), and [#16](https://github.com/eudai-core/project-cryptid/pull/16). Pull request #18 is merged.
4. **Historical or exploratory notes.** [`docs/spec-01.md`](docs/spec-01.md), [`docs/spec-02.md`](docs/spec-02.md), [`docs/spec-03.md`](docs/spec-03.md), [`art/style-guide.md`](art/style-guide.md) (v0.2), [`specs/14-feel-and-wow.md`](specs/14-feel-and-wow.md) where it labels itself a recommendation, concept images that contradict an approved spec, and the art-box paths cited inside handoff notes.

A merged pull request is not verification. There is no `qa/*-report.md` in this repository. Nothing has been published, so nothing is Released.

## Vision

Project Cryptid is a Roblox cryptid-collecting tycoon. The player keeps a candle-lit lair, hunts strange creatures, and builds income from what they bind.

The world look is spec 15 (director ruling 1, 11 Nov). [`specs/15-creative-brief-v3.md`](specs/15-creative-brief-v3.md) (approved direction, 5 Nov 2026) is a haunted mythological town: "every hunt is a glowing duel", with a purple night, coloured magic flames, and Neon on flames, portals, runes, signs, and eyes, within the budgets in [`docs/VISUAL_REFERENCES.md`](docs/VISUAL_REFERENCES.md). Spec 01 A2 palette tokens still apply to UI. Style guide v0.2, style guide v0.8, and the world-look rules in specs 01 and 03 are superseded where they conflict with that. Gameplay numbers in specs 01–13 still stand unless spec 15 changes them.

## Core loop

Intended loop, from the approved specs:

1. **Hunt.** Leave the lair through the Wild Gate. The tutorial hunt is the Hodag, about 20 studs outside the gate, hold still within 12 studs for 3 seconds ([`specs/01-theme-and-first-3-min.md`](specs/01-theme-and-first-3-min.md)). Later hunts are contested: first player to finish the bind wins, and the others get assist cash ([`specs/11-multiplayer-competition-and-pacing.md`](specs/11-multiplayer-competition-and-pacing.md), [`specs/15-creative-brief-v3.md`](specs/15-creative-brief-v3.md)).
2. **Capture.** The server grants the cryptid. The client plays the reveal. Goal 3 shows three tier pips and the line "Three marks. Rarer things are watching." Silhouettes are cut for launch (decision D40).
3. **Tarot cases.** Readings and the Fate Reel are **earn-only**. They are never sold for Robux. Eudai's decision B (4 Nov 2026, 12:57 UTC) removed paid crates, cases, readings, and pulls. The paid side of the Tarot Table is Bound Rites: fixed bundles whose exact contents are shown before purchase. The reel ships in January, not at launch ([`specs/09-launch-roster-and-monetisation.md`](specs/09-launch-roster-and-monetisation.md), [`specs/10-tarot-readings-and-reel.md`](specs/10-tarot-readings-and-reel.md)).
4. **Collection.** Bound cryptids live in the menagerie and on pads. The 34-cryptid Grimoire Lectern and the Bestiary NEW stamp are later ([`specs/03-town-centre.md`](specs/03-town-centre.md), spec 10 §8).
5. **Tycoon income.** Pads earn cash every second. The Bone Altar multiplies that income. Cash auto-credits. There is no collect button in spec 01.
6. **Rebirth.** The Rite of Rebirth spends cash, keeps one chosen familiar, and raises a permanent income multiplier. Tiers 1–7 are the launch ladder. Tier 8 is sealed. The public stat is Tithe ([`specs/07-rebirth-and-leaderboard.md`](specs/07-rebirth-and-leaderboard.md)).

## Approved features

These are the decisions the specs record as approved. Implementation status is in the next sections, not here.

- Shared occult `UITheme`. Server decides cash, rolls, prices, and rewards.
- First three minutes: Mothman Hatchling already earning, Fresno Nightcrawler, Hodag catch, Hidebehind, pads, Bone Altar I, Ward Candles shown and not yet buyable. No purchase prompt before step 8 and 5:00.
- Eight walled lairs around Hollowmere. Personal Rift Fissure uses RiftDim trim, not Neon (D38, D41).
- Hollowmere: Pale Pedlar (live, global 5-minute stock, cash only) and Skill Shrine (live). Other districts are shuttered or reserved.
- Ring 1 of the skill tree (7 buyable nodes). `h5` and `h6` stay sealed until they are deterministic.
- Offline haul (20% for up to 8 hours), Nightly Offering day 1 in session 1, Offering Bowl.
- Launch roster of 12 cryptids. Monetisation core: passes, cosmetics, cash bundles. Robux prices in spec 09 are still proposed.
- Tarot readings earn-only (decision B). Server Luck is specified as the only paid random item, January only, PolicyService-gated. Style guide D37 still says "Server Luck: pending Eudai". Both sentences are on record.
- Rebirth tiers 1–7 and the Tithe board (spec 07 v3, taken from spec 11).
- Rare-catch announcements for free-source Epics. Personal Robux purchases do not announce. Server-wide gifts may name the buyer with no price and no buy link (D36).
- World events: Fog Night is the only launch event (D49, spec 12). Blood Moon, Rift Storm, Eclipse, The Tolling, and Witch-Lights are Update 1.
- Compliance ruling: in-game cash is paid currency because it is sold in Robux bundles ([`specs/compliance-audit-cash-random.md`](specs/compliance-audit-cash-random.md)).
- Creative brief v3 for look, feel, and the hunt ([`specs/15-creative-brief-v3.md`](specs/15-creative-brief-v3.md)), including coloured flames and the mythic town. Seasons stay cosmetic ([`specs/13-seasons.md`](specs/13-seasons.md)).
- UI psychology for visual pass #17 and later UI pull requests ([`specs/16-ui-psychology.md`](specs/16-ui-psychology.md)). Those pull requests name the spec 16 rule numbers they apply.

## Psychology rationale

UI and feel follow the player-psychology brief in [`specs/16-ui-psychology.md`](specs/16-ui-psychology.md): variable earned rewards, near-miss tension in the bind, juicy collect pops, escalating rarity reveals, clear progress bars and goals, gentle loss aversion, social proof via rare catch announcements, value framing, the item shown before purchase, and impulse-friendly shop placement. The files under [`specs/research/`](specs/research/) are the 4 Nov competitor price snapshots. The research citations for this brief are the URLs inside spec 16.

Bounds, from Roblox policy and specs 09 and 15: no paid random items, no fake urgency, no fake players, and no countdown pressure on kids. Server Luck and the Robux prices stay open (director ruling 5, pending Eudai) and are not decided here.

A UI pull request, including visual pass #17, names the spec 16 rule numbers it applies. Those are the ten rules in spec 16 §8. The P0 UI pass (44 px targets, the upper-left Menu, rarity chips, the Pedlar Details button, and card portraits) applies §8 rules 2, 4, 5, and 7. It does not change prices or odds.

## Where each agent reads

| Who | Start here |
|---|---|
| Every agent | This file, then [`AGENTS.md`](AGENTS.md) (field notes, then Project rules). |
| Project Director | Grok. Final coordinator. Sets order, merges, and is the person who may authorise a change to an approved decision. |
| Systems Architect | Scripting and systems: finish #14, #15 rebirth, #16 tools, saves, and economy. Then the spec for that feature, and the files named in [Implemented behaviour](#implemented-behaviour). After #14 merges, do not edit `TownBuilder` or other town visual files without the World Builder. |
| World Builder | Owns #17 (17a sky + cobbles, 17b building shapes, 17c life + VFX) and all town, visual, lighting, and VFX files. Starts after #14 merges. [`specs/15-creative-brief-v3.md`](specs/15-creative-brief-v3.md), [`specs/16-ui-psychology.md`](specs/16-ui-psychology.md) (name the §8 rule numbers), [`docs/VISUAL_REFERENCES.md`](docs/VISUAL_REFERENCES.md), [`art/style-guide-v0.8.md`](art/style-guide-v0.8.md) (world-look lines that conflict with spec 15 are superseded; see the ruling). |
| Art Director | [`art/style-guide-v0.8.md`](art/style-guide-v0.8.md) (world-look lines that conflict with spec 15 are superseded; see the ruling), [`art/ART-DIRECTION-V2.md`](art/ART-DIRECTION-V2.md), [`specs/15-creative-brief-v3.md`](specs/15-creative-brief-v3.md), [`specs/16-ui-psychology.md`](specs/16-ui-psychology.md), [`docs/VISUAL_REFERENCES.md`](docs/VISUAL_REFERENCES.md), [`specs/store-art-brief.md`](specs/store-art-brief.md). |
| Growth Strategist | [`specs/`](specs/) 01–13 and the compliance audit. |
| Integration Engineer | [`art/vfx/audio-licences.md`](art/vfx/audio-licences.md), [`docs/published-place-checklist.md`](docs/published-place-checklist.md), `scripts/stamp-build.sh`. |
| QA | [`docs/FEATURE_STATUS.md`](docs/FEATURE_STATUS.md) and the acceptance tables inside each spec. A PASS is a `qa/*-report.md` that says PASS. There are none yet. |
| Gemini | Not joining development. Visual pass #17 is owned by the Cryptid World Builder (director ruling 19). Do not start that pass on Gemini's behalf. It starts after #14 merges. |

`docs/studio-ops-guide` is not in the repository. Agents follow §11 of that guide when it is present. Until then, the standards in [`AGENTS.md`](AGENTS.md) apply: server-authoritative gameplay, `UITheme`, no magic numbers, versioned DataStore migrations.

## Current priorities

Build in this order. Do not start a later item by skipping an earlier one. Visual pass #17 is the exception: it starts after #14 merges, and it is not blocked on #15 or #16.

1. **#14** town v3 — [pull request #14](https://github.com/eudai-core/project-cryptid/pull/14), branch `cursor/town-v3`, head `8522745e95e2886bc25df7816e2529b9f9eca219`. Open. Not on main.
2. **#18** preview-kick fix — [pull request #18](https://github.com/eudai-core/project-cryptid/pull/18) merged on main at `c576b08`. In Studio, PlaceId 0, or a 403 / must-publish error, uses the mock DataStore and warns once. Do not reopen it.
3. **#15** rebirth tiers 1–7 and the Tithe ledger — [pull request #15](https://github.com/eudai-core/project-cryptid/pull/15), branch `cursor/rebirth-r1-r7`, head `57ed2beb843b63046c5008a9db8479f422d3edc8`. Open. Director ruling 10: this pull request must enforce 7 tiers.
4. **#16** `rbx_check` — [pull request #16](https://github.com/eudai-core/project-cryptid/pull/16), branch `cursor/rbx-check`, head `8dfcbc8bd2ba7bf5f1d2f9a3119ab18e7ab5db35`. Open. Not on main.
5. **#17** visual pass 1 — [issue #17](https://github.com/eudai-core/project-cryptid/issues/17). Open. No pull request. Owner: Cryptid World Builder. Starts after #14 merges, split into 17a sky + cobbles, 17b building shapes, and 17c life + VFX. Town geometry within the cap (364 parts / 24 lights, under 31 Highlights); no map expansion. Built-in rbxasset skyboxes only. 0 new lights. 0 standing town Highlights (only a pooled rare-cryptid aura). No gameplay, economy, DataStore, remotes, or monetisation files. Name the spec 16 rule numbers the pass applies. Lighting may be tuned from main's current values (director ruling 8); it does not start from D43 or D44.

## Intended behaviour

Design authority for gameplay numbers is specs 01–13, plus the change notes those files already contain. World look is spec 15 where the older guides conflict; see [Director rulings (11 Nov)](#director-rulings-11-nov).

| Topic | Spec |
|---|---|
| Theme, palette, first three minutes | [`specs/01-theme-and-first-3-min.md`](specs/01-theme-and-first-3-min.md) (draft v2.2). A2 palette tokens still apply to UI. World-look rules that ban a purple night or limit Neon to two cryptids' eyes are superseded where they conflict with spec 15 (director ruling 1). The tutorial catch is the Hodag (ruling 18); the "any Common" assumption line is superseded. |
| Lairs | [`specs/02-player-bases.md`](specs/02-player-bases.md) (draft v1.3) |
| Hollowmere and the Pale Pedlar | [`specs/03-town-centre.md`](specs/03-town-centre.md) (draft v2.2). World-look rules that conflict with spec 15 are superseded (director ruling 1). The #14 district names are canonical (ruling 2). Town budget is 364 parts and 24 lights (ruling 17). |
| Skill tree | [`specs/04-skill-tree.md`](specs/04-skill-tree.md) (draft v1.1) |
| Ring 1 cut | [`specs/05-skill-tree-ring1-cut.md`](specs/05-skill-tree-ring1-cut.md) (draft v1.2) |
| Offline haul, daily offering, bowl | [`specs/06-offline-and-daily.md`](specs/06-offline-and-daily.md) (draft v2) |
| Rebirth and Tithe | [`specs/07-rebirth-and-leaderboard.md`](specs/07-rebirth-and-leaderboard.md) (draft v3) |
| Rare-catch announcements | [`specs/08-rare-catch-announcement.md`](specs/08-rare-catch-announcement.md) (draft v2.3) |
| Roster and monetisation | [`specs/09-launch-roster-and-monetisation.md`](specs/09-launch-roster-and-monetisation.md) (draft v3.1) |
| Tarot, Fate Reel, Server Luck, Essence | [`specs/10-tarot-readings-and-reel.md`](specs/10-tarot-readings-and-reel.md) (draft v2.1) |
| Multiplayer, contest, pacing | [`specs/11-multiplayer-competition-and-pacing.md`](specs/11-multiplayer-competition-and-pacing.md) (v1.1, approved as the design base) |
| World events | [`specs/12-world-events.md`](specs/12-world-events.md) (v1.2) |
| Seasons | [`specs/13-seasons.md`](specs/13-seasons.md) |
| Feel and wow answers | [`specs/14-feel-and-wow.md`](specs/14-feel-and-wow.md) — proposals, not an implementation approval |
| Creative brief v3 | [`specs/15-creative-brief-v3.md`](specs/15-creative-brief-v3.md) — approved direction for look, feel, and hunt. World look wins where style guide v0.2, v0.8, and specs 01 and 03 conflict (director ruling 1). Covers the Stat Card (ruling 21). Clock-face colour is Update 1. |
| UI psychology | [`specs/16-ui-psychology.md`](specs/16-ui-psychology.md) — draft v1, 11 Nov 2026. Ten UI rules in §8. Does not change gameplay numbers, prices, or economy formulae. |
| Pedlar supplies shop | [`specs/17-pedlar-supplies.md`](specs/17-pedlar-supplies.md) — draft v1, 11 Nov 2026. Design note. The stall stops selling cryptids and becomes a cash supplies shop. Prices are proposals. No `src/` change in that note. |
| Tools, capture twists, aptitudes | [`specs/18-tools-capture-aptitudes.md`](specs/18-tools-capture-aptitudes.md) — draft v1, 11 Nov 2026. Design note. Deterministic L1–L5 and the UV Lamp, one twist per launch species, Courage / Instinct / Attunement. Read with spec 17. |
| Cash-as-paid-currency audit | [`specs/compliance-audit-cash-random.md`](specs/compliance-audit-cash-random.md) |
| Store icon and thumbnails | [`specs/store-art-brief.md`](specs/store-art-brief.md) |
| Competitor snapshots (4 Nov 2026) | [`specs/research/gamepasses-snapshot-2026-11-04.json`](specs/research/gamepasses-snapshot-2026-11-04.json), [`specs/research/devproducts-snapshot-2026-11-04.json`](specs/research/devproducts-snapshot-2026-11-04.json) |
| Retention and monetisation research (11 Nov 2026) | [`specs/research/2026-11-roblox-retention-monetisation-research.md`](specs/research/2026-11-roblox-retention-monetisation-research.md). Research, not a spec. Specs 17 and 18 fold in its top five recommendations and replace each **[A]** with a cited config or spec. |

Art direction and VFX intent:

- [`art/style-guide-v0.8.md`](art/style-guide-v0.8.md) — living style guide through D49. World-look rules that conflict with spec 15 are superseded by director ruling 1. Decisions that do not conflict (including D34 for Mythic, D38/D41 RiftDim on the fissure, and the Highlight pool of 2) stay.
- [`art/ART-DIRECTION-V2.md`](art/ART-DIRECTION-V2.md) — v2 (5 Nov) and the v3 mythic-town update the same day. v2 shop shapes are retired.
- [`art/vfx/vfx-audio-plan.md`](art/vfx/vfx-audio-plan.md), [`art/vfx/atmosphere-pass.md`](art/vfx/atmosphere-pass.md), [`art/vfx/atmosphere-events.md`](art/vfx/atmosphere-events.md), [`art/vfx/atmosphere-studio-capture-plan.md`](art/vfx/atmosphere-studio-capture-plan.md), [`art/vfx/vfx-templates-README.md`](art/vfx/vfx-templates-README.md), [`art/handoff/VFX-P0.md`](art/handoff/VFX-P0.md), [`art/handoff/ATMOSPHERE-LAUNCH.md`](art/handoff/ATMOSPHERE-LAUNCH.md).
- Audio licence log (empty of asset ids): [`art/vfx/audio-licences.md`](art/vfx/audio-licences.md).

Concept images, every file. Town name on the art is Hollowmere, and the apothecary is Runeheart Apothecary. Other place names on these sheets are placeholders (director ruling 3). Gems drawn on the sheets are superseded (ruling 4). Bystanders are mood only (ruling 22).

| Image | What it shows |
|---|---|
| [`art/concepts/town-hub.jpg`](art/concepts/town-hub.jpg) | Muted dusk Hollowmere. Weeping Well, eight roads, clock belfry, market stalls. |
| [`art/concepts/stalls-morrow-nell.jpg`](art/concepts/stalls-morrow-nell.jpg) | Morrow Apothecary and Nell Night Cook, wooden stalls. |
| [`art/concepts/pale-pedlar.jpg`](art/concepts/pale-pedlar.jpg) | Veiled Pale Pedlar, four cages, a sign that reads Greyhaven Town. |
| [`art/concepts/fog-night.jpg`](art/concepts/fog-night.jpg) | Fog Night mood board. Names Greyvale Town and a Wendigo. |
| [`art/concepts/hollow-clock-bloodmoon.jpg`](art/concepts/hollow-clock-bloodmoon.jpg) | Clock tower under a red moon. |
| [`art/concepts/winter-town.jpg`](art/concepts/winter-town.jpg) | Snow on the well and roofs, holiday wreaths with red bows. |
| [`art/concepts/case-reveal.jpg`](art/concepts/case-reveal.jpg) | "Veil & Vesper" rare tarot case, single card reveal. |
| [`art/concepts/v2-case-spin.jpg`](art/concepts/v2-case-spin.jpg) | Spinning tarot reel with a gem cost on Open x3. |
| [`art/concepts/stat-card.jpg`](art/concepts/stat-card.jpg) | Jackalope dossier card. Mood only. The layout is [`art/mocks/dossier-v1.png`](art/mocks/dossier-v1.png). |
| [`art/concepts/v2-shops.jpg`](art/concepts/v2-shops.jpg) | Cauldron potion shop and jack-o'-lantern food shop. Retired by art direction v3. |
| [`art/concepts/v2-town-portals.jpg`](art/concepts/v2-town-portals.jpg) | "Witchwood" plaza, three portals, gem HUD, pumpkins. |
| [`art/concepts/v3-town.jpg`](art/concepts/v3-town.jpg) | Mythic plaza: Runeheart Apothecary, Howling Horn, Veil & Fate, Dusk & Dial, three portals, runestones, gem HUD. |
| [`art/concepts/v3-shops.jpg`](art/concepts/v3-shops.jpg) | Tree apothecary and longship tavern with blue fire. |
| [`art/concepts/v3-tools.jpg`](art/concepts/v3-tools.jpg) | Lanterns L1–L5: Rusty, Ember, Spirit Compass, Binding Chains, Silver Censer. The sheet's old "Moonlit Censer" label is the same tool. Moonlit is a variant name, not the tool. |
| [`art/concepts/v3-variants.jpg`](art/concepts/v3-variants.jpg) | Jackalope as Normal, Spectral, Gilded, Shadow, Moonlit. Sheet says Legendary and tradeable. Gilded and Moonlit are look, odds, and source TBD (AD). |
| [`art/concepts/v3-sigil-trace.jpg`](art/concepts/v3-sigil-trace.jpg) | Sigil Trace minigame over a Jackalope. |
| [`art/concepts/v3-tug-of-war.jpg`](art/concepts/v3-tug-of-war.jpg) | Two lantern beams clashing on one cryptid. |
| [`art/vfx/concepts/ATMOS_concept_lair-night_2026-11-04.png`](art/vfx/concepts/ATMOS_concept_lair-night_2026-11-04.png) | Lair at night. Labelled concept only, not Studio proof, never store art. |
| [`art/vfx/concepts/ATMOS_concept_wilds-hunt_2026-11-04.png`](art/vfx/concepts/ATMOS_concept_wilds-hunt_2026-11-04.png) | Wilds hunt. Same label. |
| [`art/vfx/concepts/ATMOS_concept_catch-beat-epic_2026-11-04.png`](art/vfx/concepts/ATMOS_concept_catch-beat-epic_2026-11-04.png) | Epic catch circle. Same label. |
| [`art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png`](art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png) | Parchment card row and wax seal. Same label. |

Creature and prop handoffs: [`art/handoff/`](art/handoff/). Models that the game actually loads are under `assets/cryptids/` and `assets/lair/`, not under `art/models/`. The handoff notes still cite box paths `/workspace/project-cryptid/art/models/...`. Those paths are not in this repository.

VFX template models (17, no scripts) are under [`art/vfx/templates/`](art/vfx/templates/). They are not in the Rojo tree. `*.parts.json` generator previews are gitignored and were not added.

## Implemented behaviour

On main at `c576b08`. This is what the code does today. It is not a claim that QA passed.

- **UITheme and the opening rite.** `src/shared/UITheme.luau`, `src/client/UiFactory.luau`, `src/client/GoalBanner.luau`, `src/client/CashPlaque.luau`, `src/shared/Logic/OnboardingGoals.luau`, `src/server/PlayerSession.luau`. Tests: `tests/economy_onboarding.spec.luau`, `tests/theme_and_source.spec.luau`, `tests/number_format.spec.luau`.
- **Eight lairs, pads, altar cost curve, RiftDim fissure.** `src/server/PlotBuilder.luau`, `src/server/Plot.luau`, `src/shared/Config/Plots.luau`, `src/shared/Config/Lair.luau`, `src/shared/Config/BoneAltar.luau`, `src/server/RiftGlow.luau`. Tests: `tests/plots.spec.luau`. `BoneAltar.MAX_REBIRTHS` is 40. The comment in that file says `rebirths` stays 0 until a rebirth spec writes the field.
- **Hollowmere spec 03 town and Pale Pedlar.** `src/server/TownBuilder.luau`, `src/shared/Config/Town.luau`, `src/shared/Logic/TownLayout.luau`, `src/client/TownDress.luau`, `src/server/Pedlar.luau`, `src/client/PedlarShop.luau`, `src/server/ShopRoll.luau`. Tests: `tests/town.spec.luau`. Districts in code: Pale Pedlar live, Skill Shrine live, Lanternwright / Expedition Board / Bone Broker / Grimoire Lectern shuttered, Tarot Table and Great Rift reserved. No Runeheart Apothecary, Howling Horn, Veil & Fate, or Dusk & Dial. Browsing the Pedlar is a server distance check on `RequestPedlarOpen`; the client only shows the shop.
- **Twelve cryptid models.** `assets/cryptids/*.rbxmx`, `src/shared/Config/CryptidArt.luau`, `src/shared/CryptidModels.luau`. Tests: `tests/art_batch.spec.luau`. Shop species ids such as `uncommon_01` stay, so old saves still resolve. Their display names are launch-roster cryptids at the same rarity (Jackalope is Uncommon). `Species.modelId` points those ids at the roster model. Legendary and Mythic pools are empty. Snallygaster and the Flatwoods Monster stay on the Nightly Offering and out of the Pedlar.
- **Ring 1 skill tree.** `src/shared/Config/SkillConfig.luau`, `src/shared/Logic/SkillTree.luau`, `src/client/SkillTree.luau`. Tests: `tests/skill_tree.spec.luau`. The shrine billboard uses `Town.SHRINE_BODY` ("The carving is blank. The skill tree waits for a later rite.") while the onboarding step is under 8, next to `Town.SHRINE_UNMARKED` ("The shrine is silent to the unmarked."). The tree module itself is on main. The body string is stale. Updating it is a code follow-up after #14 (director ruling 12). This index does not change `src/`.
- **Offline haul, Nightly Offering, bowl.** `src/shared/Logic/Offline.luau`, `src/shared/Logic/Daily.luau`, `src/shared/Logic/Bowl.luau`, `src/client/HaulPanel.luau`, `src/client/OfferingPanel.luau`.
- **Saves.** DataStore `ProjectCryptid_Player_v1`, `Save.DATA_VERSION = 9` in `src/shared/Config/Save.luau`. Migrations run in `src/shared/Logic/Schema.luau`. Lock, retry, and wipe guard: `src/server/Ledger.luau`, `src/shared/Logic/SaveGuard.luau`. Tests: `tests/save_hardening.spec.luau`, `tests/persistence.spec.luau`, `tests/session_document.spec.luau`.
- **Monetisation core.** `src/server/MonetisationService.luau`, `src/shared/Config/Monetisation.luau`, `src/client/RelicsShop.luau`. Catalog ids are unset, so live sale is disabled. Tests: `tests/monetisation.spec.luau`.
- **Rate limit and analytics.** `src/server/RateLimiter.luau`, `src/server/Analytics.luau`. Tests: `tests/rate_limit.spec.luau`, `tests/analytics.spec.luau`.
- **Studio watchdog and QA args.** `src/server/Dev/StudioTestWatchdog.server.luau`, `src/shared/Logic/QaArgs.luau`. Tests: `tests/watchdog.spec.luau`, `tests/qa_args.spec.luau`, `tests/studio_qa.spec.luau`.
- **Lighting on main.** `src/server/LightingSetup.luau` applies `UITheme.lighting`. Ambient `(60, 55, 52)`, OutdoorAmbient `(95, 88, 82)`, Atmosphere colour Ash `#1A1719`, fog 250–1100, density 0.18, haze 0.3, ClockTime 1. Technology Future is set in `default.project.json`. Director ruling 8 keeps these values. Visual pass #17 may tune them.
- **Studio mock DataStore.** `src/server/Ledger.luau`, `src/server/DataStoreGateway.luau`, `src/shared/Logic/StudioStore.luau`, `src/shared/Config/StudioDataStore.luau`. Tests: `tests/studio_store.spec.luau`. In Studio, PlaceId 0 uses the in-memory mock immediately and warns once. A 403 or a must-publish error in Studio falls back to that mock on the first failure and warns once. A published Studio place whose calls succeed uses the real store and does not warn. A live server never installs the mock. Pull request #18, on main at `c576b08`.

Not on main, so not implemented behaviour: town v3 geometry, rebirth rite, Tithe board, `rbx_check`, tarot reel, biomes as portals, Fog Night, seasons, Sigil Trace, tools L2–L5, variants, expeditions, steal remote, rare-catch server banner. `UITheme.rarity.Mythic` is the GoldBright token (D34, director ruling 6). The Bone flare, distinct frame, and thin Rift core are not drawn; the rarity map is one colour token.

## Verified behaviour

Verified here means a check that has been run and recorded. Lune tests on main exercise pure logic (income, onboarding, schema, locks, plots, the Pedlar, the watchdog, offline haul, the offering, the bowl, monetisation, skills, theme guards). They do not open Studio.

No file matching `qa/*-report.md` exists. No Studio capture log is filled in (`art/vfx/atmosphere-studio-capture-plan.md` §5 is empty until a real capture). Store art must be real Studio captures (decision D12); the concept images are not store art, and the four ATMOS sheets say so on the image.

`docs/spec-01.md` maps spec 01 QA cases to Lune test names and to Studio steps. Those Lune names are the verification that exists. The Studio steps are instructions, not a recorded pass.

## Superseded documents

Kept on purpose. Do not delete them. They are no longer the design authority.

| File | What it is now |
|---|---|
| [`art/style-guide.md`](art/style-guide.md) | Style guide **v0.2** (3 Nov 2026, decisions D1–D13). Superseded by [`art/style-guide-v0.8.md`](art/style-guide-v0.8.md). Its world-look lines (no bright purple, Neon only on two cryptids' eyes, Neon Rift conveyor trim) are also superseded where they conflict with spec 15 (director rulings 1 and 9). The Neon conveyor trim was already removed: main uses RiftDim. |
| [`docs/spec-01.md`](docs/spec-01.md) | Implementation note for the opening rite as built. Superseded as design by [`specs/01-theme-and-first-3-min.md`](specs/01-theme-and-first-3-min.md). Still useful as a description of the build and its Lune map. |
| [`docs/spec-02.md`](docs/spec-02.md) | Implementation note for lairs. Superseded as design by [`specs/02-player-bases.md`](specs/02-player-bases.md). |
| [`docs/spec-03.md`](docs/spec-03.md) | Implementation note for Hollowmere and the Pedlar. Superseded as design by [`specs/03-town-centre.md`](specs/03-town-centre.md). |

[`art/style-guide-v0.8.md`](art/style-guide-v0.8.md) stays the living guide for decisions that do not conflict with the 11 Nov rulings. Its world-look lines that ban a purple night or limit Neon to two cryptids' eyes are superseded where they conflict with spec 15 (ruling 1). The same note is on [`specs/01-theme-and-first-3-min.md`](specs/01-theme-and-first-3-min.md) and [`specs/03-town-centre.md`](specs/03-town-centre.md): A2 UI tokens stay; the world-look conflict does not.

`README.md` still links the three implementation notes. That link is historical. The mock-store paragraphs in `README.md` and [`docs/spec-01.md`](docs/spec-01.md) match main after pull request #18 (director ruling 11).

## Versions kept side by side

These bundle files differ from the copies already in the repo. The repo copies were not overwritten.

| Already in the repo | Incoming copy | What differs |
|---|---|---|
| [`art/handoff/BATCH-01.md`](art/handoff/BATCH-01.md) | [`art/handoff/bundle-2026-11-04/BATCH-01.md`](art/handoff/bundle-2026-11-04/BATCH-01.md) | Incoming adds the D33 note: Hodag Wilds readability is check #1. |
| [`art/handoff/BATCH-02.md`](art/handoff/BATCH-02.md) | [`art/handoff/bundle-2026-11-04/BATCH-02.md`](art/handoff/bundle-2026-11-04/BATCH-02.md) | Incoming says the Hidebehind check runs after the Hodag. |
| [`art/handoff/BATCH-03.md`](art/handoff/BATCH-03.md) | [`art/handoff/bundle-2026-11-04/BATCH-03.md`](art/handoff/bundle-2026-11-04/BATCH-03.md) | Incoming reorders the Studio pending list: Hodag first, Hidebehind second. |
| [`art/handoff/Hidebehind.md`](art/handoff/Hidebehind.md) | [`art/handoff/bundle-2026-11-04/Hidebehind.md`](art/handoff/bundle-2026-11-04/Hidebehind.md) | Incoming places the Hidebehind at goal 7, Pad 4, after the Hodag. |
| [`art/handoff/Hodag.md`](art/handoff/Hodag.md) | [`art/handoff/bundle-2026-11-04/Hodag.md`](art/handoff/bundle-2026-11-04/Hodag.md) | Incoming makes the Hodag goal 3 and Studio check #1. |

Every other handoff file in the bundle matched the repo copy and was left as it is. New handoffs added once: `ATMOSPHERE-LAUNCH.md`, `HODAG-ONBOARDING.md`, `VFX-P0.md`.

## Director rulings (11 Nov)

The Project Director ruled on the conflicts the pull request #19 report left open. The numbers below are that report's numbers. **Resolved** means this ruling is the decision. Do not reopen one in a pull request. An earlier draft of this index split "names" into two items and counted 23. That count is retired. Only item 5 is open.

1. **Look. Resolved.** Spec 15's world look wins: a purple night, coloured flames, and Neon on flames, portals, runes, signs, and eyes, within the budgets in [`docs/VISUAL_REFERENCES.md`](docs/VISUAL_REFERENCES.md). Spec 01 A2 palette tokens still apply to UI. Style guide v0.2, style guide v0.8, and the world-look rules in specs 01 and 03 are superseded where they conflict: the ban on bright purple, saturated blue, and cartoony shapes in the world, and the limit of Neon to the Mothman Hatchling's eyes and the Dover Demon's eyes. The notes in those files say so.
2. **Town. Resolved.** The district and building names on pull request #14 are canonical: Runeheart Apothecary, The Howling Horn, Veil & Fate, and Dusk & Dial. The moon-face colour change moves to Update 1 (spec 15 §9). It is not part of #14. Portal locks on that pull request stay props.
3. **Names. Resolved.** The town is Hollowmere. The apothecary is Runeheart Apothecary. Other names on the concept art (Greyhaven, Greyvale, Witchwood, Morrow Apothecary, Nell Night Cook, Hollowmere Apothecary, Veil & Vesper) are placeholders.
4. **Gems. Resolved.** There is no gem currency. The gems and the "Open x3 = 3 gems" price on `v3-town.jpg`, `v2-town-portals.jpg`, and `v2-case-spin.jpg` are superseded. Decision B still forbids selling readings. Spec 10 still says every reel is a free pull.
5. **Server Luck and Robux prices. OPEN — pending Eudai.** Specs 09 and 10 record Server Luck as the only paid random item, January only, PolicyService-gated. Style guide D37 still says "Server Luck: pending Eudai". Robux prices in spec 09 are still proposed. This ruling does not close either sentence.
6. **Mythic colour. Resolved.** D34 wins. Mythic is GoldBright with a Bone flare, a distinct frame, and a thin Rift core. Legendary stays plain GoldBright. The Rift token is not the Mythic colour, and a purple frame is not the Mythic colour. `UITheme.rarity.Mythic` on main is still the Rift token. Changing that token is a later code change, not this docs change.
7. **Highlights. Resolved.** The cap is 31 until 255 is verified in Studio. The pool of 2 stays (D8). The visual QA line uses 31.
8. **Night grade. Resolved.** Keep main's lighting values: OutdoorAmbient `(95, 88, 82)`, Atmosphere colour Ash `#1A1719`, ClockTime 1. Visual pass #17 may tune them. D43 `(95, 98, 108)`, D44 `#282A30`, and the atmosphere handoff's ClockTime 0 do not override main until that pass.
9. **Rift Neon. Resolved.** Read with ruling 1. Spec 15's Neon allowance is flames, portals, runes, signs, and eyes. Style guide v0.2's Neon Rift conveyor trim stays superseded: D38 and D41 removed it, and main's fissure uses RiftDim. Spec 15 does not put Neon back on the fissure belt, the Great Rift pit, or the Pedlar lantern.
10. **Rebirth. Resolved.** Launch is tiers 1–7 (spec 07). Tier 8 stays sealed. Pull request #15 must enforce 7. `BoneAltar.MAX_REBIRTHS` on main is 40 until that pull request lands. No rite writes `rebirths` yet.
11. **Studio mock store. Resolved.** The docs match main after pull request #18 (`c576b08`). In Studio, PlaceId 0 uses the in-memory mock immediately and warns once. A 403 or a must-publish error in Studio falls back to the same mock on the first failure and warns once. The load, save, and release path still runs on the mock. A live server never installs the mock. A published Studio place whose DataStore calls succeed uses the real store and does not warn. See [`README.md`](README.md) and [`docs/spec-01.md`](docs/spec-01.md).
12. **Skill shrine copy. Resolved as a docs match, with a code follow-up.** `Town.SHRINE_BODY` on main is still `"The carving is blank. The skill tree waits for a later rite."` Ring 1 is merged (pull request #8). The billboard shows that string only while the onboarding step is under 8, beside `Town.SHRINE_UNMARKED`. This change does not edit `src/`. Updating the string is a follow-up after #14.
13. **Jackalope. Resolved.** The Jackalope is Uncommon (spec 15). `stat-card.jpg` (Rare) and `v3-variants.jpg` (Legendary, and the word tradeable) do not change that. Variants stay earn-only. There is no trading.
14. **Sigil Trace. Resolved.** Spec 15. Taps do nothing alone. No tap buffs and no catch-chance boosts. The labels on `v3-sigil-trace.jpg` (Dash, Stabilize, Reset, a combo, "increase your catch chance") are not the rule.
15. **Fog Night. Resolved.** Spec 12: atmosphere only. The Wendigo and the survival frame on `fog-night.jpg` are out of scope. The Wendigo is not in the roster. Greyvale on that sheet is a placeholder (ruling 3).
16. **Pumpkins and wreaths. Resolved.** No pumpkins. Use the spec 13 wreaths: dark green, holly-like, and no holiday name in UI text. Spec 13's autumn pumpkin row and the red bows on `winter-town.jpg` are superseded where they conflict. Spec 15's ban on witch hats and cauldron buildings stands.
17. **Town budgets. Resolved.** The town is 364 parts and 24 lights. No map expansion. Spec 14's 4,000-part town ceiling does not raise this cap. Plot lights stay at 8 (D39). Cryptid handoffs keep their own part caps. Those are different objects, not a second town cap.
18. **Tutorial catch. Resolved.** The tutorial catch is the Hodag (D33). The spec 01 v2.2 assumption line that says "any Common" is superseded.
19. **Visual pass owner and scope. Resolved.** Issue #17 is owned by the Cryptid World Builder. Gemini is not the owner and is not joining development. The World Builder owns #17 (17a, 17b, 17c) and all town, visual, lighting, and VFX files. The Systems Architect owns scripting and systems: finishing #14, #15 rebirth, #16 tools, saves, and economy. The pass starts after #14 merges and is split into 17a (sky + cobbles), 17b (building shapes), and 17c (life + VFX). Town geometry within the cap (364 parts / 24 lights, under 31 Highlights); no map expansion. Built-in rbxasset skyboxes only. 0 new lights. 0 standing town Highlights (only a pooled rare-cryptid aura). No gameplay, economy, DataStore, remotes, or monetisation files. After #14 merges, no edits to `TownBuilder` or other town visual files without coordinating with the World Builder. Issue #17's text is this owner and this scope.
20. **Pedlar restock. Resolved.** The restock stays earn-only, on the global 5-minute UTC timer, and the odds are shown behind the "Details" button. Buying does not reroll the stock. It is not a paid random item.
21. **Spec 15 and spec 14. Resolved.** Spec 15 is approved. It covers the Stat Card. The clock-face colour change is Update 1 (ruling 2). Spec 14 stays a recommendation except where spec 15 adopts the Stat Card.
22. **Fake players. Resolved.** No fake players. Named bystanders and the identical crowd on `v3-town.jpg`, `v2-town-portals.jpg`, and `hollow-clock-bloodmoon.jpg` are mood only. They are not NPCs, shops, or a player count.

### Later ruling, recorded with specs 17 and 18

Not part of the 1–22 count. It does not close item 5.

The Pale Pedlar stops selling cryptids. Cryptids come from hunting, earn-only crates, and expedition eggs. The stall is a cash supplies shop. Tools are deterministic and never change odds. Every price and timing in those two notes is a proposal for the Growth Strategist. The notes do not change `src/`, Robux prices, or species ids. See [`specs/17-pedlar-supplies.md`](specs/17-pedlar-supplies.md) and [`specs/18-tools-capture-aptitudes.md`](specs/18-tools-capture-aptitudes.md).

## Conflicts and unresolved decisions

Closed by the director rulings above, in the pull request #19 report's numbering. Item 5 (Server Luck and Robux prices) is the only one still open, flagged pending Eudai. Specs 17 and 18 do not close it. Do not treat a sentence in an older file as the winner when a ruling above names the winner.

## Missing references

Named by a document in this repo, and not present as a file:

- `docs/studio-ops-guide` (and its §11).
- `agents/VERIFICATION.md` and `agents/ORCHESTRATION.md` (named by `AGENTS.md`).
- `ops/LEAN-RULES.md` (named by spec 14).
- `specs/tools/verify_odds.py`, `specs/tools/reel_check.py`, `specs/tools/pacing_sim.py`, `specs/tools/pacing_sim_output.txt`, `specs/tools/events_check.py`, `specs/tools/events_check_output.txt`.
- `art/tools/validate_rbxmx.py`, `art/tools/build_assets.py`, `art/tools/rbxlib.py`, `art/tools/build_placeholder.py`, `art/tools/preview_parts.py`, `art/tools/test_validator_rules.py`, `art/tools/vfx_budget.py`.
- `art/models/` and the box paths `/workspace/project-cryptid/art/models/*.rbxmx`. The imported models that do exist are `assets/cryptids/` and `assets/lair/`.
- `qa/screenshots/` preview sheets named by the handoffs (Roster12, per-creature front and side). The handoffs say those sheets are not Studio proof.
- `*.parts.json` VFX previews. Gitignored on purpose (`*.parts.json`). Not added.
- An image whose title is "Hollowmere Apothecary". The closest pictures are listed in the concept table above.
- A filled Studio capture log for the atmosphere pass.

External, not a repo file: the Feel & Wow canvas linked from spec 14, and the design-bible canvas named by the VFX plan.
