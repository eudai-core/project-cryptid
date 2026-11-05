--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CashPlaque = require(script.Parent:WaitForChild("CashPlaque"))
local GoalBanner = require(script.Parent:WaitForChild("GoalBanner"))
local RarityTease = require(script.Parent:WaitForChild("RarityTease"))
local HaulPanel = require(script.Parent:WaitForChild("HaulPanel"))
local OfferingPanel = require(script.Parent:WaitForChild("OfferingPanel"))
local GuideArrow = require(script.Parent:WaitForChild("GuideArrow"))
local HomeBeam = require(script.Parent:WaitForChild("HomeBeam"))
local Interactions = require(script.Parent:WaitForChild("Interactions"))
local LairBanners = require(script.Parent:WaitForChild("LairBanners"))
local PedlarShop = require(script.Parent:WaitForChild("PedlarShop"))
local SkillTree = require(script.Parent:WaitForChild("SkillTree"))
local TownDress = require(script.Parent:WaitForChild("TownDress"))
local ReturnButton = require(script.Parent:WaitForChild("ReturnButton"))
local SealToast = require(script.Parent:WaitForChild("SealToast"))
local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local WorldBoards = require(script.Parent:WaitForChild("WorldBoards"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Economy = require(Shared:WaitForChild("Config"):WaitForChild("Economy")) :: any
local HudSlots = require(Shared:WaitForChild("Logic"):WaitForChild("HudSlots")) :: any
local GameInfo = require(Shared:WaitForChild("GameInfo")) :: any
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local Names = require(Shared:WaitForChild("Config"):WaitForChild("Remotes")) :: any
local QaArgs = require(Shared:WaitForChild("Logic"):WaitForChild("QaArgs")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

print(GameInfo.name .. " client started")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")
local remotes = ReplicatedStorage:WaitForChild(Names.FOLDER)

local reduced = false
local function isReduced(): boolean
	return reduced
end

local gui = Instance.new("ScreenGui")
gui.Name = "CryptidHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 20
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.Parent = playerGui

local vignetteTop = Instance.new("Frame")
vignetteTop.Name = "VignetteTop"
vignetteTop.BackgroundColor3 = UITheme.color("Void")
vignetteTop.BorderSizePixel = 0
vignetteTop.Size = UDim2.new(1, 0, 0, 72)
vignetteTop.Active = false
vignetteTop.Parent = gui
local topFade = Instance.new("UIGradient")
topFade.Rotation = 90
topFade.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, UITheme.shape.overlayTransparency),
	NumberSequenceKeypoint.new(1, 1),
})
topFade.Parent = vignetteTop

local function fire(name: string, ...: any)
	local remote = remotes:WaitForChild(name) :: RemoteEvent
	remote:FireServer(...)
end

local plaque = CashPlaque.mount(gui, isReduced)
local banner = GoalBanner.mount(gui, isReduced, function(goal)
	local kind = goal.actionKind
	if kind == "buyRift" then
		fire(Names.BUY_RIFT, goal.actionSlot)
	elseif kind == "unlockPad" then
		fire(Names.UNLOCK_PAD, goal.actionPad)
	elseif kind == "upgradeAltar" then
		fire(Names.UPGRADE, "boneAltar")
	elseif kind == "place" then
		fire(Names.PLACE, goal.actionInstanceId, goal.actionPad)
	end
end, function()
	fire(Names.SKIP)
end)

local hud = Plots.RETURN_BUTTON
ReturnButton.mount(gui, function()
	fire(Names.RETURN_TO_LAIR)
end)
SealToast.mount(gui, player)

local steady = UiFactory.button(gui, UITheme.text.minSize)
steady.Name = "ReducedMotion"
steady.AnchorPoint = Vector2.new(0, 1)
steady.Position = UDim2.new(0, HudSlots.origin(1), 1, -hud.margin)
steady.Size = UDim2.fromOffset(hud.width, hud.steadyHeight)
steady.BackgroundColor3 = UITheme.color("Soot")
steady.TextColor3 = UITheme.color("BoneDim")
ThemeBind.apply(steady, "body", UITheme.text.minSize)
local steadyStroke = steady:FindFirstChildOfClass("UIStroke")
if steadyStroke ~= nil then
	steadyStroke.Color = UITheme.color("BoneDim")
end

local function paintSteady()
	steady.Text = if reduced then "Steady gaze: On" else "Steady gaze: Off"
end
paintSteady()
steady.Activated:Connect(function()
	fire(Names.REDUCED_MOTION, not reduced)
end)

local snapshotValue = player:WaitForChild("CryptidState"):WaitForChild("Snapshot") :: StringValue
local latestSnapshot: any = nil
local skillTree: any = nil

local function readNumber(name: string): number
	local value = player:GetAttribute(name)
	if type(value) ~= "number" then
		return 0
	end
	return value
end

local layout: () -> ()

