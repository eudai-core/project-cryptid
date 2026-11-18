--!strict

-- Cash catalogues for the Hollowmere counters. Prices the specs do not name
-- are derived from Economy and marked below. No premium products.

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Economy = import("./Economy", function()
	return script.Parent:WaitForChild("Economy")
end)

local STACK = 8
local TOOL_STACK = 1

-- Flat $400. The N×H cage formula is not on main; this is the stated exception.
local WITNESS_CAGE_CASH = 400

local function supply(id: string, name: string, effect: string, price: number)
	return table.freeze({
		id = id,
		name = name,
		effect = effect,
		price = price,
		stack = STACK,
		kind = "supply",
	})
end

local function tool(id: string, name: string, effect: string, price: number)
	return table.freeze({
		id = id,
		name = name,
		effect = effect,
		price = price,
		stack = TOOL_STACK,
		kind = "tool",
	})
end

local function later(id: string, name: string, effect: string)
	return table.freeze({
		id = id,
		name = name,
		effect = effect,
		price = 0,
		stack = TOOL_STACK,
		kind = "later",
	})
end

-- PLACEHOLDER: pending design. Specs name these Pedlar supplies and not the
-- other prices. Witness Cage stays the flat exception above.
local PEDLAR = table.freeze({
	supply(
		"reed_cage",
		"Reed Cage",
		"Holds one cryptid you already caught. Reed and wax. It does not change catch time or rarity.",
		Economy.PAD_COST[3]
	),
	supply(
		"iron_cage",
		"Iron Cage",
		"Holds one cryptid you already caught. Iron bands. It does not change catch time or rarity.",
		Economy.PAD_COST[5]
	),
	supply(
		"witness_cage",
		"Witness Cage",
		"Holds one cryptid you already caught, in plain sight. The price is a flat sum. It does not change catch time or rarity.",
		WITNESS_CAGE_CASH
	),
	supply(
		"keepers_rim",
		"Keeper's Rim",
		"A rim that marks a cage as tended. It does not change catch time or rarity.",
		Economy.WARD_CANDLES_COST
	),
	supply(
		"veil_mantle",
		"Veil Mantle",
		"A cloth that hides a cage from the road. It does not change catch time or rarity.",
		Economy.PAD_COST[6]
	),
})

-- PLACEHOLDER: pending design. Specs 03 and 15 name the shop and not its stock.
local APOTHECARY = table.freeze({
	supply(
		"wick_salve",
		"Wick Salve",
		"A salve for a cracked wick. It does not change cash, catch time, or rarity.",
		Economy.PAD_COST[3]
	),
	supply(
		"moss_tonic",
		"Moss Tonic",
		"A green tonic from the rune tree. It does not change cash, catch time, or rarity.",
		Economy.PAD_COST[4]
	),
	supply(
		"bone_tea",
		"Bone Tea",
		"A bitter cup from the hollow tree. It does not change cash, catch time, or rarity.",
		Economy.WARD_CANDLES_COST
	),
})

-- PLACEHOLDER: pending design. Specs 03 and 15 name the tavern and not its stock.
local HORN = table.freeze({
	supply(
		"hearth_broth",
		"Hearth Broth",
		"A bowl at the longship fire. It does not change cash, catch time, or rarity.",
		Economy.PAD_COST[3]
	),
	supply(
		"night_loaf",
		"Night Loaf",
		"Bread from the horn's hearth. It does not change cash, catch time, or rarity.",
		Economy.PAD_COST[4]
	),
	supply(
		"horn_cider",
		"Horn Cider",
		"A cup at the longship. It does not change cash, catch time, or rarity.",
		Economy.PAD_COST[5]
	),
})

-- PLACEHOLDER: pending design. Specs 03 and 15 name the clock and not its stock.
local DIAL = table.freeze({
	supply(
		"dial_oil",
		"Dial Oil",
		"Oil for the clock face. There is no countdown, and it does not change rarity.",
		Economy.PAD_COST[3]
	),
	supply(
		"hour_pin",
		"Hour Pin",
		"Marks the hour you choose to read. There is no countdown, and it does not change rarity.",
		Economy.PAD_COST[4]
	),
	supply(
		"dusk_charm",
		"Dusk Charm",
		"A charm of the evening face. There is no countdown, and it does not change rarity.",
		Economy.PAD_COST[5]
	),
})

-- L3–L5 effects are spec 15 §5. Their prices are not. L2 stays coming later:
-- spec 18 is not on main, and the ember lantern ships with the spawner.
-- UV Lamp is omitted until a spec on main allows it.
-- PLACEHOLDER: pending design
local LANTERN = table.freeze({
	later(
		"ember_lantern",
		"Ember Lantern",
		"Green beam. Bind time is 10% shorter. Coming later, with the hunt spawner."
	),
	tool(
		"spirit_compass",
		"Spirit Compass",
		"Blue arrow and a wisp trail to the nearest spawn. The trail is fixed, with no random turn.",
		Economy.PAD_COST[5]
	),
	tool(
		"binding_chains",
		"Binding Chains",
		"Purple chains. Bind range reaches 16 studs, and a steal is harder. The effect is fixed.",
		Economy.PAD_COST[6]
	),
	tool(
		"moonlit_censer",
		"Moonlit Censer",
		"Silver smoke. You can bind two cryptids at once. The effect is fixed.",
		Economy.PAD_COST[7]
	),
})

local BY_SHOP: { [string]: { any } } = {
	PalePedlar = PEDLAR,
	RuneheartApothecary = APOTHECARY,
	HowlingHorn = HORN,
	DuskAndDial = DIAL,
	Lanternwright = LANTERN,
	VeilAndFate = table.freeze({}),
}

local BY_ID: { [string]: any } = {}
for _, items in BY_SHOP do
	for _, item in items do
		BY_ID[item.id] = item
	end
end

local TownShops = {
	STACK = STACK,
	MAX_QTY = STACK,
	RECEIPT_CAP = 24,
	ID_MAX = 32,
	REQUEST_MAX = 64,
	WITNESS_CAGE_CASH = WITNESS_CAGE_CASH,
	NOTICES = table.freeze({
		okBuy = "Bought %s.",
		okSell = "Sold %s.",
		replay = "Already settled.",
		afford = "You need more cash.",
		stack = "You cannot carry more.",
		owned = "You already keep that.",
		item = "That is not on the counter.",
		shop = "That stall is closed.",
		soon = "Coming soon.",
		later = "Coming later.",
		permanent = "That does not sell back.",
		oversell = "You do not have that many.",
		notowned = "You do not own that.",
		open = "The stall is shut.",
		distance = "Step closer.",
		step = "The stall ignores the unmarked.",
	}),
}

function TownShops.items(shopId: string): { any }
	local items = BY_SHOP[shopId]
	if items == nil then
		return {}
	end
	return items
end

function TownShops.item(shopId: string, itemId: string): any
	local items = BY_SHOP[shopId]
	if items == nil or type(itemId) ~= "string" then
		return nil
	end
	for _, item in items do
		if item.id == itemId then
			return item
		end
	end
	return nil
end

function TownShops.anyItem(itemId: string): any
	if type(itemId) ~= "string" then
		return nil
	end
	return BY_ID[itemId]
end

return table.freeze(TownShops)
