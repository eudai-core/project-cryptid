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
	budgetFor: (() -> number?)?,
	random: (() -> number)?,
	onSaved: ((number, any, string) -> ())?,
	isHurry: (() -> boolean)?,
	confirmLive: (() -> ())?,
	settle: ((any, number) -> ())?,
}): any
	local mock: any = nil
	local warned = false
	local ready: { [number]: boolean } = {}

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
		if options.profileKey ~= nil then
			local named = options.profileKey(userId)
			if type(named) == "string" and named ~= "" then
				return named
			end
		end
		return Save.KEY_PREFIX .. tostring(userId)
	end

	local function hurry(): boolean
		return options.isHurry ~= nil and options.isHurry() == true
	end

	local function roll(): number
		if options.random == nil then
			return 0.5
		end
		local value = options.random()
		if type(value) ~= "number" then
			return 0.5
		end
		return value
	end

	local function awaitBudget()
		if hurry() or mock ~= nil or options.budgetFor == nil then
			return
		end
		local budget = options.budgetFor()
		if type(budget) ~= "number" or budget >= Save.BUDGET_MIN_REMAINING then
			return
		end
		options.waitFor(Save.BUDGET_WAIT_SECONDS)
	end

	local function runUpdate(
		label: string,
		userKey: string,
		transform: (any) -> (any?, string),
		trace: { pcallError: string }?
	): (boolean, string, any?, number)
		local lastStatus = "error"
		local attempts = 0
		for attempt = 1, Save.MAX_ATTEMPTS do
			attempts = attempt
			awaitBudget()
			local why = "error"
			local function call(): any
				return store():UpdateAsync(userKey, function(old)
					local document, status = transform(old)
					why = status
					return document
				end)
			end
			local ok, result = pcall(call)
			if not ok and installMockIfDenied(result) then
				ok, result = pcall(call)
			end
			if ok then
				if mock == nil and options.confirmLive ~= nil then
					options.confirmLive()
				end
				if type(result) == "table" then
					return true, why, result, attempts
				end
				lastStatus = why
				if why ~= "locked" then
					if why == "wipe" or why == "downgrade" then
						options.warn(string.format("[Cryptid:DataStore] refusing %s (%s) for %s", label, why, userKey))
					end
					return false, why, nil, attempts
				end
			else
				lastStatus = "error"
				local message = tostring(result)
				if trace ~= nil then
					trace.pcallError = message
				end
				options.warn("Ledger " .. label .. " failed: " .. message)
				if Retry.classify(message) == "fatal" then
					return false, "fatal", nil, attempts
				end
			end
			local pause = Retry.backoffSeconds(attempt)
			if pause == nil then
				break
			end
			if not hurry() then
				options.waitFor(Retry.withJitter(pause, roll()))
			end
		end
		return false, lastStatus, nil, attempts
	end

	local api = {}

	function api.load(userId: number, createProfile: any): any
		ready[userId] = false
		local trace = {
			pcallError = "",
			dataVersion = "missing",
			lockJobId = "",
			lockExpiresAt = "",
			migrate = "unseen",
		}
		local ok, status, result, attempts = runUpdate("read", key(userId), function(old)
			if old == nil then
				trace.dataVersion = "missing"
				trace.migrate = "create"
			elseif type(old) ~= "table" or type(old.profile) ~= "table" then
				trace.dataVersion = "bad"
				trace.migrate = "nil"
			else
				trace.dataVersion = tostring(old.profile.dataVersion)
				trace.lockJobId = tostring(old.lockJobId)
				trace.lockExpiresAt = tostring(old.lockExpiresAt)
				local version = old.profile.dataVersion
				if
					type(version) ~= "number"
					or version ~= math.floor(version)
					or version > Save.DATA_VERSION
					or version < 1
				then
					trace.migrate = "nil"
				else
					trace.migrate = "in-range"
				end
			end
			return SessionDocument.buildWrite(
				old,
				options.jobId,
				options.now(),
				Save.LOCK_TTL_SECONDS,
				createProfile,
				options.settle
			)
		end, trace)
		if type(attempts) ~= "number" or attempts < 1 then
			attempts = 1
		end
		if status == "loaded" or status == "created" then
			trace.migrate = "ok"
		elseif status == "corrupt" then
			trace.migrate = "nil"
		elseif status == "locked" then
			trace.migrate = "skipped"
		end
		local function withTrace(fields: { [string]: any }): any
			fields.dataVersionSeen = trace.dataVersion
			fields.codeVersion = Save.DATA_VERSION
			fields.migrate = trace.migrate
			fields.lockOwner = trace.lockJobId
			fields.lockExpiry = trace.lockExpiresAt
			fields.pcallError = trace.pcallError
			return fields
		end
		if ok and type(result) == "table" and result.lockJobId == options.jobId then
			local seenUnix = result.seenUnix
			local profile = Schema.migrate(result.profile, options.now())
			if profile == nil then
				trace.migrate = "nil"
				return withTrace({
					ok = false,
					message = Save.KICK_LOAD_FAILED,
					reason = "corrupt",
					attempts = attempts,
				})
			end
			ready[userId] = true
			return withTrace({
				ok = true,
				profile = profile,
				ephemeral = false,
				lockExpiresAt = result.lockExpiresAt,
				fresh = status == "created",
				seenUnix = if type(seenUnix) == "number" then seenUnix else nil,
				attempts = attempts,
				reason = status,
			})
		end
		local reason = "read"
		if status == "corrupt" then
			reason = "corrupt"
		end
		if status == "locked" then
			return withTrace({
				ok = false,
				message = Save.KICK_LOCKED,
				reason = "locked",
				attempts = attempts,
			})
		end
		return withTrace({
			ok = false,
			message = Save.KICK_LOAD_FAILED,
			reason = reason,
			attempts = attempts,
		})
	end

	local function requireReady(userId: number, label: string): boolean
		if ready[userId] == true then
			return true
		end
		options.warn("[Cryptid:DataStore] refusing " .. label .. " of an unloaded profile for " .. key(userId))
		return false
	end

	function api.save(userId: number, profile: any, rebirth: boolean?): (boolean, string)
		if not requireReady(userId, "save") then
			return false, "unloaded"
		end
		local snapshot = Schema.deepCopy(profile)
		local ok, status, result = runUpdate("save", key(userId), function(old)
			return SessionDocument.buildSave(
				old,
				options.jobId,
				options.now(),
				Save.LOCK_TTL_SECONDS,
				snapshot,
				rebirth == true
			)
		end)
		if ok and type(result) == "table" then
			if options.onSaved ~= nil then
				options.onSaved(userId, snapshot, "save")
			end
			return true, "saved"
		end
		return false, status
	end

	function api.renew(userId: number): (boolean, string, number?)
		if not requireReady(userId, "renew") then
			return false, "unloaded", nil
		end
		local ok, status, result = runUpdate("renew", key(userId), function(old)
			return SessionDocument.buildRenew(old, options.jobId, options.now(), Save.LOCK_TTL_SECONDS)
		end)
		if ok and type(result) == "table" then
			return true, "renewed", result.lockExpiresAt
		end
		return false, status, nil
	end

	function api.seedForeignLock(userId: number, stale: boolean): boolean
		local now = options.now()
		local expires = now + Save.LOCK_TTL_SECONDS
		if stale then
			expires = now - Save.QA_STALE_LOCK_AGE_SECONDS
		end
		local ok, _status, result = runUpdate("seed", key(userId), function(old)
			if type(old) ~= "table" or type(old.profile) ~= "table" then
				return nil, "missing"
			end
			return {
				lockJobId = Save.QA_FOREIGN_JOB_ID,
				lockTimestamp = now,
				lockLeaseSeconds = Save.LOCK_TTL_SECONDS,
				lockExpiresAt = expires,
				profile = old.profile,
			},
				"seeded"
		end)
		return ok == true and type(result) == "table" and result.lockJobId == Save.QA_FOREIGN_JOB_ID
	end

	function api.release(userId: number, profile: any, rebirth: boolean?): (boolean, string)
		if not requireReady(userId, "release") then
			return false, "unloaded"
		end
		local snapshot = Schema.deepCopy(profile)
		local ok, status, result = runUpdate("release", key(userId), function(old)
			return SessionDocument.buildRelease(old, options.jobId, snapshot, rebirth == true)
		end)
		if ok and type(result) == "table" then
			ready[userId] = false
			return true, "released"
		end
		return false, status
	end

	return api
end

return Ledger
