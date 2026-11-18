--!strict

-- The Pale Pedlar sells supplies through the town shop counter.
-- This module only hears the existing stall prompt. It does not publish a cryptid rotation.

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Town = require(Shared:WaitForChild("Config"):WaitForChild("Town")) :: any

local Pedlar = {}

function Pedlar.offers(): any
	return nil
end

function Pedlar.start(_onRotation: any, onBrowse: any)
	if onBrowse == nil then
		return
	end
	local promptName = if type(Town.PEDLAR_PROMPT_NAME) == "string" then Town.PEDLAR_PROMPT_NAME else "Pedlar"
	ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
		if prompt.Name ~= promptName then
			return
		end
		onBrowse(player)
	end)
end

return Pedlar
