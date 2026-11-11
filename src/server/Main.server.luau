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

local function watchCharacter(player: Player)
	player.CharacterAdded:Connect(function()
		print("[diag] CharacterAdded " .. player.Name) -- TEMP diag
	end)
	player.CharacterRemoving:Connect(function()
		print("[diag] CharacterRemoving " .. player.Name) -- TEMP diag
	end)
end

local function beginPlayer(player: Player, site: string)
	if not worldReady then
		table.insert(waiting, player)
		return
	end
	if player.Parent == nil or starting[player] == true then
		return
	end
	starting[player] = true
	task.spawn(function()
		local opened = PlayerSession.onPlayer(player, site)
		if opened == true and player.Parent ~= nil then
			print("[diag] LoadCharacter " .. player.Name) -- TEMP diag
			player:LoadCharacter()
		end
	end)
end

Players.PlayerAdded:Connect(function(player: Player)
	print("[diag] PlayerAdded " .. player.Name) -- TEMP diag
	watchCharacter(player)
	beginPlayer(player, "added")
end)
for _, player in Players:GetPlayers() do
	watchCharacter(player)
end
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

local folder = Remotes.create()
Pedlar.start(function()
	PlayerSession.republish()
	PlayerSession.onPedlarRotation()
end, function(player)
	PlayerSession.onPedlarOpen(player)
end)
PlayerSession.start(folder)

for _, player in waiting do
	beginPlayer(player, "queue")
end
for _, player in Players:GetPlayers() do
	beginPlayer(player, "players")
end
Players.PlayerRemoving:Connect(function(player: Player)
	starting[player] = nil
	PlayerSession.onRemoving(player)
end)
game:BindToClose(PlayerSession.shutdown)
