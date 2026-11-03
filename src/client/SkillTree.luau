--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Motion = require(script.Parent:WaitForChild("Motion"))
local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Town = require(Shared:WaitForChild("Config"):WaitForChild("Town")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local SkillTree = {}

function SkillTree.mount(parent: Instance, isReduced: () -> boolean): { open: () -> () }
	local root = Instance.new("CanvasGroup")
	root.Name = "SkillTree"
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = UDim2.fromOffset(440, 220)
	root.BackgroundTransparency = 1
	root.GroupTransparency = 1
	root.Visible = false
	root.ZIndex = 6
	root.Parent = parent

	local panel = UiFactory.panel(root)
	panel.Size = UDim2.fromScale(1, 1)
	local title = UiFactory.label(panel, "display", UITheme.fonts.display.mobile, "Bone")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(16, 16)
	title.Size = UDim2.new(1, -32, 0, 36)
	title.Text = Town.SHRINE_TITLE
	local body = UiFactory.label(panel, "body", UITheme.fonts.body.desktop, "BoneDim")
	body.Name = "Body"
	body.Position = UDim2.fromOffset(16, 64)
	body.Size = UDim2.new(1, -32, 0, 80)
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.Text = Town.SHRINE_BODY
	local leave = UiFactory.button(panel, UITheme.text.minSize)
	leave.Name = "Leave"
	leave.AnchorPoint = Vector2.new(0, 1)
	leave.Position = UDim2.new(0, 16, 1, -16)
	leave.Size = UDim2.fromOffset(140, 32)
	leave.BackgroundColor3 = UITheme.color("Soot")
	leave.TextColor3 = UITheme.color("BoneDim")
	leave.Text = Town.SHRINE_LEAVE
	ThemeBind.apply(leave, "body", UITheme.text.minSize)

	local function setOpen(visible: boolean)
		if visible then
			root.Visible = true
			root.GroupTransparency = 1
			Motion.play(root, "panelOpen", isReduced(), { GroupTransparency = 0 })
			return
		end
		local plan = UITheme.resolveMotion("panelClose", isReduced())
		Motion.play(root, "panelClose", isReduced(), { GroupTransparency = 1 })
		task.delay(plan.duration, function()
			if root.GroupTransparency >= 1 then
				root.Visible = false
			end
		end)
	end

	leave.Activated:Connect(function()
		setOpen(false)
	end)

	return {
		open = function()
			setOpen(true)
		end,
	}
end

return SkillTree
