--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local StealGuard = import("./StealGuard", function()
	return script.Parent:WaitForChild("StealGuard")
end)

local PlotAccess = {}

function PlotAccess.mayEnter(visitor: any, owner: any?, samePlayer: boolean): boolean
	if samePlayer then
		return true
	end
	if owner == nil then
		return false
	end
	if StealGuard.isProtected(owner) or StealGuard.isProtected(visitor) then
		return false
	end
	return true
end

function PlotAccess.blocksWithSeal(visitor: any, owner: any?, samePlayer: boolean): boolean
	if samePlayer or owner == nil then
		return false
	end
	return StealGuard.isProtected(owner) or StealGuard.isProtected(visitor)
end

return PlotAccess
