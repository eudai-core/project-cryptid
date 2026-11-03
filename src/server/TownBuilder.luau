--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Lair = require(Shared:WaitForChild("Config"):WaitForChild("Lair")) :: any
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local Shop = require(Shared:WaitForChild("Config"):WaitForChild("Shop")) :: any
local Town = require(Shared:WaitForChild("Config"):WaitForChild("Town")) :: any
local TownLayout = require(Shared:WaitForChild("Logic"):WaitForChild("TownLayout")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local TownBuilder = {}

local function material(name: string): Enum.Material
	return Enum.Material[name]
end

local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	cf: CFrame,
	materialName: string,
	colorToken: string,
	collide: boolean
): Part
	local piece = Instance.new("Part")
	piece.Name = name
	piece.Anchored = true
	piece.Size = size
	piece.CFrame = cf
	piece.Material = material(materialName)
	piece.Color = UITheme.color(colorToken)
	piece.TopSurface = Enum.SurfaceType.Smooth
	piece.BottomSurface = Enum.SurfaceType.Smooth
	piece.CanCollide = collide
	piece.CanTouch = collide
	piece.CastShadow = true
	piece.Parent = parent
	return piece
end

local function cylinder(piece: Part)
	piece.Shape = Enum.PartType.Cylinder
end

local function uprightCylinder(piece: Part, cf: CFrame)
	cylinder(piece)
	piece.CFrame = cf * CFrame.Angles(0, 0, math.rad(90))
end

local function sign(parent: Instance, cf: CFrame, text: string, colorToken: string)
	local board =
		part(parent, "Sign", Vector3.new(Town.STALL_WIDTH * 0.62, 2.2, 0.28), cf, UITheme.materials.wood, "Ash", false)
	part(
		parent,
		"SignTrim",
		Vector3.new(Town.STALL_WIDTH * 0.66, 2.5, 0.16),
		cf * CFrame.new(0, 0, 0.12),
		UITheme.materials.iron,
		"Gold",
		false
	)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Name = "SignText"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Text = text
	label.TextColor3 = UITheme.color(colorToken)
	label.TextScaled = false
	label.TextSize = UITheme.text.minSize
	label.TextWrapped = true
	label:SetAttribute("TownSign", true)
	label.Parent = gui
end

local function plate(host: BasePart, kind: string, actionText: string)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = kind
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = Town.PROMPT_DISTANCE
	prompt.ClickablePrompt = true
	prompt.ActionText = actionText
	prompt:SetAttribute("Public", true)
	prompt:SetAttribute("Kind", kind)
	prompt:SetAttribute("Available", true)
	prompt:SetAttribute("OwnerUserId", 0)
	prompt.Parent = host
end

local function sinkGround(town: Folder)
	local ground = town:FindFirstChild("Ground")
	if ground == nil or not ground:IsA("BasePart") then
		return
	end
	local substrateTop = Town.FLOOR_Y - Town.COBBLE_THICKNESS
	ground.CFrame = CFrame.new(0, substrateTop - ground.Size.X / 2, 0) * CFrame.Angles(0, 0, math.rad(90))
end

