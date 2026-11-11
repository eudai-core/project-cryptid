# Project Cryptid: Feel & Wow Design Answers

A grounded answer to all 14 questions: a memorable occult collecting world, with current plans separated from historical build evidence and new proposals. Design review: 5 November 2026, Europe/London.

**Status: design answers and proposals; not an implementation approval or build certification.**

Page: https://cursor.com/canvas/store-a63cf3f9-8205-497a-abd7-29e4e6dd2d41/5ff0e3d5-0d46-45dd-8a48-b2715bf689a2

> Find something strange. Bind it with a candle-lit rite. Give it a home worth visiting. Earn the mystery; pay only for clearly disclosed value, with Server Luck the sole policy-gated odds exception.

## What’s new vs current plan

### Undecided: recommendation — a proper acquisition dossier

One compact Stat Card after every catch, earned reading and hatch; show the actual individual, its source, abilities and what makes it special.

### Undecided: recommendation — individual personality, not runaway power

Small, source-safe aptitude rolls, one trait and a cosmetic Bond ladder. Ability rarity should mean more character, not an unbeatable creature.

### Undecided: recommendation — finish the expedition contract

One free slot, named routes, fully disclosed egg contents and materials at send-off, and no second incubation wall. Eggs are not yet a specified system.

### Undecided: recommendation — Hollowmere’s signature clock and residents

A crooked belfry beside the Weeping Well, synchronised with real event phases; memorable potion-maker and cook characters, initially decorative.

### Undecided: recommendation — habitat fieldwork

Distinct marsh, woodland and quarry paths with evidence-based discoveries. Make exploration and collection goals deeper without simply making drops rarer.

## Read this first: real progress, not promises

### Built/merged — recorded foundation, not a fresh certification

The local Architect state records PRs #1–#8 merged. PR #7’s QA found all 12 full cryptid models present, but only Mothman and Fresno were seen in-world; it failed Bloom. PR #8 tested Ring 1 purchases, costs, effects and persistence; normal input, pan/zoom and several animation checks were unconfirmed. Sources: ops/state-architect.md; qa/pr7-2884f2b-report.md; qa/pr8-0d53700-report.md.

### Planned (specs 06–13) — still a build and QA queue

Local handoffs show #9 at 02a897bc synced to TEST but QA unfinished; #10 onboarding v2 and #11–#13 are queued, rebirth is in flight, atmosphere and seasons follow. This Page is a document review dated 5 November 2026, Europe/London; no new Studio playtest was performed.

### How to read the labels

Planned (spec X) means documented, not shipped. Built/merged means supported by a named historical handoff or QA report, not every acceptance test passed. Undecided: recommendation means a new proposal for builders to review, not an approved implementation task.

### Source precedence and dates

Use spec 09 v3.1 and the cash-random audit over older Bible wording: no expedition tarot tokens, no return-time hidden rolls, no paid readings. Use style guide v0.8 and the art handoff for lighting. Price approval is recorded as Master Controller approval, not proof of live products. November 20 and later update dates are old targets, not a newly confirmed launch schedule; spec 13 anticipates a December launch.

## 1. Player and cryptid stats

### Planned (specs 01, 05, 07, 09, 11) — yes, both have progression stats

Player: cash, income/second, lifetime earned, Tithe, rebirth tier, unlocked pads, altar level, owned rites, catch time and range. Later: Hunt Marks, collection progress and species mastery. Cryptid: species, rarity, fixed base income, mutation/variant, traits field, source and acquisition date. Jersey Devil is Epic, $150/s; Hodag is Common, $5/s. These are a tycoon’s stats, not a combat HP/attack/defence system.

### Undecided: recommendation — IV-style individuals

There is no specified IV generator or ability table yet; a saved traits field is not a built trait system. Later, roll Courage, Instinct and Attunement at 0–10 on genuinely free-source obtains. Use them for small expedition route-fit differences, capped at 5% total duration improvement, not pad income, egg odds, catch contests or leaderboard points. Paid grants have fixed disclosed aptitudes; cash offers disclose every value before purchase.

### Undecided: recommendation — the Stat Card on every acquisition

After the true-tier reveal, open a compact dossier: creature portrait, name + rarity word, Normal/Shiny/Corrupted, base income → placed income, three aptitude bars, trait name + exact effect, Bond, mastery, source and first-found date. Buttons: Bind, Compare, Keep. On phone show the essentials first, Details for the rest; batch readings use a swipeable result stack. Example: Hodag · Common · $5/s · Courage 8/10 · Marshwise · Wild catch. This card and these example rolls are not built.

### Undecided: recommendation — unique abilities without power inflation

Give each free-found individual one trait, with the provisional rates below, independent of species rarity. Rare ability tiers unlock more distinctive behaviour and utility, not a stronger cash multiplier. Show the trait table before earning, and show joint odds when source restrictions apply. Never sell trait rerolls, trait luck, random crafts or chance upgrades; Server Luck remains the sole paid odds item and never changes trait or variant odds.

