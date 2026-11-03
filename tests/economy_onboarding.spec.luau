--!strict

_G.LUNE = true

local Check = require("./check")
local Economy = require("../src/shared/Config/Economy")
local Onboarding = require("../src/shared/Config/Onboarding")
local Species = require("../src/shared/Config/Species")
local Save = require("../src/shared/Config/Save")
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
	Check.eq(Economy.WARD_CANDLES_COST, 1200)
	Check.eq(Economy.PURCHASE_DEBOUNCE_SECONDS, 0.25)
	Check.eq(Economy.CATCH_DISTANCE_STUDS, 12)
	Check.eq(Economy.CATCH_SECONDS, 3)
	Check.eq(Economy.INCOME_INTERVAL_SECONDS, 1)
	Check.eq(Onboarding.GOAL_ONE_SECONDS, 5)
	Check.eq(Onboarding.SKIP_LABEL, "Skip the rite")
	Check.eq(Onboarding.BIND_HINT, "Carve a circle to bind it.")
	Check.eq(Save.DATA_VERSION, 4)
	Check.eq(Save.AUTOSAVE_SECONDS, 60)
	Check.eq(Save.KICK_LOAD_FAILED, "The ledger would not open. Rejoin.")
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
	local charged = profile.cash
	Check.eq(Transactions.buyRift(profile, 1, 10, newId()), false)
	Check.eq(profile.cash, charged)

	earnUntil(profile, 120)
	Check.truthy(Transactions.unlockPad(profile, 3))
	Check.eq(profile.padsUnlocked, 3)
	Check.eq(Economy.PAD_COST[4], 400)
	Check.eq(Transactions.unlockPad(profile, 4) ~= true, true)

	earnUntil(profile, 75)
	Check.truthy(Transactions.buyRift(profile, 2, 20, newId()))
	Check.eq(Income.perSecond(profile), 9)
	Check.eq(ProfileQuery.placedSpecies(profile, Species.RIFT_2_ID, 3), true)

	earnUntil(profile, 300)
	Check.truthy(Transactions.upgradeBoneAltar(profile))
	Check.near(Income.perSecond(profile), 11.25)
	Check.eq(profile.upgrades.boneAltar, 1)

	Check.truthy(Transactions.grantWild(profile, 30, newId()))
	Check.eq(profile.onboarding.step, 7)
	local view = OnboardingGoals.view(profile)
	Check.contains(view.progressText, Onboarding.BIND_HINT)
	Check.eq(ProfileQuery.wildPlaced(profile), false)

	earnUntil(profile, 400)
	Check.truthy(Transactions.unlockPad(profile, 4))
	local wildId = ProfileQuery.instanceOfSource(profile, "wild")
	Check.truthy(wildId)
	Check.truthy(Transactions.place(profile, wildId :: string, 4))
	Check.near(Income.perSecond(profile), 17.5)
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
	Check.eq(snap.pads[3].displayName, "Hidebehind")
	Check.eq(snap.pads[4].displayName, "Hodag")
	Check.near(snap.pads[4].income, 6.25)
end)

Check.test("QA9 income wait for goals 1 to 7 stays under 3:30", function()
	local profile = fresh()
	local seconds = 0
	local function idle(amount: number)
		Transactions.creditIncome(profile, amount)
		seconds += amount
	end
	idle(5)
	seconds += earnUntil(profile, 50)
	Check.truthy(Transactions.buyRift(profile, 1, 1, "rift-a"))
	seconds += earnUntil(profile, 120)
	Check.truthy(Transactions.unlockPad(profile, 3))
	seconds += earnUntil(profile, 75)
	Check.truthy(Transactions.buyRift(profile, 2, 1, "rift-b"))
	seconds += earnUntil(profile, 300)
	Check.truthy(Transactions.upgradeBoneAltar(profile))
	idle(3)
	Check.truthy(Transactions.grantWild(profile, 1, "wild-a"))
	seconds += earnUntil(profile, 400)
	local unlocked = Transactions.unlockPad(profile, 4)
	Check.eq(unlocked, true)
	local wildId = ProfileQuery.instanceOfSource(profile, "wild")
	local placed = Transactions.place(profile, wildId :: string, 4)
	Check.eq(placed, true)
	Check.eq(profile.onboarding.step, 8)
	Check.truthy(seconds <= 210)
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
	local ok = Transactions.skip(profile, 5, function()
		serial += 1
		return "grant-" .. tostring(serial)
	end)
	Check.eq(ok, true)
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

	profile.dataVersion = 5
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
	Check.eq(roundTrip.dataVersion, 4)
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
	Check.eq(migrated.dataVersion, 4)
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
	Check.eq(Onboarding.HEADLINES[3], "Carve a third circle.")
	Check.eq(Onboarding.HEADLINES[4], "Bind another from the Rift.")
	Check.eq(Onboarding.HEADLINES[5], "Raise the Bone Altar.")
	Check.eq(Onboarding.HEADLINES[6], "Take up your lantern. Something waits in the wild.")
	Check.eq(Onboarding.HEADLINES[7], "Carve a fourth circle and bind your catch.")
	Check.eq(Onboarding.HEADLINES[8], "Others hunger for your menagerie. Light the Ward Candles.")
end)
