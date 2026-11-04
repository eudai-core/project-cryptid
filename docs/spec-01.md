# Spec 01: Occult theme and the first three minutes

This is the implementation note for Spec 01 v1.2. The place is server-authoritative: the client displays replicated state and sends intents. It never decides cash, rewards, prices, or rolls. There are no paid products.

## How to play it in Studio

1. From the repo root, `rojo build -o ProjectCryptid.rbxlx` (or `rojo serve` and connect the plugin).
2. Open the place and press Play. The lair is built when the server starts. Edit mode is an empty place on purpose.
3. Enable **Studio access to API services** when you want the ledger to persist. Without it, Studio runs an ephemeral profile and does not write a DataStore, so a failed load cannot overwrite a real save. A published server does not do this: after three failed reads it kicks with `The ledger would not open. Rejoin.`
4. A fresh profile starts at **$25** with a **Mothman Hatchling** already on Pad 1, earning **$2/s**. Income is credited every 1.0 second. There is no collect button.

The rite, in order:

1. Watch the coffers for 5 seconds.
2. Claim the Fresno Nightcrawler for $50. It binds to Pad 2 ($3/s).
3. Carve Pad 3 for $120.
4. Claim the Hidebehind for $75. It binds to Pad 3 ($4/s).
5. Raise Bone Altar I for $300. All pad income is multiplied by 1.25.
6. Equip the Lantern and catch the Hodag 20 studs outside the exit. Hold still within 12 studs for 3 seconds.
7. Carve Pad 4 for $400 and bind the Hodag on any pad. Income becomes $17.50/s.
8. The Ward Candles goal shows `$X / $1,200`. At $1,200 or more the disabled button reads "The wax is not yet cast". The gold guide beam hides. Skip (`Skip the rite`) jumps here and puts any unclaimed Fresno Nightcrawler, Hidebehind, and Hodag in inventory. It does not grant cash, pads, or altar levels.

Use the banner button or the in-world prompt (E). Both send the same remote. The server checks the type, the rate limit, ownership, and the price again.

## Session lock

Profiles live in the DataStore `ProjectCryptid_Player_v1`, key `player_<userId>`. The document is `{ lockJobId, lockExpiresAt, profile }`. Spec 01 wrote `dataVersion` 2. `totalEarned` is lifetime income and starts at 0, so the $25 grant is not counted. A version 1 save counted that grant, so loading one subtracts $25 from `totalEarned` once and floors at 0. Loading a version 2 or 3 save does not subtract again. Spec 02 writes `dataVersion` 3 and adds `base.defences` (see [`spec-02.md`](spec-02.md)). A cryptid still stored as `wild_common` is renamed to `hodag` on load. The original document is not edited in place; a failed migration does not write.

This is a purpose-built `UpdateAsync` lock, not ProfileStore. The save is one small document and the lock rules are covered by Lune tests. A later spec can swap in ProfileStore without changing the profile shape.

- The lock lasts **90 seconds**. The server rewrites the profile and the lock every **30 seconds**, which is stricter than the spec's 60 second autosave. Purchases also request a save, throttled to **2 seconds**. Leaving always releases the lock after the latest profile is written.
- A lock whose job id is ours can be refreshed even if the expiry has passed, as long as nobody else has taken it.
- A lock owned by another server is stolen only after `lockExpiresAt`. Until then the player is kicked with `The ledger is open elsewhere. Rejoin.`
- `UpdateAsync` returns without writing when the decision is `locked`, `corrupt`, or `lost`. A missing key is created only on first join. A save never recreates a missing key, so a failed read cannot be replaced with a fresh $25 profile.
- Reads try **3 times**. The wait after a failure is 1 second, then 2 seconds. A newer `dataVersion`, a non-table, or a profile that fails validation is corrupt: the player is kicked and nothing is written.
- `onboarding.playSeconds` is stored on the onboarding record. The spec's key list does not name it, and the 5:00 steal window needs it.

## QA test mapping

