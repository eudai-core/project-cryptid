--!strict

-- Studio-only throwaway profile key. The real `player_<userId>` key is never
-- read or written when `qa:<seconds>:fresh` is set. Outside Studio the suffix
-- is ignored and the normal key is used.

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
local QaArgs = import("./QaArgs", function()
	return script.Parent:WaitForChild("QaArgs")
end)

local QaFresh = {}

function QaFresh.mark(): string
	return "_qf_"
end

function QaFresh.realKey(userId: number): string
	return Save.KEY_PREFIX .. tostring(userId)
end

function QaFresh.token(material: any): string
	if type(material) ~= "string" or material == "" then
		return ""
	end
	local stripped = string.gsub(material, "[^%x]", "")
	if #stripped < 12 then
		return ""
	end
	return string.lower(string.sub(stripped, 1, 12))
end

function QaFresh.profileKey(userId: number, freshToken: string?): string
	local base = QaFresh.realKey(userId)
	local token = QaFresh.token(freshToken)
	if #token ~= 12 then
		token = "000000000000"
	end
	return base .. QaFresh.mark() .. token
end

function QaFresh.sessionKey(userId: number, isStudio: boolean, args: any, guid: any, _now: any): string
	if QaArgs.wantsFresh(isStudio, args) ~= true then
		return QaFresh.realKey(userId)
	end
	return QaFresh.profileKey(userId, if type(guid) == "string" then guid else "")
end

return QaFresh
