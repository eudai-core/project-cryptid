--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

-- Walk from this module. Waiting on a service for the kit name hangs: this file
-- is nested under TownKits, so shared modules are reached through script.Parent.
local function sharedRoot(): any
	local dataModel = script.Parent.Parent.Parent
	return dataModel:WaitForChild("ReplicatedStorage"):WaitForChild("Shared")
end

local Kit = import("./Kit", function()
	return script.Parent:WaitForChild("Kit")
end)
local TownLook = import("../../shared/Config/TownLook", function()
	return sharedRoot():WaitForChild("Config"):WaitForChild("TownLook")
end) :: any
local UITheme = import("../../shared/UITheme", function()
	return sharedRoot():WaitForChild("UITheme")
end) :: any

local TarotTent = {}

local MODEL_NAME = "VeilAndFate"
local WOOD = UITheme.materials.wood
local BONE = UITheme.materials.candle
local STONE = UITheme.materials.altar
local METAL = UITheme.materials.iron
local CLOTH = UITheme.materials.cloth
local GLASS = UITheme.materials.glass
local NEON = UITheme.materials.neon

local BLOCKOUT = {
	Pole = true,
	Roof = true,
	Drape = true,
	Rug = true,
	EyeSigil = true,
	Eye = true,
	Pupil = true,
}

-- Local -Z faces the plaza. The peaked wedges keep their thin edge on -Z.
local SIGN_LOCAL = CFrame.new(0, 9.6, -5.35)
local FLAME_LOCAL = CFrame.new(-3.15, 0.32, -4.85)
local CORNER_POLES = {
	Vector3.new(-3.9, 3.4, -3.35),
	Vector3.new(3.9, 3.4, -3.35),
	Vector3.new(-3.9, 3.4, 3.15),
	Vector3.new(3.9, 3.4, 3.15),
}
local SCALLOP_X = { -3.15, -2.15, -1.15, 1.15, 2.15, 3.15 }
local CARDS = {
	{ x = -2.45, yaw = 28, roll = -12 },
	{ x = -1.75, yaw = 8, roll = -4 },
	{ x = -1.1, yaw = -12, roll = 6 },
}

local function distance(a: any, b: any): number
	local dx = a.X - b.X
	local dy = a.Y - b.Y
	local dz = a.Z - b.Z
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function findNamed(root: Instance, name: string, className: string?): any
	if root.Name == name and (className == nil or root.ClassName == className) then
		return root
	end
	for _, inst in root:GetDescendants() do
		if inst.Name == name and (className == nil or inst.ClassName == className) then
			return inst
		end
	end
	return nil
end

local function place(parent: Instance, pivot: any, spec: any): any
	spec.cf = pivot * spec.cf
	spec.parent = parent
	return Kit.spawn(spec)
end

local function cylinderBetween(
	parent: Instance,
	pivot: any,
	name: string,
	a: any,
	b: any,
	diameter: number,
	material: string,
	color: string,
	decor: boolean,
	shadow: boolean
)
	local length = math.max(distance(a, b), 0.05)
	local mid = Vector3.new((a.X + b.X) * 0.5, (a.Y + b.Y) * 0.5, (a.Z + b.Z) * 0.5)
	local cf = CFrame.lookAt(mid, b) * CFrame.Angles(0, math.rad(90), 0)
	place(parent, pivot, {
		name = name,
		size = Vector3.new(length, diameter, diameter),
		cf = cf,
		material = material,
		color = color,
		decor = decor,
		shadow = shadow,
		shape = Enum.PartType.Cylinder,
	})
end

local function upright(at: any): any
	return CFrame.new(at) * CFrame.Angles(0, 0, math.rad(90))
end

local function addGlow(parent: Instance, name: string, range: number, brightness: number, token: string)
	local light = Instance.new("PointLight")
	light.Name = name
	light.Color = UITheme.color(token)
	light.Range = range
	light.Brightness = brightness
	light.Shadows = false
	light.Parent = parent
end

