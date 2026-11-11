--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Catalogue = import("../shared/Config/Analytics", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Analytics")
end)
local Economy = import("../shared/Config/Economy", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Economy")
end)
local Monetisation = import("../shared/Config/Monetisation", function()
	return game:GetService("ReplicatedStorage")
		:WaitForChild("Shared")
		:WaitForChild("Config")
		:WaitForChild("Monetisation")
end)
local Save = import("../shared/Config/Save", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Save")
end)
local Species = import("../shared/Config/Species", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Species")
end)
local Money = import("../shared/Logic/Money", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("Money")
end)

local Analytics = {}
local singleton: any = nil

local function balanceOf(profile: any): number?
	if type(profile) ~= "table" then
		return nil
	end
	local cash = profile.cash
	if type(cash) ~= "number" or cash ~= cash or cash < 0 or cash == math.huge then
		return nil
	end
	return cash
end

local function charged(before: any, after: any): number?
	if type(before) ~= "number" or type(after) ~= "number" then
		return nil
	end
	local amount = Money.round(before - after)
	if amount ~= amount or amount <= 0 or amount == math.huge then
		return nil
	end
	return amount
end

local function wholeSeconds(value: any): number?
	if type(value) ~= "number" or value ~= value or value < 0 or value == math.huge then
		return nil
	end
	return math.floor(value)
end

local function playSeconds(profile: any): number
	local seconds = 0
	if type(profile) == "table" and type(profile.onboarding) == "table" then
		local played = wholeSeconds(profile.onboarding.playSeconds)
		if played ~= nil then
			seconds = played
		end
	end
	return seconds
end

local function daysSince(profile: any, now: any): number
	if type(profile) ~= "table" or type(now) ~= "number" then
		return 0
	end
	local first = profile.firstJoinUnix
	if type(first) ~= "number" then
		return 0
	end
	local days = Catalogue.utcDay(now) - Catalogue.utcDay(first)
	if days ~= days or days < 0 or days == math.huge then
		return 0
	end
	return days
end

local function ensure(profile: any): any
	local state = profile.analytics
	if type(state) ~= "table" then
		state = {
			lastReturnDay = 0,
			funnelStep = 0,
		}
		profile.analytics = state
	end
	if type(state.lastReturnDay) ~= "number" then
		state.lastReturnDay = 0
	end
	if type(state.funnelStep) ~= "number" then
		state.funnelStep = 0
	end
	return state
end

local function economyRecord(
	profile: any,
	flow: string,
	transactionType: string,
	sku: string,
	amount: number,
	fields: any
): any?
	local balance = balanceOf(profile)
	if balance == nil or sku == nil or fields == nil then
		return nil
	end
	return {
		kind = Catalogue.KIND.Economy,
		name = sku,
		flow = flow,
		currency = Catalogue.CURRENCY,
		amount = amount,
		balance = balance,
		transactionType = transactionType,
		sku = sku,
		fields = fields,
	}
end

