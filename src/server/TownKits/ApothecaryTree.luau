--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Kit = import("./Kit", function()
	return script.Parent:WaitForChild("Kit")
end)
local TownLook = import("../../shared/Config/TownLook", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("TownLook")
end) :: any
local UITheme = import("../../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any

local ApothecaryTree = {}

local MODEL_NAME = "RuneheartApothecary"
local WOOD = UITheme.materials.wood
local BONE = UITheme.materials.candle
local STONE = UITheme.materials.altar
local METAL = UITheme.materials.iron
local GLASS = UITheme.materials.glass
local NEON = UITheme.materials.neon

local BLOCKOUT = {
	Trunk = true,
	Hollow = true,
	Root = true,
	Branch = true,
	Canopy = true,
	Rune = true,
	Eye = true,
	Pupil = true,
	Bottle = true,
}

-- Local -Z faces the plaza. The spine twists as it rises so the trunk is not a drum.
local SPINE = {
	Vector3.new(0, 1.4, 0.2),
	Vector3.new(0.55, 4.6, -0.25),
	Vector3.new(-0.5, 8, 0.35),
	Vector3.new(0.65, 11.4, -0.1),
	Vector3.new(-0.4, 14.8, 0.25),
	Vector3.new(0.3, 18, -0.05),
	Vector3.new(-0.15, 21, 0.15),
}
local GIRTH = { 6.4, 5.5, 4.7, 3.7, 2.7, 1.8, 1.05 }
local SEGMENT_NAME = { "Bole", "Bole", "Bole", "Twist", "Twist", "CrownTip" }
local SEGMENT_DECOR = { false, false, false, true, true, true }
local SEGMENT_COLOR = { "Bark", "ShipWood", "Bark", "Bark", "ShipWood", "Bark" }

local LIMBS = {
	{
		name = "Limb",
		a = Vector3.new(-0.4, 12.2, 0.05),
		b = Vector3.new(-8.6, 16.6, -1.5),
		diameter = 1.15,
		color = "Bark",
	},
	{
		name = "Limb",
		a = Vector3.new(0.55, 12.8, -0.05),
		b = Vector3.new(8.9, 17.2, 0.9),
		diameter = 1.2,
		color = "ShipWood",
	},
	{
		name = "Reach",
		a = Vector3.new(0.1, 15.6, 0.1),
		b = Vector3.new(1.6, 20.8, -6.4),
		diameter = 0.9,
		color = "Bark",
	},
	{
		name = "Limb",
		a = Vector3.new(-0.15, 15.0, 0.2),
		b = Vector3.new(-2.4, 18.6, 6.6),
		diameter = 0.95,
		color = "Bark",
	},
}

-- Roots spill sideways and back. The door approach (local -Z, near x = 0) stays open.
local ROOTS = {
	{ a = Vector3.new(-1.4, 0.7, 0.2), b = Vector3.new(-5.4, 0.28, 1.7), diameter = 1.15 },
	{ a = Vector3.new(1.5, 0.65, 0.1), b = Vector3.new(5.6, 0.26, 1.5), diameter = 1.2 },
	{ a = Vector3.new(-0.4, 0.55, 1.4), b = Vector3.new(-3.2, 0.22, 4.6), diameter = 0.95 },
	{ a = Vector3.new(0.6, 0.55, 1.2), b = Vector3.new(3.1, 0.22, 4.8), diameter = 1.0 },
	{ a = Vector3.new(-1.8, 0.8, -0.4), b = Vector3.new(-4.6, 0.3, -1.7), diameter = 0.85 },
	{ a = Vector3.new(1.9, 0.75, -0.3), b = Vector3.new(4.5, 0.28, -1.5), diameter = 0.8 },
}

local RUNE_MARKS = {
	{ y = 8.6, angle = -0.55 },
	{ y = 10.4, angle = 0.42 },
	{ y = 12.5, angle = -0.32 },
	{ y = 14.0, angle = 0.55 },
	{ y = 7.4, angle = 1.2 },
}

local KNOT_MARKS = {
	{ y = 5.4, angle = 1.05 },
	{ y = 8.2, angle = -1.35 },
	{ y = 11.2, angle = 1.7 },
	{ y = 14.4, angle = -1.05 },
}

local HANGS = {
	Vector3.new(-5.6, 14.2, -0.8),
	Vector3.new(-7.2, 15.6, -1.2),
	Vector3.new(6.0, 14.6, 0.4),
	Vector3.new(7.6, 16.0, 0.7),
}

local LANTERNS = {
	Vector3.new(-5.5, 11.5, -1.3),
	Vector3.new(5.9, 11.9, -0.3),
	Vector3.new(1.3, 18.5, -4.4),
}

local TUFTS = {
	{ at = Vector3.new(-8.2, 17.0, -1.6), size = 2.5 },
	{ at = Vector3.new(8.6, 17.6, 1.0), size = 2.7 },
	{ at = Vector3.new(1.8, 21.2, -6.0), size = 2.3 },
	{ at = Vector3.new(-2.6, 19.0, 6.2), size = 2.2 },
	{ at = Vector3.new(0.1, 21.6, 0.2), size = 2.4 },
}

local TWIGS = {
	{ a = Vector3.new(-8.0, 16.4, -1.4), b = Vector3.new(-10.2, 18.4, -2.6), diameter = 0.42 },
	{ a = Vector3.new(-7.4, 16.2, -1.2), b = Vector3.new(-8.8, 14.6, -3.2), diameter = 0.36 },
	{ a = Vector3.new(8.4, 16.9, 0.8), b = Vector3.new(10.6, 18.8, 2.0), diameter = 0.44 },
	{ a = Vector3.new(7.8, 16.6, 0.6), b = Vector3.new(9.2, 15.0, -0.8), diameter = 0.34 },
	{ a = Vector3.new(1.4, 20.2, -5.6), b = Vector3.new(3.2, 22.4, -7.4), diameter = 0.32 },
}

local SIGN_LOCAL = CFrame.new(0, 6.15, -4.55)
local FLAME_LOCAL = {
	CFrame.new(-3.3, 0.42, -4.7),
	CFrame.new(3.3, 0.42, -4.55),
}
local CROW_LOCAL = CFrame.new(6.6, 16.7, 0.6)

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

local function spineAt(y: number): (any, number)
	local chosen = 1
	if y > SPINE[1].Y then
		chosen = #SPINE - 1
		for index = 1, #SPINE - 2 do
			if y <= SPINE[index + 1].Y then
				chosen = index
				break
			end
		end
	end
	local low = SPINE[chosen]
	local high = SPINE[chosen + 1]
	local span = high.Y - low.Y
	local alpha = 0
	if span >= 1e-4 and y > low.Y then
		alpha = math.clamp((y - low.Y) / span, 0, 1)
	end
	local center = Vector3.new(
		low.X + (high.X - low.X) * alpha,
		low.Y + (high.Y - low.Y) * alpha,
		low.Z + (high.Z - low.Z) * alpha
	)
	local girth = GIRTH[chosen] + (GIRTH[chosen + 1] - GIRTH[chosen]) * alpha
	return center, girth / 2
end

local function outwardAt(y: number, angle: number, extra: number): any
	local center, radius = spineAt(y)
	local dir = Vector3.new(math.sin(angle), 0, -math.cos(angle))
	return center + dir * (radius + extra)
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

local function addLife(parent: Instance, name: string, spec: any)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = name
	emitter.Rate = spec.rate
	emitter.Lifetime = NumberRange.new(spec.life, spec.life)
	emitter.Speed = NumberRange.new(spec.speed * 0.5, spec.speed)
	emitter.SpreadAngle = Vector2.new(spec.spread, spec.spread)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-18, 18)
	emitter.Acceleration = Vector3.new(0, TownLook.APOTHECARY_VFX.lift, 0)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.LightInfluence = 0
	emitter.Color = ColorSequence.new(UITheme.color("Rift"))
	emitter.Size = NumberSequence.new(spec.size)
	emitter.Transparency = NumberSequence.new(0.35)
	emitter.Enabled = true
	emitter:SetAttribute("TownEffect", "ApothecaryLife")
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

