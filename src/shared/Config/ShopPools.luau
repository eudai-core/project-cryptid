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
	}),
	Rare = table.freeze({
		"rare_01",
		"rare_02",
	}),
	Epic = table.freeze({
		"epic_01",
		"epic_02",
	}),
	Legendary = table.freeze({
		"legendary_01",
		"legendary_02",
	}),
	Mythic = table.freeze({
		"mythic_01",
		"mythic_02",
	}),
}

return table.freeze(ShopPools)
