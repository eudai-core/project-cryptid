--!strict

local TownLook = {
	-- Runaway sanity guards only. There is no part, light, or emitter budget; do not thin a building to stay under them.
	PART_CAP = 20000,
	LIGHT_CAP = 200,
	EMITTER_CAP = 200,
	-- Per-effect weight. Not a town-wide emitter cap.
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
	APOTHECARY_LIGHT = table.freeze({
		eye = table.freeze({ range = 14, brightness = 0.8 }),
		flame = table.freeze({ range = 9, brightness = 0.5 }),
		rune = table.freeze({ range = 5, brightness = 0.28 }),
		lantern = table.freeze({ range = 7, brightness = 0.4 }),
	}),
	APOTHECARY_VFX = table.freeze({
		lift = 0.45,
		spore = table.freeze({ rate = 4, life = 2.4, speed = 0.45, size = 0.38, spread = 30 }),
		firefly = table.freeze({ rate = 3, life = 2.2, speed = 0.75, size = 0.16, spread = 46 }),
		steam = table.freeze({ rate = 6, life = 1.5, speed = 1.05, size = 0.48, spread = 16 }),
	}),
	TAROT_LIGHT = table.freeze({
		eye = table.freeze({ range = 7, brightness = 0.35 }),
		lantern = table.freeze({ range = 14, brightness = 0.62 }),
		flame = table.freeze({ range = 8, brightness = 0.38 }),
		crystal = table.freeze({ range = 6, brightness = 0.32 }),
		sconce = table.freeze({ range = 6, brightness = 0.28 }),
	}),
	TAROT_VFX = table.freeze({
		lift = 0.35,
		incense = table.freeze({ rate = 5, life = 2.4, speed = 0.5, size = 0.55, spread = 12 }),
		mote = table.freeze({ rate = 4, life = 2.6, speed = 0.35, size = 0.14, spread = 36 }),
	}),
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
	-- Low cover over the muted violet night. Not a storm, and not a voxel map.
	CLOUD_COVER = 0.5,
	CLOUD_DENSITY = 0.4,
	CLOUD_COLOR = "604A6E",
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
