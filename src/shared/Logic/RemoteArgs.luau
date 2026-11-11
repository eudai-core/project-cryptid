--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
end)
local SkillConfig = import("../Config/SkillConfig", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("SkillConfig")
end)
local Shop = import("../Config/Shop", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Shop")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)

local RemoteArgs = {}

function RemoteArgs.slot(value: any): number?
	if type(value) ~= "number" or value ~= math.floor(value) then
		return nil
	end
	if value < 1 or value > #Species.GUARANTEES then
		return nil
	end
	return value
end

function RemoteArgs.pad(value: any): number?
	if type(value) ~= "number" or value ~= math.floor(value) then
		return nil
	end
	if value < 1 or value > Economy.MAX_PADS then
		return nil
	end
	return value
end

function RemoteArgs.upgradeId(value: any): string?
	if value ~= "boneAltar" then
		return nil
	end
	return value
end

function RemoteArgs.instanceId(value: any): string?
	if type(value) ~= "string" or #value < 1 or #value > 64 then
		return nil
	end
	if string.match(value, "^[%w%-]+$") == nil then
		return nil
	end
	return value
end

function RemoteArgs.pedlarSlot(value: any): number?
	if type(value) ~= "number" or value ~= math.floor(value) then
		return nil
	end
	if value < 1 or value > Shop.SLOT_COUNT then
		return nil
	end
	return value
end

function RemoteArgs.rotationId(value: any): number?
	if type(value) ~= "number" or value ~= math.floor(value) then
		return nil
	end
	if value < 0 or value > 1e12 then
		return nil
	end
	return value
end

function RemoteArgs.skillId(value: any): string?
	if type(value) ~= "string" or #value < 1 or #value > SkillConfig.ID_MAX then
		return nil
	end
	if string.match(value, "^[%w]+$") == nil then
		return nil
	end
	if SkillConfig.get(value) == nil then
		return nil
	end
	return value
end

function RemoteArgs.flag(value: any): boolean?
	if type(value) ~= "boolean" then
		return nil
	end
	return value
end

function RemoteArgs.withinDistance(distance: number?, limit: number): boolean
	if type(distance) ~= "number" or distance ~= distance then
		return false
	end
	return distance <= limit
end

function RemoteArgs.catchElapsed(elapsed: number?, required: number): boolean
	if type(elapsed) ~= "number" or elapsed ~= elapsed then
		return false
	end
	return elapsed >= required
end

return RemoteArgs