local function addLife(parent: Instance, name: string, spec: any, token: string)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = name
	emitter.Rate = spec.rate
	emitter.Lifetime = NumberRange.new(spec.life, spec.life)
	emitter.Speed = NumberRange.new(spec.speed * 0.5, spec.speed)
	emitter.SpreadAngle = Vector2.new(spec.spread, spec.spread)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-12, 12)
	emitter.Acceleration = Vector3.new(0, TownLook.TAROT_VFX.lift, 0)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.LightInfluence = 0
	emitter.Color = ColorSequence.new(UITheme.color(token))
	emitter.Size = NumberSequence.new(spec.size)
	emitter.Transparency = NumberSequence.new(0.42)
	emitter.Enabled = true
	emitter:SetAttribute("TownEffect", "TarotLife")
	emitter:SetAttribute("TownFlame", "extra")
	emitter.Parent = parent
end

local function moveTo(anchor: any, desired: any, parts: { any })
	if anchor == nil then
		return
	end
	local delta = desired * anchor.CFrame:Inverse()
	for _, piece in parts do
		if piece.CFrame ~= nil then
			piece.CFrame = delta * piece.CFrame
		end
	end
end

local function buildFrame(parent: Instance, pivot: any)
	place(parent, pivot, {
		name = "CentrePole",
		size = Vector3.new(10.3, 0.48, 0.48),
		cf = upright(Vector3.new(0, 5.35, 0.05)),
		material = WOOD,
		color = "Bark",
		shadow = true,
		shape = Enum.PartType.Cylinder,
	})
	for _, at in CORNER_POLES do
		place(parent, pivot, {
			name = "CornerPole",
			size = Vector3.new(6.4, 0.36, 0.36),
			cf = upright(at),
			material = WOOD,
			color = "Bark",
			shadow = true,
			shape = Enum.PartType.Cylinder,
		})
	end
	place(parent, pivot, {
		name = "Ridge",
		size = Vector3.new(8.0, 0.32, 0.32),
		cf = CFrame.new(0, 11.15, 0),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = true,
		shape = Enum.PartType.Cylinder,
	})
end

local function buildRoof(parent: Instance, pivot: any)
	place(parent, pivot, {
		className = "WedgePart",
		name = "RoofFront",
		size = Vector3.new(8.2, 5.0, 3.6),
		cf = CFrame.new(0, 8.7, -1.8),
		material = CLOTH,
		color = "TentCloth",
		shadow = true,
	})
	place(parent, pivot, {
		className = "WedgePart",
		name = "RoofBack",
		size = Vector3.new(8.2, 5.0, 3.5),
		cf = CFrame.new(0, 8.7, 1.75) * CFrame.Angles(0, math.rad(180), 0),
		material = CLOTH,
		color = "TentCloth",
		shadow = true,
	})
	place(parent, pivot, {
		className = "WedgePart",
		name = "RoofLiner",
		size = Vector3.new(7.2, 4.2, 3.1),
		cf = CFrame.new(0, 8.15, -1.95),
		material = CLOTH,
		color = "NightSky",
		decor = true,
		shadow = false,
	})
	for _, side in { -1, 1 } do
		local yaw = if side > 0 then math.rad(90) else math.rad(-90)
		place(parent, pivot, {
			className = "WedgePart",
			name = "SideGore",
			size = Vector3.new(3.4, 2.6, 2.2),
			cf = CFrame.new(side * 2.4, 8.2, -1.4) * CFrame.Angles(0, yaw, 0),
			material = CLOTH,
			color = "TentCloth",
			decor = true,
			shadow = true,
		})
	end
end

local function buildCloth(parent: Instance, pivot: any)
	for _, side in { -1, 1 } do
		place(parent, pivot, {
			name = "SideWall",
			size = Vector3.new(0.2, 6.15, 6.3),
			cf = CFrame.new(side * 4.05, 3.25, -0.1) * CFrame.Angles(0, 0, math.rad(side * 2)),
			material = CLOTH,
			color = "TentCloth",
			shadow = true,
		})
		place(parent, pivot, {
			name = "SideFold",
			size = Vector3.new(5.6, 1.25, 1.25),
			cf = CFrame.new(side * 3.55, 3.05, -0.15) * CFrame.Angles(0, math.rad(90), 0),
			material = CLOTH,
			color = "TentCloth",
			decor = true,
			shadow = true,
			shape = Enum.PartType.Cylinder,
		})
		place(parent, pivot, {
			name = "InnerDrape",
			size = Vector3.new(0.12, 4.6, 4.8),
			cf = CFrame.new(side * 3.72, 3.0, -0.15),
			material = CLOTH,
			color = "NightSky",
			decor = true,
			shadow = false,
		})
	end
	place(parent, pivot, {
		name = "BackWall",
		size = Vector3.new(7.7, 6.1, 0.18),
		cf = CFrame.new(0, 3.22, 3.28),
		material = CLOTH,
		color = "TentCloth",
		shadow = true,
	})
