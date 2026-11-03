# Project Cryptid

Project Cryptid is a Roblox cryptid-collecting tycoon with a dark occult horror theme. Players find cryptids and build a tycoon around what they uncover.

This repository is a [Rojo](https://rojo.space/) project: Luau source on disk builds into a place file you can open in Roblox Studio. The scripts in this scaffold are placeholders so the project builds. Gameplay lands in later changes.

## Prerequisites

- [Rojo](https://rojo.space/docs/v7/getting-started/installation/) 7
- Roblox Studio
- The Rojo Studio plugin, for live sync

Rojo, Selene, and StyLua are pinned in [`rokit.toml`](rokit.toml). [Rokit](https://github.com/rojo-rbx/rokit) installs that pin file:

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
| `src/server/Main.server.luau` | `Script` |
| `src/client/Main.client.luau` | `LocalScript` |
| `src/shared/GameInfo.luau` | `ModuleScript` |

## Lint and format

```bash
selene src
stylua --check src
```

`selene.toml` sets `std = "roblox"`. `stylua.toml` is the formatter config.
