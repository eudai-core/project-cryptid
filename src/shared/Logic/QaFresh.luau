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
	return "_qafresh_"
end

function QaFresh.realKey(userId: number): string
	return Save.KEY_PREFIX .. tostring(userId)
end

function QaFresh.token(jobId: any, now: any): string
	if type(jobId) == "string" and jobId ~= "" then
		return jobId
	end
	local stamp = now
	if type(stamp) ~= "number" or stamp ~= stamp or stamp < 0 or stamp == math.huge then
		stamp = 0
	end
	return tostring(math.floor(stamp))
end

function QaFresh.profileKey(userId: number, freshToken: string?): string
	local base = QaFresh.realKey(userId)
	if type(freshToken) ~= "string" or freshToken == "" then
		return base
	end
	return base .. QaFresh.mark() .. freshToken
end

function QaFresh.sessionKey(userId: number, isStudio: boolean, args: any, jobId: any, now: any): string
	if QaArgs.wantsFresh(isStudio, args) ~= true then
		return QaFresh.realKey(userId)
	end
	return QaFresh.profileKey(userId, QaFresh.token(jobId, now))
end

return QaFresh
