--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local SaveGuard = import("./SaveGuard", function()
	return script.Parent:WaitForChild("SaveGuard")
end)
local Schema = import("./Schema", function()
	return script.Parent:WaitForChild("Schema")
end)

local SessionDocument = {}

local function lockActive(document: any, jobId: string, now: number): boolean
	local lockJob = document.lockJobId
	if type(lockJob) ~= "string" or lockJob == "" or lockJob == jobId then
		return false
	end
	local expires = document.lockExpiresAt
	if type(expires) ~= "number" then
		return false
	end
	return expires > now
end

local function sealed(profile: any, jobId: string, now: number, ttl: number): any
	return {
		lockJobId = jobId,
		lockTimestamp = now,
		lockLeaseSeconds = ttl,
		lockExpiresAt = now + ttl,
		profile = profile,
	}
end

local function guard(old: any, profile: any, rebirth: boolean): (any?, string)
	local reason = SaveGuard.rejection(old.profile, profile, rebirth)
	if reason ~= nil then
		return nil, reason
	end
	return nil, ""
end

function SessionDocument.buildWrite(
	old: any,
	jobId: string,
	now: number,
	ttl: number,
	createProfile: any,
	settle: ((any, number) -> ())?
): (any?, string)
	local function finish(profile: any, status: string): (any?, string)
		local seenUnix = nil
		if settle ~= nil then
			local prior = settle(profile, now)
			if type(prior) == "number" and prior == prior and prior >= 0 and prior ~= math.huge then
				seenUnix = math.floor(prior)
			end
		end
		local document = sealed(profile, jobId, now, ttl)
		if seenUnix ~= nil then
			document.seenUnix = seenUnix
		end
		return document, status
	end
	if old == nil then
		local profile = Schema.migrate(createProfile, now)
		if profile == nil then
			return nil, "corrupt"
		end
		return finish(profile, "created")
	end
	if type(old) ~= "table" or type(old.profile) ~= "table" then
		return nil, "corrupt"
	end
	if lockActive(old, jobId, now) then
		return nil, "locked"
	end
	local profile = Schema.migrate(old.profile, now)
	if profile == nil then
		return nil, "corrupt"
	end
	return finish(profile, "loaded")
end

function SessionDocument.buildSave(
	old: any,
	jobId: string,
	now: number,
	ttl: number,
	profile: any,
	rebirth: boolean?
): (any?, string)
	if type(old) ~= "table" then
		return nil, "lost"
	end
	if old.lockJobId ~= jobId then
		return nil, "lost"
	end
	if type(profile) ~= "table" then
		return nil, "corrupt"
	end
	local _, reason = guard(old, profile, rebirth == true)
	if reason ~= "" then
		return nil, reason
	end
	return sealed(profile, jobId, now, ttl), "saved"
end

function SessionDocument.buildRenew(old: any, jobId: string, now: number, ttl: number): (any?, string)
	if type(old) ~= "table" or old.lockJobId ~= jobId then
		return nil, "lost"
	end
	if type(old.profile) ~= "table" then
		return nil, "corrupt"
	end
	return sealed(old.profile, jobId, now, ttl), "renewed"
end

function SessionDocument.buildRelease(old: any, jobId: string, profile: any, rebirth: boolean?): (any?, string)
	if type(old) ~= "table" or old.lockJobId ~= jobId then
		return nil, "lost"
	end
	if type(profile) ~= "table" then
		return nil, "corrupt"
	end
	local _, reason = guard(old, profile, rebirth == true)
	if reason ~= "" then
		return nil, reason
	end
	return {
		lockJobId = "",
		lockTimestamp = 0,
		lockLeaseSeconds = 0,
		lockExpiresAt = 0,
		profile = profile,
	},
		"released"
end

return SessionDocument
