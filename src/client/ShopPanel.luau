--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TarotPanel = require(script.Parent:WaitForChild("TarotPanel"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NumberFormat = require(Shared:WaitForChild("Logic"):WaitForChild("NumberFormat")) :: any
local PanelRange = require(Shared:WaitForChild("Logic"):WaitForChild("PanelRange")) :: any
local PedlarBrowse = require(Shared:WaitForChild("Logic"):WaitForChild("PedlarBrowse")) :: any
local Shop = require(Shared:WaitForChild("Config"):WaitForChild("Shop")) :: any
local ShopAnchors = require(Shared:WaitForChild("Config"):WaitForChild("ShopAnchors")) :: any
local ShopNotices = require(Shared:WaitForChild("Logic"):WaitForChild("ShopNotices")) :: any
local Town = require(Shared:WaitForChild("Config"):WaitForChild("Town")) :: any
local TownShops = require(Shared:WaitForChild("Config"):WaitForChild("TownShops")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local ShopPanel = {}

local function accent(gui: GuiObject, fillToken: string, glowToken: string)
	gui.BackgroundColor3 = UITheme.color(fillToken)
	local stroke = gui:FindFirstChildOfClass("UIStroke")
	if stroke ~= nil then
		stroke.Color = UITheme.color(glowToken)
		stroke.Thickness = UITheme.shape.strokePx
	end
end

local function fire(remotes: Folder, name: string, ...: any)
	local remote = remotes:WaitForChild(name) :: RemoteEvent
	remote:FireServer(...)
end

local function hostPart(inst: Instance?): BasePart?
	if inst == nil then
		return nil
	end
	if inst:IsA("BasePart") then
		return inst
	end
	if inst:IsA("Model") then
		if inst.PrimaryPart ~= nil then
			return inst.PrimaryPart
		end
		return inst:FindFirstChildWhichIsA("BasePart", true)
	end
	if inst:IsA("ProximityPrompt") then
		return hostPart(inst.Parent)
	end
	return nil
end

local function walkPath(root: Instance, path: any): Instance?
	if type(path) ~= "table" then
		return nil
	end
	local node: Instance? = root
	for _, name in path do
		if node == nil or type(name) ~= "string" then
			return nil
		end
		node = node:FindFirstChild(name)
	end
	return node
end

local function activationOf(prompt: Instance?): number
	if prompt ~= nil and prompt:IsA("ProximityPrompt") then
		local distance = prompt.MaxActivationDistance
		if type(distance) == "number" and distance == distance and distance > 0 and distance < math.huge then
			return distance
		end
	end
	return Town.PROMPT_DISTANCE
end

function ShopPanel.mount(
	parent: Instance,
	player: Player,
	remotes: Folder,
	names: any,
	camera: Camera,
	snapshotValue: StringValue
)
	local touch = UITheme.shape.touchPx
	local gap = UITheme.shape.plaqueGapPx
	local shownToken = -1
	local shownId = ""
	local counts: { [string]: number } = {}
	local noticeText: { [string]: string } = {}
	local anchorPart: BasePart? = nil
	local closeLimit = PanelRange.limit(Town.PROMPT_DISTANCE, Town.PANEL_HYSTERESIS)
	local lastSample = 0
	local rangeConn: RBXScriptConnection? = nil
	local diedConn: RBXScriptConnection? = nil
	local addedConn: RBXScriptConnection? = nil
	local removingConn: RBXScriptConnection? = nil

	local root = UiFactory.panel(parent)
	root.Name = "ShopPanel"
	root.Visible = false
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = UDim2.fromOffset(Shop.PANEL.width, Shop.PANEL.height)
	accent(root, "Void", "teal")

	local title = UiFactory.label(root, "display", UITheme.fonts.display.mobile, "Bone")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(gap, gap)
	title.Size = UDim2.new(1, -(touch * 2 + gap * 3), 0, touch)
	title.Text = ""

	local closeButton = UiFactory.button(root, UITheme.fonts.body.mobile)
	closeButton.Name = "Close"
	closeButton.Text = "Close"
	closeButton.Size = UDim2.fromOffset(touch * 2, touch)
	closeButton.Position = UDim2.new(1, -(touch * 2 + gap), 0, gap)

	local soon = UiFactory.label(root, "body", UITheme.fonts.body.desktop, "Bone")
	soon.Name = "Soon"
	soon.Text = "Coming soon."
	soon.TextWrapped = true
	soon.Visible = false
	soon.Position = UDim2.fromOffset(gap, touch + gap * 2)
	soon.Size = UDim2.new(1, -gap * 2, 0, touch)

	local list = Instance.new("ScrollingFrame")
	list.Name = "Items"
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = gap
	list.ScrollBarImageColor3 = UITheme.color("BoneDim")
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Position = UDim2.fromOffset(gap, touch + gap * 2)
	list.Size = UDim2.new(1, -gap * 2, 1, -(touch * 3 + gap * 4))
	list.Parent = root
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, gap)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	local function noticeLabel(name: string): TextLabel
		local label = UiFactory.label(root, "body", UITheme.fonts.body.desktop, "Bone")
		label.Name = name
		label.Text = ""
		label.TextWrapped = true
		label.Visible = false
		label.Position = UDim2.new(0, gap, 1, -(touch + gap))
		label.Size = UDim2.new(1, -gap * 2, 0, touch)
		return label
	end

	local pedlarNotice = noticeLabel("PedlarNotice")
	local shopNotice = noticeLabel("ShopNotice")
	local tarotNotice = noticeLabel("TarotNotice")

	local function pricePx(): number
		if camera.ViewportSize.X < UITheme.shape.mobileWidthBreakpoint then
			return UITheme.shape.priceLine.mobile
		end
		return UITheme.shape.priceLine.desktop
	end

	local function stopWatch()
		if rangeConn ~= nil then
			rangeConn:Disconnect()
			rangeConn = nil
		end
		if diedConn ~= nil then
			diedConn:Disconnect()
			diedConn = nil
		end
		if addedConn ~= nil then
			addedConn:Disconnect()
			addedConn = nil
		end
		if removingConn ~= nil then
			removingConn:Disconnect()
			removingConn = nil
		end
	end

	local function closePanel()
		root.Visible = false
		stopWatch()
	end

	local function paintNotice()
		local channel = ShopNotices.channel(ShopAnchors.get(shownId))
		local text = ""
		if shownId ~= "" then
			local stored = noticeText[shownId]
			if type(stored) == "string" then
				text = stored
			end
		end
		pedlarNotice.Text = if channel == "pedlar" then text else ""
		shopNotice.Text = if channel == "shop" then text else ""
		tarotNotice.Text = if channel == "tarot" then text else ""
		pedlarNotice.Visible = channel == "pedlar" and text ~= ""
		shopNotice.Visible = channel == "shop" and text ~= ""
		tarotNotice.Visible = channel == "tarot" and text ~= ""
	end

	local function bindAnchor(shopId: string)
		anchorPart = nil
		closeLimit = PanelRange.limit(Town.PROMPT_DISTANCE, Town.PANEL_HYSTERESIS)
		local town = workspace:FindFirstChild("Town")
		local entry = ShopAnchors.get(shopId)
		if town == nil or entry == nil then
			return
		end
		local prompt: Instance? = nil
		local host: Instance? = nil
		if entry.mode == "pedlar" then
			prompt = PedlarBrowse.findPrompt(town)
			if prompt == nil then
				host = walkPath(town, entry.fallbackPath)
			end
		else
			host = walkPath(town, entry.anchorPath)
		end
		if host ~= nil and prompt == nil then
			prompt = host:FindFirstChildWhichIsA("ProximityPrompt")
		end
		closeLimit = PanelRange.limit(activationOf(prompt), Town.PANEL_HYSTERESIS)
		local part = hostPart(host)
		if part == nil then
			part = hostPart(prompt)
		end
		anchorPart = part
	end

	local function watchRange()
		if not root.Visible then
			stopWatch()
			return
		end
		local now = os.clock()
		if not PanelRange.due(now, lastSample, Town.PANEL_POLL_SECONDS) then
			return
		end
		lastSample = now
		local part = anchorPart
		if part == nil or part.Parent == nil then
			return
		end
		local character = player.Character
		if character == nil then
			return
		end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart == nil or not rootPart:IsA("BasePart") then
			return
		end
		local distance = (rootPart.Position - part.Position).Magnitude
		if PanelRange.outOfRange(distance, closeLimit) then
			closePanel()
		end
	end

	local function bindLife(character: Model)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid ~= nil then
			diedConn = humanoid.Died:Connect(function()
				closePanel()
			end)
		end
	end

	local function startWatch()
		if rangeConn ~= nil then
			return
		end
		lastSample = 0
		rangeConn = RunService.Heartbeat:Connect(watchRange)
		local character = player.Character
		if character ~= nil then
			bindLife(character)
		end
		addedConn = player.CharacterAdded:Connect(function()
			closePanel()
		end)
		removingConn = player.CharacterRemoving:Connect(function()
			closePanel()
		end)
	end

	closeButton.MouseButton1Click:Connect(function()
		closePanel()
	end)

	local function readCounts()
		counts = {}
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(snapshotValue.Value)
		end)
		if ok and type(decoded) == "table" and type(decoded.wares) == "table" then
			for id, count in decoded.wares do
				if type(id) == "string" and type(count) == "number" then
					counts[id] = count
				end
			end
		end
	end

	local function clearCards()
		for _, child in list:GetChildren() do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
	end

	local function addButton(row: Instance, text: string, onClick: () -> ())
		local button = UiFactory.button(row, UITheme.fonts.body.mobile)
		button.Name = text
		button.Text = text
		button.Size = UDim2.fromOffset(touch * 2, touch)
		button.MouseButton1Click:Connect(onClick)
		return button
	end

	local function render(shopId: string): boolean
		local entry = ShopAnchors.get(shopId)
		if entry == nil then
			root.Visible = false
			return false
		end
		title.Text = entry.displayName
		local tent = entry.plug == "tarot"
		local comingSoon = not tent and not ShopAnchors.sells(entry)
		soon.Visible = comingSoon
		list.Visible = not comingSoon
		clearCards()
		if tent then
			TarotPanel.fill(list, snapshotValue, remotes, names, gap, pricePx(), UITheme.shape.priceLine.color)
			return true
		end
		if comingSoon then
			return true
		end
		readCounts()
		local linePx = pricePx()
		for index, item in TownShops.items(entry.catalogueId) do
			local card = UiFactory.panel(list)
			card.Name = item.id
			card.LayoutOrder = index
			card.AutomaticSize = Enum.AutomaticSize.Y
			card.Size = UDim2.fromScale(1, 0)
			accent(card, "Ash", "violet")
			local pad = Instance.new("UIPadding")
			pad.PaddingTop = UDim.new(0, gap)
			pad.PaddingBottom = UDim.new(0, gap)
			pad.PaddingLeft = UDim.new(0, gap)
			pad.PaddingRight = UDim.new(0, gap)
			pad.Parent = card
			local stack = Instance.new("UIListLayout")
			stack.Padding = UDim.new(0, gap)
			stack.SortOrder = Enum.SortOrder.LayoutOrder
			stack.Parent = card

			local nameLabel = UiFactory.label(card, "header", UITheme.fonts.header.mobile, "Bone")
			nameLabel.Name = "Name"
			nameLabel.LayoutOrder = 1
			nameLabel.AutomaticSize = Enum.AutomaticSize.Y
			nameLabel.Size = UDim2.fromScale(1, 0)
			nameLabel.TextWrapped = true
			nameLabel.Text = item.name

			local effectLabel = UiFactory.label(card, "body", UITheme.fonts.body.mobile, "BoneDim")
			effectLabel.Name = "Effect"
			effectLabel.LayoutOrder = 2
			effectLabel.AutomaticSize = Enum.AutomaticSize.Y
			effectLabel.Size = UDim2.fromScale(1, 0)
			effectLabel.TextWrapped = true
			effectLabel.Text = item.effect

			local priceLabel = UiFactory.label(card, "number", linePx, UITheme.shape.priceLine.color)
			priceLabel.Name = "Price"
			priceLabel.LayoutOrder = 3
			priceLabel.Size = UDim2.new(1, 0, 0, touch)
			priceLabel.TextWrapped = true
			if item.kind == "later" then
				priceLabel.Text = "Coming later."
			else
				local ownedCount = counts[item.id]
				local ownedText = if type(ownedCount) == "number" and ownedCount > 0
					then "  ·  kept " .. tostring(ownedCount)
					else ""
				priceLabel.Text = NumberFormat.formatCash(item.price) .. ownedText
			end

			if item.kind ~= "later" then
				local row = Instance.new("Frame")
				row.Name = "Actions"
				row.LayoutOrder = 4
				row.BackgroundTransparency = 1
				row.Size = UDim2.new(1, 0, 0, touch)
				row.Parent = card
				local actions = Instance.new("UIListLayout")
				actions.FillDirection = Enum.FillDirection.Horizontal
				actions.Padding = UDim.new(0, gap)
				actions.Parent = row
				addButton(row, "Buy", function()
					fire(remotes, names.SHOP_BUY, shopId, item.id, HttpService:GenerateGUID(false), 1)
				end)
				if item.kind == "supply" then
					addButton(row, "Sell", function()
						fire(remotes, names.SHOP_SELL, shopId, item.id, HttpService:GenerateGUID(false), 1)
					end)
				end
			end
		end
		return true
	end

	local function showShop(shopId: string)
		local opening = not root.Visible or shopId ~= shownId
		if render(shopId) ~= true then
			shownId = ""
			stopWatch()
			return
		end
		shownId = shopId
		if opening then
			noticeText[shopId] = ShopNotices.onOpen(shopId)
		end
		root.Visible = true
		paintNotice()
		bindAnchor(shopId)
		startWatch()
	end

	local function showFromServer()
		local token = player:GetAttribute(ShopAnchors.OPEN_TOKEN)
		local shopId = player:GetAttribute(ShopAnchors.OPEN_ID)
		if type(token) ~= "number" or type(shopId) ~= "string" then
			return
		end
		if ShopAnchors.get(shopId) == nil then
			closePanel()
			return
		end
		if token == shownToken and shopId == shownId and root.Visible then
			return
		end
		shownToken = token
		showShop(shopId)
	end

	local function placePanel()
		local width = Shop.PANEL.width
		local height = Shop.PANEL.height
		if camera.ViewportSize.X < UITheme.shape.mobileWidthBreakpoint then
			local margin = Shop.PANEL.mobileMargin
			width = camera.ViewportSize.X - margin * 2
			height = camera.ViewportSize.Y - margin * 2
		end
		root.Size = UDim2.fromOffset(math.max(width, touch * 4), math.max(height, touch * 4))
		if root.Visible and shownId ~= "" then
			render(shownId)
		end
	end

	local function onPedlarNotice()
		local message = player:GetAttribute(Shop.NOTICE)
		if type(message) ~= "string" or message == "" then
			return
		end
		if not root.Visible or not ShopNotices.accept(shownId, ShopAnchors.PEDLAR_ID) then
			return
		end
		noticeText[ShopAnchors.PEDLAR_ID] = message
		paintNotice()
	end

	local function onShopNotice()
		local message = player:GetAttribute(ShopAnchors.NOTICE)
		local noticeShop = player:GetAttribute(ShopAnchors.NOTICE_SHOP)
		if type(message) ~= "string" or message == "" or type(noticeShop) ~= "string" then
			return
		end
		if not root.Visible or not ShopNotices.accept(shownId, noticeShop) then
			return
		end
		noticeText[noticeShop] = message
		paintNotice()
	end

	player:GetAttributeChangedSignal(ShopAnchors.OPEN_TOKEN):Connect(showFromServer)
	player:GetAttributeChangedSignal(Shop.OPEN_TOKEN):Connect(function()
		local token = player:GetAttribute(Shop.OPEN_TOKEN)
		if type(token) ~= "number" then
			return
		end
		showShop(ShopAnchors.PEDLAR_ID)
	end)
	player:GetAttributeChangedSignal(Shop.NOTICE_TOKEN):Connect(onPedlarNotice)
	player:GetAttributeChangedSignal(ShopAnchors.NOTICE_TOKEN):Connect(onShopNotice)
	snapshotValue.Changed:Connect(function()
		if root.Visible and shownId ~= "" then
			render(shownId)
		end
	end)
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(placePanel)
	placePanel()
	if player:GetAttribute(ShopAnchors.OPEN_TOKEN) ~= nil then
		showFromServer()
	end
end

return ShopPanel
