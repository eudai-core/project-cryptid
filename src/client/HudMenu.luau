--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local HudMenu = {}

function HudMenu.mount(parent: Instance, onCalm: () -> (), controls: any)
	local menuSpec = UITheme.shape.hudMenu
	local touch = UITheme.shape.touchPx
	local gap = UITheme.shape.plaqueGapPx
	local root = Instance.new("Frame")
	root.Name = "HudMenu"
	root.BackgroundTransparency = 1
	root.BorderSizePixel = 0
	root.Size = UDim2.fromOffset(menuSpec.sheetW, touch)
	root.Position = UDim2.fromOffset(UITheme.shape.screenInset, gap)
	root.ZIndex = 5
	root.Parent = parent

	local menu = UiFactory.button(root, UITheme.text.minSize)
	menu.Name = "Menu"
	menu.Text = UITheme.copy.menu
	menu.Size = UDim2.fromOffset(menuSpec.buttonW, touch)
	menu.Position = UDim2.fromOffset(0, 0)
	menu.BackgroundColor3 = UITheme.color("Soot")
	menu.TextColor3 = UITheme.color("Bone")
	menu.ZIndex = 6

	local pip = Instance.new("Frame")
	pip.Name = "OfferingPip"
	pip.AnchorPoint = Vector2.new(1, 0)
	local pipSize = UITheme.shape.offeringPip
	pip.Position = UDim2.new(1, -UITheme.shape.plaqueGapPx / 2, 0, UITheme.shape.plaqueGapPx / 2)
	pip.Size = UDim2.fromOffset(pipSize, pipSize)
	pip.BackgroundColor3 = UITheme.color("Gold")
	pip.BorderSizePixel = 0
	pip.Visible = false
	pip.ZIndex = 7
	pip.Parent = menu
	UiFactory.corner(pip)

	local sheet = UiFactory.panel(root)
	sheet.Name = "Sheet"
	sheet.Position = UDim2.fromOffset(0, touch + gap)
	sheet.Size = UDim2.fromOffset(menuSpec.sheetW, 0)
	sheet.AutomaticSize = Enum.AutomaticSize.Y
	sheet.Visible = false
	sheet.ZIndex = 6
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, gap)
	padding.PaddingBottom = UDim.new(0, gap)
	padding.PaddingLeft = UDim.new(0, gap)
	padding.PaddingRight = UDim.new(0, gap)
	padding.Parent = sheet
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, gap)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = sheet

	local stash = Instance.new("Frame")
	stash.Name = "Stash"
	stash.Visible = false
	stash.BackgroundTransparency = 1
	stash.Size = UDim2.fromOffset(0, 0)
	stash.Parent = root

	local function adopt(button: TextButton, order: number)
		button.AnchorPoint = Vector2.new(0, 0)
		button.Position = UDim2.fromOffset(0, 0)
		button.Size = UDim2.new(1, 0, 0, touch)
		button.LayoutOrder = order
		button.ZIndex = 7
		local function place()
			button.Parent = if button.Visible then sheet else stash
			if button.Visible then
				button.Size = UDim2.new(1, 0, 0, touch)
			end
		end
		button:GetPropertyChangedSignal("Visible"):Connect(place)
		place()
	end

	adopt(controls.offeringButton, 1)
	adopt(controls.returnButton, 2)

	local calm = UiFactory.button(sheet, UITheme.text.minSize)
	calm.Name = "CalmMotion"
	calm.LayoutOrder = 3
	calm.Size = UDim2.new(1, 0, 0, touch)
	calm.BackgroundColor3 = UITheme.color("Soot")
	calm.TextColor3 = UITheme.color("Bone")
	calm.Text = UITheme.copy.calmOff
	calm.ZIndex = 7

	local reason = UiFactory.label(sheet, "body", UITheme.text.minSize, "BoneDim")
	reason.Name = "CalmReason"
	reason.LayoutOrder = 4
	reason.Size = UDim2.new(1, 0, 0, UITheme.text.minSize * menuSpec.reasonLines)
	reason.TextWrapped = true
	reason.Text = UITheme.copy.calmReason
	reason.ZIndex = 7

	adopt(controls.rites, 5)

	local open = false
	local function setOpen(on: boolean)
		open = on
		sheet.Visible = on
	end

	menu.Activated:Connect(function()
		setOpen(not open)
	end)
	local function closeSheet()
		setOpen(false)
	end
	controls.offeringButton.Activated:Connect(closeSheet)
	controls.returnButton.Activated:Connect(closeSheet)
	controls.rites.Activated:Connect(closeSheet)
	calm.Activated:Connect(function()
		onCalm()
	end)

	local function mirrorPip()
		local offeringOn = controls.offeringButton.Visible and controls.offeringPip.Visible
		pip.Visible = offeringOn
	end
	controls.offeringButton:GetPropertyChangedSignal("Visible"):Connect(mirrorPip)
	controls.offeringPip:GetPropertyChangedSignal("Visible"):Connect(mirrorPip)

	local api = {}

	function api.layout(bannerHeight: number)
		root.Position = UDim2.fromOffset(UITheme.shape.screenInset, bannerHeight + gap)
	end

	function api.setCalm(on: boolean)
		calm.Text = if on then UITheme.copy.calmOn else UITheme.copy.calmOff
		calm.TextColor3 = UITheme.color("Bone")
	end

	return api
end

return HudMenu
