--!strict

-- selene: allow(global_usage)
_G.LUNE = true

local fs = require("@lune/fs")
local Check = require("./check")
local BoneAltar = require("../src/shared/Config/BoneAltar")
local Economy = require("../src/shared/Config/Economy")
local RebirthRules = require("../src/shared/Config/Rebirth")
local Return = require("../src/shared/Config/Return")
local Save = require("../src/shared/Config/Save")
local BoardConfig = require("../src/shared/Config/TitheBoard")
local Daily = require("../src/shared/Logic/Daily")
local Money = require("../src/shared/Logic/Money")
local NumberFormat = require("../src/shared/Logic/NumberFormat")
local Ownership = require("../src/shared/Logic/Ownership")
local QaArgs = require("../src/shared/Logic/QaArgs")
local Rebirth = require("../src/shared/Logic/Rebirth")
local SaveGuard = require("../src/shared/Logic/SaveGuard")
local Schema = require("../src/shared/Logic/Schema")
local SkillEffects = require("../src/shared/Logic/SkillEffects")
local TitheBoard = require("../src/shared/Logic/TitheBoard")

local COSTS = { 5000000, 15000000, 45000000, 135000000, 405000000, 1215000000, 3645000000 }
local GATES = { 5000000, 20000000, 49000000, 150000000, 454000000, 1365000000, 4099000000 }
local FACTORS = { 1.5, 2.25, 3.38, 5.06, 7.59, 11.39, 17.09 }
local MULTIPLIERS = { 1.5, 2, 2.5, 3, 3.5, 4, 4.5 }

local function ready(): any
	local profile = Schema.newProfile(1, "keeper")
	profile.onboarding.step = RebirthRules.ONBOARDING_STEP
	profile.everHeld1M = true
	profile.cash = Rebirth.cost(1)
	profile.tithe = Rebirth.titheGate(1)
	profile.skills = { "l1" }
	profile.upgrades.boneAltar = 4
	profile.padsUnlocked = Economy.CASH_PAD_MAX
	profile.daily.step = 3
	profile.passes.extraPads = true
	profile.cosmetics.owned.banner = true
	profile.bowl = 500
	profile.totalEarned = 20
	profile.cryptids.other = {
		speciesId = "hodag",
		mutation = "",
		traits = {},
		acquiredAt = 2,
		source = "wild",
	}
	profile.pads["3"] = "other"
	return profile
end

Check.test("rebirth tiers 1 to 7 use the spec cost, tithe gate, multiplier, and price factor", function()
	Check.eq(Save.DATA_VERSION, 10)
	Check.eq(RebirthRules.DEBOUNCE_SECONDS, 0.25)
	Check.eq(RebirthRules.PRICE_FACTOR, BoneAltar.REBIRTH_FACTOR)
	Check.eq(Rebirth.cost(8), nil)
	Check.eq(Rebirth.titheGate(8), nil)
	for tier, cost in COSTS do
		Check.eq(Rebirth.cost(tier), cost, "cost " .. tostring(tier))
		Check.eq(Rebirth.titheGate(tier), GATES[tier], "gate " .. tostring(tier))
		Check.eq(Rebirth.multiplierFor(tier), MULTIPLIERS[tier], "mult " .. tostring(tier))
		Check.eq(Rebirth.priceFactorShown(tier), FACTORS[tier], "factor " .. tostring(tier))
		Check.eq(Economy.padCost(3, tier), Economy.PAD_COST[3] * (BoneAltar.REBIRTH_FACTOR ^ tier))
		Check.eq(BoneAltar.cost(1, tier), BoneAltar.COST[1] * (BoneAltar.REBIRTH_FACTOR ^ tier))
	end
	Check.eq(Rebirth.multiplierFor(0), 1)
end)

Check.test("the rite stays locked one dollar short and when tithe is short", function()
	local profile = ready()
	profile.cash = (Rebirth.cost(1) :: number) - 1
	local view = Rebirth.view(profile)
	Check.eq(view.canBegin, false)
	Check.eq(view.blockReason, "Gather $1 more")
	Check.eq(Rebirth.commit(profile, "keeper"), false)
	Check.eq(profile.rebirths, 0)
	Check.eq(profile.cash, (Rebirth.cost(1) :: number) - 1)

	profile.cash = Rebirth.cost(1)
	profile.tithe = 4000000
	local locked = Rebirth.view(profile)
	local expected = string.format(
		RebirthRules.TITHE_LINE,
		NumberFormat.formatCash(4000000),
		NumberFormat.formatCash(Rebirth.titheGate(1) :: number)
	)
	Check.eq(locked.blockReason, expected)
	Check.eq(locked.canBegin, false)
	Check.eq(Rebirth.commit(profile, "keeper"), false)
	Check.eq(profile.tithe, 4000000)
end)

