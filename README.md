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

## Live sync

```bash
rojo serve
```

In Studio, connect with the Rojo plugin.

`servePlaceIds` in `default.project.json` is `null` on purpose. The place id is not known yet, so this is a TODO. When the experience exists, set `servePlaceIds` to an array of place ids, for example `[123456789]`, so Rojo refuses to live-sync this project into a different place. JSON has no comments, which is why the reminder lives here instead of in the project file.

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

Lune runs the pure-logic tests (cash format, income, onboarding, schema, session lock, plot ring, assignment, migration, and the Pale Pedlar). It does not need Studio. Studio steps are in [`docs/spec-01.md`](docs/spec-01.md), [`docs/spec-02.md`](docs/spec-02.md), and [`docs/spec-03.md`](docs/spec-03.md).

`selene.toml` sets `std = "roblox"`. `stylua.toml` is the formatter config.
