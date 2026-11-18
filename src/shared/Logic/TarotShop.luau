--!strict

-- Server-side tent actions. The client may send a case id and a request id.
-- Weights, prices, pity, and results in the same call are ignored.

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local TarotCases = import("../Config/TarotCases", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("TarotCases")
end)
local Town = import("../Config/Town", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Town")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local NumberFormat = import("./NumberFormat", function()
	return script.Parent:WaitForChild("NumberFormat")
end)
local RemoteArgs = import("./RemoteArgs", function()
	return script.Parent:WaitForChild("RemoteArgs")
end)
local TarotOdds = import("./TarotOdds", function()
	return script.Parent:WaitForChild("TarotOdds")
end)
local TarotRoll = import("./TarotRoll", function()
	return script.Parent:WaitForChild("TarotRoll")
end)
local TarotSave = import("./TarotSave", function()
	return script.Parent:WaitForChild("TarotSave")
end)
local Transactions = import("./Transactions", function()
	return script.Parent:WaitForChild("Transactions")
end)

local TarotShop = {}

local function clockOf(value: any): number?
	local now = value
	if type(now) == "function" then
		now = now()
	end
	if type(now) ~= "number" or now ~= now or now < 0 or now == math.huge then
		return nil
	end
	return math.floor(now)
end

local function refused(code: string, message: string): any
	return {
		code = code,
		message = message,
		prompt = false,
		productId = nil,
		rarity = nil,
		reveal = nil,
	}
end

function TarotShop.blocked(gate: any): string?
	if type(gate) ~= "table" or gate.opened ~= true then
		return "open"
	end
	if RemoteArgs.withinDistance(gate.distance, Town.BUY_DISTANCE) ~= true then
		return "distance"
	end
	return nil
end

local function findRequest(profile: any, requestId: string): any?
	local requests = profile.tarot.requests
	if type(requests) ~= "table" then
		return nil
	end
	for index = #requests, 1, -1 do
		local entry = requests[index]
		if type(entry) == "table" and entry.id == requestId then
			return entry
		end
	end
	return nil
end

local function remember(
	profile: any,
	requestId: string,
	caseId: string,
	line: string,
	rarity: string,
	rewardId: string,
	cash: number
)
	table.insert(profile.tarot.requests, {
		id = requestId,
		caseId = caseId,
		line = line,
		rarity = rarity,
		rewardId = rewardId,
		cash = cash,
	})
	while #profile.tarot.requests > TarotCases.REQUEST_CAP do
		table.remove(profile.tarot.requests, 1)
	end
end

local function countOf(profile: any, case: any): number
	if case.kind == "free" then
		local tokens = profile.tarot.tokens
		local count = if type(tokens) == "table" then tokens[case.token] else nil
		if type(count) ~= "number" then
			return 0
		end
		return count
	end
	local cases = profile.tarot.cases
	local count = if type(cases) == "table" then cases[case.id] else nil
	if type(count) ~= "number" then
		return 0
	end
	return count
end

function TarotShop.decide(case: any, ctx: any): any
	if type(case) ~= "table" or type(ctx) ~= "table" then
		return refused("args", TarotCases.NOTICES.args)
	end
	if case.kind == "free" then
		return refused("free", TarotCases.NOTICES.unavailable)
	end
	local now = clockOf(ctx.now)
	if now == nil or TarotOdds.inWindow(case, now) ~= true then
		return refused("window", TarotCases.NOTICES.window)
	end
	if ctx.paidEnabled ~= true or ctx.policyAllows ~= true then
		return refused("unavailable", TarotCases.NOT_AVAILABLE)
	end
	local productId = case.productId
	if type(productId) ~= "number" or productId ~= math.floor(productId) or productId <= 0 then
		return refused("unavailable", TarotCases.NOT_AVAILABLE)
	end
	return {
		code = "prompt",
		message = TarotCases.SEE_PRICE,
		prompt = true,
		productId = productId,
		rarity = nil,
		reveal = nil,
	}
end

function TarotShop.buy(profile: any, caseId: any, requestId: any, ctx: any): any
	if RemoteArgs.tarotCase(caseId) == nil or RemoteArgs.requestId(requestId) == nil then
		return refused("args", TarotCases.NOTICES.args)
	end
	if type(profile) ~= "table" or type(ctx) ~= "table" then
		return refused("args", TarotCases.NOTICES.args)
	end
	local case = TarotCases.get(caseId)
	if case == nil then
		return refused("args", TarotCases.NOTICES.args)
	end
	return TarotShop.decide(case, ctx)
end

local function lineFor(outcome: any): string
	if outcome.converted == true then
		return "You owned that rarity. The card became " .. NumberFormat.formatCash(outcome.card.duplicateCash) .. "."
	end
	return "The card is " .. outcome.card.name .. ", " .. outcome.rarity .. "."
end

