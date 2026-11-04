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
local Income = import("./Income", function()
	return script.Parent:WaitForChild("Income")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local Transactions = import("./Transactions", function()
	return script.Parent:WaitForChild("Transactions")
end)

local Daily = {}

local function clockOf(unix: any): number
	if type(unix) ~= "number" or unix ~= unix or unix < 0 or unix == math.huge then
		return 0
	end
	return unix
end

function Daily.dayNumber(unix: any): number
	return math.floor(clockOf(unix) / Return.DAY_SECONDS)
end

function Daily.nextReset(unix: any): number
	return (Daily.dayNumber(unix) + 1) * Return.DAY_SECONDS
end

function Daily.ready(profile: any, unix: any): boolean
	return profile.daily.lastClaimDay < Daily.dayNumber(unix)
end

function Daily.missed(profile: any, unix: any): boolean
	if profile.daily.lastClaimDay < 0 then
		return false
	end
	return Daily.dayNumber(unix) - profile.daily.lastClaimDay > 1
end

function Daily.offerButton(profile: any): boolean
	return profile.onboarding.step >= Return.GATE_STEP and profile.onboarding.playSeconds >= Return.BUTTON_PLAY_SECONDS
end

function Daily.shouldAutoOpen(eligibleAtJoin: boolean, ready: boolean): boolean
	return eligibleAtJoin == true and ready == true
end

function Daily.cashFor(step: number, rate: any): number
	local spec = Return.STEPS[step]
	if spec == nil or spec.minutes <= 0 then
		return 0
	end
	local safe = rate
	if type(safe) ~= "number" or safe ~= safe or safe < 0 or safe == math.huge then
		safe = 0
	end
	local scaled = math.floor(safe * spec.minutes * Return.SECONDS_PER_MINUTE)
	if scaled < spec.floor then
		return spec.floor
	end
	return scaled
end

function Daily.preview(step: number, rate: any): any
	local spec = Return.STEPS[step]
	if spec == nil then
		return nil
	end
	local speciesId = spec.speciesId or ""
	local species = if speciesId ~= "" then Species.get(speciesId) else nil
	return {
		step = step,
		cash = Daily.cashFor(step, rate),
		minutes = spec.minutes,
		speciesId = speciesId,
		displayName = if species ~= nil then species.displayName else "",
	}
end

function Daily.claim(profile: any, unix: any, makeId: () -> string): (boolean, string)
	if not Daily.ready(profile, unix) then
		return false, "claimed"
	end
	local step = profile.daily.step
	local spec = Return.STEPS[step]
	if spec == nil then
		return false, "step"
	end
	local cash = Daily.cashFor(step, Income.perSecond(profile))
	if spec.speciesId ~= nil then
		local id = makeId()
		if type(id) ~= "string" then
			return false, "id"
		end
		local granted, reason = Transactions.grantOffering(profile, spec.speciesId, clockOf(unix), id)
		if not granted then
			return false, reason
		end
	end
	if cash > 0 then
		profile.cash = Money.round(profile.cash + cash)
		profile.totalEarned = Money.round(profile.totalEarned + cash)
	end
	profile.daily.lastClaimDay = Daily.dayNumber(unix)
	profile.daily.totalClaims += 1
	local nextStep = step + 1
	if nextStep > Return.LADDER_STEPS then
		nextStep = 1
	end
	profile.daily.step = nextStep
	return true, "ok"
end

return Daily
