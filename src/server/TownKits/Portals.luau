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

local Portals = {}

local WOOD = UITheme.materials.wood
local STONE = UITheme.materials.altar
local COBBLE = UITheme.materials.cobble
local BONE_MAT = UITheme.materials.candle
local METAL = UITheme.materials.iron
local NEON = UITheme.materials.neon
local LIME = "Limestone"

-- Local -Z faces the plaza. The walk gap (|x| < 2, y < 6) stays clear of colliding parts.
local VORTEX_Y = 4.4
local VORTEX_Z = 0.15
local PORTAL_SCALE = 2.25
local DISC = 8.4
local LOCK_X = 5.05 * PORTAL_SCALE

local SIGN_AT = {
	WhisperingWoods = CFrame.new(0, 12.8, -2.2),
	SunkenMarsh = CFrame.new(0, 11.6, -3.9),
	BoneQuarry = CFrame.new(0, 12.5, -2.2),
}

local SIGN_COPY = {
	WhisperingWoods = "Whispering Woods",
	SunkenMarsh = "Sunken Marsh",
	BoneQuarry = "Bone Quarry",
}

local BLOCKOUT = {
	tree = {
		Trunk = true,
		Lintel = true,
		Knot = true,
		Vortex = true,
		VortexHost = true,
	},
	serpent = {
		Pillar = true,
		SerpentHead = true,
		Snout = true,
		Jaw = true,
		Eye = true,
		Vortex = true,
		VortexHost = true,
	},
	ribcage = {
		Pillar = true,
		Rib = true,
		Vortex = true,
		VortexHost = true,
	},
}

local DOOM_CLASS = {
	Part = true,
	WedgePart = true,
	MeshPart = true,
	UnionOperation = true,
}

-- Roblox server identity cannot assign Script.Source. When that write fails, the kit
-- spins the same parts through Kit.animate. Under Lune the source returns before any API.
local SPIN_SOURCE = [=[
if type(_G) == "table" and rawget(_G, "LUNE") == true then
	return
end
pcall(function()
	local RunService = game:GetService("RunService")
	if RunService == nil then
		return
	end
	local heartbeat = RunService.Heartbeat
	if heartbeat == nil or type(heartbeat.Connect) ~= "function" then
		return
	end
	local model = script.Parent
	if model == nil or type(model.GetDescendants) ~= "function" then
		return
	end
	local axis = nil
	local parts = {}
	for _, inst in model:GetDescendants() do
		if inst.Name == "Vortex" and type(inst.IsA) == "function" and inst:IsA("BasePart") then
			axis = inst
		elseif inst:GetAttribute("TownSpin") == true and type(inst.IsA) == "function" and inst:IsA("BasePart") then
			table.insert(parts, inst)
		end
	end
	if axis == nil or axis.CFrame == nil then
		return
	end
	local relative = {}
	local speed = {}
	for index, part in parts do
		relative[index] = axis.CFrame:Inverse() * part.CFrame
		local rate = part:GetAttribute("SpinSpeed")
		speed[index] = if type(rate) == "number" then rate else 0.6
	end
	local elapsed = 0
	local connection = nil
	connection = heartbeat:Connect(function(dt)
		local spun, spinErr = pcall(function()
			elapsed += if type(dt) == "number" then dt else 0
			if axis.Parent == nil or axis.CFrame == nil then
				return
			end
			for index, part in parts do
				if part.Parent ~= nil and part.CFrame ~= nil and relative[index] ~= nil then
					part.CFrame = axis.CFrame * CFrame.Angles(speed[index] * elapsed, 0, 0) * relative[index]
				end
			end
		end)
		if spun or connection == nil then
			return
		end
		local link = connection
		connection = nil
		pcall(function()
			link:Disconnect()
		end)
		warn(spinErr)
	end)
end)
]=]

local function distance(a: any, b: any): number
	local dx = a.X - b.X
	local dy = a.Y - b.Y
	local dz = a.Z - b.Z
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function separated(a: any, b: any): any
	if distance(a, b) >= 0.08 then
		return b
	end
	return Vector3.new(a.X + 0.08, a.Y + 0.02, a.Z)
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

local function growCf(cf: any): any
	if cf == nil or cf.Position == nil then
		return cf
	end
	local pos = cf.Position
	if cf.r00 ~= nil then
		return CFrame.new(
			pos.X * PORTAL_SCALE,
			pos.Y * PORTAL_SCALE,
			pos.Z * PORTAL_SCALE,
			cf.r00,
			cf.r01,
			cf.r02,
			cf.r10,
			cf.r11,
			cf.r12,
			cf.r20,
			cf.r21,
			cf.r22
		)
	end
	local extra = PORTAL_SCALE - 1
	return cf + Vector3.new(pos.X * extra, pos.Y * extra, pos.Z * extra)
