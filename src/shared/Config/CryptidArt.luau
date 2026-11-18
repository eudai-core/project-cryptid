--!strict

local DEFAULT_FAMILY = "beast"

local FAMILY_OF: { [string]: string } = {
	mothman_hatchling = "winged",
	fresno_nightcrawler = "lurker",
	hidebehind = "lurker",
	hodag = "beast",
	jackalope = "beast",
	dover_demon = "lurker",
	snallygaster = "winged",
	loveland_frogman = "lurker",
	flatwoods_monster = "lurker",
	beast_of_bray_road = "beast",
	jersey_devil = "winged",
	loch_ness_serpent = "serpent",
	uncommon_01 = "beast",
	uncommon_02 = "lurker",
	rare_01 = "beast",
	rare_02 = "beast",
	epic_01 = "winged",
	epic_02 = "serpent",
	legendary_01 = "beast",
	legendary_02 = "serpent",
	mythic_01 = "winged",
	mythic_02 = "serpent",
}

local function piece(
	name: string,
	sx: number,
	sy: number,
	sz: number,
	x: number,
	y: number,
	z: number,
	color: string?,
	material: string,
	shape: string,
	useRarity: boolean
)
	return table.freeze({
		name = name,
		sx = sx,
		sy = sy,
		sz = sz,
		x = x,
		y = y,
		z = z,
		color = color,
		material = material,
		shape = shape,
		useRarity = useRarity,
	})
end

local function rootPiece()
	return piece("Root", 1, 0.2, 1, 0, 0.1, 0, "Ash", "Fabric", "Block", false)
end

local function bandPiece()
	return piece("RarityBand", 1.15, 0.16, 0.22, 0, 1.15, -0.45, nil, "Fabric", "Block", true)
end

local function silhouette(parts: { any })
	local list = { rootPiece() }
	for _, item in parts do
		table.insert(list, item)
	end
	table.insert(list, bandPiece())
	return table.freeze(list)
end

local CryptidArt = {
	unknownId = "unknown",
	defaultFamily = DEFAULT_FAMILY,
	defaultRarity = "Common",
	defaultColor = "BoneDim",
	faceGateYaw = math.pi,
	billboardMargin = 2,
	mountName = "CryptidMount",
	fallbackModelName = "CryptidPlaceholder",
	shadowVolume = 1,
	folders = table.freeze({
		assets = "Assets",
		cryptids = "Cryptids",
		lair = "Lair",
		placeholders = "Placeholders",
	}),
	models = table.freeze({
		pad = "Pad",
		altar = "BoneAltar",
	}),
	attr = table.freeze({
		cryptidId = "CryptidId",
		placeholder = "IsPlaceholder",
		state = "State",
		tier = "Tier",
		speciesId = "SpeciesId",
	}),
	states = table.freeze({
		occupied = "Occupied",
		empty = "Empty",
		locked = "Locked",
		sealed = "Sealed",
		affordable = "Affordable",
	}),
	families = table.freeze({
		"winged",
		"lurker",
		"beast",
		"serpent",
	}),
	assetDirs = table.freeze({
		"assets/cryptids",
		"assets/lair",
		"assets/placeholders",
	}),
	bodies = table.freeze({
		winged = silhouette({
			piece("Body", 1.1, 1.3, 0.9, 0, 1.05, 0, "Soot", "Slate", "Block", false),
			piece("Head", 0.75, 0.75, 0.75, 0, 1.9, -0.35, "Soot", "Slate", "Ball", false),
			piece("Wing_R", 0.18, 1.5, 2.2, 1.35, 1.45, 0.15, "Ash", "Fabric", "Block", false),
			piece("Wing_L", 0.18, 1.5, 2.2, -1.35, 1.45, 0.15, "Ash", "Fabric", "Block", false),
		}),
		lurker = silhouette({
			piece("Torso", 0.7, 3.1, 0.65, 0, 2.15, 0, "Soot", "Slate", "Block", false),
			piece("Head", 0.7, 0.7, 0.7, 0, 3.85, -0.2, "Ash", "Slate", "Ball", false),
			piece("Arm_R", 0.22, 2.3, 0.22, 0.6, 1.9, -0.15, "Soot", "Basalt", "Block", false),
			piece("Arm_L", 0.22, 2.3, 0.22, -0.6, 1.9, -0.15, "Soot", "Basalt", "Block", false),
		}),
		beast = silhouette({
			piece("Body", 1.15, 0.95, 2.5, 0, 0.75, 0.1, "Soot", "Slate", "Block", false),
			piece("Head", 0.7, 0.7, 0.8, 0, 1.05, -1.25, "Ash", "Slate", "Ball", false),
			piece("Tail", 0.28, 0.28, 1.15, 0, 0.85, 1.5, "Soot", "Slate", "Block", false),
		}),
		serpent = silhouette({
			piece("BodyLow", 0.55, 0.5, 1.5, 0, 0.4, 0.7, "Soot", "Slate", "Block", false),
			piece("BodyMid", 0.5, 0.7, 1.15, 0, 0.95, -0.35, "Soot", "Slate", "Block", false),
			piece("Head", 0.7, 0.35, 0.85, 0, 1.5, -1.2, "Ash", "Slate", "Block", false),
		}),
	}),
}

function CryptidArt.billboardStuds(topY: number, adorneeY: number): number
	local rise = topY - adorneeY
	if rise < 0 then
		rise = 0
	end
	return rise + CryptidArt.billboardMargin
end

function CryptidArt.familyOf(cryptidId: string): string
	local family = FAMILY_OF[cryptidId]
	if family == nil then
		return DEFAULT_FAMILY
	end
	return family
end

function CryptidArt.padState(sealed: boolean, occupied: boolean, locked: boolean): string
	if sealed then
		return CryptidArt.states.sealed
	end
	if occupied then
		return CryptidArt.states.occupied
	end
	if locked then
		return CryptidArt.states.locked
	end
	return CryptidArt.states.empty
end

function CryptidArt.affordableRim(state: string, canAfford: boolean): boolean
	return state == CryptidArt.states.locked and canAfford
end

function CryptidArt.tierShown(tier: number, level: number): boolean
	return level >= tier
end

function CryptidArt.mappedSpecies(): { string }
	local list = {}
	for id in FAMILY_OF do
		table.insert(list, id)
	end
	table.sort(list)
	return list
end

return CryptidArt
