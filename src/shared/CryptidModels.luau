--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local ArtAssets = import("./ArtAssets", function()
	return script.Parent:WaitForChild("ArtAssets")
end)
local CryptidArt = import("./Config/CryptidArt", function()
	return script.Parent:WaitForChild("Config"):WaitForChild("CryptidArt")
end)
local Species = import("./Config/Species", function()
	return script.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local UITheme = import("./UITheme", function()
	return script.Parent:WaitForChild("UITheme")
end)

export type Choice = {
	cryptidId: string,
	sourceId: string,
	placeholder: boolean,
	procedural: boolean,
	warn: boolean,
}

export type RecipePart = {
	name: string,
	color: string,
	material: string,
	shape: string,
	sx: number,
	sy: number,
	sz: number,
	x: number,
	y: number,
	z: number,
	transparent: boolean,
}

export type Recipe = {
	cryptidId: string,
	family: string,
	rarity: string,
	parts: { RecipePart },
}

local CryptidModels = {}

local warned: { [string]: boolean } = {}

local function normalize(cryptidId: any): string
	if type(cryptidId) ~= "string" or cryptidId == "" then
		return CryptidArt.unknownId
	end
	return cryptidId
end

function CryptidModels.choose(
	cryptidId: string,
	realIds: { [string]: boolean },
	placeholderIds: { [string]: boolean }
): Choice
	local id = normalize(cryptidId)
	if realIds[id] == true then
		return {
			cryptidId = id,
			sourceId = id,
			placeholder = false,
			procedural = false,
			warn = false,
		}
	end
	if placeholderIds[id] == true then
		return {
			cryptidId = id,
			sourceId = id,
			placeholder = true,
			procedural = false,
			warn = true,
		}
	end
	return {
		cryptidId = id,
		sourceId = id,
		placeholder = true,
		procedural = true,
		warn = true,
	}
end

function CryptidModels.markWarned(cryptidId: string): boolean
	if warned[cryptidId] == true then
		return false
	end
	warned[cryptidId] = true
	return true
end

function CryptidModels.resetWarnings()
	table.clear(warned)
end

function CryptidModels.recipe(cryptidId: string): Recipe
	local id = normalize(cryptidId)
	local species = Species.get(id)
	local rarity = CryptidArt.defaultRarity
	if species ~= nil then
		rarity = species.rarity
	end
	local family = CryptidArt.familyOf(id)
	local body = CryptidArt.bodies[family]
	if body == nil then
		body = CryptidArt.bodies[CryptidArt.defaultFamily]
	end
	local parts: { RecipePart } = {}
	for _, spec in body do
		local color = spec.color
		if spec.useRarity == true then
			local token = UITheme.rarity[rarity]
			if type(token) == "string" then
				color = token
			else
				color = CryptidArt.defaultColor
			end
		end
		if type(color) ~= "string" then
			color = CryptidArt.defaultColor
		end
		table.insert(parts, {
			name = spec.name,
			color = color,
			material = spec.material,
			shape = spec.shape,
			sx = spec.sx,
			sy = spec.sy,
			sz = spec.sz,
			x = spec.x,
			y = spec.y,
			z = spec.z,
			transparent = spec.name == "Root",
		})
	end
	return {
		cryptidId = id,
		family = family,
		rarity = rarity,
		parts = parts,
	}
end

local function catalog(folder: Instance?): { [string]: Model }
	local found: { [string]: Model } = {}
	if folder == nil then
		return found
	end
	local children = folder:GetChildren()
	table.sort(children, function(a, b)
		return a.Name < b.Name
	end)
	for _, child in children do
		if child:IsA("Model") then
			local id = child:GetAttribute(CryptidArt.attr.cryptidId)
			if type(id) == "string" and found[id] == nil then
				found[id] = child
			end
		end
	end
	return found
end

local function flags(models: { [string]: Model }): { [string]: boolean }
	local ids: { [string]: boolean } = {}
	for id in models do
		ids[id] = true
	end
	return ids
end

local function buildGeneric(recipe: Recipe): Model
	local model = Instance.new("Model")
	model.Name = CryptidArt.fallbackModelName
	local root: BasePart? = nil
	for _, spec in recipe.parts do
		local piece = Instance.new("Part")
		piece.Name = spec.name
		piece.Size = Vector3.new(spec.sx, spec.sy, spec.sz)
		piece.CFrame = CFrame.new(spec.x, spec.y, spec.z)
		piece.Anchored = true
		piece.CanCollide = false
		piece.CanTouch = false
		piece.CanQuery = false
		piece.Material = Enum.Material[spec.material]
		piece.Color = UITheme.color(spec.color)
		piece.Shape = Enum.PartType[spec.shape]
		local volume = spec.sx * spec.sy * spec.sz
		piece.CastShadow = volume >= CryptidArt.shadowVolume and not spec.transparent
		piece.Transparency = if spec.transparent then 1 else 0
		piece.TopSurface = Enum.SurfaceType.Smooth
		piece.BottomSurface = Enum.SurfaceType.Smooth
		piece.Parent = model
		if spec.name == "Root" then
			piece.PivotOffset = CFrame.new(-spec.x, -spec.y, -spec.z)
			root = piece
		end
	end
	if root ~= nil then
		model.PrimaryPart = root
	end
	model:SetAttribute(CryptidArt.attr.cryptidId, recipe.cryptidId)
	model:SetAttribute(CryptidArt.attr.placeholder, true)
	return model
end

function CryptidModels.get(cryptidId: string): Model
	local real = catalog(ArtAssets.folder(CryptidArt.folders.cryptids))
	local placeholders = catalog(ArtAssets.folder(CryptidArt.folders.placeholders))
	local lookedUp = cryptidId
	if type(cryptidId) == "string" then
		lookedUp = Species.modelId(cryptidId)
	end
	local choice = CryptidModels.choose(lookedUp, flags(real), flags(placeholders))
	local recipe = CryptidModels.recipe(choice.cryptidId)
	if choice.warn and CryptidModels.markWarned(choice.cryptidId) then
		local using = if choice.procedural
			then string.format("generic %s %s", recipe.family, recipe.rarity)
			else "placeholder"
		warn(string.format("CryptidModels: no model for %s, using %s", choice.cryptidId, using))
	end
	if choice.procedural then
		return buildGeneric(recipe)
	end
	local template = real[choice.cryptidId]
	if template == nil then
		template = placeholders[choice.sourceId]
	end
	if template == nil then
		return buildGeneric(recipe)
	end
	local clone = template:Clone()
	if choice.placeholder then
		clone:SetAttribute(CryptidArt.attr.placeholder, true)
	end
	return clone
end

function CryptidModels.pivotTo(model: Model, mount: CFrame)
	model:PivotTo(mount)
end

return CryptidModels
