--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local Check = require("./check")
local Bowl = require("../src/shared/Logic/Bowl")
local Daily = require("../src/shared/Logic/Daily")
local Duration = require("../src/shared/Logic/Duration")
local Income = require("../src/shared/Logic/Income")
local OfferingCopy = require("../src/shared/Logic/OfferingCopy")
local Offline = require("../src/shared/Logic/Offline")
local Ownership = require("../src/shared/Logic/Ownership")
local QaArgs = require("../src/shared/Logic/QaArgs")
local Return = require("../src/shared/Config/Return")
local Save = require("../src/shared/Config/Save")
local Schema = require("../src/shared/Logic/Schema")
local SessionDocument = require("../src/shared/Logic/SessionDocument")
local Settings = require("../src/shared/Logic/Settings")
local Snapshot = require("../src/shared/Logic/Snapshot")
local Species = require("../src/shared/Config/Species")
local Transactions = require("../src/shared/Logic/Transactions")
local WatchdogBudget = require("../src/server/Dev/WatchdogBudget")

local function fresh(): any
	return Schema.newProfile(1_000, "starter")
end

local function ids(): () -> string
	local serial = 0
	return function()
		serial += 1
		return "offering-" .. tostring(serial)
	end
end

Check.test("offline haul matches the 2 hour and 8 hour figures", function()
	local profile = fresh()
	profile.onboarding.step = 8
	profile.offline.rate = 100
	profile.offline.rateNoPass = 100
	profile.lastSeenUnix = 1_000
	local twoHours = Offline.fold(profile, 1_000 + 2 * Return.SECONDS_PER_HOUR)
	Check.eq(twoHours.haul, 144_000)
	Check.eq(twoHours.show, true)
	Check.eq(twoHours.granted, 0)
	Check.eq(profile.offline.pending, 144_000)
	Check.eq(profile.offline.capped, false)
	Check.eq(profile.cash, 25)
	local amount, tithe = Offline.claim(profile)
	Check.eq(amount, 144_000)
	Check.eq(tithe, 144_000)
	Check.eq(profile.cash, 25 + 144_000)
	Check.eq(profile.totalEarned, 144_000)
	Check.eq(profile.tithe, 144_000)
	Check.eq(Offline.claim(profile), 0)
	Check.eq(profile.cash, 25 + 144_000)

	local capped = fresh()
	capped.onboarding.step = 8
	capped.offline.rate = 100
	capped.offline.rateNoPass = 100
	capped.lastSeenUnix = 1_000
	local twenty = 20 * Return.SECONDS_PER_HOUR
	local long = Offline.fold(capped, 1_000 + twenty)
	Check.eq(long.haul, 576_000)
	Check.eq(capped.offline.capped, true)
	Check.eq(capped.offline.awaySeconds, twenty)
	Check.eq(Offline.shows(576_000, twenty), true)
end)

Check.test("a short or negative absence pays nothing and a sub-five-minute haul is silent", function()
	local profile = fresh()
	profile.onboarding.step = 8
	profile.offline.rate = 100
	profile.offline.rateNoPass = 100
	profile.lastSeenUnix = 5_000
	local brief = Offline.fold(profile, 5_000 + 45)
	Check.eq(brief.haul, 0)
	Check.eq(brief.show, false)
	Check.eq(profile.cash, 25)
	Check.eq(profile.offline.pending, 0)

	local early = fresh()
	early.onboarding.step = 8
	early.offline.rate = 100
	early.lastSeenUnix = 9_000
	local backwards = Offline.fold(early, 8_000)
	Check.eq(backwards.haul, 0)
	Check.eq(early.cash, 25)
	Check.eq(early.lastSeenUnix, 8_000)

	local quiet = fresh()
	quiet.onboarding.step = 8
	quiet.offline.rate = 100
	quiet.offline.rateNoPass = 100
	quiet.lastSeenUnix = 2_000
	local twoMinutes = Offline.fold(quiet, 2_000 + 120)
	Check.eq(twoMinutes.haul, 2_400)
	Check.eq(twoMinutes.show, false)
	Check.eq(twoMinutes.granted, 2_400)
	Check.eq(quiet.offline.pending, 0)
	Check.eq(quiet.cash, 25 + 2_400)

	local newbie = fresh()
	newbie.onboarding.step = 7
	newbie.offline.rate = 100
	newbie.lastSeenUnix = 1_000
	local blocked = Offline.fold(newbie, 1_000 + 2 * Return.SECONDS_PER_HOUR)
	Check.eq(blocked.haul, 0)
	Check.eq(newbie.cash, 25)
end)

