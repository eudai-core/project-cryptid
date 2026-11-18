--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MonetisationService = require(script.Parent:WaitForChild("MonetisationService"))
local StudioQaHooks = require(script.Parent:WaitForChild("Dev"):WaitForChild("StudioQaHooks"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local TarotCases = require(Shared:WaitForChild("Config"):WaitForChild("TarotCases"))
local TarotAccess = require(Shared:WaitForChild("Logic"):WaitForChild("TarotAccess"))

local TarotService = {}

function TarotService.context(session: any, gate: any): any
	return {
		now = StudioQaHooks.unixNow(),
		entropy = os.time(),
		paidEnabled = TarotAccess.enabled(TarotCases.PAID_TAROT_ENABLED, RunService:IsStudio(), StudioQaHooks.args()),
		policyAllows = session.paidRandom == true,
		gate = gate,
		rng = function(seed: number)
			return Random.new(seed)
		end,
		newId = function()
			return HttpService:GenerateGUID(false)
		end,
	}
end

function TarotService.prompt(player: Player, decision: any): boolean
	if type(decision) ~= "table" or decision.prompt ~= true then
		return false
	end
	local productId = decision.productId
	if type(productId) ~= "number" or productId ~= math.floor(productId) or productId <= 0 then
		return false
	end
	MonetisationService.promptProduct(player, productId)
	return true
end

return TarotService
