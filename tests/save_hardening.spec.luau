--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local Check = require("./check")
local Economy = require("../src/shared/Config/Economy")
local Save = require("../src/shared/Config/Save")
local Schema = require("../src/shared/Logic/Schema")
local Autosave = require("../src/shared/Logic/Autosave")
local SessionClose = require("../src/shared/Logic/SessionClose")
local Retry = require("../src/shared/Logic/Retry")
local ShutdownFlush = require("../src/shared/Logic/ShutdownFlush")
local Ledger = require("../src/server/Ledger")
local MockDataStore = require("../src/server/MockDataStore")
local SaveHooks = require("../src/server/SaveHooks")

local function key(userId: number): string
	return Save.KEY_PREFIX .. tostring(userId)
end

local function open(store: any, jobId: string, now: () -> number, warnings: { string }?, extras: any?): any
	local options = extras or {}
	return Ledger.open({
		getStore = function()
			return store
		end,
		createMock = function()
			error("this ledger was given its store and must not install another")
		end,
		allowMock = function()
			return options.allowMock == true
		end,
		jobId = jobId,
		now = now,
		waitFor = options.waitFor or function() end,
		warn = function(message: string)
			if warnings ~= nil then
				table.insert(warnings, message)
			end
		end,
		budgetFor = options.budgetFor,
		random = options.random or function()
			return 0.5
		end,
		onSaved = options.onSaved,
		isHurry = options.isHurry,
		confirmLive = options.confirmLive,
	})
end

local function counting(inner: any): (any, { n: number })
	local calls = { n = 0 }
	local wrapped = {}
	function wrapped:UpdateAsync(updateKey: string, transform: (any) -> any): any
		calls.n += 1
		return inner:UpdateAsync(updateKey, transform)
	end
	function wrapped:GetAsync(readKey: string): any
		return inner:GetAsync(readKey)
	end
	return wrapped, calls
end

local function same(left: any, right: any): boolean
	if type(left) ~= type(right) then
		return false
	end
	if type(left) ~= "table" then
		return left == right
	end
	for name, value in left do
		if not same(value, right[name]) then
			return false
		end
	end
	for name, value in right do
		if not same(value, left[name]) then
			return false
		end
	end
	return true
end

local function legacy(version: number): any
	local profile = Schema.newProfile(20, "starter")
	profile.dataVersion = version
	profile.cash = 80
	profile.totalEarned = if version == 1 then 45 else 40
	if version < 4 then
		profile.shop = nil
		profile.settings = { reducedMotion = version == 3 }
	else
		profile.shop.lastRotationId = 9
		profile.settings.bindAtOnce = true
	end
	if version < 3 then
		profile.base = nil
	else
		profile.base = { defences = { ["2"] = "ward_candle" } }
	end
	return profile
end

Check.test("retry classifies fatal errors and jitters the backoff", function()
	Check.eq(Retry.classify("502 Internal"), "retryable")
	Check.eq(Retry.classify("Request was throttled (429)"), "retryable")
	Check.eq(Retry.classify("403 StudioAccessToApisNotAllowed"), "retryable")
	Check.eq(Retry.classify("DataStore value cannot be serialized"), "fatal")
	Check.eq(Retry.withJitter(Save.BACKOFF_BASE_SECONDS, 0.5), Save.BACKOFF_BASE_SECONDS)
	Check.near(
		Retry.withJitter(Save.BACKOFF_BASE_SECONDS, 0),
		Save.BACKOFF_BASE_SECONDS * (1 - Save.BACKOFF_JITTER_RATIO)
	)
	Check.near(
		Retry.withJitter(Save.BACKOFF_BASE_SECONDS, 1),
		Save.BACKOFF_BASE_SECONDS * (1 + Save.BACKOFF_JITTER_RATIO)
	)
end)

