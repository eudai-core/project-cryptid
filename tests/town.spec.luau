--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local Check = require("./check")
local Income = require("../src/shared/Logic/Income")
local Lanterns = require("../src/shared/Config/Lanterns")
local PlotRing = require("../src/shared/Logic/PlotRing")
local Plots = require("../src/shared/Config/Plots")
local RemoteArgs = require("../src/shared/Logic/RemoteArgs")
local Save = require("../src/shared/Config/Save")
local Schema = require("../src/shared/Logic/Schema")
local Shop = require("../src/shared/Config/Shop")
local ShopLedger = require("../src/shared/Logic/ShopLedger")
local ShopPools = require("../src/shared/Config/ShopPools")
local ShopRoll = require("../src/server/ShopRoll")
local ShopStock = require("../src/shared/Logic/ShopStock")
local Species = require("../src/shared/Config/Species")
local Town = require("../src/shared/Config/Town")
local TownLayout = require("../src/shared/Logic/TownLayout")
local Transactions = require("../src/shared/Logic/Transactions")
local UITheme = require("../src/shared/UITheme")
local SeededRng = require("../src/server/SeededRng")

local SPEC_ANGLES = { 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5 }
local SPEC_ODDS = {
	{ 100, 0, 0, 0, 0, 0 },
	{ 0, 75, 25, 0, 0, 0 },
	{ 0, 0, 80, 20, 0, 0 },
	{ 0, 0, 70, 30, 0, 0 },
}
local SPEC_PRICE = {
	Common = 180,
	Uncommon = 900,
	Rare = 6750,
	Epic = 64000,
	Legendary = 720000,
	Mythic = 9000000,
}

local function count(text: string, needle: string): number
	local found = 0
	local cursor = 1
	while true do
		local at = string.find(text, needle, cursor, true)
		if at == nil then
			return found
		end
		found += 1
		cursor = at + #needle
	end
end

local function filesUnder(dir: string, into: { string })
	for _, name in fs.readDir(dir) do
		local path = dir .. "/" .. name
		if fs.isDir(path) then
			filesUnder(path, into)
		elseif string.match(name, "%.luau$") ~= nil then
			table.insert(into, path)
		end
	end
end

local function rich(): any
	local profile = Schema.newProfile(1, "starter")
	profile.onboarding.step = Shop.GATE_STEP
	profile.cash = 20000000
	return profile
end

Check.test("QA1 the well is at the origin and roads match the plot angles", function()
	Check.eq(Town.RADIUS, Plots.TOWN_RADIUS)
	Check.eq(TownLayout.townRadius(), 120)
	local well = TownLayout.well()
	Check.near(well.x, 0, 1)
	Check.near(well.y, 0, 1)
	Check.near(well.z, 0, 1)
	Check.eq(Town.WELL_DIAMETER, 10)
	Check.eq(Town.ROAD_WIDTH, 16)
	Check.eq(Plots.COUNT, 8)
	for index = 1, Plots.COUNT do
		local opening = TownLayout.opening(index)
		local edge = PlotRing.townEdge(index)
		Check.eq(opening.angle, (index - 1) * Plots.ANGLE_STEP)
		Check.near(opening.x, edge.x, 1, "opening x " .. tostring(index))
		Check.near(opening.z, edge.z, 1, "opening z " .. tostring(index))
		Check.near(TownLayout.radius(opening), 120, 1)
		local district = TownLayout.district(index)
		Check.near(district.angle, SPEC_ANGLES[index], 0.001, "district angle " .. tostring(index))
		Check.near(TownLayout.radius(district), 75, 1, "district radius " .. tostring(index))
		local front = TownLayout.front(index)
		local inward = TownLayout.radius({
			x = district.x + front.x,
			z = district.z + front.z,
		})
		Check.eq(inward < TownLayout.radius(district), true)
	end
	local arc = 2 * TownLayout.openingHalfAngle() * Plots.TOWN_RADIUS
	Check.near(arc, Town.ROAD_WIDTH, 0.1)
	Check.eq(Town.OUTER_SURFACE, Town.FLOOR_Y)
	Check.eq(Town.FLOOR_Y, 0.4)
	local padHalf = 3
	local wellNear = Town.WELL_OFFSET - Town.WELL_DIAMETER / 2
	Check.eq(wellNear > padHalf, true)
	local candleNear = Town.WELL_OFFSET - Town.WELL_CANDLE_RADIUS
	Check.eq(candleNear > padHalf, true)
end)

