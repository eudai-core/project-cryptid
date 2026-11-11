--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

-- This file is the TownKits module. Sibling kit modules are its children, not
-- siblings under ServerScriptService.
local Longship = import("./Longship", function()
	return script:WaitForChild("Longship")
end)
local WeepingWell = import("./WeepingWell", function()
	return script:WaitForChild("WeepingWell")
end)
local ApothecaryTree = import("./ApothecaryTree", function()
	return script:WaitForChild("ApothecaryTree")
end)

local TownKits = {}

-- Future kits append here. TownBuilder keeps a single applyAll call.
local KITS = { Longship, WeepingWell, ApothecaryTree }

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
