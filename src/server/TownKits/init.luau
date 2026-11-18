--!strict
-- Kit contract. Adding a shop kit is one new file. Do not edit this module.
--
-- File: src/server/TownKits/<Name>.luau, a child of this TownKits module.
-- The file returns a table:
--   replace(townFolder, refs)  required. Builds the kit. refs.qualityLevel is 1..10.
--   name                       optional. Defaults to the module name. Used in warnings.
--   order                      optional number. Lower runs first. Default 0. Name breaks ties.
--   isKit                      optional. false skips the file (helpers such as Kit.luau).
-- A module with no replace function is not a kit. Kit.luau is never loaded as one.

local TownKits = {
	strict = false,
	forceQuality = nil :: number?,
}

local MODULE_SOURCE = debug.info(1, "s")
local EXTRA: { any } = {}

local function byOrder(a: any, b: any): boolean
	local aOrder = if type(a.order) == "number" then a.order else 0
	local bOrder = if type(b.order) == "number" then b.order else 0
	if aOrder ~= bOrder then
		return aOrder < bOrder
	end
	return tostring(a.name) < tostring(b.name)
end

local function accept(loaded: any, fallbackName: string): any
	if type(loaded) ~= "table" or type(loaded.replace) ~= "function" or loaded.isKit == false then
		return nil
	end
	if type(loaded.name) ~= "string" then
		loaded.name = fallbackName
	end
	return loaded
end

local function discoverLune(): { any }
	local fs = require("@lune/fs")
	local path = string.match(MODULE_SOURCE, '^%[string "(.*)"%]$') or MODULE_SOURCE
	local dir = string.match(path, "^(.*)/[^/]+$") or "src/server/TownKits"
	local found = {}
	for _, fileName in fs.readDir(dir) do
		if string.sub(fileName, -5) == ".luau" and fileName ~= "init.luau" then
			local stem = string.sub(fileName, 1, #fileName - 5)
			if stem ~= "Kit" then
				local kit = accept(require("./" .. stem), stem)
				if kit ~= nil then
					table.insert(found, kit)
				end
			end
		end
	end
	return found
end

local function discoverRoblox(): { any }
	local found = {}
	for _, child in script:GetChildren() do
		if child:IsA("ModuleScript") and child.Name ~= "Kit" then
			local kit = accept(require(child), child.Name)
			if kit ~= nil then
				table.insert(found, kit)
			end
		end
	end
	return found
end

function TownKits.discover(): { any }
	-- selene: allow(global_usage)
	local found = if _G.LUNE == true then discoverLune() else discoverRoblox()
	for _, extra in EXTRA do
		table.insert(found, extra)
	end
	table.sort(found, byOrder)
	return found
end

function TownKits._push(kit: any): () -> ()
	if type(kit.name) ~= "string" then
		kit.name = "kit"
	end
	table.insert(EXTRA, kit)
	return function()
		for index, item in EXTRA do
			if item == kit then
				table.remove(EXTRA, index)
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
	for _, kit in TownKits.discover() do
		local kitName = tostring(kit.name)
		local ok, result = xpcall(function()
			return kit.replace(townFolder, effective)
		end, debug.traceback)
		if ok then
			if result ~= nil then
				table.insert(reports, result)
			end
		else
			table.insert(failures, result)
			if type(warn) == "function" then
				warn("[TownKits] " .. kitName .. " failed: " .. tostring(result))
			end
			if TownKits.strict == true then
				error(kitName .. " failed: " .. tostring(result), 0)
			end
		end
	end
	return reports, failures
end

return TownKits
