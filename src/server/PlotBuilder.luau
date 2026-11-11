--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ArtAssets = require(Shared:WaitForChild("ArtAssets")) :: any
local CryptidArt = require(Shared:WaitForChild("Config"):WaitForChild("CryptidArt")) :: any
local Lair = require(Shared:WaitForChild("Config"):WaitForChild("Lair")) :: any
local RiftGlow = require(script.Parent:WaitForChild("RiftGlow"))
local Lanterns = require(Shared:WaitForChild("Config"):WaitForChild("Lanterns")) :: any
local PlotRing = require(Shared:WaitForChild("Logic"):WaitForChild("PlotRing")) :: any
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local Town = require(Shared:WaitForChild("Config"):WaitForChild("Town")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any
local LairVisual = require(script.Parent:WaitForChild("LairVisual"))
local Wisp = require(script.Parent:WaitForChild("Wisp"))

local TownBuilder = require(script.Parent:WaitForChild("TownBuilder"))

local PlotBuilder = {}

local missingArt: { [string]: boolean } = {}

local function noteMissing(name: string)
	if missingArt[name] then
		return
	end
	missingArt[name] = true
	warn("Missing lair art: " .. name)
end

local function material(name: string): Enum.Material
	return Enum.Material[name]
end

local function makePart(
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

local function invisibleAnchor(parent: Instance, name: string, size: Vector3, cf: CFrame): Part
	local piece = makePart(parent, name, size, cf, UITheme.materials.altar, "Ash", false)
	piece.Transparency = 1
	piece.CastShadow = false
	piece.CanQuery = false
	return piece
end

local function originOf(index: number): CFrame
	local center = PlotRing.center(index)
	local axes = PlotRing.axes(index)
	return CFrame.fromMatrix(
		Vector3.new(center.x, center.y, center.z),
		Vector3.new(axes.x.x, axes.x.y, axes.x.z),
		Vector3.new(axes.y.x, axes.y.y, axes.y.z),
		Vector3.new(axes.z.x, axes.z.y, axes.z.z)
	)
end

local function folder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing ~= nil and existing:IsA("Folder") then
		existing:Destroy()
	end
	local created = Instance.new("Folder")
	created.Name = name
	created.Parent = parent
	return created
end

local function lantern(parent: Instance, cf: CFrame)
	makePart(
		parent,
		"LanternPost",
		Vector3.new(Lanterns.POST_THICKNESS, Lanterns.POST_HEIGHT, Lanterns.POST_THICKNESS),
		cf * CFrame.new(0, Lanterns.POST_HEIGHT / 2, 0),
		UITheme.materials.lantern,
		"Ash",
		true
	)
	local glass = makePart(
		parent,
		"LanternGlass",
		Vector3.new(Lanterns.GLASS_SIZE, Lanterns.GLASS_SIZE, Lanterns.GLASS_SIZE),
		cf * CFrame.new(0, Lanterns.POST_HEIGHT + Lanterns.GLASS_SIZE / 2, 0),
		UITheme.materials.glass,
		"BoneDim",
		false
	)
	glass.Transparency = Lanterns.GLASS_TRANSPARENCY
	makePart(
		parent,
		"LanternAccent",
		Vector3.new(Lanterns.ACCENT_WIDTH, Lanterns.ACCENT_HEIGHT, Lanterns.ACCENT_WIDTH),
		cf * CFrame.new(0, Lanterns.POST_HEIGHT, 0),
		UITheme.materials.padRing,
		"Gold",
		false
	)
	local light = Instance.new("PointLight")
	light.Name = "LanternLight"
	light.Color = UITheme.color(Lanterns.COLOR_TOKEN)
	light.Brightness = Lanterns.BRIGHTNESS
	light.Range = Lanterns.RANGE
	light.Shadows = Lanterns.SHADOWS
	light.Parent = glass
end

local function candle(parent: Instance, origin: CFrame, localPos: Vector3, withLight: boolean): (PointLight?, BasePart)
	local stick = makePart(
		parent,
		"Candle",
		Vector3.new(Lair.CANDLE_STICK.x, Lair.CANDLE_STICK.y, Lair.CANDLE_STICK.z),
		origin * CFrame.new(localPos + Vector3.new(0, Lair.CANDLE_STICK.y / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		UITheme.materials.candle,
		"Bone",
		false
	)
	stick.Shape = Enum.PartType.Cylinder
	local flame = makePart(
		parent,
		"Flame",
		Vector3.new(Lair.CANDLE_FLAME.x, Lair.CANDLE_FLAME.y, Lair.CANDLE_FLAME.z),
		origin * CFrame.new(localPos + Vector3.new(0, Lair.CANDLE_STICK.y + Lair.CANDLE_FLAME.y / 2, 0)),
		UITheme.materials.candle,
		"Candle",
		false
	)
	local light = nil
	if withLight then
		light = Instance.new("PointLight")
		light.Color = UITheme.color("Candle")
		light.Range = Lair.CANDLE_RANGE
		light.Brightness = Lair.CANDLE_BRIGHTNESS
		light.Shadows = true
		light.Enabled = false
		light.Parent = flame
	end
	flame.Transparency = 1
	return light, flame
end

local function prompt(parent: BasePart, kind: string, key: Enum.KeyCode?, button: Enum.KeyCode?): ProximityPrompt
	local plate = Instance.new("ProximityPrompt")
	plate.Name = kind
	plate.Style = Enum.ProximityPromptStyle.Custom
	plate.KeyboardKeyCode = if key ~= nil then key else Enum.KeyCode.E
	plate.GamepadKeyCode = if button ~= nil then button else Enum.KeyCode.ButtonX
	plate.HoldDuration = 0
	plate.RequiresLineOfSight = false
	plate.MaxActivationDistance = Lair.PURCHASE_PROMPT_DISTANCE
	plate.ClickablePrompt = true
	plate:SetAttribute("OwnerUserId", 0)
	plate:SetAttribute("Kind", kind)
	plate:SetAttribute("Available", false)
	plate.Parent = parent
	return plate
end

local function wallRun(
	parent: Instance,
	origin: CFrame,
	name: string,
	alongX: boolean,
	fixed: number,
	gap: number,
	floorTop: number
)
	local span = Plots.FOOTPRINT
	local segment = (span - gap) / 2
	local center = gap / 2 + segment / 2
	local y = floorTop + Plots.WALL_HEIGHT / 2
	local size = if alongX
		then Vector3.new(segment, Plots.WALL_HEIGHT, Plots.WALL_THICKNESS)
		else Vector3.new(Plots.WALL_THICKNESS, Plots.WALL_HEIGHT, segment)
	local posA = if alongX then Vector3.new(-center, y, fixed) else Vector3.new(fixed, y, -center)
	local posB = if alongX then Vector3.new(center, y, fixed) else Vector3.new(fixed, y, center)
	makePart(parent, name .. "A", size, origin * CFrame.new(posA), UITheme.materials.wall, "Wall", true)
	makePart(parent, name .. "B", size, origin * CFrame.new(posB), UITheme.materials.wall, "Wall", true)
end

local function sideWall(parent: Instance, origin: CFrame, name: string, x: number, floorTop: number)
	makePart(
		parent,
		name,
		Vector3.new(Plots.WALL_THICKNESS, Plots.WALL_HEIGHT, Plots.FOOTPRINT),
		origin * CFrame.new(x, floorTop + Plots.WALL_HEIGHT / 2, 0),
		UITheme.materials.wall,
		"Wall",
		true
	)
end

local function merlons(
	parent: Instance,
	origin: CFrame,
	alongX: boolean,
	fixed: number,
	gapHalf: number,
	floorTop: number
)
	local span = Plots.FOOTPRINT / 2 - 1
	local cursor = -span
	local y = floorTop + Plots.WALL_HEIGHT + Plots.MERLON_HEIGHT / 2
	local step = Plots.MERLON_WIDTH + Plots.MERLON_GAP
	while cursor + Plots.MERLON_WIDTH <= span + 0.05 do
		local mid = cursor + Plots.MERLON_WIDTH / 2
		local outsideGate = gapHalf <= 0 or math.abs(mid) - Plots.MERLON_WIDTH / 2 >= gapHalf
		if outsideGate then
			local size = if alongX
				then Vector3.new(Plots.MERLON_WIDTH, Plots.MERLON_HEIGHT, Plots.WALL_THICKNESS)
				else Vector3.new(Plots.WALL_THICKNESS, Plots.MERLON_HEIGHT, Plots.MERLON_WIDTH)
			local pos = if alongX then Vector3.new(mid, y, fixed) else Vector3.new(fixed, y, mid)
			makePart(parent, "Merlon", size, origin * CFrame.new(pos), UITheme.materials.wall, "Wall", true)
		end
		cursor += step
	end
end

local function gate(
	parent: Instance,
	origin: CFrame,
	gateName: string,
	doorName: string,
	z: number,
	width: number,
	floorTop: number
): (Part, Part, Part)
	local lintel = makePart(
		parent,
		gateName,
		Vector3.new(width, Plots.LINTEL_HEIGHT, Plots.WALL_THICKNESS),
		origin * CFrame.new(0, floorTop + Plots.WALL_HEIGHT - Plots.LINTEL_HEIGHT / 2, z),
		UITheme.materials.wall,
		"Wall",
		true
	)
	local doorHeight = Plots.WALL_HEIGHT - Plots.LINTEL_HEIGHT
	local door = makePart(
		parent,
		doorName,
		Vector3.new(width, doorHeight, Plots.WALL_THICKNESS),
		origin * CFrame.new(0, floorTop + doorHeight / 2, z),
		UITheme.materials.wall,
		"Wall",
		true
	)
	local seal = makePart(
		parent,
		"WardingSeal",
		Vector3.new(width, doorHeight, 0.4),
		origin * CFrame.new(0, floorTop + doorHeight / 2, z),
		UITheme.materials.lantern,
		"RiftDim",
		false
	)
	seal.Transparency = 1
	seal.CanQuery = false
	return lintel, door, seal
end

function PlotBuilder.buildGround(town: Folder)
	makePart(
		town,
		"Ground",
		Vector3.new(Plots.GROUND_RADIUS * 2, Plots.GROUND_THICKNESS, Plots.GROUND_RADIUS * 2),
		CFrame.new(0, -Plots.GROUND_THICKNESS / 2, 0),
		UITheme.materials.floor,
		"Wall",
		true
	)
	makePart(
		town,
		"TownPlatform",
		Vector3.new(Plots.FALLBACK_SIZE, Plots.FALLBACK_THICKNESS, Plots.FALLBACK_SIZE),
		CFrame.new(0, Plots.FALLBACK_THICKNESS / 2, 0),
		UITheme.materials.floor,
		"Floor",
		true
	)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "TownSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.CanTouch = false
	spawn.CanQuery = false
	spawn.Transparency = 1
	spawn.Duration = 0
	spawn.Neutral = true
	spawn.Enabled = true
	spawn.CFrame = CFrame.new(0, Plots.FALLBACK_THICKNESS + 0.5, 0)
	spawn.Parent = town
	for _, offset in Lanterns.townOffsets() do
		lantern(town, CFrame.new(offset.x, Plots.FALLBACK_THICKNESS, offset.z))
	end
end

function PlotBuilder.buildPlot(parent: Folder, index: number): any
	local origin = originOf(index)
	local floorTop = Plots.FLOOR_THICKNESS
	local model = Instance.new("Model")
	model.Name = "Plot" .. tostring(index)
	model:SetAttribute("PlotIndex", index)
	model:SetAttribute("OwnerUserId", 0)
	model:SetAttribute("OwnerName", "")
	model:SetAttribute("PlotState", "free")
	model:SetAttribute("Sealed", false)

	local slab = makePart(
		model,
		"Floor",
		Vector3.new(Plots.FOOTPRINT, Plots.FLOOR_THICKNESS, Plots.FOOTPRINT),
		origin * CFrame.new(0, floorTop / 2, 0),
		UITheme.materials.floor,
		"Floor",
		true
	)
	model.PrimaryPart = slab

	local half = Plots.FOOTPRINT / 2
	wallRun(model, origin, "WallFront", true, half, Plots.LAIR_GATE_WIDTH, floorTop)
	wallRun(model, origin, "WallBack", true, -half, Plots.WILD_GATE_WIDTH, floorTop)
	sideWall(model, origin, "WallEast", half, floorTop)
	sideWall(model, origin, "WallWest", -half, floorTop)
	merlons(model, origin, true, half, Plots.LAIR_GATE_WIDTH / 2, floorTop)
	merlons(model, origin, true, -half, Plots.WILD_GATE_WIDTH / 2, floorTop)
	merlons(model, origin, false, half, 0, floorTop)
	merlons(model, origin, false, -half, 0, floorTop)

	local lairGate, lairDoor, lairSeal =
		gate(model, origin, "LairGate", "LairDoor", half, Plots.LAIR_GATE_WIDTH, floorTop)
	local _, wildDoor, wildSeal = gate(model, origin, "WildGate", "WildDoor", -half, Plots.WILD_GATE_WIDTH, floorTop)
	wildSeal:Destroy()
	for _, offset in Lanterns.gateOffsets() do
		lantern(model, origin * CFrame.new(offset.x, 0, offset.z))
	end

	local townLocalZ = Plots.RING_RADIUS - Plots.TOWN_RADIUS
	local roadStart = half + Plots.WALL_THICKNESS / 2
	local roadLength = townLocalZ - roadStart
	makePart(
		model,
		"Road",
		Vector3.new(Plots.ROAD_WIDTH, Plots.ROAD_THICKNESS, roadLength),
		origin * CFrame.new(0, Plots.ROAD_THICKNESS / 2, roadStart + roadLength / 2),
		UITheme.materials.floor,
		"Floor",
		true
	)

	Wisp.attach(model, "WildWisp", origin * CFrame.new(0, Town.WISP.wildLift, Plots.WILD_GATE_Z - Town.WISP.wildPast))

	local wildPoint = PlotRing.wildLocal()
	local wildStart = -half - Plots.WALL_THICKNESS / 2
	local wildLength = math.abs(wildPoint.z - wildStart)
	makePart(
		model,
		"WildPath",
		Vector3.new(Plots.ROAD_WIDTH, Plots.ROAD_THICKNESS, wildLength),
		origin * CFrame.new(0, Plots.ROAD_THICKNESS / 2, (wildStart + wildPoint.z) / 2),
		UITheme.materials.floor,
		"Floor",
		true
	)

	local riftLength = math.abs(Plots.RIFT_Z_FRONT - Plots.RIFT_Z_BACK)
	local riftCenterZ = (Plots.RIFT_Z_FRONT + Plots.RIFT_Z_BACK) / 2
	local riftY = floorTop + Plots.RIFT_THICKNESS / 2
	local belt = makePart(
		model,
		"Conveyor",
		Vector3.new(Plots.RIFT_WIDTH, Plots.RIFT_THICKNESS, riftLength),
		origin * CFrame.new(Plots.RIFT_X, riftY, riftCenterZ),
		UITheme.materials.conveyor,
		"Ash",
		true
	)
	RiftGlow.attach(belt, true, true)
	makePart(
		model,
		"RiftTrimLeft",
		Vector3.new(Plots.RIFT_TRIM.x, Plots.RIFT_TRIM.y, riftLength),
		origin * CFrame.new(Plots.RIFT_X - Plots.RIFT_WIDTH / 2, riftY + Plots.RIFT_THICKNESS / 2, riftCenterZ),
		UITheme.materials.lantern,
		"RiftDim",
		false
	)
	makePart(
		model,
		"RiftTrimRight",
		Vector3.new(Plots.RIFT_TRIM.x, Plots.RIFT_TRIM.y, riftLength),
		origin * CFrame.new(Plots.RIFT_X + Plots.RIFT_WIDTH / 2, riftY + Plots.RIFT_THICKNESS / 2, riftCenterZ),
		UITheme.materials.lantern,
		"RiftDim",
		false
	)

	local altarBase = origin * CFrame.new(Plots.ALTAR_X, 0, Plots.ALTAR_Z)
	local altar = invisibleAnchor(
		model,
		"Altar",
		Vector3.new(Plots.ALTAR_SIZE.x, Plots.ALTAR_SIZE.y, Plots.ALTAR_SIZE.z),
		altarBase * CFrame.new(0, floorTop + Plots.ALTAR_SIZE.y / 2, 0)
	)
	local altarPrompt = prompt(altar, "UpgradeAltar")
	local ritePrompt = prompt(altar, "Rite", Enum.KeyCode.R, Enum.KeyCode.ButtonY)
	local altarModel = ArtAssets.clone(CryptidArt.folders.lair, CryptidArt.models.altar)
	local altarTiers = {}
	if altarModel ~= nil then
		altarTiers = LairVisual.prepareAltar(altarModel, LairVisual.faceGate(altarBase * CFrame.new(0, floorTop, 0)))
		altarModel.Parent = model
		LairVisual.applyAltar(altarModel, altarTiers, 0)
	else
		noteMissing(CryptidArt.models.altar)
	end

	local pads = {}
	for padIndex = 1, Plots.PAD_COUNT do
		local localPad = PlotRing.padLocal(padIndex)
		local stand = origin * CFrame.new(localPad.x, 0, localPad.z)
		local faced = LairVisual.faceGate(stand * CFrame.new(0, floorTop, 0))
		local center = invisibleAnchor(
			model,
			"Pad" .. tostring(padIndex),
			Vector3.new(Plots.PAD_CENTER_THICKNESS, Lair.PAD_DIAMETER, Lair.PAD_DIAMETER),
			stand * CFrame.new(0, floorTop + Plots.PAD_CENTER_LIFT, 0) * CFrame.Angles(0, 0, math.rad(90))
		)
		center.Shape = Enum.PartType.Cylinder
		center:SetAttribute("OwnerUserId", 0)
		center:SetAttribute("PadIndex", padIndex)
		center:SetAttribute("beingStolen", false)
		center:SetAttribute("Sealed", PlotRing.isSealedPad(padIndex))
		CollectionService:AddTag(center, "CryptidPad")
		local padPrompt = prompt(center, "Pad")
		local visual = ArtAssets.clone(CryptidArt.folders.lair, CryptidArt.models.pad)
		local states = nil
		local mount = nil
		if visual ~= nil then
			visual.Name = "PadArt" .. tostring(padIndex)
			states, mount = LairVisual.preparePad(visual, faced)
			visual.Parent = model
			local initial = if PlotRing.isSealedPad(padIndex) then CryptidArt.states.sealed else CryptidArt.states.empty
			LairVisual.applyPad(visual, states, initial, false)
			visual:SetAttribute("beingStolen", false)
			visual:SetAttribute("Sealed", PlotRing.isSealedPad(padIndex))
		else
			noteMissing(CryptidArt.models.pad)
		end
		table.insert(pads, {
			index = padIndex,
			stand = faced,
			center = center,
			prompt = padPrompt,
			visual = visual,
			states = states,
			mount = mount,
		})
	end

	local rift = {}
	for _, slot in Plots.RIFT_SLOTS do
		local stand = origin * CFrame.new(Plots.RIFT_X, riftY + Plots.RIFT_THICKNESS / 2, slot.z)
		local marker = makePart(
			model,
			"RiftSlot" .. tostring(slot.slot),
			Vector3.new(Plots.RIFT_MARKER, Plots.ROAD_THICKNESS, Plots.RIFT_MARKER),
			stand,
			UITheme.materials.conveyor,
			"Ash",
			false
		)
		marker:SetAttribute("OwnerUserId", 0)
		marker:SetAttribute("Slot", slot.slot)
		CollectionService:AddTag(marker, "CryptidRift")
		local riftPrompt = prompt(marker, "BuyRift")
		riftPrompt:SetAttribute("Slot", slot.slot)
		table.insert(rift, {
			slot = slot.slot,
			stand = LairVisual.faceGate(stand * CFrame.new(0, Plots.ROAD_THICKNESS, 0)),
			part = marker,
			prompt = riftPrompt,
		})
	end

	local wildBase = origin * CFrame.new(wildPoint.x, 0, wildPoint.z)
	local wildStand = LairVisual.faceGate(wildBase * CFrame.new(0, Plots.ROAD_THICKNESS, 0))
	local wildPad = makePart(
		model,
		"WildSpawn",
		Vector3.new(0.3, Lair.WILD_CLEARING_RADIUS * 2, Lair.WILD_CLEARING_RADIUS * 2),
		wildBase * CFrame.new(0, floorTop + 0.2, 0) * CFrame.Angles(0, 0, math.rad(90)),
		UITheme.materials.padCenter,
		"Ash",
		false
	)
	wildPad.Shape = Enum.PartType.Cylinder
	wildPad:SetAttribute("OwnerUserId", 0)
	CollectionService:AddTag(wildPad, "CryptidWild")
	local wildPrompt = prompt(wildPad, "Catch")
	wildPrompt.MaxActivationDistance = Lair.CATCH_PROMPT_DISTANCE

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "LairSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.CanTouch = false
	spawn.CanQuery = false
	spawn.Transparency = 1
	spawn.Duration = 0
	spawn.Neutral = false
	spawn.Enabled = false
	local spawnPos = origin:PointToWorldSpace(Vector3.new(0, Plots.STAND_HEIGHT, Plots.SPAWN_Z))
	local lookPos = origin:PointToWorldSpace(Vector3.new(0, Plots.STAND_HEIGHT, Plots.SPAWN_Z - 1))
	spawn.CFrame = CFrame.lookAt(spawnPos, lookPos)
	spawn.Parent = model

	for socketIndex, socket in Plots.DEFENCE_SOCKETS do
		local plinth = makePart(
			model,
			"Plinth" .. tostring(socketIndex),
			Vector3.new(Plots.PLINTH_SIZE, 1, Plots.PLINTH_SIZE),
			origin * CFrame.new(socket.x, floorTop + 0.5, socket.z),
			UITheme.materials.wall,
			"Wall",
			true
		)
		local attachment = Instance.new("Attachment")
		attachment.Name = PlotRing.socketName(socketIndex)
		attachment.Parent = plinth
	end

	local threshold = makePart(
		model,
		"Threshold",
		Vector3.new(Plots.FOOTPRINT, Plots.THRESHOLD_HEIGHT, Plots.FOOTPRINT),
		origin * CFrame.new(0, floorTop + Plots.THRESHOLD_HEIGHT / 2, 0),
		UITheme.materials.floor,
		"Wall",
		false
	)
	threshold.Transparency = 1
	threshold.CanTouch = true
	threshold.CanQuery = false
	threshold.CastShadow = false

	local lights = {}
	local flames = {}
	local inset = Plots.WALL_THICKNESS / 2 + 0.4
	local reach = Plots.FOOTPRINT / 2 - Plots.CANDLE_SPACING
	local lit = 0
	local function addCandle(localPos: Vector3)
		local withLight = lit < Lair.CANDLE_LIGHT_COUNT
		if withLight then
			lit += 1
		end
		local light, flame = candle(model, origin, localPos, withLight)
		if light ~= nil then
			table.insert(lights, light)
		end
		table.insert(flames, flame)
	end
	for cursor = -reach, reach, Plots.CANDLE_SPACING do
		if math.abs(cursor) > Plots.LAIR_GATE_WIDTH / 2 then
			addCandle(Vector3.new(cursor, Plots.CANDLE_HEIGHT, half - inset))
		end
		if math.abs(cursor) > Plots.WILD_GATE_WIDTH / 2 then
			addCandle(Vector3.new(cursor, Plots.CANDLE_HEIGHT, -half + inset))
		end
		addCandle(Vector3.new(half - inset, Plots.CANDLE_HEIGHT, cursor))
		addCandle(Vector3.new(-half + inset, Plots.CANDLE_HEIGHT, cursor))
	end

	local cloth = makePart(
		model,
		"BannerCloth",
		Vector3.new(Plots.BANNER_WIDTH, Plots.BANNER_HEIGHT, 0.35),
		origin * CFrame.new(0, floorTop + Plots.WALL_HEIGHT + Plots.BANNER_LIFT, half),
		UITheme.materials.cloth,
		"Blood",
		false
	)
	makePart(
		model,
		"BannerTrim",
		Vector3.new(Plots.BANNER_WIDTH + 0.6, Plots.BANNER_HEIGHT + 0.6, 0.2),
		origin * CFrame.new(0, floorTop + Plots.WALL_HEIGHT + Plots.BANNER_LIFT, half + 0.15),
		UITheme.materials.padRing,
		"Gold",
		false
	)

	model.Parent = parent
	return {
		index = index,
		model = model,
		origin = origin,
		state = "free",
		userId = 0,
		ownerName = "",
		generation = 0,
		protected = false,
		profile = nil,
		pads = pads,
		rift = rift,
		altar = altar,
		altarModel = altarModel,
		altarTiers = altarTiers,
		altarPrompt = altarPrompt,
		ritePrompt = ritePrompt,
		wildPad = wildPad,
		wildStand = wildStand,
		wildPrompt = wildPrompt,
		spawnLocation = spawn,
		belt = belt,
		doors = { lairDoor, wildDoor },
		seal = lairSeal,
		lights = lights,
		flames = flames,
		lairGate = lairGate,
		banner = cloth,
	}
end

function PlotBuilder.build(): { any }
	local plotsFolder = folder(workspace, "Plots")
	local town = folder(workspace, "Town")
	PlotBuilder.buildGround(town)
	TownBuilder.build(town)
	local plots = {}
	for index = 1, Plots.COUNT do
		plots[index] = PlotBuilder.buildPlot(plotsFolder, index)
	end
	return plots
end

return PlotBuilder