end

local function growSize(size: any): any
	if size == nil then
		return size
	end
	return Vector3.new(size.X * PORTAL_SCALE, size.Y * PORTAL_SCALE, size.Z * PORTAL_SCALE)
end

local function place(parent: Instance, pivot: any, spec: any): any
	spec.size = growSize(spec.size)
	spec.cf = growCf(spec.cf)
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
	neonRole: string?
): any
	local target = separated(a, b)
	local length = math.max(distance(a, target), 0.08)
	local mid = Vector3.new((a.X + target.X) * 0.5, (a.Y + target.Y) * 0.5, (a.Z + target.Z) * 0.5)
	local cf = CFrame.lookAt(mid, target) * CFrame.Angles(0, math.rad(90), 0)
	return place(parent, pivot, {
		name = name,
		size = Vector3.new(length, diameter, diameter),
		cf = cf,
		material = material,
		color = color,
		decor = decor,
		shadow = not decor,
		shape = Enum.PartType.Cylinder,
		neonRole = neonRole,
	})
end

local function plateBetween(
	parent: Instance,
	pivot: any,
	name: string,
	a: any,
	b: any,
	width: number,
	thick: number,
	material: string,
	color: string
)
	local target = separated(a, b)
	local length = math.max(distance(a, target), 0.08)
	local mid = Vector3.new((a.X + target.X) * 0.5, (a.Y + target.Y) * 0.5, (a.Z + target.Z) * 0.5)
	local cf = CFrame.lookAt(mid, target) * CFrame.Angles(0, 0, math.rad(32))
	place(parent, pivot, {
		className = "WedgePart",
		name = name,
		size = Vector3.new(width, thick, length),
		cf = cf,
		material = material,
		color = color,
		decor = true,
		shadow = false,
	})
end

local function ball(
	parent: Instance,
	pivot: any,
	name: string,
	at: any,
	diameter: number,
	material: string,
	color: string,
	decor: boolean,
	neonRole: string?
): any
	return place(parent, pivot, {
		name = name,
		size = Vector3.new(diameter, diameter, diameter),
		cf = CFrame.new(at),
		material = material,
		color = color,
		decor = decor,
		shadow = not decor,
		shape = Enum.PartType.Ball,
		neonRole = neonRole,
	})
end

local function samples(count: number, fn: (number) -> any): { any }
	local points = {}
	for index = 0, count do
		points[index + 1] = fn(index / count)
	end
	return points
end

local function wobble(seed: number): number
	return math.sin(seed * 12.989) * 0.5 + 0.5
end

local function layChain(
	parent: Instance,
	pivot: any,
	name: string,
	points: { any },
	startD: number,
	endD: number,
	material: string,
	color: string,
	decor: boolean,
	plates: boolean,
	plateName: string,
	plateColor: string
)
	local span = #points - 1
	for index = 1, span do
		local t = if span <= 1 then 0 else (index - 1) / (span - 1)
		local diameter = startD + (endD - startD) * t
		local a = points[index]
		local b = points[index + 1]
		cylinderBetween(parent, pivot, name, a, b, diameter, material, color, decor, nil)
		if plates and index % 2 == 0 then
			plateBetween(parent, pivot, plateName, a, b, diameter * 1.7, diameter * 0.42, material, plateColor)
		end
	end
end

local function steps(detail: boolean, high: number, low: number): number
	if detail then
		return high
	end
	return low
end

local function axisCf(): any
	return CFrame.new(0, VORTEX_Y, VORTEX_Z) * CFrame.Angles(0, math.rad(90), 0)
end

local function markSpin(part: any, speed: number, transparency: number)
	part.Transparency = transparency
	part:SetAttribute("TownSpin", true)
	part:SetAttribute("SpinSpeed", speed)
end

local function addLight(parent: Instance, name: string, token: string, range: number, brightness: number)
	local light = Instance.new("PointLight")
	light.Name = name
	light.Color = UITheme.color(token)
	light.Range = range
	light.Brightness = brightness
	light.Shadows = false
	light.Parent = parent
end

