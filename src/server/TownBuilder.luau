--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Lair = import("../shared/Config/Lair", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Lair")
end) :: any
local Lanterns = import("../shared/Config/Lanterns", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Lanterns")
end) :: any
local Plots = import("../shared/Config/Plots", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Plots")
end) :: any
local Shop = import("../shared/Config/Shop", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Shop")
end) :: any
local Town = import("../shared/Config/Town", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Town")
end) :: any
local TownLook = import("../shared/Config/TownLook", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("TownLook")
end) :: any
local TownLayout = import("../shared/Logic/TownLayout", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("TownLayout")
end) :: any
local UITheme = import("../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any
local RiftGlow = import("./RiftGlow", function()
	return script.Parent:WaitForChild("RiftGlow")
end)
local Wisp = import("./Wisp", function()
	return script.Parent:WaitForChild("Wisp")
end)
local TownKits = import("./TownKits", function()
	return script.Parent:WaitForChild("TownKits")
end)

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

local function neonPart(
	parent: Instance,
	name: string,
	size: Vector3,
	cf: CFrame,
	colorToken: string,
	role: string
): Part
	if TownLook.NEON_ROLES[role] ~= true then
		error("Neon role is not allowed: " .. role, 2)
	end
	local piece = part(parent, name, size, cf, UITheme.materials.neon, colorToken, false)
	piece:SetAttribute("NeonRole", role)
	piece.CastShadow = false
	return piece
end

local function runestoneAt(model: Model, position: Vector3, colorToken: string)
	local cf = CFrame.lookAt(position, Vector3.new(0, position.Y, 0))
	part(model, "Runestone", Vector3.new(1.15, 2.3, 0.42), cf, UITheme.materials.altar, "Stone", false)
	neonPart(model, "RuneMark", Vector3.new(0.55, 1.15, 0.08), cf * CFrame.new(0, 0.1, -0.24), colorToken, "rune")
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

local function cobble(town: Folder)
	local thickness = Town.COBBLE_THICKNESS
	local diameter = Plots.TOWN_RADIUS * 2
	local centerY = Town.FLOOR_Y - thickness / 2
	local disc = part(
		town,
		"Cobble",
		Vector3.new(thickness, diameter, diameter),
		CFrame.new(0, centerY, 0),
		UITheme.materials.cobble,
		"Soot",
		true
	)
	uprightCylinder(disc, CFrame.new(0, centerY, 0))
end

local function candleAt(parent: Instance, position: Vector3)
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
	part(
		parent,
		"Flame",
		Vector3.new(Lair.CANDLE_FLAME.x, Lair.CANDLE_FLAME.y, Lair.CANDLE_FLAME.z),
		CFrame.new(position + Vector3.new(0, Lair.CANDLE_STICK.y + Lair.CANDLE_FLAME.y / 2, 0)),
		UITheme.materials.candle,
		"Candle",
		false
	)
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
		UITheme.materials.glass,
		"Spirit",
		false
	)
	water.Transparency = 0.35
	uprightCylinder(water, CFrame.new(0, -0.4, 0))
	local drip = part(
		model,
		"WellDrip",
		Vector3.new(0.4, 0.4, 0.4),
		CFrame.new(0, 0.15, 0),
		UITheme.materials.glass,
		"Spirit",
		false
	)
	drip.Transparency = 1
	drip.CanQuery = false
	drip.CastShadow = false
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "SpiritMist"
	emitter.Rate = TownLook.MIST_RATE
	emitter.Lifetime = NumberRange.new(TownLook.MIST_LIFE, TownLook.MIST_LIFE)
	emitter.Speed = NumberRange.new(0.35, 0.8)
	emitter.SpreadAngle = Vector2.new(30, 30)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-12, 12)
	emitter.Acceleration = Vector3.new(0, 0.6, 0)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.LightInfluence = 0
	emitter.Color = ColorSequence.new(UITheme.color("Spirit"))
	emitter.Size = NumberSequence.new(1.4)
	emitter.Transparency = NumberSequence.new(0.45)
	emitter:SetAttribute("TownEffect", "WellSpirit")
	emitter.Parent = drip
	local runes = Instance.new("ParticleEmitter")
	runes.Name = "RuneDrift"
	runes.Rate = TownLook.RUNE_DRIFT_RATE
	runes.Lifetime = NumberRange.new(TownLook.RUNE_DRIFT_LIFE, TownLook.RUNE_DRIFT_LIFE)
	runes.Speed = NumberRange.new(0.2, 0.55)
	runes.SpreadAngle = Vector2.new(20, 20)
	runes.Rotation = NumberRange.new(0, 360)
	runes.RotSpeed = NumberRange.new(-20, 20)
	runes.Acceleration = Vector3.new(0, 0.35, 0)
	runes.EmissionDirection = Enum.NormalId.Top
	runes.LightInfluence = 0
	runes.Color = ColorSequence.new(UITheme.color("Spirit"))
	runes.Size = NumberSequence.new(0.35)
	runes.Transparency = NumberSequence.new(0.2)
	runes:SetAttribute("TownEffect", "WellSpirit")
	runes.Parent = drip
	local spirit = Instance.new("PointLight")
	spirit.Name = "WellLight"
	spirit.Color = UITheme.color("Spirit")
	spirit.Range = TownLook.WELL_LIGHT_RANGE
	spirit.Brightness = TownLook.WELL_LIGHT_BRIGHTNESS
	spirit.Shadows = false
	spirit.Parent = drip
	local foot = -Town.WELL_HEIGHT / 2
	for index = 1, Town.WELL_CANDLES do
		local theta = (index - 1) * (2 * math.pi / Town.WELL_CANDLES)
		runestoneAt(
			model,
			Vector3.new(
				Town.WELL_CANDLE_RADIUS * math.sin(theta),
				foot + 1.15,
				Town.WELL_CANDLE_RADIUS * math.cos(theta)
			),
			if index % 2 == 0 then "Spirit" else "FlameGreen"
		)
	end
	model.Parent = town
	local baseY = Plots.FALLBACK_THICKNESS + Town.WELL_HEIGHT / 2
	model:PivotTo(CFrame.new(Town.WELL_OFFSET, baseY, 0))
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
	local mergedPairs = 0
	local held: { angle: number, scale: number }? = nil
	local function place(angle: number, scale: number, span: number)
		local height = Town.WALL_HEIGHT * scale
		local y = Town.FLOOR_Y + height / 2
		local x = radius * math.sin(angle)
		local z = radius * math.cos(angle)
		local width = radius * step * span + 0.2
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
	local function flush()
		if held ~= nil then
			place(held.angle, held.scale, 1)
			held = nil
		end
	end
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
		if open then
			flush()
			mergedPairs = 0
		else
			local scale = 0.72 + 0.28 * ((index % 5) / 4)
			if mergedPairs < 2 and held == nil then
				held = { angle = angle, scale = scale }
			elseif mergedPairs < 2 and held ~= nil then
				place(held.angle + step / 2, math.max(held.scale, scale), 2)
				held = nil
				mergedPairs += 1
			else
				place(angle, scale, 1)
			end
		end
	end
	flush()
