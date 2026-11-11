--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local Check = require("./check")
local Catalogue = require("../src/shared/Config/Analytics")
local Economy = require("../src/shared/Config/Economy")
local Monetisation = require("../src/shared/Config/Monetisation")
local Onboarding = require("../src/shared/Config/Onboarding")
local Return = require("../src/shared/Config/Return")
local Save = require("../src/shared/Config/Save")
local Species = require("../src/shared/Config/Species")
local Ledger = require("../src/server/Ledger")
local MockDataStore = require("../src/server/MockDataStore")
local Analytics = require("../src/server/Analytics")
local Offline = require("../src/shared/Logic/Offline")
local OnboardingGoals = require("../src/shared/Logic/OnboardingGoals")
local PlotAssign = require("../src/shared/Logic/PlotAssign")
local ProfileQuery = require("../src/shared/Logic/ProfileQuery")
local QaArgs = require("../src/shared/Logic/QaArgs")
local Schema = require("../src/shared/Logic/Schema")
local Transactions = require("../src/shared/Logic/Transactions")
local WatchdogBudget = require("../src/server/Dev/WatchdogBudget")

local DAY = Return.DAY_SECONDS
local PLAYER = {
	Name = "pii-name",
	DisplayName = "pii-display",
	UserId = 987654321,
}
local PII = { "pii-name", "pii-display", "987654321" }
local BLOCKED = "FirstRobuxPurchase"

local function clean(text: string)
	for _, needle in PII do
		Check.eq(string.find(text, needle, 1, true), nil, needle)
	end
end

local function openHub(clockAt: (() -> number)?)
	local records = {}
	local printed = {}
	local sent = 0
	local hub = Analytics.open({
		isStudio = true,
		clock = clockAt or function()
			return 0
		end,
		print = function(line: string)
			table.insert(printed, line)
			clean(line)
			Check.eq(string.sub(line, 1, 20), "[Cryptid:Analytics] ")
		end,
		studioSink = function(record)
			table.insert(records, record)
			clean(Catalogue.encode(record))
		end,
		send = function()
			sent += 1
			error("live send")
		end,
	})
	return hub, records, printed, function()
		return sent
	end
end

local function sessionFor(profile: any, key: string?): any
	return {
		profile = profile,
		analyticsKey = key or "session",
		pendingIncome = 0,
		leaving = false,
		analyticsClosed = false,
		bornAt = 0,
	}
end

local function named(records: { any }, name: string): { any }
	local found = {}
	for _, record in records do
		if record.name == name then
			table.insert(found, record)
		end
	end
	return found
end

local function funnelNames(records: { any }): { string }
	local names = {}
	for _, record in records do
		if record.kind == Catalogue.KIND.Onboarding then
			table.insert(names, record.stepName)
		end
	end
	return names
end

local function field(record: any, key: string): string?
	if type(record.fields) ~= "table" then
		return nil
	end
	return record.fields[key]
end

