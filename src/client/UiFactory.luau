--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local UiFactory = {}

function UiFactory.corner(parent: GuiObject)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, UITheme.shape.cornerPx)
	corner.Parent = parent
end

function UiFactory.stroke(parent: GuiObject, token: string, thickness: number, transparency: number): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = UITheme.color(token)
	stroke.Thickness = thickness
	stroke.Transparency = transparency
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

function UiFactory.panel(parent: Instance): Frame
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = UITheme.color("Ash")
	frame.BorderSizePixel = 0
	frame.Parent = parent
	UiFactory.corner(frame)
	UiFactory.stroke(frame, "Gold", UITheme.shape.strokePx, UITheme.shape.strokeTransparency)
	return frame
end

function UiFactory.label(parent: Instance, role: string, size: number, colorToken: string): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.TextColor3 = UITheme.color(colorToken)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextWrapped = false
	label.RichText = false
	label.Parent = parent
	ThemeBind.apply(label, role, size)
	return label
end

function UiFactory.button(parent: Instance, size: number): TextButton
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	button.BackgroundColor3 = UITheme.color("Blood")
	button.TextColor3 = UITheme.color("Bone")
	button.RichText = false
	button.TextWrapped = true
	button.Parent = parent
	UiFactory.corner(button)
	UiFactory.stroke(button, "Gold", UITheme.shape.strokePx, 0)
	ThemeBind.apply(button, "body", size)
	return button
end

return UiFactory
