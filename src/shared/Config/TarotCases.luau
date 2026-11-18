--!strict

-- Veil & Fate cases. The free decks use spec 09 §5.1–§5.2.
-- Paid tiers, the Premium case, and the event case are a framework only.
-- productId and price are unset. TBD: pending Eudai approval.
-- Paid contents, weights, pity thresholds, and the event window are placeholders.

local PERCENT_BASIS = 10000

-- TBD: pending Eudai approval. Placeholder pity thresholds.
local PITY_TIER_1 = 20
local PITY_TIER_2 = 15
local PITY_TIER_3 = 10
local PITY_PREMIUM = 8
local PITY_EVENT = 12

-- TBD: pending Eudai approval. Placeholder UTC window (2030-01-01 through 2030-01-08).
local EVENT_START = 1893456000
local EVENT_END = 1894060800

-- TBD: pending Eudai approval. Placeholder duplicate cash, not a live price.
local PLACEHOLDER_CASH = 1

local function row(rarity: string, weight: number)
	return table.freeze({
		rarity = rarity,
		weight = weight,
	})
end

local function card(id: string, name: string, rarity: string, duplicateCash: number, kind: string)
	return table.freeze({
		id = id,
		name = name,
		rarity = rarity,
		duplicateCash = duplicateCash,
		kind = kind,
	})
end

local function placeholderPool(prefix: string)
	return table.freeze({
		card(prefix .. "_common", "Placeholder Common", "Common", PLACEHOLDER_CASH, "placeholder"),
		card(prefix .. "_uncommon", "Placeholder Uncommon", "Uncommon", PLACEHOLDER_CASH, "placeholder"),
		card(prefix .. "_rare", "Placeholder Rare", "Rare", PLACEHOLDER_CASH, "placeholder"),
		card(prefix .. "_epic", "Placeholder Epic", "Epic", PLACEHOLDER_CASH, "placeholder"),
	})
end

local PALE_POOL = table.freeze({
	card("mothman_hatchling", "Mothman Hatchling", "Common", 60, "cryptid"),
	card("fresno_nightcrawler", "Fresno Nightcrawler", "Common", 90, "cryptid"),
	card("hidebehind", "Hidebehind", "Common", 120, "cryptid"),
	card("hodag", "Hodag", "Common", 150, "cryptid"),
	card("uncommon_01", "Jackalope", "Uncommon", 720, "cryptid"),
	card("uncommon_02", "Dover Demon", "Uncommon", 840, "cryptid"),
	card("snallygaster", "Snallygaster", "Uncommon", 960, "cryptid"),
	card("loveland_frogman", "Loveland Frogman", "Uncommon", 1080, "cryptid"),
	card("flatwoods_monster", "Flatwoods Monster", "Rare", 6000, "cryptid"),
	card("rare_01", "Beast of Bray Road", "Rare", 7500, "cryptid"),
	card("epic_01", "Jersey Devil", "Epic", 60000, "cryptid"),
	card("epic_02", "Loch Ness Serpent", "Epic", 68000, "cryptid"),
})

local BLOOD_POOL = table.freeze({
	card("uncommon_01", "Jackalope", "Uncommon", 720, "cryptid"),
	card("uncommon_02", "Dover Demon", "Uncommon", 840, "cryptid"),
	card("snallygaster", "Snallygaster", "Uncommon", 960, "cryptid"),
	card("loveland_frogman", "Loveland Frogman", "Uncommon", 1080, "cryptid"),
	card("flatwoods_monster", "Flatwoods Monster", "Rare", 6000, "cryptid"),
	card("rare_01", "Beast of Bray Road", "Rare", 7500, "cryptid"),
	card("epic_01", "Jersey Devil", "Epic", 60000, "cryptid"),
	card("epic_02", "Loch Ness Serpent", "Epic", 68000, "cryptid"),
})

local PALE_WEIGHTS = table.freeze({
	row("Common", 55),
	row("Uncommon", 35),
	row("Rare", 9),
	row("Epic", 1),
})

local BLOOD_WEIGHTS = table.freeze({
	row("Uncommon", 50),
	row("Rare", 40),
	row("Epic", 10),
})

-- TBD: pending Eudai approval. Placeholder weights, not a live offer.
local TIER_1_WEIGHTS = table.freeze({
	row("Common", 70),
	row("Uncommon", 20),
	row("Rare", 8),
	row("Epic", 2),
})

local TIER_2_WEIGHTS = table.freeze({
	row("Common", 50),
	row("Uncommon", 30),
	row("Rare", 15),
	row("Epic", 5),
})

local TIER_3_WEIGHTS = table.freeze({
	row("Common", 20),
	row("Uncommon", 35),
	row("Rare", 30),
	row("Epic", 15),
})

local PREMIUM_WEIGHTS = table.freeze({
	row("Common", 5),
	row("Uncommon", 15),
	row("Rare", 40),
	row("Epic", 40),
})

local EVENT_WEIGHTS = table.freeze({
	row("Common", 60),
	row("Uncommon", 25),
	row("Rare", 12),
	row("Epic", 3),
})

