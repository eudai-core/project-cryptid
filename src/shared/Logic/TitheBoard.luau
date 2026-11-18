--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Board = import("../Config/TitheBoard", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("TitheBoard")
end)
local NumberFormat = import("./NumberFormat", function()
	return script.Parent:WaitForChild("NumberFormat")
end)

local TitheBoard = {}

function TitheBoard.label(value: number): string
	local amount = value
	if type(amount) ~= "number" or amount ~= amount or amount == math.huge or amount < 0 then
		amount = 0
	end
	local text = NumberFormat.formatCash(amount)
	if string.sub(text, 1, 1) == "$" then
		return string.sub(text, 2)
	end
	return text
end

function TitheBoard.shouldWrite(lastAt: number?, now: number, previous: number?, score: number): boolean
	if type(now) ~= "number" or type(score) ~= "number" then
		return false
	end
	if type(previous) == "number" and previous == score and type(lastAt) == "number" then
		return false
	end
	if type(lastAt) ~= "number" then
		return true
	end
	return now - lastAt >= Board.WRITE_SECONDS
end

function TitheBoard.order(rows: { any }): { any }
	table.sort(rows, function(a, b)
		if a.tithe ~= b.tithe then
			return a.tithe > b.tithe
		end
		return a.userId < b.userId
	end)
	while #rows > Board.TOP do
		table.remove(rows)
	end
	for _, row in rows do
		row.label = TitheBoard.label(row.tithe)
	end
	return rows
end

function TitheBoard.merge(existing: { any }, updates: { any }): { any }
	local byId: { [number]: any } = {}
	for _, row in existing do
		if type(row) == "table" and type(row.userId) == "number" then
			byId[row.userId] = {
				userId = row.userId,
				name = row.name,
				tithe = row.tithe,
			}
		end
	end
	for _, row in updates do
		if type(row) == "table" and type(row.userId) == "number" and type(row.tithe) == "number" then
			byId[row.userId] = {
				userId = row.userId,
				name = if type(row.name) == "string" and row.name ~= "" then row.name else tostring(row.userId),
				tithe = row.tithe,
			}
		end
	end
	local list = {}
	for _, row in byId do
		table.insert(list, row)
	end
	return TitheBoard.order(list)
end

function TitheBoard.ingest(state: any, ok: boolean, incoming: { any }?, online: { any }?): any
	local base = state.rows
	if type(base) ~= "table" then
		base = {}
	end
	if ok == true and type(incoming) == "table" then
		base = incoming
		state.message = ""
	else
		state.message = Board.REWRITING
	end
	local live = online
	if type(live) ~= "table" then
		live = {}
	end
	state.rows = TitheBoard.merge(base, live)
	local revision = state.revision
	if type(revision) ~= "number" then
		revision = 0
	end
	state.revision = revision + 1
	return state
end

return TitheBoard
