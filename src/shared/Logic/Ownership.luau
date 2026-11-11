--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Monetisation = import("../Config/Monetisation", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Monetisation")
end)
local Return = import("../Config/Return", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Return")
end)
local Income = import("./Income", function()
	return script.Parent:WaitForChild("Income")
end)
local Rebirth = import("./Rebirth", function()
	return script.Parent:WaitForChild("Rebirth")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)

local Ownership = {}

function Ownership.layers(profile: any, forcedCash: number?): { skills: number, rebirth: number, cashPass: number }
	return {
		skills = 1,
		rebirth = Rebirth.multiplier(profile),
		cashPass = Ownership.cashMultiplier(profile, forcedCash),
	}
end

function Ownership.leaveRates(profile: any, forcedCash: number?): (number, number)
	local layers = Ownership.layers(profile, forcedCash)
	local scale = layers.skills * layers.rebirth
	local titheRate = Money.round(Income.tithePerSecond(profile) * scale)
	local cashRate = Money.round(Income.perSecond(profile) * scale * layers.cashPass)
	return titheRate, cashRate
end

function Ownership.cryptidTick(profile: any, seconds: number, forcedCash: number?): { cash: number, tithe: number }
	local span = seconds
	if type(span) ~= "number" or span ~= span or span < 0 or span == math.huge then
		span = 0
	end
	local noPass, withPass = Ownership.leaveRates(profile, forcedCash)
	return {
		cash = Money.round(withPass * span),
		tithe = Money.round(noPass * span),
	}
end

function Ownership.autoCollect(profile: any, forced: boolean?): boolean
	if forced == true then
		return true
	end
	if not Monetisation.passLive("autoCollect") then
		return false
	end
	return type(profile) == "table" and profile.autoCollect == true
end

function Ownership.cashMultiplier(profile: any, forced: number?): number
	if type(forced) == "number" and forced == forced and forced > 0 and forced < 1e6 and forced ~= math.huge then
		return forced
	end
	if type(profile) ~= "table" or profile.cashDouble ~= true then
		return 1
	end
	if not Monetisation.passLive("cashDouble") then
		return 1
	end
	return Return.CASH_DOUBLE_MULTIPLIER
end

return Ownership
