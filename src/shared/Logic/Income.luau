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
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local ProfileQuery = import("./ProfileQuery", function()
	return script.Parent:WaitForChild("ProfileQuery")
end)

local Income = {}

function Income.multiplier(altarLevel: number, l3: boolean?): number
	return BoneAltar.multiplier(altarLevel, l3 == true)
end

function Income.contribution(speciesId: string, altarLevel: number, l3: boolean?): number
	local species = Species.get(speciesId)
	if species == nil then
		return 0
	end
	return Money.round(species.baseIncome * Income.multiplier(altarLevel, l3 == true))
end

function Income.perSecond(profile: any): number
	local base = 0
	for index = 1, profile.padsUnlocked do
		local instanceId = ProfileQuery.padAt(profile, index)
		if instanceId ~= nil then
			local record = profile.cryptids[instanceId]
			if record ~= nil then
				local species = Species.get(record.speciesId)
				if species ~= nil then
					base += species.baseIncome
				end
			end
		end
	end
	return Money.round(base * Income.multiplier(profile.upgrades.boneAltar, BoneAltar.l3Owned(profile)))
end

return Income
