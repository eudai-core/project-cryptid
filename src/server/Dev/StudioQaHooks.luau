--!strict

local RunService = game:GetService("RunService")

local StudioQaHooks = {}

function StudioQaHooks.args(): any
	if not RunService:IsStudio() then
		return nil
	end
	local ok, args = pcall(function()
		return (game:GetService("StudioTestService") :: any):GetTestArgs()
	end)
	if not ok then
		return nil
	end
	return args
end

return StudioQaHooks
