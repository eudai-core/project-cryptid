--!strict

_G.LUNE = true

local fs = require("@lune/fs")

local Check = require("./check")
local Economy = require("../src/shared/Config/Economy")
local Names = require("../src/shared/Config/Remotes")
local RateLimit = require("../src/shared/Config/RateLimit")
local Save = require("../src/shared/Config/Save")
local Schema = require("../src/shared/Logic/Schema")
local Shop = require("../src/shared/Config/Shop")
local ShopAnchors = require("../src/shared/Config/ShopAnchors")
local PanelRange = require("../src/shared/Logic/PanelRange")
local ShopNotices = require("../src/shared/Logic/ShopNotices")
local ShopPrompts = require("../src/shared/Logic/ShopPrompts")
local Species = require("../src/shared/Config/Species")
local Town = require("../src/shared/Config/Town")
local TownShop = require("../src/shared/Logic/TownShop")
local TownShops = require("../src/shared/Config/TownShops")
local Transactions = require("../src/shared/Logic/Transactions")
local UITheme = require("../src/shared/UITheme")
local RemoteArgs = require("../src/shared/Logic/RemoteArgs")
local RateLimiter = require("../src/server/RateLimiter")

local function openGate(distance: number?): any
	return {
		opened = true,
		distance = if distance == nil then 0 else distance,
		step = Shop.GATE_STEP,
	}
end

local function purse(): any
	local profile = Schema.newProfile(1_000, "town-shop-starter")
	profile.cash = Economy.PAD_COST[8]
	profile.onboarding.step = Shop.GATE_STEP
	return profile
end

local function purchasable(shopId: string): any
	for _, item in TownShops.items(shopId) do
		if item.kind == "supply" or item.kind == "tool" then
			return item
		end
	end
	return nil
end

local function node(name: string, className: string, attributes: { [string]: any }?, waits: { any }?)
	local self = {
		Name = name,
		ClassName = className,
		attributes = attributes or {},
		children = {},
		Parent = nil,
	}
	function self:FindFirstChild(childName: string)
		for _, child in self.children do
			if child.Name == childName then
				return child
			end
		end
		return nil
	end
	function self:WaitForChild(childName: string, timeout: number)
		if waits ~= nil then
			table.insert(waits, { parent = self.Name, name = childName, timeout = timeout })
		end
		return self:FindFirstChild(childName)
	end
	function self:GetAttribute(key: string)
		return self.attributes[key]
	end
	function self:FindFirstChildWhichIsA(class: string)
		for _, child in self.children do
			if child.ClassName == class then
				return child
			end
		end
		return nil
	end
	function self:IsA(class: string)
		return self.ClassName == class
	end
	function self:GetDescendants()
		local out = {}
		local function walkNodes(current: any)
			for _, child in current.children do
				table.insert(out, child)
				walkNodes(child)
			end
		end
		walkNodes(self)
		return out
	end
	return self
end

local function add(parent: any, child: any)
	table.insert(parent.children, child)
	child.Parent = parent
	return child
end

local function countClass(root: any, className: string): number
	local total = 0
	local function walk(current: any)
		if current.ClassName == className then
			total += 1
		end
		for _, child in current.children do
			walk(child)
		end
	end
	walk(root)
	return total
end

local function bindNow(town: any, waits: { any }?): (any, { any })
	local missing = {}
	local created = {}
	ShopPrompts.bind(town, {
		waitSeconds = ShopAnchors.WAIT_SECONDS,
		spawn = function(fn)
			fn()
		end,
		onMissing = function(shopId: string, path: string)
			table.insert(missing, { shopId = shopId, path = path })
		end,
		onReady = function() end,
		createPrompt = function(anchor: any, entry: any)
			local prompt = node(entry.promptKind, "ProximityPrompt", {
				ShopId = entry.shopId,
				Kind = entry.promptKind,
			}, waits)
			prompt.actionText = entry.actionText
			prompt.objectText = entry.displayName
			add(anchor, prompt)
			table.insert(created, prompt)
		end,
	})
	return missing, created
end

