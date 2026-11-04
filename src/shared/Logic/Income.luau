--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
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

function Income.multiplier(altarLevel: number): number
	local level = altarLevel
	if level < 0 then
		level = 0
	end
	if level > Economy.MAX_ALTAR_LEVEL then
		level = Economy.MAX_ALTAR_LEVEL
	end
	return 1 + Economy.ALTAR_BONUS_PER_LEVEL * level
end

function Income.contribution(speciesId: string, altarLevel: number, perLevel: number?, skillIncome: number?): number
	local species = Species.get(speciesId)
	if species == nil then
		return 0
	end
	local level = altarLevel
	if level < 0 then
		level = 0
	end
	if level > Economy.MAX_ALTAR_LEVEL then
		level = Economy.MAX_ALTAR_LEVEL
	end
	local rate = Economy.ALTAR_BONUS_PER_LEVEL
	if type(perLevel) == "number" then
		rate = perLevel
	end
	local skill = 0
	if type(skillIncome) == "number" then
		skill = skillIncome
	end
	return Money.round(species.baseIncome * (1 + rate * level) * (1 + skill))
end

function Income.perSecond(profile: any): number
	local altar = SkillEffects.altarMultiplier(profile)
	local skill = SkillEffects.skillIncome(profile)
	local wild = SkillEffects.wildIncome(profile)
	local total = 0
	for index = 1, profile.padsUnlocked do
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
	return Money.round(total)
end

return Income