end

local function flicker(light: PointLight)
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return
	end
	task.spawn(function()
		while light.Parent ~= nil do
			local dip = Town.FLICKER_MIN + math.random() * (Town.FLICKER_MAX - Town.FLICKER_MIN)
			light.Brightness = Town.LAMP_DIP_BRIGHTNESS
			task.wait(dip)
			if light.Parent == nil then
				break
			end
			light.Brightness = Lanterns.BRIGHTNESS
			task.wait(Town.FLICKER_GAP)
		end
	end)
end

local function wallWisps(town: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "Wisps"
	folder.Parent = town
	local radius = Plots.TOWN_RADIUS
	for index = 1, Town.WISP.wallCount do
		local theta = math.rad(TownLayout.districtAngle(index))
		local cf = CFrame.new(radius * math.sin(theta), Town.WISP.lift, radius * math.cos(theta))
		Wisp.attach(folder, "WallWisp" .. tostring(index), cf)
	end
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
		local platformHalf = Plots.FALLBACK_SIZE / 2
		if math.abs(position.X) <= platformHalf and math.abs(position.Z) <= platformHalf then
			continue
		end
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
		-- Four ring lamps stay dark so the corner lanterns, well, and portals keep the light cap.
		if index % 4 ~= 0 then
			local light = Instance.new("PointLight")
			light.Color = UITheme.color(Lanterns.COLOR_TOKEN)
			light.Range = Lanterns.RANGE
			light.Brightness = Lanterns.BRIGHTNESS
			light.Shadows = Lanterns.SHADOWS
			light.Parent = head
			if index % Town.FLICKER_STRIDE == 0 then
				flicker(light)
			end
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
		Town.PEDLAR_HOST,
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
	local signCf = CFrame.new(0, Town.STALL_HEIGHT - 1.9, -Town.STALL_DEPTH / 2 - 0.2)
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
			CFrame.new(-(Town.STALL_WIDTH * 0.62) / 2 - 0.85, Town.STALL_HEIGHT - 1.6, -Town.STALL_DEPTH / 2 - 0.35),
			UITheme.materials[Lanterns.RIFT_MATERIAL],
			Lanterns.RIFT_SURFACE,
			false
		)
		local light = Instance.new("PointLight")
		light.Name = "StockLight"
		light.Color = UITheme.color(Lanterns.COLOR_TOKEN)
		light.Range = Lanterns.RANGE
		light.Brightness = Lanterns.BRIGHTNESS
		light.Shadows = Lanterns.SHADOWS
		light.Parent = lantern
		local motes = RiftGlow.attach(lantern, false, false)
		motes.Name = "StockGlow"
		game:GetService("CollectionService"):AddTag(lantern, "PedlarLantern")
		game:GetService("CollectionService"):AddTag(model, "PedlarStall")
		plate(floor, Town.PEDLAR_PROMPT_NAME, Shop.PROMPT)
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
	game:GetService("CollectionService"):AddTag(model, "SkillShrine")
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
			UITheme.materials[Lanterns.RIFT_MATERIAL],
			Lanterns.RIFT_SURFACE,
			false
		)
		uprightCylinder(glow, cf * CFrame.new(0, 0.55, 0))
		glow.Transparency = 0.45
		RiftGlow.attach(glow, true, true)
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

