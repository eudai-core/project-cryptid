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

local function addLife(parent: Instance, name: string)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = name
	emitter.Rate = 4
	emitter.Lifetime = NumberRange.new(2.1, 2.1)
	emitter.Speed = NumberRange.new(0.15, 0.4)
	emitter.SpreadAngle = Vector2.new(22, 22)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-10, 10)
	emitter.Acceleration = Vector3.new(0, 0.35, 0)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.LightInfluence = 0
	emitter.Color = ColorSequence.new(UITheme.color("Bone"))
	emitter.Size = NumberSequence.new(0.16)
	emitter.Transparency = NumberSequence.new(0.45)
	emitter.Enabled = true
	emitter:SetAttribute("TownEffect", "PedlarLife")
	emitter:SetAttribute("TownFlame", "extra")
	emitter.Parent = parent
end

local function animate(model: any, step: (number, number) -> ())
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return
	end
	local connection: any = nil
	local function stop()
		if connection ~= nil and type(connection.Disconnect) == "function" then
			pcall(function()
				connection:Disconnect()
			end)
		end
		connection = nil
	end
	local function watch()
		local destroying = if model ~= nil then model.Destroying else nil
		if destroying == nil or type(destroying.Connect) ~= "function" then
			return
		end
		pcall(function()
			destroying:Connect(function()
				stop()
			end)
		end)
	end
	local bound = pcall(function()
		local runService = game:GetService("RunService")
		connection = runService.Heartbeat:Connect(function(dt)
			step(if type(dt) == "number" then dt else 0, os.clock())
		end)
	end)
	if bound and connection ~= nil then
		watch()
		return
	end
	pcall(function()
		local tweens = game:GetService("TweenService")
		if tweens == nil or type(tweens.Create) ~= "function" then
			return
		end
		local clock = Instance.new("NumberValue")
		clock.Name = "SwingClock"
		clock.Value = 0
		clock.Parent = model
		local info = TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tween = tweens:Create(clock, info, { Value = 1 })
		connection = clock:GetPropertyChangedSignal("Value"):Connect(function()
			step(0, clock.Value)
		end)
		tween:Play()
		watch()
	end)
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

local function buildCages(parent: Instance, pivot: any, detail: boolean)
	local seats = { -4.4, -1.5, 1.5, 4.4 }
	for index, x in seats do
		for bar = 0, 3 do
			local ox = (bar - 1.5) * 0.28
			place(parent, pivot, {
				name = "CageBar",
				size = Vector3.new(0.06, 1.15, 0.06),
				cf = CFrame.new(x + ox, 2.15, -3.55),
				material = METAL,
				color = "BoneDim",
				decor = true,
			})
		end
		place(parent, pivot, {
			name = "CageRing",
			size = Vector3.new(0.95, 0.06, 0.7),
			cf = CFrame.new(x, 1.55, -3.55),
			material = METAL,
			color = "Soot",
			decor = true,
		})
		place(parent, pivot, {
			name = "CageRing",
			size = Vector3.new(0.95, 0.06, 0.7),
			cf = CFrame.new(x, 2.7, -3.55),
			material = METAL,
			color = "Soot",
			decor = true,
		})
		place(parent, pivot, {
			name = "Curio",
			size = Vector3.new(0.28, 0.22, 0.18),
			cf = CFrame.new(x, 1.75, -3.5) * CFrame.Angles(0.2, sway(index, 0.4), 0.1),
			material = BONE,
			color = "Bone",
			decor = true,
			shadow = false,
		})
		if detail and index % 2 == 0 then
			local wick = place(parent, pivot, {
				name = "CageWick",
				size = Vector3.new(0.12, 0.12, 0.12),
				cf = CFrame.new(x, 2.2, -3.5),
				material = GLASS,
				color = "Rift",
				decor = true,
				shadow = false,
				shape = Enum.PartType.Ball,
			})
			wick.Transparency = 0.35
			addPoint(wick, "CageGlow", 5, 0.22, "Rift")
		end
	end
end

local function buildCloak(parent: Instance, pivot: any, detail: boolean)
	local facets = if detail then 7 else 4
	for index = 1, facets do
		local y = 1.6 + index * 0.55
		local width = 2.8 - index * 0.18
		place(parent, pivot, {
			className = "WedgePart",
			name = "CloakFacet",
			size = Vector3.new(width, 0.55, 0.9),
			cf = CFrame.new(sway(index, 0.08), y, 4.85)
				* CFrame.Angles(math.rad(8), sway(index, 0.2), math.rad(sway(index, 6))),
			material = BONE,
			color = if index % 2 == 0 then "Bone" else "BoneDim",
			decor = true,
		})
	end
	place(parent, pivot, {
		className = "WedgePart",
		name = "CloakHood",
		size = Vector3.new(1.3, 0.7, 0.85),
		cf = CFrame.new(0.05, 5.7, 4.55) * CFrame.Angles(math.rad(-18), 0, math.rad(4)),
		material = BONE,
		color = "Bone",
		decor = true,
	})
	if detail then
		local hem = place(parent, pivot, {
			name = "CloakHem",
			size = Vector3.new(2.4, 0.08, 0.7),
			cf = CFrame.new(0, 1.45, 4.95),
			material = CLOTH,
			color = "Bone",
			decor = true,
			shadow = false,
		})
		addLife(hem, "PaleMotes")
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
	animate(model, function(_dt: number, t: number)
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
	buildBed(folder, pivot, detail)
	buildWheels(folder, pivot)
	buildCanopy(folder, pivot, detail)
	buildCrates(folder, pivot, detail)
	buildCages(folder, pivot, detail)
	buildCloak(folder, pivot, detail)
	buildMosaic(folder, pivot, detail)
	buildTradeSign(model, folder, pivot)
	buildHanger(folder, pivot)

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
