--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Longship = import("./Longship", function()
	return script.Parent:WaitForChild("Longship")
end)
local WeepingWell = import("./WeepingWell", function()
	return script.Parent:WaitForChild("WeepingWell")
end)

local TownKits = {}

-- Future kits append here. TownBuilder keeps a single applyAll call.
local KITS = { Longship, WeepingWell }

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
