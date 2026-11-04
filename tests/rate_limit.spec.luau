--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local Check = require("./check")
local Economy = require("../src/shared/Config/Economy")
local Names = require("../src/shared/Config/Remotes")
local RateLimit = require("../src/shared/Config/RateLimit")
local RateLimiter = require("../src/server/RateLimiter")

local GUARD = "src/server/RemoteGuard.luau"
local LIMITER = "src/server/RateLimiter.luau"
local CREATOR = "src/server/Remotes.luau"
local SESSION = "src/server/PlayerSession.luau"
local PLAYER = 41
local OTHER = 42

local function begin(): { string }
	RateLimiter.reset()
	local logs = {}
	RateLimiter.setLogger(function(message: string)
		table.insert(logs, message)
	end)
	return logs
end

local function joined(logs: { string }): string
	return table.concat(logs, "\n")
end

local function liveNames(): { string }
	local names = {}
	for key, value in Names do
		if key ~= "FOLDER" then
			Check.eq(type(value), "string", key)
			table.insert(names, value)
		end
	end
	table.sort(names)
	return names
end

local function everyName(): { string }
	local names = liveNames()
	local seen = {}
	for _, name in names do
		seen[name] = true
	end
	for _, name in RateLimit.specialNames() do
		if seen[name] ~= true then
			table.insert(names, name)
		end
	end
	table.sort(names)
	return names
end

local function count(text: string, needle: string): number
	local found = 0
	local startAt = 1
	while true do
		local at = string.find(text, needle, startAt, true)
		if at == nil then
			return found
		end
		found += 1
		startAt = at + #needle
	end
end

local function walk(dir: string, files: { string })
	for _, name in fs.readDir(dir) do
		local path = dir .. "/" .. name
		if fs.isDir(path) then
			walk(path, files)
		elseif string.match(name, "%.luau$") ~= nil then
			table.insert(files, path)
		end
	end
end

local function flood(player: number, remoteName: string, now: number): any
	local opened = RateLimiter.consume(player, remoteName, now)
	local dropped = RateLimiter.consume(player, remoteName, now)
	return opened, dropped
end

Check.test("spec 11 rates, burst, and the typed denial", function()
	Check.eq(RateLimit.CHANNEL_START_PER_SECOND, 4)
	Check.eq(RateLimit.LIKE_PER_SECOND, 1)
	Check.eq(RateLimit.STEAL_PER_SECOND, 1)
	Check.eq(RateLimit.DEFAULT_PER_SECOND, 10)
	Check.eq(RateLimit.BURST_SECONDS, 1)
	Check.eq(RateLimit.FLOODS_BEFORE_IGNORE, 3)
	Check.eq(RateLimit.FLOOD_WINDOW_SECONDS, 60)
	Check.eq(RateLimit.IGNORE_SECONDS, 30)
	Check.eq(RateLimit.DENIED_ERROR, "rate_limited")
	Check.eq(RateLimit.perSecond("RequestStartChannel"), RateLimit.CHANNEL_START_PER_SECOND)
	Check.eq(RateLimit.perSecond("RequestLike"), RateLimit.LIKE_PER_SECOND)
	Check.eq(RateLimit.perSecond("RequestSteal"), RateLimit.STEAL_PER_SECOND)
	Check.eq(RateLimit.capacity("RequestLike"), RateLimit.LIKE_PER_SECOND * RateLimit.BURST_SECONDS)
	Check.eq(RateLimit.perSecond("RequestCancelChannel"), RateLimit.DEFAULT_PER_SECOND)
	Check.eq(RateLimit.perSecond("RequestSetSanctuary"), RateLimit.DEFAULT_PER_SECOND)
	for _, name in liveNames() do
		Check.eq(RateLimit.perSecond(name), RateLimit.DEFAULT_PER_SECOND, name)
	end
	local rejected = RateLimiter.rejected()
	Check.eq(rejected.ok, false)
	Check.eq(rejected.error, "rate_limited")
end)

Check.test("a full bucket is served and the next call is dropped", function()
	begin()
	for _, name in everyName() do
		RateLimiter.forget(PLAYER)
		local capacity = RateLimit.capacity(name)
		for _ = 1, capacity do
			local decision = RateLimiter.consume(PLAYER, name, 0)
			Check.eq(decision.allowed, true, name)
			Check.eq(decision.error, nil, name)
		end
		local overflow = RateLimiter.consume(PLAYER, name, 0)
		Check.eq(overflow.allowed, false, name)
		Check.eq(overflow.error, "rate_limited", name)
		Check.eq(overflow.ignored, false, name)
		Check.eq(overflow.floodMarked, true, name)
	end
end)

