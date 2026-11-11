--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local Check = require("./check")
local Economy = require("../src/shared/Config/Economy")
local Save = require("../src/shared/Config/Save")
local StudioDataStore = require("../src/shared/Config/StudioDataStore")
local Schema = require("../src/shared/Logic/Schema")
local StudioStore = require("../src/shared/Logic/StudioStore")
local StudioQa = require("../src/server/Dev/StudioQa")
local Ledger = require("../src/server/Ledger")
local MockDataStore = require("../src/server/MockDataStore")

local CRYPTID_TEST_PLACE_ID = 80631305127330

local function key(userId: number): string
	return Save.KEY_PREFIX .. tostring(userId)
end

local function kickText(plan: string, loaded: any): string?
	if plan == "kick" then
		return Save.KICK_LOAD_FAILED
	end
	if type(loaded) ~= "table" or loaded.ok ~= true or loaded.profile == nil then
		local message = if type(loaded) == "table" then loaded.message else nil
		if type(message) == "string" and message ~= "" then
			return message
		end
		return Save.KICK_LOAD_FAILED
	end
	return nil
end

local function open(
	store: any,
	isStudio: boolean,
	placeId: number,
	warnings: { string },
	mock: any
): (any, { created: number, reads: number })
	local stats = { created = 0, reads = 0 }
	local ledger = Ledger.open({
		getStore = function()
			stats.reads += 1
			if store == nil then
				error("real store must not be opened")
			end
			return store
		end,
		createMock = function()
			stats.created += 1
			return mock
		end,
		allowMock = function()
			return isStudio == true
		end,
		isStudio = isStudio,
		placeId = placeId,
		jobId = if isStudio then "studio-job" else "live-job",
		now = function()
			return 50
		end,
		waitFor = function() end,
		warn = function(message: string)
			table.insert(warnings, message)
		end,
	})
	return ledger, stats
end

