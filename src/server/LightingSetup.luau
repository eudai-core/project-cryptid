--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local UITheme = import("../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any

local TownLook = import("../shared/Config/TownLook", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("TownLook")
end) :: any

local LightingSetup = {}

local function effect(lighting: Instance, className: string): any
	local existing = lighting:FindFirstChildOfClass(className)
	if existing == nil then
		existing = Instance.new(className)
		existing.Parent = lighting
	end
	return existing
end

function LightingSetup.apply()
	local Lighting = game:GetService("Lighting")
	local lighting = UITheme.lighting
	Lighting.Ambient = Color3.fromHex(TownLook.SKY_AMBIENT)
	Lighting.OutdoorAmbient = Color3.fromHex(TownLook.SKY_OUTDOOR_AMBIENT)
	Lighting.ColorShift_Top = Color3.fromHex(TownLook.SKY_COLOR_SHIFT_TOP)
	Lighting.Brightness = lighting.brightness
	Lighting.ExposureCompensation = lighting.exposureCompensation
	Lighting.ClockTime = lighting.clockTime
	Lighting.GeographicLatitude = lighting.geographicLatitude
	Lighting.GlobalShadows = lighting.globalShadows
	Lighting.FogColor = UITheme.color(lighting.fogColor)
	Lighting.FogStart = lighting.fogStart
	Lighting.FogEnd = lighting.fogEnd

	local atmosphere = effect(Lighting, "Atmosphere")
	atmosphere.Density = TownLook.SKY_ATMOSPHERE_DENSITY
	atmosphere.Offset = lighting.atmosphereOffset
	atmosphere.Color = Color3.fromHex(TownLook.SKY_ATMOSPHERE_COLOR)
	atmosphere.Decay = Color3.fromHex(TownLook.SKY_ATMOSPHERE_DECAY)
	atmosphere.Glare = TownLook.SKY_ATMOSPHERE_GLARE
	atmosphere.Haze = TownLook.SKY_ATMOSPHERE_HAZE

	local bloom = effect(Lighting, "BloomEffect")
	bloom.Name = "TownBloom"
	bloom.Enabled = lighting.bloomEnabled
	bloom.Intensity = lighting.bloomIntensity
	bloom.Size = lighting.bloomSize
	bloom.Threshold = lighting.bloomThreshold

	local grade = effect(Lighting, "ColorCorrectionEffect")
	grade.Name = "TownGrade"
	grade.Enabled = true
	grade.Saturation = TownLook.SKY_GRADE_SATURATION
	grade.Contrast = lighting.colorContrast
	grade.Brightness = lighting.colorBrightness
	grade.TintColor = Color3.fromHex(TownLook.SKY_GRADE_TINT)

	local sky = effect(Lighting, "Sky")
	sky.Name = "HollowmereSky"
	local face = TownLook.SKYBOX_FACE
	sky.SkyboxBk = face.bk
	sky.SkyboxDn = face.dn
	sky.SkyboxFt = face.ft
	sky.SkyboxLf = face.lf
	sky.SkyboxRt = face.rt
	sky.SkyboxUp = face.up
	sky.StarCount = TownLook.SKY_STAR_COUNT
	sky.SunAngularSize = TownLook.SKY_SUN_ANGULAR_SIZE
	sky.MoonAngularSize = TownLook.SKY_MOON_ANGULAR_SIZE
	sky.CelestialBodiesShown = TownLook.SKY_CELESTIAL_BODIES_SHOWN

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