local haul = HaulPanel.mount(gui, isReduced, function()
	fire(Names.CLAIM_HAUL)
end)
local tease = RarityTease.mount(gui, isReduced)
local offering = OfferingPanel.mount(gui, isReduced, function()
	fire(Names.CLAIM_DAILY)
end, function()
	return banner.isBusy() or tease.isBusy()
end)

local function applyAttributes()
	reduced = player:GetAttribute("ReducedMotion") == true
	paintSteady()
	plaque.apply(
		readNumber("Cash"),
		readNumber("IncomePerSecond"),
		0,
		readNumber("StateRevision"),
		readNumber("OnboardingStep"),
		readNumber("Bowl")
	)
	layout()
end

local function applySnapshot(text: string)
	if text == "" then
		return
	end
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(text)
	end)
	if not ok or type(decoded) ~= "table" then
		return
	end
	latestSnapshot = decoded
	if skillTree ~= nil then
		skillTree.apply(decoded)
	end
	if type(decoded.goal) == "table" then
		banner.apply(decoded.goal)
	end
	if type(decoded.reveal) == "table" then
		tease.show(decoded.reveal)
	end
	local credit = decoded.lastCredit
	if type(credit) ~= "number" then
		credit = 0
	end
	local revision = decoded.revision
	if type(revision) ~= "number" then
		revision = 0
	end
	plaque.apply(
		readNumber("Cash"),
		readNumber("IncomePerSecond"),
		credit,
		revision,
		readNumber("OnboardingStep"),
		if type(decoded.bowl) == "number" then decoded.bowl else readNumber("Bowl")
	)
	haul.apply(decoded.haul)
	offering.apply(decoded.daily, haul.isOpen())
	WorldBoards.refresh(decoded)
	layout()
end

layout = function()
	local viewport = camera.ViewportSize
	local mobile = viewport.X < UITheme.shape.mobileWidthBreakpoint
	local bannerHeight = banner.layout(mobile)
	plaque.layout(mobile, bannerHeight + UITheme.shape.plaqueGapPx)
	tease.layout(mobile)
	haul.layout(mobile)
	offering.layout(mobile)
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local nextCamera = workspace.CurrentCamera
	if nextCamera ~= nil then
		camera = nextCamera
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)
		layout()
	end
end)
layout()

player:GetAttributeChangedSignal("Cash"):Connect(applyAttributes)
player:GetAttributeChangedSignal("IncomePerSecond"):Connect(applyAttributes)
player:GetAttributeChangedSignal("LastCredit"):Connect(applyAttributes)
player:GetAttributeChangedSignal("StateRevision"):Connect(applyAttributes)
player:GetAttributeChangedSignal("ReducedMotion"):Connect(applyAttributes)
player:GetAttributeChangedSignal("OnboardingStep"):Connect(applyAttributes)
snapshotValue.Changed:Connect(function(text)
	applySnapshot(text)
end)

local catching = false
local function beginCatch()
	if catching then
		return
	end
	catching = true
	local previous = player:GetAttribute("CatchToken")
	if type(previous) ~= "number" then
		previous = 0
	end
	fire(Names.BEGIN_CATCH)
	task.spawn(function()
		local deadline = os.clock() + 2
		local token = previous
		while os.clock() < deadline do
			local current = player:GetAttribute("CatchToken")
			if type(current) == "number" and current ~= previous then
				token = current
				break
			end
			task.wait(0.05)
		end
		if token ~= previous then
			local catchSeconds = player:GetAttribute("CatchSeconds")
			if type(catchSeconds) ~= "number" or catchSeconds ~= catchSeconds then
				catchSeconds = Economy.CATCH_SECONDS
			end
			task.wait(catchSeconds + Economy.CATCH_CLIENT_BUFFER_SECONDS)
			if player:GetAttribute("CatchToken") == token then
				fire(Names.COMPLETE_CATCH)
			end
		end
		catching = false
	end)
end

local skill = SkillTree.mount(gui, player, isReduced)
skillTree = skill
if RunService:IsStudio() then
	local StudioTestService = game:GetService("StudioTestService") :: any
	local ok, studioArgs = pcall(function()
		return StudioTestService:GetTestArgs()
	end)
	if ok and QaArgs.openTree(true, studioArgs) then
		local function openWhenReady()
			skill.open()
		end
		player:GetAttributeChangedSignal("OnboardingStep"):Connect(openWhenReady)
		player.CharacterAdded:Connect(function()
			task.defer(openWhenReady)
		end)
		task.defer(openWhenReady)
	end
end
local pedlar = PedlarShop.mount(gui, player, remotes :: Folder, Names, isReduced)
TownDress.start()
Interactions.start(player, remotes :: Folder, Names, beginCatch, {
	onPedlar = pedlar.open,
	onShrine = skill.open,
})
GuideArrow.start(player)
LairBanners.start(player)
HomeBeam.start(player)
WorldBoards.start(function()
	return latestSnapshot
end)

if player:GetAttribute("StateRevision") ~= nil then
	applyAttributes()
end
applySnapshot(snapshotValue.Value)
