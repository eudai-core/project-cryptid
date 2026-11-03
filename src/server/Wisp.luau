--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Town = require(Shared:WaitForChild("Config"):WaitForChild("Town")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

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
	emitter.Parent = host
end

return Wisp
