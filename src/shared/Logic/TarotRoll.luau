--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local TarotCases = import("../Config/TarotCases", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("TarotCases")
end)
local ProfileQuery = import("./ProfileQuery", function()
	return script.Parent:WaitForChild("ProfileQuery")
end)
local TarotOdds = import("./TarotOdds", function()
	return script.Parent:WaitForChild("TarotOdds")
end)

local TarotRoll = {}

function TarotRoll.mix(nonce: number, entropy: number): number
	local left = bit32.band(nonce, TarotCases.SEED_MASK)
	local right = bit32.band(entropy, TarotCases.SEED_MASK)
	local mixed = bit32.bxor(left, right, TarotCases.SEED_SALT)
	if mixed == 0 then
		mixed = 1
	end
	return mixed
end

local function owns(profile: any, card: any): boolean
	if card.kind == "cryptid" then
		return ProfileQuery.ownsSpecies(profile, card.id)
	end
	local known = profile.tarot.known
	return type(known) == "table" and known[card.id] == true
end

function TarotRoll.roll(case: any, profile: any, rng: any): any?
	local pity = TarotOdds.pityCount(profile, case.family)
	local rows = TarotOdds.live(case, pity)
	local rarity = TarotOdds.pick(rows, rng)
	local pool = {}
	local unowned = {}
	for _, card in case.pool do
		if card.rarity == rarity then
			table.insert(pool, card)
			if not owns(profile, card) then
				table.insert(unowned, card)
			end
		end
	end
	if #pool == 0 then
		return nil
	end
	local rolled = pool[rng:NextInteger(1, #pool)]
	local card = rolled
	local converted = false
	if owns(profile, rolled) then
		if #unowned > 0 then
			card = unowned[rng:NextInteger(1, #unowned)]
		else
			converted = true
		end
	end
	local nextPity = 0
	local rank = TarotCases.RANK[rarity] or 0
	local floor = TarotCases.RANK[case.pity.rarity] or 0
	if rank < floor then
		nextPity = pity + 1
		local cap = case.pity.within - 1
		if cap < 0 then
			cap = 0
		end
		if nextPity > cap then
			nextPity = cap
		end
	end
	return {
		card = card,
		rarity = rarity,
		converted = converted,
		pity = nextPity,
		rows = rows,
	}
end

return TarotRoll
