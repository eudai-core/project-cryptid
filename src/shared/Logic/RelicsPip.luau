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
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)

local RelicsPip = {}

local function ready(profile: any): boolean
	return type(profile) == "table" and type(profile.ui) == "table"
end

function RelicsPip.note(profile: any, speciesId: string): boolean
	if not ready(profile) then
		return false
	end
	if profile.ui.relicsPipShown == true or profile.ui.relicsPipCleared == true then
		return false
	end
	local species = Species.get(speciesId)
	if species == nil or species.rarity ~= "Rare" then
		return false
	end
	profile.ui.relicsPipShown = true
	return true
end

function RelicsPip.armExisting(profile: any)
	if not ready(profile) then
		return
	end
	if profile.ui.relicsPipShown == true or profile.ui.relicsPipCleared == true then
		return
	end
	for _, record in profile.cryptids do
		if type(record) == "table" and type(record.speciesId) == "string" then
			local species = Species.get(record.speciesId)
			if species ~= nil and species.rarity == "Rare" then
				profile.ui.relicsPipShown = true
				return
			end
		end
	end
end

function RelicsPip.clear(profile: any): boolean
	if not ready(profile) or profile.ui.relicsPipCleared == true then
		return false
	end
	profile.ui.relicsPipCleared = true
	return true
end

function RelicsPip.shouldShow(profile: any): boolean
	if not ready(profile) then
		return false
	end
	if profile.ui.relicsPipShown ~= true or profile.ui.relicsPipCleared == true then
		return false
	end
	return Monetisation.shopOpen(profile)
end

return RelicsPip