Check.test("anchor paths match the kit contract", function()
	local expected = {
		HowlingHorn = "Hollowmere.HowlingHorn.HowlingHornPromptAnchor",
		RuneheartApothecary = "Hollowmere.RuneheartApothecary.RuneheartApothecaryPromptAnchor",
		VeilAndFate = "Hollowmere.VeilAndFate.VeilAndFatePromptAnchor",
		DuskAndDial = "Hollowmere.DuskAndDial.DuskAndDialPromptAnchor",
		Lanternwright = "Hollowmere.Lanternwright.LanternwrightPromptAnchor",
	}
	for shopId, path in expected do
		local entry = ShopAnchors.get(shopId)
		Check.eq(ShopAnchors.pathText(entry.anchorPath), path, shopId)
		Check.eq(entry.actionText, "Enter", shopId)
	end
	local pedlar = ShopAnchors.get(ShopAnchors.PEDLAR_ID)
	Check.eq(ShopAnchors.pathText(pedlar.modelPath), "Districts.PalePedlar")
	Check.eq(ShopAnchors.pathText(pedlar.fallbackPath), "Districts.PalePedlar.PalePedlarPromptAnchor")
	Check.eq(pedlar.actionText, "Browse")
	Check.eq(pedlar.mode, "pedlar")
	Check.eq(ShopAnchors.get("VeilAndFate").mode, "tarot")
	Check.eq(ShopAnchors.get("VeilAndFate").plug, "tarot")
	Check.eq(ShopAnchors.get("WeepingWell"), nil)
	Check.eq(ShopAnchors.get("WhisperingWoods"), nil)
	Check.eq(ShopAnchors.get("SunkenMarsh"), nil)
	Check.eq(ShopAnchors.get("BoneQuarry"), nil)
end)