Check.test("PlaceId 0 in Studio loads on the mock store and does not kick", function()
	Check.eq(StudioStore.preferMock(true, StudioDataStore.UNPUBLISHED_PLACE_ID, nil), true)
	Check.eq(StudioQa.plan(true, nil), "load")
	local gateway = fs.readFile("src/server/DataStoreGateway.luau")
	Check.contains(gateway, "isStudio = RunService:IsStudio()")
	Check.contains(gateway, "placeId = game.PlaceId")
	Check.contains(fs.readFile("src/server/Ledger.luau"), "StudioStore.preferMock")
	Check.contains(fs.readFile("src/server/PlayerSession.luau"), "if not loaded.ok or loaded.profile == nil then")

	local mock = MockDataStore.new()
	local warnings = {}
	local ledger, stats = open(nil, true, 0, warnings, mock)
	local first = ledger.load(4, Schema.newProfile(50, "starter-a"))
	local second = ledger.load(5, Schema.newProfile(50, "starter-b"))

	Check.eq(first.ok, true)
	Check.eq(first.profile.cash, Economy.STARTING_CASH)
	Check.eq(first.profile.dataVersion, Save.DATA_VERSION)
	Check.eq(kickText(StudioQa.plan(true, nil), first), nil)
	Check.eq(kickText("load", second), nil)
	Check.eq(second.ok, true)
	Check.eq(stats.created, 1)
	Check.eq(stats.reads, 0)
	Check.eq(#warnings, 1)
	Check.eq(warnings[1], StudioDataStore.MOCK_WARNING)
	Check.eq(warnings[1], Ledger.MOCK_WARNING)
	Check.eq(mock:GetAsync(key(4)).lockJobId, "studio-job")
	Check.eq(mock:GetAsync(key(5)).lockJobId, "studio-job")
	first.profile.cash = 60
	local saved, savedStatus = ledger.save(4, first.profile)
	Check.eq(saved, true)
	Check.eq(savedStatus, "saved")
	Check.eq(mock:GetAsync(key(4)).profile.cash, 60)
	Check.eq(#warnings, 1)
	Check.eq(stats.reads, 0)
end)

Check.test("a Studio 403 on a published place falls back once and does not kick", function()
	local calls = 0
	local real = {
		UpdateAsync = function()
			calls += 1
			error("403 StudioAccessToApisNotAllowed")
		end,
	}
	Check.eq(StudioStore.preferMock(true, CRYPTID_TEST_PLACE_ID, nil), false)
	Check.eq(StudioStore.preferMock(true, CRYPTID_TEST_PLACE_ID, "403 StudioAccessToApisNotAllowed"), true)

	local mock = MockDataStore.new()
	local warnings = {}
	local ledger, stats = open(real, true, CRYPTID_TEST_PLACE_ID, warnings, mock)
	local players = { 21, 22, 23 }
	for _, userId in players do
		local loaded = ledger.load(userId, Schema.newProfile(50, "starter-a"))
		Check.eq(loaded.ok, true)
		Check.eq(loaded.profile ~= nil, true)
		Check.eq(kickText("load", loaded), nil)
		Check.eq(loaded.profile.cash, Economy.STARTING_CASH)
		Check.eq(mock:GetAsync(key(userId)).lockJobId, "studio-job")
	end
	Check.eq(calls, 1)
	Check.eq(stats.created, 1)
	Check.eq(#warnings, 1)
	Check.eq(warnings[1], StudioDataStore.MOCK_WARNING)
end)

Check.test("a 403 outside Studio still kicks and never installs the mock", function()
	local denied = "403 StudioAccessToApisNotAllowed"
	Check.eq(StudioStore.preferMock(false, CRYPTID_TEST_PLACE_ID, denied), false)
	Check.eq(StudioStore.preferMock(false, 0, denied), false)
	Check.eq(StudioStore.preferMock(false, 0, nil), false)
	Check.eq(StudioStore.preferMock(false, 0, "You must publish this place to the web to access DataStore."), false)
	Check.eq(
		StudioStore.preferMock(
			false,
			CRYPTID_TEST_PLACE_ID,
			"502: API Services rejected request with error. HTTP 403 (Forbidden)"
		),
		false
	)

	local calls = 0
	local real = {
		UpdateAsync = function()
			calls += 1
			error(denied)
		end,
	}
	local warnings = {}
	local ledger, stats = open(real, false, CRYPTID_TEST_PLACE_ID, warnings, MockDataStore.new())
	local loaded = ledger.load(1, Schema.newProfile(10, "starter-a"))
	Check.eq(loaded.ok, false)
	Check.eq(loaded.message, Save.KICK_LOAD_FAILED)
	Check.eq(kickText("load", loaded), Save.KICK_LOAD_FAILED)
	Check.eq(loaded.attempts, Save.MAX_ATTEMPTS)
	Check.eq(stats.created, 0)
	Check.eq(calls, Save.MAX_ATTEMPTS)
	Check.eq(#warnings, Save.MAX_ATTEMPTS)
	for _, message in warnings do
		Check.eq(string.find(message, "in-memory mock", 1, true), nil)
		Check.contains(message, "Ledger read failed")
	end
end)

Check.test("a published Studio place with a working store uses the real store", function()
	Check.eq(StudioStore.preferMock(true, CRYPTID_TEST_PLACE_ID, nil), false)
	local real = MockDataStore.new()
	local warnings = {}
	local ledger, stats = open(real, true, CRYPTID_TEST_PLACE_ID, warnings, MockDataStore.new())
	local loaded = ledger.load(8, Schema.newProfile(50, "starter-a"))
	Check.eq(loaded.ok, true)
	Check.eq(kickText("load", loaded), nil)
	Check.eq(stats.created, 0)
	Check.eq(stats.reads > 0, true)
	Check.eq(#warnings, 0)
	Check.eq(real:GetAsync(key(8)).lockJobId, "studio-job")
	loaded.profile.cash = 40
	local saved, savedStatus = ledger.save(8, loaded.profile)
	Check.eq(saved, true)
	Check.eq(savedStatus, "saved")
	Check.eq(real:GetAsync(key(8)).profile.cash, 40)
	Check.eq(stats.created, 0)
	Check.eq(#warnings, 0)
end)

Check.test("a must-publish error in Studio falls back to the mock", function()
	local messages = {
		"You must publish this place to the web to access DataStore.",
		"502: API Services rejected request with error. HTTP 403 (Forbidden)",
	}
	for index, message in messages do
		Check.eq(StudioStore.isAccessDenied(message), true)
		local calls = 0
		local real = {
			UpdateAsync = function()
				calls += 1
				error(message)
			end,
		}
		local mock = MockDataStore.new()
		local warnings = {}
		local ledger, stats = open(real, true, CRYPTID_TEST_PLACE_ID, warnings, mock)
		local loaded = ledger.load(30 + index, Schema.newProfile(50, "starter-a"))
		Check.eq(loaded.ok, true)
		Check.eq(kickText("load", loaded), nil)
		Check.eq(calls, 1)
		Check.eq(stats.created, 1)
		Check.eq(#warnings, 1)
		Check.eq(warnings[1], StudioDataStore.MOCK_WARNING)
		Check.eq(mock:GetAsync(key(30 + index)).lockJobId, "studio-job")
	end
end)
