--!strict

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Save = require(Shared:WaitForChild("Config"):WaitForChild("Save")) :: any
local Retry = require(Shared:WaitForChild("Logic"):WaitForChild("Retry")) :: any
local Schema = require(Shared:WaitForChild("Logic"):WaitForChild("Schema")) :: any
local SessionDocument = require(Shared:WaitForChild("Logic"):WaitForChild("SessionDocument")) :: any

local jobId = game.JobId
if jobId == "" then
	jobId = "studio-" .. HttpService:GenerateGUID(false)
end

local store: any = nil

local function getStore(): any
	if store == nil then
		store = DataStoreService:GetDataStore(Save.STORE_NAME)
	end
	return store
end

local function key(userId: number): string
	return Save.KEY_PREFIX .. tostring(userId)
end

local DataStoreGateway = {}

local function acquire(userId: number, createProfile: any): (string, any?)
	local why = "error"
	local result = getStore():UpdateAsync(key(userId), function(old)
		local document, status = SessionDocument.buildWrite(old, jobId, os.time(), Save.LOCK_TTL_SECONDS, createProfile)
		why = status
		return document
	end)
	if type(result) == "table" and result.lockJobId == jobId then
		local profile = Schema.migrate(result.profile)
		if profile == nil then
			return "corrupt", nil
		end
		return "ready", profile
	end
	return why, nil
end

function DataStoreGateway.load(userId: number, createProfile: any): any
	local lastStatus = "error"
	for attempt = 1, Save.MAX_ATTEMPTS do
		local ok, status, profile = pcall(acquire, userId, createProfile)
		if not ok then
			lastStatus = "error"
			local message = tostring(status)
			warn("Ledger read failed: " .. message)
			if RunService:IsStudio() and string.find(string.lower(message), "studio", 1, true) ~= nil then
				break
			end
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
		task.wait(pause)
	end
	if lastStatus == "locked" then
		return {
			ok = false,
			message = Save.KICK_LOCKED,
		}
	end
	if RunService:IsStudio() then
		warn("DataStore unavailable in Studio. This ledger is ephemeral and will not be saved.")
		return {
			ok = true,
			profile = Schema.migrate(createProfile),
			ephemeral = true,
		}
	end
	return {
		ok = false,
		message = Save.KICK_LOAD_FAILED,
	}
end

function DataStoreGateway.save(userId: number, profile: any): (boolean, string)
	local snapshot = Schema.deepCopy(profile)
	local why = "error"
	local ok, result = pcall(function()
		return getStore():UpdateAsync(key(userId), function(old)
			local document, status = SessionDocument.buildSave(old, jobId, os.time(), Save.LOCK_TTL_SECONDS, snapshot)
			why = status
			return document
		end)
	end)
	if not ok then
		warn("Ledger save failed: " .. tostring(result))
		return false, "error"
	end
	if type(result) ~= "table" then
		return false, why
	end
	return true, "saved"
end

function DataStoreGateway.release(userId: number, profile: any): (boolean, string)
	local snapshot = Schema.deepCopy(profile)
	local why = "error"
	local ok, result = pcall(function()
		return getStore():UpdateAsync(key(userId), function(old)
			local document, status = SessionDocument.buildRelease(old, jobId, snapshot)
			why = status
			return document
		end)
	end)
	if not ok then
		warn("Ledger release failed: " .. tostring(result))
		return false, "error"
	end
	if type(result) ~= "table" then
		return false, why
	end
	return true, "released"
end

return DataStoreGateway