local function berm(town: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "Berm"
	folder.Parent = town
	local inner = Plots.TOWN_RADIUS
	local outer = Plots.GROUND_RADIUS
	local segments = Town.BERM_SEGMENTS
	local angle = (2 * math.pi) / segments
	local length = outer - inner
	local mid = (inner + outer) / 2
	local width = 2 * outer * math.sin(angle / 2) + 0.4
	local substrateTop = Town.FLOOR_Y - Town.COBBLE_THICKNESS
	local height = Town.OUTER_SURFACE - substrateTop
	local y = substrateTop + height / 2
	for index = 1, segments do
		local theta = (index - 0.5) * angle
		local x = mid * math.sin(theta)
		local z = mid * math.cos(theta)
		local cf = CFrame.lookAt(Vector3.new(x, y, z), Vector3.new(0, y, 0))
		part(folder, "Berm", Vector3.new(width, height, length), cf, UITheme.materials.floor, "Wall", true)
	end
end

local function cobble(town: Folder)
	local thickness = Town.COBBLE_THICKNESS
	local diameter = Plots.TOWN_RADIUS * 2
	local disc = part(
		town,
		"Cobble",
		Vector3.new(thickness, diameter, diameter),
		CFrame.new(0, Town.FLOOR_Y - thickness / 2, 0),
		UITheme.materials.cobble,
		"Soot",
		true
	)
	uprightCylinder(disc, CFrame.new(0, Town.FLOOR_Y - thickness / 2, 0))
end

local function candleAt(parent: Instance, position: Vector3): PointLight
	local stick = part(
		parent,
		"Candle",
		Vector3.new(Lair.CANDLE_STICK.y, Lair.CANDLE_STICK.x, Lair.CANDLE_STICK.z),
		CFrame.new(position + Vector3.new(0, Lair.CANDLE_STICK.y / 2, 0)),
		UITheme.materials.candle,
		"Bone",
		false
	)
	uprightCylinder(stick, CFrame.new(position + Vector3.new(0, Lair.CANDLE_STICK.y / 2, 0)))
	local flame = part(
		parent,
		"Flame",
		Vector3.new(Lair.CANDLE_FLAME.x, Lair.CANDLE_FLAME.y, Lair.CANDLE_FLAME.z),
		CFrame.new(position + Vector3.new(0, Lair.CANDLE_STICK.y + Lair.CANDLE_FLAME.y / 2, 0)),
		UITheme.materials.candle,
		"Candle",
		false
	)
	local light = Instance.new("PointLight")
	light.Color = UITheme.color("Candle")
	light.Range = Town.WELL_LIGHT_RANGE
	light.Brightness = Town.WELL_LIGHT_BRIGHTNESS
	light.Shadows = true
	light.Parent = flame
	return light
end

local function well(town: Folder)
	local model = Instance.new("Model")
	model.Name = "WeepingWell"
	local centre =
		part(model, "Centre", Vector3.new(1, 1, 1), CFrame.new(0, 0, 0), UITheme.materials.altar, "Wall", false)
	centre.Transparency = 1
	centre.CanQuery = false
	model.PrimaryPart = centre
	local stone = part(
		model,
		"Stone",
		Vector3.new(Town.WELL_HEIGHT, Town.WELL_DIAMETER, Town.WELL_DIAMETER),
		CFrame.new(0, 0, 0),
		UITheme.materials.altar,
		"Wall",
		true
	)
	uprightCylinder(stone, CFrame.new(0, 0, 0))
	local water = part(
		model,
		"WellWater",
		Vector3.new(0.4, Town.WELL_WATER_DIAMETER, Town.WELL_WATER_DIAMETER),
		CFrame.new(0, -0.4, 0),
		UITheme.materials.floor,
		"Ash",
		false
	)
	uprightCylinder(water, CFrame.new(0, -0.4, 0))
	local drip = part(
		model,
		"WellDrip",
		Vector3.new(0.4, 0.4, 0.4),
		CFrame.new(0, 0.7, 0),
		UITheme.materials.floor,
		"Ash",
		false
	)
	drip.Transparency = 1
	drip.CanQuery = false
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Drip"
	emitter.Rate = 5
	emitter.Lifetime = NumberRange.new(0.8, 1.3)
	emitter.Speed = NumberRange.new(0.4, 1)
	emitter.SpreadAngle = Vector2.new(10, 10)
	emitter.Acceleration = Vector3.new(0, -10, 0)
	emitter.EmissionDirection = Enum.NormalId.Bottom
	emitter.Color = ColorSequence.new(UITheme.color("Ash"))
	emitter.Size = NumberSequence.new(0.12)
	emitter.Transparency = NumberSequence.new(0.25)
	emitter.LightEmission = 0
	emitter.Parent = drip
	local rim = Town.WELL_HEIGHT / 2
	for index = 1, Town.WELL_CANDLES do
		local theta = (index - 1) * (2 * math.pi / Town.WELL_CANDLES)
		candleAt(
			model,
			Vector3.new(Town.WELL_CANDLE_RADIUS * math.sin(theta), rim, Town.WELL_CANDLE_RADIUS * math.cos(theta))
		)
	end
	model.Parent = town
end

local function roads(town: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "Roads"
	folder.Parent = town
	local inner = Town.ROAD_INNER
	local outer = Plots.TOWN_RADIUS - Town.RAMP_LENGTH
	local length = outer - inner
	local mid = (inner + outer) / 2
	local roadY = Town.FLOOR_Y + Town.ROAD_THICKNESS / 2
	for index = 1, Plots.COUNT do
		local theta = math.rad(TownLayout.roadAngle(index))
		local x = mid * math.sin(theta)
		local z = mid * math.cos(theta)
		local cf = CFrame.lookAt(Vector3.new(x, roadY, z), Vector3.new(0, roadY, 0))
		part(
			folder,
			"TownRoad",
			Vector3.new(Town.ROAD_WIDTH, Town.ROAD_THICKNESS, length),
			cf,
			UITheme.materials.cobble,
			"Soot",
			true
		)
		local rampMid = Plots.TOWN_RADIUS - Town.RAMP_LENGTH / 2
		local drop = Town.OUTER_SURFACE - Town.FLOOR_Y
		local pitch = math.atan(drop / Town.RAMP_LENGTH)
		local rampY = (Town.OUTER_SURFACE + Town.FLOOR_Y) / 2
		local rx = rampMid * math.sin(theta)
		local rz = rampMid * math.cos(theta)
		local rampCf = CFrame.lookAt(Vector3.new(rx, rampY, rz), Vector3.new(0, rampY, 0)) * CFrame.Angles(pitch, 0, 0)
		part(
			folder,
			"TownRamp",
			Vector3.new(Town.ROAD_WIDTH, Town.ROAD_THICKNESS, Town.RAMP_LENGTH),
			rampCf,
			UITheme.materials.cobble,
			"Soot",
			true
		)
	end
end

local function wall(town: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "Wall"
	folder.Parent = town
	local radius = Plots.TOWN_RADIUS
	local count = math.floor((2 * math.pi * radius) / Town.WALL_SEGMENT)
	local step = (2 * math.pi) / count
	local half = TownLayout.openingHalfAngle()
	local margin = (Town.WALL_SEGMENT / radius) * 0.5
	local width = radius * step + 0.2
	for index = 1, count do
		local angle = (index - 0.5) * step
		local open = false
		for road = 1, Plots.COUNT do
			local center = math.rad(TownLayout.roadAngle(road))
			local delta = math.abs(math.atan2(math.sin(angle - center), math.cos(angle - center)))
			if delta <= half + margin then
				open = true
				break
			end
		end
		if not open then
			local scale = 0.72 + 0.28 * ((index % 5) / 4)
			local height = Town.WALL_HEIGHT * scale
			local y = Town.FLOOR_Y + height / 2
			local x = radius * math.sin(angle)
			local z = radius * math.cos(angle)
			local cf = CFrame.lookAt(Vector3.new(x, y, z), Vector3.new(0, y, 0))
			part(
				folder,
				"TownWall",
				Vector3.new(width, height, Town.WALL_THICKNESS),
				cf,
				UITheme.materials.wall,
				"Wall",
				true
			)
		end
	end
end

local function flicker(light: PointLight)
	task.spawn(function()
		while light.Parent ~= nil do
			local dip = Town.FLICKER_MIN + math.random() * (Town.FLICKER_MAX - Town.FLICKER_MIN)
			light.Brightness = Town.LAMP_DIP_BRIGHTNESS
			task.wait(dip)
			if light.Parent == nil then
				break
			end
			light.Brightness = Town.LAMP_BRIGHTNESS
			task.wait(Town.FLICKER_GAP)
		end
	end)
end

local function lamps(town: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "Lamps"
	folder.Parent = town
	local radius = TownLayout.lampRadius()
	local y = Town.FLOOR_Y + Town.LAMP_HEIGHT / 2
	for index = 1, Town.LAMP_COUNT do
		local theta = (index - 1) * (2 * math.pi / Town.LAMP_COUNT)
		local position = Vector3.new(radius * math.sin(theta), y, radius * math.cos(theta))
		local post = part(
			folder,
			"LampPost",
			Vector3.new(Town.LAMP_HEIGHT, 0.45, 0.45),
			CFrame.new(position),
			UITheme.materials.iron,
			"Wall",
			true
		)
		uprightCylinder(post, CFrame.new(position))
		local headCf = CFrame.new(position + Vector3.new(0, Town.LAMP_HEIGHT / 2 + 0.6, 0))
		local head = part(folder, "Lamp", Vector3.new(1.1, 1.3, 1.1), headCf, UITheme.materials.iron, "Ash", false)
		local light = Instance.new("PointLight")
		light.Color = UITheme.color("Candle")
		light.Range = Town.LAMP_RANGE
		light.Brightness = Town.LAMP_BRIGHTNESS
		light.Shadows = true
		light.Parent = head
		if index % Town.FLICKER_STRIDE == 0 then
			flicker(light)
		end
	end
end

local function placeModel(model: Model, cf: CFrame)
	model:PivotTo(cf)
end

local function districtCf(index: number, lean: boolean): CFrame
	local place = TownLayout.district(index)
	local cf = CFrame.lookAt(Vector3.new(place.x, place.y, place.z), Vector3.new(0, place.y, 0))
	if lean then
		cf = cf * CFrame.Angles(0, 0, math.rad(TownLayout.leanDegrees(index)))
	end
	return cf
end

local function banner(model: Model)
	part(
		model,
		"Banner",
		Vector3.new(0.2, Town.BANNER_HEIGHT, Town.BANNER_WIDTH),
		CFrame.new(Town.STALL_WIDTH / 2, 4.2, 0) * CFrame.Angles(0, 0, math.rad(8)),
		UITheme.materials.cloth,
		"Blood",
		false
	)
end

local function buildStall(parent: Folder, spec: any, index: number)
	local model = Instance.new("Model")
	model.Name = spec.id
	local root = part(model, "Root", Vector3.new(1, 1, 1), CFrame.new(), UITheme.materials.wood, "Wall", false)
	root.Transparency = 1
	root.CanQuery = false
	model.PrimaryPart = root
	local floor = part(
		model,
		"Floor",
		Vector3.new(Town.STALL_WIDTH, 0.4, Town.STALL_DEPTH),
		CFrame.new(0, 0.2, 0),
		UITheme.materials.wood,
		"Wall",
		true
	)
	part(
		model,
		"Counter",
		Vector3.new(Town.STALL_WIDTH - 1, 3, 3.2),
		CFrame.new(0, 1.9, -Town.STALL_DEPTH / 2 + 2.2),
		UITheme.materials.wood,
		"Ash",
		true
	)
	part(
		model,
		"Roof",
		Vector3.new(Town.STALL_WIDTH + 1.4, 0.45, Town.STALL_DEPTH + 1.2),
		CFrame.new(0, Town.STALL_HEIGHT, 0) * CFrame.Angles(math.rad(-4), 0, 0),
		UITheme.materials.floor,
		"Wall",
		true
	)
	part(
		model,
		"PostLeft",
		Vector3.new(0.45, Town.STALL_HEIGHT, 0.45),
		CFrame.new(-Town.STALL_WIDTH / 2 + 0.4, Town.STALL_HEIGHT / 2, -Town.STALL_DEPTH / 2 + 0.4),
		UITheme.materials.wood,
		"Wall",
		true
	)
	part(
		model,
		"PostRight",
		Vector3.new(0.45, Town.STALL_HEIGHT, 0.45),
		CFrame.new(Town.STALL_WIDTH / 2 - 0.4, Town.STALL_HEIGHT / 2, -Town.STALL_DEPTH / 2 + 0.4),
		UITheme.materials.wood,
		"Wall",
		true
	)
	banner(model)
	local signCf = CFrame.new(0, Town.STALL_HEIGHT - 1.2, -Town.STALL_DEPTH / 2 - 0.2)
	if spec.status == "shuttered" then
		part(
			model,
			"Shutter",
			Vector3.new(Town.STALL_WIDTH - 0.6, 3.4, 0.25),
			CFrame.new(0, 2.2, -Town.STALL_DEPTH / 2 + 0.4),
			UITheme.materials.cloth,
			"Blood",
			false
		)
		sign(model, signCf, Town.SHUTTERED, "BoneDim")
	else
		sign(model, signCf, spec.name, "Bone")
	end
	if spec.kind == "pedlar" then
		local lantern = part(
			model,
			"PedlarLantern",
			Vector3.new(0.9, 1.2, 0.9),
			CFrame.new(0, Town.STALL_HEIGHT - 1.6, -Town.STALL_DEPTH / 2 - 1.1),
			UITheme.materials.iron,
			"Ash",
			false
		)
		local light = Instance.new("PointLight")
		light.Name = "StockLight"
		light.Color = UITheme.color("Candle")
		light.Range = Town.LAMP_RANGE
		light.Brightness = Town.LAMP_BRIGHTNESS
		light.Shadows = true
		light.Parent = lantern
		CollectionService:AddTag(lantern, "PedlarLantern")
		CollectionService:AddTag(model, "PedlarStall")
		plate(floor, "Pedlar", Shop.PROMPT)
	end
	model.Parent = parent
	placeModel(model, districtCf(index, true))
end

local function buildShrine(parent: Folder, spec: any, index: number)
	local model = Instance.new("Model")
	model.Name = spec.id
	local root = part(model, "Root", Vector3.new(1, 1, 1), CFrame.new(), UITheme.materials.altar, "Wall", false)
	root.Transparency = 1
	root.CanQuery = false
	model.PrimaryPart = root
	local plinth =
		part(model, "Plinth", Vector3.new(8, 1.2, 8), CFrame.new(0, 0.6, 0), UITheme.materials.altar, "Wall", true)
	part(model, "Pillar", Vector3.new(2.2, 6.5, 2.2), CFrame.new(0, 4.4, 0.6), UITheme.materials.altar, "Ash", true)
	part(model, "Capital", Vector3.new(3.4, 0.5, 3.4), CFrame.new(0, 7.8, 0.6), UITheme.materials.altar, "Wall", true)
	banner(model)
	sign(model, CFrame.new(0, 3.2, -3.6), spec.name, "Bone")
	for side = -1, 1, 2 do
		candleAt(model, Vector3.new(side * 2.4, 1.2, -2.2))
	end
	CollectionService:AddTag(model, "SkillShrine")
	plate(plinth, "SkillShrine", Town.SHRINE_PROMPT)
	model.Parent = parent
	placeModel(model, districtCf(index, true))
end

local function cornerPosts(host: BasePart, height: number)
	local reach = Town.RESERVED_SIZE / 2 - 1
	local offsets = {
		Vector3.new(-reach, height / 2, -reach),
		Vector3.new(reach, height / 2, -reach),
		Vector3.new(reach, height / 2, reach),
		Vector3.new(-reach, height / 2, reach),
	}
	for _, offset in offsets do
		part(
			host,
			"Post",
			Vector3.new(0.4, height, 0.4),
			host.CFrame * CFrame.new(offset),
			UITheme.materials.wood,
			"BoneDim",
			true
		)
	end
end

local function buildReserved(town: Folder, spec: any)
	local place = TownLayout.district(spec.index)
	local y = Town.FLOOR_Y + Town.FOOTPRINT_THICKNESS / 2 + 0.05
	local cf = CFrame.lookAt(Vector3.new(place.x, y, place.z), Vector3.new(0, y, 0))
	local footprint = part(
		town,
		spec.footprint,
		Vector3.new(Town.RESERVED_SIZE, Town.FOOTPRINT_THICKNESS, Town.RESERVED_SIZE),
		cf,
		UITheme.materials.cobble,
		"Ash",
		true
	)
	footprint:SetAttribute("Status", "reserved")
	if spec.kind == "rift" then
		cornerPosts(footprint, Town.FENCE_HEIGHT)
		local reach = Town.RESERVED_SIZE / 2 - 1
		local railY = Town.FENCE_HEIGHT * 0.7
		part(
			footprint,
			"Rail",
			Vector3.new(reach * 2, 0.25, 0.25),
			cf * CFrame.new(0, railY, -reach),
			UITheme.materials.wood,
			"Wall",
			true
		)
		part(
			footprint,
			"Rail",
			Vector3.new(reach * 2, 0.25, 0.25),
			cf * CFrame.new(0, railY, reach),
			UITheme.materials.wood,
			"Wall",
			true
		)
		part(
			footprint,
			"Rail",
			Vector3.new(0.25, 0.25, reach * 2),
			cf * CFrame.new(-reach, railY, 0),
			UITheme.materials.wood,
			"Wall",
			true
		)
		part(
			footprint,
			"Rail",
			Vector3.new(0.25, 0.25, reach * 2),
			cf * CFrame.new(reach, railY, 0),
			UITheme.materials.wood,
			"Wall",
			true
		)
		local pit = part(
			footprint,
			"Pit",
			Vector3.new(Town.PIT_DEPTH, Town.PIT_DIAMETER, Town.PIT_DIAMETER),
			cf * CFrame.new(0, 0.2, 0),
			UITheme.materials.wall,
			"Void",
			false
		)
		uprightCylinder(pit, cf * CFrame.new(0, 0.2, 0))
		local glow = part(
			footprint,
			"RiftGlow",
			Vector3.new(0.35, Town.PIT_DIAMETER + 1.4, Town.PIT_DIAMETER + 1.4),
			cf * CFrame.new(0, 0.55, 0),
			UITheme.materials.neon,
			"Rift",
			false
		)
		uprightCylinder(glow, cf * CFrame.new(0, 0.55, 0))
		glow.Transparency = 0.45
	else
		cornerPosts(footprint, 2.2)
		local reach = Town.RESERVED_SIZE / 2 - 1
		part(
			footprint,
			"Rope",
			Vector3.new(reach * 2, 0.15, 0.15),
			cf * CFrame.new(0, 1.4, -reach),
			UITheme.materials.cloth,
			"BoneDim",
			false
		)
		part(
			footprint,
			"Rope",
			Vector3.new(reach * 2, 0.15, 0.15),
			cf * CFrame.new(0, 1.4, reach),
			UITheme.materials.cloth,
			"BoneDim",
			false
		)
		part(
			footprint,
			"Rope",
			Vector3.new(0.15, 0.15, reach * 2),
			cf * CFrame.new(-reach, 1.4, 0),
			UITheme.materials.cloth,
			"BoneDim",
			false
		)
		part(
			footprint,
			"Rope",
			Vector3.new(0.15, 0.15, reach * 2),
			cf * CFrame.new(reach, 1.4, 0),
			UITheme.materials.cloth,
			"BoneDim",
			false
		)
	end
end

function TownBuilder.build(town: Folder)
	sinkGround(town)
	berm(town)
	cobble(town)
	well(town)
	roads(town)
	wall(town)
	lamps(town)
	local districts = Instance.new("Folder")
	districts.Name = "Districts"
	districts.Parent = town
	for index, spec in Town.DISTRICTS do
		if spec.status == "reserved" then
			buildReserved(town, spec)
		elseif spec.kind == "shrine" then
			buildShrine(districts, spec, index)
		else
			buildStall(districts, spec, index)
		end
	end
end

return TownBuilder