local function dressingRoot(model: Model)
	local root = part(model, "Root", Vector3.new(1, 1, 1), CFrame.new(), UITheme.materials.wood, "Wall", false)
	root.Transparency = 1
	root.CanQuery = false
	root.CastShadow = false
	model.PrimaryPart = root
end

local function plazaCf(angle: number, radius: number): CFrame
	local theta = math.rad(angle)
	local y = Town.FLOOR_Y
	local at = Vector3.new(radius * math.sin(theta), y, radius * math.cos(theta))
	return CFrame.lookAt(at, Vector3.new(0, y, 0))
end

local function facingDisc(piece: Part, cf: CFrame)
	cylinder(piece)
	piece.CFrame = cf * CFrame.Angles(0, math.rad(90), 0)
end

local function colouredFlame(parent: Instance, cf: CFrame, effectId: string, colorToken: string)
	part(parent, "Bowl", Vector3.new(1.8, 0.45, 1.8), cf, UITheme.materials.altar, "Stone", false)
	local fire =
		neonPart(parent, "Flame", Vector3.new(0.9, 1.35, 0.9), cf * CFrame.new(0, 0.85, 0), colorToken, "flame")
	fire.Shape = Enum.PartType.Ball
	fire.Transparency = 0.15
	local host = part(
		parent,
		"FlameHost",
		Vector3.new(0.4, 0.4, 0.4),
		cf * CFrame.new(0, 1.1, 0),
		UITheme.materials.candle,
		colorToken,
		false
	)
	host.Transparency = 1
	host.CanQuery = false
	host.CastShadow = false
	local function emit(tier: string, rate: number, life: number, speed: number, size: number, spread: number)
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = effectId .. tier
		emitter.Rate = rate
		emitter.Lifetime = NumberRange.new(life, life)
		emitter.Speed = NumberRange.new(speed * 0.6, speed)
		emitter.SpreadAngle = Vector2.new(spread, spread)
		emitter.Rotation = NumberRange.new(0, 360)
		emitter.RotSpeed = NumberRange.new(-25, 25)
		emitter.Acceleration = Vector3.new(0, 1.2, 0)
		emitter.EmissionDirection = Enum.NormalId.Top
		emitter.LightInfluence = 0
		emitter.Color = ColorSequence.new(UITheme.color(colorToken))
		emitter.Size = NumberSequence.new(size)
		emitter.Transparency = NumberSequence.new(0.15)
		emitter.Enabled = true
		emitter:SetAttribute("TownEffect", effectId)
		emitter:SetAttribute("TownFlame", tier)
		emitter.Parent = host
	end
	emit("core", TownLook.FLAME_CORE_RATE, TownLook.FLAME_CORE_LIFE, 1.4, 0.9, 12)
	emit("extra", TownLook.FLAME_EXTRA_RATE, TownLook.FLAME_EXTRA_LIFE, 1.8, 0.55, 24)
end

