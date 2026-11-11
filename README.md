# Project Cryptid

Project Cryptid is a Roblox cryptid-collecting tycoon with a dark occult horror theme. Players find cryptids and build a tycoon around what they uncover.

This repository is a [Rojo](https://rojo.space/) project: Luau source on disk builds into a place file you can open in Roblox Studio. Spec 01 (the shared occult theme and the first three minutes) is described in [`docs/spec-01.md`](docs/spec-01.md). Spec 02 (one walled lair plot per player) is described in [`docs/spec-02.md`](docs/spec-02.md). Spec 03 (Hollowmere and the Pale Pedlar) is described in [`docs/spec-03.md`](docs/spec-03.md).

## Prerequisites

- [Rojo](https://rojo.space/docs/v7/getting-started/installation/) 7
- Roblox Studio
- The Rojo Studio plugin, for live sync

Rojo, Selene, StyLua, and Lune are pinned in [`rokit.toml`](rokit.toml). [Rokit](https://github.com/rojo-rbx/rokit) installs that pin file:

```bash
rokit install
```

Installing the Rojo CLI on its own is enough if you only need to build a place. [Aftman](https://github.com/LPGhatguy/aftman) is an older toolchain manager; this repo pins tools with Rokit.

## Build

From the repository root:

```bash
rojo build -o ProjectCryptid.rbxlx
```

Open `ProjectCryptid.rbxlx` in Roblox Studio. Built place files are gitignored.

`ReplicatedStorage.BuildSha` is `dev` in that build. QA reads the attribute in the edit session (`inspect path=ReplicatedStorage`) to see which commit is loaded. There is no separate generated file: the value is a committed project attribute, and the stamp script below rewrites that one string in the working copy.

The Integration Engineer stamps the commit before building a place that will be tested. A GitHub zip has no `.git` directory, so pass the commit from the archive name:

```powershell
.\scripts\stamp-build.ps1 -Sha <commit>
rojo build -o ProjectCryptid.rbxlx
```

From a git checkout the script can read `HEAD` itself:

```bash
./scripts/stamp-build.sh
rojo build -o ProjectCryptid.rbxlx
```

`BUILD_SHA` is used when no argument is passed. If no commit can be resolved, the attribute stays `dev`. Do not commit a stamped SHA. Put the working copy back with `./scripts/stamp-build.sh dev` or `.\scripts\stamp-build.ps1 -Sha dev`. `rojo build -o ProjectCryptid.rbxlx` without the script still builds, and the attribute is `dev`.

## Studio playtests

Start a bot playtest with `args=qa:<seconds>` (for example `args=qa:300`). `ServerScriptService.Dev.StudioTestWatchdog` ends that session itself, so nobody has to press Stop if the bridge drops. It does nothing in a live server, and nothing when the argument is missing, so a manual Play is left alone.

The seconds are clamped to 1–1800. The ops guide does not name a range; 1800 is thirty minutes, and `0` is raised to 1 so a typo cannot end the test before the bridge reconnects. A `qa:` argument with no usable number uses 300. A suffix such as `qa:420:plots3` uses 420. Suffixes can be combined. In Studio only, `qa:<seconds>:loadfail` kicks before the ledger opens, `qa:<seconds>:foreignlock` plants a fresh lock from another job, and `qa:<seconds>:foreignlock:stale` plants an already expired one. Those three do nothing in a live server. The output shows both moments:

```text
[Cryptid:Watchdog] armed for 300s (args "qa:300")
[Cryptid:Watchdog] ending bot playtest after 300s
```

`GetTestArgs` returns the value as it was passed. The wrapper passes one string, so a table argument does not arm the watchdog.

Suffixes on that same `qa:` string are Studio-only and never become remotes. `offline:<seconds>` rewinds the loaded `lastSeenUnix` before the haul is computed (`qa:300:offline:7200` is two hours away). `utc:<days>` shifts the Nightly Offering day number (`qa:300:utc:1`). `utcjump:<seconds>` adds one more UTC day after the test has been running that long (`qa:300:utcjump:20` lets you claim, wait, and claim the next step). `loadfail`, `foreignlock`, and `foreignlock:stale` are the save-debug hooks. `opentree` opens the rites circle through its normal open path once onboarding step 8 is met. `reducedmotion:on` and `reducedmotion:off` set that session's motion only and are not written to the save. Unknown suffixes such as `plots3` are ignored. A published server does not read them. The haul still uses `os.time()` and the saved `lastSeenUnix`, never the client clock.

A Studio playtest can also start the test player with a set purse: `args=qa:600:cash50000`. On profile load the server sets that player's cash to the number, clamped to 10,000,000 (`QaConfig.MAX_GRANT`). `qa:600:plots3:cash50000` is the same grant with the plots suffix. This runs only when `RunService:IsStudio()` is true and the argument is a `qa:` string with a `cash<N>` token. It does nothing in a live server, nothing on a manual Play, and nothing when the token is missing or malformed. It does not change total earned. There is no remote and no chat command. The Output window shows:

```text
[Cryptid:QA] granted cash 50000 to <userId>
```

Use this to reach Quiet Step. Steady Hand, Long Reach, and Quiet Step together cost $9,500, and the catch then takes 2.25 seconds.

An unpublished Studio place cannot call the DataStore API. The server then uses an in-memory mock, once, and the real load, save, and release path still runs (session lock and migrations included). A live or published server never installs the mock. The Output window shows this warning a single time:

```text
[Cryptid:DataStore] Studio has no DataStore API access. Using an in-memory mock store. This session is not saved to a live DataStore.
```

Any other DataStore error is still reported as `Ledger read failed` and, after the retries, kicks the player. The mock is not a substitute for those failures.

## Live sync

```bash
rojo serve
```

In Studio, connect with the Rojo plugin.

`servePlaceIds` in `default.project.json` stays `null`. The live place id is not set, and a plain `rojo serve` must not attach to the private test universe. That universe is place `80631305127330`, with Studio API access on. Serve it with `rojo serve serve.test.project.json`. The in-memory mock must not warn there. What the mock cannot prove is listed in [`docs/published-place-checklist.md`](docs/published-place-checklist.md).

## Folder layout

| Path | Roblox instance |
| --- | --- |
| `src/server` | `ServerScriptService` |
| `src/client` | `StarterPlayer.StarterPlayerScripts` |
| `src/shared` | `ReplicatedStorage.Shared` |

| File | Built instance |
| --- | --- |
| `*.server.luau` | `Script` |
| `*.client.luau` | `LocalScript` |
| other `*.luau` | `ModuleScript` |

## Lint, format, and tests

```bash
selene src
stylua --check src tools/rbx_check
lune run tests/run.luau
lune run tools/rbx_check
```

Lune runs the pure-logic tests (cash format, income, onboarding, schema, session lock, plot ring, assignment, migration, the Pale Pedlar, the playtest watchdog budget, the ledger against the in-memory DataStore, offline haul, the Nightly Offering, and the Offering Bowl). It does not need Studio. Studio steps are in [`docs/spec-01.md`](docs/spec-01.md), [`docs/spec-02.md`](docs/spec-02.md), and [`docs/spec-03.md`](docs/spec-03.md).

`lune run tools/rbx_check` is a static, offline pass over `src`: server-side remote checks, no client cash or shop rolls, no yields on Heartbeat-style callbacks or in `*.hot.luau`, no allocation in `*.hot.luau`, DataStore keys within 50 characters, deprecated APIs, `wait()`, `Instance.new` with the parent in the constructor, and gameplay integers that belong in Config. It does not call the network. A failed check exits non-zero. `lune run tools/rbx_check --self-test` checks the rules against built-in samples. The MIT notice for the adapted runner is in [`tools/rbx_check/LICENSE-THIRDPARTY`](tools/rbx_check/LICENSE-THIRDPARTY).

`selene.toml` sets `std = "roblox"`. `stylua.toml` is the formatter config.
