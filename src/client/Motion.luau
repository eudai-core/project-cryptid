--!strict

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local STYLES = {
	Linear = Enum.EasingStyle.Linear,
	Quad = Enum.EasingStyle.Quad,
	Back = Enum.EasingStyle.Back,
}
local DIRECTIONS = {
	In = Enum.EasingDirection.In,
	Out = Enum.EasingDirection.Out,
}

local Motion = {}

function Motion.play(instance: Instance, eventName: string, reduced: boolean, goals: { [string]: any }): Tween?
	local plan = UITheme.resolveMotion(eventName, reduced)
	local event = UITheme.motion[eventName]
	if plan.duration <= 0 then
		for property, value in goals do
			(instance :: any)[property] = value
		end
		return nil
	end
	local info = TweenInfo.new(plan.duration, STYLES[event.easing], DIRECTIONS[event.direction])
	local tween = TweenService:Create(instance :: any, info, goals)
	tween:Play()
	return tween
end

function Motion.wireButton(button: TextButton, isEnabled: () -> boolean, isReduced: () -> boolean)
	local scale = Instance.new("UIScale")
	scale.Name = "PressScale"
	scale.Parent = button
	local base = UITheme.color("Blood")
	local hover = UITheme.color("BloodHover")

	button.MouseEnter:Connect(function()
		if not isEnabled() then
			return
		end
		Motion.play(button, "buttonHover", isReduced(), { BackgroundColor3 = hover })
	end)
	button.MouseLeave:Connect(function()
		if not isEnabled() then
			return
		end
		Motion.play(button, "buttonHover", isReduced(), { BackgroundColor3 = base })
	end)
	button.MouseButton1Down:Connect(function()
		if not isEnabled() then
			return
		end
		local plan = UITheme.resolveMotion("buttonPress", isReduced())
		local pressed = UITheme.motion.buttonPress.scale
		if not plan.allowScale or plan.duration <= 0 or type(pressed) ~= "number" then
			scale.Scale = 1
			return
		end
		local down = TweenService:Create(
			scale,
			TweenInfo.new(plan.duration * 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Scale = pressed }
		)
		down.Completed:Connect(function()
			TweenService:Create(
				scale,
				TweenInfo.new(plan.duration * 0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Scale = 1 }
			):Play()
		end)
		down:Play()
	end)
end

return Motion
