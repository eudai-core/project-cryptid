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
	local warned = false
	local function safeDress(inst: Instance)
		local ok, err = pcall(dress, inst)
		if not ok and not warned then
			warned = true
			warn(err)
		end
	end
	for _, inst in workspace:GetDescendants() do
		safeDress(inst)
	end
	workspace.DescendantAdded:Connect(safeDress)
end

return TownDress
