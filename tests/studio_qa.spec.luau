--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local Check = require("./check")
local Save = require("../src/shared/Config/Save")
local Schema = require("../src/shared/Logic/Schema")
local StudioQa = require("../src/server/Dev/StudioQa")
local WatchdogBudget = require("../src/server/Dev/WatchdogBudget")
local Ledger = require("../src/server/Ledger")
local MockDataStore = require("../src/server/MockDataStore")

local function key(userId: number): string
	return Save.KEY_PREFIX .. tostring(userId)
end

local function open(store: any, jobId: string, now: () -> number): any
	return Ledger.open({
		getStore = function()
			return store
		end,
		createMock = function()
			error("this ledger was given its store and must not install another")
		end,
		allowMock = function()
			return false
		end,
		jobId = jobId,
		now = now,
		waitFor = function() end,
		warn = function() end,
	})
end

Check.test("studio save hooks are inert outside Studio", function()
	Check.eq(StudioQa.active(false, "qa:120:loadfail"), nil)
	Check.eq(StudioQa.active(false, "qa:120:foreignlock"), nil)
	Check.eq(StudioQa.active(false, "qa:120:foreignlock:stale"), nil)
	Check.eq(StudioQa.plan(false, "qa:120:loadfail"), "load")
	Check.eq(StudioQa.plan(false, "qa:90:foreignlock"), "load")
	Check.eq(StudioQa.plan(false, "qa:90:foreignlock:stale"), "load")
	Check.eq(StudioQa.plan(true, "qa:120:loadfail"), "kick")
	Check.eq(StudioQa.plan(true, "qa:90:foreignlock"), "seed-fresh")
	Check.eq(StudioQa.plan(true, "qa:90:foreignlock:stale"), "seed-stale")
	Check.eq(StudioQa.plan(true, "qa:420:plots3"), "load")
	Check.eq(StudioQa.plan(true, "play"), "load")
	Check.eq(StudioQa.plan(true, nil), "load")
	Check.eq(WatchdogBudget.secondsFor("qa:120:loadfail"), 120)
	Check.eq(WatchdogBudget.secondsFor("qa:90:foreignlock"), 90)
	Check.eq(WatchdogBudget.secondsFor("qa:90:foreignlock:stale"), 90)

	local hooks = fs.readFile("src/server/Dev/StudioQaHooks.luau")
	local guardAt = string.find(hooks, "if not RunService:IsStudio() then", 1, true)
	local argsAt = string.find(hooks, "GetTestArgs()", 1, true)
	Check.truthy(guardAt)
	Check.truthy(argsAt)
	Check.eq((guardAt :: number) < (argsAt :: number), true)
	Check.eq(string.find(hooks, "RemoteEvent", 1, true), nil)
	Check.eq(string.find(fs.readFile("src/server/Dev/StudioQa.luau"), "RemoteEvent", 1, true), nil)

	local session = fs.readFile("src/server/PlayerSession.luau")
	local planAt = string.find(session, "StudioQa.plan(RunService:IsStudio(), StudioQaHooks.args())", 1, true)
	local loadAt = string.find(session, "DataStoreGateway.load(player.UserId, created)", 1, true)
	Check.truthy(planAt)
	Check.truthy(loadAt)
	Check.eq((planAt :: number) < (loadAt :: number), true)

	local gateway = fs.readFile("src/server/DataStoreGateway.luau")
	local studioAt = string.find(gateway, "if not RunService:IsStudio() then", 1, true)
	local seedAt = string.find(gateway, "ledger.seedForeignLock", 1, true)
	Check.truthy(studioAt)
	Check.truthy(seedAt)
	Check.eq((studioAt :: number) < (seedAt :: number), true)
end)

Check.test("a fresh foreign lock kicks and a stale one is stolen without wiping cash", function()
	local store = MockDataStore.new()
	local now = 5000
	local previous = open(store, "previous", function()
		return now
	end)
	local loaded = previous.load(9, Schema.newProfile(now, "starter"))
	loaded.profile.cash = 3169
	Check.eq(previous.save(9, loaded.profile), true)
	Check.eq(previous.release(9, loaded.profile), true)

	local seeder = open(store, "studio-job", function()
		return now
	end)
	Check.eq(seeder.seedForeignLock(9, false), true)
	Check.eq(store:GetAsync(key(9)).lockJobId, Save.QA_FOREIGN_JOB_ID)
	Check.eq(store:GetAsync(key(9)).profile.cash, 3169)
	Check.eq(store:GetAsync(key(9)).lockExpiresAt > now, true)

	local joiner = open(store, "studio-next", function()
		return now
	end)
	local denied = joiner.load(9, Schema.newProfile(now, "decoy"))
	Check.eq(denied.ok, false)
	Check.eq(denied.message, Save.KICK_LOCKED)
	Check.eq(denied.profile, nil)
	Check.eq(store:GetAsync(key(9)).profile.cash, 3169)
	Check.eq(store:GetAsync(key(9)).lockJobId, Save.QA_FOREIGN_JOB_ID)

	Check.eq(seeder.seedForeignLock(9, true), true)
	Check.eq(store:GetAsync(key(9)).lockExpiresAt < now, true)
	local stolen = joiner.load(9, Schema.newProfile(now, "decoy"))
	Check.eq(stolen.ok, true)
	Check.eq(stolen.profile.cash, 3169)
	Check.eq(stolen.profile.pads["1"], "starter")
	Check.eq(store:GetAsync(key(9)).lockJobId, "studio-next")
	Check.eq(store:GetAsync(key(9)).profile.cash, 3169)

	local emptyStore = MockDataStore.new()
	local empty = open(emptyStore, "studio-job", function()
		return now
	end)
	Check.eq(empty.seedForeignLock(4, false), false)
	Check.eq(emptyStore:GetAsync(key(4)), nil)
end)
