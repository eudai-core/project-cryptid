--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local TownDress = {}

local function dress(inst: Instance)
	if not inst:IsA("TextLabel") or inst:GetAttribute("TownSign") ~= true then
		return
	end
	ThemeBind.apply(inst, "body", UITheme.text.minSize)
end

function TownDress.start()
	for _, inst in workspace:GetDescendants() do
		dress(inst)
	end
	workspace.DescendantAdded:Connect(dress)
end

return TownDress
