--!strict

local ShopPools = {
	Common = table.freeze({
		"fresno_nightcrawler",
		"hidebehind",
		"hodag",
		"mothman_hatchling",
	}),
	Uncommon = table.freeze({
		"uncommon_01",
		"uncommon_02",
		"loveland_frogman",
	}),
	Rare = table.freeze({
		"rare_01",
	}),
	Epic = table.freeze({
		"epic_01",
		"epic_02",
	}),
	Legendary = table.freeze({}),
	Mythic = table.freeze({}),
}

return table.freeze(ShopPools)
