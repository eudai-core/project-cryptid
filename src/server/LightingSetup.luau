--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local LightingSetup = {}

function LightingSetup.apply()
	Lighting.Ambient = UITheme.color("Ambient")
	Lighting.OutdoorAmbient = UITheme.color("Ambient")
	Lighting.Brightness = 0.2
	Lighting.ClockTime = 1
	Lighting.GeographicLatitude = 0
	Lighting.GlobalShadows = true
	Lighting.FogColor = UITheme.color("Void")
	Lighting.FogStart = 90
	Lighting.FogEnd = 240

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere == nil then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = 0.35
	atmosphere.Offset = 0.1
	atmosphere.Color = UITheme.color("Void")
	atmosphere.Decay = UITheme.color("Ash")
	atmosphere.Glare = 0
	atmosphere.Haze = 0.8

	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate ~= nil then
		baseplate:Destroy()
	end
	local defaultSpawn = workspace:FindFirstChild("SpawnLocation")
	if defaultSpawn ~= nil and defaultSpawn:IsA("SpawnLocation") then
		defaultSpawn:Destroy()
	end
end

return LightingSetup