Check.test("a doubled leave rate books the pre-pass amount on the tithe", function()
	local profile = fresh()
	profile.onboarding.step = 8
	Offline.capture(profile, Ownership.cashMultiplier(profile, 2))
	Check.eq(profile.offline.rateNoPass, Income.perSecond(profile))
	Check.eq(profile.offline.rate, Income.perSecond(profile) * 2)
	profile.offline.rate = 200
	profile.offline.rateNoPass = 100
	profile.lastSeenUnix = 100
	local folded = Offline.fold(profile, 100 + 2 * Return.SECONDS_PER_HOUR)
	Check.eq(folded.haul, 288_000)
	Check.eq(folded.tithe, 144_000)
	local _, tithe = Offline.claim(profile)
	Check.eq(tithe, 144_000)
	Check.eq(profile.tithe, 144_000)
	Check.eq(Ownership.cashMultiplier(profile), 1)
	Check.eq(Return.CASH_DOUBLE_ENABLED, false)
	Check.eq(Return.CASH_DOUBLE_PASS_ID, nil)
end)

Check.test("the nightly offering pauses, rolls the UTC day, and pays once", function()
	local profile = fresh()
	profile.onboarding.step = 8
	profile.daily.step = 2
	local day = 1_000
	local first = day * Return.DAY_SECONDS + 10
	Check.eq(Daily.claim(profile, first, ids()), true)
	Check.eq(profile.daily.step, 3)
	Check.eq(profile.daily.lastClaimDay, day)
	Check.eq(profile.daily.totalClaims, 1)
	local skipped = (day + 3) * Return.DAY_SECONDS + 5
	Check.eq(Daily.ready(profile, skipped), true)
	Check.eq(profile.daily.step, 3)
	Check.eq(Daily.missed(profile, skipped), true)
	Check.eq(Daily.claim(profile, skipped, ids()), true)
	Check.eq(profile.daily.step, 4)

	local reset = fresh()
	reset.onboarding.step = 8
	local late = day * Return.DAY_SECONDS + 23 * Return.SECONDS_PER_HOUR + 59 * Return.SECONDS_PER_MINUTE
	local early = (day + 1) * Return.DAY_SECONDS + 5
	Check.eq(Daily.dayNumber(late), day)
	Check.eq(Daily.dayNumber(early), day + 1)
	Check.eq(Daily.claim(reset, late, ids()), true)
	Check.eq(Daily.ready(reset, late + 30), false)
	Check.eq(Daily.claim(reset, late + 30, ids()), false)
	Check.eq(reset.daily.totalClaims, 1)
	Check.eq(Daily.ready(reset, early), true)
	Check.eq(Daily.claim(reset, early, ids()), true)
	Check.eq(reset.daily.totalClaims, 2)
end)

Check.test("day 1 is offered in session 1 without opening itself", function()
	local profile = fresh()
	Check.eq(Daily.offerButton(profile), false)
	profile.onboarding.step = 8
	profile.onboarding.playSeconds = Return.BUTTON_PLAY_SECONDS - 1
	Check.eq(Daily.offerButton(profile), false)
	profile.onboarding.playSeconds = Return.BUTTON_PLAY_SECONDS
	Check.eq(Daily.offerButton(profile), true)
	Check.eq(Daily.ready(profile, 10), true)
	Check.eq(Daily.shouldAutoOpen(false, true), false)
	Check.eq(Daily.shouldAutoOpen(true, true), true)
	Check.eq(Daily.shouldAutoOpen(true, false), false)
	Check.eq(Daily.cashFor(1, 630), 189_000)
	Check.eq(Daily.cashFor(1, 0), 250)
	local broke = fresh()
	broke.onboarding.step = 8
	broke.pads["1"] = nil
	Check.eq(Income.perSecond(broke), 0)
	local before = broke.cash
	Check.eq(Daily.claim(broke, 10, ids()), true)
	Check.eq(broke.cash, before + 250)
	Check.eq(broke.tithe, 0)
	Check.eq(broke.daily.step, 2)
end)