function TarotShop.open(profile: any, caseId: any, requestId: any, deps: any): any
	if RemoteArgs.tarotCase(caseId) == nil or RemoteArgs.requestId(requestId) == nil then
		return refused("args", TarotCases.NOTICES.args)
	end
	if type(profile) ~= "table" or type(deps) ~= "table" or TarotSave.apply(profile, profile) ~= true then
		return refused("args", TarotCases.NOTICES.args)
	end
	local case = TarotCases.get(caseId)
	if case == nil then
		return refused("args", TarotCases.NOTICES.args)
	end
	local prior = findRequest(profile, requestId)
	if prior ~= nil then
		return {
			code = "replay",
			message = prior.line,
			prompt = false,
			productId = nil,
			rarity = prior.rarity,
			reveal = {
				text = prior.line,
				rarity = prior.rarity,
			},
		}
	end
	local blocked = TarotShop.blocked(deps.gate)
	if blocked ~= nil then
		local notice = if blocked == "distance" then TarotCases.NOTICES.distance else TarotCases.NOTICES.open
		return refused(blocked, notice)
	end
	local now = clockOf(deps.now)
	if case.kind ~= "free" then
		if now == nil or TarotOdds.inWindow(case, now) ~= true then
			return refused("window", TarotCases.NOTICES.window)
		end
		if deps.paidEnabled ~= true or deps.policyAllows ~= true then
			return refused("unavailable", TarotCases.NOT_AVAILABLE)
		end
		if countOf(profile, case) < 1 then
			return refused("empty", TarotCases.NOTICES.empty)
		end
	elseif countOf(profile, case) < 1 then
		return refused("none", TarotCases.NOTICES.none)
	end
	local nowChecked = now
	local entropy = clockOf(deps.entropy)
	if nowChecked == nil or entropy == nil or type(deps.rng) ~= "function" or type(deps.newId) ~= "function" then
		return refused("args", TarotCases.NOTICES.args)
	end
	local nonce = profile.tarot.nonce
	if type(nonce) ~= "number" then
		nonce = 0
	end
	local rng = deps.rng(TarotRoll.mix(nonce, entropy))
	local outcome = TarotRoll.roll(case, profile, rng)
	if outcome == nil then
		return refused("id", TarotCases.NOTICES.id)
	end
	local line = lineFor(outcome)
	if #line > TarotCases.LINE_MAX then
		line = string.sub(line, 1, TarotCases.LINE_MAX)
	end
	local cash = 0
	if outcome.converted == true then
		cash = outcome.card.duplicateCash
		profile.cash = Money.round(profile.cash + cash)
		profile.totalEarned = Money.round(profile.totalEarned + cash)
	elseif outcome.card.kind == "cryptid" then
		local instanceId = deps.newId()
		if
			type(instanceId) ~= "string"
			or Transactions.grantReading(profile, instanceId, outcome.card.id, nowChecked) ~= true
		then
			return refused("id", TarotCases.NOTICES.id)
		end
	else
		profile.tarot.known[outcome.card.id] = true
	end
	if case.kind == "free" then
		profile.tarot.tokens[case.token] -= 1
	else
		local left = countOf(profile, case) - 1
		if left <= 0 then
			profile.tarot.cases[case.id] = nil
		else
			profile.tarot.cases[case.id] = left
		end
	end
	profile.tarot.familyPity[case.family] = outcome.pity
	if case.family == "pale" or case.family == "blood" then
		profile.tarot.pity[case.family] = outcome.pity
	end
	profile.tarot.nonce = nonce + 1
	remember(profile, requestId, case.id, line, outcome.rarity, outcome.card.id, cash)
	return {
		code = "ok",
		message = line,
		prompt = false,
		productId = nil,
		rarity = outcome.rarity,
		reveal = {
			text = line,
			rarity = outcome.rarity,
		},
	}
end

local function buttonFor(case: any, count: number, ctx: any): (string, string)
	if case.kind == "free" then
		if count > 0 then
			return TarotCases.OPEN, "open"
		end
		return TarotCases.NO_CARDS, "open"
	end
	local openable = count > 0
		and ctx.paidEnabled == true
		and ctx.policyAllows == true
		and TarotOdds.inWindow(case, ctx.now) == true
	if openable then
		return TarotCases.OPEN, "open"
	end
	local decision = TarotShop.decide(case, ctx)
	if decision.prompt == true then
		return TarotCases.SEE_PRICE, "buy"
	end
	return TarotCases.NOT_AVAILABLE, "buy"
end

function TarotShop.present(profile: any, now: number, ctx: any): any
	local view = {
		oddsNote = TarotCases.ODDS_NOTE,
		cases = {},
		reveal = nil,
	}
	if type(profile) ~= "table" or type(profile.tarot) ~= "table" or type(ctx) ~= "table" then
		return view
	end
	local clock = clockOf(now)
	if clock == nil then
		clock = 0
	end
	local paidCtx = {
		now = clock,
		paidEnabled = ctx.paidEnabled == true,
		policyAllows = ctx.policyAllows == true,
	}
	for _, case in TarotCases.list() do
		local paid = case.kind ~= "free"
		if paid and paidCtx.policyAllows ~= true then
			continue
		end
		if paid and TarotOdds.inWindow(case, clock) ~= true then
			continue
		end
		local count = countOf(profile, case)
		local pity = TarotOdds.pityCount(profile, case.family)
		local label, action = buttonFor(case, count, paidCtx)
		local endsText = ""
		if case.kind == "event" then
			endsText = TarotOdds.endText(case)
		end
		table.insert(view.cases, {
			id = case.id,
			name = case.name,
			kind = case.kind,
			count = count,
			odds = TarotOdds.disclose(case, pity),
			pityLine = TarotOdds.pityLine(case, pity),
			duplicateLine = TarotOdds.duplicateLine(case),
			endsText = endsText,
			placeholder = case.placeholder == true,
			button = label,
			action = action,
		})
	end
	local reveal = ctx.reveal
	if type(reveal) == "table" and type(reveal.text) == "string" and type(reveal.rarity) == "string" then
		view.reveal = {
			text = reveal.text,
			rarity = reveal.rarity,
		}
	end
	return view
end

return TarotShop