local function localPoint(pivot: any, cf: any): any
	return pivot:Inverse() * cf.Position
end

local function buildTrunk(parent: Instance, pivot: any)
	for index = 1, #SEGMENT_NAME do
		local diameter = (GIRTH[index] + GIRTH[index + 1]) * 0.5
		cylinderBetween(
			parent,
			pivot,
			SEGMENT_NAME[index],
			SPINE[index],
			SPINE[index + 1],
			diameter,
			WOOD,
			SEGMENT_COLOR[index],
			SEGMENT_DECOR[index],
			true
		)
	end
	local span = 3.1
	local rise = 1.7
	local run = 2.15
	local peak = SPINE[#SPINE].Y + rise * 0.55
	for _, side in { -1, 1 } do
		local yaw = if side > 0 then math.rad(90) else math.rad(-90)
		place(parent, pivot, {
			className = "WedgePart",
			name = "Crown",
			size = Vector3.new(span, rise, run),
			cf = CFrame.new(0, peak, side * run / 2) * CFrame.Angles(0, yaw, 0),
			material = WOOD,
			color = "Bark",
			decor = true,
			shadow = true,
		})
	end
end

local function buildLimbs(parent: Instance, pivot: any)
	for _, limb in LIMBS do
		cylinderBetween(parent, pivot, limb.name, limb.a, limb.b, limb.diameter, WOOD, limb.color, true, true)
	end
end

local function buildRoots(parent: Instance, pivot: any)
	for _, spur in ROOTS do
		cylinderBetween(parent, pivot, "RootSpur", spur.a, spur.b, spur.diameter, WOOD, "Bark", true, true)
		place(parent, pivot, {
			name = "Knuckle",
			size = Vector3.new(spur.diameter * 1.35, spur.diameter * 1.15, spur.diameter * 1.35),
			cf = CFrame.new(spur.a),
			material = WOOD,
			color = "Bark",
			decor = true,
			shadow = true,
			shape = Enum.PartType.Ball,
		})
	end
end

local function buildDoor(parent: Instance, pivot: any): any
	local recessAt = outwardAt(2.05, 0, 0.08)
	local doorAt = outwardAt(2.05, 0, 0.42)
	place(parent, pivot, {
		name = "DoorRecess",
		size = Vector3.new(2.8, 3.75, 0.46),
		cf = CFrame.new(recessAt),
		material = BONE,
		color = "Void",
		decor = true,
		shadow = true,
	})
	local door = place(parent, pivot, {
		name = "Door",
		size = Vector3.new(2.15, 3.2, 0.28),
		cf = CFrame.new(doorAt),
		material = WOOD,
		color = "Bark",
		decor = true,
		shadow = true,
	})
	place(parent, pivot, {
		name = "Lintel",
		size = Vector3.new(3.15, 0.42, 0.4),
		cf = CFrame.new(outwardAt(3.85, 0, 0.36)),
		material = WOOD,
		color = "ShipWood",
		decor = true,
		shadow = true,
	})
	for _, angle in { -0.5, 0.5 } do
		place(parent, pivot, {
			name = "DoorPost",
			size = Vector3.new(0.42, 3.45, 0.42),
			cf = CFrame.new(outwardAt(2.05, angle, 0.32)),
			material = WOOD,
			color = "Bark",
			decor = true,
			shadow = true,
		})
	end
	local sill = place(parent, pivot, {
		name = "DoorAnchor",
		size = Vector3.new(2.4, 0.24, 1.15),
		cf = CFrame.new(0, 0.22, doorAt.Z - 0.95),
		material = STONE,
		color = "Stone",
	})
	sill:SetAttribute("TownAnchor", "Door")
	return door
end

local function buildEye(parent: Instance, pivot: any)
	local eyeAt = outwardAt(9.55, 0, 0.55)
	local pupilAt = outwardAt(9.55, 0, 1.25)
	local ringAt = outwardAt(9.55, 0, 0.16)
	place(parent, pivot, {
		name = "EyeRing",
		size = Vector3.new(0.28, 2.55, 2.55),
		cf = CFrame.new(ringAt) * CFrame.Angles(0, math.rad(90), 0),
		material = BONE,
		color = "Bone",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	local eye = place(parent, pivot, {
		name = "Eye",
		size = Vector3.new(1.8, 1.8, 1.8),
		cf = CFrame.new(eyeAt),
		material = NEON,
		color = "Rift",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
		neonRole = "eye",
	})
	place(parent, pivot, {
		name = "Pupil",
		size = Vector3.new(0.62, 0.72, 0.62),
		cf = CFrame.new(pupilAt),
		material = BONE,
		color = "Void",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
	})
	local glow = TownLook.APOTHECARY_LIGHT.eye
	addGlow(eye, "EyeGlow", glow.range, glow.brightness, "Rift")
end

local function buildDetail(parent: Instance, pivot: any, door: Instance)
	for _, mark in RUNE_MARKS do
		local at = outwardAt(mark.y, mark.angle, 0.16)
		local center = spineAt(mark.y)
		local rune = place(parent, pivot, {
			name = "Rune",
			size = Vector3.new(0.62, 1.25, 0.14),
			cf = CFrame.lookAt(at, Vector3.new(center.X, at.Y, center.Z)),
			material = NEON,
			color = "Rift",
			decor = true,
			shadow = false,
			neonRole = "rune",
		})
		local glow = TownLook.APOTHECARY_LIGHT.rune
		addGlow(rune, "RuneGlow", glow.range, glow.brightness, "Rift")
	end
	for _, mark in KNOT_MARKS do
		place(parent, pivot, {
			name = "Knot",
			size = Vector3.new(1.05, 0.9, 1.05),
			cf = CFrame.new(outwardAt(mark.y, mark.angle, 0.2)),
			material = WOOD,
			color = "Bark",
			decor = true,
			shadow = true,
			shape = Enum.PartType.Ball,
		})
	end
	local scarAt = outwardAt(10.6, -1.15, 0.1)
	local scarCenter = spineAt(10.6)
	place(parent, pivot, {
		name = "Scar",
		size = Vector3.new(0.22, 2.3, 0.16),
		cf = CFrame.lookAt(scarAt, Vector3.new(scarCenter.X, scarAt.Y, scarCenter.Z)),
		material = WOOD,
		color = "Blood",
		decor = true,
		shadow = false,
	})
	for _, at in HANGS do
		cylinderBetween(
			parent,
			pivot,
			"Cord",
			at + Vector3.new(0, 0.85, 0),
			at + Vector3.new(0, 0.15, 0),
			0.08,
			METAL,
			"Gold",
			true,
			false
		)
		place(parent, pivot, {
			name = "Bottle",
			size = Vector3.new(0.95, 0.42, 0.42),
			cf = CFrame.new(at) * CFrame.Angles(0, 0, math.rad(90)),
			material = GLASS,
			color = "Rift",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
	end
	local lanternGlow = TownLook.APOTHECARY_LIGHT.lantern
	for _, at in LANTERNS do
		place(parent, pivot, {
			name = "Lantern",
			size = Vector3.new(1.05, 0.55, 0.55),
			cf = CFrame.new(at) * CFrame.Angles(0, 0, math.rad(90)),
			material = METAL,
			color = "Gold",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
		local wick = place(parent, pivot, {
			name = "Wick",
			size = Vector3.new(0.28, 0.28, 0.28),
			cf = CFrame.new(at + Vector3.new(0, 0.1, 0)),
			material = GLASS,
			color = "Rift",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Ball,
		})
		addGlow(wick, "LanternGlow", lanternGlow.range, lanternGlow.brightness, "Rift")
	end
	for _, tuft in TUFTS do
		place(parent, pivot, {
			name = "Canopy",
			size = Vector3.new(tuft.size, tuft.size * 0.82, tuft.size * 0.9),
			cf = CFrame.new(tuft.at),
			material = BONE,
			color = "RiftDim",
			decor = true,
			shadow = true,
			shape = Enum.PartType.Ball,
		})
	end
	for _, twig in TWIGS do
		cylinderBetween(parent, pivot, "Twig", twig.a, twig.b, twig.diameter, WOOD, "Bark", true, true)
	end
	place(parent, pivot, {
		name = "DoorRing",
		size = Vector3.new(0.12, 0.46, 0.46),
		cf = CFrame.new(outwardAt(1.85, 0.28, 0.7)) * CFrame.Angles(0, math.rad(90), 0),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	local paneAt = outwardAt(19.4, 0, 0.22)
	place(parent, pivot, {
		name = "Pane",
		size = Vector3.new(0.72, 0.72, 0.12),
		cf = CFrame.new(paneAt) * CFrame.Angles(0, 0, math.rad(45)),
		material = NEON,
		color = "Rift",
		decor = true,
		shadow = false,
		neonRole = "rune",
	})
	local vfx = TownLook.APOTHECARY_VFX
	local crown = findNamed(parent, "CrownTip", "Part")
	if crown ~= nil then
		addLife(crown, "SporeDrift", vfx.spore)
	end
	local reach = findNamed(parent, "Reach", "Part")
	if reach ~= nil then
		addLife(reach, "Firefly", vfx.firefly)
	end
	addLife(door, "PotionSteam", vfx.steam)
end

local function lightFlames(model: Instance)
	local glow = TownLook.APOTHECARY_LIGHT.flame
	for _, inst in model:GetDescendants() do
		if inst.Name == "Flame" and inst.ClassName == "Part" and inst:GetAttribute(Kit.PART_ATTRIBUTE) ~= true then
			addGlow(inst, "FlameGlow", glow.range, glow.brightness, "FlameGreen")
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

	local bowls = {}
	local flames = {}
	local hosts = {}
	for _, inst in model:GetDescendants() do
		if inst.ClassName == "Part" and inst:GetAttribute(Kit.PART_ATTRIBUTE) ~= true then
			if inst.Name == "Bowl" then
				table.insert(bowls, inst)
			elseif inst.Name == "Flame" then
				table.insert(flames, inst)
			elseif inst.Name == "FlameHost" then
				table.insert(hosts, inst)
			end
		end
	end
	table.sort(bowls, function(a, b)
		return localPoint(pivot, a.CFrame).X < localPoint(pivot, b.CFrame).X
	end)
	local usedFlame = {}
	local usedHost = {}
	local function nearest(origin: any, pool: { any }, used: { [any]: boolean }): any
		local best = nil
		local bestDist = math.huge
		for _, piece in pool do
			if used[piece] ~= true and piece.CFrame ~= nil then
				local gap = distance(origin.CFrame.Position, piece.CFrame.Position)
				if gap < bestDist then
					best = piece
					bestDist = gap
				end
			end
		end
		return best
	end
	for index, bowl in bowls do
		local target = FLAME_LOCAL[index]
		if target ~= nil then
			local flame = nearest(bowl, flames, usedFlame)
			local host = nearest(bowl, hosts, usedHost)
			if flame ~= nil then
				usedFlame[flame] = true
			end
			if host ~= nil then
				usedHost[host] = true
			end
			local group = { bowl }
			if flame ~= nil then
				table.insert(group, flame)
			end
			if host ~= nil then
				table.insert(group, host)
			end
			moveTo(bowl, pivot * target, group)
		end
	end

	local crow = findNamed(model, "CrowBody", "Part")
	local crowParts = {}
	if crow ~= nil then
		table.insert(crowParts, crow)
	end
	local wing = findNamed(model, "CrowWing", "Part")
	if wing ~= nil then
		table.insert(crowParts, wing)
	end
	moveTo(crow, pivot * CROW_LOCAL, crowParts)
end

local function quietLights(model: Instance)
	for _, inst in model:GetDescendants() do
		local className = inst.ClassName
		if className == "PointLight" or className == "SpotLight" or className == "SurfaceLight" then
			inst.Shadows = false
		end
	end
end

function ApothecaryTree.replace(townFolder: Instance, refs: any): any
	local model = findNamed(townFolder, MODEL_NAME, "Model")
	if model == nil or model:GetAttribute("TownKit") == "ApothecaryTree" then
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
	folder.Name = "Tree"
	folder.Parent = model

	buildTrunk(folder, pivot)
	buildLimbs(folder, pivot)
	buildRoots(folder, pivot)
	local door = buildDoor(folder, pivot)
	buildEye(folder, pivot)
	if detail then
		buildDetail(folder, pivot, door)
	end
	repositionKept(model, pivot)
	lightFlames(model)
	quietLights(model)

	local anchor = findNamed(folder, "DoorAnchor", "Part")
	for _, prompt in prompts do
		prompt.Parent = if anchor ~= nil then anchor else model
	end

	local afterParts = Kit.countParts(model)
	local afterLights = Kit.countLights(model)
	local afterEmitters = Kit.countEmitters(model)
	model:SetAttribute("TownKit", "ApothecaryTree")
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

return ApothecaryTree
