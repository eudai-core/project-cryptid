--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CryptidModel = require(script.Parent:WaitForChild("CryptidModel"))
local Economy = require(Shared:WaitForChild("Config"):WaitForChild("Economy")) :: any
local Lair = require(Shared:WaitForChild("Config"):WaitForChild("Lair")) :: any
local NumberFormat = require(Shared:WaitForChild("Logic"):WaitForChild("NumberFormat")) :: any
local OnboardingGoals = require(Shared:WaitForChild("Logic"):WaitForChild("OnboardingGoals")) :: any
local ProfileQuery = require(Shared:WaitForChild("Logic"):WaitForChild("ProfileQuery")) :: any
local Species = require(Shared:WaitForChild("Config"):WaitForChild("Species")) :: any
local Transactions = require(Shared:WaitForChild("Logic"):WaitForChild("Transactions")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local Plot = {}
local slotCursor = 0

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
	piece.Parent = parent
	return piece
end

local function candle(parent: Instance, origin: CFrame, localPos: Vector3)
	local stand = origin * CFrame.new(localPos + Vector3.new(0, 0.5, 0))
	local stick = makePart(
		parent,
		"Candle",
		Vector3.new(0.35, 0.9, 0.35),
		stand * CFrame.Angles(0, 0, math.rad(90)),
		UITheme.materials.candle,
		"Bone",
		false
	)
	stick.Shape = Enum.PartType.Cylinder
	local flame = makePart(
		parent,
		"Flame",
		Vector3.new(0.25, 0.35, 0.25),
		origin * CFrame.new(localPos + Vector3.new(0, 1.15, 0)),
		UITheme.materials.candle,
		"Candle",
		false
	)
	local light = Instance.new("PointLight")
	light.Color = UITheme.color("Candle")
	light.Range = Lair.CANDLE_RANGE
	light.Brightness = Lair.CANDLE_BRIGHTNESS
	light.Shadows = true
	light.Parent = flame
end

local function prompt(parent: BasePart, ownerUserId: number, kind: string): ProximityPrompt
	local plate = Instance.new("ProximityPrompt")
	plate.Name = kind
	plate.Style = Enum.ProximityPromptStyle.Custom
	plate.KeyboardKeyCode = Enum.KeyCode.E
	plate.GamepadKeyCode = Enum.KeyCode.ButtonX
	plate.HoldDuration = 0
	plate.RequiresLineOfSight = false
	plate.MaxActivationDistance = Lair.PURCHASE_PROMPT_DISTANCE
	plate.ClickablePrompt = true
	plate:SetAttribute("OwnerUserId", ownerUserId)
	plate:SetAttribute("Kind", kind)
	plate:SetAttribute("Available", false)
	plate.Parent = parent
	return plate
end

local function replaceCreature(host: Instance, speciesId: string?, cf: CFrame)
	local existing = host:FindFirstChild("Creature")
	if speciesId == nil then
		if existing ~= nil then
			existing:Destroy()
		end
		return
	end
	if existing ~= nil and existing:GetAttribute("SpeciesId") == speciesId then
		return
	end
	if existing ~= nil then
		existing:Destroy()
	end
	local model = CryptidModel.build(speciesId)
	model.Name = "Creature"
	model.Parent = host
	model:PivotTo(cf)
end

function Plot.nextOrigin(): CFrame
	local slot = slotCursor
	slotCursor += 1
	local column = slot % 4
	local row = math.floor(slot / 4)
	return CFrame.new(column * Lair.PLOT_STRIDE, 0, row * Lair.PLOT_STRIDE)
end

function Plot.create(ownerUserId: number, origin: CFrame): any
	local folder = workspace:FindFirstChild("Lairs")
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = "Lairs"
		folder.Parent = workspace
	end

	local model = Instance.new("Model")
	model.Name = "Lair_" .. tostring(ownerUserId)
	model:SetAttribute("OwnerUserId", ownerUserId)

	local halfZ = Lair.FLOOR_SIZE.z / 2
	local halfX = Lair.FLOOR_SIZE.x / 2
	local floor = makePart(
		model,
		"Floor",
		Vector3.new(Lair.FLOOR_SIZE.x, Lair.FLOOR_SIZE.y, Lair.FLOOR_SIZE.z),
		origin * CFrame.new(0, -0.5, 0),
		UITheme.materials.floor,
		"Soot",
		true
	)
	model.PrimaryPart = floor

	local wallY = Lair.WALL_HEIGHT / 2
	makePart(
		model,
		"WallNorth",
		Vector3.new(Lair.FLOOR_SIZE.x, Lair.WALL_HEIGHT, Lair.WALL_THICKNESS),
		origin * CFrame.new(0, wallY, halfZ),
		UITheme.materials.wall,
		"Ambient",
		true
	)
	makePart(
		model,
		"WallEast",
		Vector3.new(Lair.WALL_THICKNESS, Lair.WALL_HEIGHT, Lair.FLOOR_SIZE.z),
		origin * CFrame.new(halfX, wallY, 0),
		UITheme.materials.wall,
		"Ambient",
		true
	)
	makePart(
		model,
		"WallWest",
		Vector3.new(Lair.WALL_THICKNESS, Lair.WALL_HEIGHT, Lair.FLOOR_SIZE.z),
		origin * CFrame.new(-halfX, wallY, 0),
		UITheme.materials.wall,
		"Ambient",
		true
	)
	local gap = Lair.EXIT_GAP
	local segment = (Lair.FLOOR_SIZE.x - gap) / 2
	makePart(
		model,
		"WallSouthLeft",
		Vector3.new(segment, Lair.WALL_HEIGHT, Lair.WALL_THICKNESS),
		origin * CFrame.new(-(gap / 2 + segment / 2), wallY, -halfZ),
		UITheme.materials.wall,
		"Ambient",
		true
	)
	makePart(
		model,
		"WallSouthRight",
		Vector3.new(segment, Lair.WALL_HEIGHT, Lair.WALL_THICKNESS),
		origin * CFrame.new(gap / 2 + segment / 2, wallY, -halfZ),
		UITheme.materials.wall,
		"Ambient",
		true
	)

	local wildZ = -halfZ - Economy.WILD_SPAWN_STUDS
	local pathLength = Economy.WILD_SPAWN_STUDS + 16
	makePart(
		model,
		"Path",
		Vector3.new(16, 1, pathLength),
		origin * CFrame.new(0, -0.5, -halfZ - pathLength / 2),
		UITheme.materials.floor,
		"Soot",
		true
	)

	local belt = makePart(
		model,
		"Conveyor",
		Vector3.new(Lair.CONVEYOR_LENGTH, 0.6, Lair.CONVEYOR_WIDTH),
		origin * CFrame.new(0, 0.3, Lair.CONVEYOR_Z),
		UITheme.materials.conveyor,
		"Ash",
		true
	)
	makePart(
		model,
		"RiftTrimLeft",
		Vector3.new(Lair.CONVEYOR_LENGTH, 0.15, 0.25),
		origin * CFrame.new(0, 0.65, Lair.CONVEYOR_Z - Lair.CONVEYOR_WIDTH / 2),
		UITheme.materials.neon,
		"Rift",
		false
	)
	makePart(
		model,
		"RiftTrimRight",
		Vector3.new(Lair.CONVEYOR_LENGTH, 0.15, 0.25),
		origin * CFrame.new(0, 0.65, Lair.CONVEYOR_Z + Lair.CONVEYOR_WIDTH / 2),
		UITheme.materials.neon,
		"Rift",
		false
	)

	local altarStand = origin * CFrame.new(0, 0, Lair.ALTAR_Z)
	local altar = makePart(
		model,
		"Altar",
		Vector3.new(8, 3, 4),
		altarStand * CFrame.new(0, 1.5, 0),
		UITheme.materials.altar,
		"Ash",
		true
	)
	makePart(
		model,
		"AltarLip",
		Vector3.new(8.4, 0.25, 4.4),
		altarStand * CFrame.new(0, 3.1, 0),
		UITheme.materials.padRing,
		"Gold",
		false
	)
	local altarPrompt = prompt(altar, ownerUserId, "UpgradeAltar")
	altarPrompt.MaxActivationDistance = Lair.PURCHASE_PROMPT_DISTANCE

	local pads = {}
	for index, pos in Lair.PAD_POSITIONS do
		local stand = origin * CFrame.new(pos.x, 0, pos.z)
		local ring = makePart(
			model,
			"PadRing" .. tostring(index),
			Vector3.new(0.35, Lair.PAD_DIAMETER + 1.6, Lair.PAD_DIAMETER + 1.6),
			stand * CFrame.new(0, 0.2, 0) * CFrame.Angles(0, 0, math.rad(90)),
			UITheme.materials.padRing,
			"Gold",
			false
		)
		ring.Shape = Enum.PartType.Cylinder
		local center = makePart(
			model,
			"Pad" .. tostring(index),
			Vector3.new(0.45, Lair.PAD_DIAMETER, Lair.PAD_DIAMETER),
			stand * CFrame.new(0, 0.28, 0) * CFrame.Angles(0, 0, math.rad(90)),
			UITheme.materials.padCenter,
			"Soot",
			false
		)
		center.Shape = Enum.PartType.Cylinder
		center:SetAttribute("OwnerUserId", ownerUserId)
		center:SetAttribute("PadIndex", index)
		CollectionService:AddTag(center, "CryptidPad")
		local padPrompt = prompt(center, ownerUserId, "Pad")
		table.insert(pads, {
			index = index,
			stand = stand,
			ring = ring,
			center = center,
			prompt = padPrompt,
		})
	end

	local rift = {}
	for slot = 1, #Species.GUARANTEES do
		local x = if slot == 1 then -9 else 9
		local stand = origin * CFrame.new(x, 0.7, Lair.CONVEYOR_Z)
		local marker = makePart(
			model,
			"RiftSlot" .. tostring(slot),
			Vector3.new(4, 0.2, 4),
			stand,
			UITheme.materials.conveyor,
			"Ash",
			false
		)
		marker:SetAttribute("OwnerUserId", ownerUserId)
		marker:SetAttribute("Slot", slot)
		CollectionService:AddTag(marker, "CryptidRift")
		local riftPrompt = prompt(marker, ownerUserId, "BuyRift")
		riftPrompt:SetAttribute("Slot", slot)
		table.insert(rift, {
			slot = slot,
			stand = stand * CFrame.new(0, 0.2, 0),
			part = marker,
			prompt = riftPrompt,
		})
	end

	local wildStand = origin * CFrame.new(0, 0, wildZ)
	local wildPad = makePart(
		model,
		"WildSpawn",
		Vector3.new(0.3, Lair.WILD_CLEARING_RADIUS * 2, Lair.WILD_CLEARING_RADIUS * 2),
		wildStand * CFrame.new(0, 0.2, 0) * CFrame.Angles(0, 0, math.rad(90)),
		UITheme.materials.padCenter,
		"Ash",
		false
	)
	wildPad.Shape = Enum.PartType.Cylinder
	wildPad:SetAttribute("OwnerUserId", ownerUserId)
	CollectionService:AddTag(wildPad, "CryptidWild")
	local wildPrompt = prompt(wildPad, ownerUserId, "Catch")
	wildPrompt.MaxActivationDistance = Lair.CATCH_PROMPT_DISTANCE

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "LairSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Transparency = 1
	spawn.Duration = 0
	spawn.Neutral = true
	local spawnPos = origin:PointToWorldSpace(Vector3.new(0, 3, Lair.SPAWN_Z))
	local lookPos = origin:PointToWorldSpace(Vector3.new(0, 3, 0))
	spawn.CFrame = CFrame.lookAt(spawnPos, lookPos)
	spawn.Parent = model

	local candleSpots = {
		Vector3.new(-40, 0, 36),
		Vector3.new(40, 0, 36),
		Vector3.new(0, 0, Lair.SPAWN_Z),
		Vector3.new(-20, 0, Lair.CONVEYOR_Z),
		Vector3.new(20, 0, Lair.CONVEYOR_Z),
		Vector3.new(0, 0, Lair.ALTAR_Z + 3),
		Vector3.new(-8, 0, -halfZ),
		Vector3.new(8, 0, -halfZ),
		Vector3.new(0, 0, (-halfZ + wildZ) / 2),
		Vector3.new(-4, 0, wildZ),
		Vector3.new(4, 0, wildZ),
	}
	for _, pos in Lair.PAD_POSITIONS do
		table.insert(candleSpots, Vector3.new(pos.x + 5, 0, pos.z + 5))
	end
	for _, spot in candleSpots do
		candle(model, origin, spot)
	end

	model.Parent = folder
	return {
		model = model,
		origin = origin,
		pads = pads,
		rift = rift,
		altar = altar,
		altarPrompt = altarPrompt,
		wildPad = wildPad,
		wildStand = wildStand,
		wildPrompt = wildPrompt,
		spawnLocation = spawn,
		belt = belt,
	}
end

local function guidePart(plot: any, guide: string): BasePart?
	if guide == "altar" then
		return plot.altar
	end
	if guide == "wild" then
		return plot.wildPad
	end
	local padIndex = string.match(guide, "^pad:(%d+)$")
	if padIndex ~= nil then
		local pad = plot.pads[tonumber(padIndex)]
		if pad ~= nil then
			return pad.center
		end
	end
	local slot = string.match(guide, "^rift:(%d+)$")
	if slot ~= nil then
		local rift = plot.rift[tonumber(slot)]
		if rift ~= nil then
			return rift.part
		end
	end
	return nil
end

function Plot.sync(plot: any, profile: any, guideValue: ObjectValue)
	for _, pad in plot.pads do
		local instanceId = ProfileQuery.padAt(profile, pad.index)
		local speciesId = nil
		if instanceId ~= nil then
			local record = profile.cryptids[instanceId]
			if record ~= nil then
				speciesId = record.speciesId
			end
		end
		replaceCreature(pad.center, speciesId, pad.stand * CFrame.new(0, 0, 0))
		local locked = pad.index > profile.padsUnlocked
		local nextPad = pad.index == profile.padsUnlocked + 1
		local cost = Economy.PAD_COST[pad.index]
		if locked and nextPad and type(cost) == "number" and profile.cash + 1e-9 >= cost then
			pad.ring.Color = UITheme.color("Blood")
		else
			pad.ring.Color = UITheme.color("Gold")
		end
		pad.prompt:SetAttribute("Pad", pad.index)
		if locked and nextPad then
			pad.prompt:SetAttribute("Kind", "UnlockPad")
			pad.prompt:SetAttribute("Available", true)
			pad.prompt.ActionText = "Carve"
			pad.prompt.ObjectText = NumberFormat.formatCash(cost)
		elseif not locked and instanceId == nil then
			local goal = OnboardingGoals.view(profile)
			local wantsPlace = goal.actionKind == "place"
				and goal.actionPad == pad.index
				and goal.actionInstanceId ~= ""
			pad.prompt:SetAttribute("Kind", "Place")
			pad.prompt:SetAttribute("InstanceId", if wantsPlace then goal.actionInstanceId else "")
			pad.prompt:SetAttribute("Available", wantsPlace)
			pad.prompt.ActionText = "Bind"
			pad.prompt.ObjectText = "Circle " .. tostring(pad.index)
		else
			pad.prompt:SetAttribute("Available", false)
			pad.prompt.ActionText = ""
		end
	end

	local offers = Transactions.currentOffers(profile)
	local offerBySlot = {}
	for _, offer in offers do
		offerBySlot[offer.slot] = offer
	end
	for _, rift in plot.rift do
		local offer = offerBySlot[rift.slot]
		if offer == nil then
			replaceCreature(rift.part, nil, rift.stand)
			rift.prompt:SetAttribute("Available", false)
		else
			replaceCreature(rift.part, offer.speciesId, rift.stand)
			rift.prompt:SetAttribute("Available", true)
			rift.prompt:SetAttribute("Slot", offer.slot)
			rift.prompt.ActionText = "Claim"
			rift.prompt.ObjectText = NumberFormat.formatCash(offer.price)
		end
	end

	local showWild = profile.onboarding.step == 6 and not ProfileQuery.hasSource(profile, "wild")
	replaceCreature(plot.wildPad, if showWild then Species.WILD_ID else nil, plot.wildStand)
	plot.wildPrompt:SetAttribute("Available", showWild)
	plot.wildPrompt.ActionText = "Catch"
	local wildSpecies = Species.get(Species.WILD_ID)
	plot.wildPrompt.ObjectText = wildSpecies.displayName

	local nextAltar = profile.upgrades.boneAltar + 1
	local altarCost = Economy.ALTAR_COST[nextAltar]
	if type(altarCost) == "number" then
		plot.altarPrompt:SetAttribute("Available", true)
		plot.altarPrompt.ActionText = "Raise"
		plot.altarPrompt.ObjectText = NumberFormat.formatCash(altarCost)
	else
		plot.altarPrompt:SetAttribute("Available", false)
	end

	local goal = OnboardingGoals.view(profile)
	guideValue.Value = guidePart(plot, goal.guide)
end

function Plot.destroy(plot: any)
	if plot.model ~= nil then
		plot.model:Destroy()
	end
end

return Plot
