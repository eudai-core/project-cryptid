# Published test place checklist

The in-memory mock proves session-lock decisions, retries, migrations, and save refusals. It does not prove Roblox DataStores. Re-check every item below in the private test place before treating saves as done.

Place id: `80631305127330`. Studio API access is on for this universe only. The live game stays API-off. `default.project.json` keeps `servePlaceIds` null so a plain `rojo serve` cannot attach here.

## Connect

1. From the repo root, stamp the commit if this build will be identified in Studio, then serve the test project:

   ```bash
   ./scripts/stamp-build.sh
   rojo serve serve.test.project.json
   ```

   `serve.test.project.json` is `default.project.json` plus `"servePlaceIds": [80631305127330]`, including `Workspace.StreamingEnabled` and `Lighting.Technology`. The stamp script writes `BuildSha` into both project files. Put the working copy back to `dev` before committing.

2. In Studio, open place `80631305127330` (Creator Dashboard → the test universe → this place). Connect the Rojo plugin. Rojo accepts the connection only because the serve file lists this place id.

3. Press Play. The Output window must **not** contain:

   ```text
   [Cryptid:DataStore] Studio has no DataStore API access. Using an in-memory mock store. This session is not saved to a live DataStore.
   ```

   If that warning appears, API access is off or the place is not this universe. Stop. The mock is not this checklist. Any other `Ledger read failed` / `Ledger save failed` line is a bug unless a later retry succeeds.

4. Confirm `ReplicatedStorage.BuildSha` matches the commit you stamped.

## What to re-check

### Real lock contention across two servers

The mock can pretend another `JobId` holds the key. Only two real servers share a DataStore.

1. In Studio, Test → Start, 1 player, and leave that server running. In the server command bar, `print(game.JobId)` and note cash.
2. With the same Roblox account, join place `80631305127330` from the Roblox app. That cloud server has a different `JobId` than the Studio server. Studio test players and the website client are different processes.
3. While the Studio server still holds a fresh lease (90 seconds), the cloud join must kick with `The ledger is open elsewhere. Rejoin.` It must not start a new $25 profile.
4. Stop the Studio server so `BindToClose` releases the lock. Join from the app again. The kick is gone. Cash matches the Studio server's last save, including the starter on pad 1. There is no second starter.

If both sessions show the same `JobId`, they are one server and this check did not run.

### Throttling under real budgets

The mock can throw `429` and report a budget of 0. Studio's real budget is smaller than a live server and is the one that matters here.

1. During Play, in the server command bar:

   ```lua
   local DataStoreService = game:GetService("DataStoreService")
   print(DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync))
   ```

2. Join consumes one `UpdateAsync`. The printed budget drops by one, then a purchase or the 30 second autosave drops it again. It must stay at or above 0 and recover over the minute. The player is not kicked.
3. Do not write a loop that burns the whole budget. If a save does hit a throttle, Output shows `Ledger save failed` with a retryable code, a later attempt succeeds, and cash is unchanged by the failed attempt. A first `429` that kicks, or that writes a default profile, is a bug.

### BindToClose on a real shutdown

The mock runs the flush on a fake list of profiles. It does not run Studio's stop or a cloud server shutdown.

1. Test → Start, **2 players**. Wait until both have printed `PASS spawn`. Change both profiles (let income tick, or buy on each client).
2. Stop the test. Studio uses the short shutdown path: it must not sit for the full 20 second live budget, and it must still write. Output must not show the mock warning.
3. Start 2 players again. Each client keeps the cash and creatures from before the stop. Neither is kicked with the lock message.
4. Cloud check: join from the Roblox app, earn some cash, then shut that server down from the Creator Dashboard (or leave until the server empties). Rejoin. Cash matches the pre-shutdown value. A lock kick may appear only if the old server has not released yet. After the 90 second lease, or after the shutdown flush, the rejoin shows the saved cash, never a fresh $25 profile.

### Teleport / rejoin race

1. Play on the test place, note cash, leave, and rejoin immediately.
2. The new server must load the same profile. It must not grant a second starter, and it must not replace a developed lair with the default.
3. If the previous server is still inside `BindToClose`, the rejoin kicks with `The ledger is open elsewhere. Rejoin.` rather than opening a blank ledger. When that kick clears, the data from the first server is what loads.
4. There is no teleport button in this build. When one is added, teleport to this same place and apply the same two checks: no duplicate creatures, and no fresh profile while the origin server still owns the lock.

### OrderedDataStore leaderboards (later)

Not built. The mock has no ordered store. When a leaderboard spec lands, write one score on server A, read the ordered page on server B, and confirm the value survives a rejoin. A passing Lune test is not this check.

### AnalyticsService events (later)

Not built. Successful profile writes fire the server save hook (`SaveHooks`) so pad income can be batched on the 30 second autosave. When analytics lands, play for more than 30 seconds and confirm one batch per successful save in the Analytics dashboard. A clean autosave that skips the write must not emit a second batch. The mock cannot deliver `AnalyticsService` events.

## Studio QA hooks

These suffixes ride the existing `qa:<seconds>[:suffix]` playtest argument. They run only when `RunService:IsStudio()` is true. A live server ignores them. There is no remote.

Start from the edit session: `playtest op=play args=qa:120:loadfail` (or `foreignlock`, or `foreignlock:stale`). The watchdog still uses the seconds. Output should show the armed line with the full argument string.

- `loadfail` — the player is kicked with `The ledger would not open. Your progress is safe. Rejoin.` before `DataStoreGateway.load`. Read the key afterwards. Cash and the lock must be unchanged. There must be no new document if the key was empty.
- `foreignlock` — before load, the existing profile is wrapped in a fresh lock owned by `qa-foreign` (90 seconds). The join then retries and kicks with `The ledger is open elsewhere. Rejoin.` The stored cash stays the previous value. The lock job stays `qa-foreign` until that lease expires.
- `foreignlock:stale` — the planted lock is already past its lease. The join steals it, prints `PASS spawn`, and keeps the stored cash. The new lock job is this server's JobId, not `qa-foreign`.
- Confirm no QA cash grant fires in live servers. `qa:<seconds>:cash<N>` sets cash only when `RunService:IsStudio()` is true. A published server must not print `[Cryptid:QA] granted cash`.

## 2-player local pass

Use this as the smoke pass on every build of this place.

1. `rojo serve serve.test.project.json`, place `80631305127330`, Rojo connected, API access on.
2. Test → Start → 2 players. Server Output shows `PASS spawn` for each player and does not show the mock warning.
3. Let income tick on both. Stop. Start again. Both balances persist. Leave one client and rejoin that slot. The balance is still there, the lock releases, and the other player is untouched.
