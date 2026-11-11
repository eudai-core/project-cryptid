--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local BoneAltar = import("../Config/BoneAltar", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("BoneAltar")
end)
local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
end)
local SkillConfig = import("../Config/SkillConfig", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("SkillConfig")
end)

local SkillEffects = {}

local function sumKind(profile: any, kind: string): number
	if type(profile) ~= "table" or type(profile.skills) ~= "table" then
		return 0
	end
	local total = 0
	for index = 1, #profile.skills do
		local node = SkillConfig.get(profile.skills[index])
		if node ~= nil and node.sealed ~= true and node.effect.kind == kind then
			total += node.effect.value
		end
	end
	return total
end

function SkillEffects.skillIncome(profile: any): number
	return sumKind(profile, "income")
end

function SkillEffects.wildIncome(profile: any): number
	return sumKind(profile, "wildIncome")
end

function SkillEffects.altarPerLevel(profile: any): number
	local devoted = sumKind(profile, "altarPerLevel")
	if devoted > 0 then
		return devoted
	end
	return Economy.ALTAR_BONUS_PER_LEVEL
end

function SkillEffects.altarMultiplier(profile: any): number
	local level = 0
	if type(profile) == "table" and type(profile.upgrades) == "table" then
		local raw = profile.upgrades.boneAltar
		if type(raw) == "number" then
			level = raw
		end
	end
	if level < 0 then
		level = 0
	end
	if level > Economy.MAX_ALTAR_LEVEL then
		level = Economy.MAX_ALTAR_LEVEL
	end
	return 1 + SkillEffects.altarPerLevel(profile) * level
end

function SkillEffects.catchSeconds(profile: any): number
	local time = Economy.CATCH_SECONDS * (1 - sumKind(profile, "catchTime"))
	if time < SkillConfig.CATCH_TIME_MIN then
		return SkillConfig.CATCH_TIME_MIN
	end
	return time
end

function SkillEffects.catchRange(profile: any): number
	return Economy.CATCH_DISTANCE_STUDS + sumKind(profile, "catchRange")
end

function SkillEffects.padCost(profile: any, index: number): number?
	local base = Economy.padCost(index, BoneAltar.rebirths(profile))
	if type(base) ~= "number" then
		return nil
	end
	local discount = sumKind(profile, "padCost")
	if discount <= 0 then
		return base
	end
	return math.round(base * (1 - discount))
end

return SkillEffects
