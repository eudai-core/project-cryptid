--!strict

_G.LUNE = true

local Check = require("./check")
local Analytics = require("../src/shared/Config/Analytics")
local BoneAltar = require("../src/shared/Config/BoneAltar")
local Economy = require("../src/shared/Config/Economy")
local Onboarding = require("../src/shared/Config/Onboarding")
local Species = require("../src/shared/Config/Species")
local Save = require("../src/shared/Config/Save")
local UITheme = require("../src/shared/UITheme")
local Schema = require("../src/shared/Logic/Schema")
local Income = require("../src/shared/Logic/Income")
local Transactions = require("../src/shared/Logic/Transactions")
local OnboardingGoals = require("../src/shared/Logic/OnboardingGoals")
local ProfileQuery = require("../src/shared/Logic/ProfileQuery")
local Debounce = require("../src/shared/Logic/Debounce")
local StealGuard = require("../src/shared/Logic/StealGuard")
local Snapshot = require("../src/shared/Logic/Snapshot")
local RemoteArgs = require("../src/shared/Logic/RemoteArgs")
local serde = require("@lune/serde")

local function fresh(): any
	return Schema.newProfile(1_700_000_000, "starter")
end

local function earnUntil(profile: any, cost: number): number
	local ticks = 0
	while profile.cash + 1e-9 < cost and ticks < 5000 do
		Transactions.creditIncome(profile, 1)
		ticks += 1
	end
	return ticks
end

Check.test("species and economy match spec 01", function()
	Check.eq(Species.get(Species.STARTER_ID).displayName, "Mothman Hatchling")
	Check.eq(Species.get(Species.STARTER_ID).baseIncome, 2)
	Check.eq(Species.get(Species.STARTER_ID).rarity, "Common")
	Check.eq(Species.get(Species.RIFT_1_ID).displayName, "Fresno Nightcrawler")
	Check.eq(Species.get(Species.RIFT_1_ID).baseIncome, 3)
	Check.eq(Species.get(Species.RIFT_1_ID).riftPrice, 50)
	Check.eq(Species.get(Species.RIFT_2_ID).displayName, "Hidebehind")
	Check.eq(Species.get(Species.RIFT_2_ID).baseIncome, 4)
	Check.eq(Species.get(Species.RIFT_2_ID).riftPrice, 75)
	Check.eq(Species.WILD_ID, "hodag")
	Check.eq(Species.get(Species.WILD_ID).displayName, "Hodag")
	Check.eq(Species.get(Species.WILD_ID).rarity, "Common")
	Check.eq(Species.get(Species.WILD_ID).baseIncome, 5)
	Check.eq(Economy.STARTING_CASH, 25)
	Check.eq(Economy.PAD_COST[3], 120)
	Check.eq(Economy.PAD_COST[4], 400)
	Check.eq(Economy.PAD_COST[5], 1200)
	Check.eq(Economy.PAD_COST[6], 3000)
	Check.eq(Economy.ALTAR_COST[1], 300)
	Check.eq(Economy.ALTAR_COST[2], 1500)
	Check.eq(Economy.ALTAR_COST[3], 8000)
	Check.eq(Economy.ALTAR_COST[10], 625000000)
	Check.eq(Economy.MAX_ALTAR_LEVEL, 10)
	Check.eq(Species.GUARANTEES[2].pad, 4)
	Check.eq(Economy.WARD_CANDLES_COST, 1200)
	Check.eq(Economy.PURCHASE_DEBOUNCE_SECONDS, 0.25)
	Check.eq(Economy.CATCH_DISTANCE_STUDS, 12)
	Check.eq(Economy.CATCH_SECONDS, 3)
	Check.eq(Economy.INCOME_INTERVAL_SECONDS, 1)
	Check.eq(Onboarding.GOAL_ONE_SECONDS, 5)
	Check.eq(Onboarding.SKIP_LABEL, "Skip the rite")
	Check.eq(Onboarding.BIND_HINT, "Carve a circle to bind it.")
	Check.eq(Save.DATA_VERSION, 7)
	Check.eq(Save.AUTOSAVE_SECONDS, 60)
	Check.eq(Save.KICK_LOAD_FAILED, "The ledger would not open. Your progress is safe. Rejoin.")
end)

