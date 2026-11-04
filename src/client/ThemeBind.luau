--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local ThemeBind = {}

function ThemeBind.apply(label: TextLabel | TextButton, role: string, size: number)
	local spec = UITheme.fonts[role]
	local textSize = math.max(size, UITheme.text.minSize)
	label.TextScaled = UITheme.text.scaled
	label.TextSize = textSize
	label.Font = Enum.Font[spec.family]
	if spec.weight == "Bold" then
		local ok, face = pcall(function()
			return Font.fromEnum(Enum.Font[spec.family])
		end)
		if ok and face ~= nil then
			label.FontFace = Font.new(face.Family, Enum.FontWeight.Bold, face.Style)
		end
	end
	local constraint = label:FindFirstChildOfClass("UITextSizeConstraint")
	if constraint == nil then
		constraint = Instance.new("UITextSizeConstraint")
		constraint.Parent = label
	end
	constraint.MaxTextSize = textSize
	constraint.MinTextSize = UITheme.text.minSize
end

return ThemeBind
