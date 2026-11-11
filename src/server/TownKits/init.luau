--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

-- script is this TownKits module. Its parent is the service that owns the folder.
-- WaitForChild on that parent hangs: the kits are children of this module.
local function sibling(name: string): any
	return script:WaitForChild(name)
end

local Longship = import("./Longship", function()
	return sibling("Longship")
end)
local WeepingWell = import("./WeepingWell", function()
	return sibling("WeepingWell")
end)
local ApothecaryTree = import("./ApothecaryTree", function()
	return sibling("ApothecaryTree")
end)
local TarotTent = import("./TarotTent", function()
	return sibling("TarotTent")
end)

local TownKits = {}

-- Future kits append here. TownBuilder keeps a single applyAll call.
local KITS = { Longship, WeepingWell, ApothecaryTree, TarotTent }

function TownKits.applyAll(townFolder: Instance, refs: any)
	local reports = {}
	for _, kit in KITS do
		local report = kit.replace(townFolder, refs)
		if report ~= nil then
			table.insert(reports, report)
		end
	end
	return reports
end

return TownKits