Check.test("QA1 fresh profile is the starter lair", function()
	local profile = fresh()
	Check.eq(profile.cash, 25)
	Check.eq(profile.totalEarned, 0)
	Check.eq(profile.padsUnlocked, 2)
	Check.eq(profile.onboarding.step, 1)
	Check.eq(profile.onboarding.starterGranted, true)
	Check.eq(ProfileQuery.placedSpecies(profile, Species.STARTER_ID, 1), true)
	Check.eq(Income.perSecond(profile), 2)
	local snap = Snapshot.build(profile, 0, 1)
	Check.eq(snap.incomePerSecond, 2)
	Check.eq(snap.pads[1].displayName, "Mothman Hatchling")
	Check.eq(snap.pads[1].state, "occupied")
	Check.eq(snap.pads[2].state, "empty")
	Check.eq(snap.pads[3].state, "locked")
	Check.eq(snap.goal.headline, Onboarding.HEADLINES[1])
end)

Check.test("QA2 ten idle seconds credits exactly twenty dollars", function()
	local profile = fresh()
	local gained = Transactions.creditIncome(profile, 10)
	Check.eq(gained, 20)
	Check.eq(profile.cash, 45)
	Check.eq(profile.totalEarned, 20)
	Check.eq(profile.onboarding.step, 2)
	Check.eq(profile.onboarding.playSeconds, 10)
end)

Check.test("altar multiplier and inventory do not earn", function()
	Check.eq(Income.multiplier(0), 1)
	Check.eq(Income.multiplier(1), 1.25)
	Check.eq(Income.multiplier(2), 1.5)
	local profile = fresh()
	profile.cryptids.pocket = {
		speciesId = Species.WILD_ID,
		mutation = "",
		traits = {},
		acquiredAt = 0,
		source = "wild",
	}
	Check.eq(Income.perSecond(profile), 2)
end)