### Planned (specs 09–12) / Undecided: recommendation — retention layers

Already planned: cosmetic Shiny/Corrupted and event looks; species mastery at 5/15/40/100/250 obtains, capped at +5% species income; separate found-variant pages. New proposal: individual Bond 1–10 from active use, unlocking an idle animation, dossier notes and a pad ornament, with no decay or passive AFK obligation. Preserve Bond on the chosen rebirth familiar. Defer additional weather-mutation mechanics: their rates and effects are not settled.

Undecided: recommendation — one trait roll per eligible free-source individual; total 100%. These are ability tiers, not species rarities.

| Ability tier | Rate | Example utility |
| --- | --- | --- |
| Familiar | 60% | Marshwise: marks known marsh landmarks |
| Unusual | 25% | Keen Listener: subtitles nearby creature cues |
| Rare | 10% | Pathfinder: shows discovered route directions |
| Occult | 4% | Runesight: reveals optional fixed lore inscriptions |
| Singular | 1% | Living Omen: bespoke idle + personal cosmetic sigil |

## 2. Is 12 cryptids enough?

### Planned (spec 09 §3) — 12 is a sensible launch roster

Four Commons: Mothman Hatchling, Fresno Nightcrawler, Hidebehind, Hodag. Four Uncommons: Jackalope, Dover Demon, Snallygaster, Loveland Frogman. Two Rares: Flatwoods Monster, Beast of Bray Road. Two Epics: Jersey Devil, Loch Ness Serpent. Legendary/Mythic are not launch pools; the older 34-entry journal is a longer-term ambition.

### Built/merged — models exist; finished presentation is not proven

Art’s asset list records full models for all 12, and PR #7 QA inspected all 12 in ReplicatedStorage. That does not mean all 12 passed phone readability, animation or in-world showcase QA.

### Undecided: recommendation — ideal launch is 12 polished, not 24 rushed

Ship 12 with clear silhouettes, excellent binding and a useful Bestiary; 16 is a stretch only after the core passes QA. Spec 11’s model completes the base 12 around day 2, so species count alone will not retain players. Keep its 3–4-species weekly update ambition conditional on quality; variants, mastery and R1–R7 supply the longer chase. Do not advertise 36 species when you mean 12 species × 3 looks.

## 3. Expeditions, eggs and materials

### Planned (specs 03, 04, 09 §8, 12 §6.2; Bible §4) — January, not launch

The Expedition Board is a reserved/shuttered feature. Pick a cryptid and route, send it through a lantern-lit doorway, and track a real server timer. The later Expedition Lore rite reduces duration by 10%. Crucially, spec 09 v3.1 requires every reward to be rolled free and shown at send-off; the old Bible’s return-time roll is superseded. No tarot tokens may come from expeditions.

### Undecided: recommendation — a complete first version

One free expedition slot. Free routes: Lantern Wood, 10 minutes; Hollow Marsh, 1 hour; Bell Quarry, 4 hours. The selected cryptid temporarily leaves its pad; state that income trade-off before confirming. Server time advances offline. Before Send, show all outcomes already determined: named creature or egg contents, every stat/trait, cash, materials and any relic. Return only delivers that exact manifest, once; disconnects cannot reroll it.

### Undecided: recommendation — egg finds and boosts

Eggs, egg rates and an egg-finding stat are not in the current specs. Start a prototype at one egg with a 10% free mission chance; an earn-only Field Research track could raise this to 12%, then 15%, maximum one egg. Unlock it through free wild fieldwork, never cash, Robux, paid creatures, premium slots or a paid pass. Publish rates. Keep this out of the sellable expedition path until a source/throughput audit proves payment cannot buy more random draws.

### Planned (spec 12 §6.2, amended by audit row 9) — existing expedition loot

Cash and named cryptids are already illustrated in the manifest. A relic is proposed at 10% per expedition; conditional relic shares are Fog Lantern 50%, Cracked Bell 20%, Wisp Jar 20%, Blood Chalice 7%, Rift Shard 2%, Black Sun Coin 1%. Roll and disclose these at send-off, not return. Earned relics trigger full free events; carry at most five of each.

### Undecided: recommendation — additional materials and incubation

Ashwood repairs cosmetic stall/route scenery, Marsh Resin crafts chosen lantern finishes, Bell Fragments buy chosen clock/lair ornaments. Award fixed disclosed amounts; do not replace Ritual Essence’s reading-duplicate role. Skip a second incubation wait in version one: the return can include a short hatch ceremony, but species, IVs, trait and variant were already disclosed. If incubation is added later, prototype a 5-minute free timer with no paid hatch speed or random acceleration.

### Planned (spec 09 §8) — skips have a strict limit

Instant Return is a planned developer product, 19/49/99 R$ for ≤30 minutes/≤2 hours/≤8 hours remaining, at most once per expedition and three daily. It may deliver only the fully known manifest, never reveal or generate eggs/stats/loot. Recommendation: launch the expedition prototype without paid skips; re-audit repeat sends, early cancellations and trait-based speed before enabling this January product.

