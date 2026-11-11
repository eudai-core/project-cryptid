--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local Check = require("./check")
local Save = require("../src/shared/Config/Save")
local Schema = require("../src/shared/Logic/Schema")
local QaArgs = require("../src/shared/Logic/QaArgs")
local QaFresh = require("../src/shared/Logic/QaFresh")
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

Check.test("tree and motion hooks are inert outside Studio", function()
	Check.eq(QaArgs.openTree(false, "qa:120:opentree"), false)
	Check.eq(QaArgs.openTree(false, "qa:120:offline:7200:opentree"), false)
	Check.eq(QaArgs.reducedMotion(false, "qa:120:reducedmotion:on"), nil)
	Check.eq(QaArgs.reducedMotion(false, "qa:120:reducedmotion:off"), nil)
	Check.eq(QaArgs.openTree(true, "qa:120:opentree"), true)
	Check.eq(QaArgs.openTree(true, "qa:300:offline:7200:opentree"), true)
	Check.eq(QaArgs.openTree(true, "qa:120:plots3"), false)
	Check.eq(QaArgs.reducedMotion(true, "qa:120:reducedmotion:on"), true)
	Check.eq(QaArgs.reducedMotion(true, "qa:120:reducedmotion:off"), false)
	Check.eq(QaArgs.reducedMotion(true, "qa:120:opentree"), nil)
	Check.eq(QaArgs.parse("qa:300:utcjump:20:reducedmotion:on").utcJumpSeconds, 20)
	Check.eq(QaArgs.parse("qa:300:utcjump:20:reducedmotion:on").reducedMotion, "on")
	local session = fs.readFile("src/server/PlayerSession.luau")
	Check.eq(string.find(session, "sessionReducedMotion", 1, true) ~= nil, true)
	Check.eq(string.find(session, "profile.settings.reducedMotion = motionOverride", 1, true), nil)
	local client = fs.readFile("src/client/Main.client.luau")
	Check.eq(string.find(client, "RunService:IsStudio()", 1, true) ~= nil, true)
	Check.eq(string.find(client, "QaArgs.openTree", 1, true) ~= nil, true)
	Check.eq(string.find(client, "skill.open()", 1, true) ~= nil, true)
end)

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

