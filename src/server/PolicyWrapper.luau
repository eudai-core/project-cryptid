--!strict

local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PolicyGate = require(Shared:WaitForChild("Logic"):WaitForChild("PolicyGate"))

local PolicyWrapper = {}

function PolicyWrapper.allows(player: Player): boolean
	if player.Parent == nil then
		return false
	end
	return PolicyGate.allows(tostring(player.UserId), function()
		return PolicyService:GetPolicyInfoForPlayerAsync(player)
	end, function(seconds: number)
		task.wait(seconds)
	end)
end

return PolicyWrapper
