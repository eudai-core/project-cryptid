--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local StudioDataStore = import("../Config/StudioDataStore", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("StudioDataStore")
end)

local StudioStore = {}

function StudioStore.isAccessDenied(message: string): boolean
	local lower = string.lower(message)
	for _, phrase in StudioDataStore.DENIED_MARKERS do
		if string.find(lower, phrase, 1, true) ~= nil then
			return true
		end
	end
	if string.find(lower, StudioDataStore.STUDIO_WORD, 1, true) == nil then
		return false
	end
	for _, phrase in StudioDataStore.STUDIO_CONTEXT_MARKERS do
		if string.find(lower, phrase, 1, true) ~= nil then
			return true
		end
	end
	return false
end

function StudioStore.preferMock(isStudio: boolean, placeId: number?, err: any): boolean
	if isStudio ~= true then
		return false
	end
	if placeId == StudioDataStore.UNPUBLISHED_PLACE_ID then
		return true
	end
	if err == nil then
		return false
	end
	return StudioStore.isAccessDenied(tostring(err))
end

return StudioStore
