--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Save = import("../Config/Save", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Save")
end)

local SaveGuard = {}

local function countMap(value: any): number
	if type(value) ~= "table" then
		return 0
	end
	local total = 0
	for _ in value do
		total += 1
	end
	return total
end

function SaveGuard.wiped(previous: any, incoming: any): boolean
	if type(previous) ~= "table" or type(incoming) ~= "table" then
		return false
	end
	local prevPads = previous.padsUnlocked
	local nextPads = incoming.padsUnlocked
	if
		type(prevPads) == "number"
		and type(nextPads) == "number"
		and prevPads > Save.WIPE_EMPTY_PADS
		and nextPads < prevPads
	then
		return true
	end
	local prevCryptids = countMap(previous.cryptids)
	local nextCryptids = countMap(incoming.cryptids)
	if prevCryptids > Save.WIPE_EMPTY_CRYPTIDS and nextCryptids == Save.WIPE_EMPTY_CRYPTIDS then
		return true
	end
	local prevCash = previous.cash
	local nextCash = incoming.cash
	local cashToEmpty = type(prevCash) == "number"
		and type(nextCash) == "number"
		and prevCash > Save.WIPE_EMPTY_CASH
		and nextCash == Save.WIPE_EMPTY_CASH
	if cashToEmpty and nextCryptids < prevCryptids then
		return true
	end
	return false
end

function SaveGuard.rejection(stored: any, incoming: any, rebirth: boolean): string?
	if type(incoming) ~= "table" then
		return "corrupt"
	end
	if type(stored) ~= "table" then
		return nil
	end
	local oldVersion = stored.dataVersion
	local newVersion = incoming.dataVersion
	if type(oldVersion) == "number" and type(newVersion) == "number" and newVersion < oldVersion then
		return "downgrade"
	end
	if rebirth ~= true and SaveGuard.wiped(stored, incoming) then
		return "wipe"
	end
	return nil
end

return SaveGuard
