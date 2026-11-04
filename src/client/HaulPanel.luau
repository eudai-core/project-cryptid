--!strict

local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Motion = require(script.Parent:WaitForChild("Motion"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NumberFormat = require(Shared:WaitForChild("Logic"):WaitForChild("NumberFormat")) :: any
local OfferingCopy = require(Shared:WaitForChild("Logic"):WaitForChild("OfferingCopy")) :: any
local Return = require(Shared:WaitForChild("Config"):WaitForChild("Return")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local ACTION = "CryptidHaulDismiss"

local HaulPanel = {}

function HaulPanel.mount(parent: Instance, isReduced: () -> boolean, claim: () -> ())
	local backdrop = Instance.new("TextButton")
	backdrop.Name = "HaulBackdrop"
	backdrop.BackgroundColor3 = UITheme.color("Void")
	backdrop.BackgroundTransparency = 0.45
	backdrop.BorderSizePixel = 0
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.Visible = false
	backdrop.ZIndex = 30
	backdrop.Parent = parent

	local frame = UiFactory.panel(backdrop)
	frame.Name = "HaulPanel"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.ZIndex = 31
	frame.Active = true

	local title = UiFactory.label(frame, "display", UITheme.shape.haulPanel.title, "Bone")
	title.Name = "Title"
	title.Text = Return.HAUL_TITLE
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = 32

	local body = UiFactory.label(frame, "body", UITheme.shape.haulPanel.body, "Bone")
	body.Name = "Body"
	body.TextXAlignment = Enum.TextXAlignment.Center
	body.TextWrapped = true
	body.RichText = true
	body.ZIndex = 32

	local amount = UiFactory.label(frame, "number", UITheme.shape.haulPanel.amount, "GoldBright")
	amount.Name = "Haul"
	amount.Text = "+$0"
	amount.TextXAlignment = Enum.TextXAlignment.Center
	amount.ZIndex = 32

	local detail = UiFactory.label(frame, "body", UITheme.shape.haulPanel.detail, "BoneDim")
	detail.Name = "Detail"
	detail.Text = OfferingCopy.haulDetail()
	detail.TextXAlignment = Enum.TextXAlignment.Center
	detail.TextWrapped = true
	detail.ZIndex = 32

	local cap = UiFactory.label(frame, "body", UITheme.shape.haulPanel.detail, "BoneDim")
	cap.Name = "Cap"
	cap.Text = OfferingCopy.haulCap()
	cap.TextXAlignment = Enum.TextXAlignment.Center
	cap.TextWrapped = true
	cap.Visible = false
	cap.ZIndex = 32

	local button = UiFactory.button(frame, UITheme.fonts.body.desktop)
	button.Name = "Take"
	button.Text = Return.HAUL_BUTTON
	button.ZIndex = 33
	Motion.wireButton(button, function()
		return true
	end, isReduced)

	local value = Instance.new("NumberValue")
	value.Name = "HaulValue"
	value.Parent = frame
	value.Changed:Connect(function()
		amount.Text = "+" .. NumberFormat.formatCash(value.Value)
	end)

	local open = false
	local shownKey = ""

	local function setOpen(on: boolean)
		open = on
		backdrop.Visible = on
		if on then
			ContextActionService:BindActionAtPriority(ACTION, function(_name, state)
				if state == Enum.UserInputState.Begin then
					if open then
						setOpen(false)
						claim()
					end
				end
				return Enum.ContextActionResult.Sink
			end, false, UITheme.shape.escapePriority, Enum.KeyCode.Escape)
		else
			ContextActionService:UnbindAction(ACTION)
		end
	end

	local function close()
		if not open then
			return
		end
		setOpen(false)
		claim()
	end

	button.Activated:Connect(close)
	backdrop.Activated:Connect(function()
		close()
	end)

	local api = {}

	function api.isOpen(): boolean
		return open
	end

	function api.layout(mobile: boolean)
		local spec = UITheme.shape.haulPanel
		if mobile then
			frame.Size = UDim2.new(1, -UITheme.shape.screenInset * 2, 0, spec.mobileH)
		else
			frame.Size = UDim2.fromOffset(spec.desktop.w, spec.desktop.h)
		end
		local inset = UITheme.shape.screenInset
		title.Position = UDim2.fromOffset(inset, 28)
		title.Size = UDim2.new(1, -inset * 2, 0, spec.title + 8)
		body.Position = UDim2.fromOffset(inset, 28 + spec.title + 12)
		body.Size = UDim2.new(1, -inset * 2, 0, spec.body * 2)
		amount.Position = UDim2.fromOffset(inset, 28 + spec.title + spec.body * 2 + 24)
		amount.Size = UDim2.new(1, -inset * 2, 0, spec.amount + 8)
		detail.Position = UDim2.fromOffset(inset, 28 + spec.title + spec.body * 2 + spec.amount + 40)
		detail.Size = UDim2.new(1, -inset * 2, 0, spec.detail * 2)
		cap.Position = UDim2.fromOffset(inset, 28 + spec.title + spec.body * 2 + spec.amount + spec.detail * 2 + 44)
		cap.Size = UDim2.new(1, -inset * 2, 0, spec.detail * 2)
		button.AnchorPoint = Vector2.new(0.5, 1)
		button.Position = UDim2.new(0.5, 0, 1, -inset)
		button.Size = UDim2.fromOffset(spec.buttonW, UITheme.shape.touchPx)
	end

	function api.apply(haul: any)
		local pending = if type(haul) == "table" then haul.pending else nil
		local away = if type(haul) == "table" then haul.awaySeconds else nil
		local visible = type(haul) == "table"
			and haul.show == true
			and type(pending) == "number"
			and pending >= Return.SCREEN_MIN_HAUL
			and type(away) == "number"
		if not visible then
			shownKey = ""
			if open then
				setOpen(false)
			end
			return
		end
		body.Text = OfferingCopy.haulBodyRich(away :: number)
		detail.Text = OfferingCopy.haulDetail()
		cap.Text = OfferingCopy.haulCap()
		cap.Visible = haul.capped == true
		local key = tostring(pending) .. ":" .. tostring(away)
		if key ~= shownKey then
			shownKey = key
			value.Value = 0
			local plan = UITheme.resolveMotion("haulCount", isReduced())
			if not plan.allowCount or plan.duration <= 0 then
				value.Value = pending
			else
				Motion.play(value, "haulCount", isReduced(), { Value = pending })
			end
		end
		if not open then
			setOpen(true)
		end
	end

	api.layout(false)
	return api
end

return HaulPanel
