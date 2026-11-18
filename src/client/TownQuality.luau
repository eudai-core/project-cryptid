--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local TownLook = require(Shared:WaitForChild("Config"):WaitForChild("TownLook")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local TownQuality = {}

local function qualityLevel(): number
	local settings = UserSettings():GetService("UserGameSettings")
	local saved = settings.SavedQualityLevel
	if typeof(saved) ~= "EnumItem" then
		return 10
	end
	return saved.Value
end

local function applyEmitter(inst: Instance, level: number)
	if not inst:IsA("ParticleEmitter") then
		return
	end
	local tier = inst:GetAttribute("TownFlame")
	if type(tier) ~= "string" then
		return
	end
	inst.Enabled = TownLook.flameTierEnabled(tier, level)
end

local function applySky(level: number)
	local sky = Lighting:FindFirstChildOfClass("Sky")
	if sky == nil then
		return
	end
	sky.StarCount = TownLook.starCount(level)
end

local function apply()
	local level = qualityLevel()
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom ~= nil then
		bloom.Enabled = TownLook.bloomEnabled(level, UITheme.lighting.bloomEnabled)
	end
	applySky(level)
	for _, inst in workspace:GetDescendants() do
		applyEmitter(inst, level)
	end
end

function TownQuality.start()
	local warned = false
	local function guard(fn: () -> ())
		local ok, err = pcall(fn)
		if not ok and not warned then
			warned = true
			warn(err)
		end
	end
	guard(apply)
	workspace.DescendantAdded:Connect(function(inst)
		guard(function()
			applyEmitter(inst, qualityLevel())
		end)
	end)
	Lighting.ChildAdded:Connect(function(inst)
		guard(function()
			if inst:IsA("Sky") then
				applySky(qualityLevel())
			end
		end)
	end)
	local settings = UserSettings():GetService("UserGameSettings")
	settings:GetPropertyChangedSignal("SavedQualityLevel"):Connect(function()
		guard(apply)
	end)
end

return TownQuality