local function mythicSign(parent: Instance, cf: CFrame, text: string, trimToken: string)
	local board = part(parent, "Sign", Vector3.new(8.6, 2.5, 0.28), cf, UITheme.materials.wood, "Ash", false)
	neonPart(parent, "SignTrim", Vector3.new(9, 2.8, 0.12), cf * CFrame.new(0, 0, 0.12), trimToken, "sign")
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
	label.TextColor3 = UITheme.color("Bone")
	label.TextScaled = false
	label.TextSize = UITheme.text.minSize
	label.TextWrapped = true
	label:SetAttribute("TownSign", true)
	label.Parent = gui
end

local function lockIcon(parent: Instance, cf: CFrame)
	local icon = Instance.new("Model")
	icon.Name = "LockIcon"
	local body = part(icon, "LockBody", Vector3.new(0.72, 0.55, 0.18), cf, UITheme.materials.iron, "Gold", false)
	part(
		icon,
		"LockShackle",
		Vector3.new(0.46, 0.28, 0.12),
		cf * CFrame.new(0, 0.4, 0),
		UITheme.materials.iron,
		"Gold",
		false
	)
	icon.PrimaryPart = body
	icon.Parent = parent
end

local function crow(parent: Instance, cf: CFrame)
	local body = part(parent, "CrowBody", Vector3.new(1.15, 0.32, 0.42), cf, UITheme.materials.candle, "Void", false)
	body.Shape = Enum.PartType.Ball
	part(
		parent,
		"CrowWing",
		Vector3.new(1.35, 0.08, 0.36),
		cf * CFrame.new(0, 0.1, 0) * CFrame.Angles(0, 0, math.rad(18)),
		UITheme.materials.candle,
		"Void",
		false
	)
end

local function vortex(model: Model, colorToken: string, effectId: string)
	local discCf = CFrame.new(0, 5.4, 0)
	local disc = neonPart(model, "Vortex", Vector3.new(0.35, 6.4, 6.4), discCf, colorToken, "portal")
	facingDisc(disc, discCf)
	disc.Transparency = 0.42
	local light = Instance.new("PointLight")
	light.Name = "PortalLight"
	light.Color = UITheme.color(colorToken)
	light.Range = TownLook.PORTAL_LIGHT_RANGE
	light.Brightness = TownLook.PORTAL_LIGHT_BRIGHTNESS
	light.Shadows = false
	light.Parent = disc
	local host =
		part(model, "VortexHost", Vector3.new(0.4, 0.4, 0.4), discCf, UITheme.materials.candle, colorToken, false)
	host.Transparency = 1
	host.CanQuery = false
	host.CastShadow = false
	local function emit(name: string, rate: number, life: number, speed: number, size: number, spin: number)
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = name
		emitter.Rate = rate
		emitter.Lifetime = NumberRange.new(life, life)
		emitter.Speed = NumberRange.new(speed * 0.5, speed)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Rotation = NumberRange.new(0, 360)
		emitter.RotSpeed = NumberRange.new(-spin, spin)
		emitter.LightInfluence = 0
		emitter.Color = ColorSequence.new(UITheme.color(colorToken))
		emitter.Size = NumberSequence.new(size)
		emitter.Transparency = NumberSequence.new(0.25)
		emitter.EmissionDirection = Enum.NormalId.Front
		emitter:SetAttribute("TownEffect", effectId)
		emitter.Parent = host
	end
	emit("Swirl", TownLook.VORTEX_SWIRL_RATE, TownLook.VORTEX_SWIRL_LIFE, 0.8, 0.7, 90)
	emit("Sparks", TownLook.VORTEX_SPARK_RATE, TownLook.VORTEX_SPARK_LIFE, 1.6, 0.28, 40)
end

local function portalLabel(spec: any): string
	if spec.level ~= "" then
		return spec.sign .. "\n" .. spec.level
	end
	return spec.sign
end

