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

local Longship = {}

local MODEL_NAME = "HowlingHorn"
local WOOD = UITheme.materials.wood
local BONE = UITheme.materials.candle
local STONE = UITheme.materials.altar
local METAL = UITheme.materials.iron
local NEON = UITheme.materials.neon

local BLOCKOUT = {
	Hull = true,
	Keel = true,
	Rib = true,
	Deck = true,
	SerpentNeck = true,
	SerpentHead = true,
	SerpentJaw = true,
	Eye = true,
}

local VAULT = { z0 = -8, z1 = 12, beam0 = 6.4, beam1 = 6.4, keel0 = 15.0, keel1 = 15.0, gun0 = 3.6, gun1 = 3.6 }
local BOW_A = { z0 = -8, z1 = -11.2, beam0 = 6.4, beam1 = 3.6, keel0 = 15.0, keel1 = 15.8, gun0 = 3.6, gun1 = 6.2 }
local BOW_B = { z0 = -11.2, z1 = -14.2, beam0 = 3.6, beam1 = 1.6, keel0 = 15.8, keel1 = 16.4, gun0 = 6.2, gun1 = 8.4 }
local STERN = { z0 = 12, z1 = 16.4, beam0 = 6.4, beam1 = 3.2, keel0 = 15.0, keel1 = 13.4, gun0 = 3.6, gun1 = 6.4 }
local SHELL_COURSES = {
	{ t0 = 0, t1 = 0.5 },
	{ t0 = 0.5, t1 = 1 },
}
local SEAM_T = { 0.22, 0.42, 0.62, 0.82 }

local function distance(a: any, b: any): number
	local dx = a.X - b.X
	local dy = a.Y - b.Y
	local dz = a.Z - b.Z
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function courseNormal(t: number, side: number): (number, number, number)
	local arc = t * (math.pi * 0.5)
	return side * math.cos(arc), math.sin(arc), 0
end

local function pointOn(
	region: any,
	z: number,
	t: number,
	side: number,
	nx: number,
	ny: number,
	nz: number,
	dist: number
): any
	local span = region.z1 - region.z0
	local alpha = if math.abs(span) < 1e-4 then 0 else (z - region.z0) / span
	local beam = region.beam0 + (region.beam1 - region.beam0) * alpha
	local keel = region.keel0 + (region.keel1 - region.keel0) * alpha
	local gun = region.gun0 + (region.gun1 - region.gun0) * alpha
	local arc = t * (math.pi * 0.5)
	return Vector3.new(
		side * beam * math.cos(arc) + nx * dist,
		gun + (keel - gun) * math.sin(arc) + ny * dist,
		z + nz * dist
	)
end

local function courseWidth(region: any, t0: number, t1: number, side: number): number
	local function widthAt(z: number): number
		local p0 = pointOn(region, z, t0, side, 0, 0, 0, 0)
		local p1 = pointOn(region, z, t1, side, 0, 0, 0, 0)
		return distance(p0, p1)
	end
	return math.max((widthAt(region.z0) + widthAt(region.z1)) * 0.5 * 1.04, 0.2)
end

local function makeSpan(
	name: string,
	a: any,
	b: any,
	width: number,
	thickness: number,
	material: string,
	color: string,
	decor: boolean,
	shadow: boolean,
	nx: number,
	ny: number,
	nz: number,
	pivot: any
): any
	local length = math.max(distance(a, b), 0.05)
	local mid = Vector3.new((a.X + b.X) * 0.5, (a.Y + b.Y) * 0.5, (a.Z + b.Z) * 0.5)
	local cf = CFrame.lookAt(mid, b, Vector3.new(nx, ny, nz))
	if pivot ~= nil then
		cf = pivot * cf
	end
	return Kit.spawn({
		name = name,
		size = Vector3.new(width, thickness, length),
		cf = cf,
		material = material,
		color = color,
		decor = decor,
		shadow = shadow,
	})
end

local function place(parent: Instance, pivot: any, spec: any): any
	spec.cf = pivot * spec.cf
	spec.parent = parent
	return Kit.spawn(spec)
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

local function addCourses(
	parent: Instance?,
	pivot: any,
	region: any,
	courses: { any },
	name: string,
	thickness: number,
	material: string,
	color: string,
	decor: boolean,
	shadow: boolean,
	offset: number
): { any }
	local made = {}
	for _, side in { -1, 1 } do
		for _, course in courses do
			local tMid = ((course.t0 :: number) + (course.t1 :: number)) * 0.5
			local nx, ny, nz = courseNormal(tMid, side)
			local a = pointOn(region, region.z0, tMid, side, nx, ny, nz, offset)
			local b = pointOn(region, region.z1, tMid, side, nx, ny, nz, offset)
			local width = course.width or courseWidth(region, course.t0, course.t1, side)
			local piece = makeSpan(name, a, b, width, thickness, material, color, decor, shadow, nx, ny, nz, pivot)
			if parent ~= nil then
				piece.Parent = parent
			end
			table.insert(made, piece)
		end
	end
	return made