Check.test("the bucket refills at the published rate and a backwards clock grants nothing", function()
	begin()
	local name = "RequestBuyRift"
	local perSecond = RateLimit.perSecond(name)
	local capacity = RateLimit.capacity(name)
	for _ = 1, capacity do
		Check.eq(RateLimiter.consume(PLAYER, name, 0).allowed, true)
	end
	Check.eq(RateLimiter.consume(PLAYER, name, 0).allowed, false)
	local step = RateLimit.TOKENS_PER_CALL / perSecond
	local partial = step / 2
	Check.eq(RateLimiter.consume(PLAYER, name, partial).allowed, false)
	Check.eq(RateLimiter.consume(PLAYER, name, step).allowed, true)

	RateLimiter.forget(PLAYER)
	for _ = 1, capacity do
		Check.eq(RateLimiter.consume(PLAYER, name, 0).allowed, true)
	end
	local recovered = perSecond / 2
	local at = recovered / perSecond
	for _ = 1, recovered do
		Check.eq(RateLimiter.consume(PLAYER, name, at).allowed, true)
	end
	Check.eq(RateLimiter.consume(PLAYER, name, at).allowed, false)

	RateLimiter.forget(PLAYER)
	for _ = 1, capacity do
		Check.eq(RateLimiter.consume(PLAYER, name, 5).allowed, true)
	end
	local backwards = RateLimiter.consume(PLAYER, name, 4)
	Check.eq(backwards.allowed, false)
	Check.eq(RateLimiter.consume(PLAYER, name, 5 + step).allowed, true)
end)

Check.test("buckets are isolated per player and per remote", function()
	begin()
	local like = "RequestLike"
	local buy = "RequestBuyRift"
	local opened, dropped = flood(PLAYER, like, 0)
	Check.eq(opened.allowed, true)
	Check.eq(dropped.allowed, false)
	Check.eq(RateLimiter.consume(OTHER, like, 0).allowed, true)
	Check.eq(RateLimiter.consume(PLAYER, like, 0).allowed, false)
	local capacity = RateLimit.capacity(buy)
	for _ = 1, capacity do
		Check.eq(RateLimiter.consume(PLAYER, buy, 0).allowed, true)
	end
	Check.eq(RateLimiter.consume(PLAYER, buy, 0).allowed, false)
	Check.eq(RateLimiter.consume(PLAYER, "RequestClaimDaily", 0).allowed, true)
	Check.eq(RateLimiter.consume(OTHER, buy, 0).allowed, true)
end)

Check.test("QA14 100 RequestLike calls in one second process one and log one flood", function()
	local logs = begin()
	local allowed = 0
	local floods = 0
	for _ = 1, 100 do
		local decision = RateLimiter.consume(PLAYER, "RequestLike", 0)
		if decision.allowed then
			allowed += 1
		end
		if decision.floodMarked then
			floods += 1
		end
		Check.eq(decision.ignored, false)
	end
	Check.eq(allowed, 1)
	Check.eq(floods, 1)
	local text = joined(logs)
	Check.contains(text, "flood")
	Check.contains(text, "RequestLike")
	Check.eq(string.find(text, "ignored", 1, true), nil)
	Check.eq(string.find(text, "Kick", 1, true), nil)
	local later = RateLimiter.consume(PLAYER, "RequestLike", RateLimit.BURST_SECONDS)
	Check.eq(later.allowed, true)
	Check.eq(later.ignored, false)
end)

Check.test("100 RequestLike calls spread across the same second still process one", function()
	begin()
	local calls = 100
	local span = RateLimit.BURST_SECONDS / 2
	local allowed = 0
	for index = 0, calls - 1 do
		local now = (index / (calls - 1)) * span
		local decision = RateLimiter.consume(PLAYER, "RequestLike", now)
		if decision.allowed then
			allowed += 1
		end
		Check.eq(decision.ignored, false)
	end
	Check.eq(allowed, 1)
end)

Check.test("three floods inside 60s ignore every remote for 30s and one burst does not", function()
	local logs = begin()
	local like = "RequestLike"
	local _, first = flood(PLAYER, like, 0)
	local _, second = flood(PLAYER, like, RateLimit.FLOOD_WINDOW_SECONDS / 2)
	Check.eq(first.floodMarked, true)
	Check.eq(first.ignored, false)
	Check.eq(second.floodMarked, true)
	Check.eq(second.ignored, false)
	local _, third = flood(PLAYER, like, RateLimit.FLOOD_WINDOW_SECONDS)
	Check.eq(third.floodMarked, true)
	Check.eq(third.ignored, true)
	Check.eq(third.error, "rate_limited")
	local held = RateLimiter.consume(PLAYER, "RequestBuyRift", RateLimit.FLOOD_WINDOW_SECONDS + RateLimit.BURST_SECONDS)
	Check.eq(held.allowed, false)
	Check.eq(held.ignored, true)
	Check.eq(held.floodMarked, false)
	local releasedAt = RateLimit.FLOOD_WINDOW_SECONDS + RateLimit.IGNORE_SECONDS
	local released = RateLimiter.consume(PLAYER, like, releasedAt)
	Check.eq(released.allowed, true)
	Check.eq(released.ignored, false)
	Check.eq(RateLimiter.consume(OTHER, like, RateLimit.FLOOD_WINDOW_SECONDS).allowed, true)
	local text = joined(logs)
	Check.contains(text, "ignored")
	Check.contains(text, "flood")
	Check.eq(string.find(text, "Kick", 1, true), nil)
end)

