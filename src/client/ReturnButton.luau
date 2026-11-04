--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local HudSlots = require(Shared:WaitForChild("Logic"):WaitForChild("HudSlots")) :: any
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local ReturnButton = {}

function ReturnButton.mount(parent: Instance, fire: () -> ()): TextButton
	local button = UiFactory.button(parent, UITheme.text.minSize)
	local hud = Plots.RETURN_BUTTON
	button.Name = "ReturnToLair"
	button.Text = Plots.RETURN_LABEL
	button.AnchorPoint = Vector2.new(0, 1)
	button.Position = UDim2.new(0, HudSlots.origin(0), 1, -hud.margin)
	button.Size = UDim2.fromOffset(hud.width, hud.height)
	button.BackgroundColor3 = UITheme.color("Soot")
	button.TextColor3 = UITheme.color("Bone")
	local cooling = false
	button.Activated:Connect(function()
		if cooling then
			return
		end
		cooling = true
		button.TextColor3 = UITheme.color("BoneDim")
		fire()
		task.delay(Plots.RETURN_COOLDOWN_SECONDS, function()
			cooling = false
			button.TextColor3 = UITheme.color("Bone")
		end)
	end)
	return button
end

return ReturnButton
