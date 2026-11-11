# Research t352: Roblox retention + monetisation, and what Cryptid should build
**Owner:** Growth Strategist (final task, via Grok Bot) · **Date:** Wed 11 Nov 2026 (Europe/London) · **Status:** research draft, **docs only**
**Not a spec.** No code. **No approved Robux price is changed.** Any new price is labelled "PROPOSED, not approved".
**[A]** = estimate or guess, not verified. Every claim has a URL in §1 or inline. Anything not verified says so.

## 0. TL;DR (read this if nothing else)
- **The big Nov 2026 winners are egg/pet "collect + earn per second" games** (Steal An Egg, Throw Food For Animals). Same bones as Cryptid: collect, place, earn, unlock the next zone.
- **They keep players with a fixed rhythm, not tricks:** weekly updates, scheduled events, offline growth, collection indexes, zone gates.
- **They make money with luck boosts, paid restocks and Admin-Abuse luck windows.** Most of that is a **paid random item** under Roblox policy. Cryptid mostly cannot copy it. That is fine.
- **Our edge:** deterministic, honest versions of the same feelings: scheduled free events, expeditions, stat rolls on **free** catches, set completion, UV Lamp "hunt skill".
- **Top 5 builds:** (1) weekly Convergence event, (2) deterministic Expeditions, (3) UV Lamp, (4) free-source aptitude rolls + dossier, (5) Daily Contracts.

