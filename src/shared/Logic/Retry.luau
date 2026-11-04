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

local Retry = {}

function Retry.backoffSeconds(attempt: number): number?
	if attempt >= Save.MAX_ATTEMPTS then
		return nil
	end
	return Save.BACKOFF_BASE_SECONDS * (2 ^ (attempt - 1))
end

return Retry
