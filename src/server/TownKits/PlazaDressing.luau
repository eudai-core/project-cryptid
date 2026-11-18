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
local Town = import("../../shared/Config/Town", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Town")
end) :: any
local TownLayout = import("../../shared/Logic/TownLayout", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("TownLayout")
end) :: any
local Plots = import("../../shared/Config/Plots", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Plots")
end) :: any
local Lanterns = import("../../shared/Config/Lanterns", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Lanterns")
end) :: any
local UITheme = import("../../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any

local PlazaDressing = {}

local CLEARANCE = 10
local WALK_TOP = 7.2
local WELL_PAD = 9
local PROMPT_PAD = 5
local LIGHT_BUDGET = 50
local NEW_LAMP_CAP = 28
local CRYSTAL_CAP = 40
local CRYSTAL_CAP_LOW = 8
local RUNE_CAP = 16

local WOOD = UITheme.materials.wood
local STONE = UITheme.materials.altar
local METAL = UITheme.materials.iron
local CLOTH = UITheme.materials.cloth
local GLASS = UITheme.materials.glass
local NEON = UITheme.materials.neon

local SHOP_FOOT = {
	RuneheartApothecary = { hx = 7.5, hz = 8.5 },
	HowlingHorn = { hx = 8.5, hz = 17.5 },
	VeilAndFate = { hx = 6.5, hz = 7.5 },
	DuskAndDial = { hx = 5.5, hz = 6.5 },
	WhisperingWoods = { hx = 6.5, hz = 5.5 },
	SunkenMarsh = { hx = 6.5, hz = 5.5 },
	BoneQuarry = { hx = 6.5, hz = 5.5 },
	CrimsonBrazier = { hx = 2.5, hz = 2.5 },
}

local CRYSTAL_COLORS = { "FlameGreen", "Spirit", "Blood", "Gold", "Bone" }
local BRAZIER_COLORS = { "FlameCrimson", "Spirit", "FlameGreen", "Gold" }
local BRAZIER_COUNT = 8

local function distance(a: any, b: any): number
	local dx = a.X - b.X
	local dy = a.Y - b.Y
	local dz = a.Z - b.Z
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function findNamed(root: Instance, name: string): any
	if root.Name == name then
		return root
	end
	for _, inst in root:GetDescendants() do
		if inst.Name == name then
			return inst
		end
	end
	return nil
end

local function pivotOf(model: any): any
	if type(model.GetPivot) == "function" then
		return model:GetPivot()
	end
	if model.PrimaryPart ~= nil and model.PrimaryPart.CFrame ~= nil then
		return model.PrimaryPart.CFrame
	end
	return nil
end

local function owningModel(town: Instance, inst: any): any
	local cursor = inst.Parent
	while cursor ~= nil and cursor ~= town do
		if cursor.ClassName == "Model" then
			return cursor
		end
		cursor = cursor.Parent
	end
	return nil
end

local function hasLight(part: any): boolean
	for _, child in part:GetChildren() do
		local className = child.ClassName
		if className == "PointLight" or className == "SpotLight" or className == "SurfaceLight" then
			return true
		end
	end
	return false
end

local function makePart(parent: Instance, spec: any): any
	spec.parent = parent
	return Kit.spawn(spec)
end

local function upright(at: any): any
	return CFrame.new(at) * CFrame.Angles(0, 0, math.rad(90))
end

local function cylinderBetween(
	parent: Instance,
	name: string,
	a: any,
	b: any,
	diameter: number,
	material: string,
	color: string,
	decor: boolean
): any
	local dx = b.X - a.X
	local dy = b.Y - a.Y
	local dz = b.Z - a.Z
	local span = math.sqrt(dx * dx + dy * dy + dz * dz)
	local target = b
	if span < 0.05 then
		span = 0.05
		target = Vector3.new(a.X, a.Y + 0.05, a.Z)
	end
	local mid = Vector3.new((a.X + target.X) * 0.5, (a.Y + target.Y) * 0.5, (a.Z + target.Z) * 0.5)
	local cf = CFrame.lookAt(mid, target) * CFrame.Angles(0, math.rad(90), 0)
	return makePart(parent, {
		name = name,
		size = Vector3.new(span, diameter, diameter),
		cf = cf,
		material = material,
		color = color,
		decor = decor,
		shadow = not decor,
		shape = Enum.PartType.Cylinder,
	})
end

local function collect(town: Instance): any
	local approaches = {}
	local spheres = {}
	local roads = {}
	local footprints = {}
	local sawDoor = {}

	local function addApproach(cf: any, length: number, halfWidth: number, nose: number)
		if cf == nil or cf.LookVector == nil or cf.Position == nil then
			return
		end
		local look = cf.LookVector
		local origin = cf.Position + look * nose
		table.insert(approaches, {
			x = origin.X,
			y = origin.Y,
			z = origin.Z,
			lx = look.X,
			ly = look.Y,
			lz = look.Z,
			length = length,
			halfWidth = halfWidth,
		})
	end

	local function addSphere(position: any, radius: number)
		if position == nil then
			return
		end
		table.insert(spheres, {
			x = position.X,
			y = position.Y,
			z = position.Z,
			radius = radius,
		})
	end

	for _, inst in town:GetDescendants() do
		local name = inst.Name
		if type(name) ~= "string" then
			continue
		end
		if name == "DoorAnchor" and inst:GetAttribute("TownAnchor") == "Door" and inst.CFrame ~= nil then
			local model = owningModel(town, inst)
			if model ~= nil then
				sawDoor[model.Name] = true
			end
			local half = inst.Size.X * 0.5 + 2
			if half < 4 then
				half = 4
			end
			addApproach(inst.CFrame, CLEARANCE, half, inst.Size.Z * 0.5)
		elseif name == "TownRoad" and inst.CFrame ~= nil and inst.Size ~= nil then
			table.insert(roads, inst)
		elseif string.sub(name, -13) == "PromptAnchor" and inst.CFrame ~= nil then
			addSphere(inst.CFrame.Position, PROMPT_PAD)
		elseif inst.ClassName == "ProximityPrompt" and inst.Parent ~= nil and inst.Parent.CFrame ~= nil then
			addSphere(inst.Parent.CFrame.Position, PROMPT_PAD)
		elseif string.sub(name, 1, 9) == "Reserved_" and inst.CFrame ~= nil then
			addSphere(inst.CFrame.Position, 13)
		end
	end

	for _, spec in TownLook.SHOPS do
		local model = findNamed(town, spec.id)
		local cf = if model ~= nil then pivotOf(model) else nil
		if cf ~= nil and sawDoor[spec.id] ~= true then
			addApproach(cf, CLEARANCE, 4.5, 0)
		end
		local foot = SHOP_FOOT[spec.id]
		if model ~= nil and cf ~= nil and foot ~= nil then
			table.insert(footprints, { cf = cf, hx = foot.hx, hz = foot.hz })
		end
	end

	for _, spec in TownLook.PORTALS do
		local model = findNamed(town, spec.id)
		local cf = if model ~= nil then pivotOf(model) else nil
		if cf ~= nil then
			addApproach(cf, CLEARANCE, 5.5, 0)
			local foot = SHOP_FOOT[spec.id]
			if foot ~= nil then
				table.insert(footprints, { cf = cf, hx = foot.hx, hz = foot.hz })
			end
		end
	end

	local brazier = findNamed(town, TownLook.BRAZIER.id)
	local brazierCf = if brazier ~= nil then pivotOf(brazier) else nil
	local brazierFoot = SHOP_FOOT[TownLook.BRAZIER.id]
	if brazierCf ~= nil and brazierFoot ~= nil then
		table.insert(footprints, { cf = brazierCf, hx = brazierFoot.hx, hz = brazierFoot.hz })
	end

	local well = findNamed(town, "WeepingWell")
	local wellCf = if well ~= nil then pivotOf(well) else nil
	if wellCf ~= nil then
		addSphere(wellCf.Position, WELL_PAD)
	end

	for _, spec in Town.DISTRICTS do
		local model = findNamed(town, spec.id)
		local cf = if model ~= nil then pivotOf(model) else nil
		if cf ~= nil then
			addSphere(cf.Position, 12)
		end
	end

	return {
		approaches = approaches,
		spheres = spheres,
		roads = roads,
		footprints = footprints,
	}
end

local function hitsApproach(keep: any, x: number, y: number, z: number, margin: number): boolean
	if y > WALK_TOP then
		return false
	end
	for _, approach in keep.approaches do
		local dx = x - approach.x
		local dy = y - approach.y
		local dz = z - approach.z
		local along = dx * approach.lx + dy * approach.ly + dz * approach.lz
		if along >= -0.8 - margin and along <= approach.length + margin then
			local lx = dx - approach.lx * along
			local ly = dy - approach.ly * along
			local lz = dz - approach.lz * along
			local lateral = math.sqrt(lx * lx + ly * ly + lz * lz)
			if lateral <= approach.halfWidth + margin then
				return true
			end
		end
	end
	return false
end

local function hitsSphere(keep: any, x: number, y: number, z: number, margin: number): boolean
	for _, sphere in keep.spheres do
		if math.abs(y - sphere.y) <= 6 then
			local dx = x - sphere.x
			local dz = z - sphere.z
			local reach = sphere.radius + margin
			if dx * dx + dz * dz <= reach * reach then
				return true
			end
		end
	end
	return false
end

local function hitsRoad(keep: any, x: number, y: number, z: number, margin: number): boolean
	local point = Vector3.new(x, y, z)
	for _, road in keep.roads do
		local localPos = road.CFrame:Inverse() * point
		if
			math.abs(localPos.X) <= road.Size.X * 0.5 + margin
			and math.abs(localPos.Z) <= road.Size.Z * 0.5 + margin
		then
			return true
		end
	end
	return false
end

local function hitsFootprint(keep: any, x: number, z: number, margin: number): boolean
	for _, box in keep.footprints do
		local localPos = box.cf:Inverse() * Vector3.new(x, box.cf.Y, z)
		if math.abs(localPos.X) <= box.hx + margin and math.abs(localPos.Z) <= box.hz + margin then
			return true
		end
	end
	return false
end

local function pointClear(
	keep: any,
	x: number,
	y: number,
	z: number,
	margin: number,
	avoidRoad: boolean,
	bulky: boolean
): boolean
	if hitsApproach(keep, x, y, z, margin) or hitsSphere(keep, x, y, z, margin) then
		return false
	end
	if avoidRoad and hitsRoad(keep, x, y, z, margin) then
		return false
	end
	if bulky and hitsFootprint(keep, x, z, margin) then
		return false
	end
	return true
end

local function columnClear(
	keep: any,
	x: number,
	z: number,
	height: number,
	margin: number,
	avoidRoad: boolean,
	bulky: boolean
): boolean
	local foot = Town.FLOOR_Y + 0.35
	local mid = Town.FLOOR_Y + height * 0.5
	local top = Town.FLOOR_Y + math.min(height, WALK_TOP)
	return pointClear(keep, x, foot, z, margin, avoidRoad, bulky)
		and pointClear(keep, x, mid, z, margin, avoidRoad, bulky)
		and pointClear(keep, x, top, z, margin, avoidRoad, bulky)
end

local function addGlow(parent: Instance, range: number, brightness: number, token: string, budget: any): any
	if budget.lights >= LIGHT_BUDGET then
		return nil
	end
	local light = Instance.new("SurfaceLight")
	light.Name = "LanternGlow"
	light.Face = Enum.NormalId.Front
	light.Angle = 80
	light.Color = UITheme.color(token)
	light.Range = range
	light.Brightness = brightness
	light.Shadows = false
	light:SetAttribute("PlazaGlow", true)
	light.Parent = parent
	budget.lights += 1
	table.insert(budget.flicker, {
		light = light,
		full = brightness,
		seed = budget.lights * 0.7,
	})
	return light
end

local function addLife(parent: Instance, name: string, spec: any, token: string, lift: number)
	if NumberRange == nil or Vector2 == nil or ColorSequence == nil or NumberSequence == nil then
		return
	end
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = name
	emitter.Rate = spec.rate
	emitter.Lifetime = NumberRange.new(spec.life, spec.life)
	emitter.Speed = NumberRange.new(spec.speed * 0.45, spec.speed)
	emitter.SpreadAngle = Vector2.new(spec.spread, spec.spread)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-18, 18)
	emitter.Acceleration = Vector3.new(0, lift, 0)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.LightInfluence = 0
	emitter.Color = ColorSequence.new(UITheme.color(token))
	emitter.Size = NumberSequence.new(spec.size)
	emitter.Transparency = NumberSequence.new(0.45)
	emitter.Enabled = true
	emitter:SetAttribute("TownEffect", "PlazaLife")
	emitter:SetAttribute("TownFlame", "extra")
	emitter.Parent = parent