Check.test("lock acquire, renew, and release keep the owner and the lease", function()
	local store = MockDataStore.new()
	local now = 1000
	local hooks = {}
	local ledger = open(store, "job-a", function()
		return now
	end, {}, {
		onSaved = function(userId: number, profile: any, reason: string)
			table.insert(hooks, { userId = userId, cash = profile.cash, reason = reason })
		end,
	})
	local loaded = ledger.load(4, Schema.newProfile(20, "starter"))
	Check.eq(loaded.ok, true)
	local held = store:GetAsync(key(4))
	Check.eq(held.lockJobId, "job-a")
	Check.eq(held.lockTimestamp, 1000)
	Check.eq(held.lockLeaseSeconds, Save.LOCK_TTL_SECONDS)
	Check.eq(held.lockExpiresAt, 1000 + Save.LOCK_TTL_SECONDS)
	Check.eq(#hooks, 0)

	loaded.profile.cash = 55
	local saved, savedStatus = ledger.save(4, loaded.profile)
	Check.eq(saved, true)
	Check.eq(savedStatus, "saved")
	Check.eq(#hooks, 1)
	Check.eq(hooks[1].reason, "save")
	Check.eq(hooks[1].cash, 55)
	Check.eq(store:GetAsync(key(4)).profile.cash, 55)
	Check.eq(store:GetAsync(key(4)).lockExpiresAt, 1000 + Save.LOCK_TTL_SECONDS)

	now = 1030
	loaded.profile.cash = 999
	local renewed, renewStatus, expiresAt = ledger.renew(4)
	Check.eq(renewed, true)
	Check.eq(renewStatus, "renewed")
	Check.eq(expiresAt, 1030 + Save.LOCK_TTL_SECONDS)
	Check.eq(store:GetAsync(key(4)).profile.cash, 55)
	Check.eq(store:GetAsync(key(4)).lockTimestamp, 1030)
	Check.eq(#hooks, 1)

	local released, releaseStatus = ledger.release(4, store:GetAsync(key(4)).profile)
	Check.eq(released, true)
	Check.eq(releaseStatus, "released")
	Check.eq(store:GetAsync(key(4)).lockJobId, "")
	Check.eq(store:GetAsync(key(4)).lockExpiresAt, 0)
	Check.eq(store:GetAsync(key(4)).profile.cash, 55)
end)

Check.test("a lock held by another server is stolen only after the lease expires", function()
	local store = MockDataStore.new()
	local now = 5000
	local waits = {}
	local kept = Schema.newProfile(20, "kept")
	kept.cash = 80
	store:SeedLock(key(5), "other-server", now + Save.BACKOFF_BASE_SECONDS, kept)
	local ledger = open(store, "job-us", function()
		return now
	end, {}, {
		waitFor = function(seconds: number)
			table.insert(waits, seconds)
			now += seconds
		end,
	})
	local loaded = ledger.load(5, Schema.newProfile(20, "decoy"))
	Check.eq(loaded.ok, true)
	Check.eq(loaded.profile.cash, 80)
	Check.eq(loaded.profile.pads["1"], "kept")
	Check.eq(store:GetAsync(key(5)).lockJobId, "job-us")
	Check.eq(#waits >= 1, true)

	local blocked = MockDataStore.new()
	local blockedNow = 8000
	local blockedWaits = {}
	local rich = Schema.newProfile(20, "rich")
	rich.cash = 80
	blocked:SeedLock(key(6), "other-server", blockedNow + 10000, rich)
	local deniedLedger = open(blocked, "job-us", function()
		return blockedNow
	end, {}, {
		waitFor = function(seconds: number)
			table.insert(blockedWaits, seconds)
			blockedNow += seconds
		end,
	})
	local denied = deniedLedger.load(6, Schema.newProfile(20, "decoy"))
	Check.eq(denied.ok, false)
	Check.eq(denied.message, Save.KICK_LOCKED)
	Check.eq(#blockedWaits, Save.MAX_ATTEMPTS - 1)
	Check.eq(blocked:GetAsync(key(6)).lockJobId, "other-server")
	Check.eq(blocked:GetAsync(key(6)).profile.cash, 80)

	local expired = MockDataStore.new()
	local stale = Schema.newProfile(20, "stale")
	stale.cash = 44
	expired:SeedLock(key(7), "other-server", 10, stale)
	local immediate = open(expired, "job-us", function()
		return 11
	end)
	local stolen = immediate.load(7, Schema.newProfile(20, "decoy"))
	Check.eq(stolen.ok, true)
	Check.eq(stolen.profile.cash, 44)
	Check.eq(expired:GetAsync(key(7)).lockJobId, "job-us")
end)

Check.test("a lost lock is not written or released", function()
	local store = MockDataStore.new()
	local now = 1000
	local jobA = open(store, "job-a", function()
		return now
	end)
	local loaded = jobA.load(8, Schema.newProfile(3, "starter-a"))
	Check.eq(loaded.ok, true)
	loaded.profile.cash = 70
	now = 1000 + Save.LOCK_TTL_SECONDS
	local jobB = open(store, "job-b", function()
		return now
	end)
	local stolen = jobB.load(8, Schema.newProfile(3, "decoy"))
	Check.eq(stolen.ok, true)
	Check.eq(stolen.profile.cash, Economy.STARTING_CASH)
	local lostSave, lostStatus = jobA.save(8, loaded.profile)
	Check.eq(lostSave, false)
	Check.eq(lostStatus, "lost")
	Check.eq(store:GetAsync(key(8)).profile.cash, Economy.STARTING_CASH)
	Check.eq(store:GetAsync(key(8)).lockJobId, "job-b")
	local lostRelease, releaseStatus = jobA.release(8, loaded.profile)
	Check.eq(lostRelease, false)
	Check.eq(releaseStatus, "lost")
	Check.eq(store:GetAsync(key(8)).lockJobId, "job-b")
end)

Check.test("transient DataStore errors retry and a fatal error kicks", function()
	local transient = MockDataStore.new()
	local wrapped, calls = counting(transient)
	transient:FailNext("UpdateAsync", 2, "502 Internal")
	local waits = {}
	local warnings = {}
	local ledger = open(
		wrapped,
		"job-a",
		function()
			return 10
		end,
		warnings,
		{
			waitFor = function(seconds: number)
				table.insert(waits, seconds)
			end,
		}
	)
	local loaded = ledger.load(11, Schema.newProfile(10, "starter"))
	Check.eq(loaded.ok, true)
	Check.eq(loaded.profile.cash, Economy.STARTING_CASH)
	Check.eq(calls.n, Save.MAX_ATTEMPTS)
	Check.eq(#waits, 2)
	Check.eq(waits[1], Save.BACKOFF_BASE_SECONDS)
	Check.eq(waits[2], Save.BACKOFF_BASE_SECONDS * 2)
	Check.eq(#warnings, 2)

	local fatalStore = MockDataStore.new()
	local fatalWrapped, fatalCalls = counting(fatalStore)
	fatalStore:FailNext("UpdateAsync", 5, "DataStore value cannot be serialized")
	local fatalWaits = {}
	local fatalWarnings = {}
	local fatalLedger = open(
		fatalWrapped,
		"job-a",
		function()
			return 10
		end,
		fatalWarnings,
		{
			waitFor = function(seconds: number)
				table.insert(fatalWaits, seconds)
			end,
		}
	)
	local failed = fatalLedger.load(12, Schema.newProfile(10, "starter"))
	Check.eq(failed.ok, false)
	Check.eq(failed.message, Save.KICK_LOAD_FAILED)
	Check.eq(failed.profile, nil)
	Check.eq(fatalCalls.n, 1)
	Check.eq(#fatalWaits, 0)
	Check.eq(#fatalWarnings, 1)
	Check.eq(fatalStore:GetAsync(key(12)), nil)
end)

Check.test("a low request budget waits and a throttle is retried", function()
	local store = MockDataStore.new()
	store:SetBudget(0)
	local waits = {}
	local ledger = open(store, "job-a", function()
		return 10
	end, {}, {
		budgetFor = function()
			return store:GetRequestBudget()
		end,
		waitFor = function(seconds: number)
			table.insert(waits, seconds)
			store:SetBudget(Save.BUDGET_MIN_REMAINING + 10)
		end,
	})
	local loaded = ledger.load(13, Schema.newProfile(10, "starter"))
	Check.eq(loaded.ok, true)
	Check.eq(#waits, 1)
	Check.eq(waits[1], Save.BUDGET_WAIT_SECONDS)

	local hurried = MockDataStore.new()
	hurried:SetBudget(0)
	local hurriedWaits = {}
	local fast = open(hurried, "job-a", function()
		return 10
	end, {}, {
		budgetFor = function()
			return hurried:GetRequestBudget()
		end,
		isHurry = function()
			return true
		end,
		waitFor = function(seconds: number)
			table.insert(hurriedWaits, seconds)
		end,
	})
	local skipped = fast.load(14, Schema.newProfile(10, "starter"))
	Check.eq(skipped.ok, true)
	Check.eq(#hurriedWaits, 0)

	local throttled = MockDataStore.new()
	throttled:ThrottleNext("UpdateAsync", 1)
	local throttleWaits = {}
	local throttleWarnings = {}
	local throttledLedger = open(
		throttled,
		"job-a",
		function()
			return 10
		end,
		throttleWarnings,
		{
			budgetFor = function()
				return throttled:GetRequestBudget()
			end,
			waitFor = function(seconds: number)
				table.insert(throttleWaits, seconds)
				throttled:SetBudget(Save.BUDGET_MIN_REMAINING + 10)
			end,
		}
	)
	local recovered = throttledLedger.load(15, Schema.newProfile(10, "starter"))
	Check.eq(recovered.ok, true)
	Check.eq(throttleWaits[1], Save.BUDGET_WAIT_SECONDS)
	Check.eq(#throttleWaits, 2)
	Check.eq(#throttleWarnings, 1)
	Check.contains(throttleWarnings[1], "Ledger read failed")
	Check.eq(string.find(throttleWarnings[1], "in-memory mock", 1, true), nil)
end)

Check.test("an unloaded or default profile is never saved", function()
	local store = MockDataStore.new()
	local warnings = {}
	local ledger = open(store, "job-a", function()
		return 10
	end, warnings)
	local profile = Schema.newProfile(10, "starter")
	local saved, status = ledger.save(21, profile)
	Check.eq(saved, false)
	Check.eq(status, "unloaded")
	Check.eq(store:GetAsync(key(21)), nil)
	Check.eq(#warnings, 1)
	Check.contains(warnings[1], "unloaded")
	local released, releaseStatus = ledger.release(21, profile)
	Check.eq(released, false)
	Check.eq(releaseStatus, "unloaded")
	Check.eq(store:GetAsync(key(21)), nil)
end)

Check.test("a dataVersion downgrade is refused even with the rebirth flag", function()
	local store = MockDataStore.new()
	local warnings = {}
	local ledger = open(store, "job-a", function()
		return 40
	end, warnings)
	local loaded = ledger.load(22, Schema.newProfile(40, "starter"))
	Check.eq(loaded.ok, true)
	loaded.profile.cash = 90
	Check.eq(ledger.save(22, loaded.profile), true)
	loaded.profile.dataVersion = Save.DATA_VERSION - 1
	local saved, status = ledger.save(22, loaded.profile)
	Check.eq(saved, false)
	Check.eq(status, "downgrade")
	Check.eq(store:GetAsync(key(22)).profile.dataVersion, Save.DATA_VERSION)
	Check.eq(store:GetAsync(key(22)).profile.cash, 90)
	local reborn, rebornStatus = ledger.save(22, loaded.profile, true)
	Check.eq(reborn, false)
	Check.eq(rebornStatus, "downgrade")
	Check.eq(store:GetAsync(key(22)).profile.dataVersion, Save.DATA_VERSION)
	local sawDowngrade = false
	for _, message in warnings do
		if string.find(message, "downgrade", 1, true) ~= nil then
			sawDowngrade = true
		end
	end
	Check.eq(sawDowngrade, true)
end)

Check.test("the wipe guard refuses a collapsed lair unless rebirth is set", function()
	local store = MockDataStore.new()
	local warnings = {}
	local ledger = open(store, "job-a", function()
		return 40
	end, warnings)
	local loaded = ledger.load(23, Schema.newProfile(40, "starter"))
	loaded.profile.cash = 200
	loaded.profile.padsUnlocked = 4
	Check.eq(ledger.save(23, loaded.profile), true)

	local spent = Schema.deepCopy(loaded.profile)
	spent.cash = 0
	local spentOk, spentStatus = ledger.save(23, spent)
	Check.eq(spentOk, true)
	Check.eq(spentStatus, "saved")
	Check.eq(store:GetAsync(key(23)).profile.cash, 0)
	Check.eq(store:GetAsync(key(23)).profile.padsUnlocked, 4)

	loaded.profile.cash = 200
	Check.eq(ledger.save(23, loaded.profile), true)
	local wiped = Schema.deepCopy(loaded.profile)
	wiped.cash = 0
	wiped.padsUnlocked = 0
	local refused, reason = ledger.save(23, wiped)
	Check.eq(refused, false)
	Check.eq(reason, "wipe")
	Check.eq(store:GetAsync(key(23)).profile.cash, 200)
	Check.eq(store:GetAsync(key(23)).profile.padsUnlocked, 4)
	local released, releaseStatus = ledger.release(23, wiped)
	Check.eq(released, false)
	Check.eq(releaseStatus, "wipe")
	Check.eq(store:GetAsync(key(23)).lockJobId, "job-a")
	Check.eq(store:GetAsync(key(23)).profile.cash, 200)

	local emptied = Schema.deepCopy(loaded.profile)
	emptied.cryptids = {}
	local emptyOk, emptyStatus = ledger.save(23, emptied)
	Check.eq(emptyOk, false)
	Check.eq(emptyStatus, "wipe")

	local allowed, allowedStatus = ledger.save(23, wiped, true)
	Check.eq(allowed, true)
	Check.eq(allowedStatus, "saved")
	Check.eq(store:GetAsync(key(23)).profile.padsUnlocked, 0)
	Check.eq(store:GetAsync(key(23)).profile.cash, 0)
	local sawWipe = false
	for _, message in warnings do
		if string.find(message, "wipe", 1, true) ~= nil then
			sawWipe = true
		end
	end
	Check.eq(sawWipe, true)
end)

Check.test("BindToClose flushes every loaded profile and Studio waits within the close limit", function()
	local store = MockDataStore.new()
	local now = 100
	local ledger = open(store, "job-a", function()
		return now
	end)
	local first = ledger.load(31, Schema.newProfile(now, "starter-a"))
	local second = ledger.load(32, Schema.newProfile(now, "starter-b"))
	first.profile.cash = 70
	second.profile.cash = 90
	local third = Schema.newProfile(now, "starter-c")
	local savedIds = {}
	local result = ShutdownFlush.run({
		{ loaded = true, dirty = true, userId = 31, profile = first.profile },
		{ loaded = true, dirty = true, userId = 32, profile = second.profile },
		{ loaded = false, dirty = true, userId = 33, profile = third },
	}, {
		save = function(entry)
			if entry.userId == 33 then
				error("unloaded profile was saved")
			end
			table.insert(savedIds, entry.userId)
			return ledger.save(entry.userId, entry.profile)
		end,
		release = function(entry)
			if entry.userId == 33 then
				error("unloaded profile was released")
			end
			return ledger.release(entry.userId, entry.profile)
		end,
		spawn = function(body)
			body()
		end,
		waitFor = function()
			error("studio flush waited")
		end,
		now = function()
			return 0
		end,
		budgetSeconds = ShutdownFlush.budget(true),
	})
	Check.eq(ShutdownFlush.budget(true), Save.STUDIO_SHUTDOWN_TIMEOUT_SECONDS)
	Check.eq(ShutdownFlush.budget(false), Save.SHUTDOWN_TIMEOUT_SECONDS)
	Check.eq(Save.STUDIO_SHUTDOWN_TIMEOUT_SECONDS > 0, true)
	Check.eq(Save.STUDIO_SHUTDOWN_TIMEOUT_SECONDS <= Save.BIND_TO_CLOSE_LIMIT_SECONDS, true)
	Check.eq(Save.SHUTDOWN_TIMEOUT_SECONDS <= Save.BIND_TO_CLOSE_LIMIT_SECONDS, true)
	Check.eq(result.pending, 0)
	Check.eq(result.saved, 2)
	Check.eq(result.released, 2)
	Check.eq(#savedIds, 2)
	Check.eq(store:GetAsync(key(31)).profile.cash, 70)
	Check.eq(store:GetAsync(key(31)).lockJobId, "")
	Check.eq(store:GetAsync(key(32)).profile.cash, 90)
	Check.eq(store:GetAsync(key(32)).lockJobId, "")
	Check.eq(store:GetAsync(key(33)), nil)

	local queued = {}
	local studioClock = 0
	local studioWaits = 0
	local deferred = ShutdownFlush.run({
		{ loaded = true, dirty = true },
		{ loaded = true, dirty = false },
	}, {
		save = function()
			return true
		end,
		release = function()
			return true
		end,
		spawn = function(body)
			table.insert(queued, body)
		end,
		waitFor = function(seconds: number)
			studioWaits += 1
			studioClock += seconds
		end,
		now = function()
			return studioClock
		end,
		budgetSeconds = ShutdownFlush.budget(true),
	})
	Check.eq(#queued, 2)
	Check.eq(studioWaits > 0, true)
	Check.eq(deferred.pending, 2)
	Check.eq(deferred.saved, 0)
	Check.near(studioClock, Save.STUDIO_SHUTDOWN_TIMEOUT_SECONDS, Save.SHUTDOWN_POLL_SECONDS)

	local liveClock = 0
	local liveWaits = 0
	local live = ShutdownFlush.run({
		{ loaded = true, dirty = true },
	}, {
		save = function()
			return true
		end,
		release = function()
			return true
		end,
		spawn = function() end,
		waitFor = function(seconds: number)
			liveWaits += 1
			liveClock += seconds
		end,
		now = function()
			return liveClock
		end,
		budgetSeconds = ShutdownFlush.budget(false),
	})
	Check.eq(live.pending, 1)
	Check.eq(liveWaits > 0, true)
	Check.near(liveClock, Save.SHUTDOWN_TIMEOUT_SECONDS, Save.SHUTDOWN_POLL_SECONDS)
end)

Check.test("the dirty flag skips writes and a save fires the hook", function()
	local now = 2000
	local store = MockDataStore.new()
	local wrapped, calls = counting(store)
	local hooks = 0
	local ledger = open(wrapped, "job-a", function()
		return now
	end, {}, {
		onSaved = function(_userId: number, profile: any, reason: string)
			hooks += 1
			Check.eq(profile.cash, 55)
			Check.eq(reason, "save")
		end,
	})
	local loaded = ledger.load(41, Schema.newProfile(now, "starter"))
	local afterLoad = calls.n
	local saves = 0
	local renews = 0
	local applied = 0
	local skipped = Autosave.apply(false, loaded.lockExpiresAt, now, {
		save = function()
			saves += 1
			return ledger.save(41, loaded.profile)
		end,
		renew = function()
			renews += 1
			return ledger.renew(41)
		end,
		onSaved = function()
			applied += 1
		end,
	})
	Check.eq(skipped, "skipped")
	Check.eq(saves, 0)
	Check.eq(renews, 0)
	Check.eq(applied, 0)
	Check.eq(calls.n, afterLoad)
	Check.eq(hooks, 0)
	Check.eq(Autosave.plan(false, now + Save.LOCK_TTL_SECONDS, now), "skip")
	Check.eq(Autosave.plan(false, now + Save.LOCK_REFRESH_SECONDS, now), "renew")

	loaded.profile.cash = 55
	local written = Autosave.apply(true, loaded.lockExpiresAt, now, {
		save = function()
			saves += 1
			return ledger.save(41, loaded.profile)
		end,
		renew = function()
			renews += 1
			return ledger.renew(41)
		end,
		onSaved = function()
			applied += 1
		end,
	})
	Check.eq(written, "saved")
	Check.eq(saves, 1)
	Check.eq(renews, 0)
	Check.eq(applied, 1)
	Check.eq(hooks, 1)
	Check.eq(calls.n, afterLoad + 1)
	Check.eq(store:GetAsync(key(41)).profile.cash, 55)

	local disconnect = SaveHooks.connect(function(userId: number, profile: any, reason: string)
		Check.eq(userId, 3)
		Check.eq(profile.cash, 8)
		Check.eq(reason, "save")
		hooks += 1
	end)
	SaveHooks.fire(3, { cash = 8 }, "save")
	disconnect()
	SaveHooks.fire(3, { cash = 8 }, "save")
	Check.eq(hooks, 2)
end)

Check.test("migrations run in order from every older dataVersion and are idempotent", function()
	local targets = Schema.migrationTargets()
	Check.eq(#targets, 4)
	Check.eq(targets[1], 2)
	Check.eq(targets[2], 3)
	Check.eq(targets[3], 4)
	Check.eq(targets[4], 5)
	Check.eq(targets[1] < targets[2], true)
	Check.eq(targets[2] < targets[3], true)
	Check.eq(targets[3] < targets[4], true)

	local fromV1 = legacy(1)
	local once = Schema.migrate(fromV1)
	Check.eq(fromV1.dataVersion, 1)
	Check.eq(fromV1.totalEarned, 45)
	Check.eq(once.dataVersion, Save.DATA_VERSION)
	Check.eq(once.totalEarned, 20)
	Check.eq(once.cash, 80)
	Check.eq(next(once.base.defences), nil)
	Check.eq(once.shop.lastRotationId, 0)
	Check.eq(once.settings.bindAtOnce, false)
	Check.eq(#once.skills, 0)
	Check.eq(same(once, Schema.migrate(once)), true)

	local fromV2 = Schema.migrate(legacy(2))
	Check.eq(fromV2.dataVersion, Save.DATA_VERSION)
	Check.eq(fromV2.totalEarned, 40)
	Check.eq(next(fromV2.base.defences), nil)
	Check.eq(fromV2.shop.lastRotationId, 0)
	Check.eq(same(fromV2, Schema.migrate(fromV2)), true)

	local fromV3 = Schema.migrate(legacy(3))
	Check.eq(fromV3.dataVersion, Save.DATA_VERSION)
	Check.eq(fromV3.totalEarned, 40)
	Check.eq(fromV3.settings.reducedMotion, true)
	Check.eq(fromV3.settings.bindAtOnce, false)
	Check.eq(fromV3.base.defences[2], "ward_candle")
	Check.eq(fromV3.shop.lastRotationId, 0)
	Check.eq(same(fromV3, Schema.migrate(fromV3)), true)

	local bareV4 = legacy(4)
	bareV4.skills = nil
	local fromV4 = Schema.migrate(bareV4)
	Check.eq(fromV4.dataVersion, Save.DATA_VERSION)
	Check.eq(fromV4.totalEarned, 40)
	Check.eq(fromV4.shop.lastRotationId, 9)
	Check.eq(fromV4.settings.bindAtOnce, true)
	Check.eq(fromV4.base.defences[2], "ward_candle")
	Check.eq(#fromV4.skills, 0)
	Check.eq(same(fromV4, Schema.migrate(fromV4)), true)

	local current = Schema.newProfile(20, "starter")
	current.skills = { "h1" }
	local fromV5 = Schema.migrate(current)
	Check.eq(fromV5.dataVersion, Save.DATA_VERSION)
	Check.eq(fromV5.skills[1], "h1")
	Check.eq(same(fromV5, Schema.migrate(fromV5)), true)

	local future = Schema.newProfile(20, "starter")
	future.dataVersion = Save.DATA_VERSION + 1
	Check.eq(Schema.migrate(future), nil)
end)

Check.test("the test place project matches default.project.json plus the place id", function()
	local function treeOf(source: string): string
		local at = string.find(source, '"tree"', 1, true)
		Check.truthy(at)
		return string.sub(source, at :: number)
	end
	local mainProject = fs.readFile("default.project.json")
	local testProject = fs.readFile("serve.test.project.json")
	Check.eq(treeOf(mainProject), treeOf(testProject))
	Check.contains(mainProject, '"servePlaceIds": null')
	Check.contains(mainProject, '"StreamingEnabled": false')
	Check.contains(mainProject, '"Technology": "ShadowMap"')
	Check.eq(string.find(mainProject, "80631305127330", 1, true), nil)
	Check.contains(testProject, '"servePlaceIds": [80631305127330]')
	Check.contains(testProject, '"StreamingEnabled": false')
	Check.contains(testProject, '"Technology": "ShadowMap"')
	Check.contains(fs.readFile("scripts/stamp-build.sh"), "serve.test.project.json")
	Check.contains(fs.readFile("scripts/stamp-build.ps1"), "serve.test.project.json")
	local session = fs.readFile("src/server/PlayerSession.luau")
	Check.contains(session, "Autosave.apply")
	Check.contains(session, "SessionClose.shutdown")
	Check.contains(session, "DataStoreGateway.setHurry")
	local respawnAt = string.find(session, "player.RespawnLocation = fallback", 1, true)
	local loadAt = string.find(session, "DataStoreGateway.load(player.UserId, created)", 1, true)
	Check.truthy(respawnAt)
	Check.truthy(loadAt)
	Check.eq((respawnAt :: number) < (loadAt :: number), true)
	Check.contains(fs.readFile("src/server/Main.server.luau"), "game:BindToClose(PlayerSession.shutdown)")
	local gateway = fs.readFile("src/server/DataStoreGateway.luau")
	Check.contains(gateway, "GetRequestBudgetForRequestType")
	Check.contains(gateway, "SaveHooks.fire")
	Check.contains(fs.readFile("src/server/PlayerSession.luau"), "[Cryptid:DataStore] shutdown flush saved=")
	Check.contains(fs.readFile("src/server/PlayerSession.luau"), "released=")
	Check.contains(fs.readFile("src/server/PlayerSession.luau"), "pending=")
	Check.contains(fs.readFile("src/server/PlayerSession.luau"), "elapsed=")
end)

Check.test("detach during shutdown saves the latest cash and releases the lock", function()
	local store = MockDataStore.new()
	local now = 1000
	local ledger = open(store, "job-a", function()
		return now
	end)
	local loaded = ledger.load(77, Schema.newProfile(now, "starter"))
	loaded.profile.cash = 3169
	Check.eq(ledger.save(77, loaded.profile), true)
	loaded.profile.cash = 3195

	local active = {}
	local detaching = {}
	local session = {
		loaded = true,
		dirty = true,
		ephemeral = false,
		alive = true,
		leaving = false,
		saveBusy = false,
		profile = loaded.profile,
	}
	active[77] = session
	local role = SessionClose.begin(active, detaching, 77)
	Check.eq(role, "owner")
	Check.eq(active[77], nil)
	local again = SessionClose.begin(active, detaching, 77)
	Check.eq(again, "pending")

	local writes = 0
	local clock = 0
	local ownerDone = false
	local tally = { saved = 0, released = 0 }
	local outcome = SessionClose.shutdown(active, detaching, {
		budgetSeconds = Save.STUDIO_SHUTDOWN_TIMEOUT_SECONDS,
		now = function()
			return clock
		end,
		waitFor = function(seconds: number)
			clock += seconds
			if ownerDone then
				return
			end
			ownerDone = true
			local saved, released, state = SessionClose.persist(session, {
				now = function()
					return clock
				end,
				budgetSeconds = Save.STUDIO_SHUTDOWN_TIMEOUT_SECONDS,
				waitFor = function() end,
				save = function(current)
					writes += 1
					return ledger.save(77, current.profile)
				end,
				release = function(current)
					writes += 1
					return ledger.release(77, current.profile)
				end,
			})
			Check.eq(state, "closed")
			SessionClose.note(tally, saved, released)
			SessionClose.finish(detaching, 77)
		end,
		spawn = function()
			error("shutdown started a second close")
		end,
		persist = function()
			error("shutdown started a second write")
		end,
	})
	Check.eq(ownerDone, true)
	Check.eq(writes, 2)
	Check.eq(tally.saved, 1)
	Check.eq(tally.released, 1)
	Check.eq(outcome.pending, 0)
	Check.eq(clock > 0, true)
	Check.eq(clock <= Save.STUDIO_SHUTDOWN_TIMEOUT_SECONDS, true)
	Check.eq(store:GetAsync(key(77)).profile.cash, 3195)
	Check.eq(store:GetAsync(key(77)).lockJobId, "")
end)

Check.test("a final save waits out the in-flight autosave and writes once", function()
	local store = MockDataStore.new()
	local now = 1000
	local ledger = open(store, "job-a", function()
		return now
	end)
	local loaded = ledger.load(78, Schema.newProfile(now, "starter"))
	loaded.profile.cash = 3169
	Check.eq(ledger.save(78, loaded.profile), true)
	loaded.profile.cash = 3195
	local session = {
		loaded = true,
		dirty = true,
		ephemeral = false,
		saveBusy = true,
		profile = loaded.profile,
	}
	local calls = 0
	local clock = 0
	local saved, released, state = SessionClose.persist(session, {
		now = function()
			return clock
		end,
		budgetSeconds = Save.STUDIO_SHUTDOWN_TIMEOUT_SECONDS,
		waitFor = function(seconds: number)
			clock += seconds
			session.saveBusy = false
		end,
		save = function(current)
			calls += 1
			Check.eq(current.saveBusy, true)
			Check.eq(current.profile.cash, 3195)
			return ledger.save(78, current.profile)
		end,
		release = function(current)
			calls += 1
			return ledger.release(78, current.profile)
		end,
	})
	Check.eq(state, "closed")
	Check.eq(saved, true)
	Check.eq(released, true)
	Check.eq(calls, 2)
	Check.eq(store:GetAsync(key(78)).profile.cash, 3195)
	Check.eq(store:GetAsync(key(78)).lockJobId, "")
	Check.eq(session.saveBusy, false)

	session.saveBusy = true
	local blocked = 0
	local busySaved, busyReleased, busyState = SessionClose.persist(session, {
		now = function()
			return 0
		end,
		budgetSeconds = 0,
		waitFor = function()
			error("a busy profile must not wait when the budget is already spent")
		end,
		save = function()
			blocked += 1
			return true
		end,
		release = function()
			blocked += 1
			return true
		end,
	})
	Check.eq(busyState, "busy")
	Check.eq(busySaved, false)
	Check.eq(busyReleased, false)
	Check.eq(blocked, 0)
	Check.eq(session.saveBusy, true)
	Check.eq(store:GetAsync(key(78)).profile.cash, 3195)
end)
