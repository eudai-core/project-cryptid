--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameInfo = require(Shared:WaitForChild("GameInfo")) :: any
local LightingSetup = require(script.Parent:WaitForChild("LightingSetup"))
local PlayerSession = require(script.Parent:WaitForChild("PlayerSession"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))

print(GameInfo.name .. " server started")

LightingSetup.apply()
local folder = Remotes.create()
PlayerSession.start(folder)

Players.PlayerAdded:Connect(PlayerSession.onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(PlayerSession.onPlayer, player)
end
Players.PlayerRemoving:Connect(PlayerSession.onRemoving)
game:BindToClose(PlayerSession.shutdown)