Check.test("the catalogue freezes the v1.1 names and rejects anything else", function()
	local expected = {
		"Joined",
		"Starter Earning",
		"Claimed Rift Cryptid 1",
		"Caught Hodag",
		"Bound Hodag on Pad 3",
		"Raised Bone Altar I",
		"Carved Pad 4",
		"Claimed Rift Cryptid 2",
		"Rite Complete",
	}
	for step, name in expected do
		Check.eq(Catalogue.FUNNEL[step], name)
	end
	Check.eq(Catalogue.FUNNEL[10], nil)
	Check.eq(Catalogue.PEDLAR_STEPS[1], "Opened")
	Check.eq(Catalogue.PEDLAR_STEPS[2], "Buy Pressed")
	Check.eq(Catalogue.PEDLAR_STEPS[3], "Bought")
	local customs = {
		"OnboardingSkipped",
		"OnboardingStepTime",
		"SessionEnded",
		"PlayerReturned",
		"LedgerLoadFailed",
		"PedlarOddsViewed",
		"CatchCompleted",
		"PlotAssigned",
	}
	Check.eq(#Catalogue.CUSTOM_ORDER, #customs)
	Check.eq(#Catalogue.CUSTOM_ORDER <= Catalogue.MAX_CUSTOM_NAMES, true)
	for index, name in customs do
		Check.eq(Catalogue.CUSTOM_ORDER[index], name)
		Check.eq(Catalogue.CUSTOM[name], name)
	end
	Check.eq(Catalogue.CUSTOM[BLOCKED], nil)
	for _, name in Catalogue.FUNNEL do
		Check.eq(name == "Carved Pad 3", false)
		Check.eq(name == "Bound Hodag on Pad 4", false)
	end
	local skus = Catalogue.skuList()
	Check.eq(#skus <= 40, true)
	Check.eq(Catalogue.padSku(3), "Pad_3")
	Check.eq(Catalogue.padSku(6), "Pad_6")
	Check.eq(Catalogue.padSku(7), nil)
	Check.eq(Catalogue.altarSku(1), "BoneAltar_1")
	Check.eq(Catalogue.altarSku(2), "BoneAltar_2")
	Check.eq(Catalogue.altarSku(3), nil)
	Check.eq(Catalogue.pedlarSku("Epic"), "Pedlar_Epic")
	Check.eq(
		Catalogue.vet({
			kind = Catalogue.KIND.Custom,
			name = "NotARealEvent",
			value = 1,
		}),
		false
	)
	Check.eq(
		Catalogue.vet({
			kind = Catalogue.KIND.Custom,
			name = BLOCKED,
			value = 1,
		}),
		false
	)
	Check.eq(
		Catalogue.vet({
			kind = Catalogue.KIND.Custom,
			name = Catalogue.CUSTOM.PlotAssigned,
			value = 1,
			UserId = PLAYER.UserId,
		}),
		false
	)
	Check.eq(
		Catalogue.vet({
			kind = Catalogue.KIND.Custom,
			name = Catalogue.CUSTOM.PlotAssigned,
			value = 1,
			fields = {
				[Catalogue.FIELD_KEY.One] = "UserId - 1",
			},
		}),
		false
	)
	Check.eq(
		Catalogue.vet({
			kind = Catalogue.KIND.Custom,
			name = Catalogue.CUSTOM.PlotAssigned,
			value = 1,
			fields = {
				[Catalogue.FIELD_KEY.One] = Catalogue.ruleField("reserved"),
				CustomField04 = "Rule - Friend",
			},
		}),
		false
	)
	Check.eq(
		Catalogue.vet({
			kind = Catalogue.KIND.Economy,
			name = "Pad_7",
			flow = Catalogue.FLOW.Sink,
			currency = Catalogue.CURRENCY,
			amount = 15000,
			balance = 0,
			transactionType = Catalogue.TX.Gameplay,
			sku = "Pad_7",
		}),
		false
	)
	Check.eq(Catalogue.speciesField("Fresno Nightcrawler"), nil)
	Check.eq(Catalogue.speciesField(Species.RIFT_1_ID), "Species - fresno_nightcrawler")
	Check.eq(Catalogue.returnDay(0), nil)
	Check.eq(Catalogue.returnDay(1), "Day - 1")
	Check.eq(Catalogue.returnDay(7), "Day - 7")
	Check.eq(Catalogue.returnDay(8), "Day - 8-29")
	Check.eq(Catalogue.returnDay(30), "Day - 30+")
	Check.eq(Catalogue.sessionDay(0), "Day - 0")
	Check.eq(Catalogue.sessionDay(7), "Day - 7-29")
	Check.eq(Catalogue.sessionDay(30), "Day - 30+")
	Check.eq(Catalogue.playBucket(30), "PlaySec - 0-30")
	Check.eq(Catalogue.playBucket(31), "PlaySec - 31-60")
	Check.eq(Catalogue.playBucket(180), "PlaySec - 121-180")
	Check.eq(Catalogue.playBucket(181), "PlaySec - 180+")
end)

Check.test("a fresh join logs the grant, Joined, and the plot rule once", function()
	local hub, records, printed, sent = openHub()
	local now = 20 * DAY
	local profile = Schema.newProfile(now, "starter")
	local session = sessionFor(profile)
	Check.eq(
		hub.bootstrap(PLAYER, session, {
			fresh = true,
			seenUnix = now,
			now = now,
			rule = "lowest",
		}),
		true
	)
	Check.eq(
		hub.bootstrap(PLAYER, session, {
			fresh = true,
			seenUnix = now,
			now = now,
			rule = "lowest",
		}),
		false
	)
	Check.eq(funnelNames(records)[1], "Joined")
	Check.eq(#funnelNames(records), 1)
	Check.eq(#named(records, Catalogue.CUSTOM.OnboardingStepTime), 0)
	Check.eq(#named(records, Catalogue.CUSTOM.PlayerReturned), 0)
	local starter = named(records, Catalogue.SKU.StarterCash)
	Check.eq(#starter, 1)
	Check.eq(starter[1].flow, Catalogue.FLOW.Source)
	Check.eq(starter[1].transactionType, Catalogue.TX.Onboarding)
	Check.eq(starter[1].amount, Economy.STARTING_CASH)
	Check.eq(starter[1].balance, profile.cash)
	Check.eq(field(starter[1], Catalogue.FIELD_KEY.Three), "Onboarded - No")
	local plot = named(records, Catalogue.CUSTOM.PlotAssigned)
	Check.eq(#plot, 1)
	Check.eq(field(plot[1], Catalogue.FIELD_KEY.One), "Rule - Lowest")
	Check.eq(plot[1].value, 1)
	Check.eq(sent(), 0)
	Check.eq(#printed >= 3, true)

	local returning, back = openHub()
	local again = Schema.newProfile(now - 4 * DAY, "old")
	again.onboarding.step = 8
	again.analytics.funnelStep = 9
	local backSession = sessionFor(again, "back")
	Check.eq(
		returning.bootstrap(PLAYER, backSession, {
			fresh = false,
			seenUnix = now - DAY,
			now = now,
			rule = "reserved",
		}),
		true
	)
	Check.eq(#funnelNames(back), 0)
	Check.eq(#named(back, Catalogue.SKU.StarterCash), 0)
	local came = named(back, Catalogue.CUSTOM.PlayerReturned)
	Check.eq(#came, 1)
	Check.eq(came[1].value, 4)
	Check.eq(field(came[1], Catalogue.FIELD_KEY.One), "Day - 2-6")
	Check.eq(field(came[1], Catalogue.FIELD_KEY.Two), "Onboarded - Yes")
	Check.eq(field(named(back, Catalogue.CUSTOM.PlotAssigned)[1], Catalogue.FIELD_KEY.One), "Rule - Reserved")
end)

Check.test("PlayerReturned uses lastSeenUnix and fires once per UTC day", function()
	local hub, records = openHub()
	local now = 40 * DAY + 100
	local profile = Schema.newProfile(now, "returner")
	profile.firstJoinUnix = now - 7 * DAY
	profile.analytics.lastReturnDay = 0
	local session = sessionFor(profile, "return-day")
	Check.eq(hub.returned(PLAYER, session, now, now), false)
	Check.eq(#named(records, Catalogue.CUSTOM.PlayerReturned), 0)
	Check.eq(hub.returned(PLAYER, session, now, now - 2 * DAY), true)
	Check.eq(hub.returned(PLAYER, session, now, now - 2 * DAY), false)
	local first = named(records, Catalogue.CUSTOM.PlayerReturned)[1]
	Check.eq(first.value, 7)
	Check.eq(field(first, Catalogue.FIELD_KEY.One), "Day - 7")
	Check.eq(field(first, Catalogue.FIELD_KEY.Two), "Onboarded - No")
	local later = now + DAY
	Check.eq(hub.returned(PLAYER, session, later, now - 2 * DAY), true)
	local second = named(records, Catalogue.CUSTOM.PlayerReturned)[2]
	Check.eq(second.value, 8)
	Check.eq(field(second, Catalogue.FIELD_KEY.One), "Day - 8-29")
	Check.eq(profile.analytics.lastReturnDay, Catalogue.utcDay(later))
end)

Check.test("the rite logs steps 1 to 9 in order and a skip logs neither catch", function()
	local hub, records = openHub()
	local profile = Schema.newProfile(1_000, "rite")
	local session = sessionFor(profile, "rite")
	hub.bootstrap(PLAYER, session, {
		fresh = true,
		seenUnix = 1_000,
		now = 1_000,
		rule = "friend",
	})
	local function walk(seconds: number)
		Transactions.creditIncome(profile, seconds)
	end
	local function cross(before: number)
		hub.advanced(PLAYER, session, before)
	end
	local function idleUntil(cost: number)
		local waited = 0
		while profile.cash + 1e-9 < cost do
			walk(1)
			waited += 1
			Check.eq(waited <= 40, true, "cash wait")
		end
	end

	local before = profile.onboarding.step
	walk(Onboarding.GOAL_ONE_SECONDS)
	cross(before)
	Check.eq(profile.onboarding.step, 2)

	before = profile.onboarding.step
	walk(12)
	local cashBefore = profile.cash
	Check.truthy(Transactions.buyRift(profile, 1, 1, "rift-a"))
	hub.rift(PLAYER, session, cashBefore, Species.RIFT_1_ID)
	cross(before)
	Check.eq(profile.onboarding.step, 3)

	before = profile.onboarding.step
	walk(16)
	Check.truthy(Transactions.grantWild(profile, 2, "wild-a"))
	cross(before)
	Check.eq(hub.catch(PLAYER, session, 3.4, true), true)
	Check.eq(profile.onboarding.step, 4)

	before = profile.onboarding.step
	walk(12)
	cashBefore = profile.cash
	Check.truthy(Transactions.unlockPad(profile, 3))
	hub.pad(PLAYER, session, 3, cashBefore)
	cross(before)
	Check.eq(profile.onboarding.step, 5)

	before = profile.onboarding.step
	idleUntil(Economy.ALTAR_COST[1])
	cashBefore = profile.cash
	Check.truthy(Transactions.upgradeBoneAltar(profile))
	hub.altar(PLAYER, session, profile.upgrades.boneAltar, cashBefore)
	cross(before)
	Check.eq(profile.onboarding.step, 6)

	before = profile.onboarding.step
	idleUntil(Economy.PAD_COST[4])
	cashBefore = profile.cash
	Check.truthy(Transactions.unlockPad(profile, 4))
	hub.pad(PLAYER, session, 4, cashBefore)
	cross(before)
	Check.eq(profile.onboarding.step, 7)

	before = profile.onboarding.step
	walk(12)
	cashBefore = profile.cash
	Check.truthy(Transactions.buyRift(profile, 2, 3, "rift-b"))
	hub.rift(PLAYER, session, cashBefore, Species.RIFT_2_ID)
	cross(before)
	Check.eq(profile.onboarding.step, 8)

	local names = funnelNames(records)
	Check.eq(names[1], "Joined")
	Check.eq(names[2], "Starter Earning")
	Check.eq(names[3], "Claimed Rift Cryptid 1")
	Check.eq(names[4], "Caught Hodag")
	Check.eq(names[5], "Bound Hodag on Pad 3")
	Check.eq(names[6], "Raised Bone Altar I")
	Check.eq(names[7], "Carved Pad 4")
	Check.eq(names[8], "Claimed Rift Cryptid 2")
	Check.eq(names[9], "Rite Complete")
	Check.eq(#names, 9)
	local caughtAt = 0
	local boundAt = 0
	for index, name in names do
		if name == "Caught Hodag" then
			caughtAt = index
		elseif name == "Bound Hodag on Pad 3" then
			boundAt = index
		end
	end
	Check.eq(caughtAt > 0 and boundAt > caughtAt, true)
	local times = named(records, Catalogue.CUSTOM.OnboardingStepTime)
	Check.eq(#times, 8)
	Check.eq(times[1].value, Onboarding.GOAL_ONE_SECONDS)
	Check.eq(field(times[1], Catalogue.FIELD_KEY.One), "Step - 2")
	Check.eq(field(times[8], Catalogue.FIELD_KEY.One), "Step - 9")
	local catches = named(records, Catalogue.CUSTOM.CatchCompleted)
	Check.eq(#catches, 1)
	Check.eq(catches[1].value, 3)
	Check.eq(field(catches[1], Catalogue.FIELD_KEY.One), "Rarity - Common")
	Check.eq(field(catches[1], Catalogue.FIELD_KEY.Two), "Tutorial - Yes")
	local rifts = named(records, Catalogue.SKU.Rift)
	Check.eq(#rifts, 2)
	Check.eq(rifts[1].amount, Species.get(Species.RIFT_1_ID).riftPrice)
	Check.eq(field(rifts[1], Catalogue.FIELD_KEY.Two), "Species - fresno_nightcrawler")
	Check.eq(field(rifts[2], Catalogue.FIELD_KEY.Two), "Species - hidebehind")
	Check.eq(named(records, "Pad_3")[1].amount, Economy.PAD_COST[3])
	Check.eq(named(records, "Pad_3")[1].transactionType, Catalogue.TX.Gameplay)
	Check.eq(named(records, "Pad_4")[1].amount, Economy.PAD_COST[4])
	Check.eq(named(records, "BoneAltar_1")[1].amount, Economy.ALTAR_COST[1])
	Check.eq(field(named(records, "BoneAltar_1")[1], Catalogue.FIELD_KEY.Three), "Onboarded - No")
	hub.advanced(PLAYER, session, 1)
	Check.eq(#funnelNames(records), 9)

	local skippedHub, skippedRecords = openHub()
	local skipping = Schema.newProfile(4, "skip")
	skipping.onboarding.step = 3
	skipping.onboarding.playSeconds = 40
	local skipSession = sessionFor(skipping, "skip")
	local serial = 0
	local ok, _reason, events = Transactions.skip(skipping, 4, function()
		serial += 1
		return "skip-hodag-" .. tostring(serial)
	end)
	Check.eq(ok, true)
	Check.eq(#events, 0)
	Check.eq(skipping.onboarding.skipped, true)
	Check.eq(ProfileQuery.countSpecies(skipping, Species.WILD_ID), 1)
	Check.eq(skippedHub.skipped(PLAYER, skipSession, 3), true)
	Check.eq(skippedHub.skipped(PLAYER, skipSession, 3), false)
	Check.eq(skippedHub.advanced(PLAYER, skipSession, 3), false)
	Check.eq(#funnelNames(skippedRecords), 0)
	Check.eq(#named(skippedRecords, Catalogue.CUSTOM.CatchCompleted), 0)
	local skip = named(skippedRecords, Catalogue.CUSTOM.OnboardingSkipped)
	Check.eq(#skip, 1)
	Check.eq(skip[1].value, 3)
	Check.eq(field(skip[1], Catalogue.FIELD_KEY.One), "PlaySec - 31-60")
end)

Check.test("one advance can log several steps and a rejoin does not repeat them", function()
	local hub, records = openHub()
	local profile = Schema.newProfile(50, "jump")
	profile.onboarding.playSeconds = Onboarding.GOAL_ONE_SECONDS
	profile.cryptids.rift = {
		speciesId = Species.RIFT_1_ID,
		mutation = "",
		traits = {},
		acquiredAt = 50,
		source = "rift",
	}
	profile.pads["2"] = "rift"
	local session = sessionFor(profile, "jump")
	hub.joined(PLAYER, session)
	OnboardingGoals.advance(profile)
	Check.eq(profile.onboarding.step, 3)
	hub.advanced(PLAYER, session, 1)
	local names = funnelNames(records)
	Check.eq(names[1], "Joined")
	Check.eq(names[2], "Starter Earning")
	Check.eq(names[3], "Claimed Rift Cryptid 1")
	Check.eq(#names, 3)

	local rejoin, again = openHub()
	local back = Schema.newProfile(80, "back")
	back.onboarding.step = 4
	back.analytics.funnelStep = 4
	back.firstJoinUnix = 80 - 2 * DAY
	local backSession = sessionFor(back, "rejoin")
	rejoin.bootstrap(PLAYER, backSession, {
		fresh = false,
		seenUnix = 80 - DAY,
		now = 80,
		rule = "friend",
	})
	rejoin.advanced(PLAYER, backSession, 1)
	Check.eq(#funnelNames(again), 0)
	back.onboarding.step = 5
	rejoin.advanced(PLAYER, backSession, 4)
	Check.eq(funnelNames(again)[1], "Bound Hodag on Pad 3")
	Check.eq(#funnelNames(again), 1)
end)

Check.test("SessionEnded fires once across leave and shutdown", function()
	local nowClock = 0
	local hub, records = openHub(function()
		return nowClock
	end)
	local profile = Schema.newProfile(2 * DAY, "leave")
	profile.onboarding.step = 8
	profile.onboarding.skipped = true
	local session = sessionFor(profile, "leave")
	session.bornAt = 10
	session.pendingIncome = 6
	profile.cash = 31
	Check.eq(hub.finishExit(PLAYER, session, 5 * DAY, 40), false)
	Check.eq(hub.beginExit(session), true)
	Check.eq(hub.beginExit(session), false)
	Check.eq(hub.finishExit(PLAYER, session, 5 * DAY, 40), true)
	Check.eq(hub.finishExit(PLAYER, session, 5 * DAY, 40), false)
	local ended = named(records, Catalogue.CUSTOM.SessionEnded)
	Check.eq(#ended, 1)
	Check.eq(ended[1].value, 30)
	Check.eq(field(ended[1], Catalogue.FIELD_KEY.One), "Onboarded - No")
	Check.eq(field(ended[1], Catalogue.FIELD_KEY.Two), "Tenure - Returning")
	Check.eq(field(ended[1], Catalogue.FIELD_KEY.Three), "Day - 2-6")
	local income = named(records, Catalogue.SKU.PadIncome)
	Check.eq(#income, 1)
	Check.eq(income[1].amount, 6)
	Check.eq(income[1].flow, Catalogue.FLOW.Source)
	Check.eq(income[1].balance, 31)

	local other, otherRecords = openHub()
	local second = sessionFor(Schema.newProfile(10, "shutdown"), "shutdown")
	second.bornAt = 3
	Check.eq(other.beginExit(second), true)
	Check.eq(other.beginExit(second), false)
	Check.eq(other.finishExit(PLAYER, second, 10, 8), true)
	Check.eq(#named(otherRecords, Catalogue.CUSTOM.SessionEnded), 1)
	Check.eq(named(otherRecords, Catalogue.CUSTOM.SessionEnded)[1].value, 5)
	Check.eq(field(named(otherRecords, Catalogue.CUSTOM.SessionEnded)[1], Catalogue.FIELD_KEY.Two), "Tenure - New")
	Check.eq(field(named(otherRecords, Catalogue.CUSTOM.SessionEnded)[1], Catalogue.FIELD_KEY.Three), "Day - 0")
end)

Check.test("pad income is one batch per refresh and rejected sinks log nothing", function()
	local nowClock = 0
	local hub, records = openHub(function()
		return nowClock
	end)
	local profile = Schema.newProfile(1, "income")
	profile.cash = 40
	local session = sessionFor(profile, "income")
	for _ = 1, 40 do
		hub.noteIncome(session, 1)
	end
	Check.eq(#named(records, Catalogue.SKU.PadIncome), 0)
	Check.eq(hub.flushIncome(PLAYER, session, nowClock, false), true)
	Check.eq(#named(records, Catalogue.SKU.PadIncome), 1)
	Check.eq(named(records, Catalogue.SKU.PadIncome)[1].amount, 40)
	hub.noteIncome(session, 5)
	Check.eq(hub.flushIncome(PLAYER, session, nowClock + 10, false), false)
	Check.eq(#named(records, Catalogue.SKU.PadIncome), 1)
	profile.cash = 45
	Check.eq(hub.flushIncome(PLAYER, session, nowClock + 10, true), true)
	Check.eq(named(records, Catalogue.SKU.PadIncome)[2].amount, 5)
	Check.eq(named(records, Catalogue.SKU.PadIncome)[2].balance, 45)

	local broke = Schema.newProfile(1, "broke")
	broke.cash = 0
	broke.onboarding.step = 4
	Check.eq(Transactions.unlockPad(broke, 3), false)
	Check.eq(broke.cash, 0)
	local brokeSession = sessionFor(broke, "broke")
	Check.eq(hub.pad(PLAYER, brokeSession, 3, broke.cash), false)
	Check.eq(hub.pad(PLAYER, brokeSession, 7, 100), false)
	broke.cash = 100
	Check.eq(hub.pad(PLAYER, brokeSession, 7, 100), false)
	Check.eq(hub.altar(PLAYER, brokeSession, 3, 100), false)
	Check.eq(hub.rift(PLAYER, brokeSession, broke.cash, "not-a-species"), false)
	Check.eq(#named(records, "Pad_7"), 0)
	Check.eq(#named(records, "BoneAltar_3"), 0)
end)

Check.test("cash sources and sinks reconcile and a priced product with no id does not log", function()
	local hub, records = openHub()
	local profile = Schema.newProfile(3, "books")
	local session = sessionFor(profile, "books")
	hub.starter(PLAYER, session)
	profile.cash = profile.cash + 40
	hub.noteIncome(session, 40)
	hub.flushIncome(PLAYER, session, 0, true)
	local before = profile.cash
	profile.cash = before - 50
	hub.rift(PLAYER, session, before, Species.RIFT_1_ID)
	local sources = Economy.STARTING_CASH + 40
	local sinks = 50
	Check.eq(sources - sinks, profile.cash)
	Check.eq(
		named(records, Catalogue.SKU.StarterCash)[1].amount
			+ named(records, Catalogue.SKU.PadIncome)[1].amount
			- named(records, Catalogue.SKU.Rift)[1].amount,
		profile.cash
	)

	for _, entry in Monetisation.items() do
		Check.eq(hub.purchaseStatus(entry), "id")
		Check.eq(hub.purchase(PLAYER, session, entry), false)
	end
	local missingPrice = {
		kind = "pass",
		feature = true,
		id = 15,
	}
	Check.eq(hub.purchaseStatus(missingPrice), "price")
	missingPrice.catalogPrice = 49
	Check.eq(hub.purchaseStatus(missingPrice), "blocked")
	Check.eq(hub.purchase(PLAYER, session, missingPrice), false)
	Check.eq(#named(records, Catalogue.TX.IAP), 0)
end)

Check.test("the pedlar funnel logs an open, a refused buy, and one success", function()
	local hub, records = openHub()
	local profile = Schema.newProfile(9, "pedlar")
	profile.onboarding.step = 8
	profile.cash = 1_000
	local session = sessionFor(profile, "pedlar")
	Check.eq(hub.pedlarPressed(PLAYER, session), false)
	Check.eq(hub.pedlarOpen(PLAYER, session, 4, "funnel-open"), true)
	Check.eq(named(records, Catalogue.PEDLAR_FUNNEL)[1].stepName, "Opened")
	Check.eq(field(named(records, Catalogue.PEDLAR_FUNNEL)[1], Catalogue.FIELD_KEY.One), "Onboarded - Yes")
	hub.pedlarStale(session)
	Check.eq(hub.pedlarPressed(PLAYER, session), true)
	Check.eq(hub.pedlarPurchase(PLAYER, session, 2, Species.RIFT_2_ID, profile.cash), false)
	local steps = {}
	for _, record in named(records, Catalogue.PEDLAR_FUNNEL) do
		table.insert(steps, record.stepName)
	end
	Check.eq(steps[1], "Opened")
	Check.eq(steps[2], "Buy Pressed")
	Check.eq(steps[3], nil)

	local shop, shopRecords = openHub()
	local buyer = Schema.newProfile(9, "buyer")
	buyer.onboarding.step = 8
	buyer.cash = 1_000
	local buyerSession = sessionFor(buyer, "buyer")
	shop.pedlarOpen(PLAYER, buyerSession, 8, "funnel-buy")
	shop.pedlarPressed(PLAYER, buyerSession)
	local firstSpecies = "uncommon_01"
	local price = 100
	local before = buyer.cash
	buyer.cash = before - price
	shop.pedlarPurchase(PLAYER, buyerSession, 2, firstSpecies, before)
	before = buyer.cash
	buyer.cash = before - price
	shop.pedlarPurchase(PLAYER, buyerSession, 2, firstSpecies, before)
	local funnelSteps = {}
	for _, record in named(shopRecords, Catalogue.PEDLAR_FUNNEL) do
		table.insert(funnelSteps, record.stepName)
	end
	Check.eq(funnelSteps[1], "Opened")
	Check.eq(funnelSteps[2], "Buy Pressed")
	Check.eq(funnelSteps[3], "Bought")
	Check.eq(funnelSteps[4], nil)
	local sinks = named(shopRecords, "Pedlar_Uncommon")
	Check.eq(#sinks, 2)
	Check.eq(sinks[1].amount, price)
	Check.eq(field(sinks[1], Catalogue.FIELD_KEY.One), "Slot - 2")
	Check.eq(field(sinks[1], Catalogue.FIELD_KEY.Two), "Species - uncommon_01")
	Check.eq(field(sinks[1], Catalogue.FIELD_KEY.Three), "Onboarded - Yes")
	Check.eq(sinks[1].transactionType, Catalogue.TX.Shop)
end)

Check.test("catch spam stops at six a minute and SessionEnded still fires", function()
	local nowClock = 1_000
	local hub, records = openHub(function()
		return nowClock
	end)
	local session = sessionFor(Schema.newProfile(1, "catch"), "catch")
	for _ = 1, Catalogue.RATE_PER_MINUTE do
		Check.eq(hub.catch(PLAYER, session, 4, false), true)
	end
	Check.eq(hub.catch(PLAYER, session, 4, false), false)
	Check.eq(#named(records, Catalogue.CUSTOM.CatchCompleted), Catalogue.RATE_PER_MINUTE)
	Check.eq(field(named(records, Catalogue.CUSTOM.CatchCompleted)[1], Catalogue.FIELD_KEY.Two), "Tutorial - No")
	session.bornAt = 980
	Check.eq(hub.beginExit(session), true)
	Check.eq(hub.finishExit(PLAYER, session, 1, nowClock), true)
	Check.eq(#named(records, Catalogue.CUSTOM.SessionEnded), 1)
	nowClock += Catalogue.RATE_WINDOW_SECONDS
	local later = sessionFor(Schema.newProfile(1, "later"), "catch")
	Check.eq(hub.catch(PLAYER, later, 4, true), true)
end)

Check.test("a studio sink prints and a live failure does not escape", function()
	local _hub, records, printed, sent = openHub()
	local profile = Schema.newProfile(1, "studio")
	local session = sessionFor(profile, "studio")
	Check.eq(_hub.joined(PLAYER, session), true)
	Check.eq(sent(), 0)
	Check.eq(#printed, 1)
	Check.eq(#records, 1)

	local blew = false
	local live = Analytics.open({
		isStudio = false,
		clock = function()
			return 0
		end,
		print = function()
			blew = true
		end,
		send = function()
			error("analytics down")
		end,
	})
	local profileLive = Schema.newProfile(1, "live")
	local ok, result = pcall(function()
		return live.starter(PLAYER, sessionFor(profileLive, "live"))
	end)
	Check.eq(ok, true)
	Check.eq(result, false)
	Check.eq(blew, false)
end)

Check.test("ledger load reports the reason and the seen time from before the fold", function()
	local clock = 1_700_000_000
	local function open(store: any): any
		return Ledger.open({
			getStore = function()
				return store
			end,
			createMock = function()
				error("store was provided")
			end,
			allowMock = function()
				return false
			end,
			jobId = "analytics-job",
			now = function()
				return clock
			end,
			waitFor = function() end,
			warn = function() end,
			settle = function(profile: any, now: number)
				local prior = profile.lastSeenUnix
				Offline.fold(profile, now)
				return prior
			end,
		})
	end

	local createdStore = MockDataStore.new()
	local created = open(createdStore).load(7, Schema.newProfile(clock, "created"))
	Check.eq(created.ok, true)
	Check.eq(created.fresh, true)
	Check.eq(created.seenUnix, clock)
	Check.eq(created.profile.analytics.funnelStep, 0)
	Check.eq(created.profile.analytics.lastReturnDay, 0)

	created.profile.firstJoinUnix = clock - 10 * DAY
	created.profile.lastSeenUnix = clock - 3 * DAY
	created.profile.analytics.lastReturnDay = 4
	created.profile.analytics.funnelStep = 4
	local ledger = open(createdStore)
	ledger.load(7, Schema.newProfile(clock, "ignored"))
	Check.eq(ledger.save(7, created.profile), true)
	local returned = ledger.load(7, Schema.newProfile(clock, "ignored-again"))
	Check.eq(returned.fresh, false)
	Check.eq(returned.seenUnix, clock - 3 * DAY)
	Check.eq(returned.profile.lastSeenUnix, clock)
	Check.eq(returned.profile.analytics.lastReturnDay, 4)
	Check.eq(returned.profile.analytics.funnelStep, 4)
	Check.eq(returned.profile.firstJoinUnix, clock - 10 * DAY)

	local lockedStore = MockDataStore.new()
	lockedStore:SeedLock(Save.KEY_PREFIX .. "8", "other-job", clock + 500, Schema.newProfile(clock, "held"))
	local locked = open(lockedStore).load(8, Schema.newProfile(clock, "held-new"))
	Check.eq(locked.ok, false)
	Check.eq(locked.reason, "locked")
	Check.eq(locked.attempts, Save.MAX_ATTEMPTS)
	Check.eq(locked.message, Save.KICK_LOCKED)

	local corruptStore = MockDataStore.new()
	corruptStore:SetAsync(Save.KEY_PREFIX .. "9", {
		lockJobId = "",
		lockExpiresAt = 0,
		profile = false,
	})
	local corrupt = open(corruptStore).load(9, Schema.newProfile(clock, "bad"))
	Check.eq(corrupt.ok, false)
	Check.eq(corrupt.reason, "corrupt")
	Check.eq(corrupt.attempts, 1)

	local failedStore = MockDataStore.new()
	failedStore:FailNext("UpdateAsync", Save.MAX_ATTEMPTS, "503 unavailable")
	local failed = open(failedStore).load(10, Schema.newProfile(clock, "down"))
	Check.eq(failed.ok, false)
	Check.eq(failed.reason, "read")
	Check.eq(failed.attempts, Save.MAX_ATTEMPTS)

	local hub, records = openHub()
	Check.eq(hub.ledger(PLAYER, locked.attempts, locked.reason), true)
	Check.eq(hub.ledger(PLAYER, corrupt.attempts, corrupt.reason), true)
	Check.eq(hub.ledger(PLAYER, failed.attempts, failed.reason), true)
	Check.eq(hub.ledger(PLAYER, failed.attempts, Save.KEY_PREFIX .. "10"), true)
	local reasons = named(records, Catalogue.CUSTOM.LedgerLoadFailed)
	Check.eq(reasons[1].value, Save.MAX_ATTEMPTS)
	Check.eq(field(reasons[1], Catalogue.FIELD_KEY.One), "Reason - Locked")
	Check.eq(field(reasons[2], Catalogue.FIELD_KEY.One), "Reason - Corrupt")
	Check.eq(reasons[2].value, 1)
	Check.eq(field(reasons[3], Catalogue.FIELD_KEY.One), "Reason - ReadFailed")
	Check.eq(field(reasons[4], Catalogue.FIELD_KEY.One), "Reason - ReadFailed")
	Check.eq(string.find(Catalogue.encode(reasons[4]), Save.KEY_PREFIX, 1, true), nil)
	for _, record in reasons do
		clean(Catalogue.encode(record))
	end
end)

Check.test("plot rules stay Reserved, Friend, or Lowest and carry no identity", function()
	local state = PlotAssign.empty(8)
	local lowestIndex, lowestCode = PlotAssign.explain(state, 5, nil)
	Check.eq(lowestIndex, 1)
	Check.eq(Catalogue.ruleField(lowestCode), "Rule - Lowest")
	PlotAssign.take(state, 5, nil)
	PlotAssign.reserve(state, 5)
	local reservedIndex, reservedCode = PlotAssign.explain(state, 5, { 1 })
	Check.eq(reservedIndex, PlotAssign.reservedIndex(state, 5))
	Check.eq(Catalogue.ruleField(reservedCode), "Rule - Reserved")
	local openState = PlotAssign.empty(8)
	PlotAssign.take(openState, 2, nil)
	local friendIndex, friendCode = PlotAssign.explain(openState, 9, { 1 })
	Check.eq(friendIndex, PlotAssign.choose(openState, 9, { 1 }))
	Check.eq(Catalogue.ruleField(friendCode), "Rule - Friend")
	local hub, records = openHub()
	local profile = Schema.newProfile(1, "plot")
	hub.plot(PLAYER, sessionFor(profile, "plot"), friendCode)
	local encoded = Catalogue.encode(named(records, Catalogue.CUSTOM.PlotAssigned)[1])
	Check.eq(string.find(encoded, "9", 1, true), nil)
	Check.eq(string.find(encoded, "Rule - Friend", 1, true) ~= nil, true)
end)

Check.test("qa analytics is a Studio suffix and the server never adds a remote", function()
	local marked = QaArgs.parse("qa:30:analytics")
	Check.eq(marked.analytics, true)
	Check.eq(marked.offlineSeconds, 0)
	Check.eq(WatchdogBudget.secondsFor("qa:30:analytics"), 30)
	local mixed = QaArgs.parse("qa:45:offline:10:analytics")
	Check.eq(mixed.analytics, true)
	Check.eq(mixed.offlineSeconds, 10)
	Check.eq(mixed.utcDays, 0)
	Check.eq(QaArgs.parse("qa:30:plots3").analytics, false)
	Check.eq(QaArgs.parse("play").analytics, false)

	local session = fs.readFile("src/server/PlayerSession.luau")
	local ledgerAt = string.find(session, "sink().ledger", 1, true)
	local kickAt = string.find(session, "player:Kick(loaded.message", 1, true)
	Check.truthy(ledgerAt)
	Check.truthy(kickAt)
	Check.eq((ledgerAt :: number) < (kickAt :: number), true)
	Check.eq(string.find(session, "AnalyticsService", 1, true), nil)
	Check.eq(string.find(session, "LogCustomEvent", 1, true), nil)
	Check.eq(string.find(session, "PedlarOddsViewed", 1, true), nil)
	Check.contains(session, "sink().beginExit")
	Check.contains(session, "sink().finishExit")
	Check.contains(session, "PlayerSession.onPedlarOpen")
	Check.contains(session, "PlayerSession.onPedlarRotation")

	local server = fs.readFile("src/server/Analytics.luau")
	local catalogue = fs.readFile("src/shared/Config/Analytics.luau")
	Check.contains(server, "IsStudio")
	Check.contains(server, "LogCustomEvent")
	Check.contains(server, "LogOnboardingFunnelStepEvent")
	Check.contains(server, "LogFunnelStepEvent")
	Check.contains(server, "LogEconomyEvent")
	Check.contains(server, "pcall")
	Check.contains(catalogue, "PedlarOddsViewed")
	for _, path in { "src/server/Analytics.luau", "src/shared/Config/Analytics.luau" } do
		local text = fs.readFile(path)
		Check.eq(string.find(text, ".DisplayName", 1, true), nil, path)
		Check.eq(string.find(text, ".UserId", 1, true), nil, path)
		Check.eq(string.find(text, ".Name", 1, true), nil, path)
	end
	local remotes = fs.readFile("src/shared/Config/Remotes.luau")
	Check.eq(string.find(remotes, "Analytics", 1, true), nil)
	Check.eq(string.find(remotes, "Odds", 1, true), nil)
	local gateway = fs.readFile("src/server/DataStoreGateway.luau")
	local rewindAt = string.find(gateway, "StudioQaHooks.rewindLastSeen", 1, true)
	local foldAt = string.find(gateway, "Offline.fold", 1, true)
	Check.truthy(rewindAt)
	Check.truthy(foldAt)
	Check.eq((rewindAt :: number) < (foldAt :: number), true)
	local studio = fs.readFile("src/server/Dev/StudioQa.luau")
	Check.contains(studio, "function StudioQa.analytics")
	Check.contains(studio, "IsStudio")
end)
