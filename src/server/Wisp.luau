--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Town = import("../shared/Config/Town", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Town")
end) :: any
local UITheme = import("../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any

local Wisp = {}

function Wisp.attach(parent: Instance, name: string, cf: CFrame)
	local spec = Town.WISP
	local host = Instance.new("Part")
	host.Name = name
	host.Anchored = true
	host.CanCollide = false
	host.CanTouch = false
	host.CanQuery = false
	host.CastShadow = false
	host.Transparency = 1
	host.Size = Vector3.new(1, 1, 1)
	host.CFrame = cf
	host.Parent = parent
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Wisp"
	emitter.Rate = spec.rate
	emitter.Lifetime = NumberRange.new(spec.lifetimeMin, spec.lifetimeMax)
	emitter.Speed = NumberRange.new(spec.speedMin, spec.speedMax)
	emitter.SpreadAngle = Vector2.new(spec.spread, spec.spread)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-spec.rotSpeed, spec.rotSpeed)
	emitter.Acceleration = Vector3.new(0, spec.speedMin, 0)
	emitter.LightInfluence = 0
	emitter.Size = NumberSequence.new(spec.size)
	emitter.Transparency = NumberSequence.new(spec.transparency)
	emitter.Color = ColorSequence.new(UITheme.color(spec.color))
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter:SetAttribute("TownEffect", name)
	emitter.Parent = host
end

return Wisp
