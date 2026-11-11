--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local BoneAltar = require("../src/shared/Config/BoneAltar")
local Bundles = require("../src/shared/Logic/Bundles")
local Economy = require("../src/shared/Config/Economy")
local Income = require("../src/shared/Logic/Income")
local Lanterns = require("../src/shared/Config/Lanterns")
local Monetisation = require("../src/shared/Config/Monetisation")
local Money = require("../src/shared/Logic/Money")
local Ownership = require("../src/shared/Logic/Ownership")
local Passes = require("../src/shared/Logic/Passes")
local Plots = require("../src/shared/Config/Plots")
local PolicyGate = require("../src/shared/Logic/PolicyGate")
local Receipts = require("../src/shared/Logic/Receipts")
local RelicsCopy = require("../src/shared/Logic/RelicsCopy")
local RelicsPip = require("../src/shared/Logic/RelicsPip")
local RelicsView = require("../src/shared/Logic/RelicsView")
local Return = require("../src/shared/Config/Return")
local Save = require("../src/shared/Config/Save")
local Schema = require("../src/shared/Logic/Schema")
local Snapshot = require("../src/shared/Logic/Snapshot")
local Transactions = require("../src/shared/Logic/Transactions")
local UITheme = require("../src/shared/UITheme")
local Check = require("./check")

local function fresh(): any
	return Schema.newProfile(1_000, "starter")
end

local function coffer(): any
	return {
		key = "coffer",
		kind = "bundle",
		feature = true,
		id = 42,
	}
end

local function deps(now: number, rate: number, save: () -> boolean): any
	return {
		loaded = true,
		now = function()
			return now
		end,
		rate = function()
			return rate
		end,
		lookup = function(id: any)
			if id == 42 then
				return coffer()
			end
			return nil
		end,
		save = save,
	}
end

local function receipt(id: string, spent: number?): any
	return {
		PurchaseId = id,
		ProductId = 42,
		CurrencySpent = spent or 0,
	}
end

local BANNED = {
	"FREE!",
	"% OFF",
	"was",
	"Only X left",
	"Last chance",
	"Expires",
	"Lucky",
	"Boost your odds",
}

Check.test("no product id or catalog price ships enabled", function()
	Check.eq(Save.DATA_VERSION, 10)
	local sawBundle = false
	local sawPass = false
	for _, entry in Monetisation.items() do
		Check.eq(entry.id, nil, entry.key)
		Check.eq(entry.catalogPrice, nil, entry.key)
		Check.eq(Monetisation.isLive(entry), false, entry.key)
		Check.eq(Monetisation.passLive(entry.key), false, entry.key)
		if entry.kind == "bundle" then
			sawBundle = true
		end
		if entry.kind == "pass" then
			sawPass = true
		end
	end
	Check.eq(sawBundle, true)
	Check.eq(sawPass, true)
	Check.eq(Monetisation.byKey("cashDouble").feature, true)
	Check.eq(Monetisation.byKey("extraPads").feature, true)
	Check.eq(Monetisation.byKey("lairCosmetics").feature, true)
	Check.eq(Monetisation.byKey("starterPack").feature, true)
	Check.eq(Monetisation.byKey("autoCollect").feature, false)
	Check.eq(Monetisation.byKey("sigilNameplate").feature, false)
	Check.eq(Monetisation.byKey("serverLuck"), nil)
	Check.eq(Monetisation.byKey("crate"), nil)
	Check.eq(Return.CASH_DOUBLE_PASS_ID, nil)
	Check.eq(Return.AUTO_COLLECT_PASS_ID, nil)
	local config = fs.readFile("src/shared/Config/Monetisation.luau")
	Check.eq(string.find(string.lower(config), "tarot", 1, true), nil)
	Check.eq(string.find(string.lower(config), "crate", 1, true), nil)
	Check.eq(string.find(config, "serverLuck", 1, true), nil)
end)

