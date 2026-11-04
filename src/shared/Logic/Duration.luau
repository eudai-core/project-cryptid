--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Return = import("../Config/Return", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Return")
end)

local Duration = {}

function Duration.phrase(seconds: number): string
	local whole = seconds
	if type(whole) ~= "number" or whole ~= whole or whole < 0 or whole == math.huge then
		whole = 0
	end
	whole = math.floor(whole)
	local hours = math.floor(whole / Return.SECONDS_PER_HOUR)
	local minutes = math.floor((whole % Return.SECONDS_PER_HOUR) / Return.SECONDS_PER_MINUTE)
	if hours > 0 then
		return tostring(hours) .. "h " .. tostring(minutes) .. "m"
	end
	if minutes > 0 then
		return tostring(minutes) .. "m"
	end
	return tostring(whole) .. "s"
end

return Duration