Check.test("creature steps grant the named species once and can bind at once", function()
	Check.eq(Species.get(Species.SNALLYGASTER_ID).displayName, "Snallygaster")
	Check.eq(Species.get(Species.SNALLYGASTER_ID).baseIncome, 16)
	Check.eq(Species.get(Species.SNALLYGASTER_ID).rarity, "Uncommon")
	Check.eq(Species.get(Species.FLATWOODS_ID).displayName, "Flatwoods Monster")
	Check.eq(Species.get(Species.FLATWOODS_ID).baseIncome, 40)
	Check.eq(Species.get(Species.FLATWOODS_ID).rarity, "Rare")

	local profile = fresh()
	profile.onboarding.step = 8
	profile.daily.step = 3
	local make = ids()
	Check.eq(Daily.claim(profile, 50, make), true)
	Check.eq(profile.cryptids["offering-1"].speciesId, Species.SNALLYGASTER_ID)
	Check.eq(profile.cryptids["offering-1"].source, "offering")
	Check.eq(profile.pads["2"], nil)
	local saved = Schema.migrate(profile)
	Check.eq(saved.cryptids["offering-1"].source, "offering")
	Check.eq(saved.cryptids["offering-1"].speciesId, Species.SNALLYGASTER_ID)
	Check.eq(profile.cash, 25)

	local bound = fresh()
	bound.onboarding.step = 8
	bound.daily.step = 7
	bound.settings.bindAtOnce = true
	local cashBefore = bound.cash
	local rateBefore = Income.perSecond(bound)
	Check.eq(Daily.claim(bound, 80, ids()), true)
	Check.eq(bound.cryptids["offering-1"].speciesId, Species.FLATWOODS_ID)
	Check.eq(bound.pads["2"], "offering-1")
	Check.eq(bound.cash, cashBefore + Daily.cashFor(7, rateBefore))
	Check.eq(bound.daily.step, 1)
	Check.eq(Daily.claim(bound, 80, ids()), false)
	Check.eq(bound.daily.totalClaims, 1)
end)

Check.test("the bowl holds outside income and banks on the threshold or the forced hook", function()
	local profile = fresh()
	profile.onboarding.step = 8
	local cash = profile.cash
	local gained, changed = Bowl.route(profile, 6_000, false, false)
	Check.eq(gained, 0)
	Check.eq(changed, true)
	Check.eq(profile.bowl, 6_000)
	Check.eq(profile.cash, cash)
	Check.eq(profile.totalEarned, 0)
	local banked = Bowl.route(profile, 0, true, false)
	Check.eq(banked, 6_000)
	Check.eq(profile.bowl, 0)
	Check.eq(profile.cash, cash + 6_000)
	Check.eq(profile.totalEarned, 6_000)
	Check.eq(OfferingCopy.bowlLine(12_400), "In the bowl: $12.4K")

	local auto = fresh()
	auto.onboarding.step = 8
	local start = auto.cash
	Check.eq(Return.AUTO_COLLECT_ENABLED, false)
	Check.eq(Return.AUTO_COLLECT_PASS_ID, nil)
	Check.eq(Ownership.autoCollect(auto), false)
	for _ = 1, 5 do
		Transactions.creditIncome(auto, Return.AUTO_COLLECT_SECONDS, false, Ownership.autoCollect(auto, true))
	end
	Check.eq(auto.bowl, 0)
	Check.eq(auto.cash, start + 5 * Income.perSecond(auto))

	local held = fresh()
	held.onboarding.step = 8
	Transactions.creditIncome(held, 60, false, false)
	Check.eq(held.bowl, Income.perSecond(held) * 60)
	local beforeGate = fresh()
	local credited = Transactions.creditIncome(beforeGate, 1, false, false)
	Check.eq(credited, Income.perSecond(beforeGate))
	Check.eq(beforeGate.bowl, 0)
end)