Check.test("a receipt is granted once and only after the save succeeds", function()
	local profile = fresh()
	local start = profile.cash
	local tithe = profile.tithe
	local earned = profile.totalEarned
	local saves = 0
	local function save(): boolean
		saves += 1
		return true
	end
	local first = Receipts.process(receipt("buy-1", 99), profile, deps(10, 0, save))
	Check.eq(first.decision, Receipts.GRANTED)
	Check.eq(first.fresh, true)
	Check.eq(first.cash, 10000)
	Check.eq(profile.cash, start + 10000)
	Check.eq(profile.tithe, tithe)
	Check.eq(profile.totalEarned, earned)
	Check.eq(profile.purchases.firstPurchaseAt, 10)
	Check.eq(profile.cosmetics.owned[Monetisation.FOUNDERS_CANDLE], true)
	local second = Receipts.process(receipt("buy-1", 99), profile, deps(10, 0, save))
	Check.eq(second.decision, Receipts.GRANTED)
	Check.eq(second.fresh, false)
	Check.eq(profile.cash, start + 10000)
	Check.eq(saves, 1)
	Check.eq(profile.purchases.ledger["buy-1"].productId, 42)
	local kept = Schema.migrate(serde.decode("json", serde.encode("json", profile)))
	Check.eq(kept.cash, start + 10000)
	Check.eq(kept.purchases.ledger["buy-1"].productId, 42)
	Check.eq(kept.purchases.firstPurchaseAt, 10)
	Check.eq(kept.cosmetics.owned[Monetisation.FOUNDERS_CANDLE], true)
end)

Check.test("an unloaded profile and a failed save return NotProcessedYet", function()
	local profile = fresh()
	local start = profile.cash
	local calls = 0
	local unloaded = deps(10, 0, function()
		calls += 1
		return true
	end)
	unloaded.loaded = false
	local skipped = Receipts.process(receipt("buy-unloaded"), profile, unloaded)
	Check.eq(skipped.decision, Receipts.NOT_PROCESSED)
	Check.eq(calls, 0)
	Check.eq(profile.cash, start)
	Check.eq(profile.purchases.ledger["buy-unloaded"], nil)

	local mode = "fail"
	local function save(): boolean
		calls += 1
		if mode == "fail" then
			return false
		end
		if mode == "throw" then
			error("disk")
		end
		return true
	end
	local failed = Receipts.process(receipt("buy-save"), profile, deps(20, 0, save))
	Check.eq(failed.decision, Receipts.NOT_PROCESSED)
	Check.eq(profile.cash, start)
	Check.eq(profile.purchases.ledger["buy-save"], nil)
	Check.eq(profile.purchases.firstPurchaseAt, nil)
	mode = "throw"
	local threw = Receipts.process(receipt("buy-save"), profile, deps(20, 0, save))
	Check.eq(threw.decision, Receipts.NOT_PROCESSED)
	Check.eq(profile.cash, start)
	mode = "ok"
	local granted = Receipts.process(receipt("buy-save"), profile, deps(20, 0, save))
	Check.eq(granted.decision, Receipts.GRANTED)
	Check.eq(granted.fresh, true)
	Check.eq(profile.cash, start + 10000)
	local again = Receipts.process(receipt("buy-save"), profile, deps(20, 0, save))
	Check.eq(again.fresh, false)
	Check.eq(profile.cash, start + 10000)
end)

Check.test("a bundle quote locks for five minutes and the grant is the max", function()
	local profile = fresh()
	Check.eq(Bundles.amount(0, "pouch"), 2000)
	Check.eq(Bundles.amount(0, "coffer"), 10000)
	Check.eq(Bundles.amount(0, "chest"), 30000)
	Check.eq(Bundles.amount(0, "vault"), 75000)
	Check.eq(Bundles.amount(100, "pouch"), 60000)
	Check.eq(Bundles.amount(200, "pouch"), 120000)
	Check.eq(Monetisation.byKey("pouch").minutes, 10)
	Check.eq(Monetisation.byKey("coffer").minutes, 45)
	Check.eq(Monetisation.byKey("chest").minutes, 120)
	Check.eq(Monetisation.byKey("vault").minutes, 300)
	Check.eq(Monetisation.QUOTE_LOCK_SECONDS, 300)

	local locked = Bundles.lockQuote(profile, "coffer", 5000, 1000)
	Check.eq(locked, 2_700_000)
	Check.eq(Bundles.grantAmount(profile, "coffer", 5000 + 299, 0), 2_700_000)
	Check.eq(Bundles.grantAmount(profile, "coffer", 5000 + 10, 2000), 5_400_000)
	Check.eq(Bundles.grantAmount(profile, "coffer", 5000 + 300, 0), 10000)

	local quoted = fresh()
	Bundles.lockQuote(quoted, "coffer", 80, 1000)
	local saves = 0
	local result = Receipts.process(
		receipt("quoted"),
		quoted,
		deps(80, 0, function()
			saves += 1
			return true
		end)
	)
	Check.eq(result.cash, 2_700_000)
	Check.eq(quoted.cash, 25 + 2_700_000)
	Check.eq(quoted.tithe, 0)
	Check.eq(saves, 1)
end)

