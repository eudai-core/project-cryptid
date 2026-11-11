--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameInfo = require(Shared:WaitForChild("GameInfo")) :: any
local LightingSetup = require(script.Parent:WaitForChild("LightingSetup"))
local Pedlar = require(script.Parent:WaitForChild("Pedlar"))
local PlayerSession = require(script.Parent:WaitForChild("PlayerSession"))
local Plot = require(script.Parent:WaitForChild("Plot"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))
local SpawnCheck = require(script.Parent:WaitForChild("SpawnCheck"))

print(GameInfo.name .. " server started")

LightingSetup.apply()
Plot.build()
SpawnCheck.start()
local folder = Remotes.create()
Pedlar.start(function()
	PlayerSession.republish()
	PlayerSession.onPedlarRotation()
end, function(player)
	PlayerSession.onPedlarOpen(player)
end)
PlayerSession.start(folder)

Players.PlayerAdded:Connect(PlayerSession.onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(PlayerSession.onPlayer, player)
end
Players.PlayerRemoving:Connect(PlayerSession.onRemoving)
game:BindToClose(PlayerSession.shutdown)