function Analytics.open(deps: any): any
	if type(deps) ~= "table" then
		deps = {}
	end
	local buckets: { [string]: { number } } = {}

	local function clockNow(): number
		if type(deps.clock) ~= "function" then
			return 0
		end
		local value = deps.clock()
		if type(value) ~= "number" or value ~= value or value == math.huge then
			return 0
		end
		return value
	end

	local function deliver(player: any, record: any): boolean
		if deps.isStudio == true then
			local line = "[Cryptid:Analytics] " .. Catalogue.encode(record)
			if type(deps.print) == "function" then
				deps.print(line)
			end
			if type(deps.studioSink) == "function" then
				deps.studioSink(record)
			end
			return true
		end
		if type(deps.send) ~= "function" then
			return false
		end
		local ok = pcall(deps.send, player, record)
		return ok
	end

	local function allowRate(session: any): boolean
		local key = "session"
		if type(session) == "table" and type(session.analyticsKey) == "string" and session.analyticsKey ~= "" then
			key = session.analyticsKey
		end
		local now = clockNow()
		local bucket = buckets[key]
		if bucket == nil then
			bucket = {}
			buckets[key] = bucket
		end
		local kept = {}
		for _, at in bucket do
			if type(at) == "number" and now - at < Catalogue.RATE_WINDOW_SECONDS then
				table.insert(kept, at)
			end
		end
		if #kept >= Catalogue.RATE_PER_MINUTE then
			buckets[key] = kept
			return false
		end
		table.insert(kept, now)
		buckets[key] = kept
		return true
	end

	local function submit(player: any, session: any, record: any, counted: boolean): boolean
		if Catalogue.vet(record) ~= true then
			return false
		end
		if counted == true and allowRate(session) ~= true then
			return false
		end
		return deliver(player, record)
	end

	local function sendEconomy(
		player: any,
		session: any,
		flow: string,
		transactionType: string,
		sku: string?,
		amount: number?,
		fields: any
	): boolean
		if sku == nil or amount == nil then
			return false
		end
		local record = economyRecord(session.profile, flow, transactionType, sku, amount, fields)
		if record == nil then
			return false
		end
		return submit(player, session, record, false)
	end

	local api = {}

	function api.submit(player: any, session: any, record: any, counted: boolean): boolean
		return submit(player, session, record, counted)
	end

	function api.purchaseStatus(entry: any): string
		if type(entry) ~= "table" or Monetisation.isLive(entry) ~= true then
			return "id"
		end
		local price = entry.catalogPrice
		if
			type(price) ~= "number"
			or price ~= price
			or price <= 0
			or price == math.huge
			or price ~= math.floor(price)
		then
			return "price"
		end
		return "blocked"
	end

	function api.purchase(_player: any, _session: any, entry: any): boolean
		return api.purchaseStatus(entry) == "open"
	end

	function api.noteIncome(session: any, amount: any)
		if type(session) ~= "table" then
			return
		end
		if type(amount) ~= "number" or amount ~= amount or amount <= 0 or amount == math.huge then
			return
		end
		local pending = session.pendingIncome
		if type(pending) ~= "number" then
			pending = 0
		end
		session.pendingIncome = Money.round(pending + amount)
	end

	function api.flushIncome(player: any, session: any, clock: any, force: boolean): boolean
		if type(session) ~= "table" then
			return false
		end
		local pending = session.pendingIncome
		if type(pending) ~= "number" or pending <= 0 then
			return false
		end
		local at = clock
		if type(at) ~= "number" then
			at = 0
		end
		local last = session.incomeLoggedAt
		if force ~= true and type(last) == "number" and at - last < Save.LOCK_REFRESH_SECONDS then
			return false
		end
		local amount = pending
		session.pendingIncome = 0
		local fields = Catalogue.fields(nil, nil, Catalogue.onboarded(session.profile))
		local sent = sendEconomy(
			player,
			session,
			Catalogue.FLOW.Source,
			Catalogue.TX.Gameplay,
			Catalogue.SKU.PadIncome,
			amount,
			fields
		)
		if sent ~= true then
			local again = session.pendingIncome
			if type(again) ~= "number" then
				again = 0
			end
			session.pendingIncome = Money.round(again + amount)
			return false
		end
		session.incomeLoggedAt = at
		return true
	end

	function api.beginExit(session: any): boolean
		if type(session) ~= "table" or session.leaving == true then
			return false
		end
		session.leaving = true
		return true
	end

	function api.finishExit(player: any, session: any, now: any, clock: any): boolean
		if type(session) ~= "table" or session.analyticsClosed == true or session.leaving ~= true then
			return false
		end
		session.analyticsClosed = true
		api.flushIncome(player, session, clock, true)
		local length = 0
		if type(clock) == "number" and type(session.bornAt) == "number" then
			local elapsed = math.floor(clock - session.bornAt)
			if elapsed == elapsed and elapsed >= 0 and elapsed ~= math.huge then
				length = elapsed
			end
		end
		local days = daysSince(session.profile, now)
		local fields =
			Catalogue.fields(Catalogue.onboarded(session.profile), Catalogue.tenure(days), Catalogue.sessionDay(days))
		if fields == nil then
			return false
		end
		return submit(player, session, {
			kind = Catalogue.KIND.Custom,
			name = Catalogue.CUSTOM.SessionEnded,
			value = length,
			fields = fields,
		}, false)
	end

	function api.starter(player: any, session: any): boolean
		if type(session) ~= "table" or session.starterLogged == true then
			return false
		end
		local amount = Economy.STARTING_CASH
		if type(amount) ~= "number" or amount <= 0 then
			return false
		end
		local fields = Catalogue.fields(nil, nil, Catalogue.onboarded(session.profile))
		if
			sendEconomy(
				player,
				session,
				Catalogue.FLOW.Source,
				Catalogue.TX.Onboarding,
				Catalogue.SKU.StarterCash,
				amount,
				fields
			) ~= true
		then
			return false
		end
		session.starterLogged = true
		return true
	end

	function api.joined(player: any, session: any): boolean
		if type(session) ~= "table" or type(session.profile) ~= "table" then
			return false
		end
		local state = ensure(session.profile)
		if state.funnelStep >= 1 then
			return false
		end
		local sent = submit(player, session, {
			kind = Catalogue.KIND.Onboarding,
			name = Catalogue.ONBOARDING_FUNNEL,
			step = 1,
			stepName = Catalogue.FUNNEL[1],
		}, false)
		if sent ~= true then
			return false
		end
		state.funnelStep = 1
		return true
	end

	function api.returned(player: any, session: any, now: any, seenUnix: any): boolean
		if type(session) ~= "table" or type(session.profile) ~= "table" then
			return false
		end
		if type(seenUnix) ~= "number" or type(now) ~= "number" then
			return false
		end
		local days = daysSince(session.profile, now)
		if days < 1 then
			return false
		end
		local today = Catalogue.utcDay(now)
		if Catalogue.utcDay(seenUnix) >= today then
			return false
		end
		local state = ensure(session.profile)
		if state.lastReturnDay >= today then
			return false
		end
		local bucket = Catalogue.returnDay(days)
		if bucket == nil then
			return false
		end
		local fields = Catalogue.fields(bucket, Catalogue.onboarded(session.profile), nil)
		if fields == nil then
			return false
		end
		local sent = submit(player, session, {
			kind = Catalogue.KIND.Custom,
			name = Catalogue.CUSTOM.PlayerReturned,
			value = days,
			fields = fields,
		}, false)
		if sent ~= true then
			return false
		end
		state.lastReturnDay = today
		return true
	end

	function api.plot(player: any, session: any, code: any): boolean
		if type(session) ~= "table" or session.plotLogged == true then
			return false
		end
		local field = Catalogue.ruleField(code)
		if field == nil then
			return false
		end
		local fields = Catalogue.fields(field, nil, nil)
		if fields == nil then
			return false
		end
		local sent = submit(player, session, {
			kind = Catalogue.KIND.Custom,
			name = Catalogue.CUSTOM.PlotAssigned,
			value = 1,
			fields = fields,
		}, false)
		if sent ~= true then
			return false
		end
		session.plotLogged = true
		return true
	end

	function api.bootstrap(player: any, session: any, info: any): boolean
		if type(info) ~= "table" then
			return false
		end
		local changed = false
		if info.fresh == true then
			api.starter(player, session)
			if api.joined(player, session) then
				changed = true
			end
		elseif api.returned(player, session, info.now, info.seenUnix) then
			changed = true
		end
		api.plot(player, session, info.rule)
		return changed
	end

	function api.advanced(player: any, session: any, fromStep: number): boolean
		if type(session) ~= "table" or type(session.profile) ~= "table" then
			return false
		end
		local profile = session.profile
		local skipped = type(profile.onboarding) == "table" and profile.onboarding.skipped == true
		local landed = if type(profile.onboarding) == "table" then profile.onboarding.step else fromStep
		local planned = Catalogue.eventsForTransition(fromStep, landed, skipped)
		local state = ensure(profile)
		local seconds = playSeconds(profile)
		local changed = false
		for _, event in planned do
			if event.step > state.funnelStep then
				local sent = submit(player, session, {
					kind = Catalogue.KIND.Onboarding,
					name = Catalogue.ONBOARDING_FUNNEL,
					step = event.step,
					stepName = event.stepName,
				}, false)
				if sent == true then
					local stepField = Catalogue.stepField(event.step)
					if stepField ~= nil then
						local fields = Catalogue.fields(stepField, nil, nil)
						if fields ~= nil then
							submit(player, session, {
								kind = Catalogue.KIND.Custom,
								name = Catalogue.CUSTOM.OnboardingStepTime,
								value = seconds,
								fields = fields,
							}, false)
						end
					end
					state.funnelStep = event.step
					changed = true
				end
			end
		end
		return changed
	end

	function api.skipped(player: any, session: any, goal: any): boolean
		if type(session) ~= "table" or type(session.profile) ~= "table" or session.skipLogged == true then
			return false
		end
		local onboarding = session.profile.onboarding
		if type(onboarding) ~= "table" or onboarding.skipped ~= true then
			return false
		end
		if type(goal) ~= "number" or goal ~= math.floor(goal) or goal < 1 or goal > 7 then
			return false
		end
		local fields = Catalogue.fields(Catalogue.playBucket(playSeconds(session.profile)), nil, nil)
		if fields == nil then
			return false
		end
		local sent = submit(player, session, {
			kind = Catalogue.KIND.Custom,
			name = Catalogue.CUSTOM.OnboardingSkipped,
			value = goal,
			fields = fields,
		}, false)
		if sent ~= true then
			return false
		end
		session.skipLogged = true
		return true
	end

	function api.catch(player: any, session: any, seconds: any, tutorial: boolean): boolean
		local species = Species.get(Species.WILD_ID)
		if species == nil then
			return false
		end
		local rarity = Catalogue.rarityField(species.rarity)
		local duration = wholeSeconds(seconds)
		if rarity == nil or duration == nil then
			return false
		end
		local fields = Catalogue.fields(rarity, Catalogue.tutorialField(tutorial == true), nil)
		if fields == nil then
			return false
		end
		return submit(player, session, {
			kind = Catalogue.KIND.Custom,
			name = Catalogue.CUSTOM.CatchCompleted,
			value = duration,
			fields = fields,
		}, true)
	end

	function api.rift(player: any, session: any, beforeCash: any, speciesId: any): boolean
		if type(session) ~= "table" then
			return false
		end
		local amount = charged(beforeCash, session.profile.cash)
		local species = Catalogue.speciesField(speciesId)
		if amount == nil or species == nil then
			return false
		end
		local fields = Catalogue.fields(nil, species, nil)
		return sendEconomy(player, session, Catalogue.FLOW.Sink, Catalogue.TX.Shop, Catalogue.SKU.Rift, amount, fields)
	end

	function api.pad(player: any, session: any, index: any, beforeCash: any): boolean
		if type(session) ~= "table" then
			return false
		end
		local amount = charged(beforeCash, session.profile.cash)
		local fields = Catalogue.fields(nil, nil, Catalogue.onboarded(session.profile))
		return sendEconomy(
			player,
			session,
			Catalogue.FLOW.Sink,
			Catalogue.TX.Gameplay,
			Catalogue.padSku(index),
			amount,
			fields
		)
	end

	function api.altar(player: any, session: any, level: any, beforeCash: any): boolean
		if type(session) ~= "table" then
			return false
		end
		local amount = charged(beforeCash, session.profile.cash)
		local fields = Catalogue.fields(nil, nil, Catalogue.onboarded(session.profile))
		return sendEconomy(
			player,
			session,
			Catalogue.FLOW.Sink,
			Catalogue.TX.Gameplay,
			Catalogue.altarSku(level),
			amount,
			fields
		)
	end

	local function pedlarRecord(session: any, step: number, withField: boolean): any
		local funnel = session.pedlarFunnel
		local fields = nil
		if withField == true then
			fields = Catalogue.fields(Catalogue.onboarded(session.profile), nil, nil)
		end
		return {
			kind = Catalogue.KIND.Funnel,
			name = Catalogue.PEDLAR_FUNNEL,
			funnel = Catalogue.PEDLAR_FUNNEL,
			funnelSessionId = funnel.id,
			step = step,
			stepName = Catalogue.PEDLAR_STEPS[step],
			fields = fields,
		}
	end

	function api.pedlarOpen(player: any, session: any, rotationId: any, funnelId: any): boolean
		if type(session) ~= "table" or type(rotationId) ~= "number" or type(funnelId) ~= "string" then
			return false
		end
		session.pedlarFunnel = {
			id = funnelId,
			rotation = rotationId,
			pressed = false,
			bought = false,
			stale = false,
		}
		if submit(player, session, pedlarRecord(session, 1, true), true) ~= true then
			session.pedlarFunnel = nil
			return false
		end
		return true
	end

	function api.pedlarStale(session: any)
		if type(session) ~= "table" then
			return
		end
		local funnel = session.pedlarFunnel
		if type(funnel) == "table" then
			funnel.stale = true
		end
	end

	function api.pedlarPressed(player: any, session: any): boolean
		if type(session) ~= "table" then
			return false
		end
		local funnel = session.pedlarFunnel
		if type(funnel) ~= "table" or funnel.pressed == true then
			return false
		end
		if submit(player, session, pedlarRecord(session, 2, false), true) ~= true then
			return false
		end
		funnel.pressed = true
		return true
	end

	function api.pedlarPurchase(player: any, session: any, slot: any, speciesId: any, beforeCash: any): boolean
		if type(session) ~= "table" then
			return false
		end
		local amount = charged(beforeCash, session.profile.cash)
		local species = Species.get(speciesId)
		local sent = false
		if amount ~= nil and species ~= nil then
			local slotText = Catalogue.slotField(slot)
			local speciesText = Catalogue.speciesField(speciesId)
			if slotText ~= nil and speciesText ~= nil then
				local fields = Catalogue.fields(slotText, speciesText, Catalogue.onboarded(session.profile))
				sent = sendEconomy(
					player,
					session,
					Catalogue.FLOW.Sink,
					Catalogue.TX.Shop,
					Catalogue.pedlarSku(species.rarity),
					amount,
					fields
				)
			end
		end
		local funnel = session.pedlarFunnel
		if type(funnel) == "table" and funnel.stale ~= true and funnel.bought ~= true then
			if submit(player, session, pedlarRecord(session, 3, false), true) == true then
				funnel.bought = true
			end
		end
		return sent
	end

	function api.ledger(player: any, attempts: any, status: any): boolean
		local code = "read"
		if status == "locked" then
			code = "locked"
		elseif status == "corrupt" then
			code = "corrupt"
		end
		local field = Catalogue.reasonField(code)
		if
			field == nil
			or type(attempts) ~= "number"
			or attempts ~= math.floor(attempts)
			or attempts < 1
			or attempts > 100
		then
			return false
		end
		local fields = Catalogue.fields(field, nil, nil)
		if fields == nil then
			return false
		end
		return submit(player, { analyticsKey = "ledger" }, {
			kind = Catalogue.KIND.Custom,
			name = Catalogue.CUSTOM.LedgerLoadFailed,
			value = attempts,
			fields = fields,
		}, false)
	end

	return api
