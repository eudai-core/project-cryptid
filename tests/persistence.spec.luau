--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local Check = require("./check")
local Economy = require("../src/shared/Config/Economy")
local Save = require("../src/shared/Config/Save")
local Schema = require("../src/shared/Logic/Schema")
local Ledger = require("../src/server/Ledger")
local MockDataStore = require("../src/server/MockDataStore")

local function key(userId: number): string
	return Save.KEY_PREFIX .. tostring(userId)
end

local function open(store: any, jobId: string, now: () -> number, warnings: { string }?, allowMock: boolean?): any
	return Ledger.open({
		getStore = function()
			return store
		end,
		createMock = function()
			error("this ledger was given its store and must not install another")
		end,
		allowMock = function()
			return allowMock == true
		end,
		jobId = jobId,
		now = now,
		waitFor = function() end,
		warn = function(message: string)
			if warnings ~= nil then
				table.insert(warnings, message)
			end
		end,
	})
end

Check.test("mock store copies values and cancels a nil update", function()
	local store = MockDataStore.new()
	Check.eq(store:GetAsync("missing"), nil)
	Check.eq(store:RemoveAsync("missing"), nil)
	store:SetAsync("pad", { n = 1, nested = { ok = true } })
	local got = store:GetAsync("pad")
	got.n = 99
	got.nested.ok = false
	Check.eq(store:GetAsync("pad").n, 1)
	Check.eq(store:GetAsync("pad").nested.ok, true)

	local cancelled = store:UpdateAsync("pad", function(old)
		old.n = 5
		return nil
	end)
	Check.eq(cancelled, nil)
	Check.eq(store:GetAsync("pad").n, 1)

	local written = store:UpdateAsync("pad", function(old)
		old.n += 1
		return old
	end)
	Check.eq(written.n, 2)
	written.n = 50
	Check.eq(store:GetAsync("pad").n, 2)

	local removed = store:RemoveAsync("pad")
	Check.eq(removed.n, 2)
	Check.eq(store:GetAsync("pad"), nil)

	local setNil = pcall(function()
		store:SetAsync("pad", nil)
	end)
	Check.eq(setNil, false)
	local transformThrew = pcall(function()
		store:UpdateAsync("pad", function()
			error("transform failed")
		end)
	end)
	Check.eq(transformThrew, false)
	Check.eq(store:GetAsync("pad"), nil)
end)

Check.test("ledger on the mock locks, migrates, saves, and releases", function()
	local store = MockDataStore.new()
	local now = 1000
	local clock = function()
		return now
	end
	local raw = Schema.newProfile(100, "starter-a")
	raw.dataVersion = 1
	raw.totalEarned = Economy.STARTING_CASH
	raw.cash = 80
	store:SetAsync(key(42), {
		lockJobId = "",
		lockExpiresAt = 0,
		profile = raw,
	})

	local jobA = open(store, "job-a", clock)
	local loaded = jobA.load(42, Schema.newProfile(100, "decoy"))
	Check.eq(loaded.ok, true)
	Check.eq(loaded.ephemeral, false)
	Check.eq(loaded.profile.cash, 80)
	Check.eq(loaded.profile.totalEarned, 0)
	Check.eq(loaded.profile.dataVersion, Save.DATA_VERSION)
	Check.truthy(loaded.profile.shop)
	Check.eq(loaded.profile.pads["1"], "starter-a")
	local held = store:GetAsync(key(42))
	Check.eq(held.lockJobId, "job-a")
	Check.eq(held.lockExpiresAt, 1090)
	Check.eq(held.profile.dataVersion, Save.DATA_VERSION)

	now = 1010
	local jobB = open(store, "job-b", clock)
	local denied = jobB.load(42, Schema.newProfile(100, "decoy"))
	Check.eq(denied.ok, false)
	Check.eq(denied.message, Save.KICK_LOCKED)
	Check.eq(store:GetAsync(key(42)).lockJobId, "job-a")

	now = 1090
	local stolen = jobB.load(42, Schema.newProfile(100, "decoy"))
	Check.eq(stolen.ok, true)
	Check.eq(stolen.profile.cash, 80)
	Check.eq(store:GetAsync(key(42)).lockJobId, "job-b")
	local lostSave, lostStatus = jobA.save(42, loaded.profile)
	Check.eq(lostSave, false)
	Check.eq(lostStatus, "lost")

	stolen.profile.cash = 120
	local saved, savedStatus = jobB.save(42, stolen.profile)
	Check.eq(saved, true)
	Check.eq(savedStatus, "saved")
	Check.eq(store:GetAsync(key(42)).profile.cash, 120)
	local released, releaseStatus = jobB.release(42, stolen.profile)
	Check.eq(released, true)
	Check.eq(releaseStatus, "released")
	Check.eq(store:GetAsync(key(42)).lockJobId, "")

	now = 2000
	local rejoined = jobA.load(42, Schema.newProfile(100, "decoy"))
	Check.eq(rejoined.ok, true)
	Check.eq(rejoined.profile.cash, 120)
	Check.eq(rejoined.profile.pads["1"], "starter-a")
end)

