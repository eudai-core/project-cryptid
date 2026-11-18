--!strict
-- Runs after every other town kit. Retints built-in materials and, above quality 3,
-- adds seeded moss, ivy, roots, and mushrooms. MaterialVariant instances are created
-- under MaterialService and reused, but they are not assigned to parts: a variant
-- whose maps are blank replaces the built-in shader with a blank texture.

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
local TownMaterials = import("../../shared/Config/TownMaterials", function()
	return game:GetService("ReplicatedStorage")
		:WaitForChild("Shared")
		:WaitForChild("Config")
		:WaitForChild("TownMaterials")
end) :: any
local UITheme = import("../../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any

local MaterialPass = {
	name = "MaterialPass",
	order = TownMaterials.ORDER,
	isKit = true,
	last = nil,
}

local PART_CLASS = {
	Part = true,
	WedgePart = true,
	CornerWedgePart = true,
	MeshPart = true,
	UnionOperation = true,
	NegateOperation = true,
	TrussPart = true,
}

local BONE_NAMES = {
	bone = true,
	skull = true,
	tooth = true,
	spine = true,
	jaw = true,
	maw = true,
	horn = true,
	rib = true,
	bead = true,
	eyering = true,
	wishbone = true,
	prowhead = true,
	prowjaw = true,
	prowhorn = true,
	prowneck = true,
}

local DENY = {
	pupil = true,
	eye = true,
	wick = true,
	sconcewick = true,
	flame = true,
	candle = true,
	crowbody = true,
	crowwing = true,
	clockface = true,
	vortexhost = true,
	sign = true,
	signtrim = true,
	root = true,
	canopy = true,
	doorrecess = true,
	pane = true,
	moonphase = true,
}

local ROOF_MAT = {
	Wood = true,
	WoodPlanks = true,
	Slate = true,
	RoofShingles = true,
	ClayRoofTiles = true,
}

local GROUND_MAT = {
	Cobblestone = true,
	Slate = true,
	Concrete = true,
	Pavement = true,
	Pebble = true,
}

local STONE_MAT = {
	Rock = true,
	Basalt = true,
	Granite = true,
	Sandstone = true,
	Pebble = true,
	Concrete = true,
	Pavement = true,
	Slate = true,
}

local PLASTIC = {
	SmoothPlastic = true,
	Plastic = true,
}

local BASE_NAMES = {
	plinth = true,
	foundation = true,
	step = true,
	capital = true,
	footing = true,
	sill = true,
	bowl = true,
}

local PORTAL_NAMES = {}
for _, spec in TownLook.PORTALS do
	if type(spec.id) == "string" then
		PORTAL_NAMES[spec.id] = true
	end
end

local function paint(token: string): any
	return UITheme.color(token)
end

local function materialName(part: any): string
	local material = part.Material
	if type(material) == "string" then
		return material
	end
	local kind = typeof(material)
	if kind == "EnumItem" or type(material) == "table" or type(material) == "userdata" then
		local ok, name = pcall(function()
			return material.Name
		end)
		if ok and type(name) == "string" then
			return name
		end
	end
	return ""
end

local function channelByte(channel: number): number
	return math.clamp(math.floor(channel * 255 + 0.5), 0, 255)
end

-- Color3 has ToHex() and R/G/B. It has no Hex field; reading one throws in Studio.
local function hexOf(color: any): string
	if color == nil then
		return ""
	end
	if type(color.ToHex) == "function" then
		local ok, hex = pcall(function()
			return color:ToHex()
		end)
		if ok and type(hex) == "string" then
			return string.upper(string.gsub(hex, "#", ""))
		end
	end
	if type(color.R) == "number" and type(color.G) == "number" and type(color.B) == "number" then
		return string.format("%02X%02X%02X", channelByte(color.R), channelByte(color.G), channelByte(color.B))
	end
	return ""
end

local function positionOf(part: any): any
	local cf = part.CFrame
	if typeof(cf) ~= "CFrame" and type(cf) ~= "table" and type(cf) ~= "userdata" then
		return nil
	end
	local okPos, pos = pcall(function()
		return cf.Position
	end)
	if okPos and pos ~= nil then
		return pos
	end
	local okX, x = pcall(function()
		return cf.X
	end)
	if okX and type(x) == "number" then
		return Vector3.new(cf.X, cf.Y, cf.Z)
	end
	return nil
end

local function hashOf(text: string): number
	local state = TownMaterials.HASH_SEED
	local span = TownMaterials.RNG_MOD
	local mul = TownMaterials.HASH_MUL
	for index = 1, #text do
		state = (state * mul + string.byte(text, index)) % span
	end
	return state
end

local function quant(value: number): string
	return tostring(math.floor(value * TownMaterials.POSITION_SCALE + 0.5))
end

local function partKey(part: any, pos: any): string
	if pos == nil then
		return part.Name
	end
	return part.Name .. ":" .. quant(pos.X) .. ":" .. quant(pos.Y) .. ":" .. quant(pos.Z)
end

local function stream(seed: number): () -> number
	local state = seed % TownMaterials.RNG_MOD
	if state < 1 then
		state = 1
	end
	return function(): number
		state = (state * TownMaterials.RNG_MUL + TownMaterials.RNG_ADD) % TownMaterials.RNG_MOD
		return state / TownMaterials.RNG_MOD
	end
end

local function scaled(full: number, level: number): number
	if level < TownMaterials.NATURE_MIN_QUALITY or full <= 0 then
		return 0
	end
	local span = TownMaterials.QUALITY_TOP - TownMaterials.NATURE_MIN_QUALITY + 1
	local along = level - TownMaterials.NATURE_MIN_QUALITY + 1
	local count = math.floor(full * along / span)
	if count < 1 then
		return 1
	end
	return count
end

local function lowerName(part: any): string
	return string.lower(tostring(part.Name))
end

local function endsWith(text: string, suffix: string): boolean
	if #text < #suffix then
		return false
	end
	return string.sub(text, #text - #suffix + 1) == suffix
end

local function isBasePart(inst: any): boolean
	return PART_CLASS[inst.ClassName] == true
end

local function childClass(part: any, className: string): boolean
	if type(part.GetChildren) ~= "function" then
		return false
	end
	for _, child in part:GetChildren() do
		if child.ClassName == className then
			return true
		end
	end
	return false
end

local function modelOf(inst: any, townFolder: Instance): any
	local cursor = inst.Parent
	while cursor ~= nil and cursor ~= townFolder do
		if cursor.ClassName == "Model" then
			return cursor
		end
		cursor = cursor.Parent
	end
	return nil
end

local function selfTagged(inst: any): boolean
	if type(inst.HasTag) ~= "function" then
		return false
	end
	for _, tag in TownMaterials.PEDLAR_TAGS do
		local ok, result = pcall(function()
			return inst:HasTag(tag)
		end)
		if ok and result == true then
			return true
		end
	end
	return false
end

local function markTree(root: any, blocked: { [any]: boolean })
	blocked[root] = true
	if type(root.GetDescendants) == "function" then
		for _, child in root:GetDescendants() do
			blocked[child] = true
		end
	end
end

local function pedlarParts(townFolder: Instance): { [any]: boolean }
	local blocked: { [any]: boolean } = {}
	local function walk(node: any)
		if node.Name == Town.PEDLAR_ID then
			markTree(node, blocked)
		end
		if type(node.GetChildren) == "function" then
			for _, child in node:GetChildren() do
				walk(child)
			end
		end
	end
	walk(townFolder)
	local ok, service = pcall(function()
		return game:GetService("CollectionService")
	end)
	if ok and service ~= nil and type(service.GetTagged) == "function" then
		for _, tag in TownMaterials.PEDLAR_TAGS do
			local taggedOk, list = pcall(function()
				return service:GetTagged(tag)
			end)
			if taggedOk and type(list) == "table" then
				for _, inst in list do
					markTree(inst, blocked)
				end
			end
		end
	end
	return blocked
end

local function pedlarHit(part: any, blocked: { [any]: boolean }): boolean
	if blocked[part] == true then
		return true
	end
	local cursor = part
	while cursor ~= nil do
		if blocked[cursor] == true or selfTagged(cursor) or cursor.Name == Town.PEDLAR_ID then
			return true
		end
		cursor = cursor.Parent
	end
	return false
end

local function isRoofName(name: string): boolean
	return string.find(name, "roof", 1, true) ~= nil
		or string.find(name, "shingle", 1, true) ~= nil
		or string.find(name, "eave", 1, true) ~= nil
		or name == "ridge"
		or name == "thatch"
end

local function isGroundName(name: string): boolean
	return name == "cobble"
		or name == "ground"
		or name == "plaza"
		or name == "platform"
		or name == "townplatform"
		or name == "townroad"
		or name == "townramp"
		or string.find(name, "footprint", 1, true) ~= nil
		or string.find(name, "reserved_", 1, true) ~= nil
end

local function isBone(part: any, material: string, name: string): boolean
	if DENY[name] == true then
		return false
	end
	if material == "Limestone" or material == "Marble" then
		return true
	end
	local hex = hexOf(part.Color)
	local boneColor = hex == string.upper(UITheme.palette.Bone) or hex == string.upper(UITheme.palette.BoneDim)
	if not boneColor then
		return false
	end
	return BONE_NAMES[name] == true or PLASTIC[material] == true or material == "Slate"
end

local function roleFor(part: any, material: string, name: string): string?
	if isBone(part, material, name) then
		return "Bone"
	end
	if isRoofName(name) and ROOF_MAT[material] == true then
		return "SlateShingle"
	end
	if material == "Brick" then
		return "AgedBrick"
	end
	if material == "Cobblestone" or (isGroundName(name) and GROUND_MAT[material] == true) then
		return "MossyCobble"
	end
	if material == "Wood" or material == "WoodPlanks" then
		return "WornDarkTimber"
	end
	if STONE_MAT[material] == true then
		return "WeatheredStone"
	end
	return nil
end

local SKIP_NAME = {
	root = true,
	sign = true,
	signtrim = true,
	pupil = true,
	flame = true,
	candle = true,
	crowbody = true,
	crowwing = true,
	clockface = true,
	vortexhost = true,
	moonphase = true,
	eye = true,
	wick = true,
	sconcewick = true,
}

local function protected(part: any, blocked: { [any]: boolean }): boolean
	if part:GetAttribute(TownMaterials.NATURE_ATTRIBUTE) ~= nil then
		return true
	end
	if part.ClassName == "SpawnLocation" then
		return true
	end
	local name = lowerName(part)
	if SKIP_NAME[name] == true then
		return true
	end
	if endsWith(name, "promptanchor") or name == "dooranchor" then
		return true
	end
	if part:GetAttribute("TownAnchor") ~= nil or part:GetAttribute("ShopId") ~= nil then
		return true
	end
	if (part.Transparency or 0) >= 1 then
		return true
	end
	local material = materialName(part)
	if material == "Neon" or type(part:GetAttribute("NeonRole")) == "string" then
		return true
	end
	if childClass(part, "SurfaceGui") or childClass(part, "BillboardGui") or childClass(part, "ProximityPrompt") then
		return true
	end
	if pedlarHit(part, blocked) then
		return true
	end
	return false
end

local function pickToken(spec: any, kitPart: boolean, hash: number): string
	local list = if kitPart then spec.kit else spec.open
	local total = 0
	for _, choice in list do
		total += choice.weight
	end
	if total <= 0 then
		return list[1].token
	end
	local cursor = hash % total
	for _, choice in list do
		if cursor < choice.weight then
			return choice.token
		end
		cursor -= choice.weight
	end
	return list[1].token
end

local function reflect(spec: any, hash: number): number
	local bucket = hash % TownMaterials.POSITION_SCALE
	local unit = bucket / TownMaterials.POSITION_SCALE
	local value = spec.reflectance + (unit - 0.5) * TownMaterials.REFLECT_JITTER
	if value < 0 then
		return 0
	end
	if value > TownMaterials.REFLECT_MAX then
		return TownMaterials.REFLECT_MAX
	end
	return value
end

local function baseFor(spec: any, current: string): string
	if spec.alternate ~= nil and current == spec.alternate then
		return spec.alternate
	end
	return spec.base
end

local function ensureVariants(): (number, number)
	local service = game:GetService("MaterialService")
	local created = 0
	local reused = 0
	for _, spec in TownMaterials.VARIANTS do
		local existing = service:FindFirstChild(spec.name)
		if existing == nil then
			local variant = Instance.new("MaterialVariant")
			variant.Name = spec.name
			variant.StudsPerTile = spec.studsPerTile
			pcall(function()
				variant.BaseMaterial = Enum.Material[spec.base]
			end)
			variant:SetAttribute("MapsApplied", false)
			variant.Parent = service
			created += 1
		else
			reused += 1
		end
	end
	return created, reused
end

local function localOf(part: any, point: any): (any, any)
	local cf = part.CFrame
	local size = part.Size
	if cf == nil or size == nil or type(cf.Inverse) ~= "function" then
		return nil, nil
	end
	local localPos = cf:Inverse() * point
	if localPos == nil or localPos.X == nil then
		return nil, nil
	end
	return localPos, size
end

local function insideExpanded(part: any, point: any, margin: number): boolean
	local localPos, size = localOf(part, point)
	if localPos == nil then
		return false
	end
	return math.abs(localPos.X) <= size.X * 0.5 + margin
		and math.abs(localPos.Y) <= size.Y * 0.5 + margin
		and math.abs(localPos.Z) <= size.Z * 0.5 + margin
end

-- A road is a flat slab. Widen it in X/Z only. A vertical margin would turn
-- TownRoad and TownRamp into a low wall and reject the cobble rim and ivy.
local function onRoadSlab(part: any, point: any): boolean
	local localPos, size = localOf(part, point)
	if localPos == nil then
		return false
	end
	return math.abs(localPos.X) <= size.X * 0.5 + TownMaterials.ROAD_MARGIN
		and math.abs(localPos.Z) <= size.Z * 0.5 + TownMaterials.ROAD_MARGIN
		and math.abs(localPos.Y) <= size.Y * 0.5 + TownMaterials.ROAD_Y_SLACK
end

local function spawnPart(
	folder: Instance,
	className: string,
	name: string,
	size: any,
	cf: any,
	material: string,
	token: string,
	kind: string,
	shape: any
): any
	local piece = Instance.new(className)
	piece.Name = name
	piece.Anchored = true
	piece.Size = size
	piece.CFrame = cf
	piece.Material = Enum.Material[material]
	piece.Color = paint(token)
	piece.Transparency = 0
	piece.CanCollide = false
	piece.CanTouch = false
	piece.CanQuery = false
	piece.CastShadow = kind == "Roots"
	piece:SetAttribute(TownMaterials.NATURE_ATTRIBUTE, kind)
	piece:SetAttribute(Kit.DECOR_ATTRIBUTE, true)
	if shape ~= nil then
		piece.Shape = shape
	end
	if className == "Part" or className == "WedgePart" then
		piece.TopSurface = Enum.SurfaceType.Smooth
		piece.BottomSurface = Enum.SurfaceType.Smooth
	end
	piece.Parent = folder
	return piece
end

local function greenOf(rng: () -> number): string
	local list = TownMaterials.NATURE_GREENS
	local index = math.floor(rng() * #list) + 1
	if index > #list then
		index = #list
	end
	if index < 1 then
		index = 1
	end
	return list[index]
end

local function plantMaterial(rng: () -> number): string
	if rng() < 0.5 then
		return "LeafyGrass"
	end
	return "Grass"
end

function MaterialPass.replace(townFolder: Instance, refs: any)
	local level = Kit.resolveQuality(refs)
	local created, reused = ensureVariants()
	local previous = townFolder:FindFirstChild(TownMaterials.NATURE_FOLDER)
	if previous ~= nil then
		previous:Destroy()
	end

	local blocked = pedlarParts(townFolder)
	local snapshot = townFolder:GetDescendants()
	local tinted = 0
	local rims = {}
	local stones = {}
	local walls = {}
	local trees: { [any]: any } = {}
	local portals: { [any]: boolean } = {}
	local doors = {}
	local prompts = {}
	local roads = {}
	local signs = {}
	local wells = {}
	local vortices = {}

	local function push(list: { any }, part: any, pos: any)
		table.insert(list, {
			part = part,
			pos = pos,
			key = tostring(hashOf(partKey(part, pos))),
		})
	end

	for _, inst in snapshot do
		if inst.ClassName == "Model" and PORTAL_NAMES[inst.Name] == true then
			portals[inst] = true
		end
		if not isBasePart(inst) then
			continue
		end
		local name = lowerName(inst)
		local pos = positionOf(inst)
		local model = modelOf(inst, townFolder)
		if name == "door" or name == "dooranchor" or inst:GetAttribute("TownAnchor") == "Door" then
			push(doors, inst, pos)
		end
		if
			endsWith(name, "promptanchor")
			or inst:GetAttribute("ShopId") ~= nil
			or childClass(inst, "ProximityPrompt")
		then
			push(prompts, inst, pos)
		end
		if name == "townroad" or name == "townramp" then
			push(roads, inst, pos)
		end
		if
			name == "sign"
			or name == "signtrim"
			or childClass(inst, "SurfaceGui")
			or childClass(inst, "BillboardGui")
		then
			push(signs, inst, pos)
		end
		if name == "vortex" then
			push(vortices, inst, pos)
		end
		if model ~= nil and model.Name == TownMaterials.WELL_MODEL then
			if name == "centre" or name == "stone" or name == "water" or name == "voussoir" then
				push(wells, inst, pos)
			end
		end
		if TownMaterials.TREE_PARTS[inst.Name] == true and pos ~= nil then
			local host = model or townFolder
			local current = trees[host]
			if current == nil or pos.Y < current.pos.Y then
				trees[host] = { part = inst, pos = pos, key = tostring(hashOf(partKey(inst, pos))) }
			end
		end
		if protected(inst, blocked) then
			continue
		end
		local material = materialName(inst)
		local role = roleFor(inst, material, name)
		if role ~= nil then
			local spec = TownMaterials.BY_NAME[role]
			local key = partKey(inst, pos)
			local hash = hashOf(key)
			local kitPart = inst:GetAttribute(Kit.PART_ATTRIBUTE) == true
			inst.Material = Enum.Material[baseFor(spec, material)]
			inst.Color = paint(pickToken(spec, kitPart, hash))
			inst.Reflectance = reflect(spec, hash)
			inst:SetAttribute(TownMaterials.ROLE_ATTRIBUTE, role)
			inst:SetAttribute(TownMaterials.PASS_ATTRIBUTE, true)
			tinted += 1
			if role == "MossyCobble" and name == "cobble" then
				push(rims, inst, pos)
			elseif role == "MossyCobble" and name ~= "townroad" and name ~= "townramp" and inst.Size ~= nil then
				local size = inst.Size
				if math.min(size.X, size.Y, size.Z) < 1 then
					push(stones, inst, pos)
				end
			elseif role == "WeatheredStone" and BASE_NAMES[name] == true then
				push(stones, inst, pos)
			end
			if
				(role == "WeatheredStone" or role == "WornDarkTimber" or role == "AgedBrick")
				and string.find(name, "wall", 1, true) ~= nil
			then
				if model == nil or model.Name ~= TownMaterials.WELL_MODEL then
					push(walls, inst, pos)
				end
			end
		end
	end

	local natureCount = 0
	local function blockedPoint(point: any, skipRoads: boolean?): boolean
		for _, item in doors do
			if insideExpanded(item.part, point, TownMaterials.DOOR_CLEARANCE) then
				return true
			end
		end
		for _, item in prompts do
			if insideExpanded(item.part, point, TownMaterials.PROMPT_CLEARANCE) then
				return true
			end
		end
		for _, item in signs do
			if insideExpanded(item.part, point, TownMaterials.SIGN_CLEARANCE) then
				return true
			end
		end
		if skipRoads ~= true then
			for _, item in roads do
				if onRoadSlab(item.part, point) then
					return true
				end
			end
		end
		for _, item in wells do
			if insideExpanded(item.part, point, TownMaterials.WELL_MARGIN) then
				return true
			end
		end
		for _, item in vortices do
			if insideExpanded(item.part, point, TownMaterials.PORTAL_MARGIN) then
				return true
			end
		end
		return false
	end

	if level >= TownMaterials.NATURE_MIN_QUALITY then
		local rng = stream(TownMaterials.NATURE_SEED + level)
		local folder = Instance.new("Folder")
		folder.Name = TownMaterials.NATURE_FOLDER
		folder.Parent = townFolder
		local mossFolder = Instance.new("Folder")
		mossFolder.Name = "Moss"
		mossFolder.Parent = folder
		local ivyFolder = Instance.new("Folder")
		ivyFolder.Name = "Ivy"
		ivyFolder.Parent = folder
		local rootFolder = Instance.new("Folder")
		rootFolder.Name = "Roots"
		rootFolder.Parent = folder
		local capFolder = Instance.new("Folder")
		capFolder.Name = "Mushrooms"
		capFolder.Parent = folder

		local function room(): boolean
			return natureCount < TownMaterials.MAX_NATURE_PARTS
		end

		local function sortList(list: { any })
			table.sort(list, function(a, b)
				return a.key < b.key
			end)
		end
		sortList(rims)
		sortList(stones)
		sortList(walls)

		local function mossAt(pos: any, yaw: number, skipRoads: boolean?)
			if not room() or pos == nil or blockedPoint(pos, skipRoads) then
				return
			end
			local width = 0.65 + rng() * 0.85
			local depth = 0.5 + rng() * 0.7
			local thick = 0.1 + rng() * 0.08
			local cf = CFrame.new(pos) * CFrame.Angles(0, yaw, 0)
			spawnPart(
				mossFolder,
				"Part",
				"MossPatch",
				Vector3.new(width, thick, depth),
				cf,
				plantMaterial(rng),
				greenOf(rng),
				"Moss",
				Enum.PartType.Ball
			)
			natureCount += 1
		end

		local function flatAngle(pos: any): number
			return math.atan2(pos.X, pos.Z)
		end

		-- One patch in each gap between roads, on the cobble rim. Road slabs are
		-- not consulted here: their boxes meet the rim at the road mouths, and a
		-- vertical margin used to reject the gaps as well.
		if #rims > 0 and room() then
			local host = rims[1].part
			local origin = positionOf(host)
			local hostSize = host.Size
			if origin ~= nil and hostSize ~= nil then
				local radius = math.max(hostSize.X, hostSize.Y, hostSize.Z) * 0.5 - TownMaterials.MOSS_INSET
				if radius < 1 then
					radius = 1
				end
				local y = origin.Y + math.min(hostSize.X, hostSize.Y, hostSize.Z) * 0.5 + TownMaterials.MOSS_LIFT
				local angles = {}
				for _, item in roads do
					if item.part.Name == "TownRoad" then
						local roadPos = positionOf(item.part)
						if roadPos ~= nil then
							table.insert(angles, flatAngle(roadPos))
						end
					end
				end
				table.sort(angles)
				if #angles == 0 then
					table.insert(angles, 0)
				end
				for index, angle in angles do
					local nxt = angles[index + 1]
					local span = if nxt == nil then angles[1] + math.pi * 2 else nxt
					local mid = (angle + span) * 0.5
					local point = Vector3.new(origin.X + math.cos(mid) * radius, y, origin.Z + math.sin(mid) * radius)
					mossAt(point, mid, true)
				end
			end
		end

		local rimCount = scaled(TownMaterials.MOSS_ON_RIM, level)
		for index = 1, rimCount do
			if #rims == 0 or not room() then
				break
			end
			local host = rims[((index - 1) % #rims) + 1]
			local placed = false
			for _ = 1, TownMaterials.PLACE_ATTEMPTS do
				local angle = rng() * math.pi * 2
				local pos = positionOf(host.part)
				local size = host.part.Size
				if pos ~= nil and size ~= nil then
					local radius = math.max(size.X, size.Y, size.Z) * 0.5 - TownMaterials.MOSS_INSET
					if radius < 1 then
						radius = 1
					end
					local thickness = math.min(size.X, size.Y, size.Z)
					local point = Vector3.new(
						pos.X + math.cos(angle) * radius,
						pos.Y + thickness * 0.5 + TownMaterials.MOSS_LIFT,
						pos.Z + math.sin(angle) * radius
					)
					if not blockedPoint(point) then
						mossAt(point, angle)
						placed = true
						break
					end
				end
			end
			if not placed then
				continue
			end
		end

		local stoneCount = scaled(TownMaterials.MOSS_ON_STONE, level)
		for index = 1, stoneCount do
			if #stones == 0 or not room() then
				break
			end
			local host = stones[((index - 1) % #stones) + 1]
			local cf = host.part.CFrame
			local size = host.part.Size
			if cf ~= nil and size ~= nil and cf.UpVector ~= nil and cf.Position ~= nil then
				local point = cf.Position + cf.UpVector * (size.Y * 0.5 + TownMaterials.MOSS_LIFT)
				mossAt(point, rng() * math.pi * 2)
			end
		end

		local wallCount = scaled(TownMaterials.IVY_WALLS, level)
		for index = 1, wallCount do
			if #walls == 0 or not room() then
				break
			end
			local host = walls[((index - 1) % #walls) + 1]
			local cf = host.part.CFrame
			local size = host.part.Size
			if cf == nil or size == nil or cf.LookVector == nil or cf.RightVector == nil or cf.Position == nil then
				continue
			end
			local links = TownMaterials.IVY_LINKS
			local span = size.Y - 0.7
			if span < 0.4 then
				span = 0.4
			end
			local step = span / links
			local along = (rng() - 0.5) * math.max(size.X - 0.8, 0.2)
			for link = 1, links do
				if not room() then
					break
				end
				local climb = 0.35 + (link - 1) * step
				local pos = cf.Position
					+ cf.LookVector * (size.Z * 0.5 + TownMaterials.IVY_GAP)
					+ cf.RightVector * along
					+ Vector3.new(0, -size.Y * 0.5 + climb, 0)
				if blockedPoint(pos, true) then
					continue
				end
				local wedgeCf = CFrame.new(pos) * CFrame.Angles(0.4, rng() * 0.6, 0.2)
				spawnPart(
					ivyFolder,
					"WedgePart",
					"IvyWedge",
					Vector3.new(0.28, 0.42, 0.16),
					wedgeCf,
					plantMaterial(rng),
					greenOf(rng),
					"Ivy",
					nil
				)
				natureCount += 1
				if room() then
					local leafPos = pos + Vector3.new(0, 0.16, 0)
					if not blockedPoint(leafPos, true) then
						spawnPart(
							ivyFolder,
							"Part",
							"IvyLeaf",
							Vector3.new(0.34, 0.08, 0.26),
							CFrame.new(leafPos) * CFrame.Angles(0.3, rng(), 0.4),
							"LeafyGrass",
							greenOf(rng),
							"Ivy",
							Enum.PartType.Ball
						)
						natureCount += 1
					end
				end
			end
		end

		local function unit(x: number, y: number, z: number): any
			local length = math.sqrt(x * x + y * y + z * z)
			if length < 0.001 then
				return Vector3.new(1, 0, 0), 0
			end
			return Vector3.new(x / length, y / length, z / length), length
		end

		local rootBudget = scaled(TownMaterials.ROOTS_PER_TREE, level)
		local treeList = {}
		for _, record in trees do
			table.insert(treeList, record)
		end
		table.sort(treeList, function(a, b)
			return a.key < b.key
		end)
		for _, record in treeList do
			local origin = record.pos
			if origin == nil then
				continue
			end
			for _ = 1, rootBudget do
				if not room() then
					break
				end
				local angle = rng() * math.pi * 2
				local direction = unit(math.cos(angle), -TownMaterials.ROOT_DROP, math.sin(angle))
				local cursor = Vector3.new(origin.X, origin.Y + 0.15, origin.Z)
				local reach = TownMaterials.ROOT_LENGTH / TownMaterials.ROOT_SEGMENTS
				for segment = 1, TownMaterials.ROOT_SEGMENTS do
					if not room() then
						break
					end
					local taper = 1 - (segment - 1) * TownMaterials.ROOT_TAPER
					if taper < 0.35 then
						taper = 0.35
					end
					local length = reach * (1.15 - segment * 0.12)
					local nextPos = Vector3.new(
						cursor.X + direction.X * length,
						cursor.Y + direction.Y * length,
						cursor.Z + direction.Z * length
					)
					if blockedPoint(nextPos) then
						break
					end
					local mid = Vector3.new(
						(cursor.X + nextPos.X) * 0.5,
						(cursor.Y + nextPos.Y) * 0.5,
						(cursor.Z + nextPos.Z) * 0.5
					)
					local ok, cf = pcall(function()
						return CFrame.lookAt(mid, nextPos) * CFrame.Angles(0, math.rad(90), 0)
					end)
					if ok and cf ~= nil then
						local diameter = 0.48 * taper
						spawnPart(
							rootFolder,
							"Part",
							"Gnarl",
							Vector3.new(length, diameter, diameter),
							cf,
							"WoodPlanks",
							if rng() < 0.75 then TownMaterials.VOID else TownMaterials.BLOOD,
							"Roots",
							Enum.PartType.Cylinder
						)
						natureCount += 1
					end
					cursor = nextPos
				end
			end
		end

		local function portalCenter(model: any): any
			if type(model.GetDescendants) ~= "function" then
				return nil
			end
			for _, inst in model:GetDescendants() do
				if inst.Name == "Vortex" then
					local pos = positionOf(inst)
					if pos ~= nil then
						return pos
					end
				end
			end
			if model.PrimaryPart ~= nil then
				return positionOf(model.PrimaryPart)
			end
			for _, inst in model:GetDescendants() do
				local pos = positionOf(inst)
				if pos ~= nil then
					return pos
				end
			end
			return nil
		end

		local shroomCount = scaled(TownMaterials.MUSHROOMS_PER_PORTAL, level)
		local portalList = {}
		for model in portals do
			table.insert(portalList, model)
		end
		table.sort(portalList, function(a, b)
			return tostring(a.Name) < tostring(b.Name)
		end)
		for _, model in portalList do
			local center = portalCenter(model)
			if center == nil then
				continue
			end
			local placed = 0
			local tries = 0
			while placed < shroomCount and tries < TownMaterials.PLACE_ATTEMPTS * shroomCount and room() do
				tries += 1
				local angle = rng() * math.pi * 2
				local radius = TownMaterials.PORTAL_RING_MIN
					+ rng() * (TownMaterials.PORTAL_RING_MAX - TownMaterials.PORTAL_RING_MIN)
				local pos = Vector3.new(
					center.X + math.cos(angle) * radius,
					Town.FLOOR_Y + TownMaterials.MOSS_LIFT,
					center.Z + math.sin(angle) * radius
				)
				if not blockedPoint(pos) then
					local stem = 0.28 + rng() * 0.18
					local stemCf = CFrame.new(pos + Vector3.new(0, stem * 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
					spawnPart(
						capFolder,
						"Part",
						"MushroomStem",
						Vector3.new(stem, 0.12, 0.12),
						stemCf,
						"Limestone",
						TownMaterials.BONE,
						"Mushrooms",
						Enum.PartType.Cylinder
					)
					natureCount += 1
					if room() then
						local capPos = pos + Vector3.new(0, stem + 0.05, 0)
						spawnPart(
							capFolder,
							"Part",
							"MushroomCap",
							Vector3.new(0.34, 0.12, 0.34),
							CFrame.new(capPos),
							"LeafyGrass",
							greenOf(rng),
							"Mushrooms",
							Enum.PartType.Ball
						)
						natureCount += 1
					end
					placed += 1
				end
			end
		end

		if natureCount == 0 then
			folder:Destroy()
		end
	end

	MaterialPass.last = {
		tinted = tinted,
		natureParts = natureCount,
		variantsCreated = created,
		variantsReused = reused,
		variantsApplied = 0,
		quality = level,
		parts = Kit.countParts(townFolder),
		lights = Kit.countLights(townFolder),
		emitters = Kit.countEmitters(townFolder),
	}
	return nil
end

return MaterialPass
