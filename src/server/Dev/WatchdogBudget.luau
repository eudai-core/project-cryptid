--!strict

-- Seconds for a bot playtest started with args `qa:<seconds>`.
-- The ops guide defaults a missing number to 300 and does not name a range.
-- 0 is raised to 1 so a typo cannot end the session before the bridge reconnects.
-- Values above 30 minutes are capped so a bad argument cannot hold Studio open overnight.

local WatchdogBudget = {
	DEFAULT_SECONDS = 300,
	MIN_SECONDS = 1,
	MAX_SECONDS = 1800,
}

function WatchdogBudget.secondsFor(args: any): number?
	if type(args) ~= "string" or string.sub(args, 1, 3) ~= "qa:" then
		return nil
	end
	local parsed = tonumber(string.match(args, "^qa:(%d+)"))
	if parsed == nil or parsed ~= parsed or parsed == math.huge then
		return WatchdogBudget.DEFAULT_SECONDS
	end
	local seconds = math.floor(parsed)
	if seconds < WatchdogBudget.MIN_SECONDS then
		return WatchdogBudget.MIN_SECONDS
	end
	if seconds > WatchdogBudget.MAX_SECONDS then
		return WatchdogBudget.MAX_SECONDS
	end
	return seconds
end

return WatchdogBudget
