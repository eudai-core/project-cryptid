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
local UITheme = import("../../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any

local PalePedlar = {}

local WOOD = UITheme.materials.wood
local METAL = UITheme.materials.iron
local GLASS = UITheme.materials.glass
local NEON = UITheme.materials.neon
local CLOTH = UITheme.materials.cloth
local BONE = UITheme.materials.candle

-- Town.PEDLAR_HOST is not a field. The live stall is the Districts model
-- whose id is the pedlar row in Town.DISTRICTS.
local BLOCKOUT = {
	Counter = true,
	Roof = true,
	PostLeft = true,
	PostRight = true,
	Banner = true,
}

local KEPT = {
	Root = true,
	Floor = true,
	Sign = true,
	SignTrim = true,
	PedlarLantern = true,
}

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

local function pedlarId(): string
	for _, spec in Town.DISTRICTS do
		if spec.kind == "pedlar" then
			return spec.id
		end
	end
	return "PalePedlar"
end

local function findHost(townFolder: Instance): any
	local id = pedlarId()
	local districts = townFolder:FindFirstChild("Districts")
	if districts ~= nil then
		local model = districts:FindFirstChild(id)
		if model ~= nil and model.ClassName == "Model" then
			return model
		end
	end
	return findNamed(townFolder, id, "Model")
end

local function place(parent: Instance, pivot: any, spec: any): any
	spec.cf = pivot * spec.cf
	spec.parent = parent
	return Kit.spawn(spec)
end

local function sway(index: number, amount: number): number
	return math.sin(index * 1.9) * amount
end

local function addPoint(parent: Instance, name: string, range: number, brightness: number, token: string)
	local light = Instance.new("PointLight")
	light.Name = name
	light.Color = UITheme.color(token)
	light.Range = range
	light.Brightness = brightness
	light.Shadows = false
	light.Parent = parent
end

local function guardsPrompt(inst: Instance, prompts: { any }): boolean
	for _, prompt in prompts do
		local cursor = prompt
		while cursor ~= nil do
			if cursor == inst then
				return true
			end
			cursor = cursor.Parent
		end
	end
	return false
end

local function dropBlockout(model: Instance, prompts: { any })
	local doomed = {}
	for _, inst in model:GetDescendants() do
		if
			BLOCKOUT[inst.Name] == true
			and KEPT[inst.Name] ~= true
			and inst:GetAttribute(Kit.PART_ATTRIBUTE) ~= true
		then
			local className = inst.ClassName
			if
				(className == "Part" or className == "WedgePart" or className == "MeshPart")
				and not guardsPrompt(inst, prompts)
			then
				table.insert(doomed, inst)
			end
		end
	end
	for _, inst in doomed do
		inst:Destroy()
	end
end

local function buildBed(parent: Instance, pivot: any, detail: boolean)
	for _, side in { -1, 1 } do
		local planks = if detail then 16 else 8
		for index = 1, planks do
			local z = -3.6 + (index - 0.5) * (7.2 / planks) + sway(index, 0.04)
			place(parent, pivot, {
				name = "BedPlank",
				size = Vector3.new(0.22, 1.15, 7.2 / planks - 0.06),
				cf = CFrame.new(side * 6.55, 0.95, z) * CFrame.Angles(0, sway(index, 0.03), math.rad(side * 1.5)),
				material = WOOD,
				color = if index % 2 == 0 then "Bark" else "ShipWood",
			})
		end
		place(parent, pivot, {
			name = "BedRail",
			size = Vector3.new(0.16, 0.12, 8.4),
			cf = CFrame.new(side * 6.7, 1.55, 0.1),
			material = METAL,
			color = "Gold",
			decor = true,
		})
	end
	place(parent, pivot, {
		name = "Tailgate",
		size = Vector3.new(12.6, 1.2, 0.18),
		cf = CFrame.new(0, 0.95, 4.55) * CFrame.Angles(math.rad(-2), 0, 0),
		material = WOOD,
		color = "Bark",
	})
	place(parent, pivot, {
		name = "Headboard",
		size = Vector3.new(12.4, 0.9, 0.16),
		cf = CFrame.new(0, 0.85, -4.35),
		material = WOOD,
		color = "ShipWood",
	})
end

local function buildWheels(parent: Instance, pivot: any)
	local seats = {
		Vector3.new(-6.3, 0.55, -3.1),
		Vector3.new(6.3, 0.55, -3.1),
		Vector3.new(-6.3, 0.55, 3.2),
		Vector3.new(6.3, 0.55, 3.2),
	}
	for _, at in seats do
		place(parent, pivot, {
			name = "Wheel",
			size = Vector3.new(0.28, 1.35, 1.35),
			cf = CFrame.new(at),
			material = WOOD,
			color = "Bark",
			shape = Enum.PartType.Cylinder,
		})
		place(parent, pivot, {
			name = "Hub",
			size = Vector3.new(0.36, 0.32, 0.32),
			cf = CFrame.new(at),
			material = METAL,
			color = "Gold",
			decor = true,
			shape = Enum.PartType.Cylinder,
		})
	end
end

local function buildCanopy(parent: Instance, pivot: any, detail: boolean)
	for _, side in { -1, 1 } do
		for _, z in { -4.1, 4.2 } do
			place(parent, pivot, {
				name = "CanopyPole",
				size = Vector3.new(0.16, 4.4, 0.16),
				cf = CFrame.new(side * 6.2, 3.3, z) * CFrame.Angles(0, 0, math.rad(side * 1.2)),
				material = WOOD,
				color = "Bark",
			})
		end
	end
	place(parent, pivot, {
		name = "CanopyRidge",
		size = Vector3.new(0.18, 0.18, 8.6),
		cf = CFrame.new(0, 5.55, 0.1),
		material = WOOD,
		color = "ShipWood",
	})
	place(parent, pivot, {
		className = "WedgePart",
		name = "Canopy",
		size = Vector3.new(6.4, 1.15, 8.8),
		cf = CFrame.new(-3.15, 5.15, 0.05) * CFrame.Angles(0, math.rad(-90), 0),
		material = CLOTH,
		color = "BoneDim",
	})
	place(parent, pivot, {
		className = "WedgePart",
		name = "Canopy",
		size = Vector3.new(6.4, 1.15, 8.8),
		cf = CFrame.new(3.15, 5.15, 0.05) * CFrame.Angles(0, math.rad(90), 0),
		material = CLOTH,
		color = "Ash",
	})
	local clothRows = if detail then 18 else 10
	local clothCols = if detail then 24 else 12
	for row = 1, clothRows do
		for col = 1, clothCols do
			local x = -5.8 + (col - 0.5) * (11.6 / clothCols)
			local z = -3.8 + (row - 0.5) * (7.6 / clothRows)
			local sag = 0.08 * math.sin(col * 0.7 + row)
			place(parent, pivot, {
				name = "CanopyScale",
				size = Vector3.new(11.6 / clothCols + 0.04, 0.05, 7.6 / clothRows + 0.03),
				cf = CFrame.new(x + sway(row + col, 0.03), 5.05 + sag + row * 0.012, z)
					* CFrame.Angles(sway(row, 0.04), sway(col, 0.05), sway(row + col, 0.03)),
				material = CLOTH,
				color = if (row + col) % 4 == 0 then "Bone" elseif (row + col) % 5 == 0 then "Ash" else "BoneDim",
				decor = true,
				shadow = false,
			})
		end
	end
	local strips = if detail then 22 else 8
	for index = 1, strips do
		local x = -5.6 + (index - 0.5) * (11.2 / strips)
		local hang = 0.7 + math.abs(sway(index, 0.55))
		place(parent, pivot, {
			name = "Tatter",
			size = Vector3.new(11.2 / strips - 0.08, hang, 0.06),
			cf = CFrame.new(x + sway(index, 0.05), 4.35 - hang / 2, -4.15)
				* CFrame.Angles(math.rad(8), 0, sway(index, 0.08)),
			material = CLOTH,
			color = if index % 3 == 0 then "Bone" else "BoneDim",
			decor = true,
		})
		if detail then
			place(parent, pivot, {
				name = "Tatter",
				size = Vector3.new(0.08, 0.45 + sway(index, 0.2), 0.35),
				cf = CFrame.new(x, 4.5, 4.35),
				material = CLOTH,
				color = "Ash",
				decor = true,
				shadow = false,
			})
		end
	end
	place(parent, pivot, {
		name = "CanopyHem",
		size = Vector3.new(12.2, 0.08, 0.08),
		cf = CFrame.new(0, 4.55, -4.2),
		material = CLOTH,
		color = "Blood",
		decor = true,
	})
end

local function buildCrates(parent: Instance, pivot: any, detail: boolean)
	local crates = if detail then 4 else 2
	for index = 1, crates do
		local x = -4.2 + index * 1.7
		local y = 0.85 + (index % 2) * 0.15
		local z = 1.4 + sway(index, 0.3)
		for board = 1, 4 do
			place(parent, pivot, {
				name = "Crate",
				size = Vector3.new(1.15, 0.12, 0.08),
				cf = CFrame.new(x, y + board * 0.22, z + 0.45) * CFrame.Angles(0, sway(board + index, 0.05), 0),
				material = WOOD,
				color = if board % 2 == 0 then "ShipWood" else "Bark",
				decor = true,
			})
			place(parent, pivot, {
				name = "Crate",
				size = Vector3.new(0.08, 0.9, 0.9),
				cf = CFrame.new(x + (if board % 2 == 0 then 0.5 else -0.5), y + 0.45, z),
				material = WOOD,
				color = "Bark",
				decor = true,
			})
		end
	end
	local jars = if detail then 6 else 3
	for index = 1, jars do
		local at = Vector3.new(3.6 + sway(index, 0.15), 0.72, -2.4 + index * 0.55)
		local jar = place(parent, pivot, {
			name = "Jar",
			size = Vector3.new(0.46, 0.28, 0.28),
			cf = CFrame.new(at) * CFrame.Angles(0, 0, math.rad(90)),
			material = GLASS,
			color = if index % 3 == 0 then "Rift" else "Bone",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
		jar.Transparency = 0.25
		place(parent, pivot, {
			name = "Cork",
			size = Vector3.new(0.14, 0.18, 0.18),
			cf = CFrame.new(at + Vector3.new(0, 0.28, 0)) * CFrame.Angles(0, 0, math.rad(90)),
			material = WOOD,
			color = "Bark",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Cylinder,
		})
	end
end

local function buildCages(parent: Instance, pivot: any)
	local seats = { -4.4, -1.5, 1.5, 4.4 }
	place(parent, pivot, {
		name = "CageRail",
		size = Vector3.new(10.4, 0.1, 0.1),
		cf = CFrame.new(0, 6.85, -3.7),
		material = METAL,
		color = "Soot",
		decor = true,
		shadow = false,
	})
	for index, x in seats do
		for bar = 0, 3 do
			local ox = (bar - 1.5) * 0.28
			place(parent, pivot, {
				name = "CageBar",
				size = Vector3.new(0.08, 1.35, 0.08),
				cf = CFrame.new(x + ox, 5.05, -3.55),
				material = METAL,
				color = "BoneDim",
				decor = true,
			})
		end
		place(parent, pivot, {
			name = "CageRing",
			size = Vector3.new(1.15, 0.08, 0.85),
			cf = CFrame.new(x, 4.4, -3.55),
			material = METAL,
			color = "Soot",
			decor = true,
		})
		place(parent, pivot, {
			name = "CageRing",
			size = Vector3.new(1.15, 0.08, 0.85),
			cf = CFrame.new(x, 5.7, -3.55),
			material = METAL,
			color = "Soot",
			decor = true,
		})
		place(parent, pivot, {
			name = "CageChain",
			size = Vector3.new(0.08, 1.15, 0.08),
			cf = CFrame.new(x, 6.35, -3.7),
			material = METAL,
			color = "Soot",
			decor = true,
			shadow = false,
		})
		place(parent, pivot, {
			name = "Curio",
			size = Vector3.new(0.28, 0.22, 0.18),
			cf = CFrame.new(x, 4.85, -3.5) * CFrame.Angles(0.2, sway(index, 0.4), 0.1),
			material = BONE,
			color = "Bone",
			decor = true,
			shadow = false,
		})
		local wick = place(parent, pivot, {
			name = "CageWick",
			size = Vector3.new(0.28, 0.28, 0.28),
			cf = CFrame.new(x, 5.05, -3.5),
			material = NEON,
			color = "Rift",
			decor = true,
			shadow = false,
			shape = Enum.PartType.Ball,
			neonRole = "flame",
		})
		wick.Transparency = 0.2
		addPoint(wick, "CageGlow", 8, 0.85, "Rift")
	end
end

local function buildMosaic(parent: Instance, pivot: any, detail: boolean)
	local rows = if detail then 14 else 8
	local cols = if detail then 16 else 8
	for row = 1, rows do
		for col = 1, cols do
			place(parent, pivot, {
				name = "BedStud",
				size = Vector3.new(0.28, 0.06, 0.22),
				cf = CFrame.new(-4.6 + col * 0.55, 0.48, -0.6 + row * 0.28)
					* CFrame.Angles(0, sway(row * 3 + col, 0.2), 0),
				material = WOOD,
				color = if (row + col) % 3 == 0 then "ShipWood" else "Bark",
				decor = true,
				shadow = false,
			})
		end
	end
	if not detail then
		return
	end
	for side = -1, 1, 2 do
		for index = 1, 28 do
			place(parent, pivot, {
				name = "Cladding",
				size = Vector3.new(0.08, 0.22, 0.42),
				cf = CFrame.new(side * 6.72, 0.55 + (index % 4) * 0.24, -4 + index * 0.28),
				material = WOOD,
				color = if index % 2 == 0 then "Bark" else "Soot",
				decor = true,
			})
		end
	end
end

local function buildStatue(parent: Instance, pivot: any)
	local statue = Instance.new("Model")
	statue.Name = "PedlarStatue"
	statue.Parent = parent
	place(statue, pivot, {
		name = "Cloak",
		size = Vector3.new(1.8, 3.6, 1.15),
		cf = CFrame.new(0.35, 3.35, 2.55),
		material = CLOTH,
		color = "Bone",
		decor = true,
		shadow = true,
	})
	place(statue, pivot, {
		name = "Shoulder",
		size = Vector3.new(2.05, 0.38, 1.2),
		cf = CFrame.new(0.35, 4.55, 2.5),
		material = CLOTH,
		color = "BoneDim",
		decor = true,
		shadow = true,
	})
	place(statue, pivot, {
		className = "WedgePart",
		name = "Hood",
		size = Vector3.new(1.2, 1.05, 1.15),
		cf = CFrame.new(0.35, 5.35, 2.45) * CFrame.Angles(0.15, math.rad(180), 0),
		material = CLOTH,
		color = "Bone",
		decor = true,
		shadow = true,
	})
	place(statue, pivot, {
		name = "HoodOpening",
		size = Vector3.new(0.62, 0.72, 0.18),
		cf = CFrame.new(0.35, 4.95, 1.95),
		material = CLOTH,
		color = "Void",
		decor = true,
		shadow = false,
	})
end

local function buildBook(parent: Instance, pivot: any)
	place(parent, pivot, {
		name = "OpenBook",
		size = Vector3.new(0.85, 0.08, 0.62),
		cf = CFrame.new(-1.15, 1.72, -2.15) * CFrame.Angles(0.08, 0.4, 0.15),
		material = BONE,
		color = "Bone",
		decor = true,
		shadow = false,
	})
	place(parent, pivot, {
		name = "OpenBook",
		size = Vector3.new(0.85, 0.08, 0.62),
		cf = CFrame.new(-0.25, 1.74, -2.05) * CFrame.Angles(0.05, -0.35, -0.12),
		material = BONE,
		color = "BoneDim",
		decor = true,
		shadow = false,
	})
	place(parent, pivot, {
		name = "BookSpine",
		size = Vector3.new(0.12, 0.1, 0.62),
		cf = CFrame.new(-0.7, 1.7, -2.1),
		material = WOOD,
		color = "Bark",
		decor = true,
		shadow = false,
	})
end

local function carveName(model: Instance, pivot: any)
	local sign = findNamed(model, "Sign", "Part")
	local trim = findNamed(model, "SignTrim", "Part")
	if sign ~= nil then
		sign.Size = Vector3.new(4.4, 0.72, 0.08)
		sign.CFrame = pivot * CFrame.new(0, 1.05, -4.55)
		sign.Material = Enum.Material.WoodPlanks
		sign.Color = UITheme.color("ShipWood")
		local gui = sign:FindFirstChild("SignGui")
		local label = if gui ~= nil then gui:FindFirstChild("SignText") else nil
		if label ~= nil then
			label.TextColor3 = UITheme.color("Gold")
			label.TextSize = 16
		end
	end
	if trim ~= nil then
		trim.Size = Vector3.new(4.6, 0.1, 0.05)
		trim.CFrame = pivot * CFrame.new(0, 0.62, -4.58)
		trim.Material = Enum.Material.WoodPlanks
		trim.Color = UITheme.color("Gold")
	end
end

local function buildTradeSign(model: any, parent: Instance, pivot: any)
	local hinge = pivot * CFrame.new(4.8, 4.6, -4.5)
	local board = place(parent, pivot, {
		name = "TradeSign",
		size = Vector3.new(1.4, 0.7, 0.08),
		cf = CFrame.new(4.8, 4.05, -4.55),
		material = WOOD,
		color = "Ash",
		decor = true,
	})
	local trim = place(parent, pivot, {
		name = "TradeTrim",
		size = Vector3.new(1.55, 0.84, 0.04),
		cf = CFrame.new(4.8, 4.05, -4.6),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
	})
	local rest = {
		[board] = hinge:Inverse() * board.CFrame,
		[trim] = hinge:Inverse() * trim.CFrame,
	}
	Kit.animate(model, function(_dt: number, t: number)
		local spun = hinge * CFrame.Angles(0, 0, math.sin(t * 0.7) * 0.06)
		for part, localCf in rest do
			if part.Parent ~= nil then
				part.CFrame = spun * localCf
			end
		end
	end)
end

local function buildHanger(parent: Instance, pivot: any)
	-- The existing PedlarLantern stays at its blockout pose. The hook stops short of it.
	place(parent, pivot, {
		name = "LanternHook",
		size = Vector3.new(0.7, 0.08, 0.08),
		cf = CFrame.new(-5.19, 6.15, -4.7) * CFrame.Angles(0, 0, math.rad(90)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	place(parent, pivot, {
		name = "LanternArm",
		size = Vector3.new(1.1, 0.08, 0.08),
		cf = CFrame.new(-5.7, 6.45, -4.7),
		material = METAL,
		color = "Soot",
		decor = true,
		shape = Enum.PartType.Cylinder,
	})
	-- StockGlow is toggled off after a rotation pulse. This globe is a separate
	-- always-on supplies lantern and is not a child of the tagged PedlarLantern.
	local globe = place(parent, pivot, {
		name = "SupplyLantern",
		size = Vector3.new(0.7, 0.9, 0.7),
		cf = CFrame.new(-5.19, 5.05, -4.85),
		material = GLASS,
		color = "Rift",
		decor = true,
		shadow = false,
	})
	globe.Transparency = 0.15
	place(parent, pivot, {
		name = "SupplyCore",
		size = Vector3.new(0.38, 0.38, 0.38),
		cf = CFrame.new(-5.19, 5.05, -4.85),
		material = NEON,
		color = "Rift",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Ball,
		neonRole = "flame",
	})
	local light = Instance.new("PointLight")
	light.Name = "SupplyLight"
	light.Color = UITheme.color("Rift")
	light.Range = 18
	light.Brightness = 2.8
	light.Shadows = false
	light.Enabled = true
	light.Parent = globe
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "SupplyGlow"
	emitter.Rate = 3
	emitter.Lifetime = NumberRange.new(2, 2)
	emitter.Speed = NumberRange.new(0.1, 0.35)
	emitter.SpreadAngle = Vector2.new(16, 16)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-8, 8)
	emitter.Acceleration = Vector3.new(0, 0.25, 0)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.LightInfluence = 0
	emitter.Color = ColorSequence.new(UITheme.color("Rift"))
	emitter.Size = NumberSequence.new(0.18)
	emitter.Transparency = NumberSequence.new(0.4)
	emitter.Enabled = true
	emitter:SetAttribute("TownEffect", "PedlarSupply")
	emitter.Parent = globe
end

function PalePedlar.replace(townFolder: Instance, refs: any): any
	local model = findHost(townFolder)
	if model == nil or model:GetAttribute("TownKit") == "PalePedlar" then
		return nil
	end
	local level = Kit.resolveQuality(refs)
	local detail = Kit.detailEnabled(level)
	local beforeParts = Kit.countParts(model)
	local beforeLights = Kit.countLights(model)
	local beforeEmitters = Kit.countEmitters(model)

	local prompts = {}
	for _, inst in model:GetDescendants() do
		if inst.ClassName == "ProximityPrompt" then
			table.insert(prompts, inst)
		end
	end
	local homes = {}
	for _, prompt in prompts do
		homes[prompt] = prompt.Parent
	end
	local lantern = findNamed(model, "PedlarLantern", "Part")
	local stock = if lantern ~= nil then lantern:FindFirstChild("StockLight") else nil

	dropBlockout(model, prompts)

	local root = model.PrimaryPart or findNamed(model, "Root", "Part")
	local pivot = if root ~= nil and root.CFrame ~= nil then root.CFrame else CFrame.new()
	local folder = Instance.new("Folder")
	folder.Name = "Wagon"
	folder.Parent = model
	local function phase(stepName: string, fn: () -> ())
		Kit.step("PalePedlar", stepName, fn)
	end
	phase("bed", function()
		buildBed(folder, pivot, detail)
	end)
	phase("wheels", function()
		buildWheels(folder, pivot)
	end)
	phase("canopy", function()
		buildCanopy(folder, pivot, detail)
	end)
	phase("crates", function()
		buildCrates(folder, pivot, detail)
	end)
	phase("cages", function()
		buildCages(folder, pivot)
	end)
	phase("mosaic", function()
		buildMosaic(folder, pivot, detail)
	end)
	phase("statue", function()
		buildStatue(folder, pivot)
		buildBook(folder, pivot)
		carveName(model, pivot)
	end)
	phase("sign", function()
		buildTradeSign(model, folder, pivot)
	end)
	phase("lantern", function()
		buildHanger(folder, pivot)
	end)

	for _, prompt in prompts do
		if prompt.Parent == nil and homes[prompt] ~= nil then
			prompt.Parent = homes[prompt]
		end
	end
	if stock ~= nil and lantern ~= nil and stock.Parent ~= lantern then
		stock.Parent = lantern
	end

	Kit.promptAnchor(model, CFrame.new(0, 2.4, -4.6))

	local afterParts = Kit.countParts(model)
	local afterLights = Kit.countLights(model)
	local afterEmitters = Kit.countEmitters(model)
	model:SetAttribute("TownKit", "PalePedlar")
	model:SetAttribute("KitQuality", level)
	model:SetAttribute("KitDetail", detail)
	model:SetAttribute("KitBeforeParts", beforeParts)
	model:SetAttribute("KitAfterParts", afterParts)
	model:SetAttribute("KitBeforeLights", beforeLights)
	model:SetAttribute("KitAfterLights", afterLights)
	model:SetAttribute("KitBeforeEmitters", beforeEmitters)
	model:SetAttribute("KitAfterEmitters", afterEmitters)
	return {
		id = pedlarId(),
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

return PalePedlar
