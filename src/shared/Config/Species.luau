--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Return = import("./Return", function()
	return script.Parent:WaitForChild("Return")
end)

export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic"

export type SpeciesRecord = {
	id: string,
	displayName: string,
	rarity: Rarity,
	baseIncome: number,
	riftPrice: number?,
}

local function record(
	id: string,
	displayName: string,
	baseIncome: number,
	riftPrice: number?,
	rarity: Rarity?
): SpeciesRecord
	local resolved = rarity
	if resolved == nil then
		resolved = "Common"
	end
	return table.freeze({
		id = id,
		displayName = displayName,
		rarity = resolved :: Rarity,
		baseIncome = baseIncome,
		riftPrice = riftPrice,
	})
end

local BY_ID: { [string]: SpeciesRecord } = {
	mothman_hatchling = record("mothman_hatchling", "Mothman Hatchling", 2, nil),
	fresno_nightcrawler = record("fresno_nightcrawler", "Fresno Nightcrawler", 3, 50),
	hidebehind = record("hidebehind", "Hidebehind", 4, 75),
	hodag = record("hodag", "Hodag", 5, nil),
	uncommon_01 = record("uncommon_01", "Placeholder Uncommon", 15, nil, "Uncommon"),
	uncommon_02 = record("uncommon_02", "Placeholder Uncommon II", 15, nil, "Uncommon"),
	rare_01 = record("rare_01", "Placeholder Rare", 45, nil, "Rare"),
	rare_02 = record("rare_02", "Placeholder Rare II", 45, nil, "Rare"),
	epic_01 = record("epic_01", "Placeholder Epic", 160, nil, "Epic"),
	epic_02 = record("epic_02", "Placeholder Epic II", 160, nil, "Epic"),
	legendary_01 = record("legendary_01", "Placeholder Legendary", 600, nil, "Legendary"),
	legendary_02 = record("legendary_02", "Placeholder Legendary II", 600, nil, "Legendary"),
	mythic_01 = record("mythic_01", "Placeholder Mythic", 2500, nil, "Mythic"),
	mythic_02 = record("mythic_02", "Placeholder Mythic II", 2500, nil, "Mythic"),
	snallygaster = record("snallygaster", "Snallygaster", Return.SNALLYGASTER_INCOME, nil, "Uncommon"),
	flatwoods_monster = record("flatwoods_monster", "Flatwoods Monster", Return.FLATWOODS_INCOME, nil, "Rare"),
}

local Species = {
	STARTER_ID = "mothman_hatchling",
	RIFT_1_ID = "fresno_nightcrawler",
	RIFT_2_ID = "hidebehind",
	WILD_ID = "hodag",
	LEGACY_WILD_ID = "wild_common",
	SNALLYGASTER_ID = "snallygaster",
	FLATWOODS_ID = "flatwoods_monster",
	GUARANTEES = table.freeze({
		table.freeze({
			slot = 1,
			speciesId = "fresno_nightcrawler",
			pad = 2,
		}),
		table.freeze({
			slot = 2,
			speciesId = "hidebehind",
			pad = 4,
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