Check.test("a rite resets the lair, keeps the bound familiar, and applies the multiplier once", function()
	local profile = ready()
	local tithe = profile.tithe
	local earned = profile.totalEarned
	local before = Schema.deepCopy(profile)
	local ok, reason = Rebirth.commit(profile, "keeper")
	Check.eq(ok, true)
	Check.eq(reason, "ok")
	Check.eq(profile.cash, RebirthRules.CASH_AFTER)
	Check.eq(profile.padsUnlocked, Economy.STARTING_PADS_UNLOCKED)
	Check.eq(profile.upgrades.boneAltar, 0)
	Check.eq(profile.pads["1"], "keeper")
	Check.eq(profile.pads["3"], nil)
	Check.eq(profile.cryptids.other, nil)
	Check.eq(profile.cryptids.keeper.speciesId, "mothman_hatchling")
	Check.eq(profile.rebirths, 1)
	Check.eq(profile.familiarId, "mothman_hatchling")
	Check.eq(profile.skills[1], "l1")
	Check.eq(profile.daily.step, 3)
	Check.eq(profile.passes.extraPads, true)
	Check.eq(profile.cosmetics.owned.banner, true)
	Check.eq(profile.tithe, tithe)
	Check.eq(profile.bowl, 0)
	Check.eq(profile.totalEarned, earned + 500)
	Check.eq(profile.everHeld1M, true)
	local again = Rebirth.commit(profile, "keeper")
	Check.eq(again, false)
	Check.eq(profile.rebirths, 1)
	Check.eq(profile.cash, RebirthRules.CASH_AFTER)
	Check.eq(SaveGuard.rejection(before, profile, false), "wipe")
	Check.eq(SaveGuard.rejection(before, profile, true), nil)

	local titheRate, cashRate = Ownership.leaveRates(profile)
	Check.eq(SkillEffects.skillIncome(profile), 0.05)
	Check.eq(titheRate, 3.15)
	Check.eq(cashRate, 3.15)
	Check.eq(Rebirth.toast(1), "You are reborn. Income ×1.5.")
end)

Check.test("ring 1 income and one rebirth match the Jersey Devil example", function()
	local profile = ready()
	profile.skills = { "l1", "l4" }
	profile.rebirths = 1
	Check.near(SkillEffects.skillIncome(profile), 0.15)
	local earned = Money.round(150 * (1 + SkillEffects.skillIncome(profile)) * Rebirth.multiplier(profile))
	Check.near(earned, 258.75)
end)

local function sameProfile(left: any, right: any): boolean
	if type(left) ~= type(right) then
		return false
	end
	if type(left) ~= "table" then
		return left == right
	end
	for key, value in left do
		if not sameProfile(value, right[key]) then
			return false
		end
	end
	for key in right do
		if left[key] == nil then
			return false
		end
	end
	return true
end

Check.test("tier 7 is the cap and a rite there changes nothing", function()
	Check.eq(BoneAltar.MAX_REBIRTHS, 7)
	Check.eq(RebirthRules.LAUNCH_CAP, 7)
	Check.eq(BoneAltar.MAX_REBIRTHS, RebirthRules.LAUNCH_CAP)
	Check.eq(Rebirth.cost(BoneAltar.MAX_REBIRTHS) ~= nil, true)
	Check.eq(Rebirth.cost(BoneAltar.MAX_REBIRTHS + 1), nil)
	local profile = ready()
	profile.rebirths = BoneAltar.MAX_REBIRTHS
	profile.cash = Rebirth.cost(1) :: number
	profile.tithe = Rebirth.titheGate(1) :: number
	local view = Rebirth.view(profile)
	Check.eq(view.sealed, true)
	Check.eq(view.canBegin, false)
	Check.eq(view.blockReason, RebirthRules.SEALED)
	local before = Schema.deepCopy(profile)
	local ok, reason = Rebirth.commit(profile, "keeper")
	Check.eq(ok, false)
	Check.eq(reason, "sealed")
	Check.eq(sameProfile(profile, before), true)
	Check.eq(profile.rebirths, BoneAltar.MAX_REBIRTHS)
	Check.eq(profile.cash, before.cash)
	Check.eq(profile.pads["1"], before.pads["1"])
	Check.eq(profile.cryptids.keeper.speciesId, before.cryptids.keeper.speciesId)
	Check.eq(profile.upgrades.boneAltar, before.upgrades.boneAltar)

	local empty = ready()
	empty.cryptids = {}
	empty.pads = {}
	local ok = Rebirth.commit(empty, "")
	Check.eq(ok, true)
	Check.eq(empty.familiarId, "")
	Check.eq(empty.pads["1"], nil)
	Check.eq(Rebirth.countCryptids(empty), 0)
end)

