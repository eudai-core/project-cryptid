--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any

local SpawnCheck = {}

local function report(player: Player, character: Model)
	task.delay(Plots.SPAWN_CHECK_SECONDS, function()
		if player.Parent == nil or player.Character ~= character then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")
		local health = if humanoid ~= nil then humanoid.Health else 0
		if root == nil or not root:IsA("BasePart") or humanoid == nil or health <= 0 then
			warn(string.format("FAIL spawn %s health %.0f floor none", player.Name, health))
			return
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { character }
		local hit = workspace:Raycast(root.Position, Vector3.new(0, -Plots.SPAWN_RAY_STUDS, 0), params)
		if hit ~= nil and hit.Instance.CanCollide then
			print(
				string.format(
					"PASS spawn %s health %.0f floor %s %.2f studs",
					player.Name,
					health,
					hit.Instance.Name,
					hit.Distance
				)
			)
			return
		end
		warn(string.format("FAIL spawn %s health %.0f floor none", player.Name, health))
	end)
end

local function watch(player: Player)
	player.CharacterAdded:Connect(function(character)
		report(player, character)
	end)
	if player.Character ~= nil then
		report(player, player.Character)
	end
end

function SpawnCheck.start()
	if not RunService:IsStudio() then
		return
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
end

return SpawnCheck
