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

local worldReady = false
local starting: { [Player]: boolean } = {}

local function beginPlayer(player: Player)
	if not worldReady or player.Parent == nil or starting[player] == true then
		return
	end
	starting[player] = true
	task.spawn(function()
		PlayerSession.onPlayer(player)
		if player.Parent ~= nil and player.Character == nil then
			player:LoadCharacter()
		end
	end)
end

Players.PlayerAdded:Connect(beginPlayer)
SpawnCheck.start()

LightingSetup.apply()
Plot.build()
worldReady = true

local folder = Remotes.create()
Pedlar.start(function()
	PlayerSession.republish()
end)
PlayerSession.start(folder)

for _, player in Players:GetPlayers() do
	beginPlayer(player)
end
Players.PlayerRemoving:Connect(function(player: Player)
	starting[player] = nil
	PlayerSession.onRemoving(player)
end)
game:BindToClose(PlayerSession.shutdown)