| # | Test | Where it is proved |
| --- | --- | --- |
| 1 | Fresh join: $25, starter on Pad 1, `+$2/s` within 5 s | Lune `QA1 fresh profile is the starter lair`. Studio: play a new user and read the plaque before the first goal ends. |
| 2 | Idle 10 s → $45 ± $2 | Lune `QA2 ten idle seconds credits exactly twenty dollars` (exact $45). Studio: do not buy anything and read cash at ~10 s. |
| 3 | Buy Rift #1 once, income `+$5/s` | Lune `QA3 through QA8 purchase chain`. Studio: claim the Fresno Nightcrawler and read the plaque. |
| 4 | Pad 3 costs $120; Pad 4 stays $400 | Lune chain asserts Pad 3 unlocks and Pad 4's price is still 400. Studio: carve Pad 3 and read Pad 4's plate. |
| 5 | Rift #2 costs $75; income `+$9/s` | Lune chain. Studio: claim the Hidebehind. |
| 6 | Bone Altar I costs $300; server income $11.25/s | Lune chain (`Income.perSecond` is 11.25). The plaque shows `+$11.25/s`. |
| 7 | Catch and place → `+$17.50/s` | Lune chain, including the wild catch sitting in inventory until Pad 4 is carved. Studio: walk the lantern out the exit, catch, carve, bind. |
| 8 | Step 8 shows Ward Candles `$X / $1,200` and hides the arrow | Lune chain asserts the headline, the formatted progress, a disabled button, and `showArrow = false`. At $1,200 the button reads "The wax is not yet cast" and does not buy. Studio: confirm the beam is gone. |
| 9 | Steps 1–7 in ≤ 3:30 | Lune `QA9` simulates the income waits (no walking) and asserts the clock stays under 210 s. Studio: play without skipping and time the rite. Walking is not simulated. |
| 10 | Leave at step 4 and rejoin | Lune: migration keeps cash, pads, and step. Studio: leave on the Hidebehind goal with API access on, rejoin, and confirm the offer is back if it was not bought. |
| 11 | Second join after completion does not grant another starter | Lune `starter grant happens once` and the session document test that a second job cannot replace an existing profile. Studio: finish the rite, rejoin, confirm one Mothman Hatchling and no replay of goals 1–7. The Ward Candles line stays. |
| 12 | Buy remote with no cash is rejected | Lune `QA12`. Studio: in the command bar on the server, fire `RequestBuyRift` only through the client remote while broke, or spend down to $0 and press Claim. Cash must not move. |
| 13 | Double-click charges once | Lune debounce (0.25 s) and a second `buyRift` on an already-bought offer. Studio: double-click Claim. |
| 14 | No purchase prompts before step 8 / 5:00 | Lune source guard rejects `MarketplaceService`, `PromptProductPurchase`, and `ProcessReceipt` under `src`. Studio: watch the first five minutes for any core purchase prompt. |
| 15 | Palette tokens, no purple, Rift used sparingly | Lune palette table and a ban on `Color3.new` / `Color3.from` outside `UITheme`. Studio: look at the plaque, banner, and lair. The only Neon is the thin conveyor trim. |
| 16 | Oswald for numbers, nothing under 14 px | Tokens lock Oswald and the 14 px minimum. Studio: phone emulator on the plaque, banner, and pad plates. |
| 17 | Reduced motion | Lune `QA17` checks durations. Studio: press **Steady gaze** and confirm the banner does not slide, the cash does not roll, and the `+$` floater does not appear. |
| 18 | Number format | Lune `QA18`: `$9,999`, `$12.3K`, `$1.23M`, plus `$4.50B`, `$1.00Dc`, `$1.0e34`. |
| 19 | Skip the rite | Lune `QA19`. Studio: press Skip on a fresh profile. Step 8, cash still $25, Fresno Nightcrawler, Hidebehind, and Hodag in inventory, no pads or altar granted, no second copies. |
| 20 | No stealing before step 8 or 5:00 | Lune `QA20`. There is no steal remote in this spec. `StealGuard.canSteal` is the gate a later spec must call. |

## Known gaps

- Ward Candles shows `$X / $1,200`. At $1,200 the button is disabled and reads "The wax is not yet cast". It still cannot be bought; defences are a later spec.
- There is no sell price, so there is no sell remote. `Transactions.canSell` stays false until step 8.
- The candle-snuff sound has no asset id. Goal completion flashes the banner stroke gold.
- The sigil and the disabled mark are text glyphs (`✶`, `⊘`). Parchment and 9-slice frames wait on asset ids.
- Pad nameplates are local to the owner.
- The Hodag still needs a line in the grimoire when that list is written. Id `hodag`, Common, $5/s.

## Resolved questions

Spec 01 v1.2 answered the open questions from the first build. These stay as approved:

- The tutorial catch is the Hodag (`hodag`).
- Skip grants an unowned Hodag plus the unowned rift pair. It grants no cash, pads, or altar levels.
- `totalEarned` is income only. Version 1 saves subtract the $25 grant once on load.
- Ward Candles progress is `$X / $1,200` from the shared formatter. At $1,200 or more the disabled BoneDim button reads "The wax is not yet cast".
- Mobile plaque text is 22 px cash and 14 px income.
- The `Dc` suffix covers the 1e33 tier. `$1.0e34` and above use scientific notation. `999,999` rounds to `$1.00M`.
- Billboards show income after the Bone Altar multiplier. Goal 7 completes when Pad 4 is unlocked and the Hodag stands on any pad.
- Bone Altar II can be bought ($1,500, ×1.50). Level III and higher are rejected.
- Income keeps auto-crediting after the rite.
- Candle light stays `#FFB36B`. After the dark-lair playtest, ambient is `#2C2622`, outdoor ambient `#221E1B`, exposure `0.35`, brightness `0.65`, candle range 18 and brightness 2. Floor and altar stone are lifted warm charcoals (`#3A342F`, `#403932`); walls stay `#1C1917`.
- A locked session uses `The ledger is open elsewhere. Rejoin.` Studio without DataStore API access uses an ephemeral profile and does not write.