end

local function addFlame(parent: Instance, token: string)
	if NumberRange == nil or Vector2 == nil or ColorSequence == nil or NumberSequence == nil then
		return
	end
	local spec = TownLook.PLAZA_VFX.brazier
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "BrazierFlame"
	emitter.Rate = spec.rate
	emitter.Lifetime = NumberRange.new(spec.life, spec.life)
	emitter.Speed = NumberRange.new(spec.speed * 0.55, spec.speed)
	emitter.SpreadAngle = Vector2.new(spec.spread, spec.spread)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-20, 20)
	emitter.Acceleration = Vector3.new(0, 1.35, 0)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.LightInfluence = 0
	emitter.Color = ColorSequence.new(UITheme.color(token))
	emitter.Size = NumberSequence.new(spec.size)
	emitter.Transparency = NumberSequence.new(0.2)
	emitter.Enabled = true
	emitter:SetAttribute("TownEffect", "PlazaBrazier")
	emitter:SetAttribute("TownFlame", "extra")
	emitter.Parent = parent
end

-- Same contract as Kit.animate: no work under Lune, Heartbeat on the server,
-- pcall around each step, and the connection drops when the model is destroyed.
local function animate(model: Instance, step: (number, number) -> ())
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return
	end
	local ran, run = pcall(function()
		return game:GetService("RunService")
	end)
	if not ran or run == nil or run.Heartbeat == nil or type(run.Heartbeat.Connect) ~= "function" then
		return
	end
	local origin = os.clock()
	local connection: any = nil
	local function onHeartbeat(dt: number)
		local ok = pcall(step, dt, os.clock() - origin)
		if not ok and connection ~= nil then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end
	local hooked, result = pcall(function()
		return run.Heartbeat:Connect(onHeartbeat)
	end)
	if not hooked or result == nil then
		return
	end
	connection = result
	local function stop()
		pcall(function()
			connection:Disconnect()
		end)
	end
	if model.Destroying ~= nil and type(model.Destroying.Connect) == "function" then
		pcall(function()
			model.Destroying:Connect(function()
				stop()
			end)
		end)
	end
