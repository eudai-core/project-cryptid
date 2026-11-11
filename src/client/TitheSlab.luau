--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Board = require(Shared:WaitForChild("Config"):WaitForChild("TitheBoard")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local TitheSlab = {}

function TitheSlab.start()
	local spec = UITheme.shape.titheBoard
	local mounted: { [BasePart]: any } = {}
	local payload = {
		message = "",
		rows = {},
	}

	local function ensure(part: BasePart)
		local existing = mounted[part]
		if existing ~= nil then
			return existing
		end
		local gui = Instance.new("SurfaceGui")
		gui.Name = "TitheLedger"
		gui.Face = Enum.NormalId.Left
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = UITheme.shape.touchPx
		gui.Parent = part
		local panel = UiFactory.panel(gui)
		panel.Size = UDim2.fromScale(1, 1)
		local title = UiFactory.label(panel, "header", spec.title, "Bone")
		title.Position = UDim2.fromOffset(spec.pad, spec.pad)
		title.Size = UDim2.new(1, -spec.pad * 2, 0, spec.title)
		title.Text = Board.TITLE
		title.TextXAlignment = Enum.TextXAlignment.Center
		ThemeBind.apply(title, "header", spec.title)
		local message = UiFactory.label(panel, "body", spec.row, "BoneDim")
		message.Name = "Message"
		message.Position = UDim2.fromOffset(spec.pad, spec.pad + spec.title)
		message.Size = UDim2.new(1, -spec.pad * 2, 0, spec.row + spec.pad)
		message.TextWrapped = true
		message.TextXAlignment = Enum.TextXAlignment.Center
		ThemeBind.apply(message, "body", spec.row)
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Rows"
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.Position = UDim2.fromOffset(spec.pad, spec.pad * 2 + spec.title + spec.row)
		scroll.Size = UDim2.new(1, -spec.pad * 2, 1, -(spec.pad * 3 + spec.title + spec.row))
		scroll.CanvasSize = UDim2.new()
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.ScrollBarThickness = UITheme.shape.plaqueGapPx
		scroll.ScrollBarImageColor3 = UITheme.color("Gold")
		scroll.Parent = panel
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, UITheme.shape.plaqueGapPx / 2)
		layout.Parent = scroll
		local record = {
			message = message,
			scroll = scroll,
		}
		mounted[part] = record
		return record
	end

	local function paint()
		for part, record in mounted do
			if part.Parent == nil then
				mounted[part] = nil
				continue
			end
			record.message.Text = payload.message
			local scroll = record.scroll
			for _, child in scroll:GetChildren() do
				if child:IsA("TextLabel") then
					child:Destroy()
				end
			end
			if type(payload.rows) ~= "table" then
				continue
			end
			for _, row in payload.rows do
				if type(row) == "table" then
					local line = UiFactory.label(scroll, "body", spec.row, "Bone")
					line.Size = UDim2.new(1, 0, 0, spec.row + UITheme.shape.plaqueGapPx)
					local name = if type(row.name) == "string" then row.name else ""
					local score = if type(row.label) == "string" then row.label else ""
					line.Text = name .. "  " .. score
					ThemeBind.apply(line, "body", spec.row)
				end
			end
		end
	end

	local function applyText(text: string)
		if text == "" then
			payload = { message = Board.REWRITING, rows = payload.rows }
			paint()
			return
		end
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(text)
		end)
		if not ok or type(decoded) ~= "table" then
			payload = { message = Board.REWRITING, rows = payload.rows }
			paint()
			return
		end
		payload = {
			message = if type(decoded.message) == "string" then decoded.message else "",
			rows = if type(decoded.rows) == "table" then decoded.rows else {},
		}
		paint()
	end

	local function hook(inst: Instance)
		if not inst:IsA("BasePart") then
			return
		end
		ensure(inst)
		paint()
	end

	CollectionService:GetInstanceAddedSignal(Board.TAG):Connect(hook)
	for _, inst in CollectionService:GetTagged(Board.TAG) do
		hook(inst)
	end

	local folder = ReplicatedStorage:WaitForChild("TitheState")
	local value = folder:WaitForChild("Board") :: StringValue
	value.Changed:Connect(applyText)
	applyText(value.Value)
end

return TitheSlab
