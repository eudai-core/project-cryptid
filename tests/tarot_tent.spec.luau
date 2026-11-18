--!strict

_G.LUNE = true

local fs = require("@lune/fs")

local Check = require("./check")
local Analytics = require("../src/shared/Config/Analytics")
local Monetisation = require("../src/shared/Config/Monetisation")
local Save = require("../src/shared/Config/Save")
local TarotCases = require("../src/shared/Config/TarotCases")
local PolicyGate = require("../src/shared/Logic/PolicyGate")
local QaArgs = require("../src/shared/Logic/QaArgs")
local Receipts = require("../src/shared/Logic/Receipts")
local RemoteArgs = require("../src/shared/Logic/RemoteArgs")
local Schema = require("../src/shared/Logic/Schema")
local TarotAccess = require("../src/shared/Logic/TarotAccess")
local TarotOdds = require("../src/shared/Logic/TarotOdds")
local TarotReceipts = require("../src/shared/Logic/TarotReceipts")
local TarotShop = require("../src/shared/Logic/TarotShop")
local Transactions = require("../src/shared/Logic/Transactions")

local function profile()
	return Schema.newProfile(1_700_000_000, "starter-tarot")
end

local function cryptidCount(held): number
	local count = 0
	for _ in held.cryptids do
		count += 1
	end
	return count
end

local function readingCount(held, speciesId: string): number
	local count = 0
	for _, cryptid in held.cryptids do
		if cryptid.speciesId == speciesId and cryptid.source == "reading" then
			count += 1
		end
	end
	return count
end

local function sequence(values: { number })
	local index = 0
	return function(_seed: number)
		return {
			NextInteger = function(_self, minimum: number, _maximum: number)
				index += 1
				local value = values[index]
				if value == nil then
					return minimum
				end
				return value
			end,
		}
	end
end

local function openDeps(rng, extra: any?)
	local deps = {
		now = 1_700_000_000,
		entropy = 11,
		paidEnabled = false,
		policyAllows = false,
		gate = {
			opened = true,
			distance = 1,
			step = 1,
		},
		rng = rng,
		newId = function()
			return "card-" .. tostring(math.floor(os.clock() * 1000000))
		end,
	}
	if type(extra) == "table" then
		for key, value in extra do
			deps[key] = value
		end
	end
	return deps
end

local function cardById(view, id: string)
	for _, card in view.cases do
		if card.id == id then
			return card
		end
	end
	return nil
end

local function basisOf(rows): number
	local total = 0
	for _, row in rows do
		total += row.basis
	end
	return total
end

