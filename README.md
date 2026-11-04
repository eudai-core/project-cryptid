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

The seconds are clamped to 1–1800. The ops guide does not name a range; 1800 is thirty minutes, and `0` is raised to 1 so a typo cannot end the test before the bridge reconnects. A `qa:` argument with no usable number uses 300. A suffix such as `qa:420:plots3` uses 420. In Studio only, `qa:<seconds>:loadfail` kicks before the ledger opens, `qa:<seconds>:foreignlock` plants a fresh lock from another job, and `qa:<seconds>:foreignlock:stale` plants an already expired one. Those three do nothing in a live server. The output shows both moments:

```text
[Cryptid:Watchdog] armed for 300s (args "qa:300")
[Cryptid:Watchdog] ending bot playtest after 300s
```

`GetTestArgs` returns the value as it was passed. The wrapper passes one string, so a table argument does not arm the watchdog.

Suffixes on that same `qa:` string are Studio-only and never become remotes. `offline:<seconds>` rewinds the loaded `lastSeenUnix` before the haul is computed (`qa:300:offline:7200` is two hours away). `utc:<days>` shifts the Nightly Offering day number (`qa:300:utc:1`). `utcjump:<seconds>` adds one more UTC day after the test has been running that long (`qa:300:utcjump:20` lets you claim, wait, and claim the next step). Unknown suffixes such as `plots3` are ignored. A published server does not read them. The haul still uses `os.time()` and the saved `lastSeenUnix`, never the client clock.

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
stylua --check src
lune run tests/run.luau
```

Lune runs the pure-logic tests (cash format, income, onboarding, schema, session lock, plot ring, assignment, migration, the Pale Pedlar, the playtest watchdog budget, the ledger against the in-memory DataStore, offline haul, the Nightly Offering, and the Offering Bowl). It does not need Studio. Studio steps are in [`docs/spec-01.md`](docs/spec-01.md), [`docs/spec-02.md`](docs/spec-02.md), and [`docs/spec-03.md`](docs/spec-03.md).

`selene.toml` sets `std = "roblox"`. `stylua.toml` is the formatter config.
