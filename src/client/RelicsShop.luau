--!strict

local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Motion = require(script.Parent:WaitForChild("Motion"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetisation = require(Shared:WaitForChild("Config"):WaitForChild("Monetisation")) :: any
local RelicsCopy = require(Shared:WaitForChild("Logic"):WaitForChild("RelicsCopy")) :: any
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local ACTION = "CryptidRelicsDismiss"
local player = Players.LocalPlayer

local RelicsShop = {}

function RelicsShop.mount(parent: Instance, isReduced: () -> boolean, onOpen: () -> (), onBuy: (string) -> ())
	local hud = Plots.RETURN_BUTTON
	local spec = UITheme.shape.relicsPanel
	local button = UiFactory.button(parent, UITheme.text.minSize)
	button.Name = "Relics"
	button.Text = RelicsCopy.BUTTON
	button.AnchorPoint = Vector2.new(1, 0)
	button.Position = UDim2.new(1, -UITheme.shape.screenInset, 0, UITheme.shape.screenInset)
	button.Size = UDim2.fromOffset(hud.width, hud.height)
	button.BackgroundColor3 = UITheme.color("Ash")
	button.TextColor3 = UITheme.color("Gold")
	button.Visible = false
	button.ZIndex = 6

	local pip = Instance.new("Frame")
	pip.Name = "Pip"
	pip.AnchorPoint = Vector2.new(1, 0)
	local pipSize = UITheme.shape.relicsPip
	pip.Position = UDim2.new(1, -UITheme.shape.plaqueGapPx, 0, UITheme.shape.plaqueGapPx)
	pip.Size = UDim2.fromOffset(pipSize, pipSize)
	pip.BackgroundColor3 = UITheme.color("GoldBright")
	pip.BorderSizePixel = 0
	pip.Visible = false
	pip.ZIndex = 7
	pip.Parent = button
	UiFactory.corner(pip)
	local pipScale = Instance.new("UIScale")
	pipScale.Name = "Pulse"
	pipScale.Parent = pip

	local backdrop = Instance.new("TextButton")
	backdrop.Name = "RelicsBackdrop"
	backdrop.BackgroundColor3 = UITheme.color("Void")
	backdrop.BackgroundTransparency = 0.45
	backdrop.BorderSizePixel = 0
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.Visible = false
	backdrop.ZIndex = 40
	backdrop.Parent = parent

	local frame = UiFactory.panel(backdrop)
	frame.Name = "RelicsPanel"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.ZIndex = 41

	local title = UiFactory.label(frame, "header", spec.title, "Gold")
	title.Name = "Title"
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = 42

	local sub = UiFactory.label(frame, "body", spec.detail, "BoneDim")
	sub.Name = "Sub"
	sub.TextXAlignment = Enum.TextXAlignment.Center
	sub.TextWrapped = true
	sub.ZIndex = 42

	local spend = UiFactory.label(frame, "body", spec.detail, "BoneDim")
	spend.Name = "Spend"
	spend.TextXAlignment = Enum.TextXAlignment.Center
	spend.ZIndex = 42

	local scroller = Instance.new("ScrollingFrame")
	scroller.Name = "Cards"
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.ScrollBarThickness = UITheme.shape.strokePx
	scroller.ScrollBarImageColor3 = UITheme.color("Gold")
	scroller.CanvasSize = UDim2.fromOffset(0, 0)
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.ZIndex = 42
	scroller.Parent = frame
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, UITheme.shape.plaqueGapPx)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = scroller

	local open = false
	local latest: any = nil
	local generation = 0
	local pipLatched = false
	local sawSnapshot = false
	local pads: { [BasePart]: BillboardGui } = {}

	local function setOpen(nextOpen: boolean)
		open = nextOpen and latest ~= nil and latest.visible == true
		backdrop.Visible = open
		if open then
			ContextActionService:BindActionAtPriority(ACTION, function(_name, state)
				if state == Enum.UserInputState.Begin then
					setOpen(false)
				end
				return Enum.ContextActionResult.Sink
			end, false, UITheme.shape.relicsEscape, Enum.KeyCode.Escape)
		else
			ContextActionService:UnbindAction(ACTION)
		end
	end

	local function showPip()
		pip.Visible = true
		pipLatched = true
		local motion = UITheme.motion.relicsPip
		local plan = UITheme.resolveMotion("relicsPip", isReduced())
		pipScale.Scale = 1
		if plan.duration <= 0 or plan.allowScale ~= true then
			return
		end
		local function beat(left: number)
			if left <= 0 or pip.Visible ~= true then
				pipScale.Scale = 1
				return
			end
			local grow = Motion.play(pipScale, "relicsPip", isReduced(), { Scale = motion.scale })
			local function shrink()
				local back = Motion.play(pipScale, "relicsPip", isReduced(), { Scale = 1 })
				if back == nil then
					beat(left - 1)
					return
				end
				back.Completed:Connect(function()
					beat(left - 1)
				end)
			end
			if grow == nil then
				shrink()
				return
			end
			grow.Completed:Connect(shrink)
		end
		beat(motion.pulses)
	end

	local function paintCards()
		for _, child in scroller:GetChildren() do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		if latest == nil or type(latest.cards) ~= "table" then
			return
		end
		for index, card in latest.cards do
			local row = UiFactory.panel(scroller)
			row.LayoutOrder = index
			row.Size = UDim2.new(1, 0, 0, spec.cardH)
			row.ZIndex = 43
			local line = UiFactory.label(row, "body", spec.body, "Bone")
			line.Text = card.line
			line.TextWrapped = true
			line.Position = UDim2.fromOffset(UITheme.shape.plaqueGapPx, UITheme.shape.plaqueGapPx)
			line.Size = UDim2.new(1, -(spec.buttonW + UITheme.shape.plaqueGapPx * 3), 1, -UITheme.shape.plaqueGapPx * 2)
			line.ZIndex = 44
			if card.owned == true then
				local owned = UiFactory.label(row, "body", spec.body, "Moss")
				owned.Text = latest.ownedLabel
				owned.AnchorPoint = Vector2.new(1, 0.5)
				owned.Position = UDim2.new(1, -UITheme.shape.plaqueGapPx, 0.5, 0)
				owned.Size = UDim2.fromOffset(spec.buttonW, UITheme.shape.touchPx)
				owned.TextXAlignment = Enum.TextXAlignment.Center
				owned.ZIndex = 44
			elseif type(card.button) == "string" and card.button ~= "" then
				local buy = UiFactory.button(row, UITheme.text.minSize)
				buy.Text = card.button
				buy.BackgroundColor3 = UITheme.color("Ash")
				buy.TextColor3 = UITheme.color("Gold")
				buy.AnchorPoint = Vector2.new(1, 0.5)
				buy.Position = UDim2.new(1, -UITheme.shape.plaqueGapPx, 0.5, 0)
				buy.Size = UDim2.fromOffset(spec.buttonW, UITheme.shape.touchPx)
				buy.ZIndex = 44
				local key = card.key
				buy.Activated:Connect(function()
					if type(key) == "string" then
						onBuy(key)
					end
				end)
			end
		end
	end

	local function refreshPads()
		local show = latest ~= nil and latest.visible == true and latest.extraPadsOwned ~= true
		for _, gui in pads do
			gui.Enabled = show
			local label = gui:FindFirstChild("Line", true)
			local action = gui:FindFirstChild("Open", true)
			if label ~= nil and label:IsA("TextLabel") and latest ~= nil then
				label.Text = latest.padLine
			end
			if action ~= nil and action:IsA("TextButton") and latest ~= nil then
				action.Text = latest.padButton
			end
		end
	end

	local function ensurePad(part: BasePart)
		if pads[part] ~= nil or part:GetAttribute("RelicPad") ~= true then
			return
		end
		if part:GetAttribute("OwnerUserId") ~= player.UserId then
			return
		end
		local gui = Instance.new("BillboardGui")
		gui.Name = "RelicPad"
		gui.Size = UDim2.fromOffset(spec.padW, spec.padH)
		gui.StudsOffset = Vector3.new(0, UITheme.shape.plaqueTopPx / 8, 0)
		gui.AlwaysOnTop = false
		gui.LightInfluence = 0
		gui.MaxDistance = Plots.BANNER_MAX_DISTANCE
		gui.Enabled = false
		gui.ResetOnSpawn = false
		gui.Parent = part
		local plate = UiFactory.panel(gui)
		plate.Size = UDim2.fromScale(1, 1)
		local label = UiFactory.label(plate, "body", UITheme.text.minSize, "Bone")
		label.Name = "Line"
		label.Size = UDim2.new(1, 0, 0.5, 0)
		label.TextXAlignment = Enum.TextXAlignment.Center
		local action = UiFactory.button(plate, UITheme.text.minSize)
		action.Name = "Open"
		action.BackgroundColor3 = UITheme.color("Ash")
		action.TextColor3 = UITheme.color("Gold")
		action.Size = UDim2.new(1, -UITheme.shape.plaqueGapPx * 2, 0.5, -UITheme.shape.plaqueGapPx)
		action.Position = UDim2.new(0, UITheme.shape.plaqueGapPx, 0.5, 0)
		action.Activated:Connect(function()
			onOpen()
			setOpen(true)
		end)
		pads[part] = gui
	end

	local function scanPads()
		for _, inst in CollectionService:GetTagged("CryptidPad") do
			if inst:IsA("BasePart") then
				ensurePad(inst)
			end
		end
		refreshPads()
	end

	local api = {}

	function api.apply(relics: any)
		latest = if type(relics) == "table" then relics else nil
		local visible = latest ~= nil and latest.visible == true
		button.Visible = visible
		if latest ~= nil then
			button.Text = latest.button
			title.Text = latest.header
			sub.Text = latest.sub
			spend.Text = latest.spend
		end
		if not visible then
			generation += 1
			pip.Visible = false
			pipLatched = false
			setOpen(false)
			refreshPads()
			sawSnapshot = true
			return
		end
		paintCards()
		refreshPads()
		local wantPip = latest.pip == true
		if wantPip and not pipLatched then
			generation += 1
			local token = generation
			local waitFor = if sawSnapshot then Monetisation.RARE_REVEAL_SECONDS else 0
			task.delay(waitFor, function()
				if token ~= generation or latest == nil or latest.pip ~= true then
					return
				end
				showPip()
			end)
		elseif not wantPip then
			generation += 1
			pip.Visible = false
			pipLatched = false
		end
		sawSnapshot = true
	end

	function api.layout(mobile: boolean)
		local width = spec.desktop.w
		local height = if mobile then spec.mobileH else spec.desktop.h
		frame.Size = UDim2.fromOffset(width, height)
		local pad = UITheme.shape.plaqueGapPx
		title.Position = UDim2.fromOffset(pad, pad)
		title.Size = UDim2.new(1, -pad * 2, 0, spec.title)
		sub.Position = UDim2.fromOffset(pad, pad + spec.title)
		sub.Size = UDim2.new(1, -pad * 2, 0, spec.body * 2)
		spend.Position = UDim2.new(0, pad, 1, -(spec.body + pad))
		spend.Size = UDim2.new(1, -pad * 2, 0, spec.body)
		local listTop = pad + spec.title + spec.body * 2 + pad
		scroller.Position = UDim2.fromOffset(pad, listTop)
		scroller.Size = UDim2.new(1, -pad * 2, 1, -(listTop + spec.body + pad * 2))
	end

	function api.isOpen(): boolean
		return open
	end

	button.Activated:Connect(function()
		local nextOpen = not open
		setOpen(nextOpen)
		if nextOpen then
			onOpen()
		end
	end)
	backdrop.Activated:Connect(function()
		setOpen(false)
	end)
	frame.Active = true

	scanPads()
	CollectionService:GetInstanceAddedSignal("CryptidPad"):Connect(function(inst)
		if inst:IsA("BasePart") then
			ensurePad(inst)
			refreshPads()
		end
	end)

	return api
end

return RelicsShop