Check.test("QA3 through QA8 purchase chain", function()
	local profile = fresh()
	Transactions.creditIncome(profile, 5)
	Check.eq(profile.onboarding.step, 2)
	Check.eq(profile.cash, 35)
	Check.eq(Transactions.grantWild(profile, 1, "too-soon"), false)

	local serial = 0
	local function newId(): string
		serial += 1
		return "id-" .. tostring(serial)
	end

	earnUntil(profile, 50)
	local before = profile.cash
	Check.truthy(Transactions.buyRift(profile, 1, 10, newId()))
	Check.eq(profile.cash, before - 50)
	Check.eq(Income.perSecond(profile), 5)
	Check.eq(ProfileQuery.placedSpecies(profile, Species.RIFT_1_ID, 2), true)
	Check.eq(profile.onboarding.step, 3)
	local charged = profile.cash
	Check.eq(Transactions.buyRift(profile, 1, 10, newId()), false)
	Check.eq(profile.cash, charged)
	local waiting = Snapshot.build(profile, 0, 1)
	Check.eq(waiting.rift[1].speciesId, Species.RIFT_2_ID)
	Check.eq(waiting.rift[1].needsCircle, true)
	Check.eq(waiting.rift[1].hint, Onboarding.NEEDS_CIRCLE)
	Check.eq(waiting.reveal, nil)

	local caught = OnboardingGoals.view(profile)
	Check.eq(caught.headline, Onboarding.HEADLINES[3])
	Check.eq(caught.progressText, Onboarding.CATCH_PROGRESS)
	Check.eq(caught.guide, "wild")
	Check.eq(caught.buttonText, "")

	Check.truthy(Transactions.grantWild(profile, 30, newId()))
	Check.eq(profile.onboarding.step, 4)
	Check.eq(ProfileQuery.wildPlaced(profile), false)
	local bind = OnboardingGoals.view(profile)
	Check.contains(bind.progressText, Onboarding.BIND_HINT)
	Check.eq(bind.actionKind, "unlockPad")
	Check.eq(bind.actionPad, 3)

	earnUntil(profile, 120)
	Check.truthy(Transactions.unlockPad(profile, 3))
	Check.eq(profile.padsUnlocked, 3)
	Check.eq(ProfileQuery.wildPlaced(profile), true)
	Check.eq(Income.perSecond(profile), 10)
	Check.eq(profile.onboarding.step, 5)
	Check.eq(Economy.PAD_COST[4], 400)
	Check.eq(Transactions.unlockPad(profile, 4) ~= true, true)

	earnUntil(profile, 300)
	Check.truthy(Transactions.upgradeBoneAltar(profile))
	Check.near(Income.perSecond(profile), 12.5)
	Check.eq(profile.upgrades.boneAltar, 1)
	Check.eq(profile.onboarding.step, 6)

	earnUntil(profile, 400)
	Check.truthy(Transactions.unlockPad(profile, 4))
	Check.near(Income.perSecond(profile), 12.5)
	Check.eq(profile.onboarding.step, 7)
	Check.eq(ProfileQuery.placedSpecies(profile, Species.RIFT_2_ID, 4), false)

	earnUntil(profile, 75)
	Check.truthy(Transactions.buyRift(profile, 2, 20, newId()))
	Check.near(Income.perSecond(profile), 17.5)
	Check.eq(ProfileQuery.placedSpecies(profile, Species.RIFT_2_ID, 4), true)
	Check.eq(profile.onboarding.step, 8)
	local done = OnboardingGoals.view(profile)
	Check.eq(done.headline, Onboarding.HEADLINES[8])
	Check.eq(done.showArrow, false)
	Check.contains(done.progressText, "$1,200")
	Check.eq(done.buttonText, "")
	Check.eq(done.buttonEnabled, false)
	profile.cash = 1200
	local funded = OnboardingGoals.view(profile)
	Check.eq(funded.progressText, "$1,200 / $1,200")
	Check.eq(funded.buttonText, Onboarding.WARD_LOCKED_LABEL)
	Check.eq(funded.buttonEnabled, false)
	Check.eq(funded.actionKind, "none")
	local snap = Snapshot.build(profile, 0, 2)
	Check.near(snap.incomePerSecond, 17.5)
	Check.eq(snap.pads[2].displayName, "Fresno Nightcrawler")
	Check.eq(snap.pads[3].displayName, "Hodag")
	Check.near(snap.pads[3].income, 6.25)
	Check.eq(snap.pads[4].displayName, "Hidebehind")
	Check.near(snap.pads[4].income, 5)
	local shown = Snapshot.build(profile, 0, 3, { revealSerial = 1 })
	Check.eq(shown.reveal.speciesName, "Hodag")
	Check.eq(shown.reveal.line, Onboarding.TEASE_LINE)
	Check.eq(shown.reveal.pips[1], "Common")
	Check.eq(shown.reveal.pips[2], "Uncommon")
	Check.eq(shown.reveal.pips[3], "Rare")
end)

Check.test("QA12 rejected purchase does not change cash", function()
	local profile = fresh()
	profile.cash = 0
	local ok, reason = Transactions.buyRift(profile, 1, 1, "nope")
	Check.eq(ok, false)
	Check.eq(reason, "afford")
	Check.eq(profile.cash, 0)
	Check.eq(profile.padsUnlocked, 2)
	local badSlot = RemoteArgs.slot("1")
	Check.eq(badSlot, nil)
	Check.eq(RemoteArgs.slot(1), 1)
	Check.eq(RemoteArgs.slot(3), nil)
	Check.eq(RemoteArgs.upgradeId("gamepass"), nil)
	Check.eq(RemoteArgs.upgradeId("boneAltar"), "boneAltar")
	Check.eq(RemoteArgs.flag("true"), nil)
	Check.eq(RemoteArgs.flag(true), true)
end)

