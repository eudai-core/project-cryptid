--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Motion = require(script.Parent:WaitForChild("Motion"))
local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
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

	local title = UiFactory.label(panel, "display", Shop.HEADER_PX, "Bone")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(Shop.PANEL.padding, 10)
	title.Size = UDim2.new(1, -160, 0, 36)
	title.Text = Shop.HEADER

	local leave = UiFactory.button(panel, UITheme.text.minSize)
	leave.Name = "Leave"
	leave.AnchorPoint = Vector2.new(1, 0)
	leave.Position = UDim2.new(1, -Shop.PANEL.padding, 0, 12)
	leave.Size = UDim2.fromOffset(96, 28)
	leave.BackgroundColor3 = UITheme.color("Soot")
	leave.TextColor3 = UITheme.color("BoneDim")
	leave.Text = Shop.LEAVE

	local countdown = UiFactory.label(panel, "number", UITheme.fonts.number.desktop, "GoldBright")
	countdown.Name = "Countdown"
	countdown.Position = UDim2.fromOffset(Shop.PANEL.padding, 48)
	countdown.Size = UDim2.new(1, -24, 0, 22)
	countdown.Text = Shop.WAITING

	local notice = UiFactory.label(panel, "body", UITheme.text.minSize, "BoneDim")
	notice.Name = "Notice"
	notice.Position = UDim2.fromOffset(Shop.PANEL.padding, 70)
	notice.Size = UDim2.new(1, -24, 0, 18)
	notice.Text = ""
	notice.Visible = false

	local oddsButton = Instance.new("TextButton")
	oddsButton.Name = "OddsLink"
	oddsButton.BackgroundTransparency = 1
	oddsButton.AutoButtonColor = false
	oddsButton.Position = UDim2.fromOffset(Shop.PANEL.padding, 92)
	oddsButton.Size = UDim2.fromOffset(64, 22)
	oddsButton.Text = Shop.ODDS
	oddsButton.TextColor3 = UITheme.color("BoneDim")
	oddsButton.TextXAlignment = Enum.TextXAlignment.Left
	oddsButton.Parent = panel
	ThemeBind.apply(oddsButton, "body", UITheme.text.minSize)
	local underline = Instance.new("Frame")
	underline.Name = "Underline"
	underline.BackgroundColor3 = UITheme.color("BoneDim")
	underline.BorderSizePixel = 0
	underline.AnchorPoint = Vector2.new(0, 1)
	underline.Position = UDim2.fromScale(0, 1)
	underline.Size = UDim2.new(1, 0, 0, 1)
	underline.Parent = oddsButton

	local bind = UiFactory.button(panel, UITheme.text.minSize)
	bind.Name = "BindAtOnce"
	bind.Position = UDim2.fromOffset(Shop.PANEL.padding + 80, 90)
	bind.Size = UDim2.fromOffset(180, 26)
	bind.BackgroundColor3 = UITheme.color("Soot")
	bind.TextColor3 = UITheme.color("Bone")
	bind.Text = Shop.BIND_OFF

	local cardLayer = Instance.new("CanvasGroup")
	cardLayer.Name = "Cards"
	cardLayer.BackgroundTransparency = 1
	cardLayer.Position = UDim2.fromOffset(Shop.PANEL.padding, 124)
	cardLayer.Size = UDim2.new(1, -Shop.PANEL.padding * 2, 1, -136)
	cardLayer.Parent = panel
	local grid = Instance.new("UIGridLayout")
	grid.CellPadding = UDim2.fromOffset(8, 8)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = cardLayer

	local oddsLayer = Instance.new("Frame")
	oddsLayer.Name = "Odds"
	oddsLayer.BackgroundColor3 = UITheme.color("Ash")
	oddsLayer.BorderSizePixel = 0
	oddsLayer.Position = cardLayer.Position
	oddsLayer.Size = cardLayer.Size
	oddsLayer.Visible = false
	oddsLayer.Parent = panel
	local oddsRow = Instance.new("UIListLayout")
	oddsRow.FillDirection = Enum.FillDirection.Horizontal
	oddsRow.Padding = UDim.new(0, 8)
	oddsRow.SortOrder = Enum.SortOrder.LayoutOrder
	oddsRow.Parent = oddsLayer

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
		local pedlar = snapshot.pedlar
		return ShopLedger.slotBought(pedlar.lastRotationId, pedlar.boughtSlots, board.rotationId, slot)
	end

	local function paintBind()
		local on = snapshot ~= nil and type(snapshot.pedlar) == "table" and snapshot.pedlar.bindAtOnce == true
		bind.Text = if on then Shop.BIND_ON else Shop.BIND_OFF
	end

	local function paintCard(card: any)
		local token = UITheme.rarity[card.rarity]
		if token == nil then
			token = "BoneDim"
		end
		card.rarityLabel.Text = card.rarity
		card.rarityLabel.TextColor3 = UITheme.color(token)
		card.art.TextColor3 = UITheme.color(token)
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

	local function rebuildCards()
		clear(cardLayer)
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
				cardFrame.Parent = cardLayer
				UiFactory.corner(cardFrame)
				UiFactory.stroke(cardFrame, "Gold", UITheme.shape.strokePx, UITheme.shape.strokeTransparency)
				local padding = Instance.new("UIPadding")
				padding.PaddingTop = UDim.new(0, 8)
				padding.PaddingBottom = UDim.new(0, 8)
				padding.PaddingLeft = UDim.new(0, 8)
				padding.PaddingRight = UDim.new(0, 8)
				padding.Parent = cardFrame
				local list = Instance.new("UIListLayout")
				list.Padding = UDim.new(0, 2)
				list.SortOrder = Enum.SortOrder.LayoutOrder
				list.Parent = cardFrame

				local slotName = UiFactory.label(cardFrame, "body", UITheme.text.minSize, "Bone")
				slotName.Size = UDim2.new(1, 0, 0, 18)
				slotName.Text = if type(offer.slotName) == "string" then offer.slotName else ""
				slotName.LayoutOrder = 1
				local art = UiFactory.label(cardFrame, "display", 28, "BoneDim")
				art.Size = UDim2.new(1, 0, 0, 32)
				art.Text = UITheme.sigil
				art.TextXAlignment = Enum.TextXAlignment.Center
				art.LayoutOrder = 2
				local creature = UiFactory.label(cardFrame, "body", UITheme.text.minSize, "Bone")
				creature.Size = UDim2.new(1, 0, 0, 32)
				creature.TextWrapped = true
				creature.Text = if type(offer.displayName) == "string" then offer.displayName else ""
				creature.LayoutOrder = 3
				local rarityLabel = UiFactory.label(cardFrame, "body", UITheme.text.minSize, "BoneDim")
				rarityLabel.Size = UDim2.new(1, 0, 0, 18)
				rarityLabel.LayoutOrder = 4
				local income = UiFactory.label(cardFrame, "income", UITheme.fonts.income.desktop, "GoldBright")
				income.Size = UDim2.new(1, 0, 0, 18)
				income.LayoutOrder = 5
				local priceLabel = UiFactory.label(cardFrame, "number", UITheme.fonts.number.desktop, "Bone")
				priceLabel.Size = UDim2.new(1, 0, 0, 18)
				priceLabel.LayoutOrder = 6
				local button = UiFactory.button(cardFrame, UITheme.text.minSize)
				button.Size = UDim2.new(1, 0, 0, 28)
				button.LayoutOrder = 7
				button.Text = Shop.BUY

				local card = {
					slot = offer.slot,
					speciesId = if type(offer.speciesId) == "string" then offer.speciesId else "",
					rarity = if type(offer.rarity) == "string" then offer.rarity else "Common",
					price = if type(offer.price) == "number" then offer.price else 0,
					rarityLabel = rarityLabel,
					art = art,
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
		clear(oddsLayer)
		for _, column in ShopStock.oddsColumns() do
			local columnFrame = Instance.new("Frame")
			columnFrame.Name = column.name
			columnFrame.BackgroundTransparency = 1
			columnFrame.Size = UDim2.new(0.25, -8, 1, 0)
			columnFrame.LayoutOrder = column.slot
			columnFrame.Parent = oddsLayer
			local list = Instance.new("UIListLayout")
			list.Padding = UDim.new(0, 2)
			list.SortOrder = Enum.SortOrder.LayoutOrder
			list.Parent = columnFrame
			local header = UiFactory.label(columnFrame, "body", UITheme.text.minSize, "Bone")
			header.Size = UDim2.new(1, 0, 0, 32)
			header.TextWrapped = true
			header.Text = column.name
			header.LayoutOrder = 0
			for rowIndex, row in column.rows do
				local token = UITheme.rarity[row.rarity]
				if token == nil then
					token = "BoneDim"
				end
				local line = UiFactory.label(columnFrame, "body", UITheme.text.minSize, token)
				line.Size = UDim2.new(1, 0, 0, 18)
				line.Text = row.rarity .. "  " .. tostring(row.percent) .. "%"
				line.LayoutOrder = rowIndex
			end
			local total = UiFactory.label(columnFrame, "number", UITheme.fonts.number.desktop, "Gold")
			total.Size = UDim2.new(1, 0, 0, 20)
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
		if mobile then
			local margin = Shop.PANEL.mobileMargin
			root.Size = UDim2.new(1, -margin * 2, 1, -margin * 2)
			grid.CellSize = UDim2.new(0.5, -8, 0.5, -8)
			grid.FillDirectionMaxCells = 2
		else
			root.Size = UDim2.fromOffset(Shop.PANEL.width, Shop.PANEL.height)
			grid.CellSize = UDim2.new(0.25, -8, 1, -8)
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
	oddsButton.Activated:Connect(function()
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
