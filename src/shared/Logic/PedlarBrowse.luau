--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Debounce = import("./Debounce", function()
	return script.Parent:WaitForChild("Debounce")
end)
local RemoteArgs = import("./RemoteArgs", function()
	return script.Parent:WaitForChild("RemoteArgs")
end)
local Town = import("../Config/Town", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Town")
end)

local PedlarBrowse = {}

function PedlarBrowse.admit(distance: number?, step: number?, gate: number, limit: number): string
	if type(step) ~= "number" or step < gate then
		return "step"
	end
	if RemoteArgs.withinDistance(distance, limit) ~= true then
		return "distance"
	end
	return "ok"
end

function PedlarBrowse.tryOpen(
	distance: number?,
	step: number?,
	gate: number,
	limit: number,
	now: number,
	lastAt: number?,
	interval: number
): (boolean, number?)
	if PedlarBrowse.admit(distance, step, gate, limit) ~= "ok" then
		return false, lastAt
	end
	local allowed, at = Debounce.allow(lastAt, now, interval)
	if not allowed then
		return false, lastAt
	end
	return true, at
end

function PedlarBrowse.reveal(gui: { Visible: boolean })
	gui.Visible = true
end

function PedlarBrowse.findPrompt(town: any): any
	if town == nil or type(town.FindFirstChild) ~= "function" then
		return nil
	end
	local districts = town:FindFirstChild("Districts")
	if districts == nil then
		return nil
	end
	local model = districts:FindFirstChild(Town.PEDLAR_ID)
	if model == nil then
		return nil
	end
	local host = model:FindFirstChild(Town.PEDLAR_HOST)
	if host == nil then
		return nil
	end
	return host:FindFirstChild(Town.PEDLAR_PROMPT_NAME)
end

return PedlarBrowse