Check.test("QA2 only the pedlar and the shrine are live", function()
	local live = 0
	local shuttered = 0
	local reserved = 0
	for _, spec in Town.DISTRICTS do
		if spec.status == "live" then
			live += 1
		elseif spec.status == "shuttered" then
			shuttered += 1
		elseif spec.status == "reserved" then
			reserved += 1
		end
	end
	Check.eq(live, 2)
	Check.eq(shuttered, 4)
	Check.eq(reserved, 2)
	Check.eq(Town.DISTRICTS[1].kind, "pedlar")
	Check.eq(Town.DISTRICTS[1].status, "live")
	Check.eq(Town.DISTRICTS[8].kind, "shrine")
	Check.eq(Town.DISTRICTS[8].status, "live")
	Check.eq(Shop.PROMPT, "Browse the Pedlar's cages")
	Check.eq(Town.SHRINE_PROMPT, "Open the skill tree")
	Check.eq(Town.SHUTTERED, "Shuttered until the next moon")
	Check.eq(Town.PROMPT_DISTANCE, 10)
	local builder = fs.readFile("src/server/TownBuilder.luau")
	Check.eq(count(builder, "plate(floor, Town.PEDLAR_PROMPT_NAME, Shop.PROMPT)"), 1)
	Check.eq(count(builder, 'plate(plinth, "SkillShrine", Town.SHRINE_PROMPT)'), 1)
	Check.contains(builder, "Town.SHUTTERED")
end)

Check.test("QA3 reserved footprints are 24 by 24 and named", function()
	Check.eq(Town.RESERVED_SIZE, 24)
	Check.eq(Town.DISTRICTS[3].footprint, "Reserved_TarotTable")
	Check.eq(Town.DISTRICTS[6].footprint, "Reserved_GreatRift")
	Check.eq(Town.DISTRICTS[3].status, "reserved")
	Check.eq(Town.DISTRICTS[6].status, "reserved")
	local builder = fs.readFile("src/server/TownBuilder.luau")
	Check.contains(builder, "spec.footprint")
	Check.contains(builder, "Town.RESERVED_SIZE")
end)

