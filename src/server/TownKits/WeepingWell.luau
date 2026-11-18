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
local GLASS = UITheme.materials.glass
local NEON = UITheme.materials.neon

local BLOCKOUT = {
	Stone = true,
	WellWater = true,
	RuneMark = true,
}

local RING_COUNT = 8
local WATER_THICKNESS = 0.4
local WATER_CENTER_Y = 0.2
local DRIP_CLEARANCE = 0.22
local RUNE_Y = 0.55
local WEEP_Y = -0.72

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

local function addSpot(parent: Instance, name: string, range: number, brightness: number)
	local light = Instance.new("SpotLight")
	light.Name = name
	light.Color = UITheme.color("Spirit")
	light.Range = range
	light.Brightness = brightness
	light.Angle = 62
	light.Face = Enum.NormalId.Top
	light.Shadows = false
	light.Parent = parent
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
		local even = index % 2 == 0
		local lift = if even then 0.16 else -0.1
		local radial = if even then 0.1 else -0.05
		local radius = metrics.midR + radial
		local at = Vector3.new(math.sin(theta) * radius, lift, math.cos(theta) * radius)
		local yaw = if even then 0.07 else -0.05
		place(parent, pivot, {
			name = "Voussoir",
			size = Vector3.new(metrics.width * 0.86, metrics.height * 0.92, metrics.thickness * 0.94),
			cf = CFrame.lookAt(at, Vector3.new(0, lift, 0)) * CFrame.Angles(0, yaw, 0),
			material = "Slate",
			color = if even then "Stone" else "PlazaRoad",
		})
	end
	for index = 0, RING_COUNT - 1 do
		local theta = index * (2 * math.pi / RING_COUNT)
		local radius = metrics.face + 0.22
		local at = Vector3.new(math.sin(theta) * radius, metrics.height * 0.42, math.cos(theta) * radius)
		place(parent, pivot, {
			name = "Lip",
			size = Vector3.new(metrics.width * 0.72, 0.28, 0.55),
			cf = CFrame.lookAt(at, Vector3.new(0, at.Y, 0)),
			material = "Cobblestone",
			color = "PlazaCobble",
			decor = true,
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

local function buildOrnament(parent: Instance, pivot: any, metrics: any)
	local runeR = metrics.face + 0.12
	local weepR = metrics.face + 0.08
	for index = 0, RING_COUNT - 1 do
		local theta = index * (2 * math.pi / RING_COUNT)
		local outward = Vector3.new(math.sin(theta), 0, math.cos(theta))
		local runeAt = outward * runeR + Vector3.new(0, RUNE_Y, 0)
		local rune = place(parent, pivot, {
			name = "Rune",
			size = Vector3.new(0.1, 1.25, 0.08),
			cf = CFrame.lookAt(runeAt, Vector3.new(0, RUNE_Y, 0)),
			material = NEON,
			color = "Spirit",
			decor = true,
			shadow = false,
			neonRole = "rune",
		})
		local strokes = {
			CFrame.new(0.18, 0.35, -0.02) * CFrame.Angles(0, 0, 0.8),
			CFrame.new(-0.16, -0.2, -0.02) * CFrame.Angles(0, 0, -0.55),
			CFrame.new(0, -0.48, -0.02) * CFrame.Angles(0, 0, math.rad(90)),
		}
		for _, localCf in strokes do
			place(parent, pivot, {
				name = "RuneGlyph",
				size = Vector3.new(0.08, 0.55, 0.06),
				cf = CFrame.lookAt(runeAt, Vector3.new(0, RUNE_Y, 0)) * localCf,
				material = NEON,
				color = "Spirit",
				decor = true,
				shadow = false,
				neonRole = "rune",
			})
		end
		addSpot(rune, "RuneGlow", 12, 1.6)
		if index % 2 == 0 then
			local weepAt = outward * weepR + Vector3.new(0, WEEP_Y, 0)
			local tip = weepAt + outward * 0.9 + Vector3.new(0, 2.7, 0)
			place(parent, pivot, {
				className = "WedgePart",
				name = "Weep",
				size = Vector3.new(0.26, 2.8, 0.58),
				cf = CFrame.lookAt(weepAt + Vector3.new(0, 1.2, 0), tip),
				material = NEON,
				color = "Spirit",
				decor = true,
				shadow = false,
				neonRole = "rune",
			})
		end
	end
	local waterTop = WATER_CENTER_Y + WATER_THICKNESS / 2
	place(parent, pivot, {
		name = "Glint",
		size = Vector3.new(0.08, 2.4, 2.4),
		cf = CFrame.new(0, waterTop + 0.06, 0) * CFrame.Angles(0, 0, math.rad(90)),
		material = NEON,
		color = "Spirit",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
		neonRole = "rune",
	})
end

local function carveRunestones(model: Instance)
	local index = 0
	for _, inst in model:GetDescendants() do
		if inst.Name == "Runestone" and inst.ClassName == "Part" and inst:GetAttribute(Kit.PART_ATTRIBUTE) ~= true then
			index += 1
			local lean = if index % 2 == 0 then 0.2 else -0.16
			inst.Size = Vector3.new(0.72, 3.8, 0.5)
			inst.CFrame = inst.CFrame * CFrame.Angles(lean, 0, lean * 0.4)
			inst.Material = Enum.Material.Slate
			inst.Color = UITheme.color("Stone")
			local strokes = {
				{ Vector3.new(0.08, 1.5, 0.06), CFrame.new(0, 0.45, -0.3) },
				{ Vector3.new(0.08, 0.7, 0.06), CFrame.new(0.16, 0.9, -0.3) * CFrame.Angles(0, 0, 0.75) },
				{ Vector3.new(0.08, 0.62, 0.06), CFrame.new(-0.14, -0.05, -0.3) * CFrame.Angles(0, 0, -0.6) },
				{ Vector3.new(0.28, 0.08, 0.06), CFrame.new(0, -0.55, -0.3) },
			}
			for _, stroke in strokes do
				local glyph = Instance.new("Part")
				glyph.Name = "RuneGlyph"
				glyph.Anchored = true
				glyph.CanCollide = false
				glyph.CanTouch = false
				glyph.CanQuery = false
				glyph.CastShadow = false
				glyph.Material = Enum.Material.Neon
				glyph.Color = UITheme.color("Spirit")
				glyph.Size = stroke[1]
				glyph.CFrame = inst.CFrame * stroke[2]
				glyph.TopSurface = Enum.SurfaceType.Smooth
				glyph.BottomSurface = Enum.SurfaceType.Smooth
				glyph:SetAttribute("NeonRole", "rune")
				glyph:SetAttribute(Kit.PART_ATTRIBUTE, true)
				glyph:SetAttribute(Kit.DECOR_ATTRIBUTE, true)
				glyph.Parent = model
			end
		end
	end
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

local bobs: { any } = {}

local function clearMotion()
	table.clear(bobs)
end

local function playMotion(model: Instance)
	local snapshot = table.clone(bobs)
	Kit.animate(model, function(_dt, elapsed)
		for _, wisp in snapshot do
			local bob = math.sin(elapsed * wisp.speed + wisp.phase) * wisp.amp
			wisp.part.CFrame = wisp.base * CFrame.new(0, bob, 0)
		end
	end)
end

local function trackBob(part: any, phase: number, amp: number)
	table.insert(bobs, {
		part = part,
		base = part.CFrame,
		phase = phase,
		amp = amp,
		speed = 1.35,
	})
end

local function buildFinish(parent: Instance, pivot: any, metrics: any)
	for course = 0, 7 do
		for index = 0, 27 do
			local theta = (index + course * 0.5) * (2 * math.pi / 28)
			local radius = metrics.midR + 0.06 + (course % 2) * 0.14
			local y = -metrics.height / 2 + 0.22 + course * 0.38
			local at = Vector3.new(math.sin(theta) * radius, y, math.cos(theta) * radius)
			place(parent, pivot, {
				name = "Brick",
				size = Vector3.new(0.62, 0.28, 0.74),
				cf = CFrame.lookAt(at, Vector3.new(0, y, 0)),
				material = "Slate",
				color = if course % 2 == 0 then "Stone" else "PlazaRoad",
				decor = true,
				shadow = true,
			})
		end
	end
	local waterTop = WATER_CENTER_Y + WATER_THICKNESS / 2
	for index = 0, 7 do
		local t = index / 7
		local diameter = 2.6 - t * 2.25
		local y = waterTop + 0.45 + index * 0.72
		place(parent, pivot, {
			className = "WedgePart",
			name = "Cone",
			size = Vector3.new(diameter, 1.15, diameter),
			cf = CFrame.new(0, y, 0),
			material = NEON,
			color = "Spirit",
			decor = true,
			shadow = false,
			neonRole = "flame",
		})
	end
	for index = 0, 15 do
		local theta = index * (2 * math.pi / 16)
		local radius = Town.WELL_WATER_DIAMETER * 0.28
		local at = Vector3.new(math.sin(theta) * radius, waterTop + 1.15, math.cos(theta) * radius)
		local wisp = place(parent, pivot, {
			name = "Wisp",
			size = Vector3.new(0.28, 0.28, 0.28),
			cf = CFrame.new(at),
			material = NEON,
			color = "Spirit",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Ball,
			neonRole = "rune",
		})
		trackBob(wisp, index * 0.45, 0.42)
	end
	for _, inst in parent:GetDescendants() do
		if inst.Name == "Weep" then
			trackBob(inst, inst.CFrame.Position.X, 0.22)
		end
	end
end

local function dressSpirits(model: Instance)
	local drip = findNamed(model, "WellDrip", "Part")
	if drip == nil then
		return
	end
	for _, inst in drip:GetChildren() do
		if inst.ClassName ~= "ParticleEmitter" then
			continue
		end
		if inst.Name == "SpiritMist" then
			Kit.tuneEmitter(inst, {
				rate = 44,
				lift = 8,
				speed = { 3.4, 6.2 },
				spread = 6,
				spin = 28,
				size = 1.65,
				sizeOut = 0.28,
				transparency = 0.16,
				color = "Spirit",
				direction = Enum.NormalId.Top,
			})
			inst:SetAttribute("TownFlame", "extra")
		elseif inst.Name == "RuneDrift" then
			Kit.tuneEmitter(inst, {
				rate = 8,
				lift = 6.5,
				speed = { 2.2, 4.4 },
				spread = 18,
				spin = 80,
				size = 0.22,
				sizeOut = 0.05,
				transparency = 0.2,
				color = "Spirit",
				direction = Enum.NormalId.Top,
			})
			inst:SetAttribute("TownFlame", "extra")
		end
	end
	local flare = Instance.new("ParticleEmitter")
	flare.Name = "WellFlare"
	flare.Enabled = false
	flare.Rate = 12
	if typeof(NumberRange) == "table" then
		flare.Lifetime = NumberRange.new(1.1, 1.1)
	else
		flare.Lifetime = { Min = 1.1, Max = 1.1 }
	end
	flare.Parent = drip
	Kit.tuneEmitter(flare, {
		rate = 12,
		lift = 9,
		speed = { 4, 7 },
		spread = 12,
		spin = 40,
		size = 1.4,
		sizeOut = 0.2,
		transparency = 0.1,
		color = "Spirit",
		direction = Enum.NormalId.Top,
	})
	flare.Enabled = false
	flare:SetAttribute("TownEffect", "WellFlare")
	flare:SetAttribute("TownFlame", "extra")
	flare:SetAttribute("RareCatchFlare", true)
end

local function dressColumn(model: Instance)
	local light = findNamed(model, "WellLight", "PointLight")
	if light ~= nil then
		light.Range = 22
		light.Brightness = 1.8
		light.Color = UITheme.color("Spirit")
		light.Shadows = false
	end
	for _, inst in model:GetDescendants() do
		if inst.Name == "RuneMark" then
			inst.Color = UITheme.color("Spirit")
			inst.Material = Enum.Material.Neon
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
	clearMotion()
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

	local function phase(stepName: string, fn: () -> ())
		Kit.step("WeepingWell", stepName, fn)
	end
	local metrics = ringMetrics()
	phase("ring", function()
		buildRing(folder, pivot, metrics)
	end)
	phase("basin", function()
		buildBasin(folder, pivot)
	end)
	phase("runestones", function()
		carveRunestones(model)
	end)
	if detail then
		phase("ornament", function()
			buildOrnament(folder, pivot, metrics)
			buildFinish(folder, pivot, metrics)
		end)
	end
	phase("drip", function()
		seatDrip(model, pivot)
	end)
	if detail then
		phase("spirits", function()
			dressSpirits(model)
			playMotion(model)
		end)
	else
		stripEmitters(model)
	end
	phase("column", function()
		dressColumn(model)
	end)
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
