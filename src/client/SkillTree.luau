--!strict

local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Motion = require(script.Parent:WaitForChild("Motion"))
local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local HudSlots = require(Shared:WaitForChild("Logic"):WaitForChild("HudSlots")) :: any
local Names = require(Shared:WaitForChild("Config"):WaitForChild("Remotes")) :: any
local NumberFormat = require(Shared:WaitForChild("Logic"):WaitForChild("NumberFormat")) :: any
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local Shop = require(Shared:WaitForChild("Config"):WaitForChild("Shop")) :: any
local SkillConfig = require(Shared:WaitForChild("Config"):WaitForChild("SkillConfig")) :: any
local SkillRules = require(Shared:WaitForChild("Logic"):WaitForChild("SkillTree")) :: any
local Town = require(Shared:WaitForChild("Config"):WaitForChild("Town")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local ACTION = "CryptidRitesLock"
local SkillTree = {}

function SkillTree.mount(parent: Instance, player: Player, isReduced: () -> boolean)
	local ui = SkillConfig.UI
	local host = parent
	if parent:IsA("ScreenGui") and parent.Parent ~= nil then
		host = parent.Parent
	end

	local screen = Instance.new("ScreenGui")
	screen.Name = "SkillTree"
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.DisplayOrder = ui.displayOrder
	screen.Enabled = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = host

	local group = Instance.new("CanvasGroup")
	group.Name = "Circle"
	group.Size = UDim2.fromScale(1, 1)
	group.BackgroundTransparency = 1
	group.GroupTransparency = 1
	group.Parent = screen

	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = UITheme.color("Void")
	backdrop.BackgroundTransparency = 0
	backdrop.BorderSizePixel = 0
	backdrop.Active = true
	backdrop.Parent = group

	local viewport = Instance.new("Frame")
	viewport.Name = "Viewport"
	viewport.Size = UDim2.fromScale(1, 1)
	viewport.BackgroundTransparency = 1
	viewport.BorderSizePixel = 0
	viewport.ClipsDescendants = true
	viewport.Active = true
	viewport.Parent = group

	local canvas = Instance.new("Frame")
	canvas.Name = "Canvas"
	canvas.AnchorPoint = Vector2.new(0.5, 0.5)
	canvas.Position = UDim2.fromScale(0.5, 0.5)
	canvas.Size = UDim2.fromOffset(ui.canvas, ui.canvas)
	canvas.BackgroundColor3 = UITheme.color("Ash")
	canvas.BorderSizePixel = 0
	canvas.Parent = viewport
	local canvasScale = Instance.new("UIScale")
	canvasScale.Scale = ui.zoomDefault
	canvasScale.Parent = canvas

	local center = ui.canvas / 2
	for _, radius in ui.rings do
		local ring = Instance.new("Frame")
		ring.Name = "Ring"
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Position = UDim2.fromOffset(center, center)
		ring.Size = UDim2.fromOffset(radius * 2, radius * 2)
		ring.BackgroundTransparency = 1
		ring.BorderSizePixel = 0
		ring.ZIndex = 1
		ring.Parent = canvas
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = ring
		local stroke = Instance.new("UIStroke")
		stroke.Color = UITheme.color("Bone")
		stroke.Thickness = ui.ringThickness
		stroke.Transparency = ui.ringTransparency
		stroke.Parent = ring
	end

	for index = 1, ui.runeCount do
		local angle = (index / ui.runeCount) * math.pi * 2
		local rune = UiFactory.label(canvas, "display", ui.small, "BoneDim")
		rune.Name = "Rune"
		rune.AnchorPoint = Vector2.new(0.5, 0.5)
		rune.Position =
			UDim2.fromOffset(center + math.cos(angle) * ui.runeRadius, center + math.sin(angle) * ui.runeRadius)
		rune.Size = UDim2.fromOffset(ui.touchMin, ui.touchMin)
		rune.Text = UITheme.sigil
		rune.TextXAlignment = Enum.TextXAlignment.Center
		rune.ZIndex = 1
	end

	local function branchLabel(text: string, point: any)
		local label = UiFactory.label(canvas, "display", ui.branchLabel, "Gold")
		label.Name = text
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Position = UDim2.fromOffset(center + point.x, center + point.y)
		label.Size = UDim2.fromOffset(ui.capstone * 4, ui.branchLabel + ui.headerPad)
		label.Text = text
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextTransparency = ui.branchTransparency
		label.ZIndex = 2
	end
	branchLabel(SkillConfig.HUNTER_LABEL, ui.branchHunter)
	branchLabel(SkillConfig.LAIR_LABEL, ui.branchLair)

	local pathLayer = Instance.new("Folder")
	pathLayer.Name = "Paths"
	pathLayer.Parent = canvas
	local nodeLayer = Instance.new("Folder")
	nodeLayer.Name = "Nodes"
	nodeLayer.Parent = canvas

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.Position = UDim2.fromOffset(ui.headerPad, ui.headerPad)
	header.Size = UDim2.new(1, -ui.closeWidth - ui.headerPad * 3, 0, ui.headerTitle + ui.cost)
	header.ZIndex = 8
	header.Parent = group
	local title = UiFactory.label(header, "display", ui.headerTitle, "Bone")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, ui.headerTitle)
	title.Text = SkillConfig.TITLE
	local cashLabel = UiFactory.label(header, "number", ui.cost, "GoldBright")
	cashLabel.Name = "Cash"
	cashLabel.Position = UDim2.fromOffset(0, ui.headerTitle)
	cashLabel.Size = UDim2.new(1, 0, 0, ui.cost)
	cashLabel.Text = NumberFormat.formatCash(0)

	local closeButton = UiFactory.button(group, ui.small)
	closeButton.Name = "Close"
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -ui.headerPad, 0, ui.headerPad)
	closeButton.Size = UDim2.fromOffset(ui.closeWidth, ui.closeHeight)
	closeButton.BackgroundColor3 = UITheme.color("Soot")
	closeButton.TextColor3 = UITheme.color("Bone")
	closeButton.Text = SkillConfig.CLOSE_LABEL
	closeButton.ZIndex = 9

	local tooltip = Instance.new("Frame")
	tooltip.Name = "Tooltip"
	tooltip.Size = UDim2.fromOffset(ui.tooltipW, ui.tooltipH)
	tooltip.BackgroundColor3 = UITheme.color("Bone")
	tooltip.BorderSizePixel = 0
	tooltip.Visible = false
	tooltip.ZIndex = 12
	tooltip.Parent = group
	UiFactory.corner(tooltip)
	UiFactory.stroke(tooltip, "Gold", UITheme.shape.strokePx, 0)
	local tipTitle = UiFactory.label(tooltip, "display", ui.tooltipTitle, "Void")
	tipTitle.Name = "Title"
	tipTitle.Position = UDim2.fromOffset(ui.headerPad, ui.headerPad)
	tipTitle.Size = UDim2.new(1, -ui.buySeal - ui.headerPad * 2, 0, ui.headerTitle)
	tipTitle.TextColor3 = UITheme.color("Void")
	local tipBranch = UiFactory.label(tooltip, "body", ui.small, "Blood")
	tipBranch.Name = "Branch"
	tipBranch.Position = UDim2.fromOffset(ui.headerPad, ui.headerPad + ui.headerTitle)
	tipBranch.Size = UDim2.new(1, -ui.buySeal - ui.headerPad * 2, 0, ui.body)
	tipBranch.TextColor3 = UITheme.color("Blood")
	local tipEffect = UiFactory.label(tooltip, "body", ui.body, "Void")
	tipEffect.Name = "Effect"
	tipEffect.Position = UDim2.fromOffset(ui.headerPad, ui.headerPad + ui.headerTitle + ui.body)
	tipEffect.Size = UDim2.new(1, -ui.headerPad * 2, 0, ui.body * 2)
	tipEffect.TextWrapped = true
	tipEffect.TextYAlignment = Enum.TextYAlignment.Top
	tipEffect.TextColor3 = UITheme.color("Void")
	local tipExtra = UiFactory.label(tooltip, "body", ui.small, "Void")
	tipExtra.Name = "Extra"
	tipExtra.Position = UDim2.fromOffset(ui.headerPad, ui.tooltipH - ui.buySeal - ui.small)
	tipExtra.Size = UDim2.new(1, -ui.buySeal - ui.headerPad * 2, 0, ui.small * 2)
	tipExtra.TextWrapped = true
	tipExtra.TextYAlignment = Enum.TextYAlignment.Top
	tipExtra.TextColor3 = UITheme.color("Void")
	local tipCost = UiFactory.label(tooltip, "number", ui.cost, "Void")
	tipCost.Name = "Cost"
	tipCost.Position = UDim2.fromOffset(ui.headerPad, ui.tooltipH - ui.cost - ui.headerPad)
	tipCost.Size = UDim2.new(1, -ui.buySeal - ui.headerPad * 2, 0, ui.cost)
	tipCost.TextColor3 = UITheme.color("Void")
	local buySeal = UiFactory.button(tooltip, ui.buyText)
	buySeal.Name = "Buy"
	buySeal.AnchorPoint = Vector2.new(1, 1)
	buySeal.Position = UDim2.new(1, -ui.headerPad, 1, -ui.headerPad)
	buySeal.Size = UDim2.fromOffset(ui.buySeal, ui.buySeal)
	buySeal.Text = SkillConfig.BUY_LABEL
	buySeal.ZIndex = 13
	local buyCorner = buySeal:FindFirstChildOfClass("UICorner")
	if buyCorner ~= nil then
		buyCorner.CornerRadius = UDim.new(1, 0)
	end
	local buyCrackA = Instance.new("Frame")
	buyCrackA.Name = "CrackA"
	buyCrackA.AnchorPoint = Vector2.new(0.5, 0.5)
	buyCrackA.Position = UDim2.fromScale(0.5, 0.5)
	buyCrackA.Size = UDim2.fromOffset(ui.buySeal * ui.crackSpan, ui.crack)
	buyCrackA.BackgroundColor3 = UITheme.color("Void")
	buyCrackA.BorderSizePixel = 0
	buyCrackA.Rotation = ui.crackA
	buyCrackA.Visible = false
	buyCrackA.ZIndex = 14
	buyCrackA.Parent = buySeal
	local buyCrackB = buyCrackA:Clone()
	buyCrackB.Name = "CrackB"
	buyCrackB.Rotation = ui.crackB
	buyCrackB.Parent = buySeal
	local needLabel = UiFactory.label(tooltip, "body", ui.small, "Soot")
	needLabel.Name = "Need"
	needLabel.AnchorPoint = Vector2.new(1, 1)
	needLabel.Position = UDim2.new(1, -ui.headerPad, 1, -ui.headerPad - ui.buySeal)
	needLabel.Size = UDim2.fromOffset(ui.buySeal + ui.headerPad * 2, ui.small)
	needLabel.TextXAlignment = Enum.TextXAlignment.Right
	needLabel.TextColor3 = UITheme.color("Soot")
	needLabel.Visible = false

	local hud = Plots.RETURN_BUTTON
	local rites = UiFactory.button(parent, UITheme.text.minSize)
	rites.Name = "Rites"
	rites.Text = SkillConfig.OPEN_LABEL
	rites.AnchorPoint = Vector2.new(0, 1)
	rites.Position = UDim2.new(0, HudSlots.ritesOrigin(), 1, -hud.margin)
	rites.Size = UDim2.fromOffset(hud.width, math.max(hud.height, ui.touchMin))
	rites.BackgroundColor3 = UITheme.color("Soot")
	rites.TextColor3 = UITheme.color("Bone")
	rites.Visible = false

	local zoom = ui.zoomDefault
	local panX = 0
	local panY = 0
	local isOpen = false
	local generation = 0
	local currentSkills: { string } = {}
	local ownedBefore: { [string]: boolean } = {}
	local primed = false
	local selectedId: string? = nil
	local pending: string? = nil
	local pendingAt = 0
	local lastTouch = false
	local lastEmpty = 0
	local suppressClick = false
	local pulseReady: { [string]: number } = {}
	local sparkAcc: { [string]: number } = {}
	local sparks: { any } = {}
	local flows: { UIGradient } = {}
	local nodes: { [string]: any } = {}
	local pointer: any = nil
	local heartbeat: RBXScriptConnection? = nil
	local paint: () -> ()
	local applyView: () -> ()
	local placeTooltip: () -> ()
	local showTip: (string) -> ()
	local openTree: () -> ()
	local closeTree: () -> ()

	local function readNumber(name: string): number
		local value = player:GetAttribute(name)
		if type(value) ~= "number" or value ~= value then
			return 0
		end
		return value
	end

	local function view()
		return {
			cash = readNumber("Cash"),
			skills = currentSkills,
			onboarding = {
				step = readNumber("OnboardingStep"),
			},
		}
	end

	local function characterAlive(): boolean
		local character = player.Character
		if character == nil then
			return false
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid == nil then
			return false
		end
		return humanoid.Health > 0
	end

	local function cursorInView(screenX: number, screenY: number): (number, number)
		local origin = viewport.AbsolutePosition
		local size = viewport.AbsoluteSize
		return screenX - (origin.X + size.X / 2), screenY - (origin.Y + size.Y / 2)
	end

	applyView = function()
		panX, panY = SkillRules.clampPan(panX, panY, zoom)
		zoom = SkillRules.clampZoom(zoom)
		canvasScale.Scale = zoom
		canvas.Position = UDim2.new(0.5, panX, 0.5, panY)
		placeTooltip()
	end

	placeTooltip = function()
		if not tooltip.Visible or selectedId == nil then
			return
		end
		local node = nodes[selectedId]
		if node == nil then
			return
		end
		local size = screen.AbsoluteSize
		if size.X < 1 or size.Y < 1 then
			return
		end
		local centerPoint = node.button.AbsolutePosition + node.button.AbsoluteSize / 2
		local origin = screen.AbsolutePosition
		local x, y = SkillRules.tooltipOrigin(
			centerPoint.X - origin.X,
			centerPoint.Y - origin.Y,
			size.X,
			size.Y,
			ui.tooltipW,
			ui.tooltipH,
			ui.tooltipGap
		)
		tooltip.Position = UDim2.fromOffset(x, y)
	end

	local function paintTooltip()
		if selectedId == nil then
			tooltip.Visible = false
			return
		end
		local tip = SkillRules.tooltip(view(), selectedId)
		if tip == nil then
			tooltip.Visible = false
			return
		end
		tooltip.Visible = true
		tipTitle.Text = tip.title
		tipBranch.Visible = tip.branch ~= nil
		tipBranch.Text = tip.branch or ""
		tipEffect.Visible = tip.effect ~= nil
		tipEffect.Text = tip.effect or ""
		if tip.sealedLine ~= nil then
			tipExtra.Visible = true
			tipExtra.Text = tip.sealedLine
			tipExtra.TextColor3 = UITheme.color("Soot")
			ThemeBind.italic(tipExtra, "body", ui.small)
		elseif tip.requires ~= nil then
			tipExtra.Visible = true
			tipExtra.Text = tip.requires
			tipExtra.TextColor3 = UITheme.color("Void")
			ThemeBind.apply(tipExtra, "body", ui.small)
		else
			tipExtra.Visible = false
			tipExtra.Text = ""
		end
		tipCost.Visible = tip.cost ~= nil
		tipCost.Text = tip.cost or ""
		needLabel.Visible = tip.need ~= nil
		needLabel.Text = tip.need or ""
		local waiting = pending == selectedId
		buyCrackA.Visible = tip.buy == "broke"
		buyCrackB.Visible = tip.buy == "broke"
		if tip.buy == "hidden" then
			buySeal.Visible = false
		elseif tip.buy == "owned" then
			buySeal.Visible = true
			buySeal.Active = false
			buySeal.Text = SkillConfig.BOUND_LABEL
			buySeal.BackgroundColor3 = UITheme.color("Soot")
			buySeal.TextColor3 = UITheme.color("BoneDim")
			buySeal.BackgroundTransparency = 0
		else
			buySeal.Visible = true
			buySeal.Text = SkillConfig.BUY_LABEL
			buySeal.Active = tip.buy == "ready" and not waiting
			buySeal.BackgroundTransparency = if waiting then ui.waitingTransparency else 0
			if tip.buy == "broke" then
				buySeal.BackgroundColor3 = UITheme.color("Soot")
				buySeal.TextColor3 = UITheme.color("BoneDim")
			else
				buySeal.BackgroundColor3 = UITheme.color("Blood")
				buySeal.TextColor3 = UITheme.color("Bone")
			end
		end
		placeTooltip()
	end

	local function clearPaths()
		flows = {}
		for _, child in pathLayer:GetChildren() do
			child:Destroy()
		end
	end

	local function drawSegment(
		x: number,
		y: number,
		length: number,
		rotation: number,
		thickness: number,
		color: string,
		transparency: number,
		z: number
	): Frame
		local segment = Instance.new("Frame")
		segment.AnchorPoint = Vector2.new(0.5, 0.5)
		segment.Position = UDim2.fromOffset(center + x, center + y)
		segment.Size = UDim2.fromOffset(length, thickness)
		segment.Rotation = rotation
		segment.BackgroundColor3 = UITheme.color(color)
		segment.BackgroundTransparency = transparency
		segment.BorderSizePixel = 0
		segment.ZIndex = z
		segment.Parent = pathLayer
		return segment
	end

	local function drawPath(parentId: string, childId: string)
		local from = SkillConfig.get(parentId)
		local to = SkillConfig.get(childId)
		if from == nil or to == nil then
			return
		end
		local dx = to.x - from.x
		local dy = to.y - from.y
		local length = math.sqrt(dx * dx + dy * dy)
		if length <= 0 then
			return
		end
		local style = SkillRules.pathLook(SkillRules.pathStyle(view(), parentId, childId))
		if isReduced() then
			style.flow = false
		end
		local rotation = math.deg(math.atan2(dy, dx))
		local ux = dx / length
		local uy = dy / length
		local function place(
			offset: number,
			piece: number,
			thickness: number,
			color: string,
			transparency: number,
			z: number
		): Frame
			local mid = offset + piece / 2
			return drawSegment(from.x + ux * mid, from.y + uy * mid, piece, rotation, thickness, color, transparency, z)
		end
		if style.dashed then
			local cursor = 0
			while cursor < length do
				local piece = math.min(ui.pathDash, length - cursor)
				place(cursor, piece, style.thickness, style.color, style.transparency, 2)
				cursor += ui.pathDash + ui.pathGap
			end
			return
		end
		if style.glowThickness > 0 then
			place(0, length, style.glowThickness, style.glow, style.glowTransparency, 2)
		end
		local core = place(0, length, style.thickness, style.color, style.transparency, 3)
		if style.flow then
			local gradient = Instance.new("UIGradient")
			gradient.Color = ColorSequence.new(UITheme.color("Blood"), UITheme.color("BloodHover"))
			gradient.Parent = core
			table.insert(flows, gradient)
		end
	end

	local function rebuildPaths()
		clearPaths()
		for _, edge in SkillConfig.EDGES do
			drawPath(edge.parent, edge.child)
		end
	end

	local function makeNode(id: string)
		local spec = SkillConfig.get(id)
		local hit = SkillRules.hitSize(spec)
		local button = Instance.new("TextButton")
		button.Name = "Node_" .. id
		button.AnchorPoint = Vector2.new(0.5, 0.5)
		button.Position = UDim2.fromOffset(center + spec.x, center + spec.y)
		button.Size = UDim2.fromOffset(hit, hit)
		button.BackgroundTransparency = 1
		button.BorderSizePixel = 0
		button.Text = ""
		button.AutoButtonColor = false
		button.ZIndex = 4
		button.Parent = nodeLayer
		local scale = Instance.new("UIScale")
		scale.Parent = button
		local disc = Instance.new("Frame")
		disc.Name = "Disc"
		disc.AnchorPoint = Vector2.new(0.5, 0.5)
		disc.Position = UDim2.fromScale(0.5, 0.5)
		disc.Size = UDim2.fromOffset(spec.size, spec.size)
		disc.BorderSizePixel = 0
		disc.ZIndex = 4
		disc.Parent = button
		local round = Instance.new("UICorner")
		round.CornerRadius = UDim.new(1, 0)
		round.Parent = disc
		local stroke = Instance.new("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = disc
		local function crack(name: string, rotation: number)
			local line = Instance.new("Frame")
			line.Name = name
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			line.Position = UDim2.fromScale(0.5, 0.5)
			line.Size = UDim2.fromOffset(spec.size * ui.crackSpan, ui.crack)
			line.Rotation = rotation
			line.BackgroundColor3 = UITheme.color("Void")
			line.BorderSizePixel = 0
			line.ZIndex = 5
			line.Visible = false
			line.Parent = disc
			return line
		end
		local sigil = UiFactory.label(disc, "display", ui.body, "Bone")
		sigil.Name = "Sigil"
		sigil.AnchorPoint = Vector2.new(0.5, 0.5)
		sigil.Position = UDim2.fromScale(0.5, 0.5)
		sigil.Size = UDim2.fromScale(ui.crackSpan, ui.crackSpan)
		sigil.Text = UITheme.sigil
		sigil.TextXAlignment = Enum.TextXAlignment.Center
		sigil.ZIndex = 6
		local seal = Instance.new("Frame")
		seal.Name = "Wax"
		seal.AnchorPoint = Vector2.new(0.5, 0.5)
		seal.Position = UDim2.fromScale(0.5, 0.5)
		seal.Size = UDim2.fromOffset(ui.sealGlyph, ui.sealGlyph)
		seal.BackgroundColor3 = UITheme.color("Blood")
		seal.BorderSizePixel = 0
		seal.Visible = false
		seal.ZIndex = 7
		seal.Parent = disc
		local sealRound = Instance.new("UICorner")
		sealRound.CornerRadius = UDim.new(1, 0)
		sealRound.Parent = seal
		UiFactory.stroke(seal, "Gold", UITheme.shape.strokePx, 0)
		local sealMark = UiFactory.label(seal, "display", ui.small, "Gold")
		sealMark.Size = UDim2.fromScale(1, 1)
		sealMark.Text = UITheme.sigil
		sealMark.TextXAlignment = Enum.TextXAlignment.Center
		sealMark.ZIndex = 8
		local lock = Instance.new("Frame")
		lock.Name = "Lock"
		lock.AnchorPoint = Vector2.new(0.5, 1)
		lock.Position = UDim2.new(0.5, 0, 1, -ui.headerPad / 2)
		lock.Size = UDim2.fromOffset(ui.lock, ui.lock)
		lock.BackgroundColor3 = UITheme.color("BoneDim")
		lock.BorderSizePixel = 0
		lock.Visible = false
		lock.ZIndex = 7
		lock.Parent = disc
		local shackle = Instance.new("Frame")
		shackle.Name = "Shackle"
		shackle.AnchorPoint = Vector2.new(0.5, 1)
		shackle.Position = UDim2.fromScale(0.5, 0)
		shackle.Size = UDim2.fromScale(ui.crackSpan, ui.crackSpan)
		shackle.BackgroundTransparency = 1
		shackle.Parent = lock
		local shackleStroke = Instance.new("UIStroke")
		shackleStroke.Color = UITheme.color("BoneDim")
		shackleStroke.Thickness = ui.crack
		shackleStroke.Parent = shackle
		local shackleRound = Instance.new("UICorner")
		shackleRound.CornerRadius = UDim.new(1, 0)
		shackleRound.Parent = shackle
		local flame = Instance.new("Frame")
		flame.Name = "Flame"
		flame.AnchorPoint = Vector2.new(0.5, 1)
		flame.Position = UDim2.new(0.5, 0, 0, ui.sparkSize)
		flame.Size = UDim2.fromOffset(ui.sparkSize, ui.sparkSize * 2)
		flame.BackgroundColor3 = UITheme.color("GoldBright")
		flame.BorderSizePixel = 0
		flame.Visible = false
		flame.ZIndex = 7
		flame.Parent = disc
		local flameRound = Instance.new("UICorner")
		flameRound.CornerRadius = UDim.new(1, 0)
		flameRound.Parent = flame
		nodes[id] = {
			button = button,
			disc = disc,
			stroke = stroke,
			sigil = sigil,
			seal = seal,
			lock = lock,
			flame = flame,
			cracks = { crack("CrackA", ui.crackA), crack("CrackB", ui.crackB) },
			scale = scale,
			igniting = false,
		}
		button.MouseEnter:Connect(function()
			if lastTouch or not isOpen then
				return
			end
			showTip(id)
		end)
		button.SelectionGained:Connect(function()
			if isOpen then
				showTip(id)
			end
		end)
		button.Activated:Connect(function()
			if suppressClick or not isOpen then
				return
			end
			showTip(id)
		end)
		button.InputBegan:Connect(function(input: InputObject)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				pointer = {
					input = input,
					startX = input.Position.X,
					startY = input.Position.Y,
					panX = panX,
					panY = panY,
					moved = false,
					fromNode = true,
				}
				lastTouch = input.UserInputType == Enum.UserInputType.Touch
			end
		end)
	end

	for _, id in SkillConfig.ORDER do
		makeNode(id)
	end

	showTip = function(id: string)
		selectedId = id
		paintTooltip()
	end

	local function emptyClick()
		selectedId = nil
		tooltip.Visible = false
		local now = os.clock()
		if now - lastEmpty <= ui.doubleClickSeconds then
			lastEmpty = 0
			local goalX, goalY, goalZoom = SkillRules.resetView()
			if isReduced() then
				panX, panY, zoom = goalX, goalY, goalZoom
				applyView()
				return
			end
			local startX, startY, startZoom = panX, panY, zoom
			local began = os.clock()
			local gen = generation
			task.spawn(function()
				while os.clock() - began < ui.resetSeconds do
					if generation ~= gen or not isOpen then
						return
					end
					local alpha = (os.clock() - began) / ui.resetSeconds
					local eased = 1 - (1 - alpha) * (1 - alpha)
					panX = startX + (goalX - startX) * eased
					panY = startY + (goalY - startY) * eased
					zoom = startZoom + (goalZoom - startZoom) * eased
					applyView()
					task.wait()
				end
				if generation == gen then
					panX, panY, zoom = goalX, goalY, goalZoom
					applyView()
				end
			end)
			return
		end
		lastEmpty = now
	end

	viewport.InputBegan:Connect(function(input: InputObject)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		pointer = {
			input = input,
			startX = input.Position.X,
			startY = input.Position.Y,
			panX = panX,
			panY = panY,
			moved = false,
			fromNode = false,
		}
		lastTouch = input.UserInputType == Enum.UserInputType.Touch
	end)

	local function clearSparks()
		for _, spark in sparks do
			spark.gui:Destroy()
		end
		sparks = {}
	end

	local function stepMotion(dt: number)
		if not isOpen then
			return
		end
		if pending ~= nil and os.clock() - pendingAt >= ui.pendingSeconds then
			pending = nil
			paintTooltip()
		end
		local stickX = 0
		local stickY = 0
		local ok, states = pcall(function()
			return UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
		end)
		if ok and type(states) == "table" then
			for _, input in states do
				if input.KeyCode == Enum.KeyCode.Thumbstick2 then
					stickX = input.Position.X
					stickY = input.Position.Y
				end
			end
		end
		if math.abs(stickX) > ui.stickDeadzone or math.abs(stickY) > ui.stickDeadzone then
			panX += stickX * ui.panSpeed * zoom * dt
			panY -= stickY * ui.panSpeed * zoom * dt
			applyView()
		end
		local wave = (math.sin((os.clock() / ui.pulseSeconds) * math.pi * 2) + 1) / 2
		local profile = view()
		for id, node in nodes do
			local look = SkillRules.visual(SkillRules.state(profile, id), isReduced(), zoom)
			if look.pulse and os.clock() >= (pulseReady[id] or 0) then
				node.stroke.Transparency = ui.pulseMin + (ui.pulseMax - ui.pulseMin) * wave
			end
			node.flame.Visible = look.flame
			if look.flame and not isReduced() then
				local flick = (math.sin((os.clock() / ui.pulseSeconds) * math.pi * 4) + 1) / 2
				node.flame.BackgroundTransparency = ui.flameMin + (ui.flameMax - ui.flameMin) * flick
			else
				node.flame.BackgroundTransparency = ui.flameMin
			end
			if look.sparks then
				sparkAcc[id] = (sparkAcc[id] or 0) + dt
				local interval = 1 / ui.sparkRate
				while sparkAcc[id] >= interval do
					sparkAcc[id] -= interval
					local alive = 0
					for _, spark in sparks do
						if spark.nodeId == id then
							alive += 1
						end
					end
					if alive >= ui.sparkPerNode or #sparks >= ui.sparkScreen then
						break
					end
					local spark = Instance.new("ImageLabel")
					spark.Name = "Spark"
					spark.AnchorPoint = Vector2.new(0.5, 0.5)
					spark.Position = UDim2.fromScale(0.5, 0.5)
					spark.Size = UDim2.fromOffset(ui.sparkSize, ui.sparkSize)
					spark.BackgroundColor3 = UITheme.color(if #sparks % 2 == 0 then "GoldBright" else "BloodHover")
					spark.BackgroundTransparency = 0
					spark.Image = ""
					spark.BorderSizePixel = 0
					spark.ZIndex = 8
					spark.Parent = node.button
					table.insert(sparks, {
						gui = spark,
						born = os.clock(),
						nodeId = id,
					})
				end
			end
		end
		local now = os.clock()
		local kept = {}
		for _, spark in sparks do
			local age = now - spark.born
			if age >= ui.sparkLife then
				spark.gui:Destroy()
			else
				local alpha = age / ui.sparkLife
				spark.gui.Position = UDim2.new(0.5, 0, 0.5, -ui.sparkRise * alpha)
				spark.gui.BackgroundTransparency = alpha
				table.insert(kept, spark)
			end
		end
		sparks = kept
		while #sparks > ui.sparkScreen do
			local oldest = table.remove(sparks, 1)
			if oldest ~= nil then
				oldest.gui:Destroy()
			end
		end
		if not isReduced() then
			local offset = (os.clock() % ui.veinFlowSeconds) / ui.veinFlowSeconds
			for _, gradient in flows do
				gradient.Offset = Vector2.new(offset, 0)
			end
		end
	end

	local function startLoops()
		if heartbeat ~= nil then
			return
		end
		heartbeat = RunService.Heartbeat:Connect(stepMotion)
	end

	local function stopLoops()
		if heartbeat ~= nil then
			heartbeat:Disconnect()
			heartbeat = nil
		end
		clearSparks()
	end

	paint = function()
		local profile = view()
		cashLabel.Text = NumberFormat.formatCash(profile.cash)
		local width = screen.AbsoluteSize.X
		local titleSize = if width > 0 and width < UITheme.shape.mobileWidthBreakpoint
			then ui.headerTitleMobile
			else ui.headerTitle
		ThemeBind.apply(title, "display", titleSize)
		for id, node in nodes do
			local state = SkillRules.state(profile, id)
			local look = SkillRules.visual(state, isReduced(), zoom)
			node.disc.BackgroundColor3 = UITheme.color(look.fill)
			node.stroke.Color = UITheme.color(look.stroke)
			node.stroke.Thickness = look.strokePx
			if not look.pulse then
				node.stroke.Transparency = look.strokeTransparency
			end
			node.sigil.TextColor3 = UITheme.color(look.sigil)
			node.sigil.TextTransparency = look.sigilTransparency
			node.seal.Visible = look.seal
			node.lock.Visible = look.lock
			node.flame.Visible = look.flame
			for _, line in node.cracks do
				line.Visible = look.cracks
			end
			if not node.igniting then
				node.scale.Scale = 1
			end
			if not look.sparks then
				sparkAcc[id] = 0
			end
		end
		rebuildPaths()
		if tooltip.Visible then
			paintTooltip()
		end
	end

	local function requestBuy(nodeId: string)
		if pending ~= nil then
			return
		end
		pending = nodeId
		pendingAt = os.clock()
		paint()
		local remote = ReplicatedStorage:WaitForChild(Names.FOLDER):WaitForChild(Names.BUY_SKILL) :: RemoteEvent
		remote:FireServer(nodeId)
	end

	local function presentIgnite(nodeId: string)
		local node = nodes[nodeId]
		if node == nil or not isOpen then
			return
		end
		local plan = SkillRules.ignitePlan(isReduced())
		if not plan.play then
			return
		end
		local spec = SkillConfig.get(nodeId)
		node.igniting = true
		local gen = generation
		if not plan.scale then
			paint()
			task.delay(plan.total, function()
				if generation == gen then
					node.igniting = false
				end
			end)
			return
		end
		local half = plan.scaleSeconds / 2
		local up = TweenService:Create(
			node.scale,
			TweenInfo.new(half, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = ui.igniteScaleTo }
		)
		up.Completed:Connect(function()
			if generation ~= gen then
				return
			end
			TweenService:Create(node.scale, TweenInfo.new(half, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 1,
			}):Play()
		end)
		up:Play()
		if plan.ring then
			local ring = Instance.new("Frame")
			ring.Name = "IgniteRing"
			ring.AnchorPoint = Vector2.new(0.5, 0.5)
			ring.Position = UDim2.fromOffset(center + spec.x, center + spec.y)
			ring.Size = UDim2.fromOffset(spec.size, spec.size)
			ring.BackgroundTransparency = 1
			ring.ZIndex = 6
			ring.Parent = canvas
			local ringRound = Instance.new("UICorner")
			ringRound.CornerRadius = UDim.new(1, 0)
			ringRound.Parent = ring
			local ringStroke = Instance.new("UIStroke")
			ringStroke.Color = UITheme.color("GoldBright")
			ringStroke.Thickness = ui.ownedStroke
			ringStroke.Parent = ring
			TweenService
				:Create(ring, TweenInfo.new(plan.ringSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.fromOffset(ui.igniteRingTo, ui.igniteRingTo),
				})
				:Play()
			local fade = TweenService:Create(
				ringStroke,
				TweenInfo.new(plan.ringSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Transparency = 1 }
			)
			fade.Completed:Connect(function()
				ring:Destroy()
			end)
			fade:Play()
		end
		if plan.embers then
			task.delay(ui.igniteEmberDelay, function()
				if generation ~= gen then
					return
				end
				for index = 1, ui.igniteEmberCount do
					local base = (index / ui.igniteEmberCount) * math.pi * 2
					local jitter = (math.random() - 0.5) * 2 * math.rad(ui.igniteJitter)
					local angle = base + jitter
					local distance = ui.igniteEmberMin + math.random() * (ui.igniteEmberMax - ui.igniteEmberMin)
					local ember = Instance.new("ImageLabel")
					ember.Name = "Ember"
					ember.AnchorPoint = Vector2.new(0.5, 0.5)
					ember.Position = UDim2.fromOffset(center + spec.x, center + spec.y)
					ember.Size = UDim2.fromOffset(ui.sparkSize, ui.sparkSize)
					ember.BackgroundColor3 = UITheme.color(if index % 2 == 0 then "GoldBright" else "BloodHover")
					ember.Image = ""
					ember.BorderSizePixel = 0
					ember.ZIndex = 7
					ember.Parent = canvas
					local goal = UDim2.fromOffset(
						center + spec.x + math.cos(angle) * distance,
						center + spec.y + math.sin(angle) * distance
					)
					TweenService
						:Create(
							ember,
							TweenInfo.new(plan.emberSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Position = goal,
								BackgroundTransparency = 1,
							}
						)
						:Play()
					task.delay(plan.emberSeconds, function()
						ember:Destroy()
					end)
				end
			end)
		end
		for _, edge in SkillConfig.EDGES do
			if edge.parent == nodeId and SkillRules.state(view(), edge.child) == "available" then
				pulseReady[edge.child] = os.clock() + plan.total
			end
		end
		task.delay(plan.total, function()
			if generation == gen then
				node.igniting = false
				node.scale.Scale = 1
			end
		end)
	end

	local function applySkills(snapshot: any)
		local list = {}
		local incoming: { [string]: boolean } = {}
		if type(snapshot) == "table" and type(snapshot.skills) == "table" then
			for index = 1, #snapshot.skills do
				local id = snapshot.skills[index]
				if type(id) == "string" then
					table.insert(list, id)
					incoming[id] = true
				end
			end
		end
		currentSkills = list
		if pending ~= nil and (incoming[pending] == true or SkillRules.state(view(), pending) == "owned") then
			pending = nil
		end
		paint()
		if primed then
			for _, id in list do
				if SkillRules.shouldIgnite(ownedBefore, id) then
					presentIgnite(id)
				end
			end
		else
			primed = true
		end
		ownedBefore = incoming
	end

	buySeal.Activated:Connect(function()
		if selectedId == nil or pending ~= nil then
			return
		end
		local tip = SkillRules.tooltip(view(), selectedId)
		if tip == nil or tip.buy ~= "ready" then
			return
		end
		requestBuy(selectedId)
	end)

	local function setControls(enabled: boolean)
		local scriptsFolder = player:FindFirstChild("PlayerScripts")
		if scriptsFolder == nil then
			return
		end
		local moduleScript = scriptsFolder:FindFirstChild("PlayerModule")
		if moduleScript == nil or not moduleScript:IsA("ModuleScript") then
			return
		end
		local ok, result = pcall(require, moduleScript)
		if not ok or type(result) ~= "table" or type(result.GetControls) ~= "function" then
			return
		end
		local controls = result:GetControls()
		if controls == nil then
			return
		end
		if enabled then
			controls:Enable()
		else
			controls:Disable()
		end
	end

	local function sinkMovement(_name: string, _state: Enum.UserInputState, _input: InputObject)
		return Enum.ContextActionResult.Sink
	end

	openTree = function()
		if isOpen or not SkillRules.gateOpen(readNumber("OnboardingStep")) or not characterAlive() then
			return
		end
		isOpen = true
		generation += 1
		screen.Enabled = true
		group.GroupTransparency = 1
		local plan = UITheme.resolveMotion("panelOpen", isReduced())
		if plan.duration > 0 then
			Motion.play(group, "panelOpen", isReduced(), { GroupTransparency = 0 })
		else
			group.GroupTransparency = 0
		end
		setControls(false)
		ContextActionService:BindActionAtPriority(
			ACTION,
			sinkMovement,
			false,
			Enum.ContextActionPriority.High.Value,
			Enum.KeyCode.W,
			Enum.KeyCode.A,
			Enum.KeyCode.S,
			Enum.KeyCode.D,
			Enum.KeyCode.Space,
			Enum.KeyCode.Thumbstick1
		)
		startLoops()
		paint()
	end

	closeTree = function()
		if not isOpen then
			return
		end
		isOpen = false
		generation += 1
		local gen = generation
		selectedId = nil
		tooltip.Visible = false
		stopLoops()
		setControls(true)
		ContextActionService:UnbindAction(ACTION)
		local plan = UITheme.resolveMotion("panelClose", isReduced())
		Motion.play(group, "panelClose", isReduced(), { GroupTransparency = 1 })
		task.delay(plan.duration, function()
			if generation == gen then
				screen.Enabled = false
			end
		end)
	end

	closeButton.Activated:Connect(closeTree)
	rites.Activated:Connect(openTree)

	local function refreshGate()
		rites.Visible = SkillRules.gateOpen(readNumber("OnboardingStep"))
		if not rites.Visible then
			closeTree()
		end
	end
	refreshGate()
	player:GetAttributeChangedSignal("OnboardingStep"):Connect(refreshGate)
	player:GetAttributeChangedSignal("Cash"):Connect(function()
		paint()
	end)

	local function bindDeath(character: Model)
		task.spawn(function()
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid == nil then
				local found = character:WaitForChild("Humanoid", ui.humanoidWait)
				if found ~= nil and found:IsA("Humanoid") then
					humanoid = found
				end
			end
			if humanoid ~= nil then
				humanoid.Died:Connect(closeTree)
			end
		end)
	end
	player.CharacterAdded:Connect(bindDeath)
	if player.Character ~= nil then
		bindDeath(player.Character)
	end

	local touches: { [InputObject]: Vector2 } = {}
	local pinchDistance: number? = nil
	local function updatePinch()
		local points = {}
		for _, pos in touches do
			table.insert(points, pos)
		end
		if #points ~= 2 then
			pinchDistance = nil
			return
		end
		pointer = nil
		local dx = points[1].X - points[2].X
		local dy = points[1].Y - points[2].Y
		local distance = math.sqrt(dx * dx + dy * dy)
		if pinchDistance ~= nil and pinchDistance > 0 and distance > 0 then
			local midX = (points[1].X + points[2].X) / 2
			local midY = (points[1].Y + points[2].Y) / 2
			local cursorX, cursorY = cursorInView(midX, midY)
			local nextZoom = zoom * (distance / pinchDistance)
			panX, panY, zoom = SkillRules.zoomToward(panX, panY, zoom, cursorX, cursorY, nextZoom)
			applyView()
		end
		pinchDistance = distance
	end

	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		local key = input.KeyCode
		if key == Enum.KeyCode[SkillConfig.OPEN_KEY] or key == Enum.KeyCode[SkillConfig.GAMEPAD_OPEN] then
			if processed and key == Enum.KeyCode[SkillConfig.OPEN_KEY] then
				return
			end
			openTree()
			return
		end
		if not isOpen then
			return
		end
		if key == Enum.KeyCode[SkillConfig.CLOSE_KEY] or key == Enum.KeyCode[SkillConfig.GAMEPAD_CLOSE] then
			closeTree()
			return
		end
		if key == Enum.KeyCode[SkillConfig.GAMEPAD_RESET] then
			lastEmpty = os.clock()
			emptyClick()
		end
		if input.UserInputType == Enum.UserInputType.Touch then
			touches[input] = Vector2.new(input.Position.X, input.Position.Y)
			updatePinch()
		end
	end)
	local function dragTo(x: number, y: number)
		if pointer == nil then
			return
		end
		local dx = x - pointer.startX
		local dy = y - pointer.startY
		if SkillRules.pastDrag(dx, dy) then
			pointer.moved = true
			suppressClick = true
			panX, panY = SkillRules.clampPan(pointer.panX + dx, pointer.panY + dy, zoom)
			applyView()
		end
	end
	UserInputService.InputChanged:Connect(function(input: InputObject)
		if not isOpen then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local mouse = UserInputService:GetMouseLocation()
			local cursorX, cursorY = cursorInView(mouse.X, mouse.Y)
			local nextZoom = SkillRules.wheelZoom(zoom, input.Position.Z)
			panX, panY, zoom = SkillRules.zoomToward(panX, panY, zoom, cursorX, cursorY, nextZoom)
			applyView()
			return
		end
		if input.UserInputType == Enum.UserInputType.Touch then
			touches[input] = Vector2.new(input.Position.X, input.Position.Y)
			updatePinch()
			if pinchDistance ~= nil then
				return
			end
		end
		if pointer == nil then
			return
		end
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			and pointer.input.UserInputType == Enum.UserInputType.MouseButton1
		then
			dragTo(input.Position.X, input.Position.Y)
			return
		end
		if pointer.input == input then
			dragTo(input.Position.X, input.Position.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input: InputObject)
		if touches[input] ~= nil then
			touches[input] = nil
			updatePinch()
		end
		if pointer == nil or pointer.input ~= input then
			return
		end
		local moved = pointer.moved
		local fromNode = pointer.fromNode
		pointer = nil
		if moved then
			task.defer(function()
				suppressClick = false
			end)
			return
		end
		if not fromNode and isOpen then
			emptyClick()
		end
	end)

	local function attachUnmarked(model: Instance)
		local adornee: BasePart? = nil
		if model:IsA("Model") then
			adornee = model.PrimaryPart
		end
		if adornee == nil then
			local plinth = model:FindFirstChild("Plinth")
			if plinth ~= nil and plinth:IsA("BasePart") then
				adornee = plinth
			end
		end
		if adornee == nil then
			return
		end
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "Unmarked"
		billboard.Size = UDim2.fromOffset(ui.shrineWidth, ui.shrineHeight)
		billboard.StudsOffset = Vector3.new(0, ui.shrineLift, 0)
		billboard.AlwaysOnTop = false
		billboard.LightInfluence = 0
		billboard.MaxDistance = ui.shrineDistance
		billboard.Adornee = adornee
		billboard.Parent = parent
		local unmarked = UiFactory.label(billboard, "body", UITheme.text.minSize, "BoneDim")
		unmarked.Size = UDim2.fromScale(1, 0.5)
		unmarked.TextXAlignment = Enum.TextXAlignment.Center
		unmarked.Text = Town.SHRINE_UNMARKED
		local body = UiFactory.label(billboard, "body", UITheme.text.minSize, "BoneDim")
		body.Position = UDim2.fromScale(0, 0.5)
		body.Size = UDim2.fromScale(1, 0.5)
		body.TextXAlignment = Enum.TextXAlignment.Center
		body.Text = Town.SHRINE_BODY
		local function refresh()
			local step = player:GetAttribute("OnboardingStep")
			billboard.Enabled = type(step) ~= "number" or step < Shop.GATE_STEP
		end
		refresh()
		player:GetAttributeChangedSignal("OnboardingStep"):Connect(refresh)
	end

	for _, model in CollectionService:GetTagged("SkillShrine") do
		attachUnmarked(model)
	end
	CollectionService:GetInstanceAddedSignal("SkillShrine"):Connect(attachUnmarked)

	panX, panY, zoom = SkillRules.resetView()
	applyView()
	paint()

	return {
		open = openTree,
		apply = applySkills,
	}
end

return SkillTree
