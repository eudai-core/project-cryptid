--!strict

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShopAnchors = require(Shared:WaitForChild("Config"):WaitForChild("ShopAnchors")) :: any
local Town = require(Shared:WaitForChild("Config"):WaitForChild("Town")) :: any
local ShopPrompts = require(Shared:WaitForChild("Logic"):WaitForChild("ShopPrompts")) :: any

local anchors: { [string]: BasePart } = {}
local missing: { { shopId: string, path: string } } = {}

local TownShopService = {}

local function makePrompt(host: BasePart, entry: any): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = entry.promptKind
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = Town.PROMPT_DISTANCE
	prompt.ClickablePrompt = true
	prompt.ActionText = entry.actionText
	prompt.ObjectText = entry.displayName
	prompt:SetAttribute("Public", true)
	prompt:SetAttribute("Kind", entry.promptKind)
	prompt:SetAttribute("ShopId", entry.shopId)
	prompt:SetAttribute("Available", true)
	prompt:SetAttribute("OwnerUserId", 0)
	prompt.Parent = host
	return prompt
end

function TownShopService.anchor(shopId: string): BasePart?
	return anchors[shopId]
end

function TownShopService.missing(): { { shopId: string, path: string } }
	return missing
end

function TownShopService.start(town: Folder, onOpen: (Player, any) -> ())
	ShopPrompts.bind(town, {
		waitSeconds = ShopAnchors.WAIT_SECONDS,
		spawn = task.spawn,
		onMissing = function(shopId: string, path: string)
			table.insert(missing, { shopId = shopId, path = path })
			warn(string.format("Town shop anchor missing: %s (%s)", shopId, path))
		end,
		onReady = function(shopId: string, host: any, _created: boolean)
			if host ~= nil and host:IsA("BasePart") then
				anchors[shopId] = host
			end
		end,
		createPrompt = function(host: any, entry: any)
			if host ~= nil and host:IsA("BasePart") then
				makePrompt(host, entry)
			end
		end,
	})
	ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
		if prompt:GetAttribute("Kind") ~= ShopAnchors.PROMPT_KIND then
			return
		end
		onOpen(player, prompt:GetAttribute("ShopId"))
	end)
end

return TownShopService
