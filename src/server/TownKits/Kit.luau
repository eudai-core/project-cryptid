--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local TownLook = import("../../shared/Config/TownLook", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("TownLook")
end) :: any
local UITheme = import("../../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any

local Kit = {
	DECOR_ATTRIBUTE = "TownDecor",
	PART_ATTRIBUTE = "TownKitPart",
}

local geometryCache: { [string]: any } = {}

local PART_CLASS = {
	Part = true,
	WedgePart = true,
	CornerWedgePart = true,
	MeshPart = true,
	UnionOperation = true,
	NegateOperation = true,
	TrussPart = true,
	SpawnLocation = true,
	Seat = true,
	VehicleSeat = true,
}

local LIGHT_CLASS = {
	PointLight = true,
	SpotLight = true,
	SurfaceLight = true,
}

function Kit.detailEnabled(level: number): boolean
	if level >= 1 and level <= TownLook.LOW_QUALITY_MAX then
		return false
	end
	return true
end

function Kit.resolveQuality(refs: any): number
	if type(refs) == "table" and type(refs.qualityLevel) == "number" then
		return refs.qualityLevel
	end
	return 10
end

function Kit.spawn(spec: any): any
	local className = spec.className or "Part"
	local piece = Instance.new(className)
	piece.Name = spec.name
	piece.Anchored = true
	piece.Size = spec.size
	piece.CFrame = spec.cf
	piece.Material = Enum.Material[spec.material]
	piece.Color = UITheme.color(spec.color)
	piece.Transparency = 0
	if className == "Part" or className == "WedgePart" then
		piece.TopSurface = Enum.SurfaceType.Smooth
		piece.BottomSurface = Enum.SurfaceType.Smooth
	end
	local decor = spec.decor == true
	if decor then
		piece.CanCollide = false
		piece.CanTouch = false
		piece.CanQuery = false
		piece:SetAttribute(Kit.DECOR_ATTRIBUTE, true)
	else
		piece.CanCollide = true
		piece.CanTouch = true
		piece.CanQuery = true
	end
	if spec.shadow == nil then
		piece.CastShadow = not decor
	else
		piece.CastShadow = spec.shadow
	end
	if spec.shape ~= nil then
		piece.Shape = spec.shape
	end
	if spec.neonRole ~= nil then
		if TownLook.NEON_ROLES[spec.neonRole] ~= true then
			error("Neon role is not allowed: " .. tostring(spec.neonRole), 2)
		end
		piece:SetAttribute("NeonRole", spec.neonRole)
	end
	piece:SetAttribute(Kit.PART_ATTRIBUTE, true)
	if spec.parent ~= nil then
		piece.Parent = spec.parent
	end
	return piece
end

local function cacheFolder(): any
	local storage = game:GetService("ServerStorage")
	local folder = storage:FindFirstChild("TownKitCache")
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = "TownKitCache"
		folder.Parent = storage
	end
	return folder
end

function Kit.clearGeometryCache()
	table.clear(geometryCache)
	local storage = game:GetService("ServerStorage")
	local folder = storage:FindFirstChild("TownKitCache")
	if folder ~= nil then
		folder:Destroy()
	end
end

local function finishHull(hull: any, source: any)
	hull.Name = "Hull"
	hull.Anchored = true
	hull.CanCollide = true
	hull.CanTouch = true
	hull.CanQuery = true
	hull.CastShadow = true
	hull.Transparency = 0
	if source ~= nil then
		hull.Material = source.Material
		hull.Color = source.Color
	end
	hull:SetAttribute(Kit.PART_ATTRIBUTE, true)
end

-- One union of a few shell plates. A second union is never fed back in.
-- Box fidelity would seal the hall, so the collision stays Hull.
-- Lune has no CSG kernel: a failed call keeps the plates.
local function computeUnion(operands: { any }): any
	local okService, service = pcall(function()
		return game:GetService("GeometryService")
	end)
	if not okService or service == nil or type(service.UnionAsync) ~= "function" or #operands < 2 then
		return nil
	end
	local folder = Instance.new("Folder")
	folder.Name = "TownKitOperands"
	folder.Parent = cacheFolder()
	for _, operand in operands do
		operand.Parent = folder
	end
	local rest = {}
	for index = 2, #operands do
		rest[index - 1] = operands[index]
	end
	local options = {
		SplitApart = false,
		CollisionFidelity = Enum.CollisionFidelity.Hull,
		RenderFidelity = Enum.RenderFidelity.Automatic,
	}
	local ok, union = pcall(function()
		return service:UnionAsync(operands[1], rest, options)
	end)
	if not ok or union == nil then
		for _, operand in operands do
			operand.Parent = nil
		end
		folder:Destroy()
		return nil
	end
	finishHull(union, operands[1])
	union.Parent = cacheFolder()
	folder:Destroy()
	return union
end

function Kit.tryUnion(cacheKey: string, operands: { any }, pivot: any, parent: Instance): boolean
	local function placeClone(template: any)
		local clone = template:Clone()
		finishHull(clone, template)
		clone.CFrame = pivot * template.CFrame
		clone.Parent = parent
	end

	local cached = geometryCache[cacheKey]
	if cached ~= nil then
		for _, operand in operands do
			operand:Destroy()
		end
		placeClone(cached)
		return true
	end

	local union = computeUnion(operands)
	if union == nil then
		for _, operand in operands do
			operand.CFrame = pivot * operand.CFrame
			operand.Parent = parent
		end
		return false
	end
	geometryCache[cacheKey] = union
	placeClone(union)
	return true
end

function Kit.countClass(root: Instance, className: string): number
	local total = 0
	for _, inst in root:GetDescendants() do
		if inst.ClassName == className then
			total += 1
		end
	end
	return total
end

function Kit.countParts(root: Instance): number
	local total = 0
	for _, inst in root:GetDescendants() do
		if PART_CLASS[inst.ClassName] == true then
			total += 1
		end
	end
	return total
end

function Kit.countLights(root: Instance): number
	local total = 0
	for _, inst in root:GetDescendants() do
		if LIGHT_CLASS[inst.ClassName] == true then
			total += 1
		end
	end
	return total
end

function Kit.countEmitters(root: Instance): number
	return Kit.countClass(root, "ParticleEmitter")
end

return Kit
