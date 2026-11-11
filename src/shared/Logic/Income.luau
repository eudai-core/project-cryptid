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
local Monetisation = import("../Config/Monetisation", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Monetisation")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local ProfileQuery = import("./ProfileQuery", function()
	return script.Parent:WaitForChild("ProfileQuery")
end)
local SkillEffects = import("./SkillEffects", function()
	return script.Parent:WaitForChild("SkillEffects")
end)

local Income = {}

function Income.multiplier(altarLevel: number, l3: boolean?): number
	return BoneAltar.multiplier(altarLevel, l3 == true)
end

function Income.contribution(
	speciesId: string,
	altarLevel: number,
	altarArg: number | boolean | nil,
	skillIncome: number?
): number
	local species = Species.get(speciesId)
	if species == nil then
		return 0
	end
	local skill = 0
	if type(skillIncome) == "number" then
		skill = skillIncome
	end
	local altar
	if type(altarArg) == "number" then
		local level = altarLevel
		if type(level) ~= "number" or level < 0 then
			level = 0
		end
		if level > BoneAltar.MAX_LEVEL then
			level = BoneAltar.MAX_LEVEL
		end
		level = math.floor(level)
		altar = 1 + altarArg * level
	else
		altar = Income.multiplier(altarLevel, altarArg == true)
	end
	return Money.round(species.baseIncome * altar * (1 + skill))
end

local function accrue(profile: any, includeRelic: boolean): number
	local unlocked = profile.padsUnlocked
	if type(unlocked) ~= "number" then
		return 0
	end
	local altar = Income.multiplier(profile.upgrades.boneAltar, BoneAltar.l3Owned(profile))
	local skill = SkillEffects.skillIncome(profile)
	local wild = SkillEffects.wildIncome(profile)
	local total = 0
	for index = 1, unlocked do
		if includeRelic or not Monetisation.isRelicPad(index) then
			local instanceId = ProfileQuery.padAt(profile, index)
			if instanceId ~= nil then
				local record = profile.cryptids[instanceId]
				if record ~= nil then
					local species = Species.get(record.speciesId)
					if species ~= nil then
						local factor = 1 + skill
						if record.source == "wild" then
							factor += wild
						end
						total += species.baseIncome * altar * factor
					end
				end
			end
		end
	end
	return Money.round(total)
end

function Income.perSecond(profile: any): number
	return accrue(profile, true)
end

function Income.tithePerSecond(profile: any): number
	return accrue(profile, false)
end

return Income
