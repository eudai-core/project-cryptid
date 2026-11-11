--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Lanterns = import("../shared/Config/Lanterns", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Lanterns")
end) :: any
local UITheme = import("../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any

local RiftGlow = {}

function RiftGlow.attach(host: BasePart, running: boolean, withLight: boolean): ParticleEmitter
	if withLight then
		local light = Instance.new("PointLight")
		light.Name = "RiftLight"
		light.Color = UITheme.color(Lanterns.RIFT_SURFACE)
		light.Brightness = Lanterns.RIFT_LIGHT_BRIGHTNESS
		light.Range = Lanterns.RIFT_LIGHT_RANGE
		light.Shadows = Lanterns.RIFT_LIGHT_SHADOWS
		light.Parent = host
	end
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "RiftMotes"
	emitter.Color = ColorSequence.new(UITheme.color(Lanterns.RIFT_PARTICLE_COLOR))
	emitter.Rate = Lanterns.RIFT_PARTICLE_RATE
	emitter.Lifetime = NumberRange.new(Lanterns.RIFT_PARTICLE_LIFETIME, Lanterns.RIFT_PARTICLE_LIFETIME)
	emitter.Speed = NumberRange.new(Lanterns.RIFT_PARTICLE_SPEED, Lanterns.RIFT_PARTICLE_SPEED)
	emitter.Size = NumberSequence.new(Lanterns.RIFT_PARTICLE_SIZE)
	emitter.Transparency = NumberSequence.new(Lanterns.RIFT_PARTICLE_TRANSPARENCY)
	emitter.LightInfluence = 0
	emitter.Enabled = running
	emitter.Parent = host
	return emitter
end

return RiftGlow