## 4. Case opening: an honest binding ritual

### Planned (specs 09–10) — cases mean earned tarot readings

No paid random cases. Pale Deck base rates are Common 55%, Uncommon 35%, Rare 9%, Epic 1%; Blood Deck is Uncommon 50%, Rare 40%, Epic 10%. Earned hard pity is 40 Pale cards or 15 Blood cards without an Epic; the live table changes to Epic 100% for a pity card. These January systems are not built/merged in the evidence reviewed.

### Planned (spec 10 §§2–4) — exact sequence and script responsibilities

Shuffle 0.8 seconds → server rolls and saves the result and 50-card strip → client animates the Fate Reel for 4 seconds, settles 0.1 seconds → charge rises only to the true tier → rarity reveal. Reveal times: Common 0.6s, Uncommon 1s, Rare 2s, Epic 3.5s. Server checks earned tokens, pity and odds, stores tarot.freeLog before ReelResult; client handles frames, sounds and reduced motion. Skipping never changes the grant.

### Planned (spec 10 §3) — no manufactured near misses

Every neighbour is independently sampled at the posted odds. The 5.5-second emphasis occurs only when a real adjacent card is higher than the winner and in the permitted band: Pale Rare+, Blood Epic. Never insert a rare neighbour, glow a losing card, use “almost” copy or charge above the actual result. Offer a calm/reduced-motion presentation; no screen shake.

### Planned (spec 10; atmosphere-pass §6) — a vivid Rare example

Your earned Pale card lies on black velvet. The wax seal cracks; the deck whispers across the table. Bone-and-gold pips drift beneath a carved needle, which stops on the server’s actual Rare. The frame warms from bone to moss to silver—and stops there. Silver smoke rises, a low bell sounds, and Flatwoods Monster appears with a NEW seal. The reading remains private. The Stat Card that follows is the new recommendation from section 1; textured velvet, bespoke ink art and a 3D step-out remain later art proposals, not shipped assets.

### Planned (art style guide; atmosphere pass) — restrained VFX

Built-in Part rings and UI first; smoke uses the allowlisted built-in texture. At most six emitters/120 particles per transient effect, within 200 world particles on screen. One client reveal light under three seconds is the explicit exception. Common openings stay short and quiet; Epic adds crimson smoke, not purple or a false Mythic tease. Wax-seal UI skin is Update 1 direction; the full reel is January.

## 5. Every planned gamepass and its value

### Planned (spec 09 v3.1 §10) — base prices, not live listings

The table lists every named permanent pass line, including later cosmetics and earned-reading convenience. Prices are recorded as Master Controller-approved base prices; older PROPOSED labels in other docs are stale. No evidence here proves live creation, sales or conversion. Value explanations are design rationale, not revenue guarantees.

### Planned (specs 06, 09–10) — fair convenience rules

Auto-Collect is sold only if the Offering Bowl works; nothing decays without it. Skip also unlocks at 40 earned cards; everyone can skip seen species. Auto-Open has a visible Stop and optional Rare+/Epic stop. Open x3 consumes only tokens already earned. None adds tokens, changes odds or speeds token earning. Keep the documented policy fallback if Roblox reclassifies these conveniences.

### Planned (spec 09) — products that are not gamepasses

Cash bundles: 25/99/249/499 R$. Lure Totem: 49, position convenience only. Shared income-only Blood Moon: 199. Fixed Satchels: 149–299, each bundle needs its contents/price approval. Moon Pass: 399 per four-week track, not a permanent pass; paid track has no random rewards, tokens or Essence. Instant Return: 19/49/99. Gifts mirror passes at the same price; Founder's Candle is a first-purchase gift, not a pass. No Revive Streak.

### Planned (spec 09 §§6, 9.5) — fixed Rites and the only paid odds item

Bound Rites are one each per account: Hare 99 = Jackalope + 30 Essence + Antler card back; Beast 249 = Bray Road + 60 Essence + banner; Devil 499 = Jersey Devil + 60 Essence + Horned nameplate frame, after the Rebirth 1 Tithe gate. Server Luck is a separate January dev product: first buy 49, then 199; whole eligible server ×2 → ×2.5 → ×3, +10 minutes per buy, 60-minute cap. Fail-closed PolicyService gating and live odds are mandatory; restricted players neither see nor receive it.

Planned (spec 09 v3.1 §10) — permanent passes; release phases are targets, not shipping proof.