## 1. Sources table (all accessed Wed 11 Nov 2026 unless noted)
### 1a. Game and platform facts
| Game / topic | Finding | URL |
|---|---|---|
| Charts snapshot | Steal An Egg ~631K–649K live (a 913K reading on 10 Nov); MM2 ~407K; Blox Fruits ~195K–226K; Throw Food For Animals ~191K; Brookhaven ~179K; Adopt Me ~115K; Break and Steal an Egg ~89K; Steal a Brainrot ~60K (#12); PS99 ~37K (#21); Fish It ~61K. Trackers differ by minute and method | https://rblxstat.com/lists/most-played-roblox-games · https://endgametools.com/en/roblox/charts · https://gametips.io/news/steal-an-egg-tops-roblox-charts-at-913k-players-clone-follows |
| Monthly average | Steal An Egg averaged 863K in Nov so far (10 of 30 days), down 35.7% vs Oct | https://rostats.io/charts/2026-11 |
| Weekly report | Steal An Egg weekly avg −17%; Throw Food For Animals +151%; Detect and Steal an Egg +1,377% (10K players) | https://rblxstat.com/blog/roblox-weekly-report-2026-11-08 |
| Grow a Garden (GaG) now | ~13K–19K live. Tracker "record 108K" only covers tracking since 29 Sep 2026. **Live counts are from trackers, not Roblox's own API** | https://rblxstat.com/games/7436755782 |
| GaG historic peak | 21M+ concurrent, June 2025 | https://www.gamesradar.com/games/mmo/with-21-million-concurrent-players-roblox-hit-grow-a-garden-is-bigger-than-half-of-steam-combined-but-players-are-already-flooding-another-far-weirder-competitor/ |
| Steal a Brainrot peak | 25.4M concurrent, Oct 2025 | https://www.pocketgamer.biz/robloxs-steal-a-brainrot-becomes-first-game-to-surpass-25m-concurrent-players/ |
| Steal An Egg loop | Grab egg from guarded nest, outrun guardian, hatch (10 s to 20 h timers), place pet to earn $/s, spend on Speed, reach next biome. Nest eggs reset every 5 min. Index pays Money + Speed for each new pet | https://rblxguide.com/games/steal-an-egg/mechanics · https://allthings.how/steal-an-egg-every-pet-and-how-to-get-them/ |
| Steal An Egg mutations + rebirth | Mutations 1.2x to 10x, odds **not published**. Rebirth adds ~5% income per level. Passes (2x money / 2x growth) are not required (wiki claim) | https://stealanegg.wikirealm.com/pets/pet-mutations/ · https://stealanegg.wikirealm.com/guides/rebirth-guide/ · https://stealanegg-roblox.wiki/faq/ |
| Throw Food For Animals | Created 18 Sep 2026; 5 players per server; loop: throw, attract animals, earn, better food, train Throw Power, new areas. Peak ~381K (Oct) | https://bloxgamer.com/guides/throw-food-for-animals-what-the-game-is-how-it-works-and-what-we-know/ |
| Break and Steal an Egg | Created 5 Sep 2026, ~89K live, 97% likes, described as a "near-identical rival" of Steal An Egg. **Its own monetisation: not verified** | https://rblxstat.com/lists/most-played-roblox-games · https://gametips.io/news/steal-an-egg-tops-roblox-charts-at-913k-players-clone-follows |
| Fish It! | Luck stat from rods, baits, server/friend luck and weather; weather is server-wide, ~10–15 min. Wiki-sourced, **not verified in game** | https://fish-it.fandom.com/wiki/Luck · https://www.sportskeeda.com/roblox-news/fish-it-weather-machine-guide |
| GaG shops | Seed + Gear shops restock every 5 min, Eggs 30 min, Cosmetics 4 h, daily merchant at 00:00 UTC. Instant restock costs **79 R$** (Seeds/Gear) and 90 R$ (Eggs) | https://gagcalculatorvalue.com/stock · https://gameboost.com/blog/when-do-shops-restock-gag |
| GaG offline + social | Crops grow offline; gifting of crops and pets; trade window | https://rblxstat.com/games/7436755782 (description) · https://growgarden.wiki/guide/faq/ |
| GaG Anubis event (7 Nov) | Hourly 10-min sandstorm (UTC), hourly event shop, every-2nd-hour server co-op boss (8 obelisks, random server relic), 30-min dig-site objectives | https://www.sportskeeda.com/roblox-news/grow-garden-anubis-part-1-update-patch-notes · https://allthings.how/grow-a-garden-anubis-event-part-1-update-v466-anubis-coins-and-ancient-archeology/ |
| Steal a Brainrot | Conveyor buy + steal + rebirth (18 max). Admin Abuse: Tue 6 pm ET and Sat 3 pm ET, 30–45 min, luck events 4x–35x. Private server 79 R$/month. "Exact spawn rates not public" | https://robloxs.wiki/wiki/brazilian-spyder/steal-a-brainrot/ · https://www.eldorado.gg/blog/steal-a-brainrot-en/steal-a-brainrot-admin-abuse-schedule-explained/ · https://allthings.how/create-and-join-a-private-server-in-roblox-steal-a-brainrot-on-console/ |
| Pet Simulator 99 | Update 101 on 7 Nov. **New update every Saturday 11:00 CT (17:00 UTC).** Huge Rotation every 2 days; Huge Hunter pass **3,250 R$** for +6,250% luck on the active Huge | https://www.biggames.io/pet-simulator-99/updates/latest · https://petsimulatorwiki.com/wiki/huge-hunter-gamepass-pet-simulator-99/ |
| Risers this week | Throw Food For Animals +134%, Ragdoll Physics +583%, Detect and Steal an Egg, Steal A Superhero Egg +357% (1.6K). Most risers are small and spiky | https://bloxbunny.com/trending-roblox-games · https://statroblox.com/leaderboards/gainers |
### 1b. Roblox rules (re-verified today)
| Topic | Finding | URL |
|---|---|---|
| Paid random items | Counts Robux **and** Robux-bought in-game currency. Probability modifiers (luck boosts, pity, enhanced drops, rate-up) count. Odds as % summing to exactly 100%, "Details" word button, live updated when boosted. Earned randomness exempt. Restricted users need a treatment (earn path, hide, block...) | https://create.roblox.com/docs/production/monetization/paid-random-items |
| PolicyService | Must gate with `ArePaidRandomItemsRestricted`; `IsPaidItemTradingAllowed` governs trading paid outcomes | same page; https://en.help.roblox.com/hc/en-us/articles/47965190783892-Promoting-Items-to-Younger-Audiences |
| Fake urgency | No "almost out of stock" or "short time" claims if untrue; no inaccurate or auto-restarting countdowns; no always-on "sale" | https://en.help.roblox.com/hc/en-us/articles/47965051378324-Presenting-Experience-Items-and-Subscriptions · https://create.roblox.com/docs/production/monetization |
| Pressure language | Avoid "GET IT NOW" etc. for minors; use "View Item / See Price / Open Shop" | https://create.roblox.com/docs/production/monetization |
| Skippable timers | Roblox says timers that can be removed or brought forward "are unpopular with Roblox users" | https://create.roblox.com/docs/production/monetization |
| Social + live ops | Limited-time items and trading create excitement; weekly update cadence is "ideal", monthly minimum | https://create.roblox.com/docs/production/monetization |
| Events (LiveOps) | Announce events in advance so players schedule their return; compare KPIs vs week before and after | https://create.roblox.com/docs/production/game-design/liveops-planning |
| Dailies | Short, modest rewards, rotate objectives, "resource drip" | https://create.roblox.com/docs/production/game-design/introduction-to-quest-design |
| Retention docs | D1 = core loop + FTUE (fun in under 5 min); D7 = progression; D30 = updates + social | https://create.roblox.com/docs/production/analytics/retention |
| Contextual purchases | "Right item, right time"; no starter pack on first load; avoid stacked modals | https://create.roblox.com/docs/production/game-design/contextual-purchases |
| DevForum staff (26 May 2026) | Preview-before-buy crates and "reloads every minute" shops are still paid random items; luck passes are modifiers; skill variance exempt. **Page returned 403 today**; quoted from our 4 Nov audit | https://devforum.roblox.com/t/clarifying-requirements-for-paid-random-items/4654622 · `specs/compliance-audit-cash-random.md` §1 |
### 1c. Psychology sources
| Lever | Source | Verified |
|---|---|---|
| Variable reward | Ferster & Skinner 1957, variable-ratio schedules resist extinction. https://www.bfskinner.org/wp-content/uploads/2015/05/Schedules_of_Reinforcement_PDF.pdf · Schultz 1998 https://journals.physiology.org/doi/full/10.1152/jn.1998.80.1.1 | Skinner today; Schultz via spec 16 |
| Near-miss | Clark et al. 2009: near-misses raise desire to play and light up win circuitry. https://pubmed.ncbi.nlm.nih.gov/19217383/ | today |
| Loot-box harm | Zendle & Cairns 2018 (n=7,422): loot-box spend linked to problem-gambling severity; correlational. https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0206767 | today |
| Streaks | Streaks help habits, but broken streaks reduce later behaviour. https://academic.oup.com/jcr/article-abstract/49/6/1095/6623414 (abstract fetch timed out; seen in search summary) · Duolingo https://blog.duolingo.com/how-duolingo-streak-builds-habit/ | search summary only |
| Collection / progress | Nunes & Drèze 2006 (34% vs 19% completion with a head start). https://academic.oup.com/jcr/article-abstract/32/4/504/1787425 · Kivetz 2006, Carey 2008 (set completion) via spec 16 | Nunes today; others via spec 16 |
| Social proof | Salganik, Dodds & Watts 2006. https://www.science.org/doi/10.1126/science.1121066 | via spec 16, not re-fetched |
| Sunk cost | Arkes & Blumer 1985. https://www.sciencedirect.com/science/article/pii/0749597885900494 | today |
| FOMO | Przybylski et al. 2013: FoMO linked to lower need satisfaction and mood. https://www.sciencedirect.com/science/article/pii/S0747563213000800 | today |
| Peak-end + juice | Kahneman et al. 1993 https://journals.sagepub.com/doi/10.1111/j.1467-9280.1993.tb00589.x · GDC "Juice It or Lose It" https://www.gdcvault.com/play/1016487/Juice-It-or-Lose | GDC today; Kahneman via spec 16 |
| Purchase motives | Hamari et al. 2017. https://doi.org/10.1016/j.chb.2016.11.045 | via spec 16 |

## 2. Per-game loop teardown
| Game | Retention loop | Spending loop | Copy for Cryptid? |
|---|---|---|---|
| **Steal An Egg** | Run, steal, hatch, place, earn, buy Speed, next biome. 5-min nest reset. Index pays for each new species. Rebirth +5% | 2x Money / 2x Growth passes; mutation shrines and consumables (odds unpublished) | **Yes:** zone gates, 5-min rhythm, index rewards. **No:** unpublished odds, paid mutation rolls |
| **Throw Food For Animals** | Free training (pull-ups) raises reach, reach unlocks animals. Update 3 added zones gated by 8,000 Throw Power | Better food costs cash; Robux not verified [A] | **Yes:** free grind for access; gate = skill + time, not money |
| **Grow a Garden** | 5-min restocks, offline growth, weather mutations, hourly events, co-op boss with server relic | 79 R$ instant restock; limited-time shop; season pass; gifting | **Yes:** offline growth, co-op server goal, hourly real-UTC events. **No:** Robux restock |
| **Steal a Brainrot** | Conveyor + steal + base lock, rebirth, twice-weekly Admin Abuse (30–45 min) | Cash/gear/Lucky Blocks, private server 79 R$/month | **Yes:** a fixed weekly "event night". **No:** Lucky Blocks and unpublished rates |
| **Pet Simulator 99** | Weekly Saturday update (101 so far), rotating Huge pets, leagues and leaderboards, Season Pass | Luck passes (3,250 R$), exclusive packs | **Yes:** weekly cadence, leaderboards. **No:** luck passes (only gated Server Luck) |
| **Fish It!** | Rod luck stat, server weather, mutations | Luck-linked rods and potions [A] | **Yes:** shared server weather = shared moment. **No:** paid luck |
| **Break and Steal an Egg / Detect and Steal an Egg** | Clones of the egg-steal loop, riding the same demand | Not verified | Signal: the "steal an egg" loop is the live trend; cryptid hunting is the same fantasy with a horror skin |
**Pattern:** the top games all have (a) a **short loop** (5 s to 5 min), (b) a **zone/gate** that feels earned, (c) a **collection index**, (d) a **weekly rhythm**, (e) something to **show off**. Cryptid has (a), (b), (c) in part. It lacks (d) and has little of (e).
**Honest warning:** these games fade too. GaG peaked at 21M and sits near 13K–19K now; Steal An Egg fell 35% in one month. Retention work beats launch hype.

## 3. Cryptid systems: what exists, what doesn't
| System | Doc status | What I assume [A] |
|---|---|---|
| Offline haul, Nightly Offering, Bowl | **Spec 06** (built on main). 20% offline, 8 h cap | Keep as is |
| Wild hunts, contests, assist cash, Hollow Rite | **Spec 11** (planned) | Rite numbers 25/40/60 stay |
| World events, event director, free event luck | **Spec 12** (Fog Night only at launch) | Director can take a weekly slot |
| Tools L1–L5 (Lanternwright) | **Spec 15 §5** (deterministic, never odds) | Stay as written |
| **UV Lamp** | **No doc.** Only named in the Architect log (7 Nov, spec 18 in progress). Spec 15 §10 has "Fog Lamp" | I assume: an information tool; never creates or changes spawns [A] |
| **Per-species capture twist** | Spec 15 §10 gives behaviours + spawn conditions per species. The "twist" rules are in spec 18, **not yet written** | One rule per species, shown in the Bestiary [A] |
| **Cryptid stats / aptitudes** | Spec 14 only: Courage/Instinct/Attunement 0–10, "not built". Architect log: income cap +10%, never leaderboard/Tithe | I assume the numbers in §5 [A] |
| **Supplies shop** | Architect log: the Pedlar becomes a cash-only supplies shop (spec 17 in progress). **No doc yet** | Items in §5 row 9 [A] |
| Expeditions | Spec 03 (shuttered), spec 09 §8 (Instant Return 19/49/99 approved), spec 12 §6.2 (relics) | Deterministic yield; relics shown at send-off (audit row 9) |
**Blocker:** specs 17 and 18 are not on disk. Rows that depend on them are tagged **[needs spec 17/18]**.

## 4. Psychology: each lever, compliant vs not
| Lever | What the science says | Compliant Cryptid version | NON-compliant version (do not build) |
|---|---|---|---|
| **Variable rewards** | Unpredictable reward schedules drive steady, persistent play (Skinner); anticipation peaks when the outcome is least certain (Fiorillo via spec 16) | Wild rarity, variants, **aptitude rolls on free catches**; odds shown in Details even where not required | Paid luck, paid rerolls, cash-bought crates, "pity" counters on paid pulls |
| **Near-miss** | Raises the urge to keep going (Clark 2009) | Contested bind lost: show the real winner + assist cash. Reel neighbour must be real | Animated "almost Mythic" on a paid item; fake near-miss the server did not roll |
| **Streaks** | Intact streaks raise behaviour; broken ones lower it (JCR) | Daily ladder **pauses, never resets**. Weekly Contract Seal needs 5 of 7 days | Streak reset to zero, sold "Revive Streak", "you lost 12 days!" |
| **Collection completion** | Head-start progress raises completion (Nunes & Drèze); collectors want full sets (Carey) | "X of 12 bound", biome sets, Pioneer stamps, endowed 1/2 on the tutorial Hodag | Hiding species behind Robux; "buy the last missing one" prompts |
| **Social proof** | Visible popularity snowballs (Salganik) | Server banners for **real free-source** rare catches; plaza Ledger; visible beam/lantern skins | Fake players, bought-rare announcements, price or buy link on a banner |
| **Rare-drop announcements** | Seeing others win makes rare things feel real | Spec 08 banners: free sources only, DisplayName, 4 s | Announcing Pedlar/Robux purchases as "catches" |
| **Limited-time events** | Roblox calls these a core LiveOps driver | Real UTC schedule published 7 days ahead; real countdown; event is free-started; say plainly if an item returns | Fake "last chance", restarting timers, "only 100 left" with no real count |
| **Sunk cost / progression** | People keep investing in what they already built (Arkes & Blumer) | Bond and mastery **survive rebirth**; rebirth screen lists "You keep / You lose" | Hiding loss on rebirth; "you'll lose everything if you stop" |
| **FOMO (allowed)** | FoMO links to lower mood (Przybylski), so keep it light | Weekly event you can plan for; skippable, returns on a schedule; free catch-up (the Almanac shows the next one) | Daily must-log-in penalties, kids-targeted pressure copy, events only reachable by paying |
| **Juice / peak-end** | People remember peak and end (Kahneman); feedback sells the action (GDC) | Wax-seal BOUND! peak, Stat Card end (spec 16) | Ending the session on a shop modal |

## 5. Ranked feature table (retention, then revenue, then effort)
**Key:** Ret = retention impact · Rev = revenue impact · Effort S/M/L, build hours **[A]**. "Paid-random?" is my read; the audit owner must confirm before build.
| # | Feature | System | Player fantasy | Proposed numbers [A] | Ret | Rev | Effort | Compliance | PROPOSED price |
|---|---|---|---|---|---|---|---|---|---|
| 1 | **Weekly "Hollow Convergence"** scheduled free event + in-game **Moon Almanac** | events | "Saturday night, the whole server hunts together" | Sat **17:00 UTC** (same as PS99's drop), **30 min**, shown 7 days ahead. Free event luck ×2 on wilds (spec 12 Eclipse method), spawn interval 45→30 s, max alive 3→4, Hollow Rite goal 60, income ×1.1. Max 1/week. Nobody can buy or start it | **H**: appointment + shared moment; mirrors Brainrot's 2 events/week and PS99's weekly drop | **M**: lifts concurrent players, Server Blood Moon (199) gets a bigger stage | **S** (~12 h) | Free luck: odds tables shown anyway. Jan Server Luck stacking: show live combined odds, cap ×4 combined [A]; **gate check**. Real clock only | None |
| 2 | **Expeditions, deterministic** | expeditions | "Send a hunter into the Woods; it comes back with a haul" | Routes **30 min / 2 h / 8 h**, yield **15 / 45 / 120 min** of pre-2x income (8 h route beats the 20% offline haul on purpose). Fixed relic per route, **shown at send-off**. Slots: 1 free, 2nd at Rebirth 3, 3rd at Rebirth 6 **or** paid. Aptitude route-fit up to −5% time | **H**: a reason to return at a time of your choosing | **M**: slot pass + approved Instant Return | **M** (~30 h) | **Deterministic = safe.** Relics rolled free at send-off (audit row 9). Slot pass must never add random rolls. Instant Return is approved, but Roblox calls skippable timers "unpopular": keep the free wait fair | **3rd slot 149 R$** PROPOSED, not approved |
| 3 | **UV Lamp: hunt skill** [needs spec 17/18] | tools/UV Lamp + per-species capture | "I read the dark with my lamp" | Hold **E**: cone **30°, 20 studs**, **6 s on / 12 s off**. Reveals species that hide: Hidebehind (seen only when you look away), Dover Demon eyes, Fresno freeze tell. **Spawns exist whether or not the lamp is on.** Tiers by cash: radius 20/28/36/44 studs, cost 15/60/180 minutes of average income [A] | **H**: turns "stand and wait" into a skill read; gives the Bestiary hints a use | **M**: cash sink (cash is bought with Robux) | **M** (~28 h) | **Information only** (like Keen Eye, audit row 8). Never spawn rate, rarity, variant, catch time. Tier time/range must stay deterministic; QA: spawn table identical with lamp on/off. If it ever shortened contested bind time, make it earn-only | None (cash only) |
| 4 | **Aptitude rolls + Dossier card** [needs spec 18] | cryptid stats | "This Hodag is a 9 Courage. Mine is special" | Courage / Instinct / Attunement 0–10 on **free-source** obtains. Odds per stat (sum 100): 0:3 · 1:5 · 2:8 · 3:11 · 4:14 · 5:16 · 6:15 · 7:12 · 8:8 · 9:6 · **10:2**. Mean 5.02. **"Prime" mark** at total ≥24: **1.77%** (my calc). Effects: income cap **+10%** (Eudai t350, per Architect log), route time ≤ −5%. Never leaderboard/Tithe. No rerolls | **H**: every catch has a second dice roll; chase 10s; ties to Bond | **M**: fixed disclosed aptitudes inside Bound Rites | **L** (~45 h) | Free rolls: no disclosure required, show in Details anyway. **Paid grants fixed and shown. Cash never buys a roll.** Pay-to-win guard: +10% cap, nothing in contested hunts | Uses existing Bound Rite prices (99/249/499); none new |
| 5 | **Daily Contracts** ("Marks") | per-species capture / events | "The Hollow sets me three marks today" | **3/day** from a pool of ≥12, reset 00:00 UTC. Rewards **5 / 10 / 15 min** of pre-2x income. All 3 = Contract Seal. **5 of 7 days** = weekly Candle cosmetic. Missing a day costs nothing | **H** (Roblox calls dailies a retention tool) | **L** | **S** (~14 h) | Free earn. Rewards are cash minutes only: no Essence, tokens, or readings. No shop prompt on the panel | None |
| 6 | **Biome Sets + Grimoire** | per-species capture | "Complete the Woods" | Woods **4** (Fresno, Hidebehind, Jackalope, Bray Road), Marsh **3**, Quarry **3**, Wanderers **2** (Mothman, Hodag). Set reward: Bone frame + **10 min** income + lair banner. Tutorial Hodag = **1/2** Wanderers at minute ~3 (endowed progress) | **H**: completion drive | **L** | **S** (~12 h) | **Only free-source obtains count** (audit row 13). Shows spawn conditions free | None |
| 7 | **Per-species capture twists** [needs spec 18] | per-species capture | "Every cryptid fights differently" | 12 rules from spec 15 §10 (hides, charges, freezes when watched...). Shown in Bestiary before the hunt. Ship 4 in Update 1, 4 in Jan, 4 later. **~7 h each** | **H** long-term (variety, D30) | **L** | **L** (~80 h) | Skill variance = exempt. No species locked behind the minigame; hold-only accessibility mode | None |
| 8 | **Moon Pass track design** (Jan) | events | "A season I can fully chase" | Pass is **already approved at 399 R$**. Propose **8 weeks, 30 tiers**, XP from contracts and catches (earned). Free track + paid track of **fixed cosmetics shown up front** | **M** (locals) | **H** | **M** (~36 h) | No Essence, tokens, readings or random items in the pass (handoff rule). Show end date truthfully. No tier-skip upsell [A] | **None: keeps 399** |
| 9 | **Supplies shop: Field Kit** [needs spec 17] | supplies shop | "I stock my satchel before the hunt" | Cash only. **Bait** (one species, spawns it at your spot once its condition is met; 90 s cooldown, **3/day per species**, bait spawn is **Normal variant only**), **Lantern Oil** (fixed 10 min extra beam range), **Fog Lamp** (spec 15). Prices as income-minutes: Common 3 · Uncommon 8 · Rare 25 · Epic 90 [A] | **M**: gives cash a purpose beyond pads | **M**: cash is sold for Robux | **M** (~30 h) | **Cash = paid, so everything is deterministic.** Species chosen by the buyer, variant fixed Normal, rarity odds untouched. **Medium risk [A]: needs audit row before build.** No restock or reroll, ever | None (cash only) |
| 10 | **Pioneer stamps (launch week)** | events | "I was here when the Hollow woke" | Any account that binds a species during the **first 7 days from launch** (20–27 Nov) gets a Pioneer stamp on that Grimoire page. End date shown | **M** | **L** | **S** (~8 h) | Real, dated, no fake counts, no purchase path. Light FOMO only | None |
| 11 | **Hollow Rite co-op** (spec 11, Update 1) | events | "We feed the Hollow together" | Existing goals **25 / 40 / 60** catches in 10 min, every 30 min; rewards 5/10/15 min income | **M**: social glue | **L** | **M** (~28 h) | Free-started events only; assist half. Matches GaG's co-op boss pattern | None |
| 12 | **Bond care ladder** | cryptid stats | "My Hodag trusts me" | Bond levels at **6 / 24 / 72 / 168 / 336 h** placed on a pad. Cosmetic aura + frame; **kept through rebirth** | **M**: honest sunk cost, softens rebirth | **L** | **M** (~22 h) | Cosmetic only (spec 14). No Robux skip | None |
| 13 | **Lantern & UV beam skins** | tools/UV Lamp | "My beam is the one everyone sees" | Colour skins for the lantern and UV Lamp beam. Visible in contested hunts. No stat change | **L** | **M** (social, Roblox "tourist" item) | **S** (~10 h) | Cosmetic, fixed content, shown before buying. No "limited" claims unless true | **49 R$ each** PROPOSED, not approved |
**Why this order:** rows 1–7 are the retention engine and mostly free of money risk. Rows 8, 9 and 13 carry the revenue. Rows 10–12 are cheap polish.
**Build-hour totals [A]:** rows 1, 5, 6, 10 ≈ 46 h (all after the Fri 13 Nov freeze, so Update 1). Rows 2, 3, 4, 7 ≈ 183 h.

## 6. Rejected or dangerous ideas
| Idea | Where seen | Why rejected |
|---|---|---|
| **Paid shop restock / reroll** | GaG 79 R$ | Pay to re-roll random stock = paid random item (DevForum staff #54, via audit). Our Pedlar has **no** restock skip |
| **Luck passes / paid hatch luck** | PS99 3,250 R$ Huge Hunter; Fish It luck | Probability modifier. Only gated Server Luck (Jan) is allowed |
| **Cash-bought eggs, crates, Lucky Blocks** | Brainrot, PS99 | Cash is paid currency. Random output = paid random item |
| **Unpublished odds or spawn rates** | Brainrot, Steal An Egg mutations | We publish tables even for free rolls |
| **Admin-Abuse style paid luck** | Brainrot luck events | Free-start events only; nobody buys a start (spec 12 §6) |
| **Streak reset / streak repair for Robux** | common in apps | Broken streaks reduce play and pressure kids. Daily ladder pauses |
| **Fake or restarting timers, "deal of the day"** | any | Explicit Roblox violation |
| **"Only X left", "last chance", "buy now" copy** | any | Roblox "pushy language" guidance for minors |
| **Trading at launch** | GaG, Brainrot market | Scams, minors, `IsPaidItemTradingAllowed` duty. Revisit at Update 3 |
| **Steal/PvP loss at launch** | Brainrot | Planned Update 3. Griefing hurts D1 for young players. Needs a fresh review |
| **Near-miss on a paid item** | slots, wheels | Violates our "never imply a higher tier" rule |
| **Pity counters on paid pulls** | gacha | Named in Roblox policy as a probability modifier |
| **Paid Bait with random variants or rarity** | my own row 9 trap | Cash purchase + random result. Variant fixed Normal, species chosen |
| **Extra expedition slot that adds random rolls** | row 2 trap | "Enhanced resource drops" [A]. Yield is deterministic |
| **Tier-skip upsell on Moon Pass** | many passes | Pressure + skippable timer. Not recommended [A] |
| **Pay-to-rank Tithe or leaderboards** | any | Spec 07: Tithe stays pure play |
| **Fake players / bots for social proof** | any | Spec 15 §3 |
| **Copying GaG-style "always on" limited shop** | GaG | An always-on "limited" shop is a false-scarcity risk |

## 7. Acceptance + QA checklist for ANY new paid item
Run this before the Architect builds it, and again before Eudai creates the product.
1. **Written spec** with fixed contents, price, and "PROPOSED, not approved" until Eudai approves. Growth never creates products or publishes.
2. **Random?** If any outcome is random and Robux or cash pays for it, directly or indirectly: STOP. It needs odds, Details, live boosted odds, and the PolicyService gate.
3. **Probability modifier?** Luck, pity, spawn rate, rarity, variant, mutation, "enhanced drops": treat as paid random. Only Server Luck passes.
4. **Cash check:** anything bought with cash is deterministic. Variants fixed, species chosen, no reroll, no restock skip.
5. **Odds math:** every table sums to exactly **100%**; run `verify_odds.py`; run `reel_check.py` if a reel exists.
6. **PolicyService:** `ArePaidRandomItemsRestricted` read per player, **fails closed** (error = restricted). Restricted players: no sales button, no paid boost.
7. **Honest copy:** no fake timer or scarcity, no "last chance / GET IT NOW", no "only"/"just". Buttons: **View Item / See Price / Open Shop**. A real end date is shown for anything limited.
8. **Placement:** nothing before onboarding step 8 + 5:00; not on haul, daily, rebirth, bind, reveal or event omen screens; no stacked modals.
9. **Fairness:** no effect on Tithe or leaderboards; no contested-hunt advantage; no change to bind time unless earn-only.
10. **Server rules:** server-authoritative grant; idempotent receipt ledger; entitlement survives rejoin; restricted account tested.
11. **Free path:** every convenience item has a fair free path (e.g. Skip Animation at 40 earned cards).
12. **Tests:** price shown equals approved price; spawn table identical with item on/off; two accounts, one restricted; refund/rejoin test.
13. **Sign-off:** audit row added to `compliance-audit-cash-random.md` by its owner; Eudai approval recorded with who and when.

## 8. Notes for Grok Bot
- **Nothing here changes an approved price.** Only rows 2, 13 carry new PROPOSED prices (149 / 49 R$).
- **Rows 3, 4, 7, 9 depend on specs 17/18**, which are not on disk yet. Re-check numbers when they land.
- **No new random-paid items.** Server Luck stays January-only and gated.
- **Data limits:** player counts are tracker snapshots, not Roblox's own API. Fish It, Break and Steal an Egg and Detect and Steal an Egg loops are partly wiki-sourced or unverified. Several psychology papers are cited via spec 16, not re-read today.
