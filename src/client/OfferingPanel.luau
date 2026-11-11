--!strict

local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Motion = require(script.Parent:WaitForChild("Motion"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NumberFormat = require(Shared:WaitForChild("Logic"):WaitForChild("NumberFormat")) :: any
local OfferingCopy = require(Shared:WaitForChild("Logic"):WaitForChild("OfferingCopy")) :: any
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local Return = require(Shared:WaitForChild("Config"):WaitForChild("Return")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local ACTION = "CryptidOfferingDismiss"

local OfferingPanel = {}

function OfferingPanel.mount(parent: Instance, isReduced: () -> boolean, claim: () -> (), isBlocked: () -> boolean)
	local hud = Plots.RETURN_BUTTON
	local button = UiFactory.button(parent, UITheme.text.minSize)
	button.Name = "Offering"
	button.Text = Return.OFFERING_BUTTON
	button.AnchorPoint = Vector2.new(0, 1)
	button.Visible = false
	button.BackgroundColor3 = UITheme.color("Soot")
	button.TextColor3 = UITheme.color("Bone")
	button.ZIndex = 5
	local lift = hud.margin + hud.height + hud.gap
	button.Position = UDim2.new(0, hud.margin, 1, -lift)
	button.Size = UDim2.fromOffset(hud.width, hud.height)

	local pip = Instance.new("Frame")
	pip.Name = "Pip"
	pip.AnchorPoint = Vector2.new(1, 0)
	local pipInset = UITheme.shape.offeringPip / 2
	pip.Position = UDim2.new(1, -pipInset, 0, pipInset)
	pip.Size = UDim2.fromOffset(UITheme.shape.offeringPip, UITheme.shape.offeringPip)
	pip.BackgroundColor3 = UITheme.color("Gold")
	pip.BorderSizePixel = 0
	pip.Visible = false
	pip.ZIndex = 6
	pip.Parent = button
	UiFactory.corner(pip)

	local backdrop = Instance.new("TextButton")
	backdrop.Name = "OfferingBackdrop"
	backdrop.BackgroundColor3 = UITheme.color("Void")
	backdrop.BackgroundTransparency = 0.45
	backdrop.BorderSizePixel = 0
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.Visible = false
	backdrop.ZIndex = 34
	backdrop.Parent = parent

	local frame = UiFactory.panel(backdrop)
	frame.Name = "OfferingPanel"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.ZIndex = 35
	frame.Active = true

	local title = UiFactory.label(frame, "display", UITheme.shape.offeringPanel.title, "Bone")
	title.Name = "Title"
	title.Text = Return.OFFERING_TITLE
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = 36

	local progress = UiFactory.label(frame, "body", UITheme.shape.offeringPanel.body, "BoneDim")
	progress.Name = "Progress"
	progress.TextXAlignment = Enum.TextXAlignment.Center
	progress.ZIndex = 36

	local waited = UiFactory.label(frame, "body", UITheme.shape.offeringPanel.detail, "Gold")
	waited.Name = "Waited"
	waited.Text = Return.OFFERING_WAITED
	waited.TextXAlignment = Enum.TextXAlignment.Center
	waited.Visible = false
	waited.ZIndex = 36

	local row = Instance.new("Frame")
	row.Name = "Cards"
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.ZIndex = 36
	row.Parent = frame
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Wraps = true
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, UITheme.shape.plaqueGapPx)
	layout.Parent = row

	local cards = {}
	for _ = 1, Return.LADDER_STEPS do
		local card = UiFactory.panel(row)
		card.ZIndex = 36
		local stroke = card:FindFirstChildOfClass("UIStroke")
		local mark = UiFactory.label(card, "number", UITheme.fonts.number.desktop, "Blood")
		mark.Name = "Mark"
		mark.Text = UITheme.disabledMark
		mark.TextXAlignment = Enum.TextXAlignment.Center
		mark.Visible = false
		mark.ZIndex = 37
		local name = UiFactory.label(card, "body", UITheme.shape.offeringPanel.card, "Bone")
		name.Name = "Name"
		name.TextWrapped = true
		name.TextXAlignment = Enum.TextXAlignment.Center
		name.TextYAlignment = Enum.TextYAlignment.Top
		name.ZIndex = 37
		local reward = UiFactory.label(card, "number", UITheme.fonts.income.desktop, "GoldBright")
		reward.Name = "Reward"
		reward.TextWrapped = true
		reward.TextXAlignment = Enum.TextXAlignment.Center
		reward.ZIndex = 37
		table.insert(cards, {
			frame = card,
			stroke = stroke,
			mark = mark,
			name = name,
			reward = reward,
		})
	end

	local countdown = UiFactory.label(frame, "body", UITheme.shape.offeringPanel.detail, "BoneDim")
	countdown.Name = "Countdown"
	countdown.TextXAlignment = Enum.TextXAlignment.Center
	countdown.ZIndex = 36

	local after = UiFactory.label(frame, "body", UITheme.shape.offeringPanel.body, "Bone")
	after.Name = "After"
	after.Text = Return.OFFERING_TOMORROW
	after.TextXAlignment = Enum.TextXAlignment.Center
	after.TextWrapped = true
	after.Visible = false
	after.ZIndex = 36

	local accept = UiFactory.button(frame, UITheme.fonts.body.desktop)
	accept.Name = "Accept"
	accept.Text = Return.OFFERING_ACCEPT
	accept.ZIndex = 37
	Motion.wireButton(accept, function()
		return accept.Visible
	end, isReduced)

	local open = false
	local autoStarted = false
	local missedShown = false
	local latest: any = nil
	local remainAt = 0
	local remainFrom = 0

	local function setOpen(on: boolean)
		open = on
		backdrop.Visible = on
		if on then
			ContextActionService:BindActionAtPriority(ACTION, function(_name, state)
				if state == Enum.UserInputState.Begin then
					setOpen(false)
				end
				return Enum.ContextActionResult.Sink
			end, false, UITheme.shape.escapePriority, Enum.KeyCode.Escape)
		else
			ContextActionService:UnbindAction(ACTION)
		end
	end

	local function paintCards(mobile: boolean)
		local spec = UITheme.shape.offeringPanel
		local cardSize = if mobile then spec.cardMobile else spec.cardDesktop
		local cardW = cardSize.w
		local cardH = cardSize.h
		for index, card in cards do
			card.frame.Size = UDim2.fromOffset(cardW, cardH)
			card.mark.Size = UDim2.new(1, 0, 0, 22)
			card.mark.Position = UDim2.fromOffset(0, 4)
			card.name.Position = UDim2.fromOffset(4, 26)
			card.name.Size = UDim2.new(1, -8, 0, 36)
			card.reward.Position = UDim2.fromOffset(4, 62)
			card.reward.Size = UDim2.new(1, -8, 0, 36)
			local step = if latest ~= nil then latest.step else 1
			local entry = if latest ~= nil and type(latest.steps) == "table" then latest.steps[index] else nil
			local current = index == step
			local claimed = index < step
			card.mark.Visible = claimed
			if type(entry) == "table" then
				local label = entry.displayName
				if type(label) ~= "string" or label == "" then
					label = OfferingCopy.minutes(entry.minutes)
				end
				card.name.Text = label
				if type(entry.cash) == "number" and entry.cash > 0 then
					card.reward.Text = NumberFormat.formatCash(entry.cash)
				else
					card.reward.Text = ""
				end
			end
			if card.stroke ~= nil then
				if current then
					card.stroke.Color = UITheme.color("Gold")
					card.stroke.Thickness = UITheme.shape.plaqueStrokePx
					card.stroke.Transparency = 0
				else
					card.stroke.Color = UITheme.color("BoneDim")
					card.stroke.Thickness = UITheme.shape.strokePx
					card.stroke.Transparency = UITheme.shape.strokeTransparency
				end
			end
			card.name.TextColor3 = if current then UITheme.color("Bone") else UITheme.color("BoneDim")
		end
		progress.Text = OfferingCopy.progress(if latest ~= nil then latest.step else 1)
		local ready = latest ~= nil and latest.ready == true
		accept.Visible = ready
		after.Visible = not ready
		waited.Visible = open and missedShown and latest ~= nil and latest.missed == true
	end

	local function paintButton()
		local show = latest ~= nil and latest.button == true
		if show and isBlocked() then
			button.Visible = false
			pip.Visible = false
			return
		end
		button.Visible = show
		pip.Visible = show and latest.ready == true
	end

	local function paintCountdown()
		if latest == nil or type(latest.nextDailyUnix) ~= "number" or type(latest.serverNow) ~= "number" then
			countdown.Text = ""
			return
		end
		local left = remainAt - (os.clock() - remainFrom)
		if left < 0 then
			left = 0
		end
		countdown.Text = OfferingCopy.countdown(left)
	end

	local mobileLayout = false

	local function openPanel()
		if latest == nil or isBlocked() then
			return
		end
		if latest.missed == true and not missedShown then
			missedShown = true
		end
		setOpen(true)
		paintCards(mobileLayout)
	end

	button.Activated:Connect(function()
		if isBlocked() then
			return
		end
		openPanel()
	end)
	accept.Activated:Connect(function()
		if latest == nil or latest.ready ~= true then
			return
		end
		claim()
	end)
	backdrop.Activated:Connect(function()
		setOpen(false)
	end)

	task.spawn(function()
		while frame.Parent ~= nil do
			task.wait(UITheme.shape.busyPoll)
			paintButton()
			if open then
				paintCountdown()
				local current = if latest ~= nil then latest.step else 0
				local card = cards[current]
				if card ~= nil and card.stroke ~= nil then
					if isReduced() then
						card.stroke.Transparency = 0
					else
						local wave = (math.sin(os.clock() * math.pi) + 1) / 2
						card.stroke.Transparency = wave * 0.45
					end
				end
			end
		end
	end)

	local api = {}

	function api.layout(mobile: boolean)
		mobileLayout = mobile
		local spec = UITheme.shape.offeringPanel
		if mobile then
			frame.Size = UDim2.new(1, -UITheme.shape.screenInset * 2, 0, spec.mobileH)
		else
			frame.Size = UDim2.fromOffset(spec.desktop.w, spec.desktop.h)
		end
		local inset = UITheme.shape.screenInset
		title.Position = UDim2.fromOffset(inset, 16)
		title.Size = UDim2.new(1, -inset * 2, 0, spec.title + 4)
		progress.Position = UDim2.fromOffset(inset, 16 + spec.title + 4)
		progress.Size = UDim2.new(1, -inset * 2, 0, spec.body)
		waited.Position = UDim2.fromOffset(inset, 16 + spec.title + spec.body + 6)
		waited.Size = UDim2.new(1, -inset * 2, 0, spec.detail + 2)
		row.Position = UDim2.fromOffset(inset, 16 + spec.title + spec.body + spec.detail + 16)
		row.Size = UDim2.new(1, -inset * 2, 0, if mobile then 200 else 120)
		countdown.AnchorPoint = Vector2.new(0, 1)
		countdown.Position = UDim2.new(0, inset, 1, -(UITheme.shape.touchPx + inset + 28))
		countdown.Size = UDim2.new(1, -inset * 2, 0, spec.detail + 2)
		after.AnchorPoint = Vector2.new(0, 1)
		after.Position = UDim2.new(0, inset, 1, -(UITheme.shape.touchPx + inset + 4))
		after.Size = UDim2.new(1, -inset * 2, 0, spec.body + 4)
		accept.AnchorPoint = Vector2.new(0.5, 1)
		accept.Position = UDim2.new(0.5, 0, 1, -inset)
		accept.Size = UDim2.fromOffset(spec.buttonW, UITheme.shape.touchPx)
		paintCards(mobile)
	end

	function api.apply(daily: any, haulOpen: boolean)
		latest = if type(daily) == "table" then daily else nil
		if latest ~= nil and type(latest.nextDailyUnix) == "number" and type(latest.serverNow) == "number" then
			remainAt = math.max(0, latest.nextDailyUnix - latest.serverNow)
			remainFrom = os.clock()
		end
		paintButton()
		paintCards(mobileLayout)
		paintCountdown()
		local wantsAuto = latest ~= nil and latest.autoOpen == true and latest.ready == true
		if wantsAuto and not autoStarted and not haulOpen and not open then
			autoStarted = true
			task.delay(Return.PANEL_GAP_SECONDS, function()
				if haulOpen or open or latest == nil or latest.ready ~= true or latest.autoOpen ~= true then
					return
				end
				if isBlocked() then
					autoStarted = false
					return
				end
				openPanel()
				api.layout(mobileLayout)
			end)
		end
	end

	api.layout(false)
	return api
end

return OfferingPanel