Check.test("a mock town containing both a DoorAnchor and a PromptAnchor yields exactly one prompt", function()
	local waits = {}
	local town = node("Town", "Folder", nil, waits)
	local hollow = add(town, node("Hollowmere", "Folder", nil, waits))
	local horn = add(hollow, node("HowlingHorn", "Folder", nil, waits))
	add(horn, node("DoorAnchor", "Part", { TownAnchor = "Door", ShopId = "HowlingHorn" }, waits))
	add(horn, node("HowlingHornPromptAnchor", "Part", { ShopId = "HowlingHorn" }, waits))
	local missing, created = bindNow(town, waits)
	Check.eq(countClass(town, "ProximityPrompt"), 1)
	Check.eq(#created, 1)
	Check.eq(created[1].Parent.Name, "HowlingHornPromptAnchor")
	Check.eq(created[1].actionText, "Enter")
	Check.eq(created[1].objectText, "The Howling Horn")
	Check.eq(horn:FindFirstChild("DoorAnchor"):FindFirstChildWhichIsA("ProximityPrompt"), nil)
	local doorListed = false
	for _, row in missing do
		if string.find(row.path, "DoorAnchor", 1, true) ~= nil then
			doorListed = true
		end
	end
	Check.eq(doorListed, false)
	local prompts = fs.readFile("src/shared/Logic/ShopPrompts.luau")
	local service = fs.readFile("src/server/TownShopService.luau")
	Check.eq(string.find(prompts, "DoorAnchor", 1, true), nil)
	Check.eq(string.find(prompts, "TownAnchor", 1, true), nil)
	Check.eq(string.find(service, "DoorAnchor", 1, true), nil)
	Check.eq(string.find(service, "TownAnchor", 1, true), nil)
end)

Check.test("present anchors bind without waiting and a missing anchor is listed", function()
	local quiet = {}
	local full = node("Town", "Folder", nil, quiet)
	local hollow = add(full, node("Hollowmere", "Folder", nil, quiet))
	for _, entry in ShopAnchors.list() do
		if entry.anchorPath ~= nil then
			local model = add(hollow, node(entry.shopId, "Model", nil, quiet))
			add(model, node(entry.shopId .. "PromptAnchor", "Part", { ShopId = entry.shopId }, quiet))
		end
	end
	local districts = add(full, node("Districts", "Folder", nil, quiet))
	local stall = add(districts, node("PalePedlar", "Model", nil, quiet))
	local floor = add(stall, node("Floor", "Part", nil, quiet))
	add(floor, node("Pedlar", "ProximityPrompt", { Kind = "Pedlar" }, quiet))
	local fallback = add(stall, node("PalePedlarPromptAnchor", "Part", { ShopId = "PalePedlar" }, quiet))
	local _missing, created = bindNow(full, quiet)
	Check.eq(#quiet, 0)
	Check.eq(#created, 5)
	Check.eq(fallback:FindFirstChildWhichIsA("ProximityPrompt"), nil)
	Check.eq(countClass(full, "ProximityPrompt"), 6)

	local waits = {}
	local empty = node("Town", "Folder", nil, waits)
	local queued = {}
	local logged = {}
	ShopPrompts.bind(empty, {
		waitSeconds = ShopAnchors.WAIT_SECONDS,
		spawn = function(fn)
			table.insert(queued, fn)
		end,
		onMissing = function(shopId: string, path: string)
			table.insert(logged, { shopId = shopId, path = path })
		end,
		createPrompt = function()
			error("missing town must not create a prompt", 0)
		end,
	})
	Check.eq(#queued, #ShopAnchors.list())
	Check.eq(#logged, 0)
	for _, fn in queued do
		fn()
	end
	Check.eq(#logged, #ShopAnchors.list())
	local sawLantern = false
	local sawTimeout = false
	for _, row in logged do
		if row.shopId == "Lanternwright" then
			sawLantern = true
			Check.eq(row.path, "Hollowmere.Lanternwright.LanternwrightPromptAnchor")
		end
	end
	for _, call in waits do
		if call.timeout == ShopAnchors.WAIT_SECONDS then
			sawTimeout = true
		end
	end
	Check.eq(sawLantern, true)
	Check.eq(sawTimeout, true)
	Check.eq(countClass(empty, "ProximityPrompt"), 0)
end)

Check.test("the pedlar prompt is kept, and the fallback is used only when it is missing", function()
	local function townWith(prompt: boolean, anchor: boolean)
		local waits = {}
		local root = node("Town", "Folder", nil, waits)
		local districts = add(root, node("Districts", "Folder", nil, waits))
		local stall = add(districts, node("PalePedlar", "Model", nil, waits))
		if anchor then
			add(stall, node("PalePedlarPromptAnchor", "Part", { ShopId = "PalePedlar" }, waits))
		end
		if prompt then
			local host = add(stall, node("Floor", "Part", nil, waits))
			add(host, node(Town.PEDLAR_PROMPT_NAME, "ProximityPrompt", nil, waits))
		end
		return root
	end
	local kept = townWith(true, true)
	local _missing, created = bindNow(kept, nil)
	local pedlarPrompts = 0
	for _, prompt in created do
		if prompt.attributes.ShopId == ShopAnchors.PEDLAR_ID then
			pedlarPrompts += 1
		end
	end
	Check.eq(pedlarPrompts, 0)
	Check.eq(countClass(kept, "ProximityPrompt"), 1)

	local fallback = townWith(false, true)
	local _, made = bindNow(fallback, nil)
	Check.eq(#made, 1)
	Check.eq(made[1].Name, Town.PEDLAR_PROMPT_NAME)
	Check.eq(made[1].actionText, "Browse")
	Check.eq(made[1].objectText, "The Pale Pedlar")
	Check.eq(made[1].Parent.Name, "PalePedlarPromptAnchor")
end)

Check.test("a mismatched shop id does not get a prompt", function()
	local waits = {}
	local town = node("Town", "Folder", nil, waits)
	local hollow = add(town, node("Hollowmere", "Folder", nil, waits))
	local model = add(hollow, node("DuskAndDial", "Model", nil, waits))
	add(model, node("DuskAndDialPromptAnchor", "Part", { ShopId = "HowlingHorn" }, waits))
	local missing, created = bindNow(town, waits)
	Check.eq(#created, 0)
	local found = false
	for _, row in missing do
		if row.shopId == "DuskAndDial" then
			found = true
		end
	end
	Check.eq(found, true)
end)

Check.test("a step-0 profile can buy at each town shop", function()
	for _, entry in ShopAnchors.list() do
		local profile = purse()
		profile.onboarding.step = 0
		local gate = openGate()
		gate.step = 0
		if ShopAnchors.sells(entry) then
			local item = purchasable(entry.shopId)
			local result = TownShop.buy(profile, entry.shopId, item.id, "step0-" .. entry.shopId, 1, gate)
			Check.eq(result.code, "ok", entry.shopId)
			Check.eq(profile.onboarding.step, 0, entry.shopId)
		else
			local result = TownShop.buy(profile, entry.shopId, "reed_cage", "step0-soon", 1, gate)
			Check.eq(result.code, "soon", entry.shopId)
		end
	end
end)

Check.test("every counter validates a cash purchase and keeps it through save and load", function()
	for _, entry in ShopAnchors.list() do
		local profile = purse()
		local earned = profile.totalEarned
		local cryptids = profile.cryptids
		if not ShopAnchors.sells(entry) then
			local refused = TownShop.buy(profile, entry.shopId, "wick_salve", "soon-" .. entry.shopId, 1, openGate())
			Check.eq(refused.code, "soon", entry.shopId)
			Check.eq(profile.cash, Economy.PAD_COST[8], entry.shopId)
			continue
		end
		local item = purchasable(entry.catalogueId)
		Check.truthy(item ~= nil, entry.shopId)
		local broke = purse()
		broke.cash = item.price - 1
		local poor = TownShop.buy(broke, entry.shopId, item.id, "poor-" .. item.id, 1, openGate())
		Check.eq(poor.code, "afford", item.id)
		Check.eq(broke.cash, item.price - 1, item.id)
		local unknown = TownShop.buy(profile, entry.shopId, "not_on_the_counter", "bad-" .. entry.shopId, 1, openGate())
		Check.eq(unknown.code, "item", entry.shopId)
		local gate = openGate()
		gate.price = 1
		gate.cash = 1
		gate.grant = 40
		local before = profile.cash
		local bought = TownShop.buy(profile, entry.shopId, item.id, "buy-" .. item.id, 1, gate)
		Check.eq(bought.code, "ok", item.id)
		Check.eq(bought.price, item.price, item.id)
		Check.eq(profile.cash, before - item.price, item.id)
		Check.eq(profile.wares.counts[item.id], 1, item.id)
		Check.eq(profile.totalEarned, earned, item.id)
		Check.eq(profile.cryptids, cryptids, item.id)
		local replay = TownShop.buy(profile, entry.shopId, item.id, "buy-" .. item.id, 1, openGate())
		Check.eq(replay.code, "replay", item.id)
		Check.eq(profile.cash, before - item.price, item.id)
		Check.eq(profile.wares.counts[item.id], 1, item.id)
		local loaded = Schema.migrate(Schema.deepCopy(profile), 2_000)
		Check.eq(loaded.wares.counts[item.id], 1, item.id)
		Check.eq(loaded.cash, profile.cash, item.id)
		Check.eq(loaded.dataVersion, Save.DATA_VERSION, item.id)
		local again = TownShop.buy(loaded, entry.shopId, item.id, "buy-" .. item.id, 1, openGate())
		Check.eq(again.code, "replay", item.id)
		Check.eq(loaded.cash, profile.cash, item.id)
		Check.eq(loaded.wares.counts[item.id], 1, item.id)
	end
end)

Check.test("bad shop arguments are refused and a client price is not trusted", function()
	local profile = purse()
	Check.eq(TownShop.buy(profile, 4, "reed_cage", "t-shop", 1, openGate()).code, "shop")
	Check.eq(TownShop.buy(profile, "NoSuchStall", "reed_cage", "t-shop-2", 1, openGate()).code, "shop")
	Check.eq(TownShop.buy(profile, "PalePedlar", "", "t-item", 1, openGate()).code, "item")
	Check.eq(TownShop.buy(profile, "PalePedlar", Species.WILD_ID, "t-cryptid", 1, openGate()).code, "item")
	Check.eq(profile.cryptids[Species.WILD_ID] == nil or profile.cryptids[Species.WILD_ID].source ~= "pedlar", true)
	Check.eq(TownShop.buy(profile, "PalePedlar", "reed_cage", "", 1, openGate()).code, "request")
	Check.eq(TownShop.buy(profile, "PalePedlar", "reed_cage", "bad id", 1, openGate()).code, "request")
	Check.eq(TownShop.buy(profile, "PalePedlar", "reed_cage", "t-zero", 0, openGate()).code, "qty")
	Check.eq(TownShop.buy(profile, "PalePedlar", "reed_cage", "t-half", 1.5, openGate()).code, "qty")
	Check.eq(TownShop.buy(profile, "PalePedlar", "reed_cage", "t-neg", -1, openGate()).code, "qty")
	Check.eq(
		TownShop.buy(profile, "PalePedlar", "reed_cage", "t-far", 1, openGate(Town.BUY_DISTANCE + 1)).code,
		"distance"
	)
	local earlyProfile = purse()
	earlyProfile.onboarding.step = 0
	local early = openGate()
	early.step = 0
	Check.eq(TownShop.buy(earlyProfile, "PalePedlar", "reed_cage", "t-step", 1, early).code, "ok")
	local shut = openGate()
	shut.opened = false
	Check.eq(TownShop.buy(profile, "PalePedlar", "reed_cage", "t-shut", 1, shut).code, "open")
	Check.eq(RemoteArgs.shopId(1), nil)
	Check.eq(RemoteArgs.itemId(false), nil)
	Check.eq(RemoteArgs.requestId({}), nil)
	Check.eq(RemoteArgs.shopQty("1"), nil)
	Check.eq(profile.cash, Economy.PAD_COST[8])
end)

Check.test("a supply hits its stack and a tool is owned once", function()
	local profile = purse()
	local cage = TownShops.item("PalePedlar", "reed_cage")
	for index = 1, cage.stack do
		local filled = TownShop.buy(profile, "PalePedlar", cage.id, "stack-" .. tostring(index), 1, openGate())
		Check.eq(filled.code, "ok", tostring(index))
	end
	local cash = profile.cash
	local over = TownShop.buy(profile, "PalePedlar", cage.id, "stack-over", 1, openGate())
	Check.eq(over.code, "stack")
	Check.eq(profile.cash, cash)
	Check.eq(profile.wares.counts[cage.id], cage.stack)

	local tool = TownShops.item("Lanternwright", "spirit_compass")
	local first = TownShop.buy(profile, "Lanternwright", tool.id, "tool-1", 1, openGate())
	Check.eq(first.code, "ok")
	local after = profile.cash
	local second = TownShop.buy(profile, "Lanternwright", tool.id, "tool-2", 1, openGate())
	Check.eq(second.code, "owned")
	Check.eq(profile.cash, after)
	Check.eq(profile.wares.counts[tool.id], 1)
	Check.eq(TownShop.buy(profile, "Lanternwright", tool.id, "tool-qty", 2, openGate()).code, "qty")
	Check.eq(profile.wares.counts[tool.id], 1)
end)

Check.test("selling supplies refunds the economy fraction and refuses the rest", function()
	local profile = purse()
	local cage = TownShops.item("PalePedlar", "reed_cage")
	local earned = profile.totalEarned
	local none = TownShop.sell(profile, "PalePedlar", cage.id, "sell-none", 1, openGate())
	Check.eq(none.code, "notowned")
	Check.eq(profile.cash, Economy.PAD_COST[8])
	local bought = TownShop.buy(profile, "PalePedlar", cage.id, "sell-buy", 1, openGate())
	Check.eq(bought.code, "ok")
	local held = profile.cash
	local tooMany = TownShop.sell(profile, "PalePedlar", cage.id, "sell-over", 2, openGate())
	Check.eq(tooMany.code, "oversell")
	Check.eq(profile.cash, held)
	Check.eq(profile.wares.counts[cage.id], 1)
	local gate = openGate()
	gate.refund = Economy.PAD_COST[8]
	local sold = TownShop.sell(profile, "PalePedlar", cage.id, "sell-ok", 1, gate)
	local refund = (cage.price * Economy.SELL_REFUND_NUMERATOR) / Economy.SELL_REFUND_DENOMINATOR
	Check.eq(sold.code, "ok")
	Check.eq(sold.cashDelta, refund)
	Check.eq(profile.cash, held + refund)
	Check.eq(profile.wares.counts[cage.id], nil)
	Check.eq(profile.totalEarned, earned)
	local replay = TownShop.sell(profile, "PalePedlar", cage.id, "sell-ok", 1, openGate())
	Check.eq(replay.code, "replay")
	Check.eq(profile.cash, held + refund)

	local tool = TownShops.item("Lanternwright", "binding_chains")
	local got = TownShop.buy(profile, "Lanternwright", tool.id, "tool-buy", 1, openGate())
	Check.eq(got.code, "ok")
	local kept = profile.cash
	local refused = TownShop.sell(profile, "Lanternwright", tool.id, "tool-sell", 1, openGate())
	Check.eq(refused.code, "permanent")
	Check.eq(profile.cash, kept)
	Check.eq(profile.wares.counts[tool.id], 1)
	local loaded = Schema.migrate(Schema.deepCopy(profile), 3_000)
	Check.eq(loaded.wares.counts[tool.id], 1)
	Check.eq(loaded.cash, kept)
	local again = TownShop.sell(loaded, "Lanternwright", tool.id, "tool-sell-again", 1, openGate())
	Check.eq(again.code, "permanent")
	Check.eq(loaded.wares.counts[tool.id], 1)
	Check.eq(loaded.cash, kept)
end)

Check.test("later lanterns and cryptids are not for sale, and wares migrate without a version bump", function()
	local profile = purse()
	local before = profile.cash
	local later = TownShop.buy(profile, "Lanternwright", "ember_lantern", "later-1", 1, openGate())
	Check.eq(later.code, "later")
	Check.eq(profile.cash, before)
	Check.eq(profile.wares.counts.ember_lantern, nil)
	Check.eq(TownShops.anyItem("uv_lamp"), nil)
	Check.eq(TownShop.buy(profile, "Lanternwright", "uv_lamp", "uv-1", 1, openGate()).code, "item")
	Check.eq(TownShops.item("PalePedlar", "witness_cage").price, TownShops.WITNESS_CAGE_CASH)
	for _, entry in ShopAnchors.list() do
		for _, item in TownShops.items(entry.catalogueId) do
			Check.eq(type(item.effect), "string", item.id)
			Check.eq(item.effect ~= "", true, item.id)
			Check.eq(item.productId, nil, item.id)
			Check.eq(item.kind == "supply" or item.kind == "tool" or item.kind == "later", true, item.id)
			if item.kind ~= "later" then
				Check.eq(type(item.price), "number", item.id)
				Check.eq(item.price > 0, true, item.id)
			end
		end
	end
	local raw = Schema.deepCopy(purse())
	raw.wares = nil
	local loaded = Schema.migrate(raw, 4_000)
	Check.eq(loaded.dataVersion, Save.DATA_VERSION)
	Check.eq(next(loaded.wares.counts), nil)
	raw.wares = { counts = { reed_cage = 2, not_a_real_item = 3 } }
	local kept = Schema.migrate(Schema.deepCopy(raw), 4_000)
	Check.eq(kept.wares.counts.reed_cage, 2)
	Check.eq(kept.wares.counts.not_a_real_item, nil)
	raw.wares = { counts = { reed_cage = -1 } }
	Check.eq(Schema.migrate(raw, 4_000), nil)
	local save = fs.readFile("src/shared/Config/Save.luau")
	Check.contains(save, "DATA_VERSION = 10")
	local v9 = Schema.deepCopy(purse())
	v9.dataVersion = 9
	v9.wares = nil
	v9.cash = 80
	local fromV9 = Schema.migrate(v9, 5_000)
	Check.eq(fromV9.dataVersion, 10)
	Check.eq(fromV9.cash, 80)
	Check.eq(fromV9.rebirths, 0)
	Check.eq(next(fromV9.wares.counts), nil)
	local v10 = Schema.deepCopy(purse())
	v10.wares = nil
	v10.cash = 44
	v10.rebirths = 2
	v10.familiarId = "fam_1"
	v10.everHeld1M = true
	v10.cryptids["kept"] = {
		speciesId = "hodag",
		mutation = "",
		traits = {},
		acquiredAt = 1,
		source = "pedlar",
	}
	local keptLedger = Schema.migrate(v10, 5_000)
	Check.eq(keptLedger.dataVersion, 10)
	Check.eq(keptLedger.cash, 44)
	Check.eq(keptLedger.rebirths, 2)
	Check.eq(keptLedger.familiarId, "fam_1")
	Check.eq(keptLedger.everHeld1M, true)
	Check.eq(keptLedger.cryptids["kept"].speciesId, "hodag")
	Check.eq(next(keptLedger.wares.counts), nil)
	local catalogue = fs.readFile("src/shared/Config/TownShops.luau")
	Check.contains(catalogue, "-- PLACEHOLDER: pending design")
	Check.eq(string.find(catalogue, "Robux", 1, true), nil)
	Check.eq(string.find(catalogue, "ProductId", 1, true), nil)
	Check.eq(string.find(catalogue, "uv_lamp", 1, true), nil)
end)

Check.test("shop remotes are server checked and the placeholder panel shows each effect", function()
	RateLimiter.reset()
	local capacity = RateLimit.capacity(Names.SHOP_BUY)
	for _ = 1, capacity do
		Check.eq(RateLimiter.consume(3, Names.SHOP_BUY, 0).allowed, true)
	end
	Check.eq(RateLimiter.consume(3, Names.SHOP_BUY, 0).allowed, false)
	Check.eq(RateLimit.perSecond(Names.SHOP_SELL), RateLimit.DEFAULT_PER_SECOND)
	local session = fs.readFile("src/server/PlayerSession.luau")
	Check.contains(session, "listen(Names.SHOP_BUY, onShopBuy)")
	Check.contains(session, "listen(Names.SHOP_SELL, onShopSell)")
	Check.contains(session, "markShopOpen(session, ShopAnchors.PEDLAR_ID)")
	Check.contains(session, "RemoteArgs.shopId")
	Check.contains(session, "allowPurchase")
	Check.eq(string.find(session, "OnServerEvent", 1, true), nil)
	local panel = fs.readFile("src/client/ShopPanel.luau")
	Check.contains(panel, "UITheme.shape.touchPx")
	Check.contains(panel, "effectLabel.Text = item.effect")
	Check.contains(panel, '"Buy"')
	Check.contains(panel, '"Sell"')
	Check.contains(panel, '"Close"')
	Check.contains(panel, "Coming soon.")
	Check.contains(panel, "Coming later.")
	Check.contains(panel, "names.SHOP_BUY")
	Check.contains(panel, "names.SHOP_SELL")
	Check.contains(panel, "Shop.OPEN_TOKEN")
	Check.contains(panel, 'accent(root, "Void", "teal")')
	Check.contains(panel, 'accent(card, "Ash", "violet")')
	Check.contains(panel, "UITheme.color(fillToken)")
	Check.contains(panel, 'UITheme.color("BoneDim")')
	Check.eq(string.find(panel, "Color3.from", 1, true), nil)
	Check.eq(string.find(panel, "names.PEDLAR_BUY", 1, true), nil)
	Check.eq(UITheme.glow.teal, "3C7F78")
	Check.eq(UITheme.glow.violet, "6E5C9A")
	local main = fs.readFile("src/client/Main.client.luau")
	Check.eq(string.find(main, "PedlarShop", 1, true), nil)
	Check.eq(string.find(panel, "profile.cash", 1, true), nil)
	local service = fs.readFile("src/server/TownShopService.luau")
	Check.contains(service, "Enum.KeyCode.E")
	Check.contains(service, "Enum.KeyCode.ButtonX")
	Check.contains(service, "HoldDuration = 0")
	Check.contains(service, "RequiresLineOfSight = false")
	Check.contains(service, "ClickablePrompt = true")
	Check.contains(service, "Town.PROMPT_DISTANCE")
	Check.contains(service, "prompt.ActionText = entry.actionText")
	Check.contains(service, "prompt.ObjectText = entry.displayName")
	Check.contains(service, "task.spawn")
	local interactions = fs.readFile("src/client/Interactions.luau")
	Check.contains(interactions, 'kindName == "SkillShrine"')
	Check.eq(string.find(interactions, "ShopAnchors", 1, true), nil)
	Check.eq(string.find(interactions, '"Pedlar"', 1, true), nil)
	Check.eq(string.find(session, "Shop.GATE_STEP", 1, true), nil)
	Check.eq(string.find(session, "PEDLAR_HOST", 1, true), nil)
	local anchors = fs.readFile("src/shared/Config/ShopAnchors.luau")
	Check.eq(string.find(anchors, "PEDLAR_HOST", 1, true), nil)
	local browse = fs.readFile("src/shared/Logic/PedlarBrowse.luau")
	Check.eq(string.find(browse, "PEDLAR_HOST", 1, true), nil)
	local pedlar = fs.readFile("src/server/Pedlar.luau")
	Check.eq(string.find(pedlar, "PedlarBoard", 1, true), nil)
	Check.eq(string.find(pedlar, "ShopRoll", 1, true), nil)
	Check.eq(string.find(pedlar, "StockLight", 1, true), nil)
	Check.eq(string.find(pedlar, "StockGlow", 1, true), nil)
	Check.contains(pedlar, "PromptTriggered")
	Check.contains(session, "Shop.CRYPTID_REFUSAL")
	Check.contains(session, "SetAttribute(Shop.OPEN_TOKEN, session.pedlarOpenToken)")
end)

Check.test("the pedlar refuses a cryptid sale and still sells supplies", function()
	local profile = purse()
	profile.cryptids["kept-cage"] = {
		speciesId = "hodag",
		mutation = "",
		traits = {},
		acquiredAt = 20,
		source = "pedlar",
	}
	profile.shop.lastRotationId = 9
	profile.shop.boughtSlots[2] = true
	local cash = profile.cash
	local refused, reason =
		Transactions.buyPedlar(profile, 9, 2, { [2] = { speciesId = "hodag" } }, 0, 30, "new-cryptid")
	Check.eq(refused, false)
	Check.eq(reason, "cryptids")
	Check.eq(profile.cash, cash)
	Check.eq(profile.cryptids["new-cryptid"], nil)
	Check.eq(profile.cryptids["kept-cage"].speciesId, "hodag")
	Check.eq(profile.shop.lastRotationId, 9)
	Check.eq(profile.shop.boughtSlots[2], true)
	local loaded = Schema.migrate(Schema.deepCopy(profile), 4_000)
	Check.eq(loaded.cryptids["kept-cage"].source, "pedlar")
	Check.eq(loaded.shop.lastRotationId, 9)
	Check.eq(loaded.shop.boughtSlots[2], true)
	for _, id in { "witness_cage", "keepers_rim", "veil_mantle", "reed_cage", "iron_cage" } do
		local item = TownShops.item("PalePedlar", id)
		Check.truthy(item, id)
		local result = TownShop.buy(loaded, "PalePedlar", id, "supply-" .. id, 1, openGate())
		Check.eq(result.code, "ok", id)
		Check.eq(loaded.wares.counts[id], 1, id)
	end
	Check.eq(loaded.cryptids["kept-cage"].speciesId, "hodag")
	Check.eq(loaded.cash < cash, true)
	local session = fs.readFile("src/server/PlayerSession.luau")
	Check.contains(session, "grantPedlarOpen")
	Check.contains(session, "Shop.OPEN_TOKEN")
end)

Check.test("an open panel closes past the prompt plus hysteresis", function()
	Check.eq(Town.PROMPT_DISTANCE, 10)
	Check.eq(Town.PANEL_HYSTERESIS > 0, true)
	Check.eq(Town.PANEL_POLL_SECONDS > 0, true)
	local limit = PanelRange.limit(Town.PROMPT_DISTANCE, Town.PANEL_HYSTERESIS)
	Check.eq(limit, Town.PROMPT_DISTANCE + Town.PANEL_HYSTERESIS)
	Check.eq(PanelRange.outOfRange(limit, limit), false)
	Check.eq(PanelRange.outOfRange(Town.PROMPT_DISTANCE, limit), false)
	Check.eq(PanelRange.outOfRange(limit + 0.01, limit), true)
	Check.eq(PanelRange.outOfRange(nil, limit), false)
	Check.eq(PanelRange.due(0, 0, Town.PANEL_POLL_SECONDS), false)
	Check.eq(PanelRange.due(Town.PANEL_POLL_SECONDS, 0, Town.PANEL_POLL_SECONDS), true)
	Check.eq(TownShops.NOTICES.distance, "Step closer.")
	local panel = fs.readFile("src/client/ShopPanel.luau")
	Check.contains(panel, "RunService.Heartbeat:Connect(watchRange)")
	Check.contains(panel, "MaxActivationDistance")
	Check.contains(panel, "Town.PANEL_HYSTERESIS")
	Check.contains(panel, "Town.PROMPT_DISTANCE")
	Check.contains(panel, "rangeConn:Disconnect()")
	Check.contains(panel, "CharacterAdded")
	Check.contains(panel, "CharacterRemoving")
	Check.contains(panel, "humanoid.Died")
	local service = fs.readFile("src/server/TownShopService.luau")
	Check.contains(service, "prompt.MaxActivationDistance = Town.PROMPT_DISTANCE")
	Check.eq(string.find(service, "PANEL_HYSTERESIS", 1, true), nil)
end)

Check.test("a pedlar notice does not land on another stall", function()
	Check.eq(Shop.CRYPTID_REFUSAL, "The Pale Pedlar sells supplies. Cryptids are not for sale.")
	Check.eq(ShopNotices.channel(ShopAnchors.get(ShopAnchors.PEDLAR_ID)), "pedlar")
	Check.eq(ShopNotices.channel(ShopAnchors.get("HowlingHorn")), "shop")
	Check.eq(ShopNotices.channel(ShopAnchors.get("RuneheartApothecary")), "shop")
	Check.eq(ShopNotices.channel(ShopAnchors.get("DuskAndDial")), "shop")
	Check.eq(ShopNotices.channel(ShopAnchors.get("Lanternwright")), "shop")
	Check.eq(ShopNotices.channel(ShopAnchors.get("VeilAndFate")), "tarot")
	Check.eq(ShopNotices.accept("HowlingHorn", ShopAnchors.PEDLAR_ID), false)
	Check.eq(ShopNotices.accept(ShopAnchors.PEDLAR_ID, ShopAnchors.PEDLAR_ID), true)
	Check.eq(ShopNotices.accept("HowlingHorn", "RuneheartApothecary"), false)
	Check.eq(ShopNotices.accept("HowlingHorn", "HowlingHorn"), true)
	Check.eq(ShopNotices.accept("VeilAndFate", "HowlingHorn"), false)
	Check.eq(ShopNotices.accept("VeilAndFate", "VeilAndFate"), true)
	Check.eq(ShopNotices.onOpen("HowlingHorn"), "")
	Check.eq(ShopNotices.onOpen(ShopAnchors.PEDLAR_ID), "")
	Check.eq(ShopNotices.onOpen("VeilAndFate"), "")
	local panel = fs.readFile("src/client/ShopPanel.luau")
	Check.contains(panel, 'noticeLabel("PedlarNotice")')
	Check.contains(panel, 'noticeLabel("ShopNotice")')
	Check.contains(panel, 'noticeLabel("TarotNotice")')
	Check.contains(panel, "ShopNotices.onOpen(shopId)")
	Check.contains(panel, "ShopNotices.accept(shownId, ShopAnchors.PEDLAR_ID)")
	Check.contains(panel, "ShopNotices.accept(shownId, noticeShop)")
	local session = fs.readFile("src/server/PlayerSession.luau")
	Check.contains(session, "ShopAnchors.NOTICE_SHOP")
	Check.contains(session, "noteShop(session, parsedShop, result.message)")
	Check.contains(session, "noteShop(session, TarotCases.SHOP_ID, result.message)")
	Check.contains(session, "noteShop(session, TarotCases.SHOP_ID, decision.message)")
	Check.contains(session, "notePedlar(session, Shop.CRYPTID_REFUSAL)")
end)
