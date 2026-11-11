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

local TownKits = {
	strict = false,
	forceQuality = nil :: number?,
}

-- Future kits append here. TownBuilder keeps a single applyAll call.
local KITS = { Longship }

function TownKits._push(kit: any): () -> ()
	table.insert(KITS, kit)
	return function()
		for index, item in KITS do
			if item == kit then
				table.remove(KITS, index)
				return
			end
		end
	end
end

function TownKits.applyAll(townFolder: Instance, refs: any)
	local effective = {}
	if type(refs) == "table" then
		for key, value in refs do
			effective[key] = value
		end
	end
	if effective.qualityLevel == nil and type(TownKits.forceQuality) == "number" then
		effective.qualityLevel = TownKits.forceQuality
	end
	local reports = {}
	local failures = {}
	for _, kit in KITS do
		local ok, result = xpcall(function()
			return kit.replace(townFolder, effective)
		end, debug.traceback)
		if ok then
			if result ~= nil then
				table.insert(reports, result)
			end
		else
			table.insert(failures, result)
			if TownKits.strict == true then
				error(result, 0)
			end
			if type(warn) == "function" then
				warn("[TownKits] " .. tostring(result))
			end
		end
	end
	return reports, failures
end

return TownKits