| Pass | Base R$ / phase | Value and motivation |
| --- | --- | --- |
| Starter Pack | 49 · launch | $5,000 + fixed Hidebehind once; a clear first purchase |
| Lair Cosmetics | 99 · launch | Gilded/Bone Rite banners and candles; personal style |
| Auto-Collect | 149 · conditional launch | Bank bowl from anywhere; uninterrupted exploring |
| Sigil Nameplate | 149 · launch stretch | Gothic overhead plate + ember aura; visible identity |
| +2 Pads | 199 · launch | Pads 9–10 survive rebirth; bigger display/income, excluded from Tithe |
| 2x Cash | 299 · launch | Double live/offline cryptid income; not Tithe, bundles or daily gifts |
| VIP Lair | 299 · Update 1 | Obsidian gate, gold-veined rims, Keeper tag, town bench; status without luck |
| Skip Animation | 99 · January | Same result instantly; also earned at 40 cards |
| Auto-Open | 149 · January | Open earned tokens with Stop; less repeated tapping |
| Open x3 | 249 · January | Group three owned earned tokens; convenient event sessions |
| Drowned Chapel theme | 199 · January target | Chosen complete lair look; atmosphere ownership |
| Bone Orchard theme | 199 · January target | Chosen complete lair look; collection and self-expression |
| Witch-Light Hollow theme | 199 · January target | Chosen complete lair look; no Neon or power |
| Grave-Candle aura | 79 · January | Restrained candle aura; avatar identity |
| Will-o'-Wisp aura | 79 · January | Restrained particle aura; one aura equipped |
| Gilded Halo aura | 299 · January | Premium gold silhouette; cosmetic prestige |
| Card-back sets | 49 each · January | Four visible backs per set; reading customisation |

## 6. Art, assets and a town worth remembering

### Planned (specs 01–03; art/style-guide.md v0.8) — occult, weathered, readable

