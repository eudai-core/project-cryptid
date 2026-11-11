--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Monetisation = import("../Config/Monetisation", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Monetisation")
end)

local PolicyGate = {}

local cache: { [string]: string } = {}

function PolicyGate.reset()
	cache = {}
end

function PolicyGate.allows(userKey: string, fetch: () -> any, sleep: (number) -> ()): boolean
	local known = cache[userKey]
	if known == "allowed" then
		return true
	end
	if known == "restricted" then
		return false
	end
	local tries = Monetisation.POLICY_ATTEMPTS
	local waits = Monetisation.POLICY_BACKOFF
	for attempt = 1, tries do
		local ok, info = pcall(fetch)
		if ok and type(info) == "table" and info.ArePaidRandomItemsRestricted == false then
			cache[userKey] = "allowed"
			return true
		end
		if ok and type(info) == "table" and info.ArePaidRandomItemsRestricted == true then
			cache[userKey] = "restricted"
			return false
		end
		if attempt < tries then
			local pause = waits[attempt]
			if type(pause) == "number" and pause > 0 then
				sleep(pause)
			end
		end
	end
	return false
end

return PolicyGate