Check.test("qa fresh loads a different key at the opening rite and is a no-op outside Studio", function()
	Check.eq(QaArgs.parse("qa:600:fresh").fresh, true)
	Check.eq(QaArgs.parse("qa:600:offline:7200:fresh").offlineSeconds, 7200)
	Check.eq(QaArgs.wantsFresh(false, "qa:600:fresh"), false)
	Check.eq(QaArgs.wantsFresh(true, "qa:600:fresh"), true)
	Check.eq(QaArgs.wantsFresh(true, "qa:600"), false)
	Check.eq(WatchdogBudget.secondsFor("qa:600:fresh"), 600)
	Check.eq(StudioQa.plan(true, "qa:600:fresh"), "load")

	local userId = 9
	local real = QaFresh.realKey(userId)
	local guid = "aaaabbbb-cccc-4ddd-8eee-ffff00001111"
	Check.eq(QaFresh.sessionKey(userId, false, "qa:600:fresh", "job-a", 10), real)
	Check.eq(QaFresh.sessionKey(userId, true, "qa:600", "job-a", 10), real)
	Check.eq(QaFresh.sessionKey(userId, true, "play", "job-a", 10), real)
	local freshKey = QaFresh.sessionKey(userId, true, "qa:600:fresh", guid, 50)
	Check.eq(freshKey, real .. "_qf_aaaabbbbcccc")
	Check.eq(freshKey ~= real, true)
	Check.eq(QaFresh.sessionKey(userId, true, "qa:600:fresh", "", 50), real .. "_qf_000000000000")

	local store = MockDataStore.new()
	local kept = Schema.newProfile(1, "starter")
	kept.onboarding.step = 8
	kept.onboarding.playSeconds = 200
	kept.cash = 9999
	store:SetAsync(real, {
		lockJobId = "",
		lockTimestamp = 0,
		lockLeaseSeconds = 0,
		lockExpiresAt = 0,
		profile = kept,
	})

	local ledger = Ledger.open({
		getStore = function()
			return store
		end,
		createMock = function()
			error("this ledger was given its store and must not install another")
		end,
		allowMock = function()
			return false
		end,
		jobId = "studio-job",
		now = function()
			return 50
		end,
		waitFor = function() end,
		warn = function() end,
		profileKey = function(id: number)
			return QaFresh.sessionKey(id, true, "qa:600:fresh", guid, 50)
		end,
	})
	local blank = Schema.newProfile(50, "starter")
	local opened = ledger.load(userId, blank)
	Check.eq(opened.ok, true)
	Check.eq(opened.profile.onboarding.playSeconds, 0)
	Check.eq(opened.profile.onboarding.step, blank.onboarding.step)
	Check.eq(opened.profile.cash, blank.cash)
	Check.eq(opened.profile.onboarding.step < 8, true)
	Check.eq(store:GetAsync(real).profile.cash, 9999)
	Check.eq(store:GetAsync(real).profile.onboarding.step, 8)
	Check.eq(store:GetAsync(real).lockJobId, "")
	Check.eq(store:GetAsync(freshKey).lockJobId, "studio-job")
	Check.eq(store:GetAsync(freshKey).profile.onboarding.playSeconds, 0)
	Check.eq(store:GetAsync(freshKey).profile.onboarding.step, blank.onboarding.step)

	opened.profile.cash = 1
	Check.eq(ledger.save(userId, opened.profile), true)
	Check.eq(store:GetAsync(real).profile.cash, 9999)
	Check.eq(store:GetAsync(real).profile.onboarding.step, 8)
	Check.eq(store:GetAsync(freshKey).profile.cash, 1)
	Check.eq(store:GetAsync(freshKey).lockJobId, "studio-job")

	local gateway = fs.readFile("src/server/DataStoreGateway.luau")
	local keyAt = string.find(gateway, "local function profileKey", 1, true)
	Check.truthy(keyAt)
	local guardAt = string.find(gateway, "if not RunService:IsStudio() then", keyAt :: number, true)
	local argsAt = string.find(gateway, "StudioQaHooks.args()", keyAt :: number, true)
	Check.truthy(guardAt)
	Check.truthy(argsAt)
	Check.eq((guardAt :: number) < (argsAt :: number), true)
	Check.eq(string.find(gateway, "RemoteEvent", 1, true), nil)
	Check.eq(string.find(gateway, "FireServer", 1, true), nil)
	local freshSource = fs.readFile("src/shared/Logic/QaFresh.luau")
	Check.eq(string.find(freshSource, "RemoteEvent", 1, true), nil)
	Check.eq(string.find(freshSource, "GetTestArgs", 1, true), nil)
	Check.eq(string.find(freshSource, "FireServer", 1, true), nil)
end)

Check.test("a fresh key for a 16-digit user id stays within the datastore limit", function()
	local DataStoreGateway = require("../src/server/DataStoreGateway")
	local userId = 1000000000000000
	Check.eq(#tostring(userId), 16)
	local real = QaFresh.realKey(userId)
	local fresh = QaFresh.sessionKey(userId, true, "qa:600:fresh", "deadbeef-cafe-4dad-8bad-0123456789ab", 1)
	Check.eq(fresh, "player_1000000000000000_qf_deadbeefcafe")
	Check.eq(#fresh <= Save.MAX_KEY_LENGTH, true)
	Check.eq(fresh ~= real, true)
	Check.eq(Save.MAX_KEY_LENGTH, 50)
	Check.eq(DataStoreGateway.refuseLongKey(string.rep("k", 51)), "KeyNameLimit")
	Check.eq(DataStoreGateway.refuseLongKey(string.rep("k", 50)), nil)
	Check.eq(DataStoreGateway.refuseLongKey(fresh), nil)

	local gateway = fs.readFile("src/server/DataStoreGateway.luau")
	local loadAt = string.find(gateway, "function DataStoreGateway.load", 1, true)
	local saveAt = string.find(gateway, "function DataStoreGateway.save", 1, true)
	local renewAt = string.find(gateway, "function DataStoreGateway.renew", 1, true)
	local releaseAt = string.find(gateway, "function DataStoreGateway.release", 1, true)
	Check.truthy(loadAt)
	Check.truthy(saveAt)
	Check.truthy(renewAt)
	Check.truthy(releaseAt)
	local function beforeStore(fnAt: number, call: string)
		local refuseAt = string.find(gateway, "refuseLongKey", fnAt, true)
		local storeAt = string.find(gateway, call, fnAt, true)
		Check.truthy(refuseAt)
		Check.truthy(storeAt)
		Check.eq((refuseAt :: number) < (storeAt :: number), true)
	end
	beforeStore(loadAt :: number, "ledger.load")
	beforeStore(saveAt :: number, "ledger.save")
	beforeStore(renewAt :: number, "ledger.renew")
	beforeStore(releaseAt :: number, "ledger.release")
end)
