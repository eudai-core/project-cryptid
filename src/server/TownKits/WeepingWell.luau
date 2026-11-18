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
local Town = import("../../shared/Config/Town", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Town")
end) :: any
local TownLook = import("../../shared/Config/TownLook", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("TownLook")
end) :: any
local UITheme = import("../../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any

local WeepingWell = {}

local MODEL_NAME = "WeepingWell"
local STONE = UITheme.materials.altar
local WOOD = UITheme.materials.wood
local METAL = UITheme.materials.iron
local GLASS = UITheme.materials.glass
local NEON = UITheme.materials.neon

local BLOCKOUT = {
	Stone = true,
	WellWater = true,
}

local RING_COUNT = 8
local POST_HEIGHT = 5.5
local POST_THICKNESS = 0.62
local POST_SINK = 0.2
local LINTEL_HEIGHT = 0.52
local LINTEL_DEPTH = 0.7
local ROOF_RISE = 1.65
local ROOF_OVERHANG = 0.45
local ROOF_CAP = 0.7
local HANG = 2.05
local BUCKET_HEIGHT = 1.2
local BUCKET_DIAMETER = 1.45
local CHAIN_DIAMETER = 0.16
local WATER_THICKNESS = 0.4
local WATER_CENTER_Y = 0.2
local DRIP_CLEARANCE = 0.22
local RUNE_Y = 0.55
local WEEP_Y = -0.72

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

local function addGlow(parent: Instance, name: string, range: number, brightness: number)
	local light = Instance.new("PointLight")
	light.Name = name
	light.Color = UITheme.color("Spirit")
	light.Range = range
	light.Brightness = brightness
	light.Shadows = false
	light.Parent = parent
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

local function ringMetrics(): any
	local outer = Town.WELL_DIAMETER / 2
	local half = math.pi / RING_COUNT
	local face = outer * math.cos(half)
	local thickness = (Town.WELL_DIAMETER - Town.WELL_WATER_DIAMETER) / 2
	return {
		face = face,
		thickness = thickness,
		width = 2 * outer * math.sin(half),
		midR = face - thickness / 2,
		height = Town.WELL_HEIGHT,
	}
end

local function buildRing(parent: Instance, pivot: any, metrics: any)
	for index = 0, RING_COUNT - 1 do
		local theta = index * (2 * math.pi / RING_COUNT)
		local at = Vector3.new(math.sin(theta) * metrics.midR, 0, math.cos(theta) * metrics.midR)
		place(parent, pivot, {
			name = "Voussoir",
			size = Vector3.new(metrics.width, metrics.height, metrics.thickness),
			cf = CFrame.lookAt(at, Vector3.new(0, 0, 0)),
			material = STONE,
			color = "Stone",
		})
	end
end

local function buildBasin(parent: Instance, pivot: any)
	local water = place(parent, pivot, {
		name = "Water",
		size = Vector3.new(WATER_THICKNESS, Town.WELL_WATER_DIAMETER, Town.WELL_WATER_DIAMETER),
		cf = CFrame.new(0, WATER_CENTER_Y, 0) * CFrame.Angles(0, 0, math.rad(90)),
		material = GLASS,
		color = "Void",
		shape = Enum.PartType.Cylinder,
	})
	water:SetAttribute("TownAnchor", "Basin")
	addGlow(water, "WaterGlow", TownLook.WELL_WATER_GLOW_RANGE, TownLook.WELL_WATER_GLOW_BRIGHTNESS)
end

local function buildFrame(parent: Instance, pivot: any, metrics: any)
	local rim = metrics.height / 2
	local postCenter = rim - POST_SINK + POST_HEIGHT / 2
	local postTop = postCenter + POST_HEIGHT / 2
	local lintelCenter = postTop + LINTEL_HEIGHT / 2
	local lintelTop = postTop + LINTEL_HEIGHT
	local lintelLength = metrics.midR * 2 + POST_THICKNESS
	local roofSpan = lintelLength + ROOF_CAP
	local run = metrics.face + ROOF_OVERHANG
	local roofCenter = lintelTop + ROOF_RISE / 2
	local peak = lintelTop + ROOF_RISE
	for _, side in { -1, 1 } do
		place(parent, pivot, {
			name = "Post",
			size = Vector3.new(POST_THICKNESS, POST_HEIGHT, POST_THICKNESS),
			cf = CFrame.new(0, postCenter, side * metrics.midR),
			material = WOOD,
			color = "Bark",
		})
	end
	place(parent, pivot, {
		name = "Lintel",
		size = Vector3.new(LINTEL_DEPTH, LINTEL_HEIGHT, lintelLength),
		cf = CFrame.new(0, lintelCenter, 0),
		material = WOOD,
		color = "Bark",
	})
	for _, side in { -1, 1 } do
		local yaw = if side > 0 then math.rad(90) else math.rad(-90)
		place(parent, pivot, {
			className = "WedgePart",
			name = "Roof",
			size = Vector3.new(roofSpan, ROOF_RISE, run),
			cf = CFrame.new(side * run / 2, roofCenter, 0) * CFrame.Angles(0, yaw, 0),
			material = WOOD,
			color = "ShipWood",
			decor = true,
			shadow = true,
		})
	end
	place(parent, pivot, {
		name = "Ridge",
		size = Vector3.new(0.4, 0.32, roofSpan),
		cf = CFrame.new(0, peak, 0),
		material = WOOD,
		color = "Bark",
		decor = true,
		shadow = true,
	})
	local bucketTop = postTop - HANG
	local bucketCenter = bucketTop - BUCKET_HEIGHT / 2
	place(parent, pivot, {
		name = "Bucket",
		size = Vector3.new(BUCKET_HEIGHT, BUCKET_DIAMETER, BUCKET_DIAMETER),
		cf = CFrame.new(0, bucketCenter, 0) * CFrame.Angles(0, 0, math.rad(90)),
		material = WOOD,
		color = "ShipWood",
		decor = true,
		shadow = true,
		shape = Enum.PartType.Cylinder,
	})
	for _, side in { -1, 1 } do
		local z = side * 0.24
		cylinderBetween(
			parent,
			pivot,
			"Chain",
			Vector3.new(0, postTop - 0.02, z),
			Vector3.new(0, bucketTop, z * 0.85),
			CHAIN_DIAMETER,
			METAL,
			"Gold",
			true,
			false
		)
	end
end

local function buildOrnament(parent: Instance, pivot: any, metrics: any)
	local runeR = metrics.face + 0.12
	local weepR = metrics.face + 0.08
	for index = 0, RING_COUNT - 1 do
		local theta = index * (2 * math.pi / RING_COUNT)
		local outward = Vector3.new(math.sin(theta), 0, math.cos(theta))
		local runeAt = outward * runeR + Vector3.new(0, RUNE_Y, 0)
		local rune = place(parent, pivot, {
			name = "Rune",
			size = Vector3.new(0.85, 1.05, 0.16),
			cf = CFrame.lookAt(runeAt, Vector3.new(0, RUNE_Y, 0)),
			material = NEON,
			color = "Spirit",
			decor = true,
			shadow = false,
			neonRole = "rune",
		})
		addGlow(rune, "RuneGlow", TownLook.WELL_RUNE_GLOW_RANGE, TownLook.WELL_RUNE_GLOW_BRIGHTNESS)
		if index % 2 == 0 then
			local weepAt = outward * weepR + Vector3.new(0, WEEP_Y, 0)
			place(parent, pivot, {
				name = "Weep",
				size = Vector3.new(0.2, 1.15, 0.1),
				cf = CFrame.lookAt(weepAt, Vector3.new(0, WEEP_Y, 0)),
				material = STONE,
				color = "Ash",
				decor = true,
				shadow = false,
			})
		end
	end
	local waterTop = WATER_CENTER_Y + WATER_THICKNESS / 2
	place(parent, pivot, {
		name = "Glint",
		size = Vector3.new(0.06, 1.55, 1.55),
		cf = CFrame.new(0, waterTop + 0.05, 0) * CFrame.Angles(0, 0, math.rad(90)),
		material = NEON,
		color = "Spirit",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
		neonRole = "rune",
	})
	local rim = metrics.height / 2
	local postTop = rim - POST_SINK + POST_HEIGHT
	place(parent, pivot, {
		name = "Sigil",
		size = Vector3.new(0.08, 0.48, 0.7),
		cf = CFrame.new(-(LINTEL_DEPTH / 2 + 0.05), postTop + LINTEL_HEIGHT / 2, 0),
		material = STONE,
		color = "Blood",
		decor = true,
		shadow = false,
	})
	local bucketTop = postTop - HANG
	place(parent, pivot, {
		name = "Hoop",
		size = Vector3.new(0.16, BUCKET_DIAMETER + 0.18, BUCKET_DIAMETER + 0.18),
		cf = CFrame.new(0, bucketTop - 0.08, 0) * CFrame.Angles(0, 0, math.rad(90)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
end

local function seatDrip(model: Instance, pivot: any)
	local drip = findNamed(model, "WellDrip", "Part")
	if drip == nil then
		return
	end
	local surface = WATER_CENTER_Y + WATER_THICKNESS / 2 + DRIP_CLEARANCE
	drip.CFrame = pivot * CFrame.new(0, surface, 0)
end

local function quietLights(model: Instance)
	for _, inst in model:GetDescendants() do
		local className = inst.ClassName
		if className == "PointLight" or className == "SpotLight" or className == "SurfaceLight" then
			inst.Shadows = false
		end
	end
end

local function stripEmitters(model: Instance)
	local doomed = {}
	for _, inst in model:GetDescendants() do
		if inst.ClassName == "ParticleEmitter" then
			table.insert(doomed, inst)
		end
	end
	for _, inst in doomed do
		inst:Destroy()
	end
end

function WeepingWell.replace(townFolder: Instance, refs: any): any
	local model = findNamed(townFolder, MODEL_NAME, "Model")
	if model == nil or model:GetAttribute("TownKit") == "WeepingWell" then
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

	local doomed = {}
	for _, inst in model:GetDescendants() do
		if BLOCKOUT[inst.Name] == true and inst:GetAttribute(Kit.PART_ATTRIBUTE) ~= true then
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

	local root = model.PrimaryPart or findNamed(model, "Centre", "Part")
	local pivot = if root ~= nil and root.CFrame ~= nil then root.CFrame else CFrame.new()
	local folder = Instance.new("Folder")
	folder.Name = "Frame"
	folder.Parent = model

	local metrics = ringMetrics()
	buildRing(folder, pivot, metrics)
	buildBasin(folder, pivot)
	buildFrame(folder, pivot, metrics)
	if detail then
		buildOrnament(folder, pivot, metrics)
	end
	seatDrip(model, pivot)
	if not detail then
		stripEmitters(model)
	end
	quietLights(model)

	local centre = findNamed(model, "Centre", "Part")
	if centre ~= nil then
		centre:SetAttribute("TownAnchor", "Well")
	end
	local basin = findNamed(folder, "Water", "Part")
	for _, prompt in prompts do
		prompt.Parent = if basin ~= nil then basin else model
	end

	local afterParts = Kit.countParts(model)
	local afterLights = Kit.countLights(model)
	local afterEmitters = Kit.countEmitters(model)
	model:SetAttribute("TownKit", "WeepingWell")
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

return WeepingWell
