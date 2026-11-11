--!strict

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Board = require(Shared:WaitForChild("Config"):WaitForChild("TitheBoard")) :: any
local Logic = require(Shared:WaitForChild("Logic"):WaitForChild("TitheBoard")) :: any

local TitheLedger = {}

local scores: { [number]: number } = {}
local names: { [number]: string } = {}
local lastWriteAt: { [number]: number } = {}
local lastWritten: { [number]: number } = {}
local state = {
	rows = {},
	message = "",
	revision = 0,
}
local boardValue: StringValue? = nil
local ordered: any = nil
local running = false
local lastReadAt = 0

local function columnFor(player: Player): StringValue
	local stats = player:FindFirstChild("leaderstats")
	if stats == nil or not stats:IsA("Folder") then
		local folder = Instance.new("Folder")
		folder.Name = "leaderstats"
		folder.Parent = player
		stats = folder
	end
	local column = stats:FindFirstChild(Board.COLUMN)
	if column == nil or not column:IsA("StringValue") then
		if column ~= nil then
			column:Destroy()
		end
		local value = Instance.new("StringValue")
		value.Name = Board.COLUMN
		value.Parent = stats
		column = value
	end
	return column :: StringValue
end

function TitheLedger.note(player: Player, tithe: number)
	local amount = tithe
	if type(amount) ~= "number" or amount ~= amount or amount < 0 or amount == math.huge then
		amount = 0
	end
	local score = math.floor(amount)
	scores[player.UserId] = score
	names[player.UserId] = player.Name
	columnFor(player).Value = Logic.label(amount)
end

local function onlineRows(): { any }
	local updates = {}
	for userId, score in scores do
		local name = names[userId]
		table.insert(updates, {
			userId = userId,
			name = if type(name) == "string" and name ~= "" then name else tostring(userId),
			tithe = score,
		})
	end
	return updates
end

local function store(): any
	if ordered ~= nil then
		return ordered
	end
	local ok, result = pcall(function()
		return DataStoreService:GetOrderedDataStore(Board.STORE_NAME)
	end)
	if ok then
		ordered = result
	end
	return ordered
end

local function readBoard(dataStore: any): (boolean, { any })
	local ok, pages = pcall(function()
		return dataStore:GetSortedAsync(false, Board.TOP)
	end)
	if not ok or pages == nil then
		return false, {}
	end
	local pageOk, page = pcall(function()
		return pages:GetCurrentPage()
	end)
	if not pageOk or type(page) ~= "table" then
		return false, {}
	end
	local incoming = {}
	for _, entry in page do
		if type(entry) == "table" then
			local userId = tonumber(entry.key)
			local score = entry.value
			if type(userId) == "number" and type(score) == "number" then
				local name = names[userId]
				table.insert(incoming, {
					userId = userId,
					name = if type(name) == "string" and name ~= "" then name else tostring(userId),
					tithe = score,
				})
			end
		end
	end
	return true, incoming
end

local function writeDue(dataStore: any, now: number)
	for userId, score in scores do
		if Logic.shouldWrite(lastWriteAt[userId], now, lastWritten[userId], score) then
			local key = tostring(userId)
			local ok = pcall(function()
				dataStore:SetAsync(key, score)
			end)
			if ok then
				lastWriteAt[userId] = now
				lastWritten[userId] = score
			end
		end
	end
end

local function publish()
	if boardValue == nil then
		return
	end
	local payload = {
		message = state.message,
		rows = state.rows,
		revision = state.revision,
	}
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(payload)
	end)
	if ok and type(encoded) == "string" then
		boardValue.Value = encoded
	end
end

local function cycle(now: number)
	local dataStore = store()
	local readOk = false
	local incoming = nil
	local attempted = false
	if dataStore ~= nil and (lastReadAt == 0 or now - lastReadAt >= Board.READ_SECONDS) then
		attempted = true
		readOk, incoming = readBoard(dataStore)
		if readOk then
			lastReadAt = now
		end
	end
	if dataStore ~= nil then
		writeDue(dataStore, now)
	end
	local live = onlineRows()
	if readOk then
		Logic.ingest(state, true, incoming, live)
	elseif attempted or dataStore == nil then
		Logic.ingest(state, false, nil, live)
	else
		Logic.ingest(state, state.message == "", state.rows, live)
	end
	publish()
end

function TitheLedger.start()
	if running then
		return
	end
	running = true
	local folder = ReplicatedStorage:FindFirstChild("TitheState")
	if folder == nil or not folder:IsA("Folder") then
		local created = Instance.new("Folder")
		created.Name = "TitheState"
		created.Parent = ReplicatedStorage
		folder = created
	end
	local existing = folder:FindFirstChild("Board")
	if existing == nil or not existing:IsA("StringValue") then
		if existing ~= nil then
			existing:Destroy()
		end
		local value = Instance.new("StringValue")
		value.Name = "Board"
		value.Parent = folder
		boardValue = value
	else
		boardValue = existing
	end
	Players.PlayerRemoving:Connect(function(player)
		scores[player.UserId] = nil
	end)
	task.spawn(function()
		while running do
			cycle(os.clock())
			task.wait(Board.READ_SECONDS)
		end
	end)
end

return TitheLedger