Check.test("QA13 debounce and a second buy cannot double charge", function()
	local allowed, at = Debounce.allow(nil, 10, Economy.PURCHASE_DEBOUNCE_SECONDS)
	Check.eq(allowed, true)
	Check.eq(at, 10)
	local again = Debounce.allow(10, 10.2, Economy.PURCHASE_DEBOUNCE_SECONDS)
	Check.eq(again, false)
	local later = Debounce.allow(10, 10.25, Economy.PURCHASE_DEBOUNCE_SECONDS)
	Check.eq(later, true)

	local profile = fresh()
	profile.cash = 50
	Check.eq(Transactions.buyRift(profile, 1, 1, "once"), true)
	Check.eq(profile.cash, 0)
	Check.eq(Transactions.buyRift(profile, 1, 1, "twice"), false)
	Check.eq(profile.cash, 0)
	Check.eq(ProfileQuery.countSpecies(profile, Species.RIFT_1_ID), 1)
end)

Check.test("QA19 skip grants unclaimed rift cryptids and the Hodag, and keeps cash", function()
	local profile = fresh()
	local serial = 0
	local ok, reason, events = Transactions.skip(profile, 5, function()
		serial += 1
		return "grant-" .. tostring(serial)
	end)
	Check.eq(ok, true)
	Check.eq(reason, "ok")
	Check.eq(#events, 0)
	Check.eq(profile.onboarding.step, 8)
	Check.eq(profile.onboarding.skipped, true)
	Check.eq(profile.cash, 25)
	Check.eq(profile.totalEarned, 0)
	Check.eq(profile.padsUnlocked, 2)
	Check.eq(profile.upgrades.boneAltar, 0)
	Check.eq(ProfileQuery.countSpecies(profile, Species.RIFT_1_ID), 1)
	Check.eq(ProfileQuery.countSpecies(profile, Species.RIFT_2_ID), 1)
	Check.eq(ProfileQuery.countSpecies(profile, Species.WILD_ID), 1)
	Check.eq(ProfileQuery.instanceOfSpecies(profile, Species.WILD_ID) ~= nil, true)
	local hodagId = ProfileQuery.instanceOfSource(profile, "wild")
	Check.eq(profile.cryptids[hodagId].speciesId, "hodag")
	Check.eq(profile.cryptids[hodagId].source, "wild")
	Check.eq(ProfileQuery.padOfInstance(profile, "grant-1"), nil)
	Check.eq(ProfileQuery.padOfInstance(profile, hodagId :: string), nil)
	local snap = Snapshot.build(profile, 0, 1)
	Check.eq(#snap.inventory, 3)
	Check.eq(#snap.rift, 0)
	Check.eq(snap.goal.progressText, "$25 / $1,200")
	Check.eq(
		Transactions.skip(profile, 6, function()
			return "again"
		end),
		false
	)
	Check.eq(ProfileQuery.countSpecies(profile, Species.RIFT_1_ID), 1)
	Check.eq(ProfileQuery.countSpecies(profile, Species.WILD_ID), 1)

	local already = fresh()
	already.cryptids["kept-hodag"] = {
		speciesId = "hodag",
		mutation = "",
		traits = {},
		acquiredAt = 0,
		source = "wild",
	}
	Check.eq(
		Transactions.skip(already, 7, function()
			serial += 1
			return "extra-" .. tostring(serial)
		end),
		true
	)
	Check.eq(ProfileQuery.countSpecies(already, Species.WILD_ID), 1)
	Check.eq(already.cash, 25)
	Check.eq(already.upgrades.boneAltar, 0)
end)

Check.test("QA20 steal protection ends at step 8 or five minutes", function()
	local profile = fresh()
	Check.eq(StealGuard.isProtected(profile), true)
	Check.eq(StealGuard.canSteal(profile, profile), false)
	profile.onboarding.playSeconds = Economy.STEAL_PROTECTION_PLAY_SECONDS
	Check.eq(StealGuard.isProtected(profile), false)
	profile.onboarding.playSeconds = 0
	profile.onboarding.step = 8
	Check.eq(StealGuard.isProtected(profile), false)
	local other = fresh()
	Check.eq(StealGuard.canSteal(profile, other), false)
	other.onboarding.step = 8
	Check.eq(StealGuard.canSteal(profile, other), true)
end)

Check.test("selling stays sealed during the rite and pads can be rearranged", function()
	local profile = fresh()
	Check.eq(Transactions.canSell(profile), false)
	Check.eq(Transactions.place(profile, "starter", 2), true)
	Check.eq(ProfileQuery.padAt(profile, 2), "starter")
	Check.eq(ProfileQuery.padAt(profile, 1), nil)
	Check.eq(Transactions.place(profile, "starter", 1), true)
	profile.onboarding.step = 8
	Check.eq(Transactions.canSell(profile), true)
end)

Check.test("catch distance and duration rules", function()
	Check.eq(RemoteArgs.withinDistance(12, Economy.CATCH_DISTANCE_STUDS), true)
	Check.eq(RemoteArgs.withinDistance(12.01, Economy.CATCH_DISTANCE_STUDS), false)
	Check.eq(RemoteArgs.withinDistance(nil, Economy.CATCH_DISTANCE_STUDS), false)
	Check.eq(RemoteArgs.catchElapsed(3, Economy.CATCH_SECONDS), true)
	Check.eq(RemoteArgs.catchElapsed(2.99, Economy.CATCH_SECONDS), false)
end)

Check.test("schema migration keeps cash and rejects corrupt or newer saves", function()
	local profile = fresh()
	profile.cash = 80
	profile.onboarding.playSeconds = nil
	local migrated = Schema.migrate(profile)
	Check.eq(migrated.cash, 80)
	Check.eq(migrated.onboarding.playSeconds, 0)
	Check.eq(migrated.cryptids.starter.speciesId, Species.STARTER_ID)
	migrated.cash = 5
	Check.eq(profile.cash, 80)

	profile.dataVersion = 8
	Check.eq(Schema.migrate(profile), nil)
	Check.eq(Schema.migrate({}), nil)
	Check.eq(Schema.migrate("ledger"), nil)
	Check.eq(Schema.migrate(nil), nil)

	local encoded = serde.encode("json", fresh())
	local decoded = serde.decode("json", encoded)
	local roundTrip = Schema.migrate(decoded)
	Check.truthy(roundTrip)
	Check.eq(roundTrip.cash, 25)
	Check.eq(roundTrip.pads["1"], "starter")
	Check.eq(roundTrip.cryptids.starter.source, "starter")
	Check.eq(roundTrip.onboarding.starterGranted, true)
	Check.eq(roundTrip.totalEarned, 0)
	Check.eq(roundTrip.dataVersion, 7)
	Check.eq(type(roundTrip.base.defences), "table")
end)

Check.test("v1 saves drop the starting grant from totalEarned and rename the old wild id", function()
	local legacy = fresh()
	legacy.dataVersion = 1
	legacy.cash = 45
	legacy.totalEarned = 45
	legacy.cryptids.oldwild = {
		speciesId = "wild_common",
		mutation = "",
		traits = {},
		acquiredAt = 4,
		source = "wild",
	}
	local migrated = Schema.migrate(legacy)
	Check.eq(migrated.dataVersion, 7)
	Check.eq(next(migrated.base.defences), nil)
	Check.eq(migrated.cash, 45)
	Check.eq(migrated.totalEarned, 20)
	Check.eq(migrated.cryptids.oldwild.speciesId, "hodag")
	Check.eq(legacy.cryptids.oldwild.speciesId, "wild_common")
	Check.eq(legacy.totalEarned, 45)

	local again = Schema.migrate(migrated)
	Check.eq(again.totalEarned, 20)

	local grantOnly = fresh()
	grantOnly.dataVersion = 1
	grantOnly.totalEarned = 10
	local clamped = Schema.migrate(grantOnly)
	Check.eq(clamped.totalEarned, 0)
end)

Check.test("starter grant happens once", function()
	local profile = fresh()
	Check.eq(Schema.ensureStarter(profile, 10, "other"), false)
	Check.eq(profile.cryptids.other, nil)
	profile.onboarding.starterGranted = false
	Check.eq(Schema.ensureStarter(profile, 11, "second"), true)
	Check.eq(profile.cryptids.second.source, "starter")
	Check.eq(Schema.ensureStarter(profile, 12, "third"), false)
end)

Check.test("headlines match the rite copy", function()
	Check.eq(Onboarding.HEADLINES[1], "Your first familiar stirs. Watch it feed your coffers.")
	Check.eq(Onboarding.HEADLINES[2], "The Rift offers a creature. Claim it.")
	Check.eq(Onboarding.HEADLINES[3], "Take up your lantern. Something waits in the wild.")
	Check.eq(Onboarding.HEADLINES[4], "Carve a third circle and bind your catch.")
	Check.eq(Onboarding.HEADLINES[5], "Raise the Bone Altar.")
	Check.eq(Onboarding.HEADLINES[6], "Carve a fourth circle.")
	Check.eq(Onboarding.HEADLINES[7], "Bind another from the Rift.")
	Check.eq(Onboarding.HEADLINES[8], "Others hunger for your menagerie. Light the Ward Candles.")
end)

Check.test("v2 goal order stays affordable from income alone", function()
	local profile = fresh()
	local clock = 0
	local names = {}
	local function walk(seconds: number)
		Transactions.creditIncome(profile, seconds)
		clock += seconds
	end
	local function note(before: number)
		for _, event in Analytics.eventsForTransition(before, profile.onboarding.step, false) do
			table.insert(names, event.stepName)
		end
	end
	local function idleUntil(cost: number): number
		local waited = 0
		while profile.cash + 1e-9 < cost do
			walk(1)
			waited += 1
			Check.eq(waited <= 35, true, "cash wait")
		end
		return waited
	end

	local before = profile.onboarding.step
	walk(Onboarding.GOAL_ONE_SECONDS)
	note(before)
	Check.eq(profile.onboarding.step, 2)
	Check.eq(profile.cash, 35)
	Check.eq(clock, 5)

	before = profile.onboarding.step
	walk(12)
	Check.eq(profile.cash, 59)
	Check.truthy(Transactions.buyRift(profile, 1, 1, "rift-a"))
	note(before)
	Check.eq(profile.cash, 9)
	Check.eq(Income.perSecond(profile), 5)
	Check.eq(profile.onboarding.step, 3)
	Check.eq(clock, 17)

	before = profile.onboarding.step
	walk(16)
	Check.eq(profile.cash, 89)
	Check.truthy(Transactions.grantWild(profile, 2, "wild-a"))
	note(before)
	Check.eq(profile.onboarding.step, 4)
	Check.eq(ProfileQuery.padOfInstance(profile, "wild-a"), nil)
	Check.eq(clock, 33)
	Check.eq(clock <= 50, true)

	before = profile.onboarding.step
	walk(12)
	Check.eq(profile.cash, 149)
	Check.truthy(Transactions.unlockPad(profile, 3))
	note(before)
	Check.eq(profile.cash, 29)
	Check.eq(Income.perSecond(profile), 10)
	Check.eq(ProfileQuery.padOfInstance(profile, "wild-a"), 3)
	Check.eq(profile.onboarding.step, 5)
	Check.eq(clock, 45)
	Check.eq(clock <= 60, true)

	before = profile.onboarding.step
	local altarWait = idleUntil(Economy.ALTAR_COST[1])
	Check.eq(altarWait, 28)
	Check.truthy(Transactions.upgradeBoneAltar(profile))
	note(before)
	Check.eq(profile.cash, 9)
	Check.near(Income.perSecond(profile), 12.5)
	Check.eq(profile.onboarding.step, 6)

	before = profile.onboarding.step
	local padWait = idleUntil(Economy.PAD_COST[4])
	Check.eq(padWait, 32)
	Check.truthy(Transactions.unlockPad(profile, 4))
	note(before)
	Check.eq(profile.cash, 9)
	Check.near(Income.perSecond(profile), 12.5)
	Check.eq(profile.onboarding.step, 7)

	before = profile.onboarding.step
	walk(12)
	Check.eq(profile.cash, 159)
	Check.truthy(Transactions.buyRift(profile, 2, 3, "rift-b"))
	note(before)
	Check.eq(profile.cash, 84)
	Check.near(Income.perSecond(profile), 17.5)
	Check.eq(ProfileQuery.placedSpecies(profile, Species.RIFT_2_ID, 4), true)
	Check.eq(profile.onboarding.step, 8)
	Check.eq(clock, 117)
	Check.eq(clock <= 165, true)

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
	Check.eq(names[1], "Starter Earning")
	Check.eq(names[2], "Claimed Rift Cryptid 1")
	Check.eq(names[3], "Caught Hodag")
	Check.eq(names[4], "Bound Hodag on Pad 3")
	Check.eq(names[5], "Raised Bone Altar I")
	Check.eq(names[6], "Carved Pad 4")
	Check.eq(names[7], "Claimed Rift Cryptid 2")
	Check.eq(names[8], "Rite Complete")
end)

Check.test("Bone Altar III-X uses the decaying add and the rebirth cost hook", function()
	local rounded = { 1, 1.25, 1.5, 1.688, 1.828, 1.934, 2.013, 2.072, 2.117, 2.15, 2.175 }
	local withL3 = { 1.3, 1.6, 1.825, 1.994, 2.12, 2.215, 2.286, 2.34, 2.38, 2.41 }
	for level = 0, 10 do
		Check.near(BoneAltar.multiplier(level, false), rounded[level + 1], 0.0006, "level " .. tostring(level))
	end
	for level = 1, 10 do
		Check.near(BoneAltar.multiplier(level, true), withL3[level], 0.0006, "l3 " .. tostring(level))
	end
	Check.eq(Income.multiplier(1), 1.25)
	Check.eq(Income.multiplier(2), 1.5)
	Check.near(Income.multiplier(3, true), 1.825)
	local costs = { 300, 1500, 8000, 40000, 200000, 1000000, 5000000, 25000000, 125000000, 625000000 }
	for level, cost in costs do
		Check.eq(BoneAltar.cost(level, 0), cost, "cost " .. tostring(level))
		Check.eq(Economy.ALTAR_COST[level], cost)
	end
	Check.eq(BoneAltar.cost(1, 1), 450)
	Check.eq(BoneAltar.cost(3, 2), 18000)
	Check.eq(BoneAltar.cost(11, 0), nil)
	Check.eq(BoneAltar.rebirths({}), 0)
	Check.eq(BoneAltar.rebirths({ rebirths = 2 }), 2)
	Check.eq(BoneAltar.rebirths({ rebirths = -1 }), 0)
	Check.eq(BoneAltar.rebirths({ rebirths = 1.5 }), 0)
	Check.eq(BoneAltar.l3Owned({}), false)
	Check.eq(BoneAltar.l3Owned({ skills = { l3 = true } }), true)

	local profile = fresh()
	profile.onboarding.step = 8
	profile.rebirths = 1
	profile.cash = 450
	Check.eq(Transactions.upgradeBoneAltar(profile), true)
	Check.eq(profile.cash, 0)
	Check.eq(profile.upgrades.boneAltar, 1)
	profile.skills = { l3 = true }
	Check.near(Income.perSecond(profile), 2.6)
	profile.upgrades.boneAltar = 10
	profile.cash = 1e12
	Check.eq(Transactions.upgradeBoneAltar(profile), false)
	profile.upgrades.boneAltar = 11
	profile.dataVersion = Save.DATA_VERSION
	Check.eq(Schema.migrate(profile), nil)
end)

Check.test("funnel step is the goal plus one and a skip logs no catch", function()
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
		Check.eq(Analytics.FUNNEL[step], name)
	end
	Check.eq(Analytics.funnelStep(3), 4)
	Check.eq(Analytics.funnelStep(4), 5)
	Check.eq(Analytics.funnelStep(6), 7)
	Check.eq(Analytics.funnelStep(7), 8)
	Check.eq(Analytics.funnelStep(8), 9)
	Check.eq(Analytics.joinEvent().stepName, "Joined")
	for _, name in Analytics.FUNNEL do
		Check.eq(name == "Carved Pad 3", false)
		Check.eq(name == "Bound Hodag on Pad 4", false)
	end
	local caught = Analytics.eventsForTransition(3, 4, false)
	Check.eq(#caught, 1)
	Check.eq(caught[1].step, 4)
	Check.eq(caught[1].stepName, "Caught Hodag")
	Check.eq(caught[1].eventName, Analytics.CATCH_EVENT)
	Check.eq(caught[1].catch, true)
	local skipped = Analytics.eventsForTransition(3, 8, true)
	Check.eq(#skipped, 0)
	for _, event in skipped do
		Check.eq(event.step == 4, false)
		Check.eq(event.eventName == Analytics.CATCH_EVENT, false)
	end
	local profile = fresh()
	profile.onboarding.step = 3
	local serial = 0
	local _ok, _reason, events = Transactions.skip(profile, 4, function()
		serial += 1
		return "skip-hodag-" .. tostring(serial)
	end)
	Check.eq(profile.onboarding.step, 8)
	Check.eq(#events, 0)
	Check.eq(ProfileQuery.countSpecies(profile, Species.WILD_ID), 1)
end)

Check.test("goal 3 tease uses tier colours and drops the silhouettes", function()
	Check.eq(Onboarding.TEASE_LINE, "Three marks. Rarer things are watching.")
	Check.eq(UITheme.rarity[Onboarding.TEASE_PIPS[1]], "BoneDim")
	Check.eq(UITheme.rarity[Onboarding.TEASE_PIPS[2]], "Moss")
	Check.eq(UITheme.rarity[Onboarding.TEASE_PIPS[3]], "TarnishedSilver")
	Check.eq(UITheme.palette.BoneDim, "A79F90")
	Check.eq(UITheme.palette.Moss, "5E7A4A")
	Check.eq(UITheme.palette.TarnishedSilver, "8C9AA3")
	Check.eq(UITheme.palette.Bone, "E8E0CF")
	local profile = fresh()
	profile.onboarding.step = 3
	local view = OnboardingGoals.view(profile)
	Check.eq(view.progressText, "0 / 1")
	Check.eq(view.headline, Onboarding.HEADLINES[3])
	local encoded = ""
	for key, value in view do
		encoded ..= tostring(key) .. "=" .. tostring(value) .. ";"
	end
	Check.eq(string.find(string.lower(encoded), "silhouette", 1, true), nil)
end)

Check.test("v5 in-progress rites recompute onto the v2 chain and finished rites stay finished", function()
	local mid = fresh()
	mid.dataVersion = 5
	mid.onboarding.step = 6
	mid.onboarding.playSeconds = 80
	mid.padsUnlocked = 3
	mid.upgrades.boneAltar = 1
	mid.cash = 40
	mid.cryptids.fresno = {
		speciesId = "fresno_nightcrawler",
		mutation = "",
		traits = {},
		acquiredAt = 1,
		source = "rift",
	}
	mid.cryptids.hide = {
		speciesId = "hidebehind",
		mutation = "",
		traits = {},
		acquiredAt = 2,
		source = "rift",
	}
	mid.pads["2"] = "fresno"
	mid.pads["3"] = "hide"
	local migrated = Schema.migrate(mid)
	Check.eq(migrated.dataVersion, 7)
	Check.eq(migrated.onboarding.step, 3)
	Check.eq(migrated.cash, 40)
	Check.eq(migrated.upgrades.boneAltar, 1)
	Check.eq(migrated.pads["3"], "hide")
	Check.eq(migrated.padsUnlocked, 3)
	Check.eq(Schema.migrate(migrated).onboarding.step, 3)
	Check.eq(mid.onboarding.step, 6)

	local done = fresh()
	done.dataVersion = 5
	done.onboarding.step = 8
	done.onboarding.playSeconds = 200
	local kept = Schema.migrate(done)
	Check.eq(kept.onboarding.step, 8)
	Check.eq(kept.onboarding.playSeconds, 200)

	local early = fresh()
	early.dataVersion = 5
	early.onboarding.playSeconds = 0
	local still = Schema.migrate(early)
	Check.eq(still.onboarding.step, 1)
	Check.eq(still.onboarding.playSeconds, 0)
end)