Check.test("a flood older than 60s does not count toward the ignore threshold", function()
	begin()
	local like = "RequestLike"
	flood(PLAYER, like, 0)
	flood(PLAYER, like, RateLimit.FLOOD_WINDOW_SECONDS / 2)
	local later = RateLimit.FLOOD_WINDOW_SECONDS + RateLimit.TOKENS_PER_CALL
	local _, dropped = flood(PLAYER, like, later)
	Check.eq(dropped.floodMarked, true)
	Check.eq(dropped.ignored, false)
	local after = RateLimiter.consume(PLAYER, like, later + RateLimit.BURST_SECONDS)
	Check.eq(after.allowed, true)
	Check.eq(after.ignored, false)
end)

Check.test("PlayerRemoving cleanup drops buckets and a silence", function()
	begin()
	local like = "RequestLike"
	flood(PLAYER, like, 0)
	flood(PLAYER, like, RateLimit.FLOOD_WINDOW_SECONDS / 2)
	local _, silenced = flood(PLAYER, like, RateLimit.FLOOD_WINDOW_SECONDS)
	Check.eq(silenced.ignored, true)
	RateLimiter.forget(PLAYER)
	local again = RateLimiter.consume(PLAYER, like, RateLimit.FLOOD_WINDOW_SECONDS)
	Check.eq(again.allowed, true)
	Check.eq(again.ignored, false)
	Check.eq(RateLimiter.consume(OTHER, like, RateLimit.FLOOD_WINDOW_SECONDS).allowed, true)
end)

