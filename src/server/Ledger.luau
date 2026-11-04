--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Save = import("../shared/Config/Save", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Save")
end)
local Retry = import("../shared/Logic/Retry", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("Retry")
end)
local Schema = import("../shared/Logic/Schema", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("Schema")
end)
local SessionDocument = import("../shared/Logic/SessionDocument", function()
	return game:GetService("ReplicatedStorage")
		:WaitForChild("Shared")
		:WaitForChild("Logic")
		:WaitForChild("SessionDocument")
end)

local Ledger = {}

Ledger.MOCK_WARNING =
	"[Cryptid:DataStore] Studio has no DataStore API access. Using an in-memory mock store. This session is not saved to a live DataStore."

function Ledger.studioApiDenied(message: string): boolean
	local lower = string.lower(message)
	local phrases = {
		"studioaccesstoapisnotallowed",
		"studio access to apis",
		"api access is not",
		"enable studio access",
		"cannot write to datastore",
		"not published",
		"must be published",
		"place has to be published",
		"publish the place",
	}
	for _, phrase in phrases do
		if string.find(lower, phrase, 1, true) ~= nil then
			return true
		end
	end
	if string.find(lower, "studio", 1, true) == nil then
		return false
	end
	return string.find(lower, "datastore", 1, true) ~= nil
		or string.find(lower, "api", 1, true) ~= nil
		or string.find(lower, "publish", 1, true) ~= nil
		or string.find(lower, "403", 1, true) ~= nil
end

function Ledger.open(options: {
	getStore: () -> any,
	createMock: () -> any,
	allowMock: () -> boolean,
	jobId: string,
	now: () -> number,
	waitFor: (number) -> (),
	warn: (string) -> (),
}): any
	local mock: any = nil
	local warned = false

	local function store(): any
		if mock ~= nil then
			return mock
		end
		return options.getStore()
	end

	local function installMockIfDenied(err: any): boolean
		if not options.allowMock() or not Ledger.studioApiDenied(tostring(err)) then
			return false
		end
		if mock == nil then
			if not warned then
				warned = true
				options.warn(Ledger.MOCK_WARNING)
			end
			mock = options.createMock()
		end
		return mock ~= nil
	end

	local function key(userId: number): string
		return Save.KEY_PREFIX .. tostring(userId)
	end

	local function acquire(userId: number, createProfile: any): (string, any?)
		local why = "error"
		local result = store():UpdateAsync(key(userId), function(old)
			local document, status =
				SessionDocument.buildWrite(old, options.jobId, options.now(), Save.LOCK_TTL_SECONDS, createProfile)
			why = status
			return document
		end)
		if type(result) == "table" and result.lockJobId == options.jobId then
			local profile = Schema.migrate(result.profile)
			if profile == nil then
				return "corrupt", nil
			end
			return "ready", profile
		end
		return why, nil
	end

	local api = {}

	function api.load(userId: number, createProfile: any): any
		local lastStatus = "error"
		for attempt = 1, Save.MAX_ATTEMPTS do
			local ok, status, profile = pcall(acquire, userId, createProfile)
			if not ok and installMockIfDenied(status) then
				ok, status, profile = pcall(acquire, userId, createProfile)
			end
			if not ok then
				lastStatus = "error"
				options.warn("Ledger read failed: " .. tostring(status))
			else
				lastStatus = status
				if status == "ready" and profile ~= nil then
					return {
						ok = true,
						profile = profile,
						ephemeral = false,
					}
				end
				if status == "corrupt" then
					return {
						ok = false,
						message = Save.KICK_LOAD_FAILED,
					}
				end
			end
			local pause = Retry.backoffSeconds(attempt)
			if pause == nil or lastStatus == "corrupt" then
				break
			end
			options.waitFor(pause)
		end
		if lastStatus == "locked" then
			return {
				ok = false,
				message = Save.KICK_LOCKED,
			}
		end
		return {
			ok = false,
			message = Save.KICK_LOAD_FAILED,
		}
	end

	function api.save(userId: number, profile: any): (boolean, string)
		local snapshot = Schema.deepCopy(profile)
		local why = "error"
		local function write(): any
			return store():UpdateAsync(key(userId), function(old)
				local document, status =
					SessionDocument.buildSave(old, options.jobId, options.now(), Save.LOCK_TTL_SECONDS, snapshot)
				why = status
				return document
			end)
		end
		local ok, result = pcall(write)
		if not ok and installMockIfDenied(result) then
			ok, result = pcall(write)
		end
		if not ok then
			options.warn("Ledger save failed: " .. tostring(result))
			return false, "error"
		end
		if type(result) ~= "table" then
			return false, why
		end
		return true, "saved"
	end

	function api.release(userId: number, profile: any): (boolean, string)
		local snapshot = Schema.deepCopy(profile)
		local why = "error"
		local function write(): any
			return store():UpdateAsync(key(userId), function(old)
				local document, status = SessionDocument.buildRelease(old, options.jobId, snapshot)
				why = status
				return document
			end)
		end
		local ok, result = pcall(write)
		if not ok and installMockIfDenied(result) then
			ok, result = pcall(write)
		end
		if not ok then
			options.warn("Ledger release failed: " .. tostring(result))
			return false, "error"
		end
		if type(result) ~= "table" then
			return false, why
		end
		return true, "released"
	end

	return api
end

return Ledger