local function buildApothecary(model: Model, spec: any)
	local trunkCf = CFrame.new(0, 7, 0.6)
	local trunk = part(model, "Trunk", Vector3.new(14, 5.6, 5.6), trunkCf, UITheme.materials.wood, "Bark", true)
	trunk.Shape = Enum.PartType.Cylinder
	trunk.CFrame = trunkCf * CFrame.Angles(0, 0, math.rad(90))
	part(model, "Hollow", Vector3.new(2.8, 3.8, 0.45), CFrame.new(0, 3.1, -2.15), UITheme.materials.wall, "Void", false)
	for _, side in { -1, 1 } do
		local rootCf = CFrame.new(side * 2.4, 1.3, 1.1) * CFrame.Angles(0, 0, math.rad(side * 32))
		local root = part(model, "Root", Vector3.new(4.2, 1.15, 1.15), rootCf, UITheme.materials.wood, "Bark", true)
		root.Shape = Enum.PartType.Cylinder
		root.CFrame = rootCf * CFrame.Angles(0, 0, math.rad(90))
	end
	local frontCf = CFrame.new(0, 1.1, -1.6) * CFrame.Angles(math.rad(28), 0, 0)
	local front = part(model, "Root", Vector3.new(3.6, 1.05, 1.05), frontCf, UITheme.materials.wood, "Bark", true)
	front.Shape = Enum.PartType.Cylinder
	front.CFrame = frontCf * CFrame.Angles(0, 0, math.rad(90))
	local branches = {
		CFrame.new(-3.2, 10.5, -0.4) * CFrame.Angles(0, 0, math.rad(48)),
		CFrame.new(3.1, 11.2, 0.2) * CFrame.Angles(0, 0, math.rad(-42)),
		CFrame.new(0.4, 12.4, -2.2) * CFrame.Angles(math.rad(50), 0, 0),
	}
	for _, cf in branches do
		local branch = part(model, "Branch", Vector3.new(4.4, 0.85, 0.85), cf, UITheme.materials.wood, "Bark", false)
		branch.Shape = Enum.PartType.Cylinder
		branch.CFrame = cf * CFrame.Angles(0, 0, math.rad(90))
	end
	local leaves = {
		Vector3.new(0, 13.2, 0.2),
		Vector3.new(-2.6, 12.2, -0.8),
		Vector3.new(2.5, 12.4, 0.4),
		Vector3.new(-0.8, 12.6, -2.2),
		Vector3.new(1.2, 11.6, 1.8),
	}
	for _, offset in leaves do
		local leaf = part(
			model,
			"Canopy",
			Vector3.new(4.2, 3.4, 3.6),
			CFrame.new(offset),
			UITheme.materials.candle,
			"MossCanopy",
			false
		)
		leaf.Shape = Enum.PartType.Ball
	end
	for index = 1, 3 do
		neonPart(
			model,
			"Rune",
			Vector3.new(0.18, 1.4, 0.85),
			CFrame.new(-1.55, 2.6 + index * 2.05, -1.85) * CFrame.Angles(0, math.rad(18), math.rad(8)),
			"Spirit",
			"rune"
		)
	end
	local eye = neonPart(model, "Eye", Vector3.new(1.7, 1.7, 1.7), CFrame.new(0, 8.4, -2.55), "FlameGreen", "eye")
	eye.Shape = Enum.PartType.Ball
	local pupil = part(
		model,
		"Pupil",
		Vector3.new(0.55, 0.7, 0.4),
		CFrame.new(0, 8.4, -3.25),
		UITheme.materials.candle,
		"Void",
		false
	)
	pupil.Shape = Enum.PartType.Ball
	for index = 1, 3 do
		local cf = CFrame.new(-2.2 + (index - 2) * 0.7, 8.5 - index * 0.15, -2.4)
		local bottle = part(model, "Bottle", Vector3.new(0.7, 0.28, 0.28), cf, UITheme.materials.glass, "Bottle", false)
		bottle.Transparency = 0.25
		bottle.Shape = Enum.PartType.Cylinder
		bottle.CFrame = cf * CFrame.Angles(0, 0, math.rad(90))
	end
	colouredFlame(model, CFrame.new(-2.2, 0.3, -3.4), "ApothecaryFlame", spec.flame)
	colouredFlame(model, CFrame.new(2.2, 0.3, -3.2), "ApothecaryFlame", spec.flame)
	mythicSign(model, CFrame.new(0, 5.6, -3.6), spec.sign, spec.flame)
	crow(model, CFrame.new(2.8, 13.4, -0.6))
end

