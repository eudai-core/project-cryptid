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
local ShopPrompts = require("../src/shared/Logic/ShopPrompts")
local Species = require("../src/shared/Config/Species")
local Town = require("../src/shared/Config/Town")
local TownShop = require("../src/shared/Logic/TownShop")
local TownShops = require("../src/shared/Config/TownShops")
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
	Check.eq(ShopAnchors.pathText(pedlar.promptPath), "Districts.PalePedlar.Floor.Pedlar")
	Check.eq(ShopAnchors.pathText(pedlar.fallbackPath), "Hollowmere.PalePedlar.PalePedlarPromptAnchor")
	Check.eq(pedlar.actionText, "Browse")
	Check.eq(pedlar.mode, "pedlar")
	Check.eq(ShopAnchors.get("VeilAndFate").mode, "soon")
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
	local fallback = add(hollow, node("PalePedlar", "Model", nil, quiet))
	add(fallback, node("PalePedlarPromptAnchor", "Part", { ShopId = "PalePedlar" }, quiet))
	local _missing, created = bindNow(full, quiet)
	Check.eq(#quiet, 0)
	Check.eq(#created, 5)
	Check.eq(fallback:FindFirstChild("PalePedlarPromptAnchor"):FindFirstChildWhichIsA("ProximityPrompt"), nil)
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
		local hollow = add(root, node("Hollowmere", "Folder", nil, waits))
		if anchor then
			local model = add(hollow, node("PalePedlar", "Model", nil, waits))
			add(model, node("PalePedlarPromptAnchor", "Part", { ShopId = "PalePedlar" }, waits))
		end
		if prompt then
			local districts = add(root, node("Districts", "Folder", nil, waits))
			local stall = add(districts, node("PalePedlar", "Model", nil, waits))
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

Check.test("every counter validates a cash purchase and keeps it through save and load", function()
	for _, entry in ShopAnchors.list() do
		local profile = purse()
		local earned = profile.totalEarned
		local cryptids = profile.cryptids
		if entry.mode == "soon" then
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
	local early = openGate()
	early.step = Shop.GATE_STEP - 1
	Check.eq(TownShop.buy(profile, "PalePedlar", "reed_cage", "t-step", 1, early).code, "step")
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
	Check.contains(save, "DATA_VERSION = 9")
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
	Check.contains(interactions, "ShopAnchors.PROMPT_KIND")
end)
