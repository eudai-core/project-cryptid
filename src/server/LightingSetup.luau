--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local LightingSetup = {}

function LightingSetup.apply()
	local lighting = UITheme.lighting
	Lighting.Ambient = UITheme.color(lighting.ambient)
	Lighting.OutdoorAmbient = UITheme.color(lighting.outdoorAmbient)
	Lighting.Brightness = lighting.brightness
	Lighting.ExposureCompensation = lighting.exposureCompensation
	Lighting.ClockTime = lighting.clockTime
	Lighting.GeographicLatitude = lighting.geographicLatitude
	Lighting.GlobalShadows = lighting.globalShadows
	Lighting.FogColor = UITheme.color(lighting.fogColor)
	Lighting.FogStart = lighting.fogStart
	Lighting.FogEnd = lighting.fogEnd

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere == nil then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = lighting.atmosphereDensity
	atmosphere.Offset = lighting.atmosphereOffset
	atmosphere.Color = UITheme.color(lighting.atmosphereColor)
	atmosphere.Decay = UITheme.color(lighting.atmosphereDecay)
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