local function buildTavern(model: Model, spec: any)
	local hullCf = CFrame.new(0, 3.5, 0.4)
	local hull = part(model, "Hull", Vector3.new(15.5, 6.2, 6.2), hullCf, UITheme.materials.wood, "ShipWood", true)
	hull.Shape = Enum.PartType.Cylinder
	hull.CFrame = hullCf * CFrame.Angles(0, math.rad(90), 0)
	part(model, "Keel", Vector3.new(1.1, 0.7, 14.2), CFrame.new(0, 6.5, 0.2), UITheme.materials.wood, "Bark", true)
	for index = -1, 1 do
		part(
			model,
			"Rib",
			Vector3.new(5.4, 0.35, 0.45),
			CFrame.new(0, 3.4, index * 3.2),
			UITheme.materials.wood,
			"Bark",
			false
		)
	end
	part(model, "Deck", Vector3.new(6.2, 0.35, 10), CFrame.new(0, 1.2, 1.2), UITheme.materials.wood, "ShipWood", true)
	local neckCf = CFrame.new(0, 4.6, -7.4) * CFrame.Angles(math.rad(-28), 0, 0)
	local neck = part(model, "SerpentNeck", Vector3.new(3.2, 0.9, 0.9), neckCf, UITheme.materials.candle, "Bone", false)
	neck.Shape = Enum.PartType.Cylinder
	neck.CFrame = neckCf * CFrame.Angles(0, 0, math.rad(90))
	local head = part(
		model,
		"SerpentHead",
		Vector3.new(1.8, 1.3, 2.2),
		CFrame.new(0, 5.5, -9.2),
		UITheme.materials.candle,
		"Bone",
		false
	)
	head.Shape = Enum.PartType.Ball
	part(
		model,
		"SerpentJaw",
		Vector3.new(1.1, 0.35, 1.4),
		CFrame.new(0, 4.9, -10),
		UITheme.materials.candle,
		"Bone",
		false
	)
	local leftEye =
		neonPart(model, "Eye", Vector3.new(0.28, 0.28, 0.28), CFrame.new(-0.45, 5.7, -10), "FlameBlue", "eye")
	leftEye.Shape = Enum.PartType.Ball
	local rightEye =
		neonPart(model, "Eye", Vector3.new(0.28, 0.28, 0.28), CFrame.new(0.45, 5.7, -10), "FlameBlue", "eye")
	rightEye.Shape = Enum.PartType.Ball
	colouredFlame(model, CFrame.new(0, 0.35, -11.2), "TavernFlame", spec.flame)
	mythicSign(model, CFrame.new(0, 8.2, -4.2), spec.sign, spec.flame)
	crow(model, CFrame.new(1.4, 7.1, 2.4))
end

local function buildTarot(model: Model, spec: any)
	local poles = {
		Vector3.new(-3.6, 4.2, -2.6),
		Vector3.new(3.6, 4.2, -2.6),
		Vector3.new(3.6, 4.2, 2.8),
		Vector3.new(-3.6, 4.2, 2.8),
	}
	for _, offset in poles do
		part(model, "Pole", Vector3.new(0.4, 8.4, 0.4), CFrame.new(offset), UITheme.materials.wood, "Bark", true)
	end
	part(
		model,
		"Roof",
		Vector3.new(8.2, 0.35, 6.4),
		CFrame.new(0, 8.3, 0.1) * CFrame.Angles(math.rad(-6), 0, 0),
		UITheme.materials.cloth,
		"TentCloth",
		false
	)
	part(
		model,
		"Drape",
		Vector3.new(6.6, 5.4, 0.22),
		CFrame.new(0, 4.6, -2.6),
		UITheme.materials.cloth,
		"TentCloth",
		false
	)
	part(
		model,
		"Drape",
		Vector3.new(0.22, 5.2, 5.2),
		CFrame.new(-3.6, 4.4, 0.2),
		UITheme.materials.cloth,
		"TentCloth",
		false
	)
	part(
		model,
		"Drape",
		Vector3.new(0.22, 5.2, 5.2),
		CFrame.new(3.6, 4.4, 0.2),
		UITheme.materials.cloth,
		"TentCloth",
		false
	)
	part(
		model,
		"Rug",
		Vector3.new(6.4, 0.12, 4.2),
		CFrame.new(0, 0.1, -4.2),
		UITheme.materials.cloth,
		"TentCloth",
		false
	)
	local sigilCf = CFrame.new(0, 5.3, -2.85)
	local ring = neonPart(model, "EyeSigil", Vector3.new(0.16, 2.5, 2.5), sigilCf, spec.flame, "eye")
	facingDisc(ring, sigilCf)
	local eye =
		neonPart(model, "Eye", Vector3.new(1.15, 1.15, 0.4), sigilCf * CFrame.new(0, 0, -0.12), spec.flame, "eye")
	eye.Shape = Enum.PartType.Ball
	local pupil = part(
		model,
		"Pupil",
		Vector3.new(0.28, 0.55, 0.2),
		sigilCf * CFrame.new(0, 0, -0.28),
		UITheme.materials.candle,
		"Void",
		false
	)
	pupil.Shape = Enum.PartType.Ball
	colouredFlame(model, CFrame.new(0, 0.3, -4.8), "TarotFlame", spec.flame)
	mythicSign(model, CFrame.new(0, 9.4, -2.8), spec.sign, spec.flame)
