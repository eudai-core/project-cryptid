--!strict

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Ledger = require(script.Parent:WaitForChild("Ledger"))
local MockDataStore = require(script.Parent:WaitForChild("MockDataStore"))
local SaveHooks = require(script.Parent:WaitForChild("SaveHooks"))
local StudioQa = require(script.Parent:WaitForChild("Dev"):WaitForChild("StudioQa"))
local Save = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Save")) :: any
local Offline = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("Offline")) :: any

local jobId = game.JobId
if jobId == "" then
	jobId = "studio-" .. HttpService:GenerateGUID(false)
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
		StudioQa.rewindLastSeen(profile)
		Offline.fold(profile, now)
	end,
})

local DataStoreGateway = {}

function DataStoreGateway.load(userId: number, createProfile: any): any
	return ledger.load(userId, createProfile)
end

function DataStoreGateway.save(userId: number, profile: any, rebirth: boolean?): (boolean, string)
	return ledger.save(userId, profile, rebirth == true)
end

function DataStoreGateway.renew(userId: number): (boolean, string, number?)
	return ledger.renew(userId)
end

function DataStoreGateway.release(userId: number, profile: any, rebirth: boolean?): (boolean, string)
	return ledger.release(userId, profile, rebirth == true)
end

function DataStoreGateway.setHurry(value: boolean)
	hurry = value
end

return DataStoreGateway
