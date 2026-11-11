--!strict

-- Spec 11 §6. Rates are tokens per second. Burst capacity is one second of
-- tokens, so a same-instant burst cannot exceed the per-second rate (QA 14).
-- A flood is one excess burst. Three of those inside the window silence every
-- remote for that player. The spec never kicks for remote spam.

local RateLimit = {
	CHANNEL_START_PER_SECOND = 4,
	LIKE_PER_SECOND = 1,
	STEAL_PER_SECOND = 1,
	DEFAULT_PER_SECOND = 10,
	BURST_SECONDS = 1,
	FLOODS_BEFORE_IGNORE = 3,
	FLOOD_WINDOW_SECONDS = 60,
	IGNORE_SECONDS = 30,
	TOKENS_PER_CALL = 1,
	TOKEN_EPSILON = 1e-6,
	DENIED_ERROR = "rate_limited",
}

local SPECIAL_RATE = table.freeze({
	RequestStartChannel = RateLimit.CHANNEL_START_PER_SECOND,
	RequestLike = RateLimit.LIKE_PER_SECOND,
	RequestSteal = RateLimit.STEAL_PER_SECOND,
})

function RateLimit.perSecond(remoteName: string): number
	local special = SPECIAL_RATE[remoteName]
	if special ~= nil then
		return special
	end
	return RateLimit.DEFAULT_PER_SECOND
end

function RateLimit.capacity(remoteName: string): number
	return RateLimit.perSecond(remoteName) * RateLimit.BURST_SECONDS
end

function RateLimit.specialNames(): { string }
	local names = {}
	for name in SPECIAL_RATE do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

return table.freeze(RateLimit)
