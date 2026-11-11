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
local TitheStore = require("../src/server/TitheStore")

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

local function openTithe(real: any, isStudio: boolean, placeId: number, warnings: { string }, mock: any): any
	return TitheStore.open({
		getStore = function()
			return real
		end,
		createMock = function()
			return mock
		end,
		allowMock = function()
			return isStudio == true
		end,
		isStudio = isStudio,
		placeId = placeId,
		warn = function(message: string)
			table.insert(warnings, message)
		end,
	})
end

Check.test("an ordered page matches the sorted DataStore shape", function()
	local ordered = MockDataStore.newOrdered()
	ordered:SetAsync("10", 4)
	ordered:SetAsync("2", 9)
	ordered:SetAsync("7", 9)
	local updated = ordered:UpdateAsync("10", function(old: number?): number
		return (old or 0) + 1
	end)
	Check.eq(updated, 5)
	local pages = ordered:GetSortedAsync(false, 2)
	Check.eq(type(pages.GetCurrentPage), "function")
	Check.eq(pages:IsFinished(), false)
	local page = pages:GetCurrentPage()
	Check.eq(#page, 2)
	Check.eq(type(page[1].key), "string")
	Check.eq(type(page[1].value), "number")
	Check.eq(page[1].key, "2")
	Check.eq(page[1].value, 9)
	Check.eq(page[2].key, "7")
	Check.eq(page[2].value, 9)
	local low = ordered:GetSortedAsync(true, 3):GetCurrentPage()
	Check.eq(low[1].key, "10")
	Check.eq(low[1].value, 5)
	Check.eq(low[3].value, 9)
end)

Check.test("PlaceId 0 in Studio reads the ordered mock and does not open the live store", function()
	local reads = 0
	local warnings = {}
	local store = TitheStore.open({
		getStore = function()
			reads += 1
			error("live ordered store")
		end,
		createMock = function()
			return MockDataStore.newOrdered()
		end,
		allowMock = function()
			return true
		end,
		isStudio = true,
		placeId = StudioDataStore.UNPUBLISHED_PLACE_ID,
		warn = function(message: string)
			table.insert(warnings, message)
		end,
	})
	Check.eq(store.set("4", 3), true)
	Check.eq(store.set("9", 8), true)
	local ok, pages = store.getSorted(false, 10)
	Check.eq(ok, true)
	local page = pages:GetCurrentPage()
	Check.eq(#page, 2)
	Check.eq(page[1].key, "9")
	Check.eq(page[1].value, 8)
	Check.eq(page[2].key, "4")
	Check.eq(page[2].value, 3)
	Check.eq(pages:IsFinished(), true)
	Check.eq(reads, 0)
	Check.eq(#warnings, 1)
	Check.eq(warnings[1], StudioDataStore.MOCK_WARNING)
	Check.eq(store.usingMock(), true)
end)

Check.test("a Studio 403 on the ordered store falls back once", function()
	local calls = 0
	local real = {
		GetSortedAsync = function(_self: any)
			calls += 1
			error("403 StudioAccessToApisNotAllowed")
		end,
		SetAsync = function(_self: any)
			calls += 1
			error("403 StudioAccessToApisNotAllowed")
		end,
		UpdateAsync = function(_self: any)
			calls += 1
			error("403 StudioAccessToApisNotAllowed")
		end,
	}
	local warnings = {}
	local store = openTithe(real, true, CRYPTID_TEST_PLACE_ID, warnings, MockDataStore.newOrdered())
	local failed, empty = store.getSorted(false, 50)
	Check.eq(failed, true)
	Check.eq(#empty:GetCurrentPage(), 0)
	Check.eq(calls, 1)
	Check.eq(#warnings, 1)
	Check.eq(warnings[1], StudioDataStore.MOCK_WARNING)
	Check.eq(store.set("15", 2), true)
	local updatedOk, updated = store.update("15", function(old: number?): number
		return (old or 0) + 6
	end)
	Check.eq(updatedOk, true)
	Check.eq(updated, 8)
	local ok, pages = store.getSorted(false, 50)
	Check.eq(ok, true)
	local page = pages:GetCurrentPage()
	Check.eq(#page, 1)
	Check.eq(page[1].key, "15")
	Check.eq(page[1].value, 8)
	Check.eq(calls, 1)
	Check.eq(#warnings, 1)
end)

Check.test("a 403 on the ordered store outside Studio never installs the mock", function()
	local calls = 0
	local created = 0
	local real = {
		GetSortedAsync = function(_self: any)
			calls += 1
			error("403 StudioAccessToApisNotAllowed")
		end,
	}
	local warnings = {}
	local store = TitheStore.open({
		getStore = function()
			return real
		end,
		createMock = function()
			created += 1
			return MockDataStore.newOrdered()
		end,
		allowMock = function()
			return false
		end,
		isStudio = false,
		placeId = 0,
		warn = function(message: string)
			table.insert(warnings, message)
		end,
	})
	local ok, pages = store.getSorted(false, 10)
	Check.eq(ok, false)
	Check.eq(pages ~= nil, true)
	Check.eq(created, 0)
	Check.eq(calls, 1)
	Check.eq(store.usingMock(), false)
	Check.eq(#warnings, 0)
	Check.eq(StudioStore.preferMock(false, 0, "403 StudioAccessToApisNotAllowed"), false)
end)
