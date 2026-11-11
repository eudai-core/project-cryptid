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

local DataStoreGateway = {}

function DataStoreGateway.refuseLongKey(key: any): string?
	if type(key) ~= "string" or #key > Save.MAX_KEY_LENGTH then
		return "KeyNameLimit"
	end
	return nil
end

-- selene: allow(global_usage)
if _G.LUNE == true then
	return DataStoreGateway
end

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Ledger = require(script.Parent:WaitForChild("Ledger"))
local MockDataStore = require(script.Parent:WaitForChild("MockDataStore"))
local SaveHooks = require(script.Parent:WaitForChild("SaveHooks"))
local StudioQaHooks = require(script.Parent:WaitForChild("Dev"):WaitForChild("StudioQaHooks"))
local QaFresh = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("QaFresh")) :: any
local Offline = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("Offline")) :: any

local jobId = game.JobId
if jobId == "" then
	jobId = "studio-" .. HttpService:GenerateGUID(false)
end

-- One GUID per server process. The fresh key uses its first 12 hex digits.
local freshGuid = ""
if RunService:IsStudio() then
	freshGuid = HttpService:GenerateGUID(false)
end

local function profileKey(userId: number): string
	if not RunService:IsStudio() then
		return Save.KEY_PREFIX .. tostring(userId)
	end
	return QaFresh.sessionKey(userId, RunService:IsStudio(), StudioQaHooks.args(), freshGuid, os.time())
end

local realStore: any = nil
local liveConfirmed = false
local hurry = false

local function getStore(): any
	if realStore == nil then
		realStore = DataStoreService:GetDataStore(Save.STORE_NAME)
	end
	return realStore
end

local function report(message: string)
	warn(message)
end

local function budgetFor(): number?
	if hurry or (RunService:IsStudio() and not liveConfirmed) then
		return nil
	end
	local ok, budget = pcall(function()
		return DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync)
	end)
	if not ok or type(budget) ~= "number" then
		return nil
	end
	return budget
end

local ledger = Ledger.open({
	getStore = getStore,
	createMock = function()
		if not RunService:IsStudio() then
			error("Mock DataStore is refused outside Studio")
		end
		return MockDataStore.new()
	end,
	allowMock = function()
		return RunService:IsStudio()
	end,
	jobId = jobId,
	now = os.time,
	waitFor = function(seconds: number)
		task.wait(seconds)
	end,
	warn = report,
	budgetFor = budgetFor,
	random = math.random,
	onSaved = function(userId: number, profile: any, reason: string)
		SaveHooks.fire(userId, profile, reason)
	end,
	isHurry = function()
		return hurry
	end,
	confirmLive = function()
		liveConfirmed = true
	end,
	settle = function(profile: any, now: number)
		StudioQaHooks.rewindLastSeen(profile)
		Offline.fold(profile, now)
	end,
	profileKey = profileKey,
})

function DataStoreGateway.load(userId: number, createProfile: any): any
	if DataStoreGateway.refuseLongKey(profileKey(userId)) ~= nil then
		return {
			ok = false,
			message = Save.KICK_LOAD_FAILED,
		}
	end
	return ledger.load(userId, createProfile)
end

function DataStoreGateway.save(userId: number, profile: any, rebirth: boolean?): (boolean, string)
	local refused = DataStoreGateway.refuseLongKey(profileKey(userId))
	if refused ~= nil then
		return false, refused
	end
	return ledger.save(userId, profile, rebirth == true)
end

function DataStoreGateway.renew(userId: number): (boolean, string, number?)
	local refused = DataStoreGateway.refuseLongKey(profileKey(userId))
	if refused ~= nil then
		return false, refused, nil
	end
	return ledger.renew(userId)
end

function DataStoreGateway.release(userId: number, profile: any, rebirth: boolean?): (boolean, string)
	local refused = DataStoreGateway.refuseLongKey(profileKey(userId))
	if refused ~= nil then
		return false, refused
	end
	return ledger.release(userId, profile, rebirth == true)
end

function DataStoreGateway.setHurry(value: boolean)
	hurry = value
end

function DataStoreGateway.seedForeignLock(userId: number, stale: boolean): boolean
	if not RunService:IsStudio() then
		return false
	end
	if DataStoreGateway.refuseLongKey(profileKey(userId)) ~= nil then
		return false
	end
	return ledger.seedForeignLock(userId, stale == true)
end

return DataStoreGateway
