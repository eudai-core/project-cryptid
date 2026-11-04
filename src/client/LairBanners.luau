--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local LairBanners = {}

local function bannerText(player: Player, model: Model): string
	local ownerId = model:GetAttribute("OwnerUserId")
	local ownerName = model:GetAttribute("OwnerName")
	if type(ownerId) == "number" and ownerId ~= 0 and ownerId == player.UserId then
		return Plots.BANNER_OWN
	end
	if type(ownerName) == "string" and ownerName ~= "" then
		return ownerName
	end
	return Plots.BANNER_UNCLAIMED
end

local function mount(player: Player, model: Model)
	local cloth = model:WaitForChild("BannerCloth")
	if not cloth:IsA("BasePart") then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "LairBanner"
	gui.Size = UDim2.fromOffset(220, 48)
	gui.StudsOffset = Vector3.new(0, 0, 0)
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0
	gui.MaxDistance = Plots.BANNER_MAX_DISTANCE
	gui.ResetOnSpawn = false
	gui.Parent = cloth
	local label = Instance.new("TextLabel")
	label.Name = "Name"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = UITheme.color("Bone")
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = gui
	ThemeBind.apply(label, "display", UITheme.fonts.display.mobile)
	local function refresh()
		label.Text = bannerText(player, model)
	end
	refresh()
	model:GetAttributeChangedSignal("OwnerUserId"):Connect(refresh)
	model:GetAttributeChangedSignal("OwnerName"):Connect(refresh)
	model:GetAttributeChangedSignal("PlotState"):Connect(refresh)
	player:GetAttributeChangedSignal("PlotIndex"):Connect(refresh)
end

function LairBanners.start(player: Player)
	local plots = workspace:WaitForChild("Plots")
	local function hook(child: Instance)
		if child:IsA("Model") then
			mount(player, child)
		end
	end
	for _, child in plots:GetChildren() do
		task.spawn(hook, child)
	end
	plots.ChildAdded:Connect(hook)
end

return LairBanners
