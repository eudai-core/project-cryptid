--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local RebirthPanel = {}

local function wrapped(parent: Instance, role: string, size: number, colorToken: string): TextLabel
	local label = UiFactory.label(parent, role, size, colorToken)
	label.TextWrapped = true
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Size = UDim2.fromScale(1, 0)
	ThemeBind.apply(label, role, size)
	return label
end

function RebirthPanel.mount(parent: Instance, _isReduced: () -> boolean, fire: (string) -> ())
	local spec = UITheme.shape.rebirthPanel
	local root = UiFactory.panel(parent)
	root.Name = "RiteOfRebirth"
	root.Visible = false
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = UDim2.fromOffset(spec.desktop.w, spec.desktop.h)

	local toast = UiFactory.label(root, "body", spec.body, "GoldBright")
	toast.Name = "RebirthToast"
	toast.Position = UDim2.fromOffset(spec.detail, 8)
	toast.Size = UDim2.new(1, -spec.detail * 2, 0, spec.choiceH / 2)
	toast.TextXAlignment = Enum.TextXAlignment.Center
	toast.Visible = false
	ThemeBind.apply(toast, "body", spec.body)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Body"
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Position = UDim2.fromOffset(spec.detail, 36)
	scroll.Size = UDim2.new(1, -spec.detail * 2, 1, -108)
	scroll.CanvasSize = UDim2.new()
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollBarThickness = UITheme.shape.plaqueGapPx
	scroll.ScrollBarImageColor3 = UITheme.color("Gold")
	scroll.Parent = root
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, UITheme.shape.plaqueGapPx)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = scroll

	local title = wrapped(scroll, "header", spec.title, "Bone")
	local body = wrapped(scroll, "body", spec.body, "BoneDim")
	local keepTitle = wrapped(scroll, "header", spec.body, "GoldBright")
	local keepBody = wrapped(scroll, "body", spec.detail, "Bone")
	local loseTitle = wrapped(scroll, "header", spec.body, "Blood")
	local loseBody = wrapped(scroll, "body", spec.detail, "Bone")
	local multiplier = wrapped(scroll, "body", spec.body, "GoldBright")
	local cost = wrapped(scroll, "body", spec.body, "Bone")
	local tithe = wrapped(scroll, "body", spec.detail, "BoneDim")
	local track = Instance.new("Frame")
	track.Name = "TitheBar"
	track.BackgroundColor3 = UITheme.color("Soot")
	track.BorderSizePixel = 0
	track.Size = UDim2.new(1, 0, 0, spec.barH)
	track.Parent = scroll
	UiFactory.corner(track)
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = UITheme.color("GoldBright")
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = track
	UiFactory.corner(fill)
	local picker = wrapped(scroll, "body", spec.detail, "Bone")
	local choices = Instance.new("Frame")
	choices.Name = "Choices"
	choices.BackgroundTransparency = 1
	choices.Size = UDim2.fromScale(1, 0)
	choices.AutomaticSize = Enum.AutomaticSize.Y
	choices.Parent = scroll
	local choiceList = Instance.new("UIListLayout")
	choiceList.Padding = UDim.new(0, UITheme.shape.plaqueGapPx / 2)
	choiceList.Parent = choices

	local begin = UiFactory.button(root, spec.body)
	begin.Name = "Begin"
	begin.AnchorPoint = Vector2.new(1, 1)
	begin.Position = UDim2.new(1, -spec.detail, 1, -spec.detail)
	begin.Size = UDim2.fromOffset(spec.buttonW, UITheme.shape.touchPx)
	local dismiss = UiFactory.button(root, spec.body)
	dismiss.Name = "NotYet"
	dismiss.AnchorPoint = Vector2.new(0, 1)
	dismiss.Position = UDim2.new(0, spec.detail, 1, -spec.detail)
	dismiss.Size = UDim2.fromOffset(spec.buttonW, UITheme.shape.touchPx)
	dismiss.BackgroundColor3 = UITheme.color("Soot")

	local latest: any = nil
	local selected = ""
	local confirming = false
	local seenNotice = 0

	local function choiceStillThere(view: any): boolean
		if type(view.choices) ~= "table" then
			return false
		end
		for _, choice in view.choices do
			if choice.instanceId == selected then
				return true
			end
		end
		return false
	end

	local paint
	local function paintChoices(view: any)
		for _, child in choices:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		if type(view.choices) ~= "table" then
			return
		end
		for _, choice in view.choices do
			local button = UiFactory.button(choices, spec.detail)
			button.Size = UDim2.new(1, 0, 0, spec.choiceH)
			button.BackgroundColor3 = if choice.instanceId == selected
				then UITheme.color("Blood")
				else UITheme.color("Soot")
			button.Text = choice.displayName .. "  " .. choice.incomeText
			button.Activated:Connect(function()
				selected = choice.instanceId
				confirming = false
				if root.Visible then
					paint()
				end
			end)
		end
	end

	paint = function()
		local view = latest
		if type(view) ~= "table" or view.revealed ~= true then
			root.Visible = false
			return
		end
		if not choiceStillThere(view) then
			selected = ""
		end
		title.Text = view.title
		body.Text = view.body
		keepTitle.Text = view.keepTitle
		keepBody.Text = view.keepBody
		loseTitle.Text = view.loseTitle
		loseBody.Text = view.loseBody
		multiplier.Text = view.multiplierText
		cost.Text = view.costText
		tithe.Text = view.titheText
		local ratio = view.bar
		if type(ratio) ~= "number" then
			ratio = 0
		end
		fill.Size = UDim2.fromScale(ratio, 1)
		picker.Text = view.picker
		paintChoices(view)
		dismiss.Text = view.notYet
		local picked = view.needsFamiliar ~= true or selected ~= ""
		local ready = view.canBegin == true and picked
		if confirming and ready then
			begin.Text = view.yes
			begin.Active = true
			begin.AutoButtonColor = false
			begin.BackgroundColor3 = UITheme.color("Blood")
			body.Text = view.second
		elseif ready then
			begin.Text = view.confirm
			begin.Active = true
			begin.BackgroundColor3 = UITheme.color("Blood")
		else
			confirming = false
			local reason = view.blockReason
			if type(reason) ~= "string" or reason == "" then
				reason = view.picker
			end
			begin.Text = reason
			begin.Active = false
			begin.BackgroundColor3 = UITheme.color("Soot")
		end
	end

	begin.Activated:Connect(function()
		local view = latest
		if type(view) ~= "table" or view.canBegin ~= true then
			return
		end
		if view.needsFamiliar == true and selected == "" then
			return
		end
		if not confirming then
			confirming = true
			paint()
			return
		end
		local uid = selected
		if view.needsFamiliar ~= true then
			uid = ""
		end
		confirming = false
		fire(uid)
	end)
	dismiss.Activated:Connect(function()
		if confirming then
			confirming = false
			paint()
			return
		end
		root.Visible = false
	end)

	local api = {}

	function api.apply(snapshot: any)
		local view = nil
		if type(snapshot) == "table" then
			view = snapshot.rebirth
		end
		latest = view
		if type(view) == "table" and type(view.noticeSerial) == "number" and view.noticeSerial ~= seenNotice then
			seenNotice = view.noticeSerial
			local text = view.noticeText
			toast.Text = if type(text) == "string" then text else ""
			toast.Visible = toast.Text ~= ""
		end
		if root.Visible then
			paint()
		end
	end

	function api.open()
		if type(latest) ~= "table" or latest.revealed ~= true then
			return
		end
		confirming = false
		root.Visible = true
		paint()
	end

	function api.layout(mobile: boolean)
		local width = spec.desktop.w
		local height = spec.desktop.h
		if mobile then
			height = spec.mobileH
			width = math.min(spec.desktop.w, 360)
		end
		root.Size = UDim2.fromOffset(width, height)
	end

	return api
end

return RebirthPanel