end

local function drive(flicker: { any }, sways: { any }, dt: number, t: number)
	if dt < 0 then
		return
	end
	for _, item in flicker do
		pcall(function()
			local wave = 0.5 + 0.5 * math.sin(t * 7.5 + item.seed)
			local light = item.light
			if light ~= nil and light.Parent ~= nil then
				local full = item.full
				local dip = Town.LAMP_DIP_BRIGHTNESS
				light.Brightness = dip + (full - dip) * (0.3 + 0.7 * wave)
			end
			local wick = item.wick
			if wick ~= nil and wick.Parent ~= nil then
				wick.Transparency = 0.06 + 0.38 * (1 - wave)
			end
		end)
	end
	for _, item in sways do
		pcall(function()
			local part = item.part
			if part.Parent == nil then
				return
			end
			local angle = math.sin(t * item.speed + item.seed) * item.amp
			part.CFrame = item.base * CFrame.Angles(0, angle, 0)
		end)
	end
end

local function rememberSway(sways: { any }, part: any, amp: number, speed: number, seed: number)
	if part == nil or part.CFrame == nil then
		return
	end
	table.insert(sways, {
		part = part,
		base = part.CFrame,
		amp = amp,
		speed = speed,
		seed = seed,
	})
end

local function dressPost(
	parent: Instance,
	x: number,
	y: number,
	z: number,
	detail: boolean,
	budget: any,
	seed: number
): any
	local foot = Vector3.new(x, Town.FLOOR_Y + 0.08, z)
	makePart(parent, {
		name = "LampBase",
		size = Vector3.new(0.16, 1.35, 1.35),
		cf = upright(foot + Vector3.new(0, 0.08, 0)),
		material = METAL,
		color = "Void",
		decor = true,
		shadow = true,
		shape = Enum.PartType.Cylinder,
	})
	local wickAt = Vector3.new(x, y, z)
	local wick = makePart(parent, {
		name = "LanternWick",
		size = Vector3.new(0.55, 0.72, 0.55),
		cf = CFrame.new(wickAt),
		material = NEON,
		color = Lanterns.COLOR_TOKEN,
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
		neonRole = "flame",
	})
	wick.Transparency = 0.12
	table.insert(budget.flicker, {
		wick = wick,
		seed = seed,
	})
	makePart(parent, {
		name = "LampFinial",
		size = Vector3.new(0.55, 0.16, 0.16),
		cf = upright(wickAt + Vector3.new(0, 0.55, 0)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	if detail then
		makePart(parent, {
			name = "LampCage",
			size = Vector3.new(0.08, 1.05, 1.05),
			cf = upright(wickAt),
			material = METAL,
			color = "Void",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
		makePart(parent, {
			name = "GoldBand",
			size = Vector3.new(0.08, 0.85, 0.85),
			cf = upright(wickAt + Vector3.new(0, -0.42, 0)),
			material = METAL,
			color = "Gold",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
		for side = -1, 1, 2 do
			cylinderBetween(
				parent,
				"LampScroll",
				Vector3.new(x, y - 1.15, z),
				Vector3.new(x + side * 0.55, y - 0.35, z),
				0.08,
				METAL,
				"Void",
				true
			)
		end
	end
	return wick
end

local function upgradeLamps(town: Instance, parent: Instance, keep: any, detail: boolean, budget: any): number
	local folder = town:FindFirstChild("Lamps")
	if folder == nil then
		return 0
	end
	local posts = {}
	local heads = {}
	for _, inst in folder:GetDescendants() do
		if inst.ClassName == "Part" and inst.CFrame ~= nil then
			if inst.Name == "LampPost" then
				table.insert(posts, inst)
			elseif inst.Name == "Lamp" then
				table.insert(heads, inst)
			end
		end
	end
	local iron = Enum.Material[METAL]
	local glass = Enum.Material[GLASS]
	local dressed = 0
	for index, post in posts do
		post.Material = iron
		post.Color = UITheme.color("Void")
		post:SetAttribute("PlazaDressed", true)
		local anchor = post.CFrame.Position
		local head = nil
		local best = 8
		for _, candidate in heads do
			local gap = distance(anchor, candidate.CFrame.Position)
			if gap < best then
				best = gap
				head = candidate
			end
		end
		local wickY = anchor.Y + Town.LAMP_HEIGHT * 0.5 + 0.55
		if head ~= nil then
			head.Material = glass
			head.Color = UITheme.color(Lanterns.COLOR_TOKEN)
			head.Transparency = 0.32
			head:SetAttribute("PlazaDressed", true)
			wickY = head.CFrame.Position.Y
		end
		local wick = nil
		if columnClear(keep, anchor.X, anchor.Z, Town.LAMP_HEIGHT, 1.6, false, false) then
			wick = dressPost(parent, anchor.X, wickY, anchor.Z, detail, budget, index)
		end
		if wick ~= nil and detail and (head == nil or not hasLight(head)) then
			addGlow(
				wick,
				TownLook.PLAZA_LIGHT.lantern.range,
				TownLook.PLAZA_LIGHT.lantern.brightness,
				Lanterns.COLOR_TOKEN,
				budget
			)
		end
		dressed += 1
	end
	return dressed
end

local function buildNewLamp(
	parent: Instance,
	x: number,
	z: number,
	detail: boolean,
	budget: any,
	seed: number,
	withLight: boolean
)
	local height = Town.LAMP_HEIGHT - 0.8
	local center = Vector3.new(x, Town.FLOOR_Y + height * 0.5, z)
	makePart(parent, {
		name = "PlazaLamp",
		size = Vector3.new(height, 0.38, 0.38),
		cf = upright(center),
		material = METAL,
		color = "Void",
		decor = false,
		shadow = true,
		shape = Enum.PartType.Cylinder,
	})
	local wickY = Town.FLOOR_Y + height + 0.35
	local wick = dressPost(parent, x, wickY, z, detail, budget, seed)
	if detail and withLight then
		addGlow(
			wick,
			TownLook.PLAZA_LIGHT.lantern.range,
			TownLook.PLAZA_LIGHT.lantern.brightness,
			Lanterns.COLOR_TOKEN,
			budget
		)
	end
end

local function placeNewLamps(parent: Instance, keep: any, detail: boolean, budget: any): number
	local placed = 0
	local function attempt(x: number, z: number, seed: number, withLight: boolean)
		if placed >= NEW_LAMP_CAP then
			return
		end
		if not columnClear(keep, x, z, Town.LAMP_HEIGHT, 1.4, true, true) then
			return
		end
		buildNewLamp(parent, x, z, detail, budget, seed, withLight)
		placed += 1
	end
	local innerCount = 16
	for index = 1, innerCount do
		local theta = (index - 0.5) * (2 * math.pi / innerCount)
		local radius = 15.5 + ((index % 3) - 1) * 0.6
		attempt(radius * math.sin(theta), radius * math.cos(theta), index, index % 2 == 0)
	end
	local flank = Town.ROAD_WIDTH * 0.5 + 3.6
	for road = 1, Plots.COUNT do
		local theta = math.rad(TownLayout.roadAngle(road))
		local rx = math.sin(theta)
		local rz = math.cos(theta)
		local px = rz
		local pz = -rx
		for _, radius in { 26, 34, 44 } do
			for side = -1, 1, 2 do
				local x = rx * radius + px * side * flank
				local z = rz * radius + pz * side * flank
				attempt(x, z, road * 10 + radius + side, false)
			end
		end
	end
	return placed
end

local function growTree(parent: Instance, x: number, z: number, detail: boolean, sways: { any }, seed: number): boolean
	local segments = if detail then 5 else 3
	local height = if detail then 11.5 else 8.2
	local points = {}
	for step = 0, segments do
		local t = step / segments
		local sway = math.sin(seed + t * 2.7) * 1.15 * t
		local cross = math.cos(seed * 0.7 + t * 2.1) * 0.85 * t
		points[step + 1] = Vector3.new(x + sway, Town.FLOOR_Y + t * height, z + cross)
	end
	local top = nil
	for step = 1, segments do
		local girth = 1.45 * (1 - 0.75 * ((step - 1) / segments))
		local piece = cylinderBetween(parent, "DeadTree", points[step], points[step + 1], girth, WOOD, "Bark", step > 2)
		if step == segments then
			top = piece
		end
		if detail then
			makePart(parent, {
				name = "TreeKnuckle",
				size = Vector3.new(girth * 1.25, girth * 1.05, girth * 1.25),
				cf = CFrame.new(points[step]),
				material = WOOD,
				color = "Bark",
				decor = true,
				shadow = true,
				shape = Enum.PartType.Ball,
			})
		end
	end
	local limbs = if detail then 4 else 1
	for limb = 1, limbs do
		local joint = points[math.max(segments - 1, 2)]
		local turn = seed + limb * 1.4
		local reach = 2.4 + (limb % 2) * 0.8
		local tip =
			Vector3.new(joint.X + math.cos(turn) * reach, joint.Y + 1.1 + limb * 0.25, joint.Z + math.sin(turn) * reach)
		local branch = cylinderBetween(parent, "TreeLimb", joint, tip, 0.28, WOOD, "Void", true)
		if limb == 1 then
			rememberSway(sways, branch, 0.05, 0.45, seed)
		end
		if detail then
			local twig = tip + Vector3.new(math.sin(turn) * 0.9, 0.7, math.cos(turn) * 0.7)
			cylinderBetween(parent, "TreeTwig", tip, twig, 0.12, WOOD, "Bark", true)
		end
	end
	rememberSway(sways, top, 0.03, 0.35, seed)
	return true
end

local function placeTrees(parent: Instance, keep: any, detail: boolean, sways: { any }): number
	local placed = 0
	local cap = if detail then 6 else 3
	for index = 1, Plots.COUNT do
		if placed >= cap then
			break
		end
		local angle = math.rad(TownLayout.roadAngle(index) + 22.5)
		for _, radius in { 102, 94 } do
			local x = radius * math.sin(angle)
			local z = radius * math.cos(angle)
			if columnClear(keep, x, z, 8, 2.2, true, true) then
				growTree(parent, x, z, detail, sways, index + radius * 0.01)
				placed += 1
				break
			end
		end
	end
	return placed
end

local function placeFences(parent: Instance, keep: any, detail: boolean): number
	local placed = 0
	local cap = if detail then 8 else 4
	for index = 1, Plots.COUNT do
		if placed >= cap then
			break
		end
		local angle = math.rad(TownLayout.roadAngle(index) + 22.5)
		local radius = 96
		local x = radius * math.sin(angle)
		local z = radius * math.cos(angle)
		if not columnClear(keep, x, z, 1.6, 1.6, true, true) then
			continue
		end
		local tangent = Vector3.new(math.cos(angle), 0, -math.sin(angle))
		for slot = -1, 1 do
			local at = Vector3.new(x, Town.FLOOR_Y + 0.7, z) + tangent * (slot * 1.7)
			makePart(parent, {
				name = "FencePost",
				size = Vector3.new(1.35, 0.22, 0.22),
				cf = upright(at),
				material = METAL,
				color = "Void",
				decor = false,
				shadow = true,
				shape = Enum.PartType.Cylinder,
			})
		end
		cylinderBetween(
			parent,
			"FenceRail",
			Vector3.new(x, Town.FLOOR_Y + 0.95, z) - tangent * 1.7,
			Vector3.new(x, Town.FLOOR_Y + 0.95, z) + tangent * 1.7,
			0.1,
			METAL,
			"Gold",
			true
		)
		local lean = if index % 2 == 0 then -16 else 14
		local graveAt = Vector3.new(x, Town.FLOOR_Y + 0.85, z) - Vector3.new(math.sin(angle), 0, math.cos(angle)) * 2.4
		if pointClear(keep, graveAt.X, graveAt.Y, graveAt.Z, 1.2, true, true) then
			makePart(parent, {
				className = "WedgePart",
				name = "GraveStone",
				size = Vector3.new(1.15, 1.55, 0.28),
				cf = CFrame.new(graveAt) * CFrame.Angles(math.rad(lean), angle, 0),
				material = STONE,
				color = "Bone",
				decor = false,
				shadow = true,
			})
			if detail then
				makePart(parent, {
					name = "GraveRune",
					size = Vector3.new(0.08, 0.55, 0.28),
					cf = CFrame.new(graveAt + Vector3.new(0, 0.25, 0)),
					material = NEON,
					color = "Spirit",
					decor = true,
					shadow = false,
					neonRole = "rune",
				})
			end
		end
		placed += 1
	end
	return placed
end

local function placeBanners(parent: Instance, keep: any, detail: boolean, sways: { any }): number
	local placed = 0
	local cap = if detail then 6 else 3
	for index = 1, Plots.COUNT do
		if placed >= cap then
			break
		end
		local angle = math.rad(TownLayout.roadAngle(index) + 22.5)
		local radius = 93
		local x = radius * math.sin(angle)
		local z = radius * math.cos(angle)
		if not columnClear(keep, x, z, 6, 1.2, true, true) then
			continue
		end
		makePart(parent, {
			name = "BannerPole",
			size = Vector3.new(6.4, 0.16, 0.16),
			cf = upright(Vector3.new(x, Town.FLOOR_Y + 3.2, z)),
			material = METAL,
			color = "Void",
			decor = true,
			shadow = true,
			shape = Enum.PartType.Cylinder,
		})
		local cloth = makePart(parent, {
			className = "WedgePart",
			name = "PlazaBanner",
			size = Vector3.new(1.6, 2.8, 0.12),
			cf = CFrame.new(x, Town.FLOOR_Y + 4.6, z) * CFrame.Angles(0, angle, math.rad(8)),
			material = CLOTH,
			color = "Blood",
			decor = true,
			shadow = false,
		})
		rememberSway(sways, cloth, 0.12, 0.8, index)
		if detail then
			makePart(parent, {
				name = "BannerTip",
				size = Vector3.new(0.28, 0.28, 0.28),
				cf = CFrame.new(x, Town.FLOOR_Y + 6.5, z),
				material = METAL,
				color = "Gold",
				decor = true,
				shadow = false,
				shape = Enum.PartType.Ball,
			})
		end
		placed += 1
	end
	return placed
end

local function placeBunting(parent: Instance, keep: any, detail: boolean, sways: { any })
	if not detail then
		return
	end
	local hooks = {}
	for _, inst in parent:GetDescendants() do
		if inst.Name == "LanternWick" and inst.CFrame ~= nil then
			local at = inst.CFrame.Position
			local radius = math.sqrt(at.X * at.X + at.Z * at.Z)
			if radius < 22 then
				table.insert(hooks, { x = at.X, z = at.Z, angle = math.atan2(at.X, at.Z) })
			end
		end
	end
	table.sort(hooks, function(a, b)
		return a.angle < b.angle
	end)
	local spans = 0
	for index = 1, #hooks do
		if spans >= 8 then
			break
		end
		local nextIndex = if index == #hooks then 1 else index + 1
		local a = hooks[index]
		local b = hooks[nextIndex]
		local midX = (a.x + b.x) * 0.5
		local midZ = (a.z + b.z) * 0.5
		local y = Town.FLOOR_Y + 8.8
		if pointClear(keep, midX, y, midZ, 0.4, false, false) then
			for flag = 1, 3 do
				local t = flag / 4
				local fx = a.x + (b.x - a.x) * t
				local fz = a.z + (b.z - a.z) * t
				local cloth = makePart(parent, {
					className = "WedgePart",
					name = "Bunting",
					size = Vector3.new(0.7, 0.85, 0.06),
					cf = CFrame.new(fx, y - 0.2, fz),
					material = CLOTH,
					color = if flag % 2 == 0 then "Blood" else "Gold",
					decor = true,
					shadow = false,
				})
				rememberSway(sways, cloth, 0.18, 1.1, index + flag)
			end
			spans += 1
		end
	end
end

local function placeCrates(parent: Instance, town: Instance, keep: any, detail: boolean): number
	local placed = 0
	local offsets = {
		Vector3.new(9.2, 0.7, 3.2),
		Vector3.new(-9.2, 0.7, 4.1),
		Vector3.new(8.4, 0.55, 6.5),
		Vector3.new(-8.6, 1.15, 6.2),
	}
	for _, spec in TownLook.SHOPS do
		local model = findNamed(town, spec.id)
		local cf = if model ~= nil then pivotOf(model) else nil
		if cf == nil then
			continue
		end
		local gave = 0
		for slot, offset in offsets do
			if gave >= 2 then
				break
			end
			local world = cf * offset
			if pointClear(keep, world.X, world.Y, world.Z, 1.3, true, false) then
				local yaw = math.atan2(world.X, world.Z)
				if slot % 2 == 0 then
					makePart(parent, {
						name = "Barrel",
						size = Vector3.new(1.15, 0.85, 0.85),
						cf = CFrame.new(world) * CFrame.Angles(0, yaw, math.rad(90)),
						material = WOOD,
						color = "Bark",
						decor = false,
						shadow = true,
						shape = Enum.PartType.Cylinder,
					})
					if detail then
						makePart(parent, {
							name = "BarrelHoop",
							size = Vector3.new(1.2, 0.9, 0.9),
							cf = CFrame.new(world) * CFrame.Angles(0, yaw, math.rad(90)),
							material = METAL,
							color = "Gold",
							decor = true,
							shadow = false,
							shape = Enum.PartType.Cylinder,
						})
					end
				else
					makePart(parent, {
						name = "Crate",
						size = Vector3.new(1.35, 1.05, 1.25),
						cf = CFrame.new(world) * CFrame.Angles(0, yaw + 0.4, 0),
						material = WOOD,
						color = "ShipWood",
						decor = false,
						shadow = true,
					})
				end
				gave += 1
				placed += 1
			end
		end
	end
	return placed
end

local function placeCrystals(parent: Instance, keep: any, detail: boolean): number
	local cap = if detail then CRYSTAL_CAP else CRYSTAL_CAP_LOW
	local placed = 0
	local rings = if detail then 4 else 2
	for ring = 1, rings do
		local count = 12 + ring * 2
		local radius = 12.5 + ring * 4.5
		for index = 1, count do
			if placed >= cap then
				return placed
			end
			local theta = (index - 0.5) * (2 * math.pi / count) + ring * 0.2
			local wobble = ((index * 5 + ring) % 5 - 2) * 0.55
			local x = (radius + wobble) * math.sin(theta)
			local z = (radius + wobble) * math.cos(theta)
			local y = Town.FLOOR_Y + 0.45
			if pointClear(keep, x, y, z, 0.8, true, true) then
				local token = CRYSTAL_COLORS[(placed % #CRYSTAL_COLORS) + 1]
				local shard = makePart(parent, {
					className = "WedgePart",
					name = "CrystalShard",
					size = Vector3.new(0.45, 0.95, 0.38),
					cf = CFrame.new(x, y, z) * CFrame.Angles(0.4, theta, 0.3),
					material = GLASS,
					color = token,
					decor = true,
					shadow = false,
				})
				shard.Transparency = 0.2
				makePart(parent, {
					name = "Crystal",
					size = Vector3.new(0.32, 0.55, 0.32),
					cf = CFrame.new(x, y + 0.15, z),
					material = NEON,
					color = token,
					decor = true,
					shadow = false,
					shape = Enum.PartType.Ball,
					neonRole = "rune",
				})
				placed += 1
			end
		end
	end
	return placed
end

local function placeRunes(parent: Instance, keep: any, detail: boolean): number
	local cap = if detail then RUNE_CAP else 8
	local placed = 0
	local flank = Town.ROAD_WIDTH * 0.5 + 1.8
	for road = 1, Plots.COUNT do
		local theta = math.rad(TownLayout.roadAngle(road))
		local rx = math.sin(theta)
		local rz = math.cos(theta)
		local px = rz
		local pz = -rx
		for _, radius in { 24, 36, 48 } do
			if placed >= cap then
				return placed
			end
			for side = -1, 1, 2 do
				if placed >= cap then
					break
				end
				local x = rx * radius + px * side * flank
				local z = rz * radius + pz * side * flank
				local y = Town.FLOOR_Y + 0.08
				if pointClear(keep, x, y, z, 1.2, true, true) then
					local token = if placed % 3 == 0 then "FlameGreen" else "Spirit"
					makePart(parent, {
						name = "PathRune",
						size = Vector3.new(1.15, 0.06, 0.42),
						cf = CFrame.new(x, y, z) * CFrame.Angles(0, theta, 0),
						material = NEON,
						color = token,
						decor = true,
						shadow = false,
						neonRole = "rune",
					})
					if detail then
						makePart(parent, {
							name = "PathRune",
							size = Vector3.new(0.42, 0.06, 0.85),
							cf = CFrame.new(x, y + 0.02, z) * CFrame.Angles(0, theta + 0.8, 0),
							material = NEON,
							color = token,
							decor = true,
							shadow = false,
							neonRole = "rune",
						})
					end
					placed += 1
				end
			end
		end
	end
	return placed
end

local function placeBraziers(parent: Instance, keep: any, detail: boolean, budget: any): number
	local placed = 0
	local function spotClear(x: number, z: number): boolean
		local y = Town.FLOOR_Y + 0.9
		if not pointClear(keep, x, y, z, 1.6, true, true) then
			return false
		end
		for step = 0, 3 do
			local turn = step * 1.57
			local rimX = x + math.cos(turn) * 0.85
			local rimZ = z + math.sin(turn) * 0.85
			if not pointClear(keep, rimX, y, rimZ, 0.45, true, true) then
				return false
			end
		end
		return true
	end
	local function build(x: number, z: number, token: string, seed: number)
		local yaw = math.atan2(x, z)
		local bowl = makePart(parent, {
			name = "PlazaBrazier",
			size = Vector3.new(0.55, 1.7, 1.7),
			cf = upright(Vector3.new(x, Town.FLOOR_Y + 0.55, z)),
			material = STONE,
			color = "Stone",
			decor = false,
			shadow = true,
			shape = Enum.PartType.Cylinder,
		})
		bowl:SetAttribute("BrazierColor", token)
		for leg = 0, 2 do
			local turn = yaw + leg * 2.094
			makePart(parent, {
				name = "BrazierLeg",
				size = Vector3.new(0.7, 0.12, 0.12),
				cf = upright(Vector3.new(x + math.cos(turn) * 0.55, Town.FLOOR_Y + 0.35, z + math.sin(turn) * 0.55)),
				material = METAL,
				color = "Void",
				decor = true,
				shadow = true,
				shape = Enum.PartType.Cylinder,
			})
		end
		makePart(parent, {
			name = "BrazierRim",
			size = Vector3.new(0.1, 1.9, 1.9),
			cf = upright(Vector3.new(x, Town.FLOOR_Y + 0.85, z)),
			material = METAL,
			color = "Gold",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
		local flame = makePart(parent, {
			name = "BrazierFlame",
			size = Vector3.new(0.55, 0.9, 0.55),
			cf = CFrame.new(x, Town.FLOOR_Y + 1.45, z),
			material = NEON,
			color = token,
			decor = true,
			shadow = false,
			shape = Enum.PartType.Ball,
			neonRole = "flame",
		})
		flame.Transparency = 0.12
		if detail then
			table.insert(budget.flicker, {
				wick = flame,
				seed = seed,
			})
			addFlame(flame, token)
			addGlow(flame, TownLook.PLAZA_LIGHT.brazier.range, TownLook.PLAZA_LIGHT.brazier.brightness, token, budget)
		end
	end
	for index = 1, BRAZIER_COUNT do
		if placed >= BRAZIER_COUNT then
			break
		end
		-- Halfway between a road and a shop spoke, so the bowl is off both.
		local base = 11.25 + (index - 1) * 45
		local built = false
		for _, shift in { 0, -4, 4 } do
			if built then
				break
			end
			local theta = math.rad(base + shift)
			for _, radius in { 16.5, 54, 61 } do
				local x = radius * math.sin(theta)
				local z = radius * math.cos(theta)
				if spotClear(x, z) then
					local token = BRAZIER_COLORS[(placed % #BRAZIER_COLORS) + 1]
					build(x, z, token, index + placed)
					placed += 1
					built = true
					break
				end
			end
		end
	end
	return placed
end

local function placeLife(parent: Instance, keep: any, detail: boolean)
	if not detail then
		return
	end
	local vfx = TownLook.PLAZA_VFX
	local fogSpots = 0
	for index = 1, 10 do
		if fogSpots >= 2 then
			break
		end
		local theta = index * 0.9 + 1.7
		local radius = 18 + (index % 3) * 2
		local x = radius * math.sin(theta)
		local z = radius * math.cos(theta)
		local y = Town.FLOOR_Y + 0.45
		if pointClear(keep, x, y, z, 4.2, true, true) then
			local host = makePart(parent, {
				name = "GroundFog",
				size = Vector3.new(6.2, 0.3, 6.2),
				cf = CFrame.new(x, y, z),
				material = GLASS,
				color = "BoneDim",
				decor = true,
				shadow = false,
			})
			host.Transparency = 1
			addLife(host, "GroundFog", vfx.fog, "BoneDim", vfx.lift)
			fogSpots += 1
		end
	end
	local flies = 0
	for _, inst in parent:GetDescendants() do
		if flies >= 2 then
			break
		end
		if inst.Name == "DeadTree" and inst.CFrame ~= nil and flies < 2 then
			local at = inst.CFrame.Position
			if at.Y > Town.FLOOR_Y + 4 then
				addLife(inst, "Firefly", vfx.firefly, "FlameGreen", 0.35)
				flies += 1
			end
		end
	end
	local motes = 0
	for _, inst in parent:GetDescendants() do
		if motes >= 2 then
			break
		end
		if inst.Name == "LanternWick" and inst.CFrame ~= nil then
			local at = inst.CFrame.Position
			local radius = math.sqrt(at.X * at.X + at.Z * at.Z)
			if radius > 30 and motes < 2 then
				addLife(inst, "MoteDrift", vfx.mote, "Gold", 0.25)
				motes += 1
			end
		end
	end
end

function PlazaDressing.replace(townFolder: Instance, refs: any): any
	local existing = townFolder:FindFirstChild("PlazaDressing")
	if existing ~= nil and existing:GetAttribute("TownKit") == "PlazaDressing" then
		return nil
	end
	-- Shop fixtures are a single model. The plaza kit dresses the built town.
	if townFolder:FindFirstChild("Lamps") == nil and townFolder:FindFirstChild("Hollowmere") == nil then
		return nil
	end
	local level = Kit.resolveQuality(refs)
	local detail = Kit.detailEnabled(level)
	local beforeParts = Kit.countParts(townFolder)
	local beforeLights = Kit.countLights(townFolder)
	local beforeEmitters = Kit.countEmitters(townFolder)

	local folder = Instance.new("Folder")
	folder.Name = "PlazaDressing"
	folder.Parent = townFolder

	local keep = collect(townFolder)
	local budget = {
		lights = 0,
		flicker = {},
	}
	local sways = {}
	local dressed = upgradeLamps(townFolder, folder, keep, detail, budget)
	local newLamps = placeNewLamps(folder, keep, detail, budget)
	placeTrees(folder, keep, detail, sways)
	placeFences(folder, keep, detail)
	placeBanners(folder, keep, detail, sways)
	placeBunting(folder, keep, detail, sways)
	placeCrates(folder, townFolder, keep, detail)
	local crystals = placeCrystals(folder, keep, detail)
	local runes = placeRunes(folder, keep, detail)
	local braziers = placeBraziers(folder, keep, detail, budget)
	placeLife(folder, keep, detail)
	local flicker = budget.flicker
	local motion = sways
	animate(folder, function(dt: number, t: number)
		drive(flicker, motion, dt, t)
	end)

	local afterParts = Kit.countParts(townFolder)
	local afterLights = Kit.countLights(townFolder)
	local afterEmitters = Kit.countEmitters(townFolder)
	folder:SetAttribute("TownKit", "PlazaDressing")
	folder:SetAttribute("KitQuality", level)
	folder:SetAttribute("KitDetail", detail)
	folder:SetAttribute("KitBeforeParts", beforeParts)
	folder:SetAttribute("KitAfterParts", afterParts)
	folder:SetAttribute("KitBeforeLights", beforeLights)
	folder:SetAttribute("KitAfterLights", afterLights)
	folder:SetAttribute("KitBeforeEmitters", beforeEmitters)
	folder:SetAttribute("KitAfterEmitters", afterEmitters)
	folder:SetAttribute("PlazaLamps", dressed + newLamps)
	folder:SetAttribute("PlazaNewLamps", newLamps)
	folder:SetAttribute("PlazaCrystals", crystals)
	folder:SetAttribute("PlazaRunes", runes)
	folder:SetAttribute("PlazaBraziers", braziers)
	folder:SetAttribute("PlazaGlow", budget.lights)
	return {
		id = "PlazaDressing",
		quality = level,
		detail = detail,
		beforeParts = beforeParts,
		afterParts = afterParts,
		beforeLights = beforeLights,
		afterLights = afterLights,
		beforeEmitters = beforeEmitters,
		afterEmitters = afterEmitters,
		lamps = dressed + newLamps,
		newLamps = newLamps,
		crystals = crystals,
		runes = runes,
		braziers = braziers,
		glow = budget.lights,
	}
end

PlazaDressing.name = "PlazaDressing"
PlazaDressing.order = 80

return PlazaDressing