local function addEmitter(
	parent: Instance,
	name: string,
	spec: any,
	token: string,
	effectId: string,
	tier: string,
	acceleration: any
)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = name
	emitter.Rate = spec.rate
	emitter.Lifetime = NumberRange.new(spec.life, spec.life)
	emitter.Speed = NumberRange.new(spec.speed * 0.5, spec.speed)
	emitter.SpreadAngle = Vector2.new(spec.spread, spec.spread)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-40, 40)
	emitter.Acceleration = acceleration
	emitter.EmissionDirection = Enum.NormalId.Front
	emitter.LightInfluence = 0
	emitter.Color = ColorSequence.new(UITheme.color(token))
	emitter.Size = NumberSequence.new(spec.size)
	emitter.Transparency = NumberSequence.new(0.18)
	emitter.Enabled = true
	emitter:SetAttribute("TownEffect", effectId)
	emitter:SetAttribute("TownFlame", tier)
	emitter.Parent = parent
end

local function swirlSpec(rate: number, life: number, speed: number, size: number, spread: number): any
	return { rate = rate, life = life, speed = speed, size = size, spread = spread }
end

local function buildVortex(parent: Instance, pivot: any, spec: any, detail: boolean): any
	local frame = axisCf()
	local disc = place(parent, pivot, {
		name = "Vortex",
		size = Vector3.new(0.42, DISC, DISC),
		cf = frame,
		material = NEON,
		color = spec.color,
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
		neonRole = "portal",
	})
	disc.Transparency = 0.08
	addLight(disc, "PortalLight", spec.color, TownLook.PORTAL_ACCENT_RANGE, TownLook.PORTAL_ACCENT_BRIGHTNESS)

	local secondary = if spec.id == "BoneQuarry" then "Bone" elseif spec.id == "SunkenMarsh" then "Moss" else "Rift"
	local spiral = if spec.id == "BoneQuarry" then "Blood" else spec.color
	local ringCount = if detail then 3 else 2
	local ringSegments = if detail then 8 else 4
	local radii = { 2.7, 2.05, 1.35 }
	local speeds = { 0.55, -0.85, 1.25 }
	for ring = 1, ringCount do
		local radius = radii[ring]
		local speed = speeds[ring]
		local color = if ring % 2 == 0 then secondary else spec.color
		local coverage = 0.78
		for index = 1, ringSegments do
			local u0 = (index - 1) / ringSegments * math.pi * 2 * coverage
			local u1 = index / ringSegments * math.pi * 2 * coverage
			local p0 = frame * Vector3.new(0, math.cos(u0) * radius, math.sin(u0) * radius)
			local p1 = frame * Vector3.new(0, math.cos(u1) * radius, math.sin(u1) * radius)
			local piece =
				cylinderBetween(parent, pivot, "VortexRing", p0, p1, 0.16 + ring * 0.03, NEON, color, true, "portal")
			markSpin(piece, speed, 0.16)
		end
	end
	if detail then
		local shards = 12
		for index = 1, shards do
			local angle = index / shards * math.pi * 2
			local radius = 0.7 + (index / shards) * 1.9
			local localPos = Vector3.new(0, math.cos(angle) * radius, math.sin(angle) * radius)
			local piece = place(parent, pivot, {
				className = "WedgePart",
				name = "VortexSpiral",
				size = Vector3.new(0.26, 0.85, 0.2),
				cf = frame * CFrame.new(localPos) * CFrame.Angles(angle, 0, math.rad(38)),
				material = NEON,
				color = spiral,
				decor = true,
				shadow = false,
				neonRole = "portal",
			})
			markSpin(piece, if index % 2 == 0 then -1.15 else 0.95, 0.08)
		end
	end

	local vfx = TownLook.PORTAL_VFX
	local up = Vector3.new(0, vfx.lift, 0)
	local down = Vector3.new(0, -vfx.fall, 0)
	addEmitter(
		disc,
		"Swirl",
		swirlSpec(TownLook.VORTEX_SWIRL_RATE, TownLook.VORTEX_SWIRL_LIFE, 0.8, 0.7, 28),
		spec.color,
		spec.id,
		"core",
		up
	)
	if detail then
		addEmitter(
			disc,
			"Sparks",
			swirlSpec(TownLook.VORTEX_SPARK_RATE, TownLook.VORTEX_SPARK_LIFE, 1.4, 0.24, 36),
			spec.color,
			spec.id,
			"extra",
			up
		)
		if spec.id == "WhisperingWoods" then
			addEmitter(disc, "Fireflies", vfx.firefly, "FlameGreen", spec.id, "extra", up)
		elseif spec.id == "SunkenMarsh" then
			addEmitter(disc, "Fog", vfx.fog, "Bone", spec.id, "extra", up)
			addEmitter(disc, "Drips", vfx.drip, "Spirit", spec.id, "extra", down)
		else
			addEmitter(disc, "Motes", vfx.mote, "Bone", spec.id, "extra", up)
			addEmitter(disc, "Embers", vfx.ember, "FlameOrange", spec.id, "extra", up)
		end
	end
	return disc