Check.test("a second request inside the debounce does not charge again", function()
	local profile = ready()
	profile.cash = (Rebirth.cost(1) :: number) + (Rebirth.cost(2) :: number)
	profile.tithe = Rebirth.titheGate(2)
	local gate = {}
	local first, firstReason = Rebirth.attempt(profile, "keeper", 50, gate)
	Check.eq(first, true)
	Check.eq(firstReason, "ok")
	Check.eq(profile.rebirths, 1)
	Check.eq(profile.cash, RebirthRules.CASH_AFTER)
	local second, secondReason = Rebirth.attempt(profile, "keeper", 50, gate)
	Check.eq(second, false)
	Check.eq(secondReason, "debounce")
	Check.eq(profile.rebirths, 1)
	Check.eq(profile.cash, RebirthRules.CASH_AFTER)

	local poor = ready()
	poor.cash = (Rebirth.cost(1) :: number) - 1
	local clock = {}
	local denied, why = Rebirth.attempt(poor, "keeper", 10, clock)
	Check.eq(denied, false)
	Check.eq(why, "cash")
	poor.cash = Rebirth.cost(1)
	local blocked, blockedWhy = Rebirth.attempt(poor, "keeper", 10, clock)
	Check.eq(blocked, false)
	Check.eq(blockedWhy, "debounce")
	Check.eq(poor.rebirths, 0)
	local later = Rebirth.attempt(poor, "keeper", 10 + RebirthRules.DEBOUNCE_SECONDS, clock)
	Check.eq(later, true)
	Check.eq(poor.rebirths, 1)
end)

Check.test("daily cash does not move tithe and relic pads stay out of it", function()
	local profile = ready()
	profile.rebirths = 1
	profile.padsUnlocked = Economy.MAX_PADS
	profile.cryptids.relic = {
		speciesId = "flatwoods_monster",
		mutation = "",
		traits = {},
		acquiredAt = 3,
		source = "relic",
	}
	profile.pads["9"] = "relic"
	local tick = Ownership.cryptidTick(profile, 4, Return.CASH_DOUBLE_MULTIPLIER)
	local bare = Ownership.cryptidTick(profile, 4, 1)
	Check.eq(tick.tithe, bare.tithe)
	Check.eq(tick.cash > bare.cash, true)
	Check.eq(tick.tithe == tick.cash, false)
	local before = profile.tithe
	local claimed = Daily.claim(profile, Return.DAY_SECONDS, function()
		return "offering-1"
	end)
	Check.eq(claimed, true)
	Check.eq(profile.tithe, before)
	Check.eq(profile.cash > RebirthRules.CASH_AFTER, true)
end)

