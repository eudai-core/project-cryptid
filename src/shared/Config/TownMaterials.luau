--!strict
-- Hollowmere material and nature pass.
-- Palette hexes are the art-direction set: near-black, crimson, tarnished gold,
-- bone white, and the sickly greens already named in UITheme (RiftDim, Moss, Rift).
-- Empty MaterialVariants are created but not applied. A variant with a blank
-- ColorMap stays blank, and assigning it replaces the built-in material shader.
-- https://create.roblox.com/docs/parts/materials
-- https://create.roblox.com/docs/reference/engine/classes/MaterialVariant
-- https://create.roblox.com/docs/reference/engine/classes/BasePart

local function swatch(token: string, weight: number)
	return table.freeze({
		token = token,
		weight = weight,
	})
end

local VOID = "Void"
local BLOOD = "Blood"
local GOLD = "Gold"
local BONE = "Bone"
local SICKLY = "RiftDim"
local MOSS = "Moss"
local RIFT = "Rift"

local TownMaterials = {
	ORDER = 1000,
	-- Quality 1, 2, and 3 add no nature. 4 and above do.
	NATURE_MIN_QUALITY = 4,
	QUALITY_TOP = 10,
	APPLY_EMPTY_VARIANTS = false,
	NATURE_FOLDER = "MaterialNature",
	ROLE_ATTRIBUTE = "TownMaterialRole",
	NATURE_ATTRIBUTE = "TownNature",
	PASS_ATTRIBUTE = "TownMaterialPass",
	PEDLAR_TAGS = table.freeze({ "PedlarStall", "PedlarLantern" }),
	WELL_MODEL = "WeepingWell",
	TREE_PARTS = table.freeze({ Trunk = true, Bole = true, RootSpur = true }),
	DOOR_CLEARANCE = 6,
	PROMPT_CLEARANCE = 6,
	SIGN_CLEARANCE = 4,
	ROAD_MARGIN = 0.5,
	WELL_MARGIN = 6,
	PORTAL_MARGIN = 4,
	PORTAL_RING_MIN = 9,
	PORTAL_RING_MAX = 14,
	MOSS_LIFT = 0.08,
	MOSS_INSET = 1.4,
	IVY_GAP = 0.12,
	ROOT_LENGTH = 3.4,
	ROOT_DROP = 0.35,
	ROOT_TAPER = 0.28,
	REFLECT_JITTER = 0.012,
	REFLECT_MAX = 0.1,
	HASH_SEED = 2166136261,
	HASH_MUL = 16777619,
	RNG_MUL = 1664525,
	RNG_ADD = 1013904223,
	RNG_MOD = 4294967296,
	NATURE_SEED = 17011,
	POSITION_SCALE = 20,
	PLACE_ATTEMPTS = 8,
	MAX_NATURE_PARTS = 480,
	MOSS_ON_RIM = 18,
	MOSS_ON_STONE = 16,
	IVY_WALLS = 7,
	IVY_LINKS = 4,
	ROOTS_PER_TREE = 4,
	ROOT_SEGMENTS = 3,
	MUSHROOMS_PER_PORTAL = 3,
	VOID = VOID,
	BLOOD = BLOOD,
	GOLD = GOLD,
	BONE = BONE,
	SICKLY = SICKLY,
	MOSS = MOSS,
	RIFT = RIFT,
	NATURE_GREENS = table.freeze({ SICKLY, MOSS, VOID, RIFT }),
}

TownMaterials.VARIANTS = table.freeze({
	table.freeze({
		name = "AgedBrick",
		base = "Brick",
		studsPerTile = 4.5,
		reflectance = 0.02,
		open = table.freeze({
			swatch(VOID, 40),
			swatch(BLOOD, 40),
			swatch(GOLD, 12),
			swatch(SICKLY, 8),
		}),
		kit = table.freeze({
			swatch(VOID, 45),
			swatch(BLOOD, 40),
			swatch(GOLD, 15),
		}),
	}),
	table.freeze({
		name = "MossyCobble",
		base = "Cobblestone",
		studsPerTile = 6,
		reflectance = 0.012,
		open = table.freeze({
			swatch(VOID, 70),
			swatch(BLOOD, 8),
			swatch(GOLD, 10),
			swatch(SICKLY, 12),
		}),
		kit = table.freeze({
			swatch(VOID, 74),
			swatch(BLOOD, 10),
			swatch(GOLD, 16),
		}),
	}),
	table.freeze({
		name = "WornDarkTimber",
		base = "WoodPlanks",
		studsPerTile = 5,
		reflectance = 0.015,
		open = table.freeze({
			swatch(VOID, 62),
			swatch(BLOOD, 16),
			swatch(GOLD, 14),
			swatch(SICKLY, 8),
		}),
		kit = table.freeze({
			swatch(VOID, 64),
			swatch(BLOOD, 20),
			swatch(GOLD, 16),
		}),
	}),
	table.freeze({
		name = "SlateShingle",
		base = "Slate",
		studsPerTile = 3.5,
		reflectance = 0.04,
		open = table.freeze({
			swatch(VOID, 76),
			swatch(BLOOD, 6),
			swatch(GOLD, 12),
			swatch(SICKLY, 6),
		}),
		kit = table.freeze({
			swatch(VOID, 78),
			swatch(BLOOD, 8),
			swatch(GOLD, 14),
		}),
	}),
	table.freeze({
		name = "WeatheredStone",
		base = "Basalt",
		alternate = "Rock",
		studsPerTile = 5.5,
		reflectance = 0.028,
		open = table.freeze({
			swatch(VOID, 66),
			swatch(BLOOD, 8),
			swatch(GOLD, 14),
			swatch(SICKLY, 12),
		}),
		kit = table.freeze({
			swatch(VOID, 72),
			swatch(BLOOD, 10),
			swatch(GOLD, 18),
		}),
	}),
	table.freeze({
		name = "Bone",
		base = "Limestone",
		alternate = "Marble",
		studsPerTile = 4,
		reflectance = 0.06,
		open = table.freeze({
			swatch(BONE, 78),
			swatch(VOID, 8),
			swatch(GOLD, 8),
			swatch(SICKLY, 6),
		}),
		kit = table.freeze({
			swatch(BONE, 80),
			swatch(VOID, 10),
			swatch(GOLD, 10),
		}),
	}),
})

local byName = {}
for _, spec in TownMaterials.VARIANTS do
	byName[spec.name] = spec
end
TownMaterials.BY_NAME = table.freeze(byName)

return table.freeze(TownMaterials)