end

local function buildWoods(parent: Instance, pivot: any, detail: boolean)
	local trunkN = steps(detail, 16, 7)
	local crownN = steps(detail, 8, 4)
	local rootN = steps(detail, 6, 3)
	local rootCount = if detail then 5 else 2
	for _, side in { -1, 1 } do
		local trunk = samples(trunkN, function(t: number)
			local x = side * (3.45 - t * 2.15) + (wobble(t * 17 + side * 3) - 0.5) * 0.55
			local y = 0.35 + t * 8.7
			local z = side * 0.18 + math.sin(t * math.pi) * 0.42 + (wobble(t * 11 + side) - 0.5) * 0.35
			return Vector3.new(x, y, z)
		end)
		layChain(parent, pivot, "Trunk", trunk, 1.35, 0.55, WOOD, "Bark", false, true, "Bark", "Soot")
		local crown = samples(crownN, function(t: number)
			local x = side * 1.35 * (1 - t)
			local y = 8.9 + math.sin(t * math.pi) * 1.4
			local z = side * (1 - t) * 0.35
			return Vector3.new(x, y, z)
		end)
		layChain(parent, pivot, "Crown", crown, 0.62, 0.28, WOOD, "Bark", false, detail, "Bark", "Moss")
		for slot = 1, rootCount do
			local roots = samples(rootN, function(t: number)
				local zAim = -1.6 + (slot - 1) * 0.7
				local reach = 1.7 + (slot % 3) * 0.4
				local x = side * (3.15 + reach * t)
				local y = 0.65 + math.sin(t * math.pi) * 0.8 - t * 0.4
				local z = zAim * (0.25 + t)
				return Vector3.new(x, math.max(y, 0.12), z)
			end)
			layChain(parent, pivot, "RootSpur", roots, 0.55, 0.22, WOOD, "Bark", false, detail, "RootPlate", "Soot")
		end
		if detail then
			for slot = 1, 4 do
				local branch = samples(6, function(t: number)
					local y0 = 6.1 + slot * 0.55
					local z1 = -1.1 + (slot % 4) * 0.65
					local x = side * (2.1 + t * 2.4)
					local y = y0 + math.sin(t * math.pi) * 0.85 - t * 0.35
					return Vector3.new(x, math.min(y, 10.2), z1 * t)
				end)
				layChain(parent, pivot, "Branch", branch, 0.32, 0.12, WOOD, "Bark", true, true, "Twig", "Moss")
				local vine = samples(5, function(t: number)
					local x = side * (4.15 + (slot % 3) * 0.2) + math.sin(t * 6 + slot) * 0.12
					local y = 7.5 - slot * 0.25 - t * 3.1
					local z = -0.7 + (slot % 4) * 0.45
					return Vector3.new(x, y, z)
				end)
				layChain(parent, pivot, "Vine", vine, 0.1, 0.05, WOOD, "Moss", true, false, "Vine", "Moss")
			end
		end
	end
	local leaves = if detail then 16 else 6
	for index = 1, leaves do
		local angle = index / leaves * math.pi * 2
		local at = Vector3.new(math.cos(angle) * 2.15, 9.35 + (index % 3) * 0.32, math.sin(angle) * 1.3)
		local color = if index % 3 == 0 then "Rift" else "MossCanopy"
		ball(parent, pivot, "Leaf", at, 1.15 + (index % 3) * 0.18, BONE_MAT, color, true, nil)
	end
	if detail then
		for index = 1, 8 do
			local side = if index % 2 == 0 then 1 else -1
			local at = Vector3.new(side * (2.4 + (index % 3) * 0.35), 4.2 + (index % 4) * 1.1, 0.2 * side)
			local fly = ball(parent, pivot, "Firefly", at, 0.16, NEON, "FlameGreen", true, "portal")
			fly.Transparency = 0.15
		end
		for index = 1, 6 do
			local side = if index % 2 == 0 then 1 else -1
			ball(
				parent,
				pivot,
				"Knot",
				Vector3.new(side * (2.2 + index * 0.15), 1.4 + index * 1.15, 0.3),
				0.55,
				WOOD,
				"Soot",
				true,
				nil
			)
		end
	end
end

