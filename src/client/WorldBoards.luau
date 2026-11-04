--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local CryptidArt = require(Shared:WaitForChild("Config"):WaitForChild("CryptidArt")) :: any
local NumberFormat = require(Shared:WaitForChild("Logic"):WaitForChild("NumberFormat")) :: any
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local player = Players.LocalPlayer
local boards: { [BasePart]: any } = {}

local WorldBoards = {}

local function ownerMatches(part: Instance): boolean
	return part:GetAttribute("OwnerUserId") == player.UserId
end

local function liftFor(part: BasePart): number
	local creature = part:FindFirstChild("Creature")
	if creature ~= nil and creature:IsA("Model") then
		local boxCf, boxSize = creature:GetBoundingBox()
		return CryptidArt.billboardStuds(boxCf.Position.Y + boxSize.Y / 2, part.Position.Y)
	end
	return CryptidArt.billboardStuds(part.Position.Y, part.Position.Y)
end

local function ensure(part: BasePart, nameRole: string)
	local existing = boards[part]
	if existing ~= nil then
		existing.gui.StudsOffset = Vector3.new(0, liftFor(part), 0)
		return existing
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "LedgerPlate"
	gui.Size = UDim2.fromOffset(200, 64)
	gui.StudsOffset = Vector3.new(0, liftFor(part), 0)
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0
	gui.MaxDistance = 90
	gui.ResetOnSpawn = false
	gui.Parent = part
	local plate = UiFactory.panel(gui)
	plate.Size = UDim2.fromScale(1, 1)
	local name = UiFactory.label(plate, nameRole, UITheme.fonts.header.mobile, "Bone")
	name.Name = "Name"
	name.Position = UDim2.fromOffset(8, 6)
	name.Size = UDim2.new(1, -16, 0, 24)
	name.TextXAlignment = Enum.TextXAlignment.Center
	local line = UiFactory.label(plate, "number", UITheme.fonts.number.desktop, "GoldBright")
	line.Name = "Line"
	line.Position = UDim2.fromOffset(8, 32)
	line.Size = UDim2.new(1, -16, 0, 24)
	line.TextXAlignment = Enum.TextXAlignment.Center
	ThemeBind.apply(name, nameRole, UITheme.fonts.header.mobile)
	ThemeBind.apply(line, "number", UITheme.fonts.number.desktop)
	local record = {
		gui = gui,
		name = name,
		line = line,
		stroke = plate:FindFirstChildOfClass("UIStroke"),
	}
	boards[part] = record
	return record
end

local function padEntry(snapshot: any, index: number): any?
	if type(snapshot) ~= "table" or type(snapshot.pads) ~= "table" then
		return nil
	end
	for _, entry in snapshot.pads do
		if entry.index == index then
			return entry
		end
	end
	return nil
end

local function riftEntry(snapshot: any, slot: number): any?
	if type(snapshot) ~= "table" or type(snapshot.rift) ~= "table" then
		return nil
	end
	for _, entry in snapshot.rift do
		if entry.slot == slot then
			return entry
		end
	end
	return nil
end

local function paintPad(part: BasePart, snapshot: any)
	if part:GetAttribute("Sealed") == true then
		local board = ensure(part, "header")
		board.gui.Enabled = true
		board.name.Text = UITheme.sigil
		board.name.TextColor3 = UITheme.color("BoneDim")
		board.line.Text = Plots.SEALED_LABEL
		board.line.TextColor3 = UITheme.color("BoneDim")
		if board.stroke ~= nil then
			board.stroke.Color = UITheme.color("BoneDim")
		end
		return
	end
	if not ownerMatches(part) then
		local existing = boards[part]
		if existing ~= nil then
			existing.gui.Enabled = false
		end
		return
	end
	local index = part:GetAttribute("PadIndex")
	if type(index) ~= "number" then
		return
	end
	local entry = padEntry(snapshot, index)
	if entry == nil then
		return
	end
	local board = ensure(part, "header")
	local stroke = board.stroke
	if entry.state == "occupied" then
		board.name.Text = tostring(entry.displayName)
		board.name.TextColor3 = UITheme.color("Bone")
		board.line.Text = NumberFormat.formatRate(entry.income or 0)
		board.line.TextColor3 = UITheme.color("GoldBright")
		if stroke ~= nil then
			stroke.Color = UITheme.color("Gold")
		end
	elseif entry.state == "locked" then
		board.name.Text = UITheme.sigil
		board.name.TextColor3 = UITheme.color("BoneDim")
		board.line.Text = NumberFormat.formatCash(entry.cost or 0) .. " · Carve"
		board.line.TextColor3 = UITheme.color("BoneDim")
		if stroke ~= nil then
			stroke.Color = if entry.affordable == true then UITheme.color("Blood") else UITheme.color("Gold")
		end
	else
		board.name.Text = "Empty circle"
		board.name.TextColor3 = UITheme.color("BoneDim")
		board.line.Text = ""
		if stroke ~= nil then
			stroke.Color = UITheme.color("Gold")
		end
	end
end

local function paintRift(part: BasePart, snapshot: any)
	if not ownerMatches(part) then
		return
	end
	local slot = part:GetAttribute("Slot")
	if type(slot) ~= "number" then
		return
	end
	local entry = riftEntry(snapshot, slot)
	local board = boards[part]
	if entry == nil then
		if board ~= nil then
			board.gui.Enabled = false
		end
		return
	end
	board = ensure(part, "header")
	board.gui.Enabled = true
	board.name.Text = tostring(entry.displayName)
	board.name.TextColor3 = UITheme.color("Bone")
	board.line.Text = NumberFormat.formatCash(entry.price or 0)
	board.line.TextColor3 = UITheme.color("GoldBright")
end

function WorldBoards.refresh(snapshot: any)
	for _, inst in CollectionService:GetTagged("CryptidPad") do
		if inst:IsA("BasePart") then
			paintPad(inst, snapshot)
		end
	end
	for _, inst in CollectionService:GetTagged("CryptidRift") do
		if inst:IsA("BasePart") then
			paintRift(inst, snapshot)
		end
	end
end

function WorldBoards.start(getSnapshot: () -> any)
	local function added(inst: Instance)
		if inst:IsA("BasePart") then
			WorldBoards.refresh(getSnapshot())
		end
	end
	CollectionService:GetInstanceAddedSignal("CryptidPad"):Connect(added)
	CollectionService:GetInstanceAddedSignal("CryptidRift"):Connect(added)
	WorldBoards.refresh(getSnapshot())
end

return WorldBoards
