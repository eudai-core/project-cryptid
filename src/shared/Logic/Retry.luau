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

local FATAL = {
	"cannot serialize",
	"cannot be serialized",
	"serialization",
	"value is too large",
	"value too large",
	"key name is too long",
	"key is too long",
	"key name too long",
	"invalid data",
	"malformed",
}

local Retry = {}

function Retry.backoffSeconds(attempt: number): number?
	if attempt >= Save.MAX_ATTEMPTS then
		return nil
	end
	return Save.BACKOFF_BASE_SECONDS * (2 ^ (attempt - 1))
end

function Retry.withJitter(base: number, roll: number): number
	local unit = roll
	if unit < 0 then
		unit = 0
	elseif unit > 1 then
		unit = 1
	end
	local offset = (unit * 2 - 1) * Save.BACKOFF_JITTER_RATIO
	local value = base * (1 + offset)
	if value < 0 then
		return 0
	end
	return value
end

function Retry.classify(message: string): string
	local lower = string.lower(message)
	for _, phrase in FATAL do
		if string.find(lower, phrase, 1, true) ~= nil then
			return "fatal"
		end
	end
	return "retryable"
end

return Retry