local function buildMarsh(parent: Instance, pivot: any, detail: boolean)
	local bodyN = steps(detail, 80, 18)
	local body = samples(bodyN, function(t: number)
		local along = if t < 0.5 then t * 2 else (1 - t) * 2
		local side = if t < 0.5 then -1 else 1
		local coil = t * math.pi * 2 * 3.25
		local x = side * 3.35 * math.cos(along * math.pi * 0.5) + math.cos(coil) * 0.16
		local y = 0.4 + 7.8 * math.sin(along * math.pi * 0.5) + math.sin(coil) * 0.1
		local z = 0.15 + math.sin(coil) * 0.48
		return Vector3.new(x, y, z)
	end)
	local span = #body - 1
	for index = 1, span do
		local t = (index - 1) / math.max(span - 1, 1)
		local diameter = 0.72 - t * 0.08
		local a = body[index]
		local b = body[index + 1]
		cylinderBetween(parent, pivot, "Coil", a, b, math.max(diameter, 0.4), STONE, "Stone", false, nil)
		if detail then
			local scaleColor = if index % 6 == 0 then "Spirit" elseif index % 2 == 0 then "Soot" else "Stone"
			local scaleMat = if index % 2 == 0 then COBBLE else STONE
			plateBetween(parent, pivot, "Scale", a, b, diameter * 1.55, diameter * 0.38, scaleMat, scaleColor)
			if index % 2 == 0 then
				plateBetween(parent, pivot, "Fin", a, b, diameter * 0.7, diameter * 0.95, STONE, "Soot")
			end
		end
	end

	ball(parent, pivot, "Cranium", Vector3.new(0, 8.15, -1.25), 2.8, STONE, "Stone", false, nil)
	place(parent, pivot, {
		name = "Brow",
		size = Vector3.new(2.4, 0.55, 1.1),
		cf = CFrame.new(0, 8.55, -2.15) * CFrame.Angles(math.rad(-18), 0, 0),
		material = STONE,
		color = "Soot",
		shadow = true,
	})
	place(parent, pivot, {
		className = "WedgePart",
		name = "Snout",
		size = Vector3.new(1.7, 1.15, 2.2),
		cf = CFrame.new(0, 7.55, -2.55) * CFrame.Angles(math.rad(18), 0, 0),
		material = STONE,
		color = "Stone",
		shadow = true,
	})
	place(parent, pivot, {
		name = "UpperJaw",
		size = Vector3.new(2.1, 0.42, 1.8),
		cf = CFrame.new(0, 7.15, -2.35) * CFrame.Angles(math.rad(12), 0, 0),
		material = COBBLE,
		color = "Stone",
		shadow = true,
	})
	place(parent, pivot, {
		className = "WedgePart",
		name = "LowerJaw",
		size = Vector3.new(1.9, 0.48, 1.7),
		cf = CFrame.new(0, 6.55, -2.15) * CFrame.Angles(math.rad(-28), 0, 0),
		material = STONE,
		color = "Soot",
		shadow = true,
	})
	for _, side in { -1, 1 } do
		local eye = ball(parent, pivot, "Eye", Vector3.new(side * 0.72, 8.15, -2.35), 0.42, NEON, "Spirit", true, "eye")
		eye.Transparency = 0.05
		if detail then
			addLight(eye, "EyeLight", "Spirit", TownLook.PORTAL_EYE_RANGE, TownLook.PORTAL_EYE_BRIGHTNESS)
		end
		place(parent, pivot, {
			name = "Fang",
			size = Vector3.new(0.16, 0.55, 0.16),
			cf = CFrame.new(side * 0.45, 6.85, -3.05) * CFrame.Angles(math.rad(16), 0, side * math.rad(8)),
			material = BONE_MAT,
			color = "Bone",
			decor = true,
			shadow = false,
		})
		place(parent, pivot, {
			name = "Fang",
			size = Vector3.new(0.14, 0.42, 0.14),
			cf = CFrame.new(side * 0.85, 6.7, -2.7) * CFrame.Angles(math.rad(20), 0, side * math.rad(-10)),
			material = BONE_MAT,
			color = "BoneDim",
			decor = true,
			shadow = false,
		})
		if detail then
			for tooth = 1, 3 do
				place(parent, pivot, {
					name = "Tooth",
					size = Vector3.new(0.1, 0.28, 0.1),
					cf = CFrame.new(side * (0.25 + tooth * 0.28), 6.95, -2.85),
					material = BONE_MAT,
					color = "Bone",
					decor = true,
					shadow = false,
				})
			end
			cylinderBetween(
				parent,
				pivot,
				"Horn",
				Vector3.new(side * 0.9, 8.6, -1.1),
				Vector3.new(side * 1.8, 9.5, -0.4),
				0.28,
				STONE,
				"Soot",
				true,
				nil
			)
		end
	end
	if detail then
		for index = 1, 6 do
			local side = if index % 2 == 0 then 1 else -1
			cylinderBetween(
				parent,
				pivot,
				"Drip",
				Vector3.new(side * 0.35 * index, 6.3, -2.4),
				Vector3.new(side * 0.35 * index, 5.5 - (index % 3) * 0.25, -2.55),
				0.06,
				STONE,
				"Spirit",
				true,
				nil
			)
		end
		for index = 1, 4 do
			local t = index / 5
			ball(parent, pivot, "Band", Vector3.new(0, 2.2 + t * 4.5, 0.2), 0.22, METAL, "Gold", true, nil)
		end
	end
