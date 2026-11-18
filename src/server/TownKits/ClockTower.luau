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
local UITheme = import("../../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any

local ClockTower = {}

local MODEL_NAME = "DuskAndDial"
local STONE = UITheme.materials.altar
local COBBLE = UITheme.materials.cobble
local WOOD = UITheme.materials.wood
local METAL = UITheme.materials.iron
local BONE = UITheme.materials.candle
local NEON = UITheme.materials.neon

local BLOCKOUT = {
	Shaft = true,
	ClockFace = true,
	MoonPhase = true,
	MoonShadow = true,
	Spire = true,
}

-- Local -Z faces the plaza. Proportions follow town-preview-v2's clock:
-- plinth, timber-framed shaft, face centred near y=10.35, belfry, steep spire to ~20.
local SIGN_LOCAL = CFrame.new(0, 4.55, -3.9)
local CROW_LOCAL = CFrame.new(-0.9, 15, -1.3)
local CLOCK_Y = 10.35
local SHAFT_TOP = 12.32
local FINE_COURSE = 0.16
local FINE_BRICK = 0.24
local COARSE_COURSE = 0.82
local COARSE_BRICK = 1.12
local TONES = { "Wall", "Soot", "Void", "Ash", "Stone", "Wall", "Soot" }
local CORNERS = {
	{ -2.45, -2.45 },
	{ 2.45, -2.45 },
	{ -2.45, 2.45 },
	{ 2.45, 2.45 },
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
	decor: boolean
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
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
end

local function halfWidth(y: number): number
	if y < 1 then
		return 3.2
	elseif y < 4.5 then
		return 2.8
	elseif y < 8.3 then
		return 2.5
	end
	return 2.8
end

local function toneAt(course: number, index: number): string
	local pick = (course * 5 + index) % #TONES
	return TONES[pick + 1]
end

local function occluded(face: number, along: number, y: number): boolean
	if face == 0 then
		if math.abs(along) < 0.82 and y > 0.4 and y < 3.05 then
			return true
		end
		if math.abs(math.abs(along) - 1.3) < 0.4 and y > 5.75 and y < 7.2 then
			return true
		end
		local dy = y - CLOCK_Y
		if along * along + dy * dy < 4.45 then
			return true
		end
	elseif face == 1 or face == 3 then
		if math.abs(along) < 0.4 and y > 5.75 and y < 7.2 then
			return true
		end
	end
	if face == 1 then
		local dz = along + 0.15
		local dy = y - 10.15
		if dz * dz + dy * dy < 0.72 then
			return true
		end
	end
	return false
end

local function addMasonry(parent: Instance, pivot: any, brickH: number, brickW: number, thick: number)
	local y = 0.08
	local course = 0
	while y + brickH <= SHAFT_TOP do
		local centerY = y + brickH * 0.5
		local half = halfWidth(centerY)
		local span = (half - thick * 0.55) * 2
		local count = math.max(math.floor(span / brickW), 3)
		local width = span / count
		local shift = if course % 2 == 0 then 0 else width * 0.5
		for face = 0, 3 do
			local yaw = face * (math.pi * 0.5)
			for index = 0, count - 1 do
				local along = -span * 0.5 + (index + 0.5) * width + shift
				if along > span * 0.5 then
					along -= span
				end
				if not occluded(face, along, centerY) then
					local swell = math.sin(course * 1.3 + index * 0.7) * 0.03
					local depth = half - thick * 0.5 - swell
					local wiggle = 0.84 + 0.14 * math.abs(math.sin(course * 2.1 + index))
					place(parent, pivot, {
						name = "Brick",
						size = Vector3.new(width * wiggle, brickH * 0.9, thick),
						cf = CFrame.Angles(0, yaw, 0) * CFrame.new(along, centerY, -depth),
						material = STONE,
						color = toneAt(course, index + face * 3),
						shadow = true,
					})
				end
			end
		end
		y += brickH
		course += 1
	end
end

local function addGlow(parent: Instance, name: string, range: number, brightness: number, token: string, spot: boolean)
	local light = Instance.new(if spot then "SpotLight" else "PointLight")
	light.Name = name
	light.Color = UITheme.color(token)
	light.Range = range
	light.Brightness = brightness
	light.Shadows = false
	if spot then
		light.Angle = 48
		light.Face = Enum.NormalId.Front
	end
	light.Parent = parent
	return light
end

local function addLife(
	parent: Instance,
	name: string,
	rate: number,
	life: number,
	speed: number,
	size: number,
	spread: number,
	token: string
)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = name
	emitter.Rate = rate
	emitter.Lifetime = NumberRange.new(life, life)
	emitter.Speed = NumberRange.new(speed * 0.5, speed)
	emitter.SpreadAngle = Vector2.new(spread, spread)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-12, 12)
	emitter.Acceleration = Vector3.new(0, 0.4, 0)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.LightInfluence = 0
	emitter.Color = ColorSequence.new(UITheme.color(token))
	emitter.Size = NumberSequence.new(size)
	emitter.Transparency = NumberSequence.new(0.4)
	emitter.Enabled = true
	emitter:SetAttribute("TownEffect", "ClockLife")
	emitter:SetAttribute("TownFlame", "extra")
	emitter.Parent = parent
end

local function pointedOpening(
	parent: Instance,
	pivot: any,
	cf: any,
	width: number,
	height: number,
	depth: number,
	glow: boolean
)
	place(parent, pivot, {
		name = "ArchVoid",
		size = Vector3.new(width, height * 0.72, depth),
		cf = cf * CFrame.new(0, -height * 0.08, 0),
		material = STONE,
		color = "NightSky",
		decor = true,
		shadow = false,
	})
	for _, side in { -1, 1 } do
		place(parent, pivot, {
			name = "ArchJamb",
			size = Vector3.new(0.08, height * 0.78, depth + 0.04),
			cf = cf * CFrame.new(side * width * 0.5, 0, 0),
			material = STONE,
			color = "Stone",
			decor = true,
			shadow = true,
		})
		place(parent, pivot, {
			name = "ArchPoint",
			size = Vector3.new(0.08, height * 0.42, depth + 0.02),
			cf = cf * CFrame.new(side * width * 0.18, height * 0.42, 0) * CFrame.Angles(0, 0, math.rad(-side * 32)),
			material = STONE,
			color = "BoneDim",
			decor = true,
			shadow = true,
		})
	end
	if glow then
		local shine = place(parent, pivot, {
			name = "ArchGlow",
			size = Vector3.new(width * 0.62, height * 0.48, 0.05),
			cf = cf * CFrame.new(0, -height * 0.05, -0.06),
			material = NEON,
			color = "DuskViolet",
			decor = true,
			shadow = false,
			neonRole = "rune",
		})
		return shine
	end
	return nil
end

local function buildBase(parent: Instance, pivot: any)
	place(parent, pivot, {
		name = "Foundation",
		size = Vector3.new(5.5, 0.18, 5.5),
		cf = CFrame.new(0, 0.1, 0),
		material = COBBLE,
		color = "Soot",
		shadow = true,
	})
	place(parent, pivot, {
		name = "Step",
		size = Vector3.new(3.2, 0.2, 1.35),
		cf = CFrame.new(0, 0.14, -3.55),
		material = COBBLE,
		color = "Ash",
		shadow = true,
	})
	place(parent, pivot, {
		name = "Step",
		size = Vector3.new(2.55, 0.16, 0.95),
		cf = CFrame.new(0, 0.3, -3.15),
		material = COBBLE,
		color = "Soot",
		shadow = true,
	})
	for step = 0, 11 do
		local rise = 0.35 + step * 0.62
		local reach = 0.95 - step * 0.05
		for _, corner in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			local half = halfWidth(rise)
			place(parent, pivot, {
				name = "Buttress",
				size = Vector3.new(0.42, 0.5, 0.42),
				cf = CFrame.new(corner[1] * (half + reach * 0.35), rise, corner[2] * (half + reach * 0.35)),
				material = STONE,
				color = if step % 3 == 0 then "Stone" else "Wall",
				shadow = true,
			})
		end
	end
end

local function buildTimber(parent: Instance, pivot: any)
	for _, corner in CORNERS do
		place(parent, pivot, {
			name = "TimberPost",
			size = Vector3.new(0.28, 7.6, 0.28),
			cf = CFrame.new(corner[1], 4.6, corner[2]),
			material = WOOD,
			color = "Bark",
			shadow = true,
		})
	end
	place(parent, pivot, {
		name = "TimberBeam",
		size = Vector3.new(5.2, 0.22, 0.22),
		cf = CFrame.new(0, 4.6, -2.52),
		material = WOOD,
		color = "ShipWood",
		shadow = true,
	})
	place(parent, pivot, {
		name = "TimberBeam",
		size = Vector3.new(5.2, 0.22, 0.22),
		cf = CFrame.new(0, 8.2, -2.52),
		material = WOOD,
		color = "ShipWood",
		shadow = true,
	})
	place(parent, pivot, {
		name = "TimberBeam",
		size = Vector3.new(0.22, 0.22, 5.2),
		cf = CFrame.new(-2.52, 4.6, 0),
		material = WOOD,
		color = "Bark",
		shadow = true,
	})
	place(parent, pivot, {
		name = "TimberBeam",
		size = Vector3.new(0.22, 0.22, 5.2),
		cf = CFrame.new(2.52, 4.6, 0),
		material = WOOD,
		color = "Bark",
		shadow = true,
	})
	for _, side in { -1, 1 } do
		place(parent, pivot, {
			name = "Brace",
			size = Vector3.new(0.16, 2.35, 0.16),
			cf = CFrame.new(side * 1.2, 5.6, -2.58) * CFrame.Angles(0, 0, math.rad(-side * 34)),
			material = WOOD,
			color = "Bark",
			decor = true,
			shadow = true,
		})
	end
	place(parent, pivot, {
		name = "TimberBand",
		size = Vector3.new(6.05, 0.22, 6.05),
		cf = CFrame.new(0, 8.35, 0),
		material = WOOD,
		color = "ShipWood",
		shadow = true,
	})
	place(parent, pivot, {
		name = "TimberBand",
		size = Vector3.new(6.05, 0.22, 6.05),
		cf = CFrame.new(0, 12.35, 0),
		material = WOOD,
		color = "ShipWood",
		shadow = true,
	})
end

local function buildDoor(parent: Instance, pivot: any): any
	local mouth = CFrame.new(0, 1.62, -3.02)
	pointedOpening(parent, pivot, mouth, 1.55, 2.45, 0.16, false)
	place(parent, pivot, {
		name = "Door",
		size = Vector3.new(0.92, 2.15, 0.1),
		cf = CFrame.new(-0.62, 1.5, -3.22) * CFrame.Angles(0, math.rad(26), 0),
		material = WOOD,
		color = "Bark",
		decor = true,
		shadow = true,
	})
	local sill = place(parent, pivot, {
		name = "DoorAnchor",
		size = Vector3.new(1.7, 0.2, 1.05),
		cf = CFrame.new(0, 0.18, -3.35),
		material = STONE,
		color = "Stone",
		shadow = true,
	})
	sill:SetAttribute("TownAnchor", "Door")
	local lantern = place(parent, pivot, {
		name = "Lantern",
		size = Vector3.new(0.32, 0.42, 0.32),
		cf = CFrame.new(0.95, 2.15, -3.28),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
	})
	local wick = place(parent, pivot, {
		name = "Wick",
		size = Vector3.new(0.16, 0.16, 0.16),
		cf = CFrame.new(0.95, 2.42, -3.36),
		material = NEON,
		color = "DuskViolet",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
		neonRole = "flame",
	})
	addGlow(lantern, "DoorGlow", 8, 0.48, "Gold", false)
	addGlow(wick, "DoorSpot", 12, 0.36, "DuskViolet", true)
	return sill
end

local function buildWindows(parent: Instance, pivot: any)
	pointedOpening(parent, pivot, CFrame.new(-1.3, 6.4, -2.62), 0.7, 1.2, 0.1, true)
	pointedOpening(parent, pivot, CFrame.new(1.3, 6.4, -2.62), 0.7, 1.2, 0.1, true)
	pointedOpening(parent, pivot, CFrame.Angles(0, math.rad(90), 0) * CFrame.new(0, 6.4, -2.62), 0.62, 1.05, 0.1, true)
	pointedOpening(parent, pivot, CFrame.Angles(0, math.rad(-90), 0) * CFrame.new(0, 6.4, -2.62), 0.62, 1.05, 0.1, true)
end

local function buildDial(parent: Instance, pivot: any): any
	local hubLocal = CFrame.new(0, CLOCK_Y, -3.12)
	local halo = place(parent, pivot, {
		name = "DialHalo",
		size = Vector3.new(0.12, 4.8, 4.8),
		cf = CFrame.new(0, CLOCK_Y, -2.88) * CFrame.Angles(0, math.rad(90), 0),
		material = BONE,
		color = "NightSky",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	local face = place(parent, pivot, {
		name = "Dial",
		size = Vector3.new(0.16, 4.15, 4.15),
		cf = CFrame.new(0, CLOCK_Y, -3.02) * CFrame.Angles(0, math.rad(90), 0),
		material = BONE,
		color = "NightSky",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	for n = 0, 11 do
		local theta = n * (math.pi / 6)
		place(parent, pivot, {
			name = "Numeral",
			size = Vector3.new(0.16, 0.28, 0.06),
			cf = hubLocal
				* CFrame.new(math.sin(theta) * 1.72, math.cos(theta) * 1.72, -0.14)
				* CFrame.Angles(0, 0, -theta),
			material = METAL,
			color = "Void",
			decor = true,
			shadow = false,
		})
	end
	for n = 0, 59 do
		if n % 5 ~= 0 then
			local theta = n * (math.pi / 30)
			place(parent, pivot, {
				name = "MinuteTick",
				size = Vector3.new(0.035, 0.08, 0.04),
				cf = hubLocal
					* CFrame.new(math.sin(theta) * 1.78, math.cos(theta) * 1.78, -0.04)
					* CFrame.Angles(0, 0, -theta),
				material = METAL,
				color = "Soot",
				decor = true,
				shadow = false,
			})
		end
	end
	for n = 0, 23 do
		local theta = n * (math.pi / 12)
		place(parent, pivot, {
			name = "Bezel",
			size = Vector3.new(0.14, 0.08, 0.08),
			cf = hubLocal
				* CFrame.new(math.sin(theta) * 2.22, math.cos(theta) * 2.22, -0.02)
				* CFrame.Angles(0, 0, -theta),
			material = METAL,
			color = "Soot",
			decor = true,
			shadow = false,
		})
	end
	local hour = place(parent, pivot, {
		name = "HourHand",
		size = Vector3.new(0.1, 0.85, 0.06),
		cf = hubLocal * CFrame.new(0, 0.35, -0.16),
		material = METAL,
		color = "Void",
		decor = true,
		shadow = false,
	})
	local minute = place(parent, pivot, {
		name = "MinuteHand",
		size = Vector3.new(0.07, 1.15, 0.05),
		cf = hubLocal * CFrame.new(0, 0.5, -0.2),
		material = METAL,
		color = "Void",
		decor = true,
		shadow = false,
	})
	place(parent, pivot, {
		name = "DialBoss",
		size = Vector3.new(0.24, 0.24, 0.24),
		cf = hubLocal * CFrame.new(0, 0, -0.1),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
	})
	local pupil = place(parent, pivot, {
		name = "DialCore",
		size = Vector3.new(0.1, 0.1, 0.1),
		cf = hubLocal * CFrame.new(0, 0, -0.18),
		material = NEON,
		color = "DuskViolet",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
		neonRole = "eye",
	})
	local faceGlow = addGlow(face, "FaceGlow", 10, 0.45, "DuskViolet", false)
	local rod = place(parent, pivot, {
		name = "PendulumRod",
		size = Vector3.new(0.06, 2.4, 0.06),
		cf = CFrame.new(0, 6.95, -3.18),
		material = METAL,
		color = "BoneDim",
		decor = true,
		shadow = false,
	})
	local bob = place(parent, pivot, {
		name = "PendulumBob",
		size = Vector3.new(0.55, 0.7, 0.48),
		cf = CFrame.new(0, 5.65, -3.18),
		material = STONE,
		color = "Blood",
		decor = true,
		shadow = true,
	})
	return {
		hub = pivot * hubLocal,
		dial = face,
		halo = halo,
		core = pupil,
		faceGlow = faceGlow,
		hour = hour,
		minute = minute,
		hourLocal = CFrame.new(0, 0.35, -0.16),
		minuteLocal = CFrame.new(0, 0.5, -0.2),
		pendPivot = pivot * CFrame.new(0, 8.15, -3.18),
		rod = rod,
		bob = bob,
		rodLocal = CFrame.new(0, -1.2, 0),
		bobLocal = CFrame.new(0, -2.5, 0),
	}
end

local function buildGears(parent: Instance, pivot: any, detail: boolean): { any }
	local gears = {}
	local specs = {
		{ cf = CFrame.new(3.05, 10.2, 0.15), radius = 0.72, rate = 0.35, teeth = 14 },
		{ cf = CFrame.new(3.02, 9.45, 0.95), radius = 0.46, rate = -0.52, teeth = 10 },
	}
	for _, spec in specs do
		local parts = {}
		local disc = place(parent, pivot, {
			name = "Gear",
			size = Vector3.new(0.1, spec.radius * 2, spec.radius * 2),
			cf = spec.cf,
			material = METAL,
			color = "Gold",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
		table.insert(parts, { part = disc, localCf = CFrame.new() })
		if detail then
			for index = 0, spec.teeth - 1 do
				local theta = index / spec.teeth * math.pi * 2
				local localCf =
					CFrame.new(0.08, math.cos(theta) * (spec.radius + 0.08), math.sin(theta) * (spec.radius + 0.08))
				local tooth = place(parent, pivot, {
					name = "GearTooth",
					size = Vector3.new(0.08, 0.12, 0.14),
					cf = spec.cf * localCf,
					material = METAL,
					color = "GoldBright",
					decor = true,
					shadow = false,
				})
				table.insert(parts, { part = tooth, localCf = localCf })
			end
		end
		table.insert(gears, { cf = pivot * spec.cf, rate = spec.rate, parts = parts })
	end
	place(parent, pivot, {
		name = "GearVoid",
		size = Vector3.new(0.08, 1.7, 1.7),
		cf = CFrame.new(2.72, 10.05, 0.35),
		material = STONE,
		color = "Void",
		decor = true,
		shadow = false,
	})
	return gears
end

local function buildBelfry(parent: Instance, pivot: any)
	for _, corner in { { -1.4, -1.4 }, { 1.4, -1.4 }, { -1.4, 1.4 }, { 1.4, 1.4 } } do
		place(parent, pivot, {
			name = "BelfryPost",
			size = Vector3.new(0.22, 2.6, 0.22),
			cf = CFrame.new(corner[1], 13.8, corner[2]),
			material = WOOD,
			color = "Bark",
			shadow = true,
		})
	end
	place(parent, pivot, {
		name = "BelfryCap",
		size = Vector3.new(3.45, 0.16, 3.45),
		cf = CFrame.new(0, 15.08, 0),
		material = WOOD,
		color = "ShipWood",
		shadow = true,
	})
	place(parent, pivot, {
		name = "BelfryVoid",
		size = Vector3.new(1.35, 1.5, 0.08),
		cf = CFrame.new(0, 13.75, -1.52),
		material = STONE,
		color = "NightSky",
		decor = true,
		shadow = false,
	})
	place(parent, pivot, {
		name = "BelfryVoid",
		size = Vector3.new(1.35, 1.5, 0.08),
		cf = CFrame.new(0, 13.75, 1.52),
		material = STONE,
		color = "Void",
		decor = true,
		shadow = false,
	})
	place(parent, pivot, {
		name = "Bell",
		size = Vector3.new(0.72, 0.52, 0.52),
		cf = CFrame.new(0, 13.85, -1.72) * CFrame.Angles(0, 0, math.rad(90)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = true,
		shape = Enum.PartType.Cylinder,
	})
	local clapper = place(parent, pivot, {
		name = "Clapper",
		size = Vector3.new(0.16, 0.16, 0.16),
		cf = CFrame.new(0, 13.48, -1.72),
		material = METAL,
		color = "GoldBright",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
	})
	addGlow(clapper, "BellGlow", 6, 0.28, "Gold", false)
end

local function buildSpire(parent: Instance, pivot: any, detail: boolean)
	local rise = 4.05
	local run = 1.9
	local width = 3.7
	local baseY = 15.15
	local pitch = math.atan(rise / run)
	for face = 0, 3 do
		local yaw = face * (math.pi * 0.5)
		place(parent, pivot, {
			className = "WedgePart",
			name = "SpireFace",
			size = Vector3.new(width, rise, run),
			cf = CFrame.Angles(0, yaw, 0) * CFrame.new(0, baseY + rise * 0.5, -run * 0.5),
			material = STONE,
			color = "Stone",
			shadow = true,
		})
	end
	for _, side in { -1, 1 } do
		place(parent, pivot, {
			name = "Eave",
			size = Vector3.new(6.3, 0.14, 1.45),
			cf = CFrame.new(0, 12.55, side * 2.55) * CFrame.Angles(side * 0.22, 0, 0),
			material = STONE,
			color = "Stone",
			decor = true,
			shadow = true,
		})
		place(parent, pivot, {
			name = "Eave",
			size = Vector3.new(1.45, 0.14, 6.3),
			cf = CFrame.new(side * 2.55, 12.55, 0) * CFrame.Angles(0, 0, -side * 0.22),
			material = STONE,
			color = "Wall",
			decor = true,
			shadow = true,
		})
	end
	place(parent, pivot, {
		name = "Finial",
		size = Vector3.new(0.12, 1.7, 0.12),
		cf = CFrame.new(0, 20.2, 0),
		material = METAL,
		color = "BoneDim",
		decor = true,
		shadow = true,
	})
	place(parent, pivot, {
		name = "SpireTip",
		size = Vector3.new(0.28, 0.28, 0.28),
		cf = CFrame.new(0, 21.15, 0),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
	})
	if not detail then
		return
	end
	local rows = 22
	for face = 0, 3 do
		local yaw = face * (math.pi * 0.5)
		for row = 0, rows - 1 do
			local t = (row + 0.5) / rows
			local y = baseY + t * rise
			local outward = run * (1 - t) + 0.08
			local half = width * 0.5 * (1 - t) * 0.92
			local count = math.max(math.floor((half * 2) / 0.2), 2)
			local brick = (half * 2) / count
			local shift = if row % 2 == 0 then 0 else brick * 0.5
			for index = 0, count - 1 do
				local along = -half + (index + 0.5) * brick + shift
				if along > half then
					along -= half * 2
				end
				place(parent, pivot, {
					name = "Shingle",
					size = Vector3.new(brick * 0.9, 0.05, 0.28),
					cf = CFrame.Angles(0, yaw, 0) * CFrame.new(along, y, -outward) * CFrame.Angles(-pitch, 0, 0),
					material = STONE,
					color = if (row + index) % 4 == 0 then "Wall" else "NightSky",
					decor = true,
					shadow = true,
				})
			end
		end
	end
end

local function buildRavens(parent: Instance, pivot: any)
	local perches = {
		{ 0.7, 14.85, -0.7, -0.5 },
		{ 1.3, 15.1, 0.6, 1.1 },
	}
	for _, perch in perches do
		local cf = CFrame.new(perch[1], perch[2], perch[3]) * CFrame.Angles(0, perch[4], 0)
		place(parent, pivot, {
			name = "RavenBody",
			size = Vector3.new(0.28, 0.16, 0.42),
			cf = cf,
			material = BONE,
			color = "Void",
			decor = true,
			shadow = true,
			shape = Enum.PartType.Ball,
		})
		place(parent, pivot, {
			name = "RavenHead",
			size = Vector3.new(0.14, 0.12, 0.16),
			cf = cf * CFrame.new(0, 0.08, -0.22),
			material = BONE,
			color = "Void",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Ball,
		})
		place(parent, pivot, {
			name = "RavenBeak",
			className = "WedgePart",
			size = Vector3.new(0.06, 0.06, 0.14),
			cf = cf * CFrame.new(0, 0.06, -0.34),
			material = BONE,
			color = "Gold",
			decor = true,
			shadow = false,
		})
		place(parent, pivot, {
			name = "RavenWing",
			size = Vector3.new(0.46, 0.04, 0.18),
			cf = cf * CFrame.new(0, 0.06, 0) * CFrame.Angles(0, 0, math.rad(18)),
			material = BONE,
			color = "Ash",
			decor = true,
			shadow = false,
		})
		place(parent, pivot, {
			name = "RavenTail",
			size = Vector3.new(0.08, 0.04, 0.2),
			cf = cf * CFrame.new(0, 0.04, 0.26),
			material = BONE,
			color = "Soot",
			decor = true,
			shadow = false,
		})
	end
end

local function buildGargoyles(parent: Instance, pivot: any)
	for _, corner in { { 1, -1 }, { -1, -1 }, { 1, 1 }, { -1, 1 } } do
		local x = corner[1] * 3.15
		local z = corner[2] * 3.15
		place(parent, pivot, {
			name = "Gargoyle",
			size = Vector3.new(0.36, 0.22, 0.55),
			cf = CFrame.new(x, 12.62, z),
			material = STONE,
			color = "Wall",
			decor = true,
			shadow = true,
		})
		place(parent, pivot, {
			name = "GargoyleHead",
			size = Vector3.new(0.22, 0.18, 0.22),
			cf = CFrame.new(x + corner[1] * 0.28, 12.7, z + corner[2] * 0.28),
			material = STONE,
			color = "Soot",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Ball,
		})
		place(parent, pivot, {
			name = "GargoyleWing",
			size = Vector3.new(0.48, 0.05, 0.16),
			cf = CFrame.new(x, 12.78, z) * CFrame.Angles(0, 0, math.rad(corner[1] * 16)),
			material = STONE,
			color = "Void",
			decor = true,
			shadow = false,
		})
	end
end

local function buildChains(parent: Instance, pivot: any)
	place(parent, pivot, {
		name = "SignBracket",
		size = Vector3.new(7.4, 0.16, 0.16),
		cf = CFrame.new(0, 6.05, -3.15),
		material = WOOD,
		color = "Bark",
		decor = true,
		shadow = true,
	})
	for _, side in { -1, 1 } do
		cylinderBetween(
			parent,
			pivot,
			"SignChain",
			Vector3.new(side * 3.4, 5.85, -3.7),
			Vector3.new(side * 3.4, 6.05, -3.2),
			0.06,
			METAL,
			"Gold",
			true
		)
	end
end

local function buildDentils(parent: Instance, pivot: any)
	local count = 26
	for face = 0, 3 do
		local yaw = face * (math.pi * 0.5)
		for index = 0, count - 1 do
			local along = -2.7 + (index + 0.5) * (5.4 / count)
			place(parent, pivot, {
				name = "Dentil",
				size = Vector3.new(0.12, 0.14, 0.16),
				cf = CFrame.Angles(0, yaw, 0) * CFrame.new(along, 12.18, -2.98),
				material = STONE,
				color = if index % 2 == 0 then "BoneDim" else "Stone",
				decor = true,
				shadow = true,
			})
		end
	end
end

local function buildLife(parent: Instance, pivot: any)
	local burner = place(parent, pivot, {
		name = "MoteHost",
		size = Vector3.new(0.3, 0.3, 0.3),
		cf = CFrame.new(0, CLOCK_Y, -3.3),
		material = BONE,
		color = "DuskViolet",
		decor = true,
		shadow = false,
	})
	burner.Transparency = 1
	addLife(burner, "DialMotes", 4, 2.4, 0.35, 0.14, 36, "Gold")
	local smoke = place(parent, pivot, {
		name = "SmokeHost",
		size = Vector3.new(0.3, 0.3, 0.3),
		cf = CFrame.new(0.95, 2.55, -3.36),
		material = BONE,
		color = "Ash",
		decor = true,
		shadow = false,
	})
	smoke.Transparency = 1
	addLife(smoke, "DoorSmoke", 5, 2.2, 0.45, 0.4, 14, "Ash")
	addLife(smoke, "DoorFlame", 8, 1.1, 0.7, 0.22, 12, "DuskViolet")
	local fog = place(parent, pivot, {
		name = "FogHost",
		size = Vector3.new(1.2, 0.2, 1.2),
		cf = CFrame.new(0, 0.35, -3.4),
		material = BONE,
		color = "Soot",
		decor = true,
		shadow = false,
	})
	fog.Transparency = 1
	addLife(fog, "BaseFog", 6, 2, 0.25, 0.7, 40, "BoneDim")
end

local function bloodMoonOn(model: Instance): boolean
	if model:GetAttribute("BloodMoon") == true then
		return true
	end
	local ok, lighting = pcall(function()
		return game:GetService("Lighting")
	end)
	if ok and lighting ~= nil and lighting:GetAttribute("BloodMoon") == true then
		return true
	end
	return false
end

local function paintFace(model: Instance, rig: any, blood: boolean)
	local token = if blood then "FlameCrimson" else "DuskViolet"
	local color = UITheme.color(token)
	if model ~= nil then
		for _, inst in model:GetDescendants() do
			if inst.Name == "ArchGlow" or inst.Name == "Dial" or inst.Name == "DialHalo" or inst.Name == "DialCore" then
				inst.Color = color
			end
		end
	end
	if rig == nil then
		return
	end
	if rig.dial ~= nil then
		rig.dial.Material = Enum.Material.SmoothPlastic
		rig.dial.Color = UITheme.color("NightSky")
		rig.dial:SetAttribute("NeonRole", nil)
	end
	if rig.halo ~= nil then
		rig.halo.Material = Enum.Material.SmoothPlastic
		rig.halo.Color = UITheme.color("NightSky")
		rig.halo:SetAttribute("NeonRole", nil)
	end
	if rig.core ~= nil then
		rig.core.Color = color
	end
	if rig.faceGlow ~= nil then
		rig.faceGlow.Color = color
	end
	rig.blood = blood
end

local function readNow(dt: number): number
	local stampedOk, stamped = pcall(function()
		return workspace:GetServerTimeNow()
	end)
	if stampedOk and type(stamped) == "number" then
		return stamped
	end
	return os.clock() + dt
end

local function driveClock(model: Instance, rig: any)
	Kit.animate(model, function(dt: number, elapsed: number)
		if type(dt) ~= "number" or type(elapsed) ~= "number" or rig == nil then
			return
		end
		local blood = bloodMoonOn(model)
		if blood ~= rig.blood then
			paintFace(model, rig, blood)
		end
		local now = readNow(dt)
		local minute = 60
		local seconds = now % minute
		local minutes = math.floor(now / minute) % minute
		local hours = math.floor(now / (minute * minute)) % 12
		local turn = math.pi * 2
		local minuteAngle = -turn * ((minutes + seconds / minute) / minute)
		local hourAngle = -turn * ((hours + (minutes + seconds / minute) / minute) / 12)
		local swing = math.sin(now * 1.35) * 0.38
		rig.hour.CFrame = rig.hub * CFrame.Angles(0, 0, hourAngle) * rig.hourLocal
		rig.minute.CFrame = rig.hub * CFrame.Angles(0, 0, minuteAngle) * rig.minuteLocal
		local swung = CFrame.Angles(0, 0, swing)
		rig.rod.CFrame = rig.pendPivot * swung * rig.rodLocal
		rig.bob.CFrame = rig.pendPivot * swung * rig.bobLocal
		for _, gear in rig.gears or {} do
			local spin = CFrame.Angles(now * gear.rate, 0, 0)
			for _, item in gear.parts do
				item.part.CFrame = gear.cf * spin * item.localCf
			end
		end
	end)
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
	if sign ~= nil then
		sign.Size = Vector3.new(3.3, 0.95, 0.16)
		sign.Material = Enum.Material.WoodPlanks
		sign.Color = UITheme.color("Bark")
		local gui = sign:FindFirstChild("SignGui")
		local label = if gui ~= nil then gui:FindFirstChild("SignText") else nil
		if label ~= nil then
			label.TextColor3 = UITheme.color("Gold")
			label.TextSize = 16
		end
	end
	if trim ~= nil then
		trim.Size = Vector3.new(3.55, 1.15, 0.08)
		trim.Material = Enum.Material.WoodPlanks
		trim.Color = UITheme.color("Gold")
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

local function stripDetailLights(model: Instance)
	for _, inst in model:GetDescendants() do
		if inst.Name == "DoorSpot" or inst.Name == "BellGlow" then
			inst:Destroy()
		end
	end
end

function ClockTower.replace(townFolder: Instance, refs: any): any
	local model = findNamed(townFolder, MODEL_NAME, "Model")
	if model == nil or model:GetAttribute("TownKit") == "ClockTower" then
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
	folder.Name = "Tower"
	folder.Parent = model

	local function phase(stepName: string, fn: () -> ())
		Kit.step("ClockTower", stepName, fn)
	end
	phase("base", function()
		buildBase(folder, pivot)
	end)
	local course = if detail then FINE_COURSE else COARSE_COURSE
	local brick = if detail then FINE_BRICK else COARSE_BRICK
	local thick = if detail then 0.46 else 0.7
	phase("masonry", function()
		addMasonry(folder, pivot, course, brick, thick)
	end)
	phase("timber", function()
		buildTimber(folder, pivot)
	end)
	local anchor = nil
	phase("door", function()
		anchor = buildDoor(folder, pivot)
	end)
	phase("windows", function()
		buildWindows(folder, pivot)
	end)
	local rig = nil
	phase("dial", function()
		rig = buildDial(folder, pivot)
	end)
	phase("gears", function()
		if rig ~= nil then
			rig.gears = buildGears(folder, pivot, detail)
		end
	end)
	phase("belfry", function()
		buildBelfry(folder, pivot)
	end)
	phase("spire", function()
		buildSpire(folder, pivot, detail)
	end)
	phase("ravens", function()
		buildRavens(folder, pivot)
	end)
	phase("chains", function()
		buildChains(folder, pivot)
	end)
	if detail then
		phase("ornament", function()
			buildGargoyles(folder, pivot)
			buildDentils(folder, pivot)
			buildLife(folder, pivot)
		end)
	else
		stripDetailLights(model)
	end
	phase("sign", function()
		repositionKept(model, pivot)
	end)
	quietLights(model)
	if model:GetAttribute("BloodMoon") == nil then
		model:SetAttribute("BloodMoon", false)
	end
	paintFace(model, rig, bloodMoonOn(model))
	if rig ~= nil then
		driveClock(model, rig)
	end

	for _, prompt in prompts do
		prompt.Parent = if anchor ~= nil then anchor else model
	end
	Kit.promptAnchor(model, CFrame.new(0, 3, -3.85))

	local afterParts = Kit.countParts(model)
	local afterLights = Kit.countLights(model)
	local afterEmitters = Kit.countEmitters(model)
	model:SetAttribute("TownKit", "ClockTower")
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

ClockTower.name = "ClockTower"
ClockTower.order = 4

return ClockTower