end

local function buildClock(model: Model, spec: any)
	local lean = 0
	for index = 1, 5 do
		local height = 3.35
		local width = 5.4 - index * 0.48
		local y = (index - 0.5) * height
		lean += 2.4
		part(
			model,
			"Shaft",
			Vector3.new(width, height + 0.08, width),
			CFrame.new((index - 1) * 0.18, y, 0) * CFrame.Angles(math.rad(lean * 0.2), 0, math.rad(lean)),
			UITheme.materials.altar,
			"Stone",
			true
		)
	end
	local faceCf = CFrame.new(0.55, 12.1, -2.45)
	local face =
		part(model, "ClockFace", Vector3.new(0.28, 3.3, 3.3), faceCf, UITheme.materials.candle, "MoonFace", false)
	facingDisc(face, faceCf)
	local moon =
		neonPart(model, "MoonPhase", Vector3.new(1.45, 1.45, 0.35), CFrame.new(0.35, 12.2, -2.7), spec.flame, "sign")
	moon.Shape = Enum.PartType.Ball
	local shadow = part(
		model,
		"MoonShadow",
		Vector3.new(1.1, 1.1, 0.3),
		CFrame.new(0.72, 12.45, -2.82),
		UITheme.materials.candle,
		"NightSky",
		false
	)
	shadow.Shape = Enum.PartType.Ball
	part(
		model,
		"Spire",
		Vector3.new(0.55, 3.4, 0.55),
		CFrame.new(1.35, 18.1, 0.2) * CFrame.Angles(0, 0, math.rad(14)),
		UITheme.materials.iron,
		"Stone",
		true
	)
	mythicSign(model, CFrame.new(0.2, 6.2, -3.3), spec.sign, spec.flame)
	crow(model, CFrame.new(1.6, 16.6, -0.4))
end

local function buildTreeArch(model: Model, spec: any)
	local leftCf = CFrame.new(-3.4, 5.2, 0.2) * CFrame.Angles(0, 0, math.rad(16))
	local left = part(model, "Trunk", Vector3.new(11.5, 1.7, 1.7), leftCf, UITheme.materials.wood, "Bark", false)
	left.Shape = Enum.PartType.Cylinder
	left.CFrame = leftCf * CFrame.Angles(0, 0, math.rad(90))
	local rightCf = CFrame.new(3.4, 5.2, 0.2) * CFrame.Angles(0, 0, math.rad(-16))
	local right = part(model, "Trunk", Vector3.new(11.5, 1.7, 1.7), rightCf, UITheme.materials.wood, "Bark", false)
	right.Shape = Enum.PartType.Cylinder
	right.CFrame = rightCf * CFrame.Angles(0, 0, math.rad(90))
	local lintelCf = CFrame.new(0, 10.2, 0)
	local lintel = part(model, "Lintel", Vector3.new(8.2, 1.15, 1.15), lintelCf, UITheme.materials.wood, "Bark", false)
	lintel.Shape = Enum.PartType.Cylinder
	lintel.CFrame = lintelCf * CFrame.Angles(0, math.rad(90), 0)
	local knot = part(
		model,
		"Knot",
		Vector3.new(1.4, 1.1, 1.2),
		CFrame.new(-2.2, 7.4, -0.8),
		UITheme.materials.wood,
		"Bark",
		false
	)
	knot.Shape = Enum.PartType.Ball
	local other =
		part(model, "Knot", Vector3.new(1.2, 1, 1.1), CFrame.new(2.6, 4.2, 0.6), UITheme.materials.wood, "Bark", false)
	other.Shape = Enum.PartType.Ball
	vortex(model, spec.color, spec.id)
end

