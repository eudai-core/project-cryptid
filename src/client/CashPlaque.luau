--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Motion = require(script.Parent:WaitForChild("Motion"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NumberFormat = require(Shared:WaitForChild("Logic"):WaitForChild("NumberFormat")) :: any
local OfferingCopy = require(Shared:WaitForChild("Logic"):WaitForChild("OfferingCopy")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local CashPlaque = {}

function CashPlaque.mount(parent: Instance, isReduced: () -> boolean)
	local frame = UiFactory.panel(parent)
	frame.Name = "CashPlaque"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	local stroke = frame:FindFirstChildOfClass("UIStroke")
	if stroke ~= nil then
		stroke.Thickness = UITheme.shape.plaqueStrokePx
		stroke.Transparency = 0
	end

	local sigil = UiFactory.label(frame, "sigil", UITheme.fonts.header.desktop, "Gold")
	sigil.Name = "Sigil"
	sigil.Text = UITheme.sigil
	sigil.TextXAlignment = Enum.TextXAlignment.Center

	local cash = UiFactory.label(frame, "number", UITheme.fonts.number.plaqueDesktop, "GoldBright")
	cash.Name = "Cash"
	cash.Text = "$0"

	local income = UiFactory.label(frame, "income", UITheme.fonts.income.desktop, "BoneDim")
	income.Name = "Income"
	income.Text = "+$0/s"

	local bowl = UiFactory.label(frame, "body", UITheme.text.minSize, "BoneDim")
	bowl.Name = "Bowl"
	bowl.Text = ""
	bowl.Visible = false

	local floats = Instance.new("Frame")
	floats.Name = "Floats"
	floats.BackgroundTransparency = 1
	floats.BorderSizePixel = 0
	floats.Size = UDim2.fromScale(1, 1)
	floats.ZIndex = 3
	floats.Parent = frame

	local shown = 0
	local lastFloated = -1
	local mobileLayout = false
	local bowlAmount = 0
	local value = Instance.new("NumberValue")
	value.Value = 0
	value.Parent = frame
	local active: Tween? = nil

	value.Changed:Connect(function()
		cash.Text = NumberFormat.formatCash(value.Value)
	end)

	local pulseOn = false
	task.spawn(function()
		while frame.Parent ~= nil do
			task.wait(0.05)
			if stroke == nil or not pulseOn or isReduced() then
				if stroke ~= nil then
					stroke.Transparency = 0
					stroke.Color = UITheme.color("Gold")
				end
			else
				local wave = (math.sin(os.clock() * math.pi) + 1) / 2
				stroke.Transparency = wave * 0.45
			end
		end
	end)

	local function spawnFloat(amount: number)
		local plan = UITheme.resolveMotion("incomeFloat", isReduced())
		if not plan.allowFloat or plan.duration <= 0 or amount <= 0 then
			return
		end
		local floater = UiFactory.label(floats, "income", UITheme.fonts.income.desktop, "GoldBright")
		floater.Text = "+" .. NumberFormat.formatCash(amount)
		floater.AnchorPoint = Vector2.new(0.5, 0.5)
		floater.Position = UDim2.fromScale(0.72, 0.45)
		floater.Size = UDim2.fromOffset(140, 24)
		floater.TextXAlignment = Enum.TextXAlignment.Right
		floater.ZIndex = 4
		local offset = UITheme.motion.incomeFloat.offset or 20
		Motion.play(floater, "incomeFloat", false, {
			Position = UDim2.new(0.72, 0, 0.45, -offset),
			TextTransparency = 1,
		})
		task.delay(plan.duration, function()
			floater:Destroy()
		end)
	end

	local api = {}

	function api.layout(mobile: boolean): number
		mobileLayout = mobile
		local size = if mobile then UITheme.shape.plaqueSize.mobile else UITheme.shape.plaqueSize.desktop
		local extra = if bowlAmount > 0 then UITheme.shape.plaqueBowlPx else 0
		local height = size.h + extra
		frame.Size = UDim2.fromOffset(size.w, height)
		frame.Position = UDim2.new(0.5, 0, 0, UITheme.shape.plaqueTopPx)
		local numberSize = if mobile then UITheme.fonts.number.plaqueMobile else UITheme.fonts.number.plaqueDesktop
		local incomeSize = if mobile then UITheme.fonts.income.mobile else UITheme.fonts.income.desktop
		local pad = if mobile then 8 else 12
		sigil.Position = UDim2.fromOffset(4, 0)
		sigil.Size = UDim2.new(0, 36, 1, 0)
		cash.Position = UDim2.fromOffset(44, pad)
		cash.Size = UDim2.new(1, -56, 0, numberSize + 2)
		income.Position = UDim2.fromOffset(44, pad + numberSize)
		income.Size = UDim2.new(1, -56, 0, incomeSize + 2)
		bowl.Position = UDim2.fromOffset(44, pad + numberSize + incomeSize + 2)
		bowl.Size = UDim2.new(1, -56, 0, UITheme.text.minSize + 2)
		bowl.Visible = bowlAmount > 0
		if bowlAmount > 0 then
			bowl.Text = OfferingCopy.bowlLine(bowlAmount)
		end
		local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
		ThemeBind.apply(sigil, "sigil", numberSize)
		ThemeBind.apply(cash, "number", numberSize)
		ThemeBind.apply(income, "income", incomeSize)
		ThemeBind.apply(bowl, "body", UITheme.text.minSize)
		return height
	end

	function api.apply(
		cashValue: number,
		incomeValue: number,
		credit: number,
		revision: number,
		step: number,
		bowlValue: number?
	)
		income.Text = NumberFormat.formatRate(incomeValue)
		pulseOn = step == 1
		local previous = shown
		local denom = math.max(math.abs(previous), 1)
		local fraction = math.abs(cashValue - previous) / denom
		local plan = UITheme.resolveMotion("cashCount", isReduced())
		local skipFraction = UITheme.motion.cashCount.skipUnderFraction or 0
		if active ~= nil then
			active:Cancel()
			active = nil
		end
		if not plan.allowCount or plan.duration <= 0 or fraction < skipFraction then
			value.Value = cashValue
		else
			active = Motion.play(value, "cashCount", isReduced(), { Value = cashValue })
		end
		shown = cashValue
		if credit > 0 and revision ~= lastFloated then
			spawnFloat(credit)
			lastFloated = revision
		end
		local nextBowl = bowlValue
		if type(nextBowl) ~= "number" or nextBowl ~= nextBowl or nextBowl < 0 then
			nextBowl = 0
		end
		if nextBowl ~= bowlAmount then
			bowlAmount = nextBowl
			api.layout(mobileLayout)
		end
	end

	api.layout(false)
	return api
end

return CashPlaque
