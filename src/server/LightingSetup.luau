--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local LightingSetup = {}

function LightingSetup.apply()
	local lighting = UITheme.lighting
	Lighting.Ambient = UITheme.color("Ambient")
	Lighting.OutdoorAmbient = UITheme.color("OutdoorAmbient")
	Lighting.Brightness = lighting.brightness
	Lighting.ExposureCompensation = lighting.exposureCompensation
	Lighting.ClockTime = lighting.clockTime
	Lighting.GeographicLatitude = lighting.geographicLatitude
	Lighting.GlobalShadows = lighting.globalShadows
	Lighting.FogColor = UITheme.color("Void")
	Lighting.FogStart = lighting.fogStart
	Lighting.FogEnd = lighting.fogEnd

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere == nil then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = lighting.atmosphereDensity
	atmosphere.Offset = lighting.atmosphereOffset
	atmosphere.Color = UITheme.color("Void")
	atmosphere.Decay = UITheme.color("Ash")
	atmosphere.Glare = lighting.atmosphereGlare
	atmosphere.Haze = lighting.atmosphereHaze

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