end

local function buildMouth(parent: Instance, pivot: any): any
	place(parent, pivot, {
		name = "Flap",
		size = Vector3.new(2.05, 5.05, 0.14),
		cf = CFrame.new(-2.55, 3.05, -3.38) * CFrame.Angles(0, math.rad(34), math.rad(-6)),
		material = CLOTH,
		color = "TentCloth",
		decor = true,
		shadow = true,
	})
	place(parent, pivot, {
		name = "Flap",
		size = Vector3.new(2.05, 5.05, 0.14),
		cf = CFrame.new(2.55, 3.05, -3.38) * CFrame.Angles(0, math.rad(-34), math.rad(6)),
		material = CLOTH,
		color = "TentCloth",
		decor = true,
		shadow = true,
	})
	place(parent, pivot, {
		name = "Valance",
		size = Vector3.new(5.4, 0.72, 0.16),
		cf = CFrame.new(0, 6.05, -3.5),
		material = CLOTH,
		color = "Blood",
		decor = true,
		shadow = true,
	})
	for _, side in { -1, 1 } do
		place(parent, pivot, {
			name = "DoorPost",
			size = Vector3.new(0.34, 5.35, 0.34),
			cf = CFrame.new(side * 2.35, 2.8, -3.42),
			material = WOOD,
			color = "Bark",
			shadow = true,
		})
	end
	place(parent, pivot, {
		name = "Lintel",
		size = Vector3.new(5.1, 0.28, 0.34),
		cf = CFrame.new(0, 5.62, -3.42),
		material = WOOD,
		color = "Bark",
		decor = true,
		shadow = true,
	})
	local sill = place(parent, pivot, {
		name = "DoorAnchor",
		size = Vector3.new(2.7, 0.22, 1.15),
		cf = CFrame.new(0, 0.16, -3.9),
		material = STONE,
		color = "Stone",
		shadow = true,
	})
	sill:SetAttribute("TownAnchor", "Door")
	cylinderBetween(
		parent,
		pivot,
		"Tie",
		Vector3.new(-3.35, 3.7, -3.28),
		Vector3.new(-3.85, 4.55, -3.32),
		0.07,
		METAL,
		"Gold",
		true,
		false
	)
	cylinderBetween(
		parent,
		pivot,
		"Tie",
		Vector3.new(3.35, 3.7, -3.28),
		Vector3.new(3.85, 4.55, -3.32),
		0.07,
		METAL,
		"Gold",
		true,
		false
	)
	return sill
end

