--!strict

local TownLook = {
	-- Runaway sanity guards only. There is no part or light budget; do not thin a building to stay under them.
	PART_CAP = 20000,
	LIGHT_CAP = 200,
	VFX_MAX_EMITTERS = 6,
	VFX_MAX_PARTICLES = 120,
	LOW_QUALITY_MAX = 4,
	WELL_LIGHT_RANGE = 14,
	WELL_LIGHT_BRIGHTNESS = 1,
	WELL_WATER_GLOW_RANGE = 10,
	WELL_WATER_GLOW_BRIGHTNESS = 0.55,
	WELL_RUNE_GLOW_RANGE = 5,
	WELL_RUNE_GLOW_BRIGHTNESS = 0.3,
	PORTAL_LIGHT_RANGE = 12,
	PORTAL_LIGHT_BRIGHTNESS = 0.9,
	MIST_RATE = 8,
	MIST_LIFE = 1.8,
	RUNE_DRIFT_RATE = 3,
	RUNE_DRIFT_LIFE = 2,
	FLAME_CORE_RATE = 16,
	FLAME_CORE_LIFE = 1,
	FLAME_EXTRA_RATE = 8,
	FLAME_EXTRA_LIFE = 1.2,
	VORTEX_SWIRL_RATE = 18,
	VORTEX_SWIRL_LIFE = 1.4,
	VORTEX_SPARK_RATE = 10,
	VORTEX_SPARK_LIFE = 1,
	CROW_COUNT = 3,
	NEON_ROLES = table.freeze({
		flame = true,
		portal = true,
		rune = true,
		sign = true,
		eye = true,
	}),
	SHOPS = table.freeze({
		table.freeze({
			id = "RuneheartApothecary",
			kind = "apothecary",
			angle = 112,
			radius = 40,
			sign = "Runeheart Apothecary",
			flame = "FlameGreen",
		}),
		table.freeze({
			id = "HowlingHorn",
			kind = "tavern",
			angle = 68,
			radius = 42,
			sign = "The Howling Horn",
			flame = "FlameBlue",
		}),
		table.freeze({
			id = "VeilAndFate",
			kind = "tarot",
			angle = 293,
			radius = 40,
			sign = "Veil & Fate",
			flame = "FlameViolet",
		}),
		table.freeze({
			id = "DuskAndDial",
			kind = "clock",
			angle = 248,
			radius = 46,
			sign = "Dusk & Dial",
			flame = "MoonGlow",
		}),
	}),
	PORTALS = table.freeze({
		table.freeze({
			id = "WhisperingWoods",
			kind = "tree",
			angle = 158,
			radius = 58,
			sign = "Whispering Woods",
			color = "FlameGreen",
			level = "",
		}),
		table.freeze({
			id = "SunkenMarsh",
			kind = "serpent",
			angle = 203,
			radius = 58,
			sign = "Sunken Marsh",
			color = "Spirit",
			level = "Level 25+",
		}),
		table.freeze({
			id = "BoneQuarry",
			kind = "ribcage",
			angle = 338,
			radius = 58,
			sign = "Bone Quarry",
			color = "FlameOrange",
			level = "",
		}),
	}),
	BRAZIER = table.freeze({
		id = "CrimsonBrazier",
		angle = 20,
		radius = 32,
		color = "FlameCrimson",
	}),
	SKY_STAR_COUNT = 3000,
	SKY_STAR_COUNT_LOW = 300,
	SKY_SUN_ANGULAR_SIZE = 0,
	SKY_MOON_ANGULAR_SIZE = 11,
	SKY_CELESTIAL_BODIES_SHOWN = true,
	SKYBOX_FACE = table.freeze({
		bk = "rbxasset://textures/sky/sky512_bk.tex",
		dn = "rbxasset://textures/sky/sky512_dn.tex",
		ft = "rbxasset://textures/sky/sky512_ft.tex",
		lf = "rbxasset://textures/sky/sky512_lf.tex",
		rt = "rbxasset://textures/sky/sky512_rt.tex",
		up = "rbxasset://textures/sky/sky512_up.tex",
	}),
	-- Muted occult grade over the built-in sky512 cubemap. Not a bright violet.
	SKY_AMBIENT = "3E2C4A",
	SKY_OUTDOOR_AMBIENT = "62466C",
	SKY_COLOR_SHIFT_TOP = "241030",
	SKY_ATMOSPHERE_COLOR = "604A6E",
	SKY_ATMOSPHERE_DECAY = "241430",
	SKY_ATMOSPHERE_DENSITY = 0.16,
	SKY_ATMOSPHERE_HAZE = 0.22,
	SKY_ATMOSPHERE_GLARE = 0,
	SKY_GRADE_SATURATION = 0.02,
	SKY_GRADE_TINT = "E4DCE8",
}

function TownLook.bloomEnabled(level: number, authored: boolean): boolean
	if level >= 1 and level <= TownLook.LOW_QUALITY_MAX then
		return false
	end
	return authored
end

function TownLook.flameTierEnabled(tier: string, level: number): boolean
	if tier == "extra" and level >= 1 and level <= TownLook.LOW_QUALITY_MAX then
		return false
	end
	return true
end

function TownLook.starCount(level: number): number
	if level >= 1 and level <= TownLook.LOW_QUALITY_MAX then
		return TownLook.SKY_STAR_COUNT_LOW
	end
	return TownLook.SKY_STAR_COUNT
end

return table.freeze(TownLook)