Check.test("settings stay inside their ranges and the v5 migration is idempotent", function()
	local profile = fresh()
	Check.eq(profile.settings.sfx, 1)
	Check.eq(profile.settings.music, 1)
	Check.eq(profile.settings.effectsQuality, "High")
	Check.eq(profile.settings.reducedMotion, false)
	Check.eq(Settings.apply(profile, "sfx", 0), true)
	Check.eq(Settings.apply(profile, "music", 0.25), true)
	Check.eq(Settings.apply(profile, "effectsQuality", "Low"), true)
	Check.eq(Settings.apply(profile, "reducedMotion", true), true)
	Check.eq(profile.settings.sfx, 0)
	Check.eq(profile.settings.music, 0.25)
	Check.eq(profile.settings.effectsQuality, "Low")
	Check.eq(Settings.apply(profile, "sfx", 1.01), false)
	Check.eq(Settings.apply(profile, "sfx", -0.01), false)
	Check.eq(Settings.apply(profile, "music", 0 / 0), false)
	Check.eq(Settings.apply(profile, "effectsQuality", "high"), false)
	Check.eq(Settings.apply(profile, "effectsQuality", "Ultra"), false)
	Check.eq(Settings.apply(profile, "bindAtOnce", true), false)
	Check.eq(Settings.apply(profile, "cash", 1), false)
	Check.eq(profile.settings.sfx, 0)
	Check.eq(profile.settings.effectsQuality, "Low")
	Check.eq(profile.settings.bindAtOnce, false)

	local legacy = fresh()
	legacy.dataVersion = 4
	legacy.cash = 80
	legacy.settings.reducedMotion = true
	legacy.settings.bindAtOnce = true
	legacy.daily = nil
	legacy.offline = nil
	legacy.bowl = nil
	legacy.tithe = nil
	legacy.lastSeenUnix = nil
	legacy.settings.sfx = nil
	legacy.settings.music = nil
	legacy.settings.effectsQuality = nil
	local migrated = Schema.migrate(legacy, 12_345)
	Check.truthy(migrated)
	Check.eq(migrated.dataVersion, Save.DATA_VERSION)
	Check.eq(Save.DATA_VERSION, 5)
	Check.eq(migrated.lastSeenUnix, 12_345)
	Check.eq(migrated.daily.step, 1)
	Check.eq(migrated.daily.lastClaimDay, -1)
	Check.eq(migrated.daily.totalClaims, 0)
	Check.eq(migrated.bowl, 0)
	Check.eq(migrated.tithe, 0)
	Check.eq(migrated.offline.pending, 0)
	Check.eq(migrated.settings.sfx, 1)
	Check.eq(migrated.settings.music, 1)
	Check.eq(migrated.settings.effectsQuality, "High")
	Check.eq(migrated.settings.reducedMotion, true)
	Check.eq(migrated.settings.bindAtOnce, true)
	Check.eq(migrated.cash, 80)
	Check.eq(legacy.dataVersion, 4)
	Check.eq(legacy.lastSeenUnix, nil)
	local again = Schema.migrate(migrated, 99_999)
	Check.eq(again.lastSeenUnix, 12_345)
	Check.eq(again.daily.step, 1)
	Check.eq(again.settings.sfx, 1)
	Check.eq(again.settings.reducedMotion, true)
	Check.eq(Schema.migrate(again, 1).settings.music, 1)

	local future = fresh()
	future.dataVersion = Save.DATA_VERSION + 1
	Check.eq(Schema.migrate(future), nil)
	local broken = fresh()
	broken.settings.sfx = 2
	Check.eq(Schema.migrate(broken), nil)
	Check.eq(broken.settings.sfx, 2)

	local document, status = SessionDocument.buildWrite({
		lockJobId = "",
		lockExpiresAt = 0,
		profile = legacy,
	}, "job", 8_000, 90, fresh())
	Check.eq(status, "loaded")
	Check.eq(document.profile.dataVersion, 5)
	Check.eq(document.profile.lastSeenUnix, 8_000)
	Check.eq(document.profile.daily.lastClaimDay, -1)
end)