end

local function ribPoints(side: number, spread: number, height: number, z: number, count: number, seed: number): { any }
	return samples(count, function(t: number)
		local x = side * spread * math.cos(t * math.pi * 0.5)
		local y = 0.32 + height * math.sin(t * math.pi * 0.5)
		local jx = (wobble(seed + t * 9) - 0.5) * 0.2
		local jz = (wobble(seed + 4 + t * 7) - 0.5) * 0.16
		return Vector3.new(x + jx, y, z + jz)
	end)
end

local function buildQuarry(parent: Instance, pivot: any, detail: boolean)
	local ribs = if detail then 7 else 4
	local ribN = steps(detail, 10, 5)
	for rib = 1, ribs do
		local z = (rib - (ribs + 1) / 2) * 0.42
		local spread = 3.75 - math.abs(z) * 0.18
		local height = 7.7 - math.abs(z) * 0.35
		for _, side in { -1, 1 } do
			local points = ribPoints(side, spread, height, z, ribN, rib * 5 + side)
			local color = if rib % 2 == 0 then "BoneDim" else "Bone"
			layChain(parent, pivot, "Rib", points, 0.68, 0.32, LIME, color, false, detail, "Ridge", "BoneDim")
		end
	end
	local spine = samples(steps(detail, 12, 6), function(t: number)
		local z = -1.5 + t * 3
		local y = 8.15 + math.sin(t * math.pi) * 0.35
		local x = (wobble(t * 6) - 0.5) * 0.12
		return Vector3.new(x, y, z)
	end)
	layChain(parent, pivot, "Spine", spine, 0.48, 0.36, LIME, "Bone", false, false, "Spine", "Bone")

	ball(parent, pivot, "Skull", Vector3.new(0, 9.15, -0.85), 1.7, BONE_MAT, "Bone", false, nil)
	place(parent, pivot, {
		className = "WedgePart",
		name = "SkullBrow",
		size = Vector3.new(1.5, 0.4, 0.7),
		cf = CFrame.new(0, 9.45, -1.45) * CFrame.Angles(math.rad(-16), 0, 0),
		material = BONE_MAT,
		color = "Bone",
		shadow = true,
	})
	place(parent, pivot, {
		name = "SkullJaw",
		size = Vector3.new(1.15, 0.38, 0.85),
		cf = CFrame.new(0, 8.45, -1.35) * CFrame.Angles(math.rad(12), 0, 0),
		material = LIME,
		color = "BoneDim",
		shadow = true,
	})
	for _, side in { -1, 1 } do
		ball(parent, pivot, "Socket", Vector3.new(side * 0.38, 9.15, -1.55), 0.32, BONE_MAT, "Void", true, nil)
		local glint =
			ball(parent, pivot, "Eye", Vector3.new(side * 0.38, 9.15, -1.68), 0.14, NEON, "FlameOrange", true, "eye")
		glint.Transparency = 0.1
		if detail then
			addLight(glint, "EyeLight", "FlameOrange", TownLook.PORTAL_EYE_RANGE, TownLook.PORTAL_EYE_BRIGHTNESS)
		end
		for tooth = 1, 3 do
			place(parent, pivot, {
				name = "Tooth",
				size = Vector3.new(0.08, 0.2, 0.08),
				cf = CFrame.new(side * (0.12 + tooth * 0.16), 8.22, -1.7),
				material = BONE_MAT,
				color = "Bone",
				decor = true,
				shadow = false,
			})
		end
		local clawN = if detail then 3 else 2
		for claw = 1, clawN do
			place(parent, pivot, {
				className = "WedgePart",
				name = "Claw",
				size = Vector3.new(0.28, 0.9, 0.22),
				cf = CFrame.new(side * (2.3 + claw * 0.28), 0.7, -0.85 + claw * 0.35)
					* CFrame.Angles(math.rad(55), 0, side * math.rad(28)),
				material = LIME,
				color = "Bone",
				shadow = true,
			})
		end
	end
	if detail then
		for index = 1, 5 do
			local side = if index % 2 == 0 then 1 else -1
			place(parent, pivot, {
				name = "Crack",
				size = Vector3.new(0.08, 0.7, 0.08),
				cf = CFrame.new(side * (0.4 + index * 0.15), 8.6, -0.4) * CFrame.Angles(0, 0, side * math.rad(18)),
				material = BONE_MAT,
				color = "Blood",
				decor = true,
				shadow = false,
			})
		end
		place(parent, pivot, {
			name = "BrowBand",
			size = Vector3.new(1.35, 0.08, 0.12),
			cf = CFrame.new(0, 9.7, -1.35),
			material = METAL,
			color = "Gold",
			decor = true,
			shadow = false,
		})
	end
