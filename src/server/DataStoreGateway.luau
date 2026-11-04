--!strict

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Ledger = require(script.Parent:WaitForChild("Ledger"))
local MockDataStore = require(script.Parent:WaitForChild("MockDataStore"))
local Save = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Save")) :: any

local jobId = game.JobId
if jobId == "" then
	jobId = "studio-" .. HttpService:GenerateGUID(false)
end

local realStore: any = nil

local function getStore(): any
	if realStore == nil then
		realStore = DataStoreService:GetDataStore(Save.STORE_NAME)
	end
	return realStore
end

local function report(message: string)
	warn(message)
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
})

local DataStoreGateway = {}

function DataStoreGateway.load(userId: number, createProfile: any): any
	return ledger.load(userId, createProfile)
end

function DataStoreGateway.save(userId: number, profile: any): (boolean, string)
	return ledger.save(userId, profile)
end

function DataStoreGateway.release(userId: number, profile: any): (boolean, string)
	return ledger.release(userId, profile)
end

return DataStoreGateway