end

local function addRibs(parent: Instance, pivot: any, region: any, stations: { number })
	for _, z in stations do
		for _, side in { -1, 1 } do
			local tMid = 0.5
			local nx, ny, nz = courseNormal(tMid, side)
			local a = pointOn(region, z, 0.08, side, nx, ny, nz, 0.42)
			local b = pointOn(region, z, 0.92, side, nx, ny, nz, 0.42)
			local piece = makeSpan("HullRib", a, b, 0.55, 0.4, WOOD, "Bark", true, true, nx, ny, nz, pivot)
			piece.Parent = parent
		end
	end
end

local function cylinderBetween(
	parent: Instance,
	pivot: any,
	name: string,
	a: Vector3,
	b: Vector3,
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

local function buildHall(parent: Instance, pivot: any)
	place(parent, pivot, {
		name = "Foundation",
		size = Vector3.new(14.2, 0.4, 34),
		cf = CFrame.new(0, 0.2, -0.5),
		material = STONE,
		color = "Stone",
	})
	place(parent, pivot, {
		name = "Deck",
		size = Vector3.new(11.4, 0.36, 24),
		cf = CFrame.new(0, 0.78, 0),
		material = WOOD,
		color = "ShipWood",
	})
	place(parent, pivot, {
		name = "Counter",
		size = Vector3.new(7.4, 1.2, 2.3),
		cf = CFrame.new(0, 1.7, -3.2),
		material = WOOD,
		color = "ShipWood",
	})
	local stepSize = Vector3.new(7.2, 0.26, 1.45)
	local steps = {
		{ z = -14.4, y = 0.28 },
		{ z = -13.0, y = 0.5 },
		{ z = -11.6, y = 0.72 },
	}
	for _, step in steps do
		place(parent, pivot, {
			name = "Step",
			size = stepSize,
			cf = CFrame.new(0, step.y, step.z),
			material = STONE,
			color = "Stone",
		})
	end
	local sill = place(parent, pivot, {
		name = "DoorAnchor",
		size = Vector3.new(4.8, 0.3, 1.8),
		cf = CFrame.new(0, 0.86, -10.6),
		material = STONE,
		color = "Stone",
	})
	sill:SetAttribute("TownAnchor", "Door")
	for _, side in { -1, 1 } do
		place(parent, pivot, {
			name = "DoorPost",
			size = Vector3.new(0.7, 6.6, 0.7),
			cf = CFrame.new(side * 2.45, 3.7, -10.6),
			material = WOOD,
			color = "Bark",
		})
		for _, z in { -6, -1, 5, 10 } do
			place(parent, pivot, {
				name = "HallPost",
				size = Vector3.new(0.62, 3.5, 0.62),
				cf = CFrame.new(side * 6.15, 2.15, z),
				material = WOOD,
				color = "Bark",
			})
		end
		local y = VAULT.gun0 + 0.2
		local x = side * (VAULT.beam0 + 0.2)
		local length = VAULT.z1 - VAULT.z0
		local look = CFrame.lookAt(Vector3.new(x, y, 2), Vector3.new(x, y, 1)) * CFrame.Angles(0, math.rad(90), 0)
		place(parent, pivot, {
			name = "Gunwale",
			size = Vector3.new(length, 0.48, 0.48),
			cf = look,
			material = WOOD,
			color = "Bark",
			decor = true,
			shadow = true,
			shape = Enum.PartType.Cylinder,
		})
	end
	place(parent, pivot, {
		name = "DoorLintel",
		size = Vector3.new(5.6, 0.55, 0.75),
		cf = CFrame.new(0, 7.15, -10.6),
		material = WOOD,
		color = "Bark",
	})
	place(parent, pivot, {
		name = "SternPost",
		size = Vector3.new(0.8, 12.2, 0.8),
		cf = CFrame.new(0, 6.4, 16.5),
		material = WOOD,
		color = "Bark",
	})
	place(parent, pivot, {
		className = "WedgePart",
		name = "SternCurl",
		size = Vector3.new(2.4, 1.4, 0.7),
		cf = CFrame.new(0, 12.8, 16.8) * CFrame.Angles(math.rad(18), 0, 0),
		material = WOOD,
		color = "Bark",
	})
	cylinderBetween(
		parent,
		pivot,
		"Keel",
		Vector3.new(0, 15.55, -7),
		Vector3.new(0, 15.55, 13),
		1.2,
		WOOD,
		"Bark",
		false,
		true
	)
end

local function buildProw(parent: Instance, pivot: any, detail: boolean)
	cylinderBetween(
		parent,
		pivot,
		"ProwNeck",
		Vector3.new(0, 15.4, -12.6),
		Vector3.new(0, 17.0, -15.4),
		1.45,
		BONE,
		"Bone",
		true,
		true
	)
	cylinderBetween(
		parent,
		pivot,
		"ProwNeck",
		Vector3.new(0, 17.0, -15.4),
		Vector3.new(0, 18.8, -17.6),
		1.25,
		BONE,
		"Bone",
		true,
		true
	)
	place(parent, pivot, {
		className = "WedgePart",
		name = "ProwStem",
		size = Vector3.new(3.2, 1.1, 1.4),
		cf = CFrame.new(0, 16.2, -14.2) * CFrame.Angles(math.rad(-28), 0, 0),
		material = WOOD,
		color = "Bark",
		decor = true,
		shadow = true,
	})
	place(parent, pivot, {
		name = "ProwHead",
		size = Vector3.new(4.4, 3.4, 4.8),
		cf = CFrame.new(0, 19.4, -18.6),
		material = BONE,
		color = "Bone",
		decor = true,
		shadow = true,
		shape = Enum.PartType.Ball,
	})
	place(parent, pivot, {
		className = "WedgePart",
		name = "ProwJaw",
		size = Vector3.new(2.8, 0.7, 1.7),
		cf = CFrame.new(0, 17.6, -20.2) * CFrame.Angles(math.rad(-24), 0, 0),
		material = BONE,
		color = "Bone",
		decor = true,
		shadow = true,
	})
	place(parent, pivot, {
		name = "Maw",
		size = Vector3.new(1.5, 0.7, 1.15),
		cf = CFrame.new(0, 18.05, -19.6),
		material = BONE,
		color = "Void",
		decor = true,
		shadow = false,
	})
	for _, side in { -1, 1 } do
		place(parent, pivot, {
			className = "WedgePart",
			name = "ProwHorn",
			size = Vector3.new(0.42, 2.3, 0.42),
			cf = CFrame.new(side * 0.95, 21.3, -18.0) * CFrame.Angles(math.rad(-36), 0, math.rad(side * 26)),
			material = BONE,
			color = "Bone",
			decor = true,
			shadow = true,
		})
		place(parent, pivot, {
			name = "Eye",
			size = Vector3.new(0.42, 0.42, 0.42),
			cf = CFrame.new(side * 0.72, 19.7, -20.7),
			material = NEON,
			color = "FlameBlue",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Ball,
			neonRole = "eye",
		})
	end
	if not detail then
		return
	end
	for index = -2, 2 do
		place(parent, pivot, {
			className = "WedgePart",
			name = "Tooth",
			size = Vector3.new(0.22, 0.48, 0.2),
			cf = CFrame.new(index * 0.38, 17.15, -20.5) * CFrame.Angles(math.rad(12), 0, 0),
			material = BONE,
			color = "Bone",
			decor = true,
			shadow = false,
		})
	end
	for index = 1, 3 do
		place(parent, pivot, {
			className = "WedgePart",
			name = "Spine",
			size = Vector3.new(0.28, 0.7, 0.28),
			cf = CFrame.new(0, 16.4 + index * 0.85, -13.2 - index * 1.15) * CFrame.Angles(math.rad(-20), 0, 0),
			material = BONE,
			color = "Bone",
			decor = true,
			shadow = false,
		})
	end
	place(parent, pivot, {
		name = "ProwMark",
		size = Vector3.new(0.18, 0.85, 1.35),
		cf = CFrame.new(0, 16.5, -14.6),
		material = BONE,
		color = "Blood",
		decor = true,
		shadow = false,
	})
end

local function buildDetail(parent: Instance, pivot: any)
	local seamCourses = {}
	for _, t in SEAM_T do
		table.insert(seamCourses, { t0 = t, t1 = t, width = 0.32 })
	end
	for _, region in { VAULT, BOW_A, BOW_B, STERN } do
		addCourses(parent, pivot, region, seamCourses, "Strake", 0.16, WOOD, "Bark", true, false, 0.62)
	end
	addRibs(parent, pivot, VAULT, { -1, 5 })
	addRibs(parent, pivot, BOW_A, { -9.6 })
	for _, z in { -4, 1, 6, 11 } do
		for _, side in { -1, 1 } do
			local pos = Vector3.new(side * 7.15, 5.4, z)
			local look = CFrame.lookAt(pos, pos + Vector3.new(side, 0, 0)) * CFrame.Angles(0, math.rad(90), 0)
			place(parent, pivot, {
				name = "Shield",
				size = Vector3.new(0.32, 2.15, 2.15),
				cf = look,
				material = WOOD,
				color = "ShipWood",
				decor = true,
				shadow = true,
				shape = Enum.PartType.Cylinder,
			})
			local boss = pos + Vector3.new(side * 0.22, 0, 0)
			local bossLook = CFrame.lookAt(boss, boss + Vector3.new(side, 0, 0)) * CFrame.Angles(0, math.rad(90), 0)
			place(parent, pivot, {
				name = "ShieldBoss",
				size = Vector3.new(0.18, 0.7, 0.7),
				cf = bossLook,
				material = METAL,
				color = "Gold",
				decor = true,
				shadow = false,
				shape = Enum.PartType.Cylinder,
			})
		end
	end
	for _, z in { -2, 6 } do
		for _, side in { -1, 1 } do
			local nx, ny, nz = courseNormal(0.45, side)
			local at = pointOn(VAULT, z, 0.45, side, nx, ny, nz, 0.5)
			place(parent, pivot, {
				name = "Rune",
				size = Vector3.new(0.16, 1.25, 0.62),
				cf = CFrame.new(at) * CFrame.Angles(0, 0, math.rad(-side * 48)),
				material = NEON,
				color = "FlameBlue",
				decor = true,
				shadow = false,
				neonRole = "rune",
			})
		end
	end
	for _, spot in { Vector3.new(-3.3, 6.7, -9.5), Vector3.new(3.3, 6.7, -9.5), Vector3.new(0, 7.9, -9.7) } do
		place(parent, pivot, {
			name = "LanternHousing",
			size = Vector3.new(0.55, 1.15, 0.55),
			cf = CFrame.new(spot) * CFrame.Angles(0, 0, math.rad(90)),
			material = METAL,
			color = "Gold",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
	end
	place(parent, pivot, {
		name = "KeelInlay",
		size = Vector3.new(0.28, 0.16, 16),
		cf = CFrame.new(0, 16.32, 2),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
	})
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
	moveTo(sign, pivot * CFrame.new(0, 8.4, -19.2), signParts)

	local bowl = findNamed(model, "Bowl", "Part")
	local flameParts = {}
	for _, name in { "Bowl", "Flame", "FlameHost" } do
		local piece = findNamed(model, name, "Part")
		if piece ~= nil then
			table.insert(flameParts, piece)
		end
	end
	moveTo(bowl, pivot * CFrame.new(5.6, 1.05, -12.6), flameParts)

	local crow = findNamed(model, "CrowBody", "Part")
	local crowParts = {}
	if crow ~= nil then
		table.insert(crowParts, crow)
	end
	local wing = findNamed(model, "CrowWing", "Part")
	if wing ~= nil then
		table.insert(crowParts, wing)
	end
	moveTo(crow, pivot * CFrame.new(2.1, 16.35, 3.4), crowParts)
end

function Longship.replace(townFolder: Instance, refs: any): any
	local model = findNamed(townFolder, MODEL_NAME, "Model")
	if model == nil or model:GetAttribute("TownKit") == "Longship" then
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

	local root = model.PrimaryPart or findNamed(model, "Root", "Part")
	local pivot = if root ~= nil and root.CFrame ~= nil then root.CFrame else CFrame.new()
	local folder = Instance.new("Folder")
	folder.Name = "Longship"
	folder.Parent = model

	local shell = addCourses(nil, nil, VAULT, SHELL_COURSES, "Shell", 0.72, WOOD, "ShipWood", false, true, 0)
	Kit.tryUnion("HowlingHornVault", shell, pivot, folder)
	addCourses(folder, pivot, BOW_A, SHELL_COURSES, "BowStrake", 0.66, WOOD, "ShipWood", false, true, 0)
	addCourses(folder, pivot, BOW_B, SHELL_COURSES, "BowStrake", 0.66, WOOD, "ShipWood", false, true, 0)
	addCourses(folder, pivot, STERN, SHELL_COURSES, "SternStrake", 0.66, WOOD, "ShipWood", false, true, 0)
	addRibs(folder, pivot, VAULT, { -4, 2, 8 })
	buildHall(folder, pivot)
	buildProw(folder, pivot, detail)
	if detail then
		buildDetail(folder, pivot)
	end
	repositionKept(model, pivot)

	local door = findNamed(folder, "DoorAnchor", "Part")
	for _, prompt in prompts do
		prompt.Parent = if door ~= nil then door else model
	end

	local afterParts = Kit.countParts(model)
	local afterLights = Kit.countLights(model)
	local afterEmitters = Kit.countEmitters(model)
	model:SetAttribute("TownKit", "Longship")
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

return Longship
