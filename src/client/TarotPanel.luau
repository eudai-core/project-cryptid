--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local TarotPanel = {}

local function accent(gui: GuiObject, fillToken: string, glowToken: string)
	gui.BackgroundColor3 = UITheme.color(fillToken)
	local stroke = gui:FindFirstChildOfClass("UIStroke")
	if stroke ~= nil then
		stroke.Color = UITheme.color(glowToken)
		stroke.Thickness = UITheme.shape.strokePx
	end
end

local function fire(remotes: Folder, name: string, caseId: string)
	local remote = remotes:WaitForChild(name) :: RemoteEvent
	remote:FireServer(caseId, HttpService:GenerateGUID(false))
end

local function addLine(
	parent: Instance,
	name: string,
	text: string,
	order: number,
	role: string,
	font: number,
	color: string
)
	local label = UiFactory.label(parent, role, font, color)
	label.Name = name
	label.LayoutOrder = order
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Size = UDim2.fromScale(1, 0)
	label.TextWrapped = true
	label.Text = text
	return label
end

function TarotPanel.fill(
	list: ScrollingFrame,
	snapshotValue: StringValue,
	remotes: Folder,
	names: any,
	gap: number,
	pricePx: number,
	priceColor: string
)
	local touch = UITheme.shape.touchPx
	local tent = nil
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(snapshotValue.Value)
	end)
	if ok and type(decoded) == "table" then
		tent = decoded.tarot
	end
	if type(tent) ~= "table" or type(tent.cases) ~= "table" then
		local quiet = UiFactory.panel(list)
		quiet.Name = "Quiet"
		quiet.Size = UDim2.new(1, 0, 0, touch)
		accent(quiet, "Ash", "violet")
		local label = UiFactory.label(quiet, "body", UITheme.fonts.body.mobile, "Bone")
		label.Size = UDim2.fromScale(1, 1)
		label.Text = "The tent is quiet."
		return
	end

	local note = UiFactory.panel(list)
	note.Name = "OddsNote"
	note.LayoutOrder = 0
	note.AutomaticSize = Enum.AutomaticSize.Y
	note.Size = UDim2.fromScale(1, 0)
	accent(note, "Ash", "teal")
	local notePad = Instance.new("UIPadding")
	notePad.PaddingTop = UDim.new(0, gap)
	notePad.PaddingBottom = UDim.new(0, gap)
	notePad.PaddingLeft = UDim.new(0, gap)
	notePad.PaddingRight = UDim.new(0, gap)
	notePad.Parent = note
	local noteText = if type(tent.oddsNote) == "string" then tent.oddsNote else ""
	addLine(note, "Copy", noteText, 1, "body", pricePx, priceColor)

	for index, card in tent.cases do
		if type(card) == "table" and type(card.id) == "string" then
			local frame = UiFactory.panel(list)
			frame.Name = card.id
			frame.LayoutOrder = index
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.Size = UDim2.fromScale(1, 0)
			accent(frame, "Ash", "violet")
			local pad = Instance.new("UIPadding")
			pad.PaddingTop = UDim.new(0, gap)
			pad.PaddingBottom = UDim.new(0, gap)
			pad.PaddingLeft = UDim.new(0, gap)
			pad.PaddingRight = UDim.new(0, gap)
			pad.Parent = frame
			local stack = Instance.new("UIListLayout")
			stack.Padding = UDim.new(0, gap)
			stack.SortOrder = Enum.SortOrder.LayoutOrder
			stack.Parent = frame

			local title = if type(card.name) == "string" then card.name else card.id
			local held = if type(card.count) == "number" then tostring(card.count) else "0"
			addLine(frame, "Name", title .. "  ·  " .. held, 1, "header", UITheme.fonts.header.mobile, "Bone")

			local order = 2
			if type(card.odds) == "table" then
				for _, row in card.odds do
					if type(row) == "table" and type(row.rarity) == "string" and type(row.text) == "string" then
						addLine(frame, row.rarity, row.rarity .. " " .. row.text, order, "body", pricePx, priceColor)
						order += 1
					end
				end
			end
			if type(card.pityLine) == "string" then
				addLine(frame, "Pity", card.pityLine, order, "body", UITheme.fonts.body.mobile, "GoldBright")
				order += 1
			end
			if type(card.duplicateLine) == "string" then
				addLine(frame, "Duplicates", card.duplicateLine, order, "body", pricePx, priceColor)
				order += 1
			end
			if type(card.endsText) == "string" and card.endsText ~= "" then
				addLine(frame, "Ends", card.endsText, order, "body", UITheme.fonts.body.mobile, "Bone")
				order += 1
			end
			if type(card.button) == "string" and type(card.action) == "string" then
				local button = UiFactory.button(frame, UITheme.fonts.body.mobile)
				button.Name = "Action"
				button.LayoutOrder = order
				button.Text = card.button
				button.Size = UDim2.new(1, 0, 0, touch)
				local caseId = card.id
				local action = card.action
				button.MouseButton1Click:Connect(function()
					local remoteName = if action == "buy" then names.TAROT_BUY else names.TAROT_OPEN
					fire(remotes, remoteName, caseId)
				end)
			end
		end
	end

	local reveal = tent.reveal
	if type(reveal) == "table" and type(reveal.text) == "string" then
		local shown = UiFactory.panel(list)
		shown.Name = "Reveal"
		shown.LayoutOrder = 100
		shown.AutomaticSize = Enum.AutomaticSize.Y
		shown.Size = UDim2.fromScale(1, 0)
		accent(shown, "Void", "teal")
		local revealPad = Instance.new("UIPadding")
		revealPad.PaddingTop = UDim.new(0, gap)
		revealPad.PaddingBottom = UDim.new(0, gap)
		revealPad.PaddingLeft = UDim.new(0, gap)
		revealPad.PaddingRight = UDim.new(0, gap)
		revealPad.Parent = shown
		addLine(shown, "Result", reveal.text, 1, "header", UITheme.fonts.header.mobile, "Bone")
	end
end

return TarotPanel
