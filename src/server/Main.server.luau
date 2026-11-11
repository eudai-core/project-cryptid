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
print("[diag] CharacterAutoLoads=" .. tostring(Players.CharacterAutoLoads)) -- TEMP diag

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
		PlayerSession.onPlayer(player)
		if player.Parent ~= nil and player.Character == nil then
			print("[diag] LoadCharacter " .. player.Name) -- TEMP diag
			player:LoadCharacter()
		end
	end)
end

Players.PlayerAdded:Connect(function(player: Player)
	print("[diag] PlayerAdded " .. player.Name) -- TEMP diag
	beginPlayer(player)
end)
SpawnCheck.start()

LightingSetup.apply()
print("[diag] build start") -- TEMP diag
Plot.build()
local town = workspace:FindFirstChild("Town")
local partCount = 0
if town ~= nil then
	for _, inst in town:GetDescendants() do
		if inst:IsA("BasePart") then
			partCount += 1
		end
	end
end
print("[diag] build done " .. tostring(partCount)) -- TEMP diag
worldReady = true
for _, player in waiting do
	beginPlayer(player)
end

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
