--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local RateLimit = import("../shared/Config/RateLimit", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("RateLimit")
end)

export type Decision = {
	allowed: boolean,
	error: string?,
	ignored: boolean,
	floodMarked: boolean,
}

type Bucket = {
	tokens: number,
	updatedAt: number,
}

type State = {
	buckets: { [string]: Bucket },
	floods: { number },
	openFlood: { [string]: boolean },
	ignoreUntil: number?,
}

local records: { [number]: State } = {}

local function defaultLog(message: string)
	warn(message)
end

local logger: (string) -> () = defaultLog

local RateLimiter = {}

local function blank(): State
	return {
		buckets = {},
		floods = {},
		openFlood = {},
		ignoreUntil = nil,
	}
end

local function log(playerKey: number, remoteName: string, kind: string)
	logger(string.format("[Cryptid:RateLimit] %s %s player %s", kind, remoteName, tostring(playerKey)))
end

local function logIgnore(playerKey: number)
	logger(
		string.format(
			"[Cryptid:RateLimit] player %s remotes ignored for %s s after %s floods",
			tostring(playerKey),
			tostring(RateLimit.IGNORE_SECONDS),
			tostring(RateLimit.FLOODS_BEFORE_IGNORE)
		)
	)
end

local function allow(): Decision
	return {
		allowed = true,
		error = nil,
		ignored = false,
		floodMarked = false,
	}
end

local function deny(ignored: boolean, floodMarked: boolean): Decision
	return {
		allowed = false,
		error = RateLimit.DENIED_ERROR,
		ignored = ignored,
		floodMarked = floodMarked,
	}
end

local function silenced(state: State, now: number): boolean
	local untilAt = state.ignoreUntil
	return untilAt ~= nil and now < untilAt
end

local function hasToken(tokens: number): boolean
	return tokens + RateLimit.TOKEN_EPSILON >= RateLimit.TOKENS_PER_CALL
end

local function refill(bucket: Bucket, now: number, perSecond: number, capacity: number)
	local elapsed = now - bucket.updatedAt
	if elapsed <= RateLimit.TOKEN_EPSILON then
		return
	end
	bucket.tokens += elapsed * perSecond
	if bucket.tokens > capacity then
		bucket.tokens = capacity
	end
	bucket.updatedAt = now
end

-- One flood mark per excess burst. Later drops in that same burst are logged
-- and do not add marks, so a single burst cannot reach the ignore threshold.
local function rememberFlood(state: State, now: number): boolean
	local kept: { number } = {}
	for _, at in state.floods do
		if now - at <= RateLimit.FLOOD_WINDOW_SECONDS then
			table.insert(kept, at)
		end
	end
	table.insert(kept, now)
	state.floods = kept
	if #kept < RateLimit.FLOODS_BEFORE_IGNORE then
		return false
	end
	state.ignoreUntil = now + RateLimit.IGNORE_SECONDS
	state.floods = {}
	state.openFlood = {}
	return true
end

function RateLimiter.consume(playerKey: number, remoteName: string, now: number): Decision
	local state = records[playerKey]
	if state == nil then
		state = blank()
		records[playerKey] = state
	end
	local perSecond = RateLimit.perSecond(remoteName)
	local capacity = RateLimit.capacity(remoteName)
	local bucket = state.buckets[remoteName]
	if bucket == nil then
		bucket = {
			tokens = capacity,
			updatedAt = now,
		}
		state.buckets[remoteName] = bucket
	else
		refill(bucket, now, perSecond, capacity)
	end
	if silenced(state, now) then
		log(playerKey, remoteName, "ignored")
		return deny(true, false)
	end
	if hasToken(bucket.tokens) then
		bucket.tokens -= RateLimit.TOKENS_PER_CALL
		state.openFlood[remoteName] = nil
		return allow()
	end
	local marked = false
	local startedIgnore = false
	if state.openFlood[remoteName] ~= true then
		state.openFlood[remoteName] = true
		marked = true
		startedIgnore = rememberFlood(state, now)
	end
	if startedIgnore then
		logIgnore(playerKey)
	end
	log(playerKey, remoteName, "flood")
	return deny(startedIgnore, marked)
end

function RateLimiter.rejected(): { ok: boolean, error: string }
	return {
		ok = false,
		error = RateLimit.DENIED_ERROR,
	}
end

function RateLimiter.forget(playerKey: number)
	records[playerKey] = nil
end

function RateLimiter.setLogger(sink: (string) -> ())
	logger = sink
end

function RateLimiter.reset()
	table.clear(records)
	logger = defaultLog
end

return RateLimiter