end

local function moveTo(anchor: any, desired: any, parts: { any })
	if anchor == nil or anchor.CFrame == nil then
		return
	end
	local delta = desired * anchor.CFrame:Inverse()
	for _, piece in parts do
		if piece.CFrame ~= nil then
			piece.CFrame = delta * piece.CFrame
		end
	end
end

local function growPart(part: any)
	if part == nil or part.Size == nil or part:GetAttribute("PortalScaled") == true then
		return
	end
	part.Size = growSize(part.Size)
	part:SetAttribute("PortalScaled", true)
end

local function ensureSign(sign: any, id: string)
	if sign == nil then
		return
	end
	for _, inst in sign:GetDescendants() do
		if inst.Name == "SignText" then
			return
		end
	end
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 36
	gui.Parent = sign
	local label = Instance.new("TextLabel")
	label.Name = "SignText"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 0.62)
	label.Text = SIGN_COPY[id] or id
	label.TextColor3 = UITheme.color("Bone")
	label.TextScaled = true
	label.Parent = gui
	if id == "SunkenMarsh" then
		local level = Instance.new("TextLabel")
		level.Name = "SignText"
		level.BackgroundTransparency = 1
		level.Size = UDim2.fromScale(1, 0.32)
		level.Position = UDim2.fromScale(0, 0.64)
		level.Text = "Level 25+"
		level.TextColor3 = UITheme.color("Gold")
		level.TextScaled = true
		level.Parent = gui
	end
end

local function repositionKept(model: Instance, pivot: any, id: string)
	local signCf = growCf(SIGN_AT[id])
	if signCf == nil then
		return
	end
	local sign = findNamed(model, "Sign", "Part")
	local signParts = {}
	if sign ~= nil then
		table.insert(signParts, sign)
	end
	local trim = findNamed(model, "SignTrim", "Part")
	if trim ~= nil then
		table.insert(signParts, trim)
	end
	growPart(sign)
	growPart(trim)
	moveTo(sign, pivot * signCf, signParts)
	ensureSign(sign, id)

	local lock = findNamed(model, "LockIcon", "Model")
	local lockBody = findNamed(model, "LockBody", "Part")
	local lockParts = {}
	if lockBody ~= nil then
		table.insert(lockParts, lockBody)
	end
	if lock ~= nil then
		for _, inst in lock:GetDescendants() do
			if inst ~= lockBody and inst.CFrame ~= nil and inst.ClassName == "Part" then
				table.insert(lockParts, inst)
			end
		end
	end
	moveTo(lockBody, pivot * signCf * CFrame.new(LOCK_X, 0, 0), lockParts)
end

local function quietLights(model: Instance)
	for _, inst in model:GetDescendants() do
		local className = inst.ClassName
		if className == "PointLight" or className == "SpotLight" or className == "SurfaceLight" then
			inst.Shadows = false
		end
	end
end