Check.test("2x cash never changes tithe and relic pads are excluded from tithe", function()
	local profile = fresh()
	profile.cashDouble = true
	Check.eq(Ownership.cashMultiplier(profile), 1)
	Check.eq(Bundles.prePassRate(profile), Income.perSecond(profile))
	local plain = Ownership.cryptidTick(profile, 10, Return.CASH_DOUBLE_MULTIPLIER)
	Check.eq(plain.tithe * Return.CASH_DOUBLE_MULTIPLIER, plain.cash)
	Check.eq(plain.tithe, Income.tithePerSecond(profile) * 10)

	profile.padsUnlocked = Economy.MAX_PADS
	profile.passes.extraPads = true
	profile.cryptids.relicbeast = {
		speciesId = "flatwoods_monster",
		mutation = "",
		traits = {},
		acquiredAt = 5,
		source = "relic",
	}
	profile.pads["9"] = "relicbeast"
	local full = Income.perSecond(profile)
	local titheRate = Income.tithePerSecond(profile)
	local relic = Income.contribution("flatwoods_monster", profile.upgrades.boneAltar, false)
	Check.eq(Money.round(full - titheRate), relic)
	Check.eq(relic > 0, true)
	local tick = Ownership.cryptidTick(profile, 10, Return.CASH_DOUBLE_MULTIPLIER)
	Check.eq(tick.tithe, Money.round(titheRate * 10))
	Check.eq(tick.cash, Money.round(full * Return.CASH_DOUBLE_MULTIPLIER * 10))
	Check.eq(tick.tithe == Money.round(full * Return.CASH_DOUBLE_MULTIPLIER * 10), false)
	Check.eq(Bundles.prePassRate(profile), full)
	local beforeTithe = profile.tithe
	Transactions.creditIncome(profile, 4)
	Check.eq(profile.tithe, beforeTithe + Ownership.cryptidTick(profile, 4).tithe)
	Check.eq(profile.tithe, beforeTithe + Money.round(titheRate * 4))
end)

Check.test("the starter pack grants once and the pass is not re-granted", function()
	local profile = fresh()
	local start = profile.cash
	local first = Passes.grant(profile, "starterPack", 50, "pack-1")
	Check.eq(first.changed, true)
	Check.eq(first.cash, Monetisation.STARTER_CASH)
	Check.eq(profile.cash, start + Monetisation.STARTER_CASH)
	Check.eq(profile.tithe, 0)
	Check.eq(profile.totalEarned, 0)
	Check.eq(profile.purchases.starterPackClaimed, true)
	Check.eq(profile.purchases.firstPurchaseAt, 50)
	Check.eq(profile.cryptids["pack-1"].speciesId, Monetisation.STARTER_SPECIES)
	Check.eq(profile.cryptids["pack-1"].source, "relic")
	Check.eq(profile.cosmetics.owned[Monetisation.FOUNDERS_CANDLE], true)
	local second = Passes.grant(profile, "starterPack", 80, "pack-2")
	Check.eq(second.changed, false)
	Check.eq(profile.cryptids["pack-2"], nil)
	Check.eq(profile.cash, start + Monetisation.STARTER_CASH)
	Check.eq(profile.purchases.firstPurchaseAt, 50)
	local doubled = Passes.grant(profile, "cashDouble", 90, nil)
	Check.eq(doubled.changed, true)
	Check.eq(profile.cashDouble, true)
	Check.eq(profile.purchases.firstPurchaseAt, 50)
	Check.eq(Ownership.cashMultiplier(profile), 1)
	local kept = Schema.migrate(profile)
	Check.eq(kept.purchases.starterPackClaimed, true)
	Check.eq(kept.cryptids["pack-1"].source, "relic")
	Check.eq(kept.padsUnlocked, 2)
end)