end

local function fieldMap(fields: any): { [any]: string }?
	if type(fields) ~= "table" then
		return nil
	end
	local keys = Enum.AnalyticsCustomFieldKeys
	local lookup = {
		[Catalogue.FIELD_KEY.One] = keys.CustomField01,
		[Catalogue.FIELD_KEY.Two] = keys.CustomField02,
		[Catalogue.FIELD_KEY.Three] = keys.CustomField03,
	}
	local map = {}
	local anyField = false
	for name, value in fields do
		local key = lookup[name]
		if key ~= nil and type(value) == "string" then
			map[key] = value
			anyField = true
		end
	end
	if not anyField then
		return nil
	end
	return map
end

local function flowOf(name: string): any
	if name == Catalogue.FLOW.Source then
		return Enum.AnalyticsEconomyFlowType.Source
	end
	return Enum.AnalyticsEconomyFlowType.Sink
end

local function transactionOf(name: string): any
	local transactions = Enum.AnalyticsEconomyTransactionType
	if name == Catalogue.TX.Onboarding then
		return transactions.Onboarding
	elseif name == Catalogue.TX.Gameplay then
		return transactions.Gameplay
	elseif name == Catalogue.TX.Shop then
		return transactions.Shop
	end
	return transactions.IAP
end

local function dispatch(service: any, player: any, record: any)
	local fields = fieldMap(record.fields)
	if record.kind == Catalogue.KIND.Custom then
		service:LogCustomEvent(player, record.name, record.value, fields)
	elseif record.kind == Catalogue.KIND.Onboarding then
		service:LogOnboardingFunnelStepEvent(player, record.step, record.stepName)
	elseif record.kind == Catalogue.KIND.Funnel then
		service:LogFunnelStepEvent(player, record.funnel, record.funnelSessionId, record.step, record.stepName, fields)
	elseif record.kind == Catalogue.KIND.Economy then
		service:LogEconomyEvent(
			player,
			flowOf(record.flow),
			record.currency,
			record.amount,
			record.balance,
			transactionOf(record.transactionType),
			record.sku,
			fields
		)
	end
end

function Analytics.live(): any
	if singleton ~= nil then
		return singleton
	end
	local RunService = game:GetService("RunService")
	local studio = RunService:IsStudio()
	local service = game:GetService("AnalyticsService")
	if studio then
		local StudioQa = require(script.Parent:WaitForChild("Dev"):WaitForChild("StudioQa"))
		if StudioQa.analytics() == true then
			print("[Cryptid:Analytics] qa analytics sink armed")
		end
	end
	singleton = Analytics.open({
		isStudio = studio,
		clock = os.clock,
		print = print,
		send = function(player: any, record: any)
			if studio then
				return
			end
			dispatch(service, player, record)
		end,
	})
	return singleton
end

return Analytics
