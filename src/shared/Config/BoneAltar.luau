--!strict

-- Bone Altar I–X. Levels I–II each add LINEAR_BONUS. Level L >= 3 adds
-- TAIL_BASE × TAIL_DECAY^(L−TAIL_OFFSET). l3 multiplies that add. Every cost
-- is × REBIRTH_FACTOR^r. r is profile.rebirths. The launch cap is Rebirth.LAUNCH_CAP.

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Rebirth = import("./Rebirth", function()
	return script.Parent:WaitForChild("Rebirth")
end)

local MAX_LEVEL = 10
local LINEAR_LEVELS = 2
local LINEAR_BONUS = 0.25
local TAIL_BASE = 0.25
local TAIL_DECAY = 0.75
local TAIL_OFFSET = 2
local L3_FACTOR = 1.2
local L3_SKILL = "l3"
local REBIRTH_FACTOR = 1.5
local REBIRTH_FIELD = "rebirths"
local MAX_REBIRTHS = Rebirth.LAUNCH_CAP
local FIRST_COST = 300
local SECOND_COST = 1500
local TAIL_FIRST_COST = 8000
local TAIL_GROWTH = 5
local SKILLS_FIELD = "skills"

local function baseCost(level: number): number?
	if level == 1 then
		return FIRST_COST
	end
	if level == 2 then
		return SECOND_COST
	end
	if level < LINEAR_LEVELS + 1 or level > MAX_LEVEL or level ~= math.floor(level) then
		return nil
	end
	return TAIL_FIRST_COST * (TAIL_GROWTH ^ (level - LINEAR_LEVELS - 1))
end

local costs: { [number]: number } = {}
for level = 1, MAX_LEVEL do
	local amount = baseCost(level)
	if amount == nil then
		error("Bone Altar cost missing for level " .. tostring(level))
	end
	costs[level] = amount
end

local BoneAltar = {
	MAX_LEVEL = MAX_LEVEL,
	LINEAR_LEVELS = LINEAR_LEVELS,
	LINEAR_BONUS = LINEAR_BONUS,
	TAIL_BASE = TAIL_BASE,
	TAIL_DECAY = TAIL_DECAY,
	TAIL_OFFSET = TAIL_OFFSET,
	L3_FACTOR = L3_FACTOR,
	L3_SKILL = L3_SKILL,
	REBIRTH_FACTOR = REBIRTH_FACTOR,
	REBIRTH_FIELD = REBIRTH_FIELD,
	MAX_REBIRTHS = MAX_REBIRTHS,
	FIRST_COST = FIRST_COST,
	SECOND_COST = SECOND_COST,
	TAIL_FIRST_COST = TAIL_FIRST_COST,
	TAIL_GROWTH = TAIL_GROWTH,
	COST = table.freeze(costs),
}

function BoneAltar.multiplier(level: number, l3: boolean): number
	local capped = level
	if type(capped) ~= "number" or capped ~= capped or capped == math.huge then
		return 1
	end
	if capped < 0 then
		capped = 0
	end
	if capped > MAX_LEVEL then
		capped = MAX_LEVEL
	end
	capped = math.floor(capped)
	local factor = if l3 == true then L3_FACTOR else 1
	local total = 1
	for step = 1, capped do
		local add = LINEAR_BONUS
		if step > LINEAR_LEVELS then
			local exponent = step - TAIL_OFFSET
			add = TAIL_BASE * (TAIL_DECAY ^ exponent)
		end
		total += add * factor
	end
	return total
end

function BoneAltar.rebirths(profile: any): number
	if type(profile) ~= "table" then
		return 0
	end
	local count = profile[REBIRTH_FIELD]
	if type(count) ~= "number" or count ~= math.floor(count) or count < 0 or count > MAX_REBIRTHS then
		return 0
	end
	return count
end

function BoneAltar.l3Owned(profile: any): boolean
	if type(profile) ~= "table" then
		return false
	end
	local skills = profile[SKILLS_FIELD]
	if type(skills) ~= "table" then
		return false
	end
	if skills[L3_SKILL] == true then
		return true
	end
	for _, id in skills do
		if id == L3_SKILL then
			return true
		end
	end
	return false
end

function BoneAltar.cost(level: number, rebirths: number): number?
	local base = BoneAltar.COST[level]
	if type(base) ~= "number" then
		return nil
	end
	local rebirthCount = rebirths
	if type(rebirthCount) ~= "number" or rebirthCount ~= math.floor(rebirthCount) or rebirthCount < 0 then
		rebirthCount = 0
	end
	if rebirthCount > MAX_REBIRTHS then
		rebirthCount = MAX_REBIRTHS
	end
	return base * (REBIRTH_FACTOR ^ rebirthCount)
end

return BoneAltar
