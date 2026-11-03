--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local SeededRng = import("./SeededRng", function()
	return script.Parent:WaitForChild("SeededRng")
end)
local ShopSalt = import("./ShopSalt", function()
	return script.Parent:WaitForChild("ShopSalt")
end)
local Shop = import("../shared/Config/Shop", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Shop")
end)
local ShopPools = import("../shared/Config/ShopPools", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("ShopPools")
end)
local ShopStock = import("../shared/Logic/ShopStock", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("ShopStock")
end)
local Species = import("../shared/Config/Species", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Species")
end)

local ShopRoll = {}

local function rollRarity(rng: any, weights: any): string
	local roll = rng:nextInt(1, 100)
	local cursor = 0
	for _, rarity in Shop.RARITY_ORDER do
		cursor += weights[rarity]
		if roll <= cursor then
			return rarity
		end
	end
	return Shop.RARITY_ORDER[#Shop.RARITY_ORDER]
end

function ShopRoll.speciesFor(rarity: string, pools: any, rng: any): (string, string, string?)
	local startIndex = 1
	for index, name in Shop.RARITY_ORDER do
		if name == rarity then
			startIndex = index
			break
		end
	end
	for index = startIndex, 1, -1 do
		local name = Shop.RARITY_ORDER[index]
		local pool = pools[name]
		if type(pool) == "table" and #pool > 0 then
			local pick = pool[rng:nextInt(1, #pool)]
			if type(pick) ~= "string" or Species.get(pick) == nil then
				return Species.STARTER_ID, "Common", "unknown shop species for " .. rarity
			end
			if name ~= rarity then
				return pick, name, "empty shop pool for " .. rarity .. ", fell back to " .. name
			end
			return pick, name, nil
		end
	end
	return Species.STARTER_ID, "Common", "empty shop pool for " .. rarity .. ", fell back to starter"
end

function ShopRoll.generate(rotationId: number, pools: any?): any
	local source = pools
	if source == nil then
		source = ShopPools
	end
	local rng = SeededRng.new(rotationId + ShopSalt.SALT)
	local offers = {}
	local bySlot = {}
	local warnings = {}
	local seen: { [string]: boolean } = {}
	for _, slot in Shop.SLOTS do
		local rolled = rollRarity(rng, slot.odds)
		local speciesId, from, warning = ShopRoll.speciesFor(rolled, source, rng)
		if warning ~= nil and seen[warning] ~= true then
			seen[warning] = true
			table.insert(warnings, warning)
		end
		local species = Species.get(speciesId)
		local rarity = if species ~= nil then species.rarity else from
		local offer = {
			slot = slot.index,
			slotName = slot.name,
			speciesId = speciesId,
			displayName = if species ~= nil then species.displayName else speciesId,
			rarity = rarity,
			rolledRarity = rolled,
			price = ShopStock.price(rarity),
			mutation = "",
		}
		table.insert(offers, offer)
		bySlot[slot.index] = offer
	end
	return {
		offers = offers,
		bySlot = bySlot,
		warnings = warnings,
	}
end

return ShopRoll
