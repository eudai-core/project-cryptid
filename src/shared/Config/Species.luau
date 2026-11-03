--!strict

export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic"

export type SpeciesRecord = {
	id: string,
	displayName: string,
	rarity: Rarity,
	baseIncome: number,
	riftPrice: number?,
}

local function record(id: string, displayName: string, baseIncome: number, riftPrice: number?): SpeciesRecord
	return table.freeze({
		id = id,
		displayName = displayName,
		rarity = "Common" :: Rarity,
		baseIncome = baseIncome,
		riftPrice = riftPrice,
	})
end

local BY_ID: { [string]: SpeciesRecord } = {
	mothman_hatchling = record("mothman_hatchling", "Mothman Hatchling", 2, nil),
	fresno_nightcrawler = record("fresno_nightcrawler", "Fresno Nightcrawler", 3, 50),
	hidebehind = record("hidebehind", "Hidebehind", 4, 75),
	wild_common = record("wild_common", "Wild Common", 5, nil),
}

local Species = {
	STARTER_ID = "mothman_hatchling",
	RIFT_1_ID = "fresno_nightcrawler",
	RIFT_2_ID = "hidebehind",
	WILD_ID = "wild_common",
	GUARANTEES = table.freeze({
		table.freeze({
			slot = 1,
			speciesId = "fresno_nightcrawler",
			pad = 2,
		}),
		table.freeze({
			slot = 2,
			speciesId = "hidebehind",
			pad = 3,
		}),
	}),
}

function Species.get(id: string): SpeciesRecord?
	return BY_ID[id]
end

function Species.ids(): { string }
	local list = {}
	for id in BY_ID do
		table.insert(list, id)
	end
	table.sort(list)
	return list
end

return Species