Check.test("QA4 two generates of one rotation are the same stock", function()
	local left = ShopRoll.generate(424242)
	local right = ShopRoll.generate(424242)
	Check.eq(#left.offers, Shop.SLOT_COUNT)
	for slot = 1, Shop.SLOT_COUNT do
		Check.eq(left.bySlot[slot].speciesId, right.bySlot[slot].speciesId)
		Check.eq(left.bySlot[slot].rolledRarity, right.bySlot[slot].rolledRarity)
		Check.eq(left.bySlot[slot].price, right.bySlot[slot].price)
		Check.eq(left.bySlot[slot].mutation, "")
	end
	local other = ShopRoll.generate(424243)
	local identical = true
	for slot = 1, Shop.SLOT_COUNT do
		if left.bySlot[slot].speciesId ~= other.bySlot[slot].speciesId then
			identical = false
		end
		if left.bySlot[slot].rolledRarity ~= other.bySlot[slot].rolledRarity then
			identical = false
		end
	end
	Check.eq(identical, false)
	local saltFile = fs.readFile("src/server/ShopSalt.luau")
	Check.contains(saltFile, "SALT")
	local shared = {}
	filesUnder("src/shared", shared)
	filesUnder("src/client", shared)
	for _, path in shared do
		local text = fs.readFile(path)
		Check.eq(string.find(text, "9031841", 1, true), nil, path)
		Check.eq(string.find(text, "ShopSalt", 1, true), nil, path)
		Check.eq(string.find(text, "ShopRoll", 1, true), nil, path)
	end
end)

Check.test("QA5 restock follows floor of unix over 300 and the countdown hits 0:00", function()
	Check.eq(Shop.ROTATION_SECONDS, 300)
	Check.eq(ShopStock.rotationId(299), 0)
	Check.eq(ShopStock.rotationId(300), 1)
	Check.eq(ShopStock.rotationId(599), 1)
	Check.eq(ShopStock.rotationId(600), 2)
	Check.eq(ShopStock.secondsRemaining(299), 1)
	Check.eq(ShopStock.secondsRemaining(300), 300)
	Check.eq(ShopStock.nextRestockUnix(300), 600)
	Check.eq(ShopStock.displaySeconds(300, 300), 0)
	Check.eq(ShopStock.displaySeconds(299, 300), 1)
	Check.eq(ShopStock.formatCountdown(0), "0:00")
	Check.eq(ShopStock.formatCountdown(252), "4:12")
	Check.eq(ShopStock.formatCountdown(300), "5:00")
	local before = ShopRoll.generate(ShopStock.rotationId(3299))
	local after = ShopRoll.generate(ShopStock.rotationId(3300))
	Check.eq(ShopStock.rotationId(3299) == ShopStock.rotationId(3300), false)
	Check.eq(before.bySlot[1].slot, 1)
	Check.eq(after.bySlot[4].slot, 4)
end)

Check.test("QA6 a hundred thousand rolls stay inside the published odds", function()
	local counts = {}
	for slot = 1, Shop.SLOT_COUNT do
		counts[slot] = {}
		for _, rarity in Shop.RARITY_ORDER do
			counts[slot][rarity] = 0
		end
	end
	local warnings = 0
	for rotationId = 1, 100000 do
		local rolled = ShopRoll.generate(rotationId)
		warnings += #rolled.warnings
		for _, offer in rolled.offers do
			counts[offer.slot][offer.rolledRarity] += 1
		end
	end
	Check.eq(warnings, 0)
	for slot, expected in SPEC_ODDS do
		for index, rarity in Shop.RARITY_ORDER do
			local rate = counts[slot][rarity] / 1000
			local tolerance = if rarity == "Mythic" then 0.1 else 0.5
			Check.near(rate, expected[index], tolerance, "slot " .. tostring(slot) .. " " .. rarity)
		end
	end
end)

Check.test("QA7 every offer is priced at that species income times rarity payback", function()
	Check.eq(ShopStock.priceFor("mothman_hatchling"), 60)
	Check.eq(ShopStock.priceFor("fresno_nightcrawler"), 90)
	Check.eq(ShopStock.priceFor("hidebehind"), 120)
	Check.eq(ShopStock.priceFor("hodag"), 150)
	for rarity, price in SPEC_PRICE do
		local row = Shop.RARITIES[rarity]
		Check.eq(ShopStock.rarityPrice(rarity), price, rarity)
		Check.eq(row.baseIncome * row.paybackSeconds, price)
		if rarity ~= "Common" then
			for _, id in ShopPools[rarity] do
				Check.eq(ShopStock.priceFor(id), price, id)
			end
		end
	end
	for rotationId = 1, 40 do
		local rolled = ShopRoll.generate(rotationId)
		for _, offer in rolled.offers do
			local species = Species.get(offer.speciesId)
			Check.truthy(species)
			Check.eq(offer.price, ShopStock.priceFor(offer.speciesId), offer.speciesId)
			Check.eq(offer.price, species.baseIncome * Shop.RARITIES[species.rarity].paybackSeconds)
			Check.eq(offer.mutation, "")
			Check.eq(species.rarity, offer.rarity)
		end
	end
	Check.eq(Income.contribution("mothman_hatchling", 0), 2)
end)

Check.test("QA8 a slot can be bought once per rotation", function()
	local profile = rich()
	local stock = ShopRoll.generate(15)
	local price = stock.bySlot[1].price
	local before = profile.cash
	local ok, reason = Transactions.buyPedlar(profile, 15, 1, stock.bySlot, Town.BUY_DISTANCE, 20, "pedlar-1")
	Check.eq(ok, true, reason)
	Check.eq(profile.cash, before - price)
	Check.eq(profile.cryptids["pedlar-1"].source, "pedlar")
	Check.eq(profile.cryptids["pedlar-1"].mutation, "")
	Check.eq(profile.shop.boughtSlots[1], true)
	Check.eq(profile.shop.lastRotationId, 15)
	local held = profile.cash
	local again, againReason = Transactions.buyPedlar(profile, 15, 1, stock.bySlot, Town.BUY_DISTANCE, 21, "pedlar-2")
	Check.eq(again, false)
	Check.eq(againReason, "bought")
	Check.eq(profile.cash, held)
	Check.eq(profile.cryptids["pedlar-2"], nil)
	local saved = Schema.migrate(profile)
	local rejoined, rejoinReason = Transactions.buyPedlar(saved, 15, 1, stock.bySlot, Town.BUY_DISTANCE, 22, "pedlar-3")
	Check.eq(rejoined, false)
	Check.eq(rejoinReason, "bought")
	Check.eq(saved.cash, held)
	Check.eq(ShopLedger.slotBought(saved.shop.lastRotationId, saved.shop.boughtSlots, 15, 1), true)
	Check.eq(ShopLedger.slotBought(saved.shop.lastRotationId, saved.shop.boughtSlots, 16, 1), false)
end)

Check.test("QA9 a stale rotation is refused with the pedlar line", function()
	Check.eq(Shop.MOVED_ON, "The Pedlar has moved on.")
	Check.eq(ShopStock.refusal(10, 11), "The Pedlar has moved on.")
	Check.eq(ShopStock.refusal(11, 11), nil)
	local profile = rich()
	profile.shop.lastRotationId = 4
	profile.shop.boughtSlots[3] = true
	profile.cash = 0
	local stock = ShopRoll.generate(5)
	local ok, reason = Transactions.buyPedlar(profile, 5, 1, stock.bySlot, Town.BUY_DISTANCE, 1, "too-poor")
	Check.eq(ok, false)
	Check.eq(reason, "afford")
	Check.eq(profile.cash, 0)
	Check.eq(profile.shop.lastRotationId, 4)
	Check.eq(profile.shop.boughtSlots[3], true)
	Check.eq(profile.cryptids["too-poor"], nil)
end)

Check.test("QA10 the pedlar stays shut before onboarding step 8", function()
	local profile = rich()
	profile.onboarding.step = 7
	local before = profile.cash
	local stock = ShopRoll.generate(3)
	local ok, reason = Transactions.buyPedlar(profile, 3, 1, stock.bySlot, Town.BUY_DISTANCE, 1, "early")
	Check.eq(ok, false)
	Check.eq(reason, "onboarding")
	Check.eq(profile.cash, before)
	Check.eq(profile.cryptids["early"], nil)
	Check.eq(Shop.UNMARKED, "The Pedlar ignores the unmarked.")
	Check.eq(Shop.GATE_STEP, 8)
	profile.onboarding.step = 8
	local opened = Transactions.buyPedlar(profile, 3, 1, stock.bySlot, Town.BUY_DISTANCE, 1, "late")
	Check.eq(opened, true)
end)

Check.test("a pedlar buy past 12 studs is refused and does not charge", function()
	Check.eq(Town.BUY_DISTANCE, 12)
	Check.eq(Town.PROMPT_DISTANCE, 10)
	local profile = rich()
	local stock = ShopRoll.generate(8)
	local before = profile.cash
	local far, farReason = Transactions.buyPedlar(profile, 8, 1, stock.bySlot, 12.01, 1, "far")
	Check.eq(far, false)
	Check.eq(farReason, "range")
	Check.eq(profile.cash, before)
	Check.eq(profile.cryptids.far, nil)
	Check.eq(profile.shop.boughtSlots[1], false)
	local missing, missingReason = Transactions.buyPedlar(profile, 8, 1, stock.bySlot, nil, 1, "missing")
	Check.eq(missing, false)
	Check.eq(missingReason, "range")
	Check.eq(profile.cash, before)
	local near = Transactions.buyPedlar(profile, 8, 1, stock.bySlot, 12, 1, "near")
	Check.eq(near, true)
	Check.eq(profile.cash, before - stock.bySlot[1].price)
	local session = fs.readFile("src/server/PlayerSession.luau")
	Check.contains(session, "Town.BUY_DISTANCE")
	Check.contains(session, "pedlarDistance")
end)

Check.test("QA11 the town never calls MarketplaceService", function()
	local files = {}
	filesUnder("src", files)
	local shop = "src/server/MonetisationService.luau"
	local copy = "src/shared/Logic/RelicsCopy.luau"
	for _, path in files do
		local text = fs.readFile(path)
		if path ~= shop then
			Check.eq(string.find(text, "MarketplaceService", 1, true), nil, path)
			Check.eq(string.find(text, "PromptProductPurchase", 1, true), nil, path)
			Check.eq(string.find(text, "ProcessReceipt", 1, true), nil, path)
		end
		if path ~= copy then
			Check.eq(string.find(text, "Robux", 1, true), nil, path)
		end
	end
end)

Check.test("QA12 the odds view is the four columns and each sums to 100", function()
	local columns = ShopStock.oddsColumns()
	Check.eq(#columns, 4)
	for slot, expected in SPEC_ODDS do
		local column = columns[slot]
		Check.eq(#column.rows, 6)
		local total = 0
		for index, row in column.rows do
			Check.eq(row.rarity, Shop.RARITY_ORDER[index])
			Check.eq(row.percent, expected[index])
			total += row.percent
		end
		Check.eq(total, 100)
		Check.eq(column.total, 100)
	end
	Check.eq(columns[1].name, "Cheap Cage")
	Check.eq(columns[2].name, "Odd Cage")
	Check.eq(columns[3].name, "Rare Cage")
	Check.eq(columns[4].name, "Pedlar's Curio")
	local client = fs.readFile("src/client/PedlarShop.luau")
	Check.contains(client, "ShopStock.oddsColumns")
	Check.contains(client, "board.rotationId")
	Check.eq(string.find(client, "only 1 left", 1, true), nil)
end)

Check.test("QA13 the live atmosphere is the playtest fog and rift green is limited", function()
	Check.eq(UITheme.lighting.atmosphereDensity, 0.18)
	Check.eq(UITheme.lighting.atmosphereHaze, 0.3)
	Check.eq(UITheme.lighting.atmosphereColor, "NightMist")
	Check.eq(UITheme.lighting.atmosphereDecay, "NightSky")
	Check.eq(UITheme.lighting.fogStart, 250)
	Check.eq(UITheme.lighting.fogEnd, 1100)
	Check.eq(UITheme.lighting.fogColor, "NightMist")
	Check.eq(UITheme.lighting.atmosphereOffset, 0)
	Check.eq(UITheme.lighting.atmosphereGlare, 0)
	Check.eq(UITheme.lighting.brightness, 1.5)
	Check.eq(UITheme.lighting.exposureCompensation, 0.3)
	Check.eq(UITheme.palette.LightAmbient, "322848")
	Check.eq(UITheme.palette.LightOutdoor, "51426E")
	Check.eq(UITheme.palette.Ash, "1A1719")
	Check.eq(UITheme.palette.Void, "0B0A0C")
	Check.eq(UITheme.world.Candle, "FFB36B")
	Check.eq(Lanterns.RANGE, 16)
	Check.eq(Lanterns.BRIGHTNESS, 1.2)
	Check.eq(Lanterns.SHADOWS, false)
	Check.eq(Town.LAMP_SPACING, 18)
	Check.eq(Town.LAMP_COUNT % Town.FLICKER_STRIDE, 0)
	Check.eq(Town.FLICKER_MIN, 0.2)
	Check.eq(Town.FLICKER_MAX, 0.6)
	local lighting = fs.readFile("src/server/LightingSetup.luau")
	Check.contains(lighting, "lighting.atmosphereDensity")
	Check.contains(lighting, "lighting.atmosphereHaze")
	Check.contains(lighting, "lighting.atmosphereColor")
	Check.contains(lighting, "lighting.atmosphereDecay")
	Check.eq(string.find(lighting, "townAir", 1, true), nil)
	Check.eq(string.find(lighting, "1.5", 1, true), nil)
	local sources = {}
	filesUnder("src", sources)
	for _, path in sources do
		local text = fs.readFile(path)
		Check.eq(string.find(text, "haze = 1.5", 1, true), nil, path)
		Check.eq(string.find(text, "atmosphereHaze = 1.5", 1, true), nil, path)
	end
	local builder = fs.readFile("src/server/TownBuilder.luau")
	local pedlar = fs.readFile("src/server/Pedlar.luau")
	Check.contains(builder, "NeonRole")
	Check.eq(string.find(builder, "LightEmission", 1, true), nil)
	Check.eq(string.find(pedlar, "LightEmission", 1, true), nil)
	Check.eq(string.find(pedlar, 'UITheme.color("Rift")', 1, true), nil)
	Check.eq(Lanterns.RIFT_PARTICLE_COLOR, "Rift")
	Check.eq(Lanterns.RIFT_SURFACE, "RiftDim")
	Check.eq(UITheme.palette.Rift, "7FA34A")
	Check.eq(UITheme.palette.RiftDim, "4F6B34")
	Check.eq(string.find(builder, "purple", 1, true), nil)
	Check.eq(string.find(pedlar, "purple", 1, true), nil)
	for _, hex in UITheme.palette do
		local red = tonumber(string.sub(hex, 1, 2), 16) or 0
		local green = tonumber(string.sub(hex, 3, 4), 16) or 0
		local blue = tonumber(string.sub(hex, 5, 6), 16) or 0
		Check.eq(red > 140 and blue > 140 and green < 100, false, hex)
	end
end)

Check.test("QA14 the shrine prompt is the spec 04 hook", function()
	local shrine = fs.readFile("src/client/SkillTree.luau")
	Check.contains(shrine, "Town.SHRINE_BODY")
	Check.contains(shrine, "function SkillTree.mount")
	Check.eq(Town.SHRINE_TITLE, "Skill Shrine")
	Check.eq(Town.SHRINE_UNMARKED, "The shrine is silent to the unmarked.")
	Check.contains(Town.SHRINE_BODY, "skill tree")
	Check.contains(shrine, "Town.SHRINE_UNMARKED")
	Check.contains(shrine, "Shop.GATE_STEP")
	local interactions = fs.readFile("src/client/Interactions.luau")
	Check.contains(interactions, 'kindName == "Pedlar" or kindName == "SkillShrine"')
	Check.contains(interactions, "SkillShrine")
	Check.contains(interactions, "town.onShrine")
	local session = fs.readFile("src/server/PlayerSession.luau")
	Check.contains(session, "allowRequest")
	Check.contains(session, "allowPurchase")
	Check.contains(session, "Transactions.buyPedlar")
	Check.contains(session, "ShopStock.refusal")
end)

Check.test("species pools use roster names and an empty rarity falls back", function()
	local seen = {}
	for _, id in ShopPools.Common do
		seen[id] = true
		Check.eq(Species.get(id).rarity, "Common")
	end
	Check.eq(seen.fresno_nightcrawler, true)
	Check.eq(seen.hidebehind, true)
	Check.eq(seen.hodag, true)
	Check.eq(seen.mothman_hatchling, true)
	for _, rarity in Shop.RARITY_ORDER do
		local pool = ShopPools[rarity]
		if rarity == "Legendary" or rarity == "Mythic" then
			Check.eq(#pool, 0, rarity)
		elseif rarity ~= "Common" then
			Check.truthy(#pool > 0, rarity)
			for _, id in pool do
				local species = Species.get(id)
				Check.truthy(species, id)
				Check.eq(species.rarity, rarity, id)
				Check.eq(species.baseIncome, Shop.RARITIES[rarity].baseIncome, id)
				Check.eq(string.find(species.displayName, "Placeholder", 1, true), nil, id)
			end
		end
	end
	local thin = {
		Common = { "fresno_nightcrawler" },
		Uncommon = { "uncommon_01" },
		Rare = {},
		Epic = {},
		Legendary = {},
		Mythic = {},
	}
	local rng = SeededRng.new(7)
	local id, from, warning = ShopRoll.speciesFor("Rare", thin, rng)
	Check.eq(id, "uncommon_01")
	Check.eq(from, "Uncommon")
	Check.truthy(warning)
	local empty = {
		Common = {},
		Uncommon = {},
		Rare = {},
		Epic = {},
		Legendary = {},
		Mythic = {},
	}
	local starter, _, emptyWarning = ShopRoll.speciesFor("Mythic", empty, rng)
	Check.eq(starter, Species.STARTER_ID)
	Check.truthy(emptyWarning)
	local rolled = ShopRoll.generate(9, thin)
	Check.truthy(#rolled.warnings > 0)
	for _, offer in rolled.offers do
		Check.truthy(Species.get(offer.speciesId))
	end
end)

Check.test("no shop or species display name says Placeholder", function()
	local paths = {
		"src/shared/Config/Species.luau",
		"src/shared/Config/Shop.luau",
		"src/shared/Config/ShopPools.luau",
	}
	for _, path in paths do
		local text = fs.readFile(path)
		Check.eq(string.find(text, "Placeholder", 1, true), nil, path)
	end
	Check.eq(Species.get("uncommon_01").displayName, "Jackalope")
	Check.eq(Species.get("uncommon_01").rarity, "Uncommon")
	Check.eq(Species.get("uncommon_02").displayName, "Dover Demon")
	Check.eq(Species.get("loveland_frogman").displayName, "Loveland Frogman")
	Check.eq(Species.get("loveland_frogman").rarity, "Uncommon")
	Check.eq(Species.get("rare_01").displayName, "Beast of Bray Road")
	Check.eq(Species.get("rare_01").rarity, "Rare")
	Check.eq(Species.get("epic_01").displayName, "Jersey Devil")
	Check.eq(Species.get("epic_02").displayName, "Loch Ness Serpent")
	Check.eq(Species.get("hodag").displayName, "Hodag")
	Check.eq(Species.get(Species.WILD_ID).rarity, "Common")
	for _, id in Species.ids() do
		local species = Species.get(id)
		Check.eq(string.find(species.displayName, "Placeholder", 1, true), nil, id)
	end
	for _, rarity in Shop.RARITY_ORDER do
		for _, id in ShopPools[rarity] do
			local species = Species.get(id)
			Check.eq(species.rarity, rarity, id)
			Check.eq(string.find(species.displayName, "Placeholder", 1, true), nil, id)
		end
	end
end)

Check.test("buying rolls into the next rotation and bind at once uses the first empty pad", function()
	local profile = rich()
	local stock = ShopRoll.generate(9)
	local first = Transactions.buyPedlar(profile, 9, 2, stock.bySlot, Town.BUY_DISTANCE, 1, "bound-off")
	Check.eq(first, true)
	Check.eq(profile.pads["2"], nil)
	Check.eq(profile.settings.bindAtOnce, false)
	local nextStock = ShopRoll.generate(10)
	profile.settings.bindAtOnce = true
	local second, reason = Transactions.buyPedlar(profile, 10, 2, nextStock.bySlot, Town.BUY_DISTANCE, 2, "bound-on")
	Check.eq(second, true, reason)
	Check.eq(profile.pads["2"], "bound-on")
	Check.eq(profile.shop.lastRotationId, 10)
	Check.eq(profile.shop.boughtSlots[2], true)
	Check.eq(profile.shop.boughtSlots[1], false)
	profile.pads["2"] = "bound-on"
	local third = Transactions.buyPedlar(profile, 10, 4, nextStock.bySlot, Town.BUY_DISTANCE, 3, "held")
	Check.eq(third, true)
	Check.eq(profile.pads["1"], "starter")
	Check.eq(profile.pads["2"], "bound-on")
	Check.eq(profile.cryptids.held.source, "pedlar")
	Check.eq(RemoteArgs.pedlarSlot(0), nil)
	Check.eq(RemoteArgs.pedlarSlot(1.5), nil)
	Check.eq(RemoteArgs.pedlarSlot(5), nil)
	Check.eq(RemoteArgs.pedlarSlot("1"), nil)
	Check.eq(RemoteArgs.pedlarSlot(4), 4)
	Check.eq(RemoteArgs.rotationId(-1), nil)
	Check.eq(RemoteArgs.rotationId(1.2), nil)
	Check.eq(RemoteArgs.rotationId(10), 10)
end)

Check.test("v3 saves gain an empty shop and bind at once without rewriting the old table", function()
	Check.eq(Save.DATA_VERSION, 9)
	local legacy = Schema.newProfile(20, "starter")
	legacy.dataVersion = 3
	legacy.cash = 80
	legacy.settings = {
		reducedMotion = true,
	}
	legacy.shop = nil
	legacy.base = {
		defences = {
			["2"] = "ward_candle",
		},
	}
	local migrated = Schema.migrate(legacy)
	Check.truthy(migrated)
	Check.eq(migrated.dataVersion, Save.DATA_VERSION)
	Check.eq(migrated.cash, 80)
	Check.eq(migrated.settings.reducedMotion, true)
	Check.eq(migrated.settings.bindAtOnce, false)
	Check.eq(migrated.shop.lastRotationId, 0)
	Check.eq(#migrated.shop.boughtSlots, 4)
	Check.eq(migrated.shop.boughtSlots[1], false)
	Check.eq(migrated.shop.boughtSlots[4], false)
	Check.eq(migrated.base.defences[2], "ward_candle")
	Check.eq(legacy.shop, nil)
	Check.eq(legacy.settings.bindAtOnce, nil)
	Check.eq(legacy.dataVersion, 3)

	local current = Schema.newProfile(4, "starter")
	current.shop.lastRotationId = 42
	current.shop.boughtSlots = { true, false, true, false }
	current.settings.bindAtOnce = true
	current.cash = 12
	local kept = Schema.migrate(current)
	Check.eq(kept.shop.lastRotationId, 42)
	Check.eq(kept.shop.boughtSlots[1], true)
	Check.eq(kept.shop.boughtSlots[2], false)
	Check.eq(kept.shop.boughtSlots[3], true)
	Check.eq(kept.settings.bindAtOnce, true)
	Check.eq(kept.cash, 12)
	Check.eq(current.shop.boughtSlots[1], true)

	local keyed = Schema.newProfile(4, "starter")
	keyed.shop.boughtSlots = { ["1"] = false, ["2"] = true, ["3"] = false, ["4"] = false }
	keyed.shop.lastRotationId = 8
	local fromKeys = Schema.migrate(keyed)
	Check.eq(fromKeys.shop.boughtSlots[2], true)
	Check.eq(fromKeys.shop.lastRotationId, 8)

	local encoded = serde.encode("json", current)
	local decoded = Schema.migrate(serde.decode("json", encoded))
	Check.eq(decoded.dataVersion, Save.DATA_VERSION)
	Check.eq(decoded.shop.boughtSlots[1], true)
	Check.eq(decoded.shop.boughtSlots[3], true)
	Check.eq(decoded.settings.bindAtOnce, true)

	local broken = Schema.newProfile(4, "starter")
	broken.shop.boughtSlots = { true, false }
	Check.eq(Schema.migrate(broken), nil)
	Check.eq(broken.shop.boughtSlots[1], true)

	local future = Schema.newProfile(4, "starter")
	future.dataVersion = Save.DATA_VERSION + 1
	Check.eq(Schema.migrate(future), nil)

	local fresh = Schema.newProfile(4, "starter")
	Check.eq(fresh.dataVersion, Save.DATA_VERSION)
	Check.eq(fresh.settings.bindAtOnce, false)
	Check.eq(fresh.shop.lastRotationId, 0)
	local lean = math.abs(TownLayout.leanDegrees(1))
	Check.eq(lean >= Town.LEAN_MIN, true)
	Check.eq(lean <= Town.LEAN_MAX, true)
	Check.eq(math.abs(TownLayout.leanDegrees(8)) <= Town.LEAN_MAX, true)
	Check.eq(Town.WISP.rate, 2)
	Check.eq(Town.WISP.transparency >= 0.8, true)
	Check.eq(Town.WISP.wallCount, Plots.COUNT)
	Check.eq(Town.WISP.wallCount + Plots.COUNT, 16)
	local edge = Town.WISP.wildPast
	Check.eq(math.abs(Plots.WILD_GATE_Z - edge) > Plots.FOOTPRINT / 2, true)
	for index = 1, Town.WISP.wallCount do
		local theta = math.rad(TownLayout.districtAngle(index))
		local point = {
			x = Plots.TOWN_RADIUS * math.sin(theta),
			z = Plots.TOWN_RADIUS * math.cos(theta),
		}
		Check.near(TownLayout.radius(point), Plots.TOWN_RADIUS, 0.01)
		Check.eq(TownLayout.radius(point) > Town.DISTRICT_RADIUS, true)
	end
end)