Check.test("the policy wrapper fails closed and caches a real answer", function()
	PolicyGate.reset()
	local sleeps = {}
	local errors = 0
	local function boom()
		errors += 1
		error("policy down")
	end
	local function sleep(seconds: number)
		table.insert(sleeps, seconds)
	end
	Check.eq(PolicyGate.allows("down", boom, sleep), false)
	Check.eq(errors, Monetisation.POLICY_ATTEMPTS)
	Check.eq(sleeps[1], Monetisation.POLICY_BACKOFF[1])
	Check.eq(sleeps[2], Monetisation.POLICY_BACKOFF[2])
	Check.eq(#sleeps, Monetisation.POLICY_ATTEMPTS - 1)
	local after = errors
	Check.eq(PolicyGate.allows("down", boom, sleep), false)
	Check.eq(errors > after, true)

	local restrictedCalls = 0
	Check.eq(
		PolicyGate.allows("held", function()
			restrictedCalls += 1
			return { ArePaidRandomItemsRestricted = true }
		end, sleep),
		false
	)
	Check.eq(
		PolicyGate.allows("held", function()
			restrictedCalls += 1
			return { ArePaidRandomItemsRestricted = false }
		end, sleep),
		false
	)
	Check.eq(restrictedCalls, 1)

	local openCalls = 0
	Check.eq(
		PolicyGate.allows("open", function()
			openCalls += 1
			return { ArePaidRandomItemsRestricted = false }
		end, sleep),
		true
	)
	Check.eq(
		PolicyGate.allows("open", function()
			openCalls += 1
			error("later")
		end, sleep),
		true
	)
	Check.eq(openCalls, 1)

	Check.eq(
		PolicyGate.allows("blank", function()
			return {}
		end, sleep),
		false
	)
	Check.eq(
		PolicyGate.allows("text", function()
			return "no"
		end, sleep),
		false
	)

	local calls = 0
	local owned = Passes.confirm(function()
		calls += 1
		error("ownership")
	end, sleep)
	Check.eq(owned, nil)
	Check.eq(calls, Monetisation.OWNERSHIP_ATTEMPTS)
	Check.eq(
		Passes.confirm(function()
			return false
		end, sleep),
		false
	)
	Check.eq(
		Passes.confirm(function()
			return true
		end, sleep),
		true
	)
end)

Check.test("relic pads 9 and 10 stay sealed until the pass and tithe ignores them", function()
	Check.eq(Economy.PAD_7_COST, 15000)
	Check.eq(Economy.PAD_8_COST, 40000)
	Check.eq(Economy.padCost(7, 0), Economy.PAD_7_COST)
	Check.eq(Economy.padCost(8, 0), Economy.PAD_8_COST)
	Check.eq(Economy.padCost(7, 1), Economy.PAD_7_COST * BoneAltar.REBIRTH_FACTOR)
	Check.eq(Economy.padCost(9, 0), nil)
	Check.eq(Plots.SEALED_LABEL, "Sealed")
	Check.eq(RelicsCopy.RELIC_PAD, "Relic pad · View Item")
	Check.eq(Monetisation.RELIC_PADS[1], 9)
	Check.eq(Monetisation.RELIC_PADS[2], 10)
	Check.eq(Lanterns.PER_PLOT_LIGHT_CAP, 8)
	Check.eq(Plots.PAD_COUNT, 12)

	local profile = fresh()
	profile.padsUnlocked = 6
	profile.cash = Economy.PAD_7_COST
	Check.eq(Transactions.unlockPad(profile, 7), true)
	Check.eq(profile.padsUnlocked, 7)
	Check.eq(profile.cash, 0)
	profile.cash = Economy.PAD_8_COST
	Check.eq(Transactions.unlockPad(profile, 8), true)
	Check.eq(profile.padsUnlocked, 8)
	Check.eq(profile.cash, 0)
	local blocked = profile.cash
	Check.eq(Transactions.unlockPad(profile, 9), false)
	Check.eq(profile.padsUnlocked, 8)
	Check.eq(profile.cash, blocked)
	Check.eq(Monetisation.relicLocked(profile, 9), true)
	Check.eq(Monetisation.relicLocked(profile, 10), true)

	profile.rebirths = 1
	profile.padsUnlocked = 6
	profile.cash = Economy.padCost(7, 1)
	Check.eq(Transactions.unlockPad(profile, 7), true)
	Check.eq(profile.cash, 0)
	Check.eq(profile.padsUnlocked, 7)

	local buyer = fresh()
	buyer.padsUnlocked = Economy.CASH_PAD_MAX
	buyer.passes.extraPads = true
	buyer.cash = Economy.PAD_8_COST
	buyer.padsUnlocked = 7
	Check.eq(Transactions.unlockPad(buyer, 8), true)
	Check.eq(buyer.padsUnlocked, Economy.MAX_PADS)
	Check.eq(buyer.passes.extraPads, true)

	local gifted = fresh()
	gifted.padsUnlocked = Economy.CASH_PAD_MAX
	local tithe = gifted.tithe
	local grant = Passes.grant(gifted, "extraPads", 30, nil)
	Check.eq(grant.changed, true)
	Check.eq(gifted.padsUnlocked, Economy.MAX_PADS)
	Check.eq(gifted.tithe, tithe)
	gifted.padsUnlocked = Economy.STARTING_PADS_UNLOCKED
	local saved = Schema.migrate(gifted)
	Check.eq(saved.passes.extraPads, true)
	Check.eq(saved.padsUnlocked, Economy.STARTING_PADS_UNLOCKED)
	Check.eq(Passes.openRelicPads(saved), false)
	saved.padsUnlocked = Economy.CASH_PAD_MAX
	Check.eq(Passes.openRelicPads(saved), true)
	Check.eq(saved.padsUnlocked, Economy.MAX_PADS)

	local early = fresh()
	early.padsUnlocked = Economy.CASH_PAD_MAX
	early.onboarding.step = 8
	early.onboarding.playSeconds = Monetisation.GATE_PLAY_SECONDS - 1
	local hidden = Snapshot.build(early, 0, 1)
	Check.eq(hidden.relics.visible, false)
	Check.eq(RelicsView.showRelicPad(hidden.relics), false)
	Check.eq(Monetisation.shopOpen(early), false)
	early.onboarding.playSeconds = Monetisation.GATE_PLAY_SECONDS
	local open = Snapshot.build(early, 0, 2)
	Check.eq(open.relics.visible, true)
	Check.eq(open.relics.padLine, RelicsCopy.RELIC_PAD)
	Check.eq(open.relics.padButton, RelicsCopy.OPEN_SHOP)
	Check.eq(RelicsView.showRelicPad(open.relics), true)
	local pad9 = nil
	for _, entry in open.pads do
		if entry.index == 9 then
			pad9 = entry
		end
	end
	Check.eq(pad9.state, "sealed")
	Check.eq(pad9.affordable, false)
	early.onboarding.step = 7
	early.onboarding.playSeconds = 1000
	Check.eq(RelicsView.showRelicPad(Snapshot.build(early, 0, 3).relics), false)
	early.onboarding.step = 8
	early.onboarding.playSeconds = Monetisation.GATE_PLAY_SECONDS
	early.passes.extraPads = true
	early.padsUnlocked = Economy.MAX_PADS
	Check.eq(RelicsView.showRelicPad(Snapshot.build(early, 0, 4).relics), false)
	Check.eq(Monetisation.relicLocked(early, 9), false)
end)

Check.test("the shop copy stays inside the gate and the receipt path does not roll", function()
	local profile = fresh()
	profile.onboarding.step = 8
	profile.onboarding.playSeconds = Monetisation.GATE_PLAY_SECONDS
	local view = RelicsView.build(profile, 10, 0, 0)
	Check.eq(view.header, RelicsCopy.HEADER)
	Check.eq(view.sub, RelicsCopy.SUB)
	Check.eq(view.button, RelicsCopy.BUTTON)
	Check.eq(view.spend, "This session: 0 Relics · 0 R$")
	Check.eq(#view.cards, 8)
	Check.eq(view.cards[1].key, "starterPack")
	for _, card in view.cards do
		Check.eq(card.live, false)
		Check.eq(card.button, "")
		for _, phrase in BANNED do
			Check.eq(string.find(card.line, phrase, 1, true), nil, card.key)
		end
	end
	local vault = view.cards[#view.cards]
	Check.eq(vault.key, "vault")
	Check.eq(string.find(vault.line, RelicsCopy.VAULT_TAG, 1, true) ~= nil, true)
	Check.eq(
		RelicsView.buttonFor({ kind = "bundle", feature = true, id = 5, looks = false }, false),
		RelicsCopy.SEE_PRICE
	)
	Check.eq(RelicsView.buttonFor({ kind = "pass", feature = true, id = 6, looks = true }, false), RelicsCopy.VIEW_ITEM)
	Check.eq(RelicsView.buttonFor(Monetisation.byKey("pouch"), false), "")

	local receipts = fs.readFile("src/shared/Logic/Receipts.luau")
	Check.eq(string.find(receipts, "math.random", 1, true), nil)
	Check.eq(string.find(receipts, "Random.new", 1, true), nil)
	Check.eq(string.find(receipts, "PolicyGate", 1, true), nil)
	local service = fs.readFile("src/server/MonetisationService.luau")
	local gate = string.find(service, "shopOpen", 1, true)
	local productPrompt = string.find(service, "PromptProductPurchase", 1, true)
	local passPrompt = string.find(service, "PromptGamePassPurchase", 1, true)
	Check.truthy(gate)
	Check.truthy(productPrompt)
	Check.truthy(passPrompt)
	Check.eq((gate :: number) < (productPrompt :: number), true)
	Check.eq((gate :: number) < (passPrompt :: number), true)
	local shop = fs.readFile("src/client/RelicsShop.luau")
	Check.eq(string.find(shop, "MarketplaceService", 1, true), nil)
	Check.eq(string.find(shop, "PromptProductPurchase", 1, true), nil)
	Check.eq(string.find(shop, "PromptGamePassPurchase", 1, true), nil)
	Check.eq(string.find(shop, "RelicsView.showRelicPad", 1, true) ~= nil, true)

	profile.ui.relicsPipShown = true
	profile.onboarding.playSeconds = Monetisation.GATE_PLAY_SECONDS - 1
	Check.eq(RelicsPip.shouldShow(profile), false)
	profile.onboarding.playSeconds = Monetisation.GATE_PLAY_SECONDS
	Check.eq(RelicsPip.shouldShow(profile), true)
	Check.eq(RelicsPip.clear(profile), true)
	Check.eq(RelicsPip.shouldShow(profile), false)
	Check.eq(RelicsPip.note(profile, "flatwoods_monster"), false)
	Check.eq(UITheme.palette.GoldBright, "C9A55A")
	Check.eq(UITheme.shape.relicsPip, 10)
	Check.eq(UITheme.motion.relicsPip.pulses, 2)
	Check.eq(UITheme.resolveMotion("relicsPip", true).allowScale, false)
end)

Check.test("v5 and v7 saves keep the ledger and gain shop defaults on the way to v10", function()
	local v5 = fresh()
	v5.dataVersion = 5
	v5.cash = 80
	v5.skills = { "h1" }
	v5.onboarding.step = 8
	v5.onboarding.playSeconds = 40
	v5.purchases = nil
	v5.passes = nil
	v5.ui = nil
	v5.cashDouble = nil
	v5.autoCollect = nil
	local fromV5 = Schema.migrate(v5, 10)
	Check.eq(fromV5.dataVersion, 10)
	Check.eq(fromV5.analytics.lastReturnDay, 0)
	Check.eq(fromV5.analytics.funnelStep, 0)
	Check.eq(fromV5.cash, 80)
	Check.eq(fromV5.skills[1], "h1")
	Check.eq(fromV5.onboarding.step, 8)
	Check.eq(fromV5.onboarding.playSeconds, 40)
	Check.eq(fromV5.passes.extraPads, false)
	Check.eq(fromV5.cashDouble, false)
	Check.eq(fromV5.purchases.starterPackClaimed, false)
	Check.eq(fromV5.ui.relicsPipCleared, false)

	local v7 = fresh()
	v7.dataVersion = 7
	v7.cash = 19
	v7.skills = { "l1" }
	v7.onboarding.step = 4
	v7.onboarding.playSeconds = 9
	v7.purchases = nil
	v7.cosmetics = nil
	v7.giftedPasses = nil
	v7.giftsReceived = nil
	v7.tarot = nil
	v7.bloodMoon = nil
	v7.ui = nil
	v7.cashDouble = nil
	v7.autoCollect = nil
	v7.passes = nil
	local fromV7 = Schema.migrate(v7, 10)
	Check.eq(fromV7.dataVersion, 10)
	Check.eq(fromV7.analytics.lastReturnDay, 0)
	Check.eq(fromV7.analytics.funnelStep, 0)
	Check.eq(fromV7.cash, 19)
	Check.eq(fromV7.skills[1], "l1")
	Check.eq(fromV7.onboarding.step, 4)
	Check.eq(fromV7.onboarding.playSeconds, 9)
	Check.eq(fromV7.passes.extraPads, false)
	Check.eq(fromV7.passes.lairCosmetics, false)
	Check.eq(fromV7.passes.sigilNameplate, false)
	Check.eq(fromV7.cashDouble, false)
	Check.eq(fromV7.autoCollect, false)
	Check.eq(fromV7.purchases.starterPackClaimed, false)
	Check.eq(next(fromV7.purchases.ledger), nil)
	Check.eq(fromV7.ui.relicsPipShown, false)
	local again = Schema.migrate(fromV7, 99)
	Check.eq(again.cash, 19)
	Check.eq(again.onboarding.step, 4)
	Check.eq(again.skills[1], "l1")
	Check.eq(again.passes.extraPads, false)
end)
