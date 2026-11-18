--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NumberFormat = require(Shared:WaitForChild("Logic"):WaitForChild("NumberFormat")) :: any
local Shop = require(Shared:WaitForChild("Config"):WaitForChild("Shop")) :: any
local ShopAnchors = require(Shared:WaitForChild("Config"):WaitForChild("ShopAnchors")) :: any
local TownShops = require(Shared:WaitForChild("Config"):WaitForChild("TownShops")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local ShopPanel = {}

local function fire(remotes: Folder, name: string, ...: any)
	local remote = remotes:WaitForChild(name) :: RemoteEvent
	remote:FireServer(...)
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

	local root = UiFactory.panel(parent)
	root.Name = "ShopPanel"
	root.Visible = false
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = UDim2.fromOffset(Shop.PANEL.width, Shop.PANEL.height)

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
	closeButton.MouseButton1Click:Connect(function()
		root.Visible = false
	end)

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
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Position = UDim2.fromOffset(gap, touch + gap * 2)
	list.Size = UDim2.new(1, -gap * 2, 1, -(touch * 3 + gap * 4))
	list.Parent = root
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, gap)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	local toast = UiFactory.label(root, "body", UITheme.fonts.body.mobile, "GoldBright")
	toast.Name = "Result"
	toast.Text = ""
	toast.TextWrapped = true
	toast.Position = UDim2.new(0, gap, 1, -(touch + gap))
	toast.Size = UDim2.new(1, -gap * 2, 0, touch)

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

	local function render(shopId: string)
		local entry = ShopAnchors.get(shopId)
		if entry == nil then
			root.Visible = false
			return
		end
		title.Text = entry.displayName
		local comingSoon = not ShopAnchors.sells(entry)
		soon.Visible = comingSoon
		list.Visible = not comingSoon
		clearCards()
		if comingSoon then
			return
		end
		readCounts()
		for index, item in TownShops.items(entry.catalogueId) do
			local card = UiFactory.panel(list)
			card.Name = item.id
			card.LayoutOrder = index
			card.AutomaticSize = Enum.AutomaticSize.Y
			card.Size = UDim2.fromScale(1, 0)
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

			local priceLabel = UiFactory.label(card, "number", UITheme.fonts.number.mobile, "GoldBright")
			priceLabel.Name = "Price"
			priceLabel.LayoutOrder = 3
			priceLabel.Size = UDim2.new(1, 0, 0, touch)
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
	end

	local function showFromServer()
		local token = player:GetAttribute(ShopAnchors.OPEN_TOKEN)
		local shopId = player:GetAttribute(ShopAnchors.OPEN_ID)
		if type(token) ~= "number" or type(shopId) ~= "string" then
			return
		end
		if ShopAnchors.get(shopId) == nil then
			root.Visible = false
			return
		end
		if token == shownToken and shopId == shownId and root.Visible then
			return
		end
		shownToken = token
		shownId = shopId
		render(shopId)
		root.Visible = true
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
	end

	player:GetAttributeChangedSignal(ShopAnchors.OPEN_TOKEN):Connect(showFromServer)
	player:GetAttributeChangedSignal(ShopAnchors.NOTICE_TOKEN):Connect(function()
		local message = player:GetAttribute(ShopAnchors.NOTICE)
		if type(message) == "string" and message ~= "" then
			toast.Text = message
		end
	end)
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