local function deck(
	id: string,
	name: string,
	kind: string,
	family: string,
	token: string?,
	weights: { any },
	pityRarity: string,
	pityWithin: number,
	pool: { any },
	placeholder: boolean,
	startsAt: number?,
	endsAt: number?
)
	return table.freeze({
		id = id,
		name = name,
		kind = kind,
		family = family,
		token = token,
		-- TBD: pending Eudai approval. No developer product and no price.
		productId = nil,
		price = nil,
		placeholder = placeholder,
		pity = table.freeze({
			rarity = pityRarity,
			within = pityWithin,
		}),
		weights = weights,
		pool = pool,
		startsAt = startsAt,
		endsAt = endsAt,
	})
end

local LIST = table.freeze({
	deck("pale", "Pale Deck", "free", "pale", "pale", PALE_WEIGHTS, "Epic", 40, PALE_POOL, false, nil, nil),
	deck("blood", "Blood Deck", "free", "blood", "blood", BLOOD_WEIGHTS, "Epic", 15, BLOOD_POOL, false, nil, nil),
	deck(
		"tier1",
		"Tier I",
		"paid",
		"tier1",
		nil,
		TIER_1_WEIGHTS,
		"Rare",
		PITY_TIER_1,
		placeholderPool("placeholder_tier1"),
		true,
		nil,
		nil
	),
	deck(
		"tier2",
		"Tier II",
		"paid",
		"tier2",
		nil,
		TIER_2_WEIGHTS,
		"Rare",
		PITY_TIER_2,
		placeholderPool("placeholder_tier2"),
		true,
		nil,
		nil
	),
	deck(
		"tier3",
		"Tier III",
		"paid",
		"tier3",
		nil,
		TIER_3_WEIGHTS,
		"Epic",
		PITY_TIER_3,
		placeholderPool("placeholder_tier3"),
		true,
		nil,
		nil
	),
	deck(
		"premium",
		"Premium",
		"paid",
		"premium",
		nil,
		PREMIUM_WEIGHTS,
		"Epic",
		PITY_PREMIUM,
		placeholderPool("placeholder_premium"),
		true,
		nil,
		nil
	),
	deck(
		"event",
		"Event case",
		"event",
		"event",
		nil,
		EVENT_WEIGHTS,
		"Rare",
		PITY_EVENT,
		placeholderPool("placeholder_event"),
		true,
		EVENT_START,
		EVENT_END
	),
})

local BY_ID: { [string]: any } = {}
for _, entry in LIST do
	BY_ID[entry.id] = entry
end

local TarotCases = {
	-- Paid cases stay off until prices and product ids are approved.
	PAID_TAROT_ENABLED = false,
	PERCENT_BASIS = PERCENT_BASIS,
	PLACEHOLDER_CASH = PLACEHOLDER_CASH,
	EVENT_START = EVENT_START,
	EVENT_END = EVENT_END,
	CASE_CAP = 99,
	REQUEST_CAP = 24,
	PITY_CAP = 1000,
	NONCE_CAP = 1000000000000,
	LINE_MAX = 180,
	GRANT_MAX = 8,
	STUDIO_SAMPLE = 1,
	SEED_MASK = 2147483647,
	SEED_SALT = 2779096485,
	SHOP_ID = "VeilAndFate",
	OPEN = "Open",
	NO_CARDS = "No cards yet",
	SEE_PRICE = "See Price",
	NOT_AVAILABLE = "Not yet available",
	ODDS_NOTE = "Each percent is that rarity's roll weight, shown to 0.01%. Leftover hundredths go to the largest remainders so the table adds to 100%. Cryptids in a rarity are equally likely.",
	DUPLICATE_RULE = "A duplicate in a rarity you have not finished is redrawn as an unowned cryptid of that rarity. If you own them all, it becomes that card's cash:",
	PLACEHOLDER_RULE = "Placeholder contents, not a live offer. A duplicate in a rarity you have not finished is redrawn as another unowned card of that rarity. If you own them all, it becomes that card's cash:",
	RANK = table.freeze({
		Common = 1,
		Uncommon = 2,
		Rare = 3,
		Epic = 4,
		Legendary = 5,
		Mythic = 6,
	}),
	NOTICES = table.freeze({
		args = "The tent did not understand that.",
		none = "You have no cards yet.",
		empty = "You have no cases.",
		unavailable = "Not yet available.",
		window = "That case is closed.",
		distance = "Step closer to the tent.",
		open = "The tent is closed.",
		replay = "Already opened.",
		id = "The card could not be bound.",
	}),
}

function TarotCases.list(): { any }
	return LIST
end

function TarotCases.get(id: any): any?
	if type(id) ~= "string" then
		return nil
	end
	return BY_ID[id]
end

function TarotCases.byProductId(id: any): any?
	if type(id) ~= "number" or id ~= math.floor(id) or id <= 0 then
		return nil
	end
	for _, entry in LIST do
		if entry.productId == id then
			return entry
		end
	end
	return nil
end

return table.freeze(TarotCases)
