--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Onboarding = require(Shared:WaitForChild("Config"):WaitForChild("Onboarding")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local RarityTease = {}

local function capped(seconds: number, reduced: boolean): number
	if reduced then
		return math.min(seconds, UITheme.reducedMotion.maxFade)
	end
	return seconds
end

local function readSeconds(value: any, fallback: number): number
	if type(value) ~= "number" or value ~= value or value < 0 or value == math.huge then
		return fallback
	end
	return value
end

function RarityTease.mount(parent: Instance, isReduced: () -> boolean)
	local group = Instance.new("CanvasGroup")
	group.Name = "RarityTease"
	group.BackgroundColor3 = UITheme.color("Ash")
	group.BorderSizePixel = 0
	group.AnchorPoint = Vector2.new(0.5, 0.5)
	group.Position = UDim2.fromScale(0.5, 0.5)
	group.Visible = false
	group.GroupTransparency = 1
	group.Active = false
	group.ZIndex = 6
	group.Parent = parent
	UiFactory.corner(group)
	UiFactory.stroke(group, "Gold", UITheme.shape.strokePx, UITheme.shape.strokeTransparency)

	local nameLabel = UiFactory.label(group, "display", UITheme.shape.goalBanner.titleDesktop, "Bone")
	nameLabel.Name = "Result"
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.TextYAlignment = Enum.TextYAlignment.Center

	local rarityChip, rarityLabel = UiFactory.rarityChip(group, "Common")
	rarityChip.AnchorPoint = Vector2.new(0.5, 0)

	local pipRow = Instance.new("Frame")
	pipRow.Name = "Pips"
	pipRow.BackgroundTransparency = 1
	pipRow.BorderSizePixel = 0
	pipRow.Visible = false
	pipRow.Parent = group
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Padding = UDim.new(0, UITheme.shape.tease.pipGap)
	list.Parent = pipRow

	local pips = {}
	for index = 1, #Onboarding.TEASE_PIPS do
		local pip = Instance.new("Frame")
		pip.Name = "Pip" .. tostring(index)
		pip.BorderSizePixel = 0
		pip.BackgroundColor3 = UITheme.color("BoneDim")
		pip.Parent = pipRow
		UiFactory.corner(pip)
		table.insert(pips, pip)
	end

	local line = UiFactory.label(group, "body", UITheme.fonts.body.desktop, "Bone")
	line.Name = "Tease"
	line.Text = Onboarding.TEASE_LINE
	line.TextWrapped = true
	line.TextXAlignment = Enum.TextXAlignment.Center
	line.TextYAlignment = Enum.TextYAlignment.Top
	line.Visible = false

	local seen = 0
	local generation = 0
	local activeTween: Tween? = nil

	local function fade(target: number, seconds: number)
		if activeTween ~= nil then
			activeTween:Cancel()
			activeTween = nil
		end
		if seconds <= 0 then
			group.GroupTransparency = target
			return
		end
		local tween = TweenService:Create(
			group,
			TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ GroupTransparency = target }
		)
		activeTween = tween
		tween:Play()
	end

	local function paintPips(names: any)
		for index, pip in pips do
			local rarityName = if type(names) == "table" then names[index] else nil
			local token = "BoneDim"
			if type(rarityName) == "string" then
				local mapped = UITheme.rarity[rarityName]
				if type(mapped) == "string" then
					token = mapped
				end
			end
			pip.BackgroundColor3 = UITheme.color(token)
		end
	end

	local api = {}

	function api.layout(isMobile: boolean)
		local metrics = if isMobile then UITheme.shape.tease.mobile else UITheme.shape.tease.desktop
		local titleSize = if isMobile
			then UITheme.shape.goalBanner.titleMobile
			else UITheme.shape.goalBanner.titleDesktop
		local bodySize = if isMobile then UITheme.fonts.body.mobile else UITheme.fonts.body.desktop
		local pip = UITheme.shape.tease.pip
		group.Size = UDim2.fromOffset(metrics.w, metrics.h)
		nameLabel.Position = UDim2.fromOffset(16, 28)
		nameLabel.Size = UDim2.new(1, -32, 0, titleSize + 4)
		rarityChip.Position = UDim2.new(0.5, 0, 0, 28 + titleSize + 6)
		rarityChip.Size = UDim2.fromOffset(UITheme.shape.chipW, UITheme.shape.pedlar.chipH)
		pipRow.AnchorPoint = Vector2.new(0.5, 0)
		pipRow.Position = UDim2.new(0.5, 0, 0, 36)
		pipRow.Size = UDim2.fromOffset(metrics.w - 32, pip)
		for _, pipFrame in pips do
			pipFrame.Size = UDim2.fromOffset(pip, pip)
		end
		line.Position = UDim2.fromOffset(16, 36 + pip + 12)
		line.Size = UDim2.new(1, -32, 0, bodySize * 2 + 4)
		ThemeBind.apply(nameLabel, "display", titleSize)
		ThemeBind.apply(rarityLabel, "body", bodySize)
		ThemeBind.apply(line, "body", bodySize)
	end

	function api.isBusy(): boolean
		return group.Visible
	end

	function api.show(reveal: any)
		if type(reveal) ~= "table" or type(reveal.token) ~= "number" then
			return
		end
		if reveal.token == seen then
			return
		end
		seen = reveal.token
		generation += 1
		local ticket = generation
		nameLabel.Text = tostring(reveal.speciesName or "")
		rarityLabel.Text = tostring(reveal.rarity or "")
		UiFactory.applyChip(rarityChip, rarityLabel, rarityLabel.Text)
		line.Text = tostring(reveal.line or Onboarding.TEASE_LINE)
		line.TextColor3 = UITheme.color("Bone")
		paintPips(reveal.pips)
		nameLabel.Visible = true
		rarityChip.Visible = true
		rarityLabel.Visible = true
		pipRow.Visible = false
		line.Visible = false
		group.GroupTransparency = 0
		group.Visible = true

		local revealSeconds = readSeconds(reveal.revealSeconds, Onboarding.REVEAL_SECONDS)
		local fadeIn = capped(readSeconds(reveal.fadeIn, Onboarding.TEASE_FADE_IN), isReduced())
		local hold = readSeconds(reveal.hold, Onboarding.TEASE_HOLD)
		local fadeOut = capped(readSeconds(reveal.fadeOut, Onboarding.TEASE_FADE_OUT), isReduced())

		task.delay(revealSeconds, function()
			if ticket ~= generation or group.Parent == nil then
				return
			end
			nameLabel.Visible = false
			rarityChip.Visible = false
			rarityLabel.Visible = false
			pipRow.Visible = true
			line.Visible = true
			group.GroupTransparency = 1
			fade(0, fadeIn)
			task.delay(fadeIn + hold, function()
				if ticket ~= generation or group.Parent == nil then
					return
				end
				fade(1, fadeOut)
				task.delay(fadeOut, function()
					if ticket ~= generation or group.Parent == nil then
						return
					end
					group.Visible = false
				end)
			end)
		end)
	end

	api.layout(false)
	return api
end

return RarityTease