Check.test("studio qa suffixes do not disturb the watchdog", function()
	local tokens = QaArgs.parse("qa:300:offline:7200:utc:1")
	Check.eq(tokens.offlineSeconds, 7_200)
	Check.eq(tokens.utcDays, 1)
	Check.eq(tokens.utcJumpSeconds, 0)
	Check.eq(WatchdogBudget.secondsFor("qa:300:offline:7200:utc:1"), 300)
	local jump = QaArgs.parse("qa:120:utcjump:30")
	Check.eq(jump.utcJumpSeconds, 30)
	Check.eq(jump.offlineSeconds, 0)
	local plots = QaArgs.parse("qa:420:plots3")
	Check.eq(plots.offlineSeconds, 0)
	Check.eq(plots.utcDays, 0)
	Check.eq(WatchdogBudget.secondsFor("qa:420:plots3"), 420)
	Check.eq(QaArgs.parse("play").offlineSeconds, 0)
	Check.eq(QaArgs.parse(nil).utcDays, 0)
end)

Check.test("haul and offering copy stays free of shop prompts", function()
	Check.eq(Duration.phrase(7 * Return.SECONDS_PER_HOUR + 42 * Return.SECONDS_PER_MINUTE), "7h 42m")
	Check.eq(
		OfferingCopy.haulBody(7 * Return.SECONDS_PER_HOUR + 42 * Return.SECONDS_PER_MINUTE),
		"Your menagerie fed the coffers for 7h 42m."
	)
	Check.eq(OfferingCopy.haulDetail(), "Lairs earn at 20% while you're away, for up to 8 hours.")
	Check.eq(OfferingCopy.haulCap(), "Your lair stops gathering after 8 hours away.")
	Check.eq(Return.HAUL_TITLE, "While you were gone…")
	Check.eq(Return.HAUL_BUTTON, "Take the haul")
	Check.eq(Return.OFFERING_TITLE, "The Nightly Offering")
	Check.eq(Return.OFFERING_ACCEPT, "Accept the offering")
	Check.eq(Return.OFFERING_TOMORROW, "Return tomorrow for the next offering.")
	Check.eq(Return.OFFERING_WAITED, "The offering waited for you.")
	Check.eq(
		OfferingCopy.countdown(7 * Return.SECONDS_PER_HOUR + 12 * Return.SECONDS_PER_MINUTE),
		"Next offering in 7h 12m"
	)
	Check.eq(OfferingCopy.progress(1), "1 of 7")

	local profile = fresh()
	profile.onboarding.step = 8
	profile.onboarding.playSeconds = 180
	profile.offline.pending = 144_000
	profile.offline.awaySeconds = 7_200
	profile.offline.capped = false
	local snap = Snapshot.build(profile, 0, 1, {
		now = 10,
		dailyAutoOpen = false,
	})
	Check.eq(snap.haul.show, true)
	Check.eq(snap.haul.pending, 144_000)
	Check.eq(snap.daily.button, true)
	Check.eq(snap.daily.autoOpen, false)
	Check.eq(snap.daily.ready, true)
	Check.eq(snap.settings.sfx, 1)
	Check.eq(snap.settings.effectsQuality, "High")
	Check.eq(#snap.daily.steps, 7)
	Check.eq(snap.daily.steps[3].displayName, "Snallygaster")
	Check.eq(snap.daily.steps[7].displayName, "Flatwoods Monster")

	local files = {
		"src/client/HaulPanel.luau",
		"src/client/OfferingPanel.luau",
		"src/shared/Config/Return.luau",
		"src/shared/Logic/OfferingCopy.luau",
	}
	for _, path in files do
		local text = fs.readFile(path)
		Check.eq(string.find(text, "MarketplaceService", 1, true), nil, path)
		Check.eq(string.find(text, "PromptProductPurchase", 1, true), nil, path)
		Check.eq(string.find(text, "Robux", 1, true), nil, path)
		Check.eq(string.find(text, "Revive", 1, true), nil, path)
		Check.eq(string.find(text, "ProcessReceipt", 1, true), nil, path)
	end
	local offering = fs.readFile("src/client/OfferingPanel.luau")
	Check.contains(offering, "Return.OFFERING_TITLE")
	Check.contains(offering, "Return.OFFERING_ACCEPT")
	local haul = fs.readFile("src/client/HaulPanel.luau")
	Check.contains(haul, "Return.HAUL_TITLE")
	Check.contains(haul, "Return.HAUL_BUTTON")
	Check.eq(string.find(haul, "Color3.new", 1, true), nil)
	Check.eq(string.find(offering, "Color3.new", 1, true), nil)
end)
