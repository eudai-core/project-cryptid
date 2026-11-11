--!strict

local function odds(common: number, uncommon: number, rare: number, epic: number, legendary: number, mythic: number)
	return table.freeze({
		Common = common,
		Uncommon = uncommon,
		Rare = rare,
		Epic = epic,
		Legendary = legendary,
		Mythic = mythic,
	})
end

local Shop = {
	SLOT_COUNT = 4,
	ROTATION_SECONDS = 300,
	GATE_STEP = 8,
	GLOW_SECONDS = 10,
	RESTOCK_POLL_SECONDS = 0.25,
	HEADER_PX = 32,
	PANEL = table.freeze({
		width = 720,
		height = 420,
		padding = 12,
		mobileMargin = 12,
	}),
	RARITY_ORDER = table.freeze({
		"Common",
		"Uncommon",
		"Rare",
		"Epic",
		"Legendary",
		"Mythic",
	}),
	RARITIES = table.freeze({
		Common = table.freeze({ baseIncome = 6, paybackSeconds = 30 }),
		Uncommon = table.freeze({ baseIncome = 15, paybackSeconds = 60 }),
		Rare = table.freeze({ baseIncome = 45, paybackSeconds = 150 }),
		Epic = table.freeze({ baseIncome = 160, paybackSeconds = 400 }),
		Legendary = table.freeze({ baseIncome = 600, paybackSeconds = 1200 }),
		Mythic = table.freeze({ baseIncome = 2500, paybackSeconds = 3600 }),
	}),
	SLOTS = table.freeze({
		table.freeze({
			index = 1,
			name = "Cheap Cage",
			odds = odds(100, 0, 0, 0, 0, 0),
		}),
		table.freeze({
			index = 2,
			name = "Odd Cage",
			odds = odds(0, 75, 25, 0, 0, 0),
		}),
		table.freeze({
			index = 3,
			name = "Rare Cage",
			odds = odds(0, 0, 80, 20, 0, 0),
		}),
		table.freeze({
			index = 4,
			name = "Pedlar's Curio",
			odds = odds(0, 0, 70, 30, 0, 0),
		}),
	}),
	HEADER = "The Pale Pedlar",
	RESTOCK_PREFIX = "Restocks in ",
	ODDS = "Odds",
	ODDS_TOTAL = "Total",
	BUY = "Buy",
	SOLD = "Sold to you",
	NEED_MORE = "Need %s more",
	BIND_ON = "Bind at once: On",
	BIND_OFF = "Bind at once: Off",
	LEAVE = "Leave",
	WAITING = "The pedlar is counting the cages.",
	UNMARKED = "The Pedlar ignores the unmarked.",
	MOVED_ON = "The Pedlar has moved on.",
	PROMPT = "Browse the Pedlar's cages",
	OPEN_TOKEN = "PedlarOpenToken",
}

return table.freeze(Shop)