local function buildSigil(parent: Instance, pivot: any)
	place(parent, pivot, {
		name = "EyeRing",
		size = Vector3.new(0.12, 2.05, 2.05),
		cf = CFrame.new(0, 7.85, -2.48) * CFrame.Angles(0, math.rad(90), 0),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	local eye = place(parent, pivot, {
		name = "Eye",
		size = Vector3.new(0.16, 1.45, 1.45),
		cf = CFrame.new(0, 7.85, -2.62) * CFrame.Angles(0, math.rad(90), 0),
		material = NEON,
		color = "TentCloth",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
		neonRole = "eye",
	})
	place(parent, pivot, {
		name = "Pupil",
		size = Vector3.new(0.42, 0.48, 0.42),
		cf = CFrame.new(0, 7.85, -2.74),
		material = BONE,
		color = "Void",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
	})
	local eyeGlow = TownLook.TAROT_LIGHT.eye
	addGlow(eye, "EyeGlow", eyeGlow.range, eyeGlow.brightness, "TentCloth")
	place(parent, pivot, {
		name = "Lantern",
		size = Vector3.new(0.72, 0.48, 0.48),
		cf = upright(Vector3.new(0.15, 4.7, -1.7)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	local wick = place(parent, pivot, {
		name = "Wick",
		size = Vector3.new(0.28, 0.28, 0.28),
		cf = CFrame.new(0.15, 4.7, -1.7),
		material = BONE,
		color = "Bone",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
	})
	local lanternGlow = TownLook.TAROT_LIGHT.lantern
	addGlow(wick, "LanternGlow", lanternGlow.range, lanternGlow.brightness, "Gold")
	place(parent, pivot, {
		name = "Finial",
		size = Vector3.new(0.7, 0.7, 0.7),
		cf = CFrame.new(0, 11.62, 0),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = true,
		shape = Enum.PartType.Ball,
	})
	place(parent, pivot, {
		name = "FinialSpike",
		size = Vector3.new(0.7, 0.14, 0.14),
		cf = upright(Vector3.new(0, 12.15, 0)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	place(parent, pivot, {
		name = "GroundRug",
		size = Vector3.new(6.2, 0.08, 5.5),
		cf = CFrame.new(0, 0.06, -0.15),
		material = CLOTH,
		color = "NightSky",
		decor = true,
		shadow = false,
	})
	place(parent, pivot, {
		name = "Mat",
		size = Vector3.new(2.4, 0.05, 1.7),
		cf = CFrame.new(0, 0.05, -4.5),
		material = CLOTH,
		color = "Blood",
		decor = true,
		shadow = false,
	})
end

local function buildDetail(parent: Instance, pivot: any)
	for _, x in SCALLOP_X do
		place(parent, pivot, {
			className = "WedgePart",
			name = "Scallop",
			size = Vector3.new(0.82, 0.2, 0.64),
			cf = CFrame.new(x, 5.85, -3.72) * CFrame.Angles(math.rad(-90), 0, 0),
			material = CLOTH,
			color = "Blood",
			decor = true,
			shadow = false,
		})
		place(parent, pivot, {
			name = "Tassel",
			size = Vector3.new(1.15, 0.06, 0.06),
			cf = upright(Vector3.new(x, 4.95, -3.78)),
			material = CLOTH,
			color = "Gold",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
		place(parent, pivot, {
			name = "TasselDrop",
			size = Vector3.new(0.16, 0.16, 0.16),
			cf = CFrame.new(x, 4.28, -3.78),
			material = METAL,
			color = "Gold",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Ball,
		})
	end
	for _, card in CARDS do
		local cf = CFrame.new(card.x, 4.15, -2.9) * CFrame.Angles(0, math.rad(card.yaw), math.rad(card.roll))
		place(parent, pivot, {
			name = "Card",
			size = Vector3.new(0.72, 1.15, 0.06),
			cf = cf,
			material = BONE,
			color = "Bone",
			decor = true,
			shadow = false,
		})
		place(parent, pivot, {
			name = "CardMark",
			size = Vector3.new(0.28, 0.4, 0.04),
			cf = cf * CFrame.new(0, 0.12, -0.05),
			material = BONE,
			color = "Blood",
			decor = true,
			shadow = false,
		})
	end
	place(parent, pivot, {
		name = "Crystal",
		size = Vector3.new(1.05, 1.05, 1.05),
		cf = CFrame.new(1.25, 1.4, -0.7),
		material = GLASS,
		color = "Bone",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
	})
	local core = place(parent, pivot, {
		name = "CrystalCore",
		size = Vector3.new(0.38, 0.38, 0.38),
		cf = CFrame.new(1.25, 1.4, -0.82),
		material = GLASS,
		color = "Rift",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
	})
	place(parent, pivot, {
		name = "CrystalStand",
		size = Vector3.new(0.7, 0.5, 0.5),
		cf = upright(Vector3.new(1.25, 0.72, -0.7)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	place(parent, pivot, {
		name = "CrystalFoot",
		size = Vector3.new(0.12, 0.95, 0.95),
		cf = upright(Vector3.new(1.25, 0.28, -0.7)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	local crystalGlow = TownLook.TAROT_LIGHT.crystal
	addGlow(core, "CrystalGlow", crystalGlow.range, crystalGlow.brightness, "Rift")
	for _, side in { -1, 1 } do
		place(parent, pivot, {
			name = "Sconce",
			size = Vector3.new(0.55, 0.36, 0.36),
			cf = upright(Vector3.new(side * 3.45, 4.55, -3.15)),
			material = METAL,
			color = "Gold",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
		local sconceWick = place(parent, pivot, {
			name = "SconceWick",
			size = Vector3.new(0.18, 0.18, 0.18),
			cf = CFrame.new(side * 3.45, 4.55, -3.15),
			material = BONE,
			color = "Bone",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Ball,
		})
		local sconceGlow = TownLook.TAROT_LIGHT.sconce
		addGlow(sconceWick, "SconceGlow", sconceGlow.range, sconceGlow.brightness, "Gold")
	end
	place(parent, pivot, {
		name = "Moon",
		size = Vector3.new(0.1, 1.15, 1.15),
		cf = CFrame.new(4.22, 3.7, 0.35),
		material = BONE,
		color = "Bone",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	place(parent, pivot, {
		name = "MoonShade",
		size = Vector3.new(0.1, 0.9, 0.9),
		cf = CFrame.new(4.28, 3.98, 0.55),
		material = BONE,
		color = "Void",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	for _, x in { -2.6, 0, 2.6 } do
		place(parent, pivot, {
			name = "Charm",
			size = Vector3.new(0.06, 0.32, 0.32),
			cf = CFrame.new(x, 5.35, -3.62) * CFrame.Angles(0, math.rad(90), 0),
			material = METAL,
			color = "Gold",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
	end
	for index = 1, 4 do
		place(parent, pivot, {
			name = "Bead",
			size = Vector3.new(0.16, 0.16, 0.16),
			cf = CFrame.new(-3.35, 1.6 + index * 0.28, -2.55),
			material = BONE,
			color = "Bone",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Ball,
		})
	end
	cylinderBetween(
		parent,
		pivot,
		"Wishbone",
		Vector3.new(2.15, 0.85, -2.15),
		Vector3.new(2.45, 0.35, -2.35),
		0.08,
		BONE,
		"Bone",
		true,
		false
	)
	cylinderBetween(
		parent,
		pivot,
		"Wishbone",
		Vector3.new(2.15, 0.85, -2.15),
		Vector3.new(1.85, 0.35, -2.35),
		0.08,
		BONE,
		"Bone",
		true,
		false
	)
	for _, at in CORNER_POLES do
		place(parent, pivot, {
			name = "PoleCap",
			size = Vector3.new(0.28, 0.28, 0.28),
			cf = CFrame.new(at.X, 6.72, at.Z),
			material = METAL,
			color = "Gold",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Ball,
		})
	end
	place(parent, pivot, {
		name = "RidgeBand",
		size = Vector3.new(6.2, 0.08, 0.22),
		cf = CFrame.new(0, 11.32, 0),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
	})
	for _, side in { -1, 1 } do
		place(parent, pivot, {
			name = "Hem",
			size = Vector3.new(6.0, 0.16, 0.16),
			cf = CFrame.new(side * 4.08, 6.28, -0.1) * CFrame.Angles(0, math.rad(90), 0),
			material = CLOTH,
			color = "Blood",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
	end
	local burner = place(parent, pivot, {
		name = "Incense",
		size = Vector3.new(0.65, 0.22, 0.65),
		cf = CFrame.new(-1.4, 0.32, -1.45),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
	})
	local vfx = TownLook.TAROT_VFX
	addLife(burner, "IncenseSmoke", vfx.incense, "Bone")
	local wick = findNamed(parent, "Wick", "Part")
	if wick ~= nil then
		addLife(wick, "MoteDrift", vfx.mote, "Gold")
	end
end

local function lightFlames(model: Instance)
	local glow = TownLook.TAROT_LIGHT.flame
	for _, inst in model:GetDescendants() do
		if inst.Name == "Flame" and inst.ClassName == "Part" and inst:GetAttribute(Kit.PART_ATTRIBUTE) ~= true then
			addGlow(inst, "FlameGlow", glow.range, glow.brightness, "Gold")
		end
	end
end

local function repositionKept(model: Instance, pivot: any)
	local sign = findNamed(model, "Sign", "Part")
	local signParts = {}
	if sign ~= nil then
		table.insert(signParts, sign)
	end
	local trim = findNamed(model, "SignTrim", "Part")
	if trim ~= nil then
		table.insert(signParts, trim)
	end
	moveTo(sign, pivot * SIGN_LOCAL, signParts)

	local bowl = findNamed(model, "Bowl", "Part")
	local flameParts = {}
	for _, name in { "Bowl", "Flame", "FlameHost" } do
		local piece = findNamed(model, name, "Part")
		if piece ~= nil and piece:GetAttribute(Kit.PART_ATTRIBUTE) ~= true then
			table.insert(flameParts, piece)
		end
	end
	moveTo(bowl, pivot * FLAME_LOCAL, flameParts)
end

local function quietLights(model: Instance)
	for _, inst in model:GetDescendants() do
		local className = inst.ClassName
		if className == "PointLight" or className == "SpotLight" or className == "SurfaceLight" then
			inst.Shadows = false
		end
	end
end

function TarotTent.replace(townFolder: Instance, refs: any): any
	local model = findNamed(townFolder, MODEL_NAME, "Model")
	if model == nil or model:GetAttribute("TownKit") == "TarotTent" then
		return nil
	end
	local level = Kit.resolveQuality(refs)
	local detail = Kit.detailEnabled(level)
	local beforeParts = Kit.countParts(model)
	local beforeLights = Kit.countLights(model)
	local beforeEmitters = Kit.countEmitters(model)

	local prompts = {}
	local spawns = {}
	for _, inst in model:GetDescendants() do
		if inst.ClassName == "ProximityPrompt" then
			table.insert(prompts, inst)
		elseif inst.ClassName == "SpawnLocation" then
			table.insert(spawns, inst)
		end
	end
	for _, prompt in prompts do
		prompt.Parent = model
	end
	for _, spawn in spawns do
		spawn.Parent = model
	end

	local root = model.PrimaryPart or findNamed(model, "Root", "Part")
	local doomed = {}
	for _, inst in model:GetDescendants() do
		if inst ~= root and BLOCKOUT[inst.Name] == true and inst:GetAttribute(Kit.PART_ATTRIBUTE) ~= true then
			local className = inst.ClassName
			if
				className == "Part"
				or className == "WedgePart"
				or className == "MeshPart"
				or className == "UnionOperation"
			then
				table.insert(doomed, inst)
			end
		end
	end
	for _, inst in doomed do
		inst:Destroy()
	end

	local pivot = if root ~= nil and root.CFrame ~= nil then root.CFrame else CFrame.new()
	local folder = Instance.new("Folder")
	folder.Name = "Tent"
	folder.Parent = model

	buildFrame(folder, pivot)
	buildRoof(folder, pivot)
	buildCloth(folder, pivot)
	local anchor = buildMouth(folder, pivot)
	buildSigil(folder, pivot)
	if detail then
		buildDetail(folder, pivot)
	end
	repositionKept(model, pivot)
	lightFlames(model)
	quietLights(model)

	for _, prompt in prompts do
		prompt.Parent = if anchor ~= nil then anchor else model
	end

	local afterParts = Kit.countParts(model)
	local afterLights = Kit.countLights(model)
	local afterEmitters = Kit.countEmitters(model)
	model:SetAttribute("TownKit", "TarotTent")
	model:SetAttribute("KitQuality", level)
	model:SetAttribute("KitDetail", detail)
	model:SetAttribute("KitBeforeParts", beforeParts)
	model:SetAttribute("KitAfterParts", afterParts)
	model:SetAttribute("KitBeforeLights", beforeLights)
	model:SetAttribute("KitAfterLights", afterLights)
	model:SetAttribute("KitBeforeEmitters", beforeEmitters)
	model:SetAttribute("KitAfterEmitters", afterEmitters)
	return {
		id = MODEL_NAME,
		quality = level,
		detail = detail,
		beforeParts = beforeParts,
		afterParts = afterParts,
		beforeLights = beforeLights,
		afterLights = afterLights,
		beforeEmitters = beforeEmitters,
		afterEmitters = afterEmitters,
	}
end

return TarotTent