local function buildSerpentArch(model: Model, spec: any)
	part(model, "Pillar", Vector3.new(1.5, 8.2, 1.5), CFrame.new(-3.3, 4.1, 0), UITheme.materials.altar, "Stone", false)
	part(model, "Pillar", Vector3.new(1.5, 8.2, 1.5), CFrame.new(3.3, 4.1, 0), UITheme.materials.altar, "Stone", false)
	local head = part(
		model,
		"SerpentHead",
		Vector3.new(4.4, 3.2, 3.6),
		CFrame.new(0, 9.4, 0.2),
		UITheme.materials.altar,
		"Stone",
		false
	)
	head.Shape = Enum.PartType.Ball
	part(model, "Snout", Vector3.new(1.6, 1.1, 2.4), CFrame.new(0, 8.6, -2.2), UITheme.materials.altar, "Stone", false)
	part(model, "Jaw", Vector3.new(2.2, 0.45, 1.8), CFrame.new(0, 7.7, -1.6), UITheme.materials.altar, "Stone", false)
	local leftEye =
		neonPart(model, "Eye", Vector3.new(0.42, 0.42, 0.42), CFrame.new(-0.7, 9.7, -1.5), spec.color, "eye")
	leftEye.Shape = Enum.PartType.Ball
	local rightEye =
		neonPart(model, "Eye", Vector3.new(0.42, 0.42, 0.42), CFrame.new(0.7, 9.7, -1.5), spec.color, "eye")
	rightEye.Shape = Enum.PartType.Ball
	vortex(model, spec.color, spec.id)
end

local function buildRibcage(model: Model, spec: any)
	part(
		model,
		"Pillar",
		Vector3.new(1.2, 7.4, 1.2),
		CFrame.new(-4.2, 3.7, 0.2),
		UITheme.materials.altar,
		"Bone",
		false
	)
	part(model, "Pillar", Vector3.new(1.2, 7.4, 1.2), CFrame.new(4.2, 3.7, 0.2), UITheme.materials.altar, "Bone", false)
	for index = 1, 4 do
		local y = 2.4 + index * 1.55
		local spread = 4.3 - index * 0.55
		local roll = 32 + index * 10
		part(
			model,
			"Rib",
			Vector3.new(0.42, 3.3, 0.42),
			CFrame.new(-spread, y, 0) * CFrame.Angles(0, 0, math.rad(roll)),
			UITheme.materials.altar,
			"Bone",
			false
		)
		part(
			model,
			"Rib",
			Vector3.new(0.42, 3.3, 0.42),
			CFrame.new(spread, y, 0) * CFrame.Angles(0, 0, math.rad(-roll)),
			UITheme.materials.altar,
			"Bone",
			false
		)
	end
	vortex(model, spec.color, spec.id)
end

local function newDressing(id: string): Model
	local model = Instance.new("Model")
	model.Name = id
	dressingRoot(model)
	return model
end

local function buildHollowmere(town: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "Hollowmere"
	folder.Parent = town
	for _, spec in TownLook.SHOPS do
		local model = newDressing(spec.id)
		if spec.kind == "apothecary" then
			buildApothecary(model, spec)
		elseif spec.kind == "tavern" then
			buildTavern(model, spec)
		elseif spec.kind == "tarot" then
			buildTarot(model, spec)
		elseif spec.kind == "clock" then
			buildClock(model, spec)
		else
			error("Unknown Hollowmere shop: " .. tostring(spec.kind), 2)
		end
		model.Parent = folder
		placeModel(model, plazaCf(spec.angle, spec.radius))
	end
	for _, spec in TownLook.PORTALS do
		local model = newDressing(spec.id)
		if spec.kind == "tree" then
			buildTreeArch(model, spec)
		elseif spec.kind == "serpent" then
			buildSerpentArch(model, spec)
		elseif spec.kind == "ribcage" then
			buildRibcage(model, spec)
		else
			error("Unknown Hollowmere portal: " .. tostring(spec.kind), 2)
		end
		mythicSign(model, CFrame.new(0, 12.5, -0.5), portalLabel(spec), spec.color)
		lockIcon(model, CFrame.new(5.05, 12.5, -0.5))
		model.Parent = folder
		placeModel(model, plazaCf(spec.angle, spec.radius))
	end
	local brazierSpec = TownLook.BRAZIER
	local brazier = newDressing(brazierSpec.id)
	colouredFlame(brazier, CFrame.new(0, 0.35, 0), "CrimsonFlame", brazierSpec.color)
	brazier.Parent = folder
	placeModel(brazier, plazaCf(brazierSpec.angle, brazierSpec.radius))
end

function TownBuilder.build(town: Folder)
	-- The town is large enough to stall Play solo if the server never yields.
	-- selene: allow(global_usage)
	if _G.LUNE ~= true then
		task.wait()
	end
	cobble(town)
	well(town)
	roads(town)
	wall(town)
	wallWisps(town)
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
	buildHollowmere(town)
	-- selene: allow(global_usage)
	if _G.LUNE ~= true then
		task.wait()
	end
	TownKits.applyAll(town, {})
end

return TownBuilder
