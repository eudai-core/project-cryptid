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
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local Ownership = import("./Ownership", function()
	return script.Parent:WaitForChild("Ownership")
end)

local Bundles = {}

function Bundles.prePassRate(profile: any): number
	local noPass = select(1, Ownership.leaveRates(profile))
	return noPass
end

function Bundles.amount(rate: number, key: string): number
	local spec = Monetisation.byKey(key)
	if spec == nil or spec.kind ~= "bundle" then
		return 0
	end
	local safe = rate
	if not Money.isFinite(safe) or safe < 0 then
		safe = 0
	end
	local scaled = Money.round(safe * spec.minutes * Monetisation.SECONDS_PER_MINUTE)
	if scaled < spec.minimum then
		return spec.minimum
	end
	return scaled
end

local function locked(profile: any, key: string, now: number): number?
	if type(profile) ~= "table" or type(profile.purchases) ~= "table" then
		return nil
	end
	local quotes = profile.purchases.quotes
	if type(quotes) ~= "table" then
		return nil
	end
	local quote = quotes[key]
	if type(quote) ~= "table" then
		return nil
	end
	if not Money.isFinite(quote.amount) or quote.amount < 0 then
		return nil
	end
	if not Money.isFinite(quote.expiresAt) or now >= quote.expiresAt then
		return nil
	end
	return quote.amount
end

function Bundles.grantAmount(profile: any, key: string, now: number, rate: number): number
	local current = Bundles.amount(rate, key)
	local quote = locked(profile, key, now)
	if quote ~= nil and quote > current then
		return quote
	end
	return current
end

function Bundles.lockQuote(profile: any, key: string, now: number, rate: number): number
	local current = Bundles.amount(rate, key)
	local quote = locked(profile, key, now)
	if quote ~= nil then
		return quote
	end
	profile.purchases.quotes[key] = {
		amount = current,
		expiresAt = now + Monetisation.QUOTE_LOCK_SECONDS,
	}
	return current
end

function Bundles.lockAll(profile: any, now: number, rate: number): boolean
	local changed = false
	for _, entry in Monetisation.items() do
		if entry.kind == "bundle" and entry.feature == true then
			local before = locked(profile, entry.key, now)
			Bundles.lockQuote(profile, entry.key, now, rate)
			if before == nil then
				changed = true
			end
		end
	end
	return changed
end

return Bundles