Check.test("v9 to v10 keeps tithe and v5 to v10 backfills it", function()
	local targets = Schema.migrationTargets()
	Check.eq(#targets, Save.DATA_VERSION - 1)
	local seen: { [number]: boolean } = {}
	for index, version in targets do
		Check.eq(version, index + 1)
		Check.eq(seen[version], nil)
		seen[version] = true
	end
	Check.eq(targets[1], 2)
	Check.eq(targets[#targets], Save.DATA_VERSION)

	local current = Schema.newProfile(5, "starter")
	current.dataVersion = 9
	current.rebirths = nil
	current.familiarId = nil
	current.everHeld1M = nil
	current.tithe = 80
	current.totalEarned = RebirthRules.REVEAL_CASH
	current.cash = 12
	current.padsUnlocked = 5
	current.cryptids.second = {
		speciesId = "mothman_hatchling",
		mutation = "",
		traits = {},
		acquiredAt = 5,
		source = "rift",
	}
	current.pads["3"] = "second"
	current.analytics.lastReturnDay = 2
	current.analytics.funnelStep = 3
	local fromV9 = Schema.migrate(current)
	Check.eq(fromV9.dataVersion, 10)
	Check.eq(fromV9.rebirths, 0)
	Check.eq(fromV9.familiarId, "")
	Check.eq(fromV9.everHeld1M, true)
	Check.eq(fromV9.tithe, 80)
	Check.eq(fromV9.cash, 12)
	Check.eq(fromV9.padsUnlocked, 5)
	Check.eq(fromV9.pads["1"], "starter")
	Check.eq(fromV9.pads["3"], "second")
	Check.eq(fromV9.cryptids.starter.speciesId, "mothman_hatchling")
	Check.eq(fromV9.cryptids.second.source, "rift")
	Check.eq(fromV9.analytics.funnelStep, 3)
	fromV9.rebirths = 4
	fromV9.familiarId = "hodag"
	local kept = Schema.migrate(fromV9)
	Check.eq(kept.rebirths, 4)
	Check.eq(kept.familiarId, "hodag")
	Check.eq(kept.tithe, 80)
	Check.eq(Schema.migrate(kept).rebirths, 4)

	local heldCash = Schema.newProfile(5, "starter")
	heldCash.dataVersion = 9
	heldCash.rebirths = nil
	heldCash.familiarId = nil
	heldCash.everHeld1M = nil
	heldCash.tithe = 10
	heldCash.totalEarned = 10
	heldCash.cash = RebirthRules.REVEAL_CASH
	Check.eq(Schema.migrate(heldCash).everHeld1M, true)
	Check.eq(Schema.migrate(heldCash).tithe, 10)

	local older = Schema.newProfile(5, "starter")
	older.dataVersion = 5
	older.totalEarned = 2500000
	older.cash = 40
	older.tithe = nil
	older.skills = { "h1" }
	older.lastSeenUnix = nil
	older.offline = nil
	older.daily = nil
	older.bowl = nil
	older.settings.sfx = nil
	older.settings.music = nil
	older.settings.effectsQuality = nil
	local fromV5 = Schema.migrate(older, 80)
	Check.eq(fromV5.dataVersion, 10)
	Check.eq(fromV5.rebirths, 0)
	Check.eq(fromV5.familiarId, "")
	Check.eq(fromV5.tithe, 2500000)
	Check.eq(fromV5.everHeld1M, true)
	Check.eq(fromV5.skills[1], "h1")
	Check.eq(fromV5.cash, 40)
	Check.eq(Schema.migrate(fromV5).tithe, 2500000)
	Check.eq(Schema.migrate(fromV5).rebirths, 0)

	local broken = Schema.newProfile(5, "starter")
	broken.rebirths = RebirthRules.LAUNCH_CAP + 1
	Check.eq(Schema.migrate(broken), nil)
end)

Check.test("the tithe board orders two keepers and keeps the last page when a read fails", function()
	Check.eq(BoardConfig.STORE_NAME, "TitheBoard_v1")
	Check.eq(BoardConfig.TOP, 50)
	Check.eq(BoardConfig.WRITE_SECONDS, 120)
	Check.eq(BoardConfig.READ_SECONDS, 120)
	Check.eq(TitheBoard.label(1240000), "1.24M")
	local ranked = TitheBoard.merge({}, {
		{ userId = 1, name = "alba", tithe = 5 },
		{ userId = 2, name = "bram", tithe = 9 },
	})
	Check.eq(ranked[1].userId, 2)
	Check.eq(ranked[1].label, TitheBoard.label(9))
	Check.eq(ranked[2].userId, 1)
	local state = {
		rows = ranked,
		message = "",
		revision = 1,
	}
	TitheBoard.ingest(state, false, nil, {})
	Check.eq(state.message, BoardConfig.REWRITING)
	Check.eq(state.rows[1].userId, 2)
	Check.eq(state.rows[2].name, "alba")
	Check.eq(TitheBoard.shouldWrite(nil, 10, nil, 5), true)
	Check.eq(TitheBoard.shouldWrite(10, 10, 5, 5), false)
	Check.eq(TitheBoard.shouldWrite(10, 10, 5, 6), false)
	Check.eq(TitheBoard.shouldWrite(10, 10 + BoardConfig.WRITE_SECONDS, 5, 6), true)
end)

Check.test("studio rebirthready is inert outside studio and prepares a tier 1 rite", function()
	Check.eq(QaArgs.rebirthReady(false, "qa:120:rebirthready"), false)
	Check.eq(QaArgs.rebirthReady(true, "qa:120:rebirthready"), true)
	Check.eq(QaArgs.rebirthReady(true, "qa:120:plots3"), false)
	Check.eq(QaArgs.parse("qa:90:offline:10:rebirthready").offlineSeconds, 10)
	local profile = Schema.newProfile(1, "starter")
	profile.onboarding.step = 1
	profile.cash = 25
	profile.tithe = 0
	Check.eq(Rebirth.prepareQa(profile), true)
	Check.eq(profile.onboarding.step, RebirthRules.ONBOARDING_STEP)
	Check.eq(profile.everHeld1M, true)
	Check.eq(profile.cash, Rebirth.cost(1))
	Check.eq(profile.tithe, Rebirth.titheGate(1))
	Check.eq(Rebirth.view(profile).canBegin, true)
	local studio = fs.readFile("src/server/Dev/StudioQa.luau")
	Check.contains(studio, "IsStudio")
	Check.contains(studio, "armRebirth")
	local client = fs.readFile("src/client/Main.client.luau")
	Check.contains(client, "QaArgs.rebirthReady")
	Check.contains(client, "IsStudio")
	local panel = fs.readFile("src/client/RebirthPanel.luau")
	Check.eq(string.find(panel, "MarketplaceService", 1, true), nil)
	Check.eq(string.find(panel, "Robux", 1, true), nil)
	local rules = fs.readFile("src/shared/Config/Rebirth.luau")
	Check.eq(string.find(rules, "Robux", 1, true), nil)
	Check.eq(string.find(rules, "ProductId", 1, true), nil)
end)
