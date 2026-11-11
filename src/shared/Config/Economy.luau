--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local BoneAltar = import("./BoneAltar", function()
	return script.Parent:WaitForChild("BoneAltar")
end)

local PAD_7_COST = 15000
local PAD_8_COST = 40000

local Economy = {
	STARTING_CASH = 25,
	INCOME_INTERVAL_SECONDS = 1,
	PURCHASE_DEBOUNCE_SECONDS = 0.25,
	CATCH_DISTANCE_STUDS = 12,
	CATCH_SECONDS = 3,
	CATCH_CLIENT_BUFFER_SECONDS = 0.15,
	WILD_SPAWN_STUDS = 20,
	STARTING_PADS_UNLOCKED = 2,
	CASH_PAD_MAX = 8,
	MAX_PADS = 10,
	PAD_7_COST = PAD_7_COST,
	PAD_8_COST = PAD_8_COST,
	ALTAR_BONUS_PER_LEVEL = BoneAltar.LINEAR_BONUS,
	MAX_ALTAR_LEVEL = BoneAltar.MAX_LEVEL,
	WARD_CANDLES_COST = 1200,
	STEAL_PROTECTION_PLAY_SECONDS = 300,
	TOOL_NAME = "Lantern",
	PAD_COST = table.freeze({
		[1] = 0,
		[2] = 0,
		[3] = 120,
		[4] = 400,
		[5] = 1200,
		[6] = 3000,
		[7] = PAD_7_COST,
		[8] = PAD_8_COST,
	}),
	ALTAR_COST = BoneAltar.COST,
}

function Economy.padCost(index: number, rebirths: number): number?
	local base = Economy.PAD_COST[index]
	if type(base) ~= "number" then
		return nil
	end
	local rebirthCount = rebirths
	if type(rebirthCount) ~= "number" or rebirthCount ~= math.floor(rebirthCount) or rebirthCount < 0 then
		rebirthCount = 0
	end
	if rebirthCount > BoneAltar.MAX_REBIRTHS then
		rebirthCount = BoneAltar.MAX_REBIRTHS
	end
	return base * (BoneAltar.REBIRTH_FACTOR ^ rebirthCount)
end

return table.freeze(Economy)
