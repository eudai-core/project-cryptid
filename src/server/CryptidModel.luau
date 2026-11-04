--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any
local Species = require(Shared:WaitForChild("Config"):WaitForChild("Species")) :: any

local CryptidModel = {}

local function part(
	model: Model,
	name: string,
	size: Vector3,
	cf: CFrame,
	colorToken: string,
	materialName: string
): Part
	local piece = Instance.new("Part")
	piece.Name = name
	piece.Size = size
	piece.CFrame = cf
	piece.Anchored = true
	piece.CanCollide = false
	piece.CanTouch = false
	piece.CanQuery = false
	piece.CastShadow = true
	piece.TopSurface = Enum.SurfaceType.Smooth
	piece.BottomSurface = Enum.SurfaceType.Smooth
	piece.Material = Enum.Material[materialName]
	piece.Color = UITheme.color(colorToken)
	piece.Parent = model
	return piece
end

local function buildMothman(model: Model)
	local body = part(model, "Body", Vector3.new(1.4, 2.4, 1.1), CFrame.new(0, 1.8, 0), "Soot", "Slate")
	part(
		model,
		"WingLeft",
		Vector3.new(0.25, 1.6, 2.8),
		CFrame.new(-1.5, 2.2, 0) * CFrame.Angles(0, 0, math.rad(-28)),
		"Ash",
		"Slate"
	)
	part(
		model,
		"WingRight",
		Vector3.new(0.25, 1.6, 2.8),
		CFrame.new(1.5, 2.2, 0) * CFrame.Angles(0, 0, math.rad(28)),
		"Ash",
		"Slate"
	)
	part(model, "Eyes", Vector3.new(0.7, 0.25, 0.2), CFrame.new(0, 2.5, -0.55), "Gold", "SmoothPlastic")
	model.PrimaryPart = body
end

local function buildNightcrawler(model: Model)
	local body = part(model, "Body", Vector3.new(1.1, 0.7, 3.4), CFrame.new(0, 0.45, 0), "BoneDim", "SmoothPlastic")
	part(model, "Hood", Vector3.new(0.8, 0.5, 0.8), CFrame.new(0, 0.7, -1.3), "Bone", "SmoothPlastic")
	model.PrimaryPart = body
end

local function buildHidebehind(model: Model)
	local body = part(model, "Body", Vector3.new(0.7, 6.2, 0.7), CFrame.new(0, 3.1, 0), "Void", "Basalt")
	part(model, "Crown", Vector3.new(1.1, 0.3, 1.1), CFrame.new(0, 6.3, 0), "Gold", "CorrodedMetal")
	model.PrimaryPart = body
end

local function buildWild(model: Model)
	local body = part(model, "Body", Vector3.new(1.6, 2.2, 1.3), CFrame.new(0, 1.3, 0), "Soot", "Slate")
	part(model, "Mask", Vector3.new(0.8, 0.8, 0.25), CFrame.new(0, 2.1, -0.6), "Bone", "SmoothPlastic")
	model.PrimaryPart = body
end

function CryptidModel.build(speciesId: string): Model
	local model = Instance.new("Model")
	local species = Species.get(speciesId)
	model.Name = if species ~= nil then species.displayName else "Cryptid"
	if speciesId == Species.STARTER_ID then
		buildMothman(model)
	elseif speciesId == Species.RIFT_1_ID then
		buildNightcrawler(model)
	elseif speciesId == Species.RIFT_2_ID then
		buildHidebehind(model)
	else
		buildWild(model)
	end
	model:SetAttribute("SpeciesId", speciesId)
	return model
end

return CryptidModel