Crooked dark timber, slate roofs, tarnished brass, bone chalk and dried-crimson cloth. Cool ash-grey distance fog (#282A30) meets warm lantern pools (#FFB36B). Think a rain-worn folklore town, not a neon pet simulator. Mild dread only: no gore or jump-scares. Winter adds roof snow, frost, bare trees and dark-green wreaths, not a Christmas-only identity.

### Built/merged + Planned (art asset list and handoff) — honest asset sourcing

The 12 existing creatures were built from code as Roblox Parts; they are not a downloaded mesh pack. Future Creator Store assets must be free, licensed, logged, inspected, and stripped of every script and remote before integration. No Blender MCP. Meshy needs Eudai’s explicit approval; do not assume old generated-mesh notes grant it. Launch uses built-in materials and effects, not a promise of bespoke generated textures or rigged animations. Custom textures are later; sounds must be Roblox-licensed and logged. Concept images are not Studio proof or store art.

### Planned (spec 03) — keep Hollowmere’s actual layout

The Weeping Well stays at the origin. Eight clear cobbled roads meet a 120-stud-radius town, with eight inward-facing districts: Pale Pedlar, Lanternwright, Tarot Table, Expedition Board, Bone Broker, Grimoire Lectern, Skill Shrine and Great Rift. A stall marked shuttered has no functional prompt. Do not invent working potion/food shops in today’s build.

### Undecided: recommendation — make empty space tell stories

Cluster leaning noticeboards, patched wheelbarrows, stacked firewood, crooked chimney pots, rain barrels, abandoned boots, weathered census plaques, washing lines and dry stone troughs beside buildings. A shutter taps gently; a sign creaks; a crow changes perch. These are decorative, not hidden purchases or fake players. Keep all eight roads and stall interaction zones clear; pool short local idle loops and stop them at distance.

### Undecided: recommendation — potion-maker and stall

Morrow the apothecary: a tall, wrapped figure with stained gloves, a moss-coloured apron and a kettle-shaped roof vent. The counter has labelled smoky-glass bottles, dried reed bundles and a tiny mechanical scale. Every 12–18 seconds Morrow stirs, checks a bottle, then folds a note. Initial stall is decorative, integrated into an existing district façade. If made functional later, sell chosen lantern dyes or fixed-duration, fixed effects only—never egg, mutation or rarity luck.

### Undecided: recommendation — food-shop character

Nell the night cook: rolled sleeves, patched crimson apron, a crooked pie hatch beneath a sagging slate awning. A covered pot releases a small budgeted wisp; Nell wipes a bowl and slides bread onto a board. Benches, hanging ladles and stacked crockery make the town hospitable. Keep food decorative/emote-only first: no hunger punishment, required meals or paid catch advantage.

### Planned (spec 03) / Undecided: recommendation — the named district residents

The Pedlar already has four cages, five-minute global stock and a RiftDim lantern (PointLight #7FA34A, range 10, brightness 0.8). New characterisation: a veiled figure taps each cage at restock, then turns the real stock ledger. Lanternwright: copper goggles, shuttered bench, hanging tool silhouettes, polishing an unlit lantern. Bone Broker: chipped abacus and specimen labels. Tarot keeper: pale gloves and a self-shuffling deck. Expedition keeper: oilskin coat and pinned route maps. These NPC looks and idle loops are proposals; the shop locations are spec facts.

### Undecided: recommendation — the Hollow Clock

Add a narrow crooked belfry beside/behind the Well, never replacing it or blocking the eight-road sightlines. Bone numerals, tarnished-gold hands, an exposed slow pendulum and a moon-phase ring become Hollowmere’s recognisable silhouette. Budget it as one building, ≤150 Parts, within the town’s 4,000-Part ceiling; add no new lights. Normal face shows the town clock; a separate labelled ring shows only a real scheduled event or a server-confirmed omen countdown—not a prediction of a random event.

### Undecided: recommendation — when the timer reaches zero

During the 45-second omen its bell gives a low note and the moon ring creeps closed. At the authoritative EVENT start, the clock face turns silver-grey for Fog Night, crimson for Blood Moon, or gold-edged shadow for Eclipse; hands separate into a sigil pattern and tiny non-Neon particles lift from the bell. At RETURN start gameplay effects stop, the ring unwinds over 45 seconds, hands resume correct time and the face blends back to the current seasonal baseline. Late joiners read the same phase; an interrupted event also returns smoothly. No flashes, extra reward rolls or added shop prompts.

### Planned (art guide §6; handoff) — wow must fit a phone

Eight lights per lair; town already uses 24/24, so new stalls/clock borrow existing light slots. Small cryptids ≤40 Parts, Rare+ ≤80; stalls ≤150; props ≤20; lair ≤1,200; town ≤4,000. World particles ≤200, ambient rig ≤40; Low disables lair fog and Bloom. No Neon except the two approved eye sets. Reuse materials, LOD decorative motion, and require actual phone/Low QA before calling it finished.

## 7. Weather and world events

### Planned (spec 12) — launch is Fog Night only

Every standard event has a 45-second omen, 30-second crossfade, active phase and 45-second return. Announcements use a quiet sound, chat/HUD line, title and real remaining-time chip—never a shop link. Only one event runs. Effects begin at EVENT, end at RETURN. Fog Night is modelled around 2.8 starts/hour, not guaranteed every 21 minutes; First Night is a stretch rule after onboarding + six minutes.

### Planned (spec 12) — free and bought events are different

Natural/free-started events may change spawns, focus and free odds, with live tables. A bought Blood Moon is only its stated +50% income and look for ten minutes; no Blood-marked spawns, variants, focus or odds. Cash-called Pedlar relic events are similarly deterministic. All event income multipliers are excluded from Tithe, offline rates, daily scaling and bundle quotes.

### Planned (spec 13) / Undecided: recommendation — The Long Night

Update 1+ winter event: reuse Fog Night with a snow skin and one earn-only cosmetic winter look. Its exact duration and reward requirement are undecided; recommend the same five-minute active phase and a fixed cosmetic reward for witnessing three qualifying free events. Do not add winter-only luck, income bonuses or stronger creatures. Seasonal weather itself is cosmetic: snowfall, frost, petals, fireflies or leaves never alter the economy.

### Planned (specs 09, 12) — later calendar moments

Witching Hours are design slots at 19:00–20:00 and 01:00–02:00 GMT in November, with a free Blood Moon omen at :30. Rift Tide: Saturday 18:00–20:00 GMT, free event luck ×1.5 and Moon Rite double progress; monthly Blood Moon Night: first Friday 19:00–21:00 GMT. These are design schedules, not routines created here. Show local times in-game; UK summer time shifts the displayed hour.

Planned (spec 12) unless a visual is explicitly marked recommendation. All times are active durations.

| Event / phase | Announcement and appearance | Gameplay |
| --- | --- | --- |
| Fog Night · launch · 5m | Distant bell; “The birds have gone quiet”; grey wisps, birds fade, moon disappears at peak | Income ×1.1; wild spawns 45→30s; Hidebehind/Dover focus inside tiers; rarity odds unchanged |
| The Tolling · U1 · 4m | “A bell tolls where no bell hangs”; visual profile unfinished; recommendation: pendulum shadows and gentle candle dips | Income ×1.1; belt 10→7s; Mothman/Snallygaster focus |
| Witch-Lights · U1 · 4m | “Pale lights gather”; visual profile unfinished; recommendation: sparse gold motes, not green Neon | Income ×1.1; wild 45→30s; cap 3→4; Fresno/Frogman focus |
| Blood Moon · U1 · 10m | Low horn; “The moon is bleeding”; enlarged moon, crimson grade and distant drum | Income ×1.5; free-started only: Bray/Jersey focus + Blood-marked hunts |
| Rift Storm · U1 · 6m | Thunder omen; “The Rift groans”; ash-green distance grade, gusts, sparse sparks | Income ×1.25; belt 10→6s; free belt Rare+ weights ×1.5 |
| Eclipse · U1 · 5m | Distant bell; “Something is swallowing the moon”; near-silence, bone/gold shadow grade | Income ×1.25; free wild Rare+ weights ×2; Flatwoods/Loch Ness focus |
| The Long Night · U1+ | Spec 13 snow skin; recommendation: muffled bells, frost on the clock and slow snow | Cosmetic winter layer; no additional seasonal economy or odds advantage |

## 8. Hub, map, zones and biome entry

### Planned (specs 02–03) — a shared, walkable eight-player world

Town radius 120 studs; eight 120×120 lairs centred at radius 260; roads run between town and each inward-facing Lair Gate. The back Wild Gate leads to hunting outside radius 330. Return to Lair is a ten-second-cooldown teleport. Friends can be assigned neighbouring plots. This is not currently a set of portal-separated biome worlds.

### Undecided: recommendation — three recognisable Wilds sectors

Lantern Wood: bent trunks, pale leg-shapes between trees, warm distant town lights. Hollow Marsh: reed silhouettes, shallow reflective channels and stone boardwalks. Bell Quarry: cut slate, broken bell fragments and hanging iron chains. Start with connected paths and shared spawn rules; biome-specific pools, creature restrictions and unlock costs are not specified and need an odds/pacing review.

### Undecided: recommendation — entry by place, not a generic portal lobby

A root arch enters the wood, a chained sluice crosses into the marsh, and a cracked bell gate frames the quarry. If later teleport streaming is necessary, use these as custom transitions with exact destinations, readable signs and an instant-motion option. Do not confuse the Great Rift’s reserved future conveyor with a built biome portal.

### Planned (specs 01–05) / Undecided: recommendation — access requirements

The tutorial hunt remains immediately available; town shop/shrine access follows onboarding step 8. No paid biome locks or fixed biome rebirth requirements exist in the specs. Recommend deeper optional paths unlock through fixed free fieldwork tasks, with requirements visible before travel; never hide a launch species behind an unannounced later feature.

## 9. Catching: simple hands, dramatic moment

### Planned (specs 01, 05, 09, 11) — hold to bind

Find an already spawned cryptid, enter 12 studs, then hold the lantern’s bind action for three seconds. Ring 1 can reduce that to 2.25 seconds and extend range to 14 studs. The server owns time and range; leaving range cancels. This is not a random Poké Ball success roll or a specified combat battle.

### Planned (spec 11 §4.1) — contested catches

Anyone can hunt a normal spawn; first to finish the server timer wins. Same-step ties use server receive order. Others who channelled ≥1 second and remain in range get 30 seconds of their own pre-2x income, minimum $50, not a creature or Essence. Owner first sight is two seconds; spawns stay ≥40 studs from non-owners. Assist/hour and pair caps fight farming. The tutorial Hodag remains protected.

### Undecided: recommendation — difficulty without phone frustration

Currently rarity changes reveal drama, not the base channel duration or success chance. Keep that at launch. Later, optional non-ranked field trials can add a slow moving sigil or timed lantern alignment, with an accessible hold-only equivalent and no exclusive species or paid success boost. A twitch/QTE minigame is not currently approved or built.

### Planned (art atmosphere pass §5, stretch) — the catch beat

As the hold fills, chalk draws beneath the creature, fog leans inward and ambience ducks. On real server confirmation, tier smoke curls upward, the chalk burns briefly and a wax-seal thud lands. Epic gets 3.5 seconds of ceremony; Common gets 0.6 seconds. Failure fizzles without a cash penalty. Do not apply the older Bible’s proposed one-second grace: spec 11’s current channel cancels outside range. Catch beat polish is still planned, not proof of a finished system.

## 10. Skill trees and balanced choices

### Built/merged — Ring 1’s two branches

PR #8’s QA report supports the seven buyable nodes, $34,000 total, server effects and saved ownership. Hunter: Steady Hand $1,000, −10% catch time; Long Reach $2,500, +2 studs; Quiet Step $6,000, another −15%, total 2.25 seconds. Lair: Warm Hearth $1,000, +5% income; Masons’ Rite $2,500, −10% pad costs; Altar Devotion $6,000, stronger altar increments; Deep Coffers $15,000, +10% income. Ordinary open/close, pan/zoom and ignite visuals were not all playtested.

### Planned (specs 04–05, 11; audit) — later Hunter and Lair rites

Ring 2 opens at Rebirth 2; each branch’s successive purchases cost $2.5M, $10M, $40M, $160M. Expedition Lore −10% duration and Hunter’s Mark +25% wild-source income are later hooks. Defence nodes wait for reviewed Echo theft. Keen Eye stays sealed; Lure Craft and Blood Tracker must be redesigned as deterministic effects before unsealing—no cash-bought spawn or rarity odds.

### Undecided: recommendation — an Expedition Steward branch

Free progression could offer Pack Ledger (clearer route comparison), Trail Memory (deterministic return-time improvement within a shared speed cap) and Homing Lantern (automatic claim of an already disclosed manifest, never more rolls). Earn egg-finding research separately through free fieldwork; do not put egg odds in a cash-bought tree.

### Undecided: recommendation — a Folklorist branch

Nodes reveal fixed clue annotations, unlock optional lore pages, and give a chosen decorative specimen frame. A capstone changes the appearance of your Bestiary lectern, not your rarity table. This makes discovery a real play style without another inflation multiplier.

### Planned (specs 05, 07) / Undecided: recommendation — balance

Launch branches are not exclusive classes: players can own all seven, keep skills through rebirth and need no paid respec. Balance Hunter’s active convenience against Lair’s deterministic growth. If later branches become exclusive, provide a free transparent respec and comparable utility; no hidden best path, mandatory dormant purchase or paid catch advantage.

## 11. UI: a ritual ledger, built for thumbs

### Planned (spec 01; art guide §5) — one shared visual language

Ash panels, bone text, tarnished-gold rules, crimson action buttons and sharp four-pixel corners. Gothic for titles only; readable body fonts and Oswald numbers. Minimum 14px text, 44px tap targets, safe insets and no overlap with jump/joystick. Rarity always has a word/symbol, not colour alone. Flat-colour fallbacks work without uploaded parchment.

### Planned (specs 01, 03–10) — key screens

HUD: cash, income and current goal. Inventory: creature selection and pad placement. Rites: pan/zoom ritual circle, parchment effects tooltip and server-confirmed wax-seal purchase. Pedlar: four exact offers, 2×2 on phone, real restock and Details. Relics: owned state, actual value and spend summary. Rebirth: explicit losses/keeps and familiar picker. Bestiary: NEW, tier pips, text teases and progress. Tarot: earned tokens, pity, Essence and live odds. Expedition panel is still later scope.

### Undecided: recommendation — two particularly useful additions

Inventory filters for species, rarity, variant, source and favourite; Compare shows actual placed-income changes without hiding trade-offs. Expedition cards keep Send / Return / Claim and the disclosed manifest on one screen. All acquisitions use the section-1 dossier, with a compact mode for repeat finds.

### Planned (specs 01, 09, 12–13) — calm and accessible

Reduced Motion, low-effects mode, SFX control, no screen shake and no fast flashing. Localisation-ready keys, legible winter contrast and captions for critical cues. New recommendation: separate reduced-flash and cue-caption settings, scalable text and full gamepad focus QA. Shop nudges wait for step 8 AND five minutes, never interrupt catches, daily/haul, rebirth or world events.

## 12. Balance: several reasons to play, one honest economy

### Planned (specs 01–03, 09–12) — each source has a job

Hunting gives active free catches and social contests. The belt supplies visible deterministic purchases at independent ten-second intervals. Pedlar stock is a global fixed five-minute rotation, with no paid refresh. Expeditions later provide disclosed offline route rewards, not tarot tokens. Earn-only cases offer collection, pity and duplicate Essence. Daily gifts are fixed and pause when you miss a day.

### Planned (specs 06–07, 11) — a long progression ladder

Offline earnings are 20% for at most eight hours; active play matters. Launch R1–R7 costs start at $5M and triple per tier; income grows linearly by +0.5 per rebirth, while pad/altar costs scale ×1.5 per rebirth and altar gains diminish. The Tithe gate blocks bought cash from simply skipping rites. Rebirth keeps skills and one chosen familiar, releases the others, and clearly warns about the reset.

### Planned (spec 11 model) — targets, not player results

Under its two 20-minute sessions/day assumptions: base Bestiary around day 2, R3 day 4, R5 day 10, R7 day 44; all Shiny/Corrupted around 10–13 weeks once available. Modelled light spender speed-up never exceeds 1.69×. These are old simulations, not guarantees: onboarding timing changed and new systems/events need reruns. Retention means enjoyable goals and social variety, not merely longer waits.

### Planned (specs 07, 09, 11–12) — fair competition and controlled sinks

Tithe excludes bought cash grants, daily gifts, 2x Cash, event boosts and Relic-pad income; Hunt Marks count completed wild catches, not rarity or purchases. Essence only buys a chosen species/cosmetic, never random crafting; paid Essence is capped at 150 lifetime. Seasonal looks and rare variants do not multiply income. Existing models of indirect acquisition advantages still need live fairness checks; exclusions are safeguards, not proof that money can never influence progress.

### Undecided: recommendation — test the three biggest balance risks

Measure paid-creature/mastery effects on Tithe, paid expedition speed enabling extra random sends, and buyable species unlocking tarot milestones. The audit already calls for free-source-only token milestones and send-off relic rolls; close those implementation gaps before January. Keep IVs/traits out of competitive power. Tune sources/sinks from evidence rather than making everything impossibly rare.

## 13. Other signature features

### Planned (spec 11) — the server becomes a small community

Hollow Rite: ten minutes of co-op catching, scaled for server size; minimum three catches to qualify, no AFK payout. The Uncommon Chase races to three Uncommons using odds that paid luck does not alter. Weekly Hunt board has cosmetic rewards and a 150-Marks daily cap. These are Update 1 plans, not merged proof.

### Planned (spec 11, launch stretch) — leave a candle

Like another lair at its gate; capped rewards and account/playtime checks resist alt farming. Today’s most-liked lair gets a gold beacon. Visitors have something meaningful to notice besides someone’s cash balance; no paid votes.

### Planned (spec 11, later review required) — Echo theft, not pet loss

A temporary translucent copy earns for fifteen minutes; the owner keeps the real cryptid. Small capped Shaken income loss, shields, new-player protection and free Sanctuary opt-out. This is Update 3 outline only and needs its fresh review before implementation.

### Planned (specs 08–10, 12–13) — a world that remembers moments

The Omens journal records witnessed events. NEW seals record first discoveries. Later free Mythics paint the sky GoldBright with a Bone flare and thin Rift core for twenty seconds; readings stay private, and shop purchases do not trigger it. Seasons dress the same recognisable world all year without changing odds.

### Undecided: recommendation — one emotional through-line

Your chosen rebirth familiar gains a small personal memory entry: where you found it, which omens it witnessed and its Bond milestones. At the Rite it waits beside the altar, then steps through with you. It is a keeper story, not just a better number—and avoids adding another currency.

## 14. Important questions still to settle

### Undecided: recommendation — social play and trading

How do friends find/join each other and compare collections? Is there ever trading? Keep it off at launch, as spec 09 says; later require provenance, duplication prevention, moderation and IsPaidItemTradingAllowed for paid items. Decide nickname filtering and safe communication before adding either.

### Planned (save/QA handoffs; specs 09, 11) — reliability and exploits

What happens if a receipt retries, a server dies mid-rebirth or two sessions claim a reward? Require idempotent grants, locked profiles, migrations, exploit rate limits, recovery tests and rollback plans. Historical save QA had an intermittent shutdown-save concern; do not call the current build safe without regression evidence.

### Undecided: recommendation — competition and low-population play

Can beginners still find creatures with expert hunters camping nearby? Do latency, assist caps and speed checks feel fair? Are co-op goals enjoyable solo or with two friends? Test real multi-client contests, not only scripted attribute checks.

### Planned (specs 01, 12–13; art handoff) — accessibility and worldwide feel

Can a dim low-end phone read the Hodag in snow and Fog Night? Can deaf players follow every omen? Do local-time displays, translations, gamepad focus and motion settings work? The northern-hemisphere season default is explicit; recommend an optional local cosmetic seasonal preference later, with no economy difference.

### Planned (analytics handoff) — retention evidence

Which onboarding step loses players? Track first fun, session length, D1/D7, time to R1/R3/R5/R7, spend-speed gaps and leave rate during omens. Launch gate targets are D1 ≥12% and average session ≥10 minutes; ads-scale bar is D1 ≥15% and D7 ≥3%. These are targets, not observed results. Update funnel labels for onboarding v2 and register pending spec 11/12 events.

### Undecided: recommendation — launch and the real wow gate

What is the minimum scene that must make a new player say “wow”? Recommend: readable first-minute Hodag → satisfying bind → placed income → visible next goal → one calm shared omen. Finish that before eggs, extra shops or more trees. Then confirm the revised launch date, retention read window, update capacity, support/bug-report route and shutdown contingency. Eudai retains Publish, live prices, Content Maturity answers, sign-ins and any real spending.

### Planned (ops/LEAN-RULES.md) — build discipline

Save decisions in specs; give each bot one narrow job and file paths, not repeated history. Use mechanical tests and budget gates. QA reports must say PLAYTESTED, CODE-READ or NOT TESTED, with BuildSha and evidence. This document adds proposals, not orders to expand the active launch queue.

## Source notes for builders

### Primary design sources opened for this answer

specs/01-theme-and-first-3-min.md; 02-player-bases.md; 03-town-centre.md; 04-skill-tree.md; 05-skill-tree-ring1-cut.md; 06-offline-and-daily.md; 07-rebirth-and-leaderboard.md; 08-rare-catch-announcement.md; 09-launch-roster-and-monetisation.md v3.1; 10-tarot-readings-and-reel.md; 11-multiplayer-competition-and-pacing.md; 12-world-events.md; 13-seasons.md; compliance-audit-cash-random.md.

### Art, progress and operational evidence opened

art/style-guide.md v0.8; art/asset-list.md; art/vfx/atmosphere-pass.md; all three ops/handoff-*.md files; ops/LEAN-RULES.md; ops/state-architect.md, state-integration-engineer.md and state-qa.md; QA reports for PR #5, #6, #7 and #8. Historical reports are evidence of those builds only. The older Feel & Wow Design Bible was also read; current specs override its stale expedition, price, source and lighting notes.

### Builder copy

The same design content is saved as specs/14-feel-and-wow.md. New items remain explicitly Undecided: recommendation; this document does not silently approve prices, add paid randomness, certify a build or authorise publication.

### Reference links

- Earlier Feel & Wow Design Bible (current specs take precedence): https://cursor.com/canvas/store-a63cf3f9-8205-497a-abd7-29e4e6dd2d41/f13730a8-df11-4f9b-b132-0a54a568d791
- Roblox paid-random-items policy (recheck before January): https://create.roblox.com/docs/production/monetization/paid-random-items
