--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local SealToast = {}

function SealToast.mount(parent: Instance, player: Player)
	local label = Instance.new("TextLabel")
	label.Name = "SealToast"
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = UDim2.new(0.5, 0, 0, Plots.TOAST_TOP)
	label.Size = UDim2.fromOffset(440, 28)
	label.BackgroundTransparency = 1
	label.Text = Plots.SEAL_TOAST
	label.TextColor3 = UITheme.color("BoneDim")
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Visible = false
	label.Parent = parent
	ThemeBind.apply(label, "body", UITheme.fonts.body.mobile)
	local token = 0
	player:GetAttributeChangedSignal("SealPulse"):Connect(function()
		token += 1
		local shown = token
		label.Visible = true
		task.delay(Plots.TOAST_SECONDS, function()
			if token == shown then
				label.Visible = false
			end
		end)
	end)
end

return SealToast