Check.test("a corrupt document is not replaced by a fresh profile", function()
	local store = MockDataStore.new()
	store:SetAsync(key(7), {
		lockJobId = "",
		lockExpiresAt = 0,
		profile = { dataVersion = 1 },
	})
	local ledger = open(store, "job-c", function()
		return 50
	end)
	local loaded = ledger.load(7, Schema.newProfile(50, "starter-a"))
	Check.eq(loaded.ok, false)
	Check.eq(loaded.message, Save.KICK_LOAD_FAILED)
	local still = store:GetAsync(key(7))
	Check.eq(still.profile.dataVersion, 1)
	Check.eq(still.profile.cash, nil)
end)

Check.test("studio api denial installs one mock and warns once", function()
	local calls = 0
	local real = {
		UpdateAsync = function()
			calls += 1
			error("403 StudioAccessToApisNotAllowed")
		end,
	}
	local mock = MockDataStore.new()
	local created = 0
	local warnings = {}
	local ledger = Ledger.open({
		getStore = function()
			return real
		end,
		createMock = function()
			created += 1
			return mock
		end,
		allowMock = function()
			return true
		end,
		jobId = "studio-job",
		now = function()
			return 50
		end,
		waitFor = function() end,
		warn = function(message: string)
			table.insert(warnings, message)
		end,
	})

	local first = ledger.load(9, Schema.newProfile(50, "starter-a"))
	Check.eq(first.ok, true)
	Check.eq(first.ephemeral, false)
	Check.eq(first.profile.cash, Economy.STARTING_CASH)
	Check.eq(first.profile.dataVersion, Save.DATA_VERSION)
	Check.eq(created, 1)
	Check.eq(calls, 1)
	Check.eq(#warnings, 1)
	Check.eq(warnings[1], Ledger.MOCK_WARNING)
	Check.eq(mock:GetAsync(key(9)).lockJobId, "studio-job")

	local second = ledger.load(10, Schema.newProfile(50, "starter-b"))
	Check.eq(second.ok, true)
	Check.eq(second.ephemeral, false)
	Check.eq(created, 1)
	Check.eq(calls, 1)
	Check.eq(#warnings, 1)
	second.profile.cash = 40
	local saved, savedStatus = ledger.save(10, second.profile)
	Check.eq(saved, true)
	Check.eq(savedStatus, "saved")
	Check.eq(mock:GetAsync(key(10)).profile.cash, 40)
end)

Check.test("a live server never installs the mock", function()
	local created = 0
	local warnings = {}
	local ledger = Ledger.open({
		getStore = function()
			return {
				UpdateAsync = function()
					error("403 StudioAccessToApisNotAllowed")
				end,
			}
		end,
		createMock = function()
			created += 1
			return MockDataStore.new()
		end,
		allowMock = function()
			return false
		end,
		jobId = "live-job",
		now = function()
			return 10
		end,
		waitFor = function() end,
		warn = function(message: string)
			table.insert(warnings, message)
		end,
	})
	local loaded = ledger.load(1, Schema.newProfile(10, "starter-a"))
	Check.eq(loaded.ok, false)
	Check.eq(loaded.message, Save.KICK_LOAD_FAILED)
	Check.eq(created, 0)
	Check.eq(#warnings, Save.MAX_ATTEMPTS)
	for _, message in warnings do
		Check.eq(string.find(message, "in-memory mock", 1, true), nil)
		Check.contains(message, "Ledger read failed")
	end
end)

Check.test("an ordinary studio failure is not hidden by the mock", function()
	local created = 0
	local warnings = {}
	local ledger = Ledger.open({
		getStore = function()
			return {
				UpdateAsync = function()
					error("502 Internal")
				end,
			}
		end,
		createMock = function()
			created += 1
			return MockDataStore.new()
		end,
		allowMock = function()
			return true
		end,
		jobId = "studio-job",
		now = function()
			return 10
		end,
		waitFor = function() end,
		warn = function(message: string)
			table.insert(warnings, message)
		end,
	})
	local loaded = ledger.load(3, Schema.newProfile(10, "starter-a"))
	Check.eq(loaded.ok, false)
	Check.eq(loaded.message, Save.KICK_LOAD_FAILED)
	Check.eq(created, 0)
	Check.eq(#warnings, Save.MAX_ATTEMPTS)
end)

Check.test("studio api denial phrases are recognised and other text is not", function()
	Check.eq(Ledger.studioApiDenied("403 StudioAccessToApisNotAllowed"), true)
	Check.eq(Ledger.studioApiDenied("The place must be published to use DataStore."), true)
	Check.eq(Ledger.studioApiDenied("Cannot write to DataStore from studio because API access is not enabled."), true)
	Check.eq(Ledger.studioApiDenied("502 Internal"), false)
	Check.eq(Ledger.studioApiDenied("studio-job failed to start"), false)
end)

Check.test("the place stamps BuildSha on ReplicatedStorage", function()
	local project = fs.readFile("default.project.json")
	Check.contains(project, '"BuildSha"')
	Check.contains(project, '"dev"')
end)
