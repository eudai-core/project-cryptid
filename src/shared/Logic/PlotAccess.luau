--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Plots = import("../Config/Plots", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Plots")
end)
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

function PlotAccess.toastFor(visitor: any, owner: any?, samePlayer: boolean): string?
	if samePlayer or owner == nil then
		return nil
	end
	if StealGuard.isProtected(visitor) then
		return Plots.RITE_TOAST
	end
	if StealGuard.isProtected(owner) then
		return Plots.SEAL_TOAST
	end
	return nil
end

return PlotAccess
