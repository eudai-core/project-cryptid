--!strict

-- The shipped flag stays off. A Studio playtest arg may turn the framework on
-- for that session only. A live server ignores the arg.

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local QaArgs = import("./QaArgs", function()
	return script.Parent:WaitForChild("QaArgs")
end)

local TarotAccess = {}

function TarotAccess.enabled(flag: any, isStudio: any, args: any): boolean
	if flag == true then
		return true
	end
	if isStudio ~= true then
		return false
	end
	return QaArgs.parse(args).tarotPaid == true
end

return TarotAccess
