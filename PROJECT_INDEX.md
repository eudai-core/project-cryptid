# Project Cryptid — project index

This file is the map. It links to the design documents and the concept images. It does not copy them. Read it before any other project document.

Main at the time of this index: `86202dd943f90b1e76a6b5c1950a2736abca0ccb` (merge of pull request #13). Feature rows and evidence live in [`docs/FEATURE_STATUS.md`](docs/FEATURE_STATUS.md). Pictures and budgets live in [`docs/VISUAL_REFERENCES.md`](docs/VISUAL_REFERENCES.md).

## Precedence

When two sources disagree, use this order. Do not collapse them into one story, and do not pick a winner in a pull request unless a human explicitly authorises the change.

1. **Approved decisions and specs.** Specs under [`specs/`](specs/), style-guide decisions D1–D49 in [`art/style-guide-v0.8.md`](art/style-guide-v0.8.md), and directions marked approved (including [`specs/15-creative-brief-v3.md`](specs/15-creative-brief-v3.md) and [`art/ART-DIRECTION-V2.md`](art/ART-DIRECTION-V2.md)).
2. **Verified implementation and tests.** Code and Lune tests on `main`, at the SHA above, plus any later SHA a QA report names.
3. **Approved issues and acceptance criteria.** Open issue [#17](https://github.com/eudai-core/project-cryptid/issues/17) and the acceptance text on open pull requests [#14](https://github.com/eudai-core/project-cryptid/pull/14), [#15](https://github.com/eudai-core/project-cryptid/pull/15), [#16](https://github.com/eudai-core/project-cryptid/pull/16), and [#18](https://github.com/eudai-core/project-cryptid/pull/18).
4. **Historical or exploratory notes.** [`docs/spec-01.md`](docs/spec-01.md), [`docs/spec-02.md`](docs/spec-02.md), [`docs/spec-03.md`](docs/spec-03.md), [`art/style-guide.md`](art/style-guide.md) (v0.2), [`specs/14-feel-and-wow.md`](specs/14-feel-and-wow.md) where it labels itself a recommendation, concept images that contradict an approved spec, and the art-box paths cited inside handoff notes.

A merged pull request is not verification. There is no `qa/*-report.md` in this repository. Nothing has been published, so nothing is Released.

## Vision

Project Cryptid is a Roblox cryptid-collecting tycoon. The player keeps a candle-lit lair, hunts strange creatures, and builds income from what they bind.

Two approved looks are both on record. [`specs/01-theme-and-first-3-min.md`](specs/01-theme-and-first-3-min.md) and style guide v0.8 describe a grim, readable, candle-lit ritual ledger: Void, dried-blood crimson, tarnished gold, bone white, and a rare sickly green. [`specs/15-creative-brief-v3.md`](specs/15-creative-brief-v3.md) (approved direction, 5 Nov 2026) describes a haunted mythological town: "every hunt is a glowing duel", spooky-cute, with a purple night and coloured magic flames. Spec 15 says it supersedes conflicting look rules in style guide v0.8 and specs 01 and 03. Gameplay numbers in specs 01–13 still stand unless spec 15 changes them. The conflict is listed below and is not resolved here.

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

## Where each agent reads

| Who | Start here |
|---|---|
| Every agent | This file, then [`AGENTS.md`](AGENTS.md) (field notes, then Project rules). |
| Project Director | Grok. Final coordinator. Sets order, merges, and is the person who may authorise a change to an approved decision. |
| Systems Architect | The spec for the feature, then the files named in [Implemented behaviour](#implemented-behaviour). |
| Art Director | [`art/style-guide-v0.8.md`](art/style-guide-v0.8.md), [`art/ART-DIRECTION-V2.md`](art/ART-DIRECTION-V2.md), [`docs/VISUAL_REFERENCES.md`](docs/VISUAL_REFERENCES.md), [`specs/store-art-brief.md`](specs/store-art-brief.md). |
| Growth Strategist | [`specs/`](specs/) 01–13 and the compliance audit. |
| Integration Engineer | [`art/vfx/audio-licences.md`](art/vfx/audio-licences.md), [`docs/published-place-checklist.md`](docs/published-place-checklist.md), `scripts/stamp-build.sh`. |
| QA | [`docs/FEATURE_STATUS.md`](docs/FEATURE_STATUS.md) and the acceptance tables inside each spec. A PASS is a `qa/*-report.md` that says PASS. There are none yet. |
| Gemini | Not joining development yet. Issue #17 still names Gemini as the owner of visual pass 1. That assignment is unresolved. |

`docs/studio-ops-guide` is not in the repository. Agents follow §11 of that guide when it is present. Until then, the standards in [`AGENTS.md`](AGENTS.md) apply: server-authoritative gameplay, `UITheme`, no magic numbers, versioned DataStore migrations.

## Current priorities

Build in this order. Do not start a later item by skipping an earlier one.

1. **#14** town v3 — [pull request #14](https://github.com/eudai-core/project-cryptid/pull/14), branch `cursor/town-v3`, head `8522745e95e2886bc25df7816e2529b9f9eca219`. Open. Not on main.
2. **#18** preview-kick fix — [pull request #18](https://github.com/eudai-core/project-cryptid/pull/18), branch `cursor/studio-mock-store`, head `9f166b0608b1d7dcc9a69e3358e3743307efdc96`. Open. An unpublished Studio place (`PlaceId == 0`) should use the mock DataStore instead of kicking.
3. **#15** rebirth tiers 1–7 and the Tithe ledger — [pull request #15](https://github.com/eudai-core/project-cryptid/pull/15), branch `cursor/rebirth-r1-r7`, head `57ed2beb843b63046c5008a9db8479f422d3edc8`. Open.
4. **#16** `rbx_check` — [pull request #16](https://github.com/eudai-core/project-cryptid/pull/16), branch `cursor/rbx-check`, head `8dfcbc8bd2ba7bf5f1d2f9a3119ab18e7ab5db35`. Open. Not on main.
5. **#17** visual pass 1 — [issue #17](https://github.com/eudai-core/project-cryptid/issues/17). Open. No pull request. Lighting, atmosphere, and VFX code only.

## Intended behaviour

Design authority for gameplay numbers is specs 01–13, plus the change notes those files already contain. Look authority is split; see [Conflicts](#conflicts-and-unresolved-decisions).

| Topic | Spec |
|---|---|
| Theme, palette, first three minutes | [`specs/01-theme-and-first-3-min.md`](specs/01-theme-and-first-3-min.md) (draft v2.2) |
| Lairs | [`specs/02-player-bases.md`](specs/02-player-bases.md) (draft v1.3) |
| Hollowmere and the Pale Pedlar | [`specs/03-town-centre.md`](specs/03-town-centre.md) (draft v2.2) |
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
| Creative brief v3 | [`specs/15-creative-brief-v3.md`](specs/15-creative-brief-v3.md) — approved direction for look, feel, and hunt |
| Cash-as-paid-currency audit | [`specs/compliance-audit-cash-random.md`](specs/compliance-audit-cash-random.md) |
| Store icon and thumbnails | [`specs/store-art-brief.md`](specs/store-art-brief.md) |
| Competitor snapshots (4 Nov 2026) | [`specs/research/gamepasses-snapshot-2026-11-04.json`](specs/research/gamepasses-snapshot-2026-11-04.json), [`specs/research/devproducts-snapshot-2026-11-04.json`](specs/research/devproducts-snapshot-2026-11-04.json) |

Art direction and VFX intent:

- [`art/style-guide-v0.8.md`](art/style-guide-v0.8.md) — living style guide through D49.
- [`art/ART-DIRECTION-V2.md`](art/ART-DIRECTION-V2.md) — v2 (5 Nov) and the v3 mythic-town update the same day. v2 shop shapes are retired.
- [`art/vfx/vfx-audio-plan.md`](art/vfx/vfx-audio-plan.md), [`art/vfx/atmosphere-pass.md`](art/vfx/atmosphere-pass.md), [`art/vfx/atmosphere-events.md`](art/vfx/atmosphere-events.md), [`art/vfx/atmosphere-studio-capture-plan.md`](art/vfx/atmosphere-studio-capture-plan.md), [`art/vfx/vfx-templates-README.md`](art/vfx/vfx-templates-README.md), [`art/handoff/VFX-P0.md`](art/handoff/VFX-P0.md), [`art/handoff/ATMOSPHERE-LAUNCH.md`](art/handoff/ATMOSPHERE-LAUNCH.md).
- Audio licence log (empty of asset ids): [`art/vfx/audio-licences.md`](art/vfx/audio-licences.md).

Concept images, every file:

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
| [`art/concepts/stat-card.jpg`](art/concepts/stat-card.jpg) | Jackalope dossier card. |
| [`art/concepts/v2-shops.jpg`](art/concepts/v2-shops.jpg) | Cauldron potion shop and jack-o'-lantern food shop. Retired by art direction v3. |
| [`art/concepts/v2-town-portals.jpg`](art/concepts/v2-town-portals.jpg) | "Witchwood" plaza, three portals, gem HUD, pumpkins. |
| [`art/concepts/v3-town.jpg`](art/concepts/v3-town.jpg) | Mythic plaza: Runeheart Apothecary, Howling Horn, Veil & Fate, Dusk & Dial, three portals, runestones, gem HUD. |
| [`art/concepts/v3-shops.jpg`](art/concepts/v3-shops.jpg) | Tree apothecary and longship tavern with blue fire. |
| [`art/concepts/v3-tools.jpg`](art/concepts/v3-tools.jpg) | Lanterns L1–L5: Rusty, Ember, Spirit Compass, Binding Chains, Moonlit Censer. |
| [`art/concepts/v3-variants.jpg`](art/concepts/v3-variants.jpg) | Jackalope as Normal, Spectral, Gilded, Shadow, Moonlit. Sheet says Legendary and tradeable. |
| [`art/concepts/v3-sigil-trace.jpg`](art/concepts/v3-sigil-trace.jpg) | Sigil Trace minigame over a Jackalope. |
| [`art/concepts/v3-tug-of-war.jpg`](art/concepts/v3-tug-of-war.jpg) | Two lantern beams clashing on one cryptid. |
| [`art/vfx/concepts/ATMOS_concept_lair-night_2026-11-04.png`](art/vfx/concepts/ATMOS_concept_lair-night_2026-11-04.png) | Lair at night. Labelled concept only, not Studio proof, never store art. |
| [`art/vfx/concepts/ATMOS_concept_wilds-hunt_2026-11-04.png`](art/vfx/concepts/ATMOS_concept_wilds-hunt_2026-11-04.png) | Wilds hunt. Same label. |
| [`art/vfx/concepts/ATMOS_concept_catch-beat-epic_2026-11-04.png`](art/vfx/concepts/ATMOS_concept_catch-beat-epic_2026-11-04.png) | Epic catch circle. Same label. |
| [`art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png`](art/vfx/concepts/ATMOS_concept_ui-parchment_2026-11-04.png) | Parchment card row and wax seal. Same label. |

Creature and prop handoffs: [`art/handoff/`](art/handoff/). Models that the game actually loads are under `assets/cryptids/` and `assets/lair/`, not under `art/models/`. The handoff notes still cite box paths `/workspace/project-cryptid/art/models/...`. Those paths are not in this repository.

VFX template models (17, no scripts) are under [`art/vfx/templates/`](art/vfx/templates/). They are not in the Rojo tree. `*.parts.json` generator previews are gitignored and were not added.

## Implemented behaviour

On main at `86202dd`. This is what the code does today. It is not a claim that QA passed.

- **UITheme and the opening rite.** `src/shared/UITheme.luau`, `src/client/UiFactory.luau`, `src/client/GoalBanner.luau`, `src/client/CashPlaque.luau`, `src/shared/Logic/OnboardingGoals.luau`, `src/server/PlayerSession.luau`. Tests: `tests/economy_onboarding.spec.luau`, `tests/theme_and_source.spec.luau`, `tests/number_format.spec.luau`.
- **Eight lairs, pads, altar cost curve, RiftDim fissure.** `src/server/PlotBuilder.luau`, `src/server/Plot.luau`, `src/shared/Config/Plots.luau`, `src/shared/Config/Lair.luau`, `src/shared/Config/BoneAltar.luau`, `src/server/RiftGlow.luau`. Tests: `tests/plots.spec.luau`. `BoneAltar.MAX_REBIRTHS` is 40. The comment in that file says `rebirths` stays 0 until a rebirth spec writes the field.
- **Hollowmere spec 03 town and Pale Pedlar.** `src/server/TownBuilder.luau`, `src/shared/Config/Town.luau`, `src/shared/Logic/TownLayout.luau`, `src/client/TownDress.luau`, `src/server/Pedlar.luau`, `src/client/PedlarShop.luau`, `src/server/ShopRoll.luau`. Tests: `tests/town.spec.luau`. Districts in code: Pale Pedlar live, Skill Shrine live, Lanternwright / Expedition Board / Bone Broker / Grimoire Lectern shuttered, Tarot Table and Great Rift reserved. No Runeheart Apothecary, Howling Horn, Veil & Fate, or Dusk & Dial.
- **Twelve cryptid models.** `assets/cryptids/*.rbxmx`, `src/shared/Config/CryptidArt.luau`, `src/shared/CryptidModels.luau`. Tests: `tests/art_batch.spec.luau`. `src/shared/Config/Species.luau` also still lists placeholder ids (`uncommon_01`, `rare_01`, `epic_01`, and so on).
- **Ring 1 skill tree.** `src/shared/Config/SkillConfig.luau`, `src/shared/Logic/SkillTree.luau`, `src/client/SkillTree.luau`. Tests: `tests/skill_tree.spec.luau`. The shrine billboard uses `Town.SHRINE_BODY` ("The carving is blank. The skill tree waits for a later rite.") while onboarding step is under 8. The tree module itself is on main.
- **Offline haul, Nightly Offering, bowl.** `src/shared/Logic/Offline.luau`, `src/shared/Logic/Daily.luau`, `src/shared/Logic/Bowl.luau`, `src/client/HaulPanel.luau`, `src/client/OfferingPanel.luau`.
- **Saves.** DataStore `ProjectCryptid_Player_v1`, `Save.DATA_VERSION = 9` in `src/shared/Config/Save.luau`. Migrations run in `src/shared/Logic/Schema.luau`. Lock, retry, and wipe guard: `src/server/Ledger.luau`, `src/shared/Logic/SaveGuard.luau`. Tests: `tests/save_hardening.spec.luau`, `tests/persistence.spec.luau`, `tests/session_document.spec.luau`.
- **Monetisation core.** `src/server/MonetisationService.luau`, `src/shared/Config/Monetisation.luau`, `src/client/RelicsShop.luau`. Catalog ids are unset, so live sale is disabled. Tests: `tests/monetisation.spec.luau`.
- **Rate limit and analytics.** `src/server/RateLimiter.luau`, `src/server/Analytics.luau`. Tests: `tests/rate_limit.spec.luau`, `tests/analytics.spec.luau`.
- **Studio watchdog and QA args.** `src/server/Dev/StudioTestWatchdog.server.luau`, `src/shared/Logic/QaArgs.luau`. Tests: `tests/watchdog.spec.luau`, `tests/qa_args.spec.luau`, `tests/studio_qa.spec.luau`.
- **Lighting on main.** `src/server/LightingSetup.luau` applies `UITheme.lighting`. Ambient `(60, 55, 52)`, OutdoorAmbient `(95, 88, 82)`, Atmosphere colour Ash `#1A1719`, fog 250–1100, density 0.18, haze 0.3, ClockTime 1. Technology Future is set in `default.project.json`.

Not on main, so not implemented behaviour: town v3 geometry, rebirth rite, Tithe board, `rbx_check`, the PlaceId-0 mock path described by pull request #18, tarot reel, biomes as portals, Fog Night, seasons, Sigil Trace, tools L2–L5, variants, expeditions, steal remote, rare-catch server banner.

## Verified behaviour

Verified here means a check that has been run and recorded. Lune tests on main exercise pure logic (income, onboarding, schema, locks, plots, the Pedlar, the watchdog, offline haul, the offering, the bowl, monetisation, skills, theme guards). They do not open Studio.

No file matching `qa/*-report.md` exists. No Studio capture log is filled in (`art/vfx/atmosphere-studio-capture-plan.md` §5 is empty until a real capture). Store art must be real Studio captures (decision D12); the concept images are not store art, and the four ATMOS sheets say so on the image.

`docs/spec-01.md` maps spec 01 QA cases to Lune test names and to Studio steps. Those Lune names are the verification that exists. The Studio steps are instructions, not a recorded pass.

## Superseded documents

Kept on purpose. Do not delete them. They are no longer the design authority.

| File | What it is now |
|---|---|
| [`art/style-guide.md`](art/style-guide.md) | Style guide **v0.2** (3 Nov 2026, decisions D1–D13). Superseded by [`art/style-guide-v0.8.md`](art/style-guide-v0.8.md). |
| [`docs/spec-01.md`](docs/spec-01.md) | Implementation note for the opening rite as built. Superseded as design by [`specs/01-theme-and-first-3-min.md`](specs/01-theme-and-first-3-min.md). Still useful as a description of the build and its Lune map. |
| [`docs/spec-02.md`](docs/spec-02.md) | Implementation note for lairs. Superseded as design by [`specs/02-player-bases.md`](specs/02-player-bases.md). |
| [`docs/spec-03.md`](docs/spec-03.md) | Implementation note for Hollowmere and the Pedlar. Superseded as design by [`specs/03-town-centre.md`](specs/03-town-centre.md). |

`README.md` still links the three implementation notes. That link is historical.

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

## Conflicts and unresolved decisions

Flagged only. Not resolved.

1. **Look.** Style guide v0.2, style guide v0.8, and specs 01 and 03 forbid bright purple, saturated blue, pastel, and cartoony shapes. Neon is limited to the Mothman Hatchling's eyes and the Dover Demon's eyes. Spec 15 and art direction v2/v3 (both 5 Nov, and spec 15 is marked approved) require a purple night sky, saturated accents, and coloured flames including purple, blue, and green, and they allow Neon on flames, portals, runes, signs, and eyes. Issue #17 repeats the bright palette. The QA budgets recorded in [`docs/VISUAL_REFERENCES.md`](docs/VISUAL_REFERENCES.md) follow the muted palette and "no bright purple".
2. **Which town.** Spec 03 is eight wooden districts around the Weeping Well. Art direction v3 retires cauldron and pumpkin shops and asks for a rune-tree apothecary, an overturned longship tavern, an eye-sigil tarot tent, and a moon-phase clock. Pull request #14 (not on main) builds Runeheart Apothecary, The Howling Horn, Veil & Fate, and Dusk & Dial, and says portal locks are props and the moon face does not change colour. Spec 15 says the moon-phase face changes colour at events and cites "spec 14 §6". In spec 14, section 6's Hollow Clock is an undecided recommendation.
3. **Shop names.** No approved spec uses the string "Hollowmere Apothecary". Concepts use Morrow Apothecary (`stalls-morrow-nell.jpg`), a tree signed APOTHECARY (`v3-shops.jpg`), and RUNEHEART APOTHECARY (`v3-town.jpg`). The food shop is Nell Night Cook, a pumpkin stew shop (retired), or The Howling Horn. The tarot stall is the reserved Tarot Table, Veil & Fate, or a case UI titled Veil & Vesper.
4. **Place names on the art.** Concepts label the town Greyhaven (`pale-pedlar.jpg`), Greyvale (`fog-night.jpg`), and Witchwood (`v2-town-portals.jpg`). The approved name is Hollowmere.
5. **Gems and paid cases.** `v3-town.jpg`, `v2-town-portals.jpg`, and `v2-case-spin.jpg` show a diamond currency. `v2-case-spin.jpg` prices Open x3 at 3 gems. Spec 15 §7 forbids a Robux-only gem currency. Decision B forbids selling readings. Spec 10 says every reel is a free pull.
6. **Server Luck.** Specs 09 and 10 record Eudai's option A: Server Luck is the only paid random item, January only, PolicyService-gated. Style guide D37 still says "Server Luck: pending Eudai". Spec 10 also says Robux prices are proposed and pending approval.
7. **Mythic colour.** `UITheme.rarity.Mythic` on main is the Rift token. D28 then D34 say Mythic is GoldBright plus a Bone flare, a distinct frame, and a thin Rift core, and Legendary is plain GoldBright. Art direction v2 paints case frames grey, green, blue, purple, and gold. D24 says no purple. `v2-case-spin.jpg` uses a purple Epic frame and a blue Rare frame.
8. **Highlight cap.** D8 says the engine limit was reported raised from 31 to 255 and that this project has not verified it. The pool of 2 stays. The visual QA line in this index still says fewer than 31 Highlights, which is the unverified older cap.
9. **Night grade.** D43 sets OutdoorAmbient to `(95, 98, 108)`. D44 sets Atmosphere colour to `#282A30`. Main's `UITheme` uses OutdoorAmbient `(95, 88, 82)` and Atmosphere colour Ash `#1A1719`. The atmosphere handoff sets ClockTime 0. Main sets ClockTime 1.
10. **Rift Neon.** Style guide v0.2 §2 still describes a Neon Rift conveyor trim. D38, D41, spec 01 v2.1, and spec 02 v1.2 remove that Neon. Main's fissure uses RiftDim (`src/server/PlotBuilder.luau`). The v0.2 sentence is the superseded file.
11. **Rebirth cap.** Spec 07 seals tier 8. `BoneAltar.MAX_REBIRTHS` on main is 40, and no rite writes `rebirths` yet. The rite is pull request #15, not merged.
12. **Unpublished Studio DataStore.** `README.md` and `docs/spec-01.md` say an unpublished Studio place uses the in-memory mock. Pull request #18 says that path does not run when `PlaceId` is 0, and the player is kicked. Both documents are on main. The fix is not.
13. **Skill shrine copy.** `Town.SHRINE_BODY` says the skill tree waits for a later rite. The ring 1 tree is merged (pull request #8). The string is shown only before step 8, next to the correct "silent to the unmarked" line.
14. **Jackalope rarity and variants.** Spec 15's roster table lists the Jackalope as Uncommon. `stat-card.jpg` labels it Rare. `v3-variants.jpg` labels it Legendary and says the forms are tradeable. Spec 15 says variants are earn-only and never sold for Robux or cash directly. No spec describes player trading.
15. **Sigil Trace controls.** Spec 15 says taps do nothing alone, the path is randomised, and tools do not change push strength. `v3-sigil-trace.jpg` shows Dash (double tap), Stabilize, Reset, a combo, and the words "increase your catch chance".
16. **Fog Night fiction.** Spec 12 is a server atmosphere event. `fog-night.jpg` adds a Wendigo, which is not in the 12-cryptid roster, and frames the night as survival.
17. **Seasons versus Halloween.** Spec 15 forbids pumpkins, witch hats, and cauldron buildings. Spec 13's autumn row includes pumpkins. `winter-town.jpg` uses red-bow wreaths. Spec 13 says not to name region-specific holidays and asks for dark-green holly-like wreaths.
18. **Part budgets.** Pull request #14 states a town part cap of 364 and a light cap of 24. Spec 14 mentions a 4,000-part town ceiling for the clock proposal. Cryptid handoffs use their own part caps (about 40, and 80 for the large ones). Plot lights stay at 8 (D39). These numbers are different scopes. Which cap a new town mesh must meet is not settled in one place.
19. **Spec 01 assumptions.** The v2.2 header still says "the tutorial wild catch is still any Common" in the assumption block. The same file's open questions, and decision D33, name the Hodag.
20. **Gemini.** Project rules: Gemini is not joining development yet. Issue #17 names Gemini as the owner of visual pass 1 and tells that agent to cut `gemini/visual-pass-1` from main.
21. **Pedlar and paid-random policy.** The compliance audit records a medium judgement call: a preview-before-buy stall can still be a paid random item if buying is the way to discover the next roll. Spec 03 treats the Pedlar as outside that, because stock is a global UTC seed on a fixed 5-minute timer and buying never rerolls it. Roblox has not ruled on timed restocks. The audit leaves that as `[A]`.
22. **Spec 14 versus spec 15.** Spec 14 says it is not an implementation approval. Spec 15 cites it for the clock's event colour change and for the Stat Card as launch scope. Spec 14's Stat Card and Hollow Clock are undecided recommendations.
23. **Fake players.** Spec 15 says no fake players. `v3-town.jpg` and `v2-town-portals.jpg` paint named bystanders. `hollow-clock-bloodmoon.jpg` paints a crowd of identical avatars.

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