local function bindModuleSpin(model: Instance, axis: any)
	local parts = {}
	local relative = {}
	local speed = {}
	for _, inst in model:GetDescendants() do
		local className = inst.ClassName
		local isPart = className == "Part" or className == "WedgePart"
		if inst:GetAttribute("TownSpin") == true and isPart and inst.CFrame ~= nil and axis.CFrame ~= nil then
			table.insert(parts, inst)
			relative[#parts] = axis.CFrame:Inverse() * inst.CFrame
			local rate = inst:GetAttribute("SpinSpeed")
			speed[#parts] = if type(rate) == "number" then rate else 0.6
		end
	end
	local spun = 0
	Kit.animate(model, function(dt: number, elapsed: number)
		if type(elapsed) ~= "number" then
			return
		end
		local step = if type(dt) == "number" then dt else 0
		spun += step
		if axis == nil or axis.CFrame == nil then
			return
		end
		for index, part in parts do
			local offset = relative[index]
			if offset ~= nil and part.CFrame ~= nil then
				part.CFrame = axis.CFrame * CFrame.Angles(speed[index] * spun, 0, 0) * offset
			end
		end
	end)
end

local function attachSpin(model: Instance, axis: any)
	local animator = Instance.new("Script")
	animator.Name = "VortexSpin"
	local wrote = pcall(function()
		animator.Source = SPIN_SOURCE
	end)
	if wrote then
		animator.Parent = model
		return
	end
	animator:Destroy()
	bindModuleSpin(model, axis)
end

local function replaceOne(townFolder: Instance, spec: any, level: number, detail: boolean): any
	local model = findNamed(townFolder, spec.id, "Model")
	if model == nil or model:GetAttribute("TownKit") == "Portals" then
		return nil
	end
	local beforeParts = Kit.countParts(model)
	local beforeLights = Kit.countLights(model)
	local beforeEmitters = Kit.countEmitters(model)

	local kept = {}
	for _, inst in model:GetDescendants() do
		if inst.ClassName == "ProximityPrompt" or inst.ClassName == "SpawnLocation" then
			table.insert(kept, inst)
		end
	end
	for _, inst in kept do
		inst.Parent = model
	end

	local root = model.PrimaryPart or findNamed(model, "Root", "Part")
	local names = BLOCKOUT[spec.kind]
	if names == nil then
		error("Unknown Hollowmere portal: " .. tostring(spec.kind), 2)
	end
	local doomed = {}
	for _, inst in model:GetDescendants() do
		if inst ~= root and names[inst.Name] == true and inst:GetAttribute(Kit.PART_ATTRIBUTE) ~= true then
			if DOOM_CLASS[inst.ClassName] == true then
				table.insert(doomed, inst)
			end
		end
	end
	for _, inst in doomed do
		inst:Destroy()
	end

	local pivot = if root ~= nil and root.CFrame ~= nil then root.CFrame else CFrame.new()
	local folder = Instance.new("Folder")
	folder.Name = "Arch"
	folder.Parent = model
	local function phase(stepName: string, fn: () -> ())
		Kit.step("Portals", stepName, fn)
	end
	phase("arch", function()
		if spec.kind == "tree" then
			buildWoods(folder, pivot, detail)
		elseif spec.kind == "serpent" then
			buildMarsh(folder, pivot, detail)
		else
			buildQuarry(folder, pivot, detail)
		end
	end)
	local vortex = nil
	phase("vortex", function()
		vortex = buildVortex(folder, pivot, spec, detail)
	end)
	phase("sign", function()
		repositionKept(model, pivot, spec.id)
	end)
	attachSpin(model, vortex)
	quietLights(model)

	local afterParts = Kit.countParts(model)
	local afterLights = Kit.countLights(model)
	local afterEmitters = Kit.countEmitters(model)
	model:SetAttribute("TownKit", "Portals")
	model:SetAttribute("KitQuality", level)
	model:SetAttribute("KitDetail", detail)
	model:SetAttribute("KitBeforeParts", beforeParts)
	model:SetAttribute("KitAfterParts", afterParts)
	model:SetAttribute("KitBeforeLights", beforeLights)
	model:SetAttribute("KitAfterLights", afterLights)
	model:SetAttribute("KitBeforeEmitters", beforeEmitters)
	model:SetAttribute("KitAfterEmitters", afterEmitters)
	return {
		id = spec.id,
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

function Portals.replace(townFolder: Instance, refs: any): any
	local level = Kit.resolveQuality(refs)
	local detail = Kit.detailEnabled(level)
	local reports = {}
	for _, spec in TownLook.PORTALS do
		local report = replaceOne(townFolder, spec, level, detail)
		if report ~= nil then
			table.insert(reports, report)
		end
	end
	if #reports == 0 then
		return nil
	end
	local summed = {
		id = "Portals",
		quality = level,
		detail = detail,
		beforeParts = 0,
		afterParts = 0,
		beforeLights = 0,
		afterLights = 0,
		beforeEmitters = 0,
		afterEmitters = 0,
		portals = reports,
	}
	for _, report in reports do
		summed.beforeParts += report.beforeParts
		summed.afterParts += report.afterParts
		summed.beforeLights += report.beforeLights
		summed.afterLights += report.afterLights
		summed.beforeEmitters += report.beforeEmitters
		summed.afterEmitters += report.afterEmitters
	end
	return summed
end

Portals.name = "Portals"
Portals.order = 4

return Portals
