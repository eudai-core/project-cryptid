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
local TitheLedger = require(script.Parent:WaitForChild("TitheLedger"))
local SpawnCheck = require(script.Parent:WaitForChild("SpawnCheck"))

print(GameInfo.name .. " server started")

local worldReady = false
local starting: { [Player]: boolean } = {}
local waiting: { Player } = {}

local function beginPlayer(player: Player)
	if not worldReady then
		table.insert(waiting, player)
		return
	end
	if player.Parent == nil or starting[player] == true then
		return
	end
	starting[player] = true
	task.spawn(function()
		local opened = PlayerSession.onPlayer(player)
		if opened == true and player.Parent ~= nil then
			player:LoadCharacter()
		end
	end)
end

Players.PlayerAdded:Connect(function(player: Player)
	beginPlayer(player)
end)
SpawnCheck.start()

LightingSetup.apply()
Plot.build()
worldReady = true

local folder = Remotes.create()
Pedlar.start(function()
	PlayerSession.republish()
	PlayerSession.onPedlarRotation()
end, function(player)
	PlayerSession.onPedlarOpen(player)
end)
TitheLedger.start()
PlayerSession.start(folder)

for _, player in waiting do
	beginPlayer(player)
end
for _, player in Players:GetPlayers() do
	beginPlayer(player)
end
Players.PlayerRemoving:Connect(function(player: Player)
	starting[player] = nil
	PlayerSession.onRemoving(player)
end)
game:BindToClose(PlayerSession.shutdown)