Check.test("displayed odds are the roll weights and add to 100%", function()
	for _, case in TarotCases.list() do
		for _, pity in { 0, case.pity.within - 1 } do
			local live = TarotOdds.live(case, pity)
			local shown = TarotOdds.disclose(case, pity)
			Check.eq(#shown, #live, case.id)
			for index, row in shown do
				Check.eq(row.weight, live[index].weight, case.id .. " " .. row.rarity)
				Check.eq(row.rarity, live[index].rarity, case.id)
			end
			Check.eq(basisOf(shown), TarotCases.PERCENT_BASIS, case.id)
		end
	end
	local pale = TarotOdds.live(TarotCases.get("pale"), 0)
	local function pick(roll: number): string
		return TarotOdds.pick(pale, {
			NextInteger = function()
				return roll
			end,
		})
	end
	Check.eq(pick(1), "Common")
	Check.eq(pick(55), "Common")
	Check.eq(pick(56), "Uncommon")
	Check.eq(pick(90), "Uncommon")
	Check.eq(pick(91), "Rare")
	Check.eq(pick(99), "Rare")
	Check.eq(pick(100), "Epic")
	local split = TarotOdds.percents({
		{ rarity = "A", weight = 1 },
		{ rarity = "B", weight = 1 },
		{ rarity = "C", weight = 1 },
	})
	Check.eq(basisOf(split), TarotCases.PERCENT_BASIS)
	local seen = {}
	for _, row in split do
		seen[row.basis] = (seen[row.basis] or 0) + 1
	end
	Check.eq(seen[3334], 1)
	Check.eq(seen[3333], 2)
	local due = TarotOdds.disclose(TarotCases.get("tier1"), 19)
	local byRarity = {}
	for _, row in due do
		byRarity[row.rarity] = row
	end
	Check.eq(byRarity.Common, nil)
	Check.eq(byRarity.Uncommon, nil)
	Check.eq(byRarity.Rare.weight, 8)
	Check.eq(byRarity.Epic.weight, 2)
	Check.eq(byRarity.Rare.basis, 8000)
	Check.eq(byRarity.Epic.basis, 2000)
end)

Check.test("pity guarantees the floor and a miss increments the counter", function()
	local held = profile()
	held.tarot.tokens.pale = 1
	held.tarot.familyPity.pale = 39
	local result = TarotShop.open(held, "pale", "pity-1", openDeps(sequence({ 1, 1 })))
	Check.eq(result.code, "ok")
	Check.eq(result.rarity, "Epic")
	Check.eq(held.tarot.familyPity.pale, 0)
	Check.eq(held.tarot.pity.pale, 0)
	Check.eq(readingCount(held, "epic_01"), 1)

	local fresh = profile()
	fresh.tarot.tokens.pale = 1
	local miss = TarotShop.open(fresh, "pale", "pity-2", openDeps(sequence({ 1, 1, 1 })))
	Check.eq(miss.code, "ok")
	Check.eq(miss.rarity, "Common")
	Check.eq(fresh.tarot.familyPity.pale, 1)
	Check.eq(fresh.tarot.pity.pale, 1)
end)

Check.test("duplicates reroll inside the rarity and otherwise become that card's cash", function()
	local held = profile()
	held.tarot.tokens.pale = 1
	Transactions.grantReading(held, "own-fresno", "fresno_nightcrawler", 1)
	Transactions.grantReading(held, "own-hide", "hidebehind", 1)
	local before = cryptidCount(held)
	local result = TarotShop.open(held, "pale", "dupe-1", openDeps(sequence({ 1, 1, 1 })))
	Check.eq(result.code, "ok")
	Check.eq(result.rarity, "Common")
	Check.eq(readingCount(held, "hodag"), 1)
	Check.eq(cryptidCount(held), before + 1)

	local owned = profile()
	owned.tarot.tokens.pale = 1
	local cash = owned.cash
	local earned = owned.totalEarned
	local roster = cryptidCount(owned)
	Transactions.grantReading(owned, "own-fresno", "fresno_nightcrawler", 1)
	Transactions.grantReading(owned, "own-hide", "hidebehind", 1)
	Transactions.grantReading(owned, "own-hodag", "hodag", 1)
	local converted = TarotShop.open(owned, "pale", "dupe-2", openDeps(sequence({ 1, 1 })))
	Check.eq(converted.code, "ok")
	Check.eq(owned.cash, cash + 60)
	Check.eq(owned.totalEarned, earned + 60)
	Check.eq(cryptidCount(owned), roster + 3)
	Check.contains(converted.message, "became")
end)

Check.test("a replayed request does not roll or spend again", function()
	local held = profile()
	held.tarot.tokens.pale = 1
	local deps = openDeps(sequence({ 1, 1, 1 }))
	local first = TarotShop.open(held, "pale", "again-1", deps)
	Check.eq(first.code, "ok")
	Check.eq(held.tarot.tokens.pale, 0)
	local roster = cryptidCount(held)
	deps.gate.distance = 100
	local second = TarotShop.open(held, "pale", "again-1", deps)
	Check.eq(second.code, "replay")
	Check.eq(second.message, first.message)
	Check.eq(held.tarot.tokens.pale, 0)
	Check.eq(cryptidCount(held), roster)
end)

Check.test("bad remote arguments and a closed or distant tent are refused", function()
	local held = profile()
	held.tarot.tokens.pale = 3
	local deps = openDeps(sequence({ 1 }))
	for _, caseId in { nil, "", "nope", 5, { id = "pale" } } do
		local refused = TarotShop.open(held, caseId, "bad-1", deps)
		Check.eq(refused.code, "args")
	end
	Check.eq(TarotShop.open(held, "pale", "", deps).code, "args")
	Check.eq(TarotShop.open(held, "pale", "bad id", deps).code, "args")
	deps.gate.opened = false
	Check.eq(TarotShop.open(held, "pale", "far-1", deps).code, "open")
	deps.gate.opened = true
	deps.gate.distance = 100
	Check.eq(TarotShop.open(held, "pale", "far-2", deps).code, "distance")
	deps.gate.distance = 1
	deps.gate.step = 1
	deps.weight = 0
	deps.price = 5
	deps.pity = 99
	deps.productId = 4242
	local opened = TarotShop.open(
		held,
		"pale",
		"step-1",
		openDeps(sequence({ 1, 1, 1 }), {
			weight = 0,
			price = 5,
			pity = 99,
			productId = 4242,
		})
	)
	Check.eq(opened.code, "ok")
	Check.eq(opened.rarity, "Common")
	Check.eq(held.tarot.familyPity.pale, 1)
	Check.eq(held.tarot.tokens.pale, 2)
	Check.eq(RemoteArgs.tarotCase("pale"), "pale")
	Check.eq(RemoteArgs.tarotCase("nope"), nil)
	Check.eq(RemoteArgs.tarotCase({}), nil)
end)

Check.test("paid cases ship off, show the same odds, and never prompt a nil product", function()
	Check.eq(TarotCases.PAID_TAROT_ENABLED, false)
	local source = fs.readFile("src/shared/Config/TarotCases.luau")
	Check.contains(source, "TBD: pending Eudai approval")
	for _, case in TarotCases.list() do
		if case.kind ~= "free" then
			Check.eq(case.productId, nil, case.id)
			Check.eq(case.price, nil, case.id)
			Check.eq(case.placeholder, true, case.id)
			Check.eq(TarotCases.byProductId(4242), nil)
		end
	end
	local held = profile()
	held.tarot.cases.tier1 = 1
	local refused = TarotShop.open(
		held,
		"tier1",
		"paid-1",
		openDeps(sequence({ 1, 1 }), {
			paidEnabled = false,
			policyAllows = true,
		})
	)
	Check.eq(refused.code, "unavailable")
	Check.eq(held.tarot.cases.tier1, 1)
	local buy = TarotShop.buy(held, "tier1", "paid-2", {
		paidEnabled = true,
		policyAllows = true,
		now = 1,
	})
	Check.eq(buy.prompt, false)
	Check.eq(buy.productId, nil)
	local synthetic = {
		id = "tier1",
		kind = "paid",
		productId = 4242,
		pity = { rarity = "Rare", within = 20 },
	}
	local prompt = TarotShop.decide(synthetic, {
		paidEnabled = true,
		policyAllows = true,
		now = 1,
	})
	Check.eq(prompt.prompt, true)
	Check.eq(prompt.productId, 4242)
	local restricted = TarotShop.decide(synthetic, {
		paidEnabled = true,
		policyAllows = false,
		now = 1,
	})
	Check.eq(restricted.prompt, false)
	local opened = TarotShop.open(
		held,
		"tier1",
		"paid-3",
		openDeps(sequence({ 1, 1 }), {
			paidEnabled = true,
			policyAllows = true,
		})
	)
	Check.eq(opened.code, "ok")
	Check.eq(held.tarot.known.placeholder_tier1_common, true)
	Check.eq(held.tarot.cases.tier1, nil)
	Check.eq(readingCount(held, "placeholder_tier1_common"), 0)
end)

Check.test("policy allows only an explicit false and fails closed", function()
	PolicyGate.reset()
	local calls = 0
	Check.eq(
		PolicyGate.allows("policy-user", function()
			calls += 1
			return { ArePaidRandomItemsRestricted = true }
		end, function() end),
		false
	)
	Check.eq(calls, 1)
	Check.eq(
		PolicyGate.allows("policy-user", function()
			calls += 1
			error("should stay cached")
		end, function() end),
		false
	)
	Check.eq(calls, 1)
	PolicyGate.forget("policy-user")
	local errors = 0
	Check.eq(
		PolicyGate.allows("policy-user", function()
			errors += 1
			error("timeout")
		end, function() end),
		false
	)
	Check.eq(errors, Monetisation.POLICY_ATTEMPTS)
	Check.eq(
		PolicyGate.allows("policy-user", function()
			return { ArePaidRandomItemsRestricted = false }
		end, function() end),
		true
	)
	Check.eq(
		PolicyGate.allows("policy-user", function()
			error("cached allow")
		end, function() end),
		true
	)
	PolicyGate.reset()
end)

Check.test("a tarot receipt grants one case once and rolls back a failed save", function()
	local fixture = {
		id = "tier1",
		productId = 4242,
	}
	local function run(held, paidEnabled: boolean, save, policy)
		return Receipts.process(
			{
				PurchaseId = "tarot-1",
				ProductId = 4242,
				CurrencySpent = 10,
			},
			held,
			{
				loaded = true,
				now = function()
					return 50
				end,
				rate = function()
					return 1
				end,
				lookup = function()
					return nil
				end,
				save = save,
				tarot = function(info, owner, deps)
					return TarotReceipts.process(info, owner, {
						paidEnabled = paidEnabled,
						policyAllows = policy,
						findCase = function(id)
							if id == 4242 then
								return fixture
							end
							return nil
						end,
						now = deps.now,
						save = deps.save,
					})
				end,
			}
		)
	end
	local held = profile()
	local saves = 0
	local first = run(held, true, function()
		saves += 1
		return true
	end, true)
	Check.eq(first.decision, Receipts.GRANTED)
	Check.eq(first.fresh, true)
	Check.eq(first.tarot, true)
	Check.eq(first.spent, 10)
	Check.eq(held.tarot.cases.tier1, 1)
	local second = run(held, false, function()
		saves += 1
		return true
	end, true)
	Check.eq(second.decision, Receipts.GRANTED)
	Check.eq(second.fresh, false)
	Check.eq(held.tarot.cases.tier1, 1)
	Check.eq(saves, 1)

	local failed = profile()
	local denied = run(failed, true, function()
		return false
	end, true)
	Check.eq(denied.decision, Receipts.NOT_PROCESSED)
	Check.eq(failed.tarot.cases.tier1, nil)
	Check.eq(next(failed.tarot.ledger), nil)

	local offline = profile()
	local quiet = run(offline, false, function()
		return true
	end, true)
	Check.eq(quiet.decision, Receipts.NOT_PROCESSED)
	Check.eq(offline.tarot.cases.tier1, nil)

	local unknown = Receipts.process(
		{
			PurchaseId = "tarot-2",
			ProductId = 4242,
		},
		profile(),
		{
			loaded = true,
			now = function()
				return 1
			end,
			rate = function()
				return 1
			end,
			lookup = TarotCases.byProductId,
			save = function()
				return true
			end,
			tarot = function(info, owner, deps)
				return TarotReceipts.process(info, owner, {
					paidEnabled = true,
					policyAllows = true,
					findCase = TarotCases.byProductId,
					now = deps.now,
					save = deps.save,
				})
			end,
		}
	)
	Check.eq(unknown.decision, Receipts.NOT_PROCESSED)

	local blocked = profile()
	local refused = TarotReceipts.process(
		{
			PurchaseId = "tarot-3",
			ProductId = 4242,
		},
		blocked,
		{
			paidEnabled = true,
			policy = function()
				error("policy down")
			end,
			findCase = function()
				return fixture
			end,
			now = 1,
			save = function()
				return true
			end,
		}
	)
	Check.eq(refused.decision, TarotReceipts.NOT_PROCESSED)
	Check.eq(blocked.tarot.cases.tier1, nil)
end)

Check.test("the event case uses a real end date and is hidden outside its window", function()
	local held = profile()
	local open = TarotShop.present(held, TarotCases.EVENT_START, {
		paidEnabled = false,
		policyAllows = true,
	})
	local event = cardById(open, "event")
	Check.truthy(event ~= nil)
	Check.contains(event.endsText, "Ends ")
	Check.contains(event.endsText, "2030-01-08")
	Check.contains(event.endsText, "UTC")
	Check.eq(string.find(event.endsText, "left", 1, true), nil)
	Check.eq(string.find(event.endsText, "only", 1, true), nil)
	Check.eq(event.button, TarotCases.NOT_AVAILABLE)
	local before = TarotShop.present(held, TarotCases.EVENT_START - 1, {
		paidEnabled = true,
		policyAllows = true,
	})
	Check.eq(cardById(before, "event"), nil)
	local after = TarotShop.present(held, TarotCases.EVENT_END, {
		paidEnabled = true,
		policyAllows = true,
	})
	Check.eq(cardById(after, "event"), nil)
	local hidden = TarotShop.present(held, TarotCases.EVENT_START, {
		paidEnabled = true,
		policyAllows = false,
	})
	Check.eq(cardById(hidden, "pale") ~= nil, true)
	Check.eq(cardById(hidden, "blood") ~= nil, true)
	Check.eq(cardById(hidden, "tier1"), nil)
	Check.eq(cardById(hidden, "event"), nil)
	local listed = TarotShop.present(held, 1_700_000_000, {
		paidEnabled = false,
		policyAllows = true,
	})
	Check.eq(cardById(listed, "tier1").button, TarotCases.NOT_AVAILABLE)
	Check.eq(cardById(listed, "tier1").action, "buy")
	Check.eq(cardById(listed, "pale").button, TarotCases.NO_CARDS)
	held.tarot.tokens.pale = 1
	local ready = TarotShop.present(held, 1_700_000_000, {
		paidEnabled = false,
		policyAllows = true,
	})
	Check.eq(cardById(ready, "pale").button, TarotCases.OPEN)
	Check.eq(cardById(ready, "pale").action, "open")
	Check.contains(ready.oddsNote, "100%")
end)

Check.test("tarot fields fill when missing and survive a round trip", function()
	local function stripped(version: number)
		local raw = Schema.deepCopy(profile())
		raw.dataVersion = version
		raw.tarot.pity.pale = 4
		raw.tarot.cases = nil
		raw.tarot.familyPity = nil
		raw.tarot.ledger = nil
		raw.tarot.requests = nil
		raw.tarot.known = nil
		raw.tarot.nonce = nil
		return raw
	end
	local loaded = Schema.migrate(stripped(Save.DATA_VERSION), 1_700_000_000)
	Check.truthy(loaded ~= nil)
	Check.eq(loaded.dataVersion, Save.DATA_VERSION)
	Check.eq(loaded.tarot.familyPity.pale, 4)
	Check.eq(loaded.tarot.pity.pale, 4)
	Check.eq(next(loaded.tarot.cases), nil)
	Check.eq(next(loaded.tarot.ledger), nil)
	Check.eq(loaded.tarot.nonce, 0)
	if Save.DATA_VERSION >= 10 then
		local fromV9 = Schema.migrate(stripped(9), 1_700_000_000)
		Check.truthy(fromV9 ~= nil, "v9 to v10")
		Check.eq(fromV9.dataVersion, 10)
		Check.eq(fromV9.tarot.familyPity.pale, 4)
		Check.eq(next(fromV9.tarot.cases), nil)
		local fromV10 = Schema.migrate(stripped(10), 1_700_000_000)
		Check.truthy(fromV10 ~= nil, "v10 without tarot fields")
		Check.eq(fromV10.dataVersion, 10)
		Check.eq(fromV10.tarot.familyPity.pale, 4)
		Check.eq(fromV10.tarot.nonce, 0)
	end

	local held = profile()
	held.tarot.cases.tier1 = 2
	held.tarot.familyPity.pale = 9
	held.tarot.pity.pale = 1
	held.tarot.ledger["purchase-1"] = {
		productId = 9,
		grantedAt = 4,
		caseId = "tier1",
		grants = { "case:tier1" },
	}
	Transactions.grantReading(held, "card-hodag", "hodag", 10)
	local round = Schema.migrate(Schema.deepCopy(held), 1_700_000_000)
	Check.eq(round.tarot.cases.tier1, 2)
	Check.eq(round.tarot.familyPity.pale, 9)
	Check.eq(round.tarot.pity.pale, 9)
	Check.eq(round.tarot.ledger["purchase-1"].productId, 9)
	Check.eq(round.cryptids["card-hodag"].source, "reading")
	Check.eq(round.cryptids["card-hodag"].speciesId, "hodag")

	local corrupt = Schema.deepCopy(held)
	corrupt.tarot.ledger["bad key"] = {
		productId = 1,
		grantedAt = 1,
		caseId = "tier1",
		grants = { "case:tier1" },
	}
	Check.eq(Schema.migrate(corrupt, 1_700_000_000), nil)

	local schema = fs.readFile("src/shared/Logic/Schema.luau")
	local v10At = string.find(schema, "local function migrateToV10", 1, true)
	local stepsAt = string.find(schema, "local MIGRATION_STEPS", 1, true)
	Check.truthy(v10At ~= nil and stepsAt ~= nil and v10At < stepsAt)
	local body = string.sub(schema, v10At, stepsAt)
	Check.contains(body, "TarotSave.apply")
	local v9At = string.find(schema, "local function migrateToV9", 1, true)
	local v9Body = string.sub(schema, v9At, v10At)
	Check.eq(string.find(v9Body, "TarotSave.apply", 1, true), nil)
	local migrateAt = string.find(schema, "function Schema.migrate", 1, true)
	local newAt = string.find(schema, "function Schema.newProfile", 1, true)
	Check.eq(string.find(string.sub(schema, migrateAt, newAt), "TarotSave.apply", 1, true), nil)
	Check.contains(string.sub(schema, newAt), "TarotSave.apply")
	local targets = Schema.migrationTargets()
	Check.eq(targets[#targets], Save.DATA_VERSION)
	Check.eq(Save.DATA_VERSION == 9 or Save.DATA_VERSION == 10, true)
end)

Check.test("the tent adds no analytics event and the client does not roll or prompt", function()
	for _, name in Analytics.CUSTOM_ORDER do
		Check.eq(string.find(string.lower(name), "tarot", 1, true), nil, name)
	end
	Check.eq(Analytics.MAX_CUSTOM_NAMES, 15)
	local panel = fs.readFile("src/client/TarotPanel.luau")
	Check.eq(string.find(panel, "MarketplaceService", 1, true), nil)
	Check.eq(string.find(panel, "Random", 1, true), nil)
	Check.eq(string.find(panel, "NextInteger", 1, true), nil)
	Check.eq(string.find(panel, "familyPity", 1, true), nil)
	Check.eq(string.find(panel, "PromptProductPurchase", 1, true), nil)
	Check.eq(string.find(panel, "math.random", 1, true), nil)
	Check.contains(panel, "FireServer(caseId, HttpService:GenerateGUID(false))")
	local service = fs.readFile("src/server/TarotService.luau")
	local guard = string.find(service, "decision.prompt ~= true", 1, true)
	local prompt = string.find(service, "promptProduct", 1, true)
	Check.truthy(guard ~= nil and prompt ~= nil and guard < prompt)
	Check.contains(service, "Random.new")
	Check.eq(string.find(service, "MarketplaceService", 1, true), nil)
	Check.eq(string.find(service, "PromptProductPurchase", 1, true), nil)
	local shop = fs.readFile("src/client/ShopPanel.luau")
	Check.contains(shop, "Coming soon.")
	Check.contains(shop, 'entry.plug == "tarot"')
	local session = fs.readFile("src/server/PlayerSession.luau")
	Check.contains(session, 'entry.plug == "tarot"')
	Check.contains(session, "gateStep = 0")
	Check.eq(QaArgs.parse("qa:600:clock+90").clockSeconds, 90)
	Check.eq(QaArgs.parse("qa:600:tarot").tarot, true)
	Check.eq(QaArgs.parse("qa:600:tarot:tarotpaid").tarotPaid, true)
	Check.eq(TarotAccess.enabled(false, false, "qa:600:tarotpaid"), false)
	Check.eq(TarotAccess.enabled(false, true, "qa:600:tarotpaid"), true)
	Check.eq(TarotAccess.enabled(false, true, "qa:600:tarot"), false)
end)
