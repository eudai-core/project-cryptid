--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local QaArgs = require(script.Parent:WaitForChild("QaArgs"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Money = require(Shared:WaitForChild("Logic"):WaitForChild("Money")) :: any

local QaGrant = {}

function QaGrant.apply(profile: any, userId: number)
	if not RunService:IsStudio() then
		return
	end
	if type(profile) ~= "table" or type(userId) ~= "number" then
		return
	end
	local StudioTestService = game:GetService("StudioTestService") :: any
	local ok, args = pcall(function()
		return StudioTestService:GetTestArgs()
	end)
	if not ok or type(args) ~= "string" then
		return
	end
	local amount = QaArgs.cashGrant(args)
	if amount == nil then
		return
	end
	profile.cash = Money.round(amount)
	warn(string.format("[Cryptid:QA] granted cash %d to %d", amount, userId))
end

return QaGrant
