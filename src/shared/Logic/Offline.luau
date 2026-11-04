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
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local Ownership = import("./Ownership", function()
	return script.Parent:WaitForChild("Ownership")
end)

local Offline = {}

local function nonNegative(value: any): number
	if type(value) ~= "number" or value ~= value or value < 0 or value == math.huge then
		return 0
	end
	return value
end

function Offline.capture(profile: any, forcedCash: number?)
	local noPass, withPass = Ownership.leaveRates(profile, forcedCash)
	profile.offline.rateNoPass = noPass
	profile.offline.rate = withPass
end

function Offline.amount(rate: any, awaySeconds: any): (number, boolean)
	local away = nonNegative(awaySeconds)
	local rateValue = nonNegative(rate)
	local capped = away > Return.CAP_SECONDS
	local elapsed = away
	if elapsed > Return.CAP_SECONDS then
		elapsed = Return.CAP_SECONDS
	end
	if elapsed < Return.MIN_AWAY_SECONDS then
		return 0, capped
	end
	local haul = math.floor(rateValue * Return.EFFICIENCY * elapsed)
	if haul < 0 then
		haul = 0
	end
	return haul, capped
end

function Offline.shows(haul: number, awaySeconds: any): boolean
	return haul >= Return.SCREEN_MIN_HAUL and nonNegative(awaySeconds) >= Return.SCREEN_AWAY_SECONDS
end

function Offline.fold(
	profile: any,
	now: number
): { changed: boolean, show: boolean, haul: number, tithe: number, granted: number }
	local clock = nonNegative(now)
	local away = clock - nonNegative(profile.lastSeenUnix)
	if away < 0 or away ~= away then
		away = 0
	end
	local haul = 0
	local tithe = 0
	local capped = false
	if profile.onboarding.step >= Return.GATE_STEP then
		haul, capped = Offline.amount(profile.offline.rate, away)
		tithe = Offline.amount(profile.offline.rateNoPass, away)
	end
	profile.lastSeenUnix = math.floor(clock)
	if haul <= 0 then
		return {
			changed = false,
			show = false,
			haul = 0,
			tithe = 0,
			granted = 0,
		}
	end
	if Offline.shows(haul, away) then
		profile.offline.pending = Money.round(profile.offline.pending + haul)
		profile.offline.pendingTithe = Money.round(profile.offline.pendingTithe + tithe)
		profile.offline.awaySeconds = math.floor(away)
		profile.offline.capped = capped
		return {
			changed = true,
			show = true,
			haul = haul,
			tithe = tithe,
			granted = 0,
		}
	end
	profile.cash = Money.round(profile.cash + haul)
	profile.totalEarned = Money.round(profile.totalEarned + haul)
	profile.tithe = Money.round(profile.tithe + tithe)
	profile.offline.notice = haul
	return {
		changed = true,
		show = false,
		haul = haul,
		tithe = tithe,
		granted = haul,
	}
end

function Offline.claim(profile: any): (number, number)
	local amount = profile.offline.pending
	local tithe = profile.offline.pendingTithe
	if type(amount) ~= "number" or amount ~= amount or amount <= 0 then
		return 0, 0
	end
	if type(tithe) ~= "number" or tithe ~= tithe or tithe < 0 then
		tithe = 0
	end
	profile.offline.pending = 0
	profile.offline.pendingTithe = 0
	profile.offline.awaySeconds = 0
	profile.offline.capped = false
	profile.cash = Money.round(profile.cash + amount)
	profile.totalEarned = Money.round(profile.totalEarned + amount)
	profile.tithe = Money.round(profile.tithe + tithe)
	return amount, tithe
end

return Offline
