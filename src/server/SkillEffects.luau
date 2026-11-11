--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Core = import("../shared/Logic/SkillEffects", function()
	return game:GetService("ReplicatedStorage")
		:WaitForChild("Shared")
		:WaitForChild("Logic")
		:WaitForChild("SkillEffects")
end)

local SkillEffects = {}

function SkillEffects.skillIncome(profile: any): number
	return Core.skillIncome(profile)
end

function SkillEffects.wildIncome(profile: any): number
	return Core.wildIncome(profile)
end

function SkillEffects.altarPerLevel(profile: any): number
	return Core.altarPerLevel(profile)
end

function SkillEffects.altarMultiplier(profile: any): number
	return Core.altarMultiplier(profile)
end

function SkillEffects.catchSeconds(profile: any): number
	return Core.catchSeconds(profile)
end

function SkillEffects.catchRange(profile: any): number
	return Core.catchRange(profile)
end

function SkillEffects.padCost(profile: any, index: number): number?
	return Core.padCost(profile, index)
end

return SkillEffects