Check.test("a normal click rate is allowed for every remote", function()
	local logs = begin()
	local names = everyName()
	Check.truthy(#names >= #liveNames())
	for _, name in names do
		local perSecond = RateLimit.perSecond(name)
		local interval = (RateLimit.TOKENS_PER_CALL * 2) / perSecond
		local clicks = RateLimit.capacity(name) + RateLimit.DEFAULT_PER_SECOND
		RateLimiter.forget(PLAYER)
		for step = 0, clicks do
			local decision = RateLimiter.consume(PLAYER, name, step * interval)
			Check.eq(decision.allowed, true, name .. " at half rate")
			Check.eq(decision.error, nil, name)
		end
	end
	for _, name in liveNames() do
		RateLimiter.forget(PLAYER)
		local clicks = RateLimit.capacity(name) + RateLimit.DEFAULT_PER_SECOND
		for step = 0, clicks do
			local now = step * Economy.PURCHASE_DEBOUNCE_SECONDS
			local decision = RateLimiter.consume(PLAYER, name, now)
			Check.eq(decision.allowed, true, name .. " at purchase cadence")
		end
	end
	Check.eq(#logs, 0)
end)

Check.test("steady traffic at exactly the published rate is allowed", function()
	local logs = begin()
	for _, name in everyName() do
		local perSecond = RateLimit.perSecond(name)
		local interval = RateLimit.TOKENS_PER_CALL / perSecond
		local steps = perSecond * RateLimit.FLOODS_BEFORE_IGNORE
		RateLimiter.forget(PLAYER)
		for step = 0, steps do
			local decision = RateLimiter.consume(PLAYER, name, step * interval)
			Check.eq(decision.allowed, true, name .. " step " .. tostring(step))
		end
	end
	Check.eq(#logs, 0)
end)

Check.test("every remote is registered through the limiter", function()
	local files = {}
	walk("src", files)
	Check.truthy(#files > 3)
	local fnCreated = 0
	local fnBound = 0
	for _, path in files do
		local text = fs.readFile(path)
		local eventAt = string.find(text, "OnServerEvent", 1, true)
		local invokeAt = string.find(text, "OnServerInvoke", 1, true)
		if path ~= GUARD then
			Check.eq(eventAt, nil, path .. " connects a remote outside RemoteGuard")
			Check.eq(invokeAt, nil, path .. " connects a remote outside RemoteGuard")
		end
		if path ~= CREATOR then
			Check.eq(string.find(text, 'Instance.new("RemoteEvent")', 1, true), nil, path)
			Check.eq(string.find(text, "Instance.new('RemoteEvent')", 1, true), nil, path)
			Check.eq(string.find(text, 'Instance.new("RemoteFunction")', 1, true), nil, path)
			Check.eq(string.find(text, "Instance.new('RemoteFunction')", 1, true), nil, path)
		end
		fnCreated += count(text, 'Instance.new("RemoteFunction")')
		fnCreated += count(text, "Instance.new('RemoteFunction')")
		for line in string.gmatch(text, "[^\n]+") do
			if
				string.find(line, "RemoteGuard.bindFunction(", 1, true) ~= nil
				and string.find(line, "function RemoteGuard.bindFunction", 1, true) == nil
			then
				fnBound += 1
			end
		end
	end
	Check.eq(fnBound, fnCreated)

	local guard = fs.readFile(GUARD)
	Check.contains(guard, "RateLimiter.consume")
	Check.contains(guard, "RateLimiter.rejected")
	Check.contains(guard, "OnServerEvent")
	Check.contains(guard, "OnServerInvoke")
	Check.eq(string.find(guard, "DataStore", 1, true), nil)
	Check.eq(string.find(guard, "RemoteArgs", 1, true), nil)
	Check.eq(string.find(guard, "Kick", 1, true), nil)
	local consumeAt = string.find(guard, "RateLimiter.consume", 1, true)
	local admitAt = string.find(guard, "local function admit", 1, true)
	Check.truthy(admitAt)
	Check.truthy(consumeAt)
	Check.eq(admitAt < consumeAt, true)
	local function admitBeforeHandler(from: number)
		local callAt = string.find(guard, "admit(player", from, true)
		local handlerAt = string.find(guard, "handler(player", from, true)
		Check.truthy(callAt)
		Check.truthy(handlerAt)
		Check.eq(callAt < handlerAt, true)
		return callAt, handlerAt
	end
	local eventFrom = string.find(guard, "OnServerEvent", 1, true)
	local invokeFrom = string.find(guard, "OnServerInvoke", 1, true)
	Check.truthy(eventFrom)
	Check.truthy(invokeFrom)
	admitBeforeHandler(eventFrom :: number)
	local functionCall, functionHandler = admitBeforeHandler(invokeFrom :: number)
	local rejectedAt = string.find(guard, "RateLimiter.rejected", invokeFrom :: number, true)
	Check.truthy(rejectedAt)
	Check.eq((functionCall :: number) < (rejectedAt :: number), true)
	Check.eq((rejectedAt :: number) < (functionHandler :: number), true)

	local session = fs.readFile(SESSION)
	local creator = fs.readFile(CREATOR)
	Check.contains(session, "RemoteGuard.bindEvent")
	Check.contains(session, "RateLimiter.forget")
	Check.eq(string.find(session, "OnServerEvent", 1, true), nil)
	Check.eq(string.find(session, "OnServerInvoke", 1, true), nil)
	Check.eq(string.find(session, "windowCount", 1, true), nil)
	Check.eq(string.find(session, "REMOTE_REQUESTS_PER_SECOND", 1, true), nil)
	Check.contains(session, "allowRequest")
	Check.contains(session, "RemoteArgs.slot")
	Check.contains(session, "RemoteArgs.pad")
	Check.contains(session, "RemoteArgs.instanceId")
	Check.contains(session, "RemoteArgs.pedlarSlot")
	Check.contains(session, "RemoteArgs.flag")
	Check.eq(string.find(fs.readFile("src/shared/Config/Economy.luau"), "REMOTE_REQUESTS_PER_SECOND", 1, true), nil)
	Check.eq(string.find(fs.readFile(LIMITER), "Kick", 1, true), nil)
	Check.eq(string.find(fs.readFile(LIMITER), "%d"), nil)
	Check.eq(string.find(guard, "%d"), nil)

	local keys = {}
	for key in Names do
		if key ~= "FOLDER" then
			table.insert(keys, key)
		end
	end
	Check.truthy(#keys > 0)
	local listens = 0
	for _ in string.gmatch(session, "listen%(Names%.") do
		listens += 1
	end
	Check.eq(listens, #keys)
	for _, key in keys do
		Check.contains(creator, "Names." .. key)
		Check.contains(session, "listen(Names." .. key .. ",")
	end
	for line in string.gmatch(session, "[^\n]+") do
		if string.find(line, "listen(", 1, true) ~= nil and string.find(line, "function listen(", 1, true) == nil then
			Check.eq(string.find(line, "listen(Names.", 1, true) ~= nil, true, line)
		end
	end
end)
