--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
end)
local Shop = import("../Config/Shop", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Shop")
end)
local ShopAnchors = import("../Config/ShopAnchors", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("ShopAnchors")
end)
local Town = import("../Config/Town", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Town")
end)
local TownShops = import("../Config/TownShops", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("TownShops")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local RemoteArgs = import("./RemoteArgs", function()
	return script.Parent:WaitForChild("RemoteArgs")
end)

local TownShop = {}

function TownShop.fresh(): any
	return {
		counts = {},
		receipts = {},
	}
end

local function blank(code: string, extra: any): any
	local message = TownShops.NOTICES[code]
	return {
		code = code,
		message = message,
		itemId = extra.itemId,
		qty = extra.qty,
		price = extra.price,
		cashDelta = extra.cashDelta or 0,
		count = extra.count,
	}
end

local function settled(kind: string, item: any, qty: number, cashDelta: number, count: number): any
	local template = if kind == "sell" then TownShops.NOTICES.okSell else TownShops.NOTICES.okBuy
	return {
		code = "ok",
		message = string.format(template, item.name),
		itemId = item.id,
		qty = qty,
		price = item.price,
		cashDelta = cashDelta,
		count = count,
	}
end

function TownShop.savedFrom(raw: any): (any?, boolean)
	if raw == nil then
		return TownShop.fresh(), true
	end
	if type(raw) ~= "table" then
		return nil, false
	end
	local rawCounts = raw.counts
	if rawCounts == nil then
		rawCounts = {}
	end
	if type(rawCounts) ~= "table" then
		return nil, false
	end
	local counts = {}
	for key, value in rawCounts do
		if type(key) ~= "string" then
			return nil, false
		end
		local item = TownShops.anyItem(key)
		if item ~= nil then
			if type(value) ~= "number" or value ~= math.floor(value) or value < 0 or value > item.stack then
				return nil, false
			end
			if value > 0 then
				counts[key] = value
			end
		end
	end
	local rawReceipts = raw.receipts
	if rawReceipts == nil then
		rawReceipts = {}
	end
	if type(rawReceipts) ~= "table" then
		return nil, false
	end
	local receipts = {}
	local seen: { [string]: boolean } = {}
	local startIndex = 1
	if #rawReceipts > TownShops.RECEIPT_CAP then
		startIndex = #rawReceipts - TownShops.RECEIPT_CAP + 1
	end
	for index = startIndex, #rawReceipts do
		local entry = rawReceipts[index]
		if type(entry) == "table" then
			local id = entry.id
			local delta = entry.cashDelta
			local itemId = entry.itemId
			local qty = entry.qty
			if
				type(id) == "string"
				and RemoteArgs.requestId(id) ~= nil
				and seen[id] ~= true
				and Money.isFinite(delta)
				and type(itemId) == "string"
				and type(qty) == "number"
				and qty == math.floor(qty)
				and qty >= 1
				and qty <= TownShops.MAX_QTY
			then
				seen[id] = true
				table.insert(receipts, {
					id = id,
					cashDelta = delta,
					itemId = itemId,
					qty = qty,
				})
			end
		end
	end
	return {
		counts = counts,
		receipts = receipts,
	}, true
end

local function ensure(profile: any): boolean
	if type(profile) ~= "table" then
		return false
	end
	if profile.wares == nil then
		profile.wares = TownShop.fresh()
	end
	local wares = profile.wares
	if type(wares) ~= "table" or type(wares.counts) ~= "table" or type(wares.receipts) ~= "table" then
		return false
	end
	return true
end

local function findReceipt(profile: any, requestId: string): any
	local receipts = profile.wares.receipts
	for index = #receipts, 1, -1 do
		local entry = receipts[index]
		if type(entry) == "table" and entry.id == requestId then
			return entry
		end
	end
	return nil
end

local function remember(profile: any, requestId: string, itemId: string, qty: number, cashDelta: number)
	local receipts = profile.wares.receipts
	table.insert(receipts, {
		id = requestId,
		itemId = itemId,
		qty = qty,
		cashDelta = cashDelta,
	})
	while #receipts > TownShops.RECEIPT_CAP do
		table.remove(receipts, 1)
	end
end

local function owned(profile: any, itemId: string): number
	local value = profile.wares.counts[itemId]
	if type(value) ~= "number" then
		return 0
	end
	return value
end

-- Only the open flag, the measured distance, and the onboarding step are read.
-- A price, a cash figure, or a grant stuffed into the same table is ignored.
local function readGate(gate: any): any
	if type(gate) ~= "table" then
		return {
			opened = false,
			distance = nil,
			step = nil,
		}
	end
	return {
		opened = gate.opened == true,
		distance = gate.distance,
		step = gate.step,
	}
end

local function gateCode(gate: any): string?
	if gate.opened ~= true then
		return "open"
	end
	if type(gate.step) ~= "number" or gate.step < Shop.GATE_STEP then
		return "step"
	end
	if RemoteArgs.withinDistance(gate.distance, Town.BUY_DISTANCE) ~= true then
		return "distance"
	end
	return nil
end

local function prepare(profile: any, shopId: any, requestId: any, qty: any, gate: any): (any?, string?, number?)
	if RemoteArgs.requestId(requestId) == nil then
		return nil, "request", nil
	end
	if not ensure(profile) then
		return nil, "shop", nil
	end
	local prior = findReceipt(profile, requestId)
	if prior ~= nil then
		return nil, "replay", nil
	end
	local parsedQty = RemoteArgs.shopQty(qty)
	if parsedQty == nil then
		return nil, "qty", nil
	end
	local blocked = gateCode(readGate(gate))
	if blocked ~= nil then
		return nil, blocked, parsedQty
	end
	local entry = ShopAnchors.get(shopId)
	if entry == nil then
		return nil, "shop", parsedQty
	end
	if not ShopAnchors.sells(entry) then
		return nil, "soon", parsedQty
	end
	return entry, nil, parsedQty
end

local function replay(profile: any, requestId: string): any
	local prior = findReceipt(profile, requestId)
	return {
		code = "replay",
		message = TownShops.NOTICES.replay,
		itemId = if prior ~= nil then prior.itemId else nil,
		qty = if prior ~= nil then prior.qty else nil,
		price = nil,
		cashDelta = if prior ~= nil then prior.cashDelta else 0,
		count = nil,
	}
end

function TownShop.buy(profile: any, shopId: any, itemId: any, requestId: any, qty: any, gate: any): any
	if RemoteArgs.requestId(requestId) ~= nil and ensure(profile) and findReceipt(profile, requestId) ~= nil then
		return replay(profile, requestId)
	end
	local entry, problem, parsedQty = prepare(profile, shopId, requestId, qty, gate)
	if problem == "replay" then
		return replay(profile, requestId)
	end
	if problem ~= nil or entry == nil or parsedQty == nil then
		return blank(problem or "shop", {})
	end
	if type(itemId) ~= "string" then
		return blank("item", { qty = parsedQty })
	end
	local item = TownShops.item(entry.catalogueId, itemId)
	if item == nil then
		return blank("item", { qty = parsedQty, itemId = itemId })
	end
	if item.kind == "later" then
		return blank("later", { qty = parsedQty, itemId = item.id, price = item.price })
	end
	if parsedQty > item.stack then
		return blank("qty", { qty = parsedQty, itemId = item.id, price = item.price })
	end
	local have = owned(profile, item.id)
	if have >= item.stack then
		local code = if item.kind == "tool" then "owned" else "stack"
		return blank(code, { qty = parsedQty, itemId = item.id, price = item.price, count = have })
	end
	if have + parsedQty > item.stack then
		return blank("stack", { qty = parsedQty, itemId = item.id, price = item.price, count = have })
	end
	local cost = Money.round(item.price * parsedQty)
	if type(profile.cash) ~= "number" or profile.cash + 1e-9 < cost then
		return blank("afford", { qty = parsedQty, itemId = item.id, price = item.price, count = have })
	end
	local nextCount = have + parsedQty
	profile.cash = Money.round(profile.cash - cost)
	profile.wares.counts[item.id] = nextCount
	remember(profile, requestId, item.id, parsedQty, -cost)
	return settled("buy", item, parsedQty, -cost, nextCount)
end

function TownShop.sell(profile: any, shopId: any, itemId: any, requestId: any, qty: any, gate: any): any
	if RemoteArgs.requestId(requestId) ~= nil and ensure(profile) and findReceipt(profile, requestId) ~= nil then
		return replay(profile, requestId)
	end
	local entry, problem, parsedQty = prepare(profile, shopId, requestId, qty, gate)
	if problem ~= nil or entry == nil or parsedQty == nil then
		return blank(problem or "shop", {})
	end
	if type(itemId) ~= "string" then
		return blank("item", { qty = parsedQty })
	end
	local item = TownShops.item(entry.catalogueId, itemId)
	if item == nil then
		return blank("item", { qty = parsedQty, itemId = itemId })
	end
	if item.kind ~= "supply" then
		return blank(
			"permanent",
			{ qty = parsedQty, itemId = item.id, price = item.price, count = owned(profile, item.id) }
		)
	end
	local have = owned(profile, item.id)
	if have <= 0 then
		return blank("notowned", { qty = parsedQty, itemId = item.id, price = item.price, count = 0 })
	end
	if parsedQty > have then
		return blank("oversell", { qty = parsedQty, itemId = item.id, price = item.price, count = have })
	end
	local refund = Money.round(item.price * parsedQty * Economy.SELL_REFUND_NUMERATOR / Economy.SELL_REFUND_DENOMINATOR)
	local left = have - parsedQty
	profile.cash = Money.round(profile.cash + refund)
	if left <= 0 then
		profile.wares.counts[item.id] = nil
	else
		profile.wares.counts[item.id] = left
	end
	remember(profile, requestId, item.id, parsedQty, refund)
	return settled("sell", item, parsedQty, refund, left)
end

return TownShop
