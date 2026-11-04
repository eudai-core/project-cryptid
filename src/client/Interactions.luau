--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Economy = require(Shared:WaitForChild("Config"):WaitForChild("Economy")) :: any
local Shop = require(Shared:WaitForChild("Config"):WaitForChild("Shop")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local Interactions = {}

local function fire(remotes: Folder, name: string, ...: any)
	local remote = remotes:WaitForChild(name) :: RemoteEvent
	remote:FireServer(...)
end

local function send(remotes: Folder, names: any, prompt: ProximityPrompt)
	local kind = prompt:GetAttribute("Kind")
	if kind == "BuyRift" then
		fire(remotes, names.BUY_RIFT, prompt:GetAttribute("Slot"))
	elseif kind == "UnlockPad" then
		fire(remotes, names.UNLOCK_PAD, prompt:GetAttribute("Pad"))
	elseif kind == "UpgradeAltar" then
		fire(remotes, names.UPGRADE, "boneAltar")
	elseif kind == "Place" then
		fire(remotes, names.PLACE, prompt:GetAttribute("InstanceId"), prompt:GetAttribute("Pad"))
	elseif kind == "Catch" then
		fire(remotes, names.BEGIN_CATCH)
	end
end

local function plateFor(prompt: ProximityPrompt)
	local parent = prompt.Parent
	if parent == nil or not parent:IsA("BasePart") then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "PromptPlate"
	gui.Size = UDim2.fromOffset(200, 48)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.Enabled = false
	gui.ResetOnSpawn = false
	gui.Parent = parent
	local panel = UiFactory.panel(gui)
	panel.Size = UDim2.fromScale(1, 1)
	local label = UiFactory.label(panel, "body", UITheme.fonts.body.mobile, "Bone")
	label.Size = UDim2.fromScale(1, 1)
	label.TextXAlignment = Enum.TextXAlignment.Center
	ThemeBind.apply(label, "body", UITheme.fonts.body.mobile)
	prompt.PromptShown:Connect(function()
		label.Text = "E  " .. prompt.ActionText
		gui.Enabled = true
	end)
	prompt.PromptHidden:Connect(function()
		gui.Enabled = false
	end)
end

function Interactions.start(player: Player, remotes: Folder, names: any, beginCatch: () -> (), town: any)
	local wired: { [Instance]: boolean } = {}
	local refreshers: { [Instance]: () -> () } = {}

	local function hook(inst: Instance)
		if not inst:IsA("ProximityPrompt") or wired[inst] then
			return
		end
		wired[inst] = true
		local function refresh()
			local publicPrompt = inst:GetAttribute("Public") == true
			local owner = inst:GetAttribute("OwnerUserId")
			local available = inst:GetAttribute("Available") == true
			local parent = inst.Parent
			local sealed = parent ~= nil and parent:GetAttribute("Sealed") == true
			local allowed = available and not sealed
			if not publicPrompt then
				allowed = allowed and owner == player.UserId
			end
			local kindName = inst:GetAttribute("Kind")
			if kindName == "Pedlar" or kindName == "SkillShrine" then
				local step = player:GetAttribute("OnboardingStep")
				if type(step) ~= "number" or step < Shop.GATE_STEP then
					allowed = false
				end
			end
			inst.Enabled = allowed
		end
		refreshers[inst] = refresh
		refresh()
		inst:GetAttributeChangedSignal("Available"):Connect(refresh)
		inst:GetAttributeChangedSignal("OwnerUserId"):Connect(refresh)
		inst:GetAttributeChangedSignal("Public"):Connect(refresh)
		local parent = inst.Parent
		if parent ~= nil then
			parent:GetAttributeChangedSignal("Sealed"):Connect(refresh)
		end
		plateFor(inst)
		inst.Triggered:Connect(function()
			local kind = inst:GetAttribute("Kind")
			if kind == "Catch" then
				beginCatch()
			elseif kind == "Pedlar" then
				town.onPedlar()
			elseif kind == "SkillShrine" then
				town.onShrine()
			else
				send(remotes, names, inst)
			end
		end)
	end

	for _, inst in CollectionService:GetTagged("CryptidPad") do
		local padPrompt = inst:FindFirstChildWhichIsA("ProximityPrompt")
		if padPrompt ~= nil then
			hook(padPrompt)
		end
	end
	local function scan(root: Instance)
		for _, desc in root:GetDescendants() do
			if desc:IsA("ProximityPrompt") then
				hook(desc)
			end
		end
	end
	local plots = workspace:WaitForChild("Plots")
	local townFolder = workspace:WaitForChild("Town")
	scan(plots)
	scan(townFolder)
	player:GetAttributeChangedSignal("OnboardingStep"):Connect(function()
		for _, refresh in refreshers do
			refresh()
		end
	end)
	workspace.DescendantAdded:Connect(function(desc)
		if desc:IsA("ProximityPrompt") then
			hook(desc)
		end
	end)

	local function watchTool(tool: Tool)
		if tool.Name ~= Economy.TOOL_NAME or wired[tool] then
			return
		end
		wired[tool] = true
		tool.Activated:Connect(function()
			beginCatch()
		end)
	end

	local function watchContainer(container: Instance?)
		if container == nil then
			return
		end
		for _, child in container:GetChildren() do
			if child:IsA("Tool") then
				watchTool(child)
			end
		end
		container.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				watchTool(child)
			end
		end)
	end

	watchContainer(player:FindFirstChildOfClass("Backpack"))
	player.CharacterAdded:Connect(function(character)
		watchContainer(character)
	end)
	if player.Character ~= nil then
		watchContainer(player.Character)
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack == nil then
		player.ChildAdded:Connect(function(child)
			if child:IsA("Backpack") then
				watchContainer(child)
			end
		end)
	end
end

return Interactions
