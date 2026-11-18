--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Motion = require(script.Parent:WaitForChild("Motion"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local CryptidModels = require(Shared:WaitForChild("CryptidModels")) :: any
local Income = require(Shared:WaitForChild("Logic"):WaitForChild("Income")) :: any
local PedlarBrowse = require(Shared:WaitForChild("Logic"):WaitForChild("PedlarBrowse")) :: any
local NumberFormat = require(Shared:WaitForChild("Logic"):WaitForChild("NumberFormat")) :: any
local Shop = require(Shared:WaitForChild("Config"):WaitForChild("Shop")) :: any
local ShopLedger = require(Shared:WaitForChild("Logic"):WaitForChild("ShopLedger")) :: any
local ShopStock = require(Shared:WaitForChild("Logic"):WaitForChild("ShopStock")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local PedlarShop = {}

local function fire(remotes: Folder, name: string, ...: any)
	local remote = remotes:WaitForChild(name) :: RemoteEvent
	remote:FireServer(...)
end

function PedlarShop.mount(parent: Instance, player: Player, remotes: Folder, names: any, isReduced: () -> boolean)
	local root = Instance.new("CanvasGroup")
	root.Name = "PedlarShop"
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = UDim2.fromOffset(Shop.PANEL.width, Shop.PANEL.height)
	root.BackgroundTransparency = 1
	root.GroupTransparency = 1
	root.Visible = false
	root.ZIndex = 6
	root.Parent = parent

	local panel = UiFactory.panel(root)
	panel.Size = UDim2.fromScale(1, 1)

	local pedlar = UITheme.shape.pedlar
	local touch = UITheme.shape.touchPx
	local gap = UITheme.shape.plaqueGapPx
	local pad = Shop.PANEL.padding

	local title = UiFactory.label(panel, "display", Shop.HEADER_PX, "Bone")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(pad, pad)
	title.Size = UDim2.new(1, -(pad * 2 + pedlar.leaveW + gap), 0, touch)
	title.Text = Shop.HEADER

	local leave = UiFactory.button(panel, UITheme.text.minSize)
	leave.Name = "Leave"
	leave.AnchorPoint = Vector2.new(1, 0)
	leave.Position = UDim2.new(1, -pad, 0, pad)
	leave.Size = UDim2.fromOffset(pedlar.leaveW, touch)
	leave.BackgroundColor3 = UITheme.color("Soot")
	leave.TextColor3 = UITheme.color("Bone")
	leave.Text = Shop.LEAVE

	local countdown = UiFactory.label(panel, "body", UITheme.text.minSize, "BoneDim")
	countdown.Name = "Countdown"
	countdown.Position = UDim2.fromOffset(pad, pad + touch + gap)
	countdown.Size = UDim2.new(1, -pad * 2, 0, UITheme.text.minSize)
	countdown.Text = Shop.WAITING

	local actionY = pad + touch + gap + UITheme.text.minSize + gap
	local notice = UiFactory.label(panel, "body", UITheme.text.minSize, "BoneDim")
	notice.Name = "Notice"
	notice.Position = UDim2.fromOffset(pad, actionY + touch + gap)
	notice.Size = UDim2.new(1, -pad * 2, 0, UITheme.text.minSize)
	notice.Text = ""
	notice.Visible = false
	local details = UiFactory.button(panel, UITheme.text.minSize)
	details.Name = "Details"
	details.Position = UDim2.fromOffset(pad, actionY)
	details.Size = UDim2.fromOffset(pedlar.detailsW, touch)
	details.BackgroundColor3 = UITheme.color("Soot")
	details.TextColor3 = UITheme.color("Bone")
	details.Text = Shop.DETAILS
	local detailsStroke = details:FindFirstChildOfClass("UIStroke")
	if detailsStroke ~= nil then
		detailsStroke.Color = UITheme.color("BoneDim")
		detailsStroke.Thickness = UITheme.shape.strokePx
	end

	local bind = UiFactory.button(panel, UITheme.text.minSize)
	bind.Name = "BindAtOnce"
	bind.Position = UDim2.fromOffset(pad + pedlar.detailsW + gap, actionY)
	bind.Size = UDim2.fromOffset(pedlar.bindW, touch)
	bind.BackgroundColor3 = UITheme.color("Soot")
	bind.TextColor3 = UITheme.color("Bone")
	bind.Text = Shop.BIND_OFF

	local cardsTop = actionY + touch + gap + UITheme.text.minSize + gap
	local cardLayer = Instance.new("CanvasGroup")
	cardLayer.Name = "Cards"
	cardLayer.BackgroundTransparency = 1
	cardLayer.Position = UDim2.fromOffset(pad, cardsTop)
	cardLayer.Size = UDim2.new(1, -pad * 2, 1, -(cardsTop + pad))
	cardLayer.Parent = panel
	local scroller = Instance.new("ScrollingFrame")
	scroller.Name = "Scroller"
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.Size = UDim2.fromScale(1, 1)
	scroller.ScrollBarThickness = UITheme.shape.strokePx
	scroller.ScrollingDirection = Enum.ScrollingDirection.Y
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.CanvasSize = UDim2.fromOffset(0, 0)
	scroller.Parent = cardLayer
	local grid = Instance.new("UIGridLayout")
	grid.CellPadding = UDim2.fromOffset(gap, gap)
	grid.CellSize = UDim2.new(0.25, -gap, 0, pedlar.cardH)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = scroller

	local oddsLayer = Instance.new("Frame")
	oddsLayer.Name = "Odds"
	oddsLayer.BackgroundColor3 = UITheme.color("Ash")
	oddsLayer.BorderSizePixel = 0
	oddsLayer.Position = cardLayer.Position
	oddsLayer.Size = cardLayer.Size
	oddsLayer.Visible = false
	oddsLayer.Parent = panel
	local oddsColumns = Instance.new("Frame")
	oddsColumns.Name = "Columns"
	oddsColumns.BackgroundTransparency = 1
	oddsColumns.Size = UDim2.new(1, 0, 1, -(UITheme.text.minSize * 2 + gap))
	oddsColumns.Parent = oddsLayer
	local oddsRow = Instance.new("UIListLayout")
	oddsRow.FillDirection = Enum.FillDirection.Horizontal
	oddsRow.Padding = UDim.new(0, gap)
	oddsRow.SortOrder = Enum.SortOrder.LayoutOrder
	oddsRow.Parent = oddsColumns
	local oddsNote = UiFactory.label(oddsLayer, "body", UITheme.text.minSize, "BoneDim")
	oddsNote.Name = "OddsNote"
	oddsNote.AnchorPoint = Vector2.new(0, 1)
	oddsNote.Position = UDim2.fromScale(0, 1)
	oddsNote.Size = UDim2.new(1, 0, 0, UITheme.text.minSize * 2)
	oddsNote.TextWrapped = true
	oddsNote.Text = Shop.ODDS_NOTE

	local board: any = nil
	local snapshot: any = nil
	local cards: { any } = {}

	local function cash(): number
		local value = player:GetAttribute("Cash")
		if type(value) ~= "number" then
			return 0
		end
		return value
	end

	local function altarLevel(): number
		if snapshot == nil or type(snapshot.boneAltar) ~= "number" then
			return 0
		end
		return snapshot.boneAltar
	end

	local function taken(slot: number): boolean
		if board == nil or snapshot == nil or type(snapshot.pedlar) ~= "table" then
			return false
		end
		local bought = snapshot.pedlar
		return ShopLedger.slotBought(bought.lastRotationId, bought.boughtSlots, board.rotationId, slot)
	end

	local function paintBind()
		local on = snapshot ~= nil and type(snapshot.pedlar) == "table" and snapshot.pedlar.bindAtOnce == true
		bind.Text = if on then Shop.BIND_ON else Shop.BIND_OFF
	end

	local function paintCard(card: any)
		UiFactory.applyChip(card.chip, card.rarityLabel, card.rarity)
		card.rarityLabel.Text = card.rarity
		local perLevel = player:GetAttribute("AltarPerLevel")
		local skillIncome = player:GetAttribute("SkillIncome")
		local rate = if type(perLevel) == "number" then perLevel else nil
		local skill = if type(skillIncome) == "number" then skillIncome else nil
		card.income.Text = NumberFormat.formatRate(Income.contribution(card.speciesId, altarLevel(), rate, skill))
		card.priceLabel.Text = NumberFormat.formatCash(card.price)
		local shortfall = card.price - cash()
		if taken(card.slot) then
			card.button.Text = Shop.SOLD
			card.button.Active = false
			card.button.BackgroundColor3 = UITheme.color("Soot")
			card.button.TextColor3 = UITheme.color("BoneDim")
		elseif shortfall > 1e-9 then
			card.button.Text = string.format(Shop.NEED_MORE, NumberFormat.formatCash(shortfall))
			card.button.Active = false
			card.button.BackgroundColor3 = UITheme.color("Soot")
			card.button.TextColor3 = UITheme.color("BoneDim")
		else
			card.button.Text = Shop.BUY
			card.button.Active = true
			card.button.BackgroundColor3 = UITheme.color("Blood")
			card.button.TextColor3 = UITheme.color("Bone")
		end
	end

	local function paintCards()
		for _, card in cards do
			paintCard(card)
		end
		paintBind()
	end

	local function clear(frame: Instance)
		for _, child in frame:GetChildren() do
			if not child:IsA("UIGridLayout") and not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end
	end

	local function mountPortrait(host: Instance, speciesId: string)
		local viewport = Instance.new("ViewportFrame")
		viewport.Name = "Portrait"
		viewport.BackgroundColor3 = UITheme.color("Ash")
		viewport.BorderSizePixel = 0
		viewport.Size = UDim2.new(1, 0, 0, pedlar.previewPx)
		viewport.Ambient = UITheme.color("BoneDim")
		viewport.LightColor = UITheme.color("Bone")
		viewport.LayoutOrder = 1
		viewport.Parent = host
		UiFactory.corner(viewport)
		local camera = Instance.new("Camera")
		camera.Name = "PortraitCamera"
		camera.Parent = viewport
		viewport.CurrentCamera = camera
		local model = CryptidModels.get(speciesId)
		model.Parent = viewport
		local ok, cf, size = pcall(function()
			return model:GetBoundingBox()
		end)
		local focus = Vector3.new(0, 0, 0)
		local radius = pedlar.previewFit
		if ok and typeof(cf) == "CFrame" and typeof(size) == "Vector3" then
			focus = cf.Position
			local span = math.max(size.X, size.Y, size.Z, 1)
			radius = span * pedlar.previewFit
		end
		local lift = radius * pedlar.previewLift
		camera.CFrame = CFrame.new(focus + Vector3.new(radius, lift, radius), focus)
	end

	local function rebuildCards()
		clear(scroller)
		cards = {}
		if board == nil or type(board.offers) ~= "table" then
			return
		end
		for _, offer in board.offers do
			if type(offer) == "table" and type(offer.slot) == "number" then
				local cardFrame = Instance.new("Frame")
				cardFrame.Name = "Slot" .. tostring(offer.slot)
				cardFrame.BackgroundColor3 = UITheme.color("Soot")
				cardFrame.BorderSizePixel = 0
				cardFrame.LayoutOrder = offer.slot
				cardFrame.Parent = scroller
				UiFactory.corner(cardFrame)
				UiFactory.stroke(cardFrame, "Gold", UITheme.shape.strokePx, UITheme.shape.strokeTransparency)
				local padding = Instance.new("UIPadding")
				padding.PaddingTop = UDim.new(0, gap)
				padding.PaddingBottom = UDim.new(0, gap)
				padding.PaddingLeft = UDim.new(0, gap)
				padding.PaddingRight = UDim.new(0, gap)
				padding.Parent = cardFrame
				local list = Instance.new("UIListLayout")
				list.Padding = UDim.new(0, gap)
				list.SortOrder = Enum.SortOrder.LayoutOrder
				list.Parent = cardFrame

				local speciesId = if type(offer.speciesId) == "string" then offer.speciesId else ""
				mountPortrait(cardFrame, speciesId)
				local creature = UiFactory.label(cardFrame, "body", pedlar.namePx, "Bone")
				creature.Size = UDim2.new(1, 0, 0, pedlar.namePx * 2)
				creature.TextWrapped = true
				creature.Text = if type(offer.displayName) == "string" then offer.displayName else ""
				creature.LayoutOrder = 2
				local rarityName = if type(offer.rarity) == "string" then offer.rarity else "Common"
				local chip, rarityLabel = UiFactory.rarityChip(cardFrame, rarityName)
				chip.Size = UDim2.new(1, 0, 0, pedlar.chipH)
				chip.LayoutOrder = 3
				local priceLabel = UiFactory.label(cardFrame, "number", pedlar.pricePx, "GoldBright")
				priceLabel.Size = UDim2.new(1, 0, 0, pedlar.pricePx)
				priceLabel.LayoutOrder = 4
				local income = UiFactory.label(cardFrame, "body", pedlar.incomePx, "BoneDim")
				income.Size = UDim2.new(1, 0, 0, pedlar.incomePx)
				income.LayoutOrder = 5
				local button = UiFactory.button(cardFrame, UITheme.text.minSize)
				button.Size = UDim2.new(1, 0, 0, touch)
				button.LayoutOrder = 6
				button.Text = Shop.BUY

				local card = {
					slot = offer.slot,
					speciesId = speciesId,
					rarity = rarityName,
					price = if type(offer.price) == "number" then offer.price else 0,
					chip = chip,
					rarityLabel = rarityLabel,
					income = income,
					priceLabel = priceLabel,
					button = button,
				}
				button.Activated:Connect(function()
					if not button.Active or board == nil then
						return
					end
					fire(remotes, names.PEDLAR_BUY, board.rotationId, card.slot)
				end)
				table.insert(cards, card)
				paintCard(card)
			end
		end
	end

	local function showOdds()
		clear(oddsColumns)
		for _, column in ShopStock.oddsColumns() do
			local columnFrame = Instance.new("Frame")
			columnFrame.Name = column.name
			columnFrame.BackgroundTransparency = 1
			columnFrame.Size = UDim2.new(0.25, -gap, 1, 0)
			columnFrame.LayoutOrder = column.slot
			columnFrame.Parent = oddsColumns
			local list = Instance.new("UIListLayout")
			list.Padding = UDim.new(0, gap)
			list.SortOrder = Enum.SortOrder.LayoutOrder
			list.Parent = columnFrame
			local header = UiFactory.label(columnFrame, "body", UITheme.text.minSize, "Bone")
			header.Size = UDim2.new(1, 0, 0, UITheme.text.minSize * 2)
			header.TextWrapped = true
			header.Text = column.name
			header.LayoutOrder = 0
			for rowIndex, row in column.rows do
				local chip, line = UiFactory.rarityChip(columnFrame, row.rarity)
				chip.Size = UDim2.new(1, 0, 0, pedlar.chipH)
				chip.LayoutOrder = rowIndex
				line.Text = row.rarity .. "  " .. tostring(row.percent) .. "%"
			end
			local total = UiFactory.label(columnFrame, "number", UITheme.fonts.number.desktop, "GoldBright")
			total.Size = UDim2.new(1, 0, 0, UITheme.fonts.number.desktop)
			total.Text = Shop.ODDS_TOTAL .. "  " .. tostring(column.total) .. "%"
			total.LayoutOrder = 20
		end
		oddsLayer.Visible = true
		cardLayer.Visible = false
	end

	local function showCards()
		oddsLayer.Visible = false
		cardLayer.Visible = true
	end

	local function layout()
		local camera = workspace.CurrentCamera
		local width = 1280
		if camera ~= nil then
			width = camera.ViewportSize.X
		end
		local mobile = width < UITheme.shape.mobileWidthBreakpoint
		local noticeY = actionY + touch + gap
		if mobile then
			bind.Position = UDim2.fromOffset(pad, actionY + touch + gap)
			noticeY = actionY + touch + gap + touch + gap
		else
			bind.Position = UDim2.fromOffset(pad + pedlar.detailsW + gap, actionY)
		end
		details.Position = UDim2.fromOffset(pad, actionY)
		notice.Position = UDim2.fromOffset(pad, noticeY)
		local top = noticeY + UITheme.text.minSize + gap
		cardLayer.Position = UDim2.fromOffset(pad, top)
		cardLayer.Size = UDim2.new(1, -pad * 2, 1, -(top + pad))
		oddsLayer.Position = cardLayer.Position
		oddsLayer.Size = cardLayer.Size
		if mobile then
			local margin = Shop.PANEL.mobileMargin
			root.Size = UDim2.new(1, -margin * 2, 1, -margin * 2)
			grid.CellSize = UDim2.new(0.5, -gap, 0, pedlar.cardH)
			grid.FillDirectionMaxCells = 2
		else
			root.Size = UDim2.fromOffset(Shop.PANEL.width, Shop.PANEL.height)
			grid.CellSize = UDim2.new(0.25, -gap, 0, pedlar.cardH)
			grid.FillDirectionMaxCells = 4
		end
	end

	local seenOpen = 0

	local function showFromServer()
		showCards()
		layout()
		PedlarBrowse.reveal(root)
		root.GroupTransparency = 1
		Motion.play(root, "panelOpen", isReduced(), { GroupTransparency = 0 })
	end

	local function closeShop()
		local plan = UITheme.resolveMotion("panelClose", isReduced())
		Motion.play(root, "panelClose", isReduced(), { GroupTransparency = 1 })
		task.delay(plan.duration, function()
			if root.GroupTransparency >= 1 then
				root.Visible = false
			end
		end)
	end

	leave.Activated:Connect(closeShop)
	details.Activated:Connect(function()
		if oddsLayer.Visible then
			showCards()
		else
			showOdds()
		end
	end)
	bind.Activated:Connect(function()
		local on = snapshot ~= nil and type(snapshot.pedlar) == "table" and snapshot.pedlar.bindAtOnce == true
		fire(remotes, names.BIND_AT_ONCE, not on)
	end)

	local function ingest(text: string, animate: boolean)
		if text == "" then
			return
		end
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(text)
		end)
		if not ok or type(decoded) ~= "table" then
			return
		end
		local previous = if board ~= nil then board.rotationId else nil
		local function apply()
			board = decoded
			rebuildCards()
			paintBind()
		end
		if animate and root.Visible and previous ~= nil and previous ~= decoded.rotationId then
			local plan = UITheme.resolveMotion("panelClose", isReduced())
			Motion.play(cardLayer, "panelClose", isReduced(), { GroupTransparency = 1 })
			task.delay(plan.duration, function()
				apply()
				cardLayer.GroupTransparency = 1
				Motion.play(cardLayer, "panelOpen", isReduced(), { GroupTransparency = 0 })
			end)
		else
			apply()
		end
	end

	task.spawn(function()
		local value = ReplicatedStorage:WaitForChild("PedlarBoard") :: StringValue
		ingest(value.Value, false)
		value.Changed:Connect(function(text)
			ingest(text, true)
		end)
	end)

	task.spawn(function()
		local state = player:WaitForChild("CryptidState")
		local snap = state:WaitForChild("Snapshot") :: StringValue
		local function read(text: string)
			if text == "" then
				return
			end
			local ok, decoded = pcall(function()
				return HttpService:JSONDecode(text)
			end)
			if ok and type(decoded) == "table" then
				snapshot = decoded
				paintCards()
			end
		end
		read(snap.Value)
		snap.Changed:Connect(read)
	end)

	task.spawn(function()
		while root.Parent ~= nil do
			if board ~= nil and type(board.nextRestockUnix) == "number" then
				local remain = ShopStock.displaySeconds(os.time(), board.nextRestockUnix)
				countdown.Text = Shop.RESTOCK_PREFIX .. ShopStock.formatCountdown(remain)
			end
			task.wait(0.2)
		end
	end)

	player:GetAttributeChangedSignal("Cash"):Connect(paintCards)
	player:GetAttributeChangedSignal("PedlarNoticeToken"):Connect(function()
		local message = player:GetAttribute("PedlarNotice")
		if type(message) ~= "string" or message == "" then
			return
		end
		notice.Text = message
		notice.Visible = true
	end)

	local function attachUnmarked(model: Instance)
		local adornee = model:FindFirstChild("Counter")
		if adornee == nil or not adornee:IsA("BasePart") then
			if model:IsA("Model") then
				adornee = model.PrimaryPart
			end
		end
		if adornee == nil or not adornee:IsA("BasePart") then
			return
		end
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "Unmarked"
		billboard.Size = UDim2.fromOffset(320, 36)
		billboard.StudsOffset = Vector3.new(0, 6, 0)
		billboard.AlwaysOnTop = false
		billboard.LightInfluence = 0
		billboard.MaxDistance = 70
		billboard.Adornee = adornee
		billboard.Parent = parent
		local label = UiFactory.label(billboard, "body", UITheme.text.minSize, "BoneDim")
		label.Size = UDim2.fromScale(1, 1)
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.Text = Shop.UNMARKED
		local function refresh()
			local step = player:GetAttribute("OnboardingStep")
			billboard.Enabled = type(step) ~= "number" or step < Shop.GATE_STEP
		end
		refresh()
		player:GetAttributeChangedSignal("OnboardingStep"):Connect(refresh)
	end

	player:GetAttributeChangedSignal(Shop.OPEN_TOKEN):Connect(function()
		local token = player:GetAttribute(Shop.OPEN_TOKEN)
		if type(token) ~= "number" or token <= seenOpen then
			return
		end
		seenOpen = token
		showFromServer()
	end)

	for _, model in CollectionService:GetTagged("PedlarStall") do
		attachUnmarked(model)
	end
	CollectionService:GetInstanceAddedSignal("PedlarStall"):Connect(attachUnmarked)

	local camera = workspace.CurrentCamera
	if camera ~= nil then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)
	end
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local nextCamera = workspace.CurrentCamera
		if nextCamera ~= nil then
			nextCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)
			layout()
		end
	end)
	layout()
end

return PedlarShop
