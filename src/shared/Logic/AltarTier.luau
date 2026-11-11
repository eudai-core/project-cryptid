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

local AltarTier = {}

function AltarTier.span(base: number, shrink: number): number
	local span = base - Plots.PAD_RING_MARGIN - shrink
	if span < Plots.ALTAR_TIER_MIN then
		return Plots.ALTAR_TIER_MIN
	end
	return span
end

function AltarTier.size(step: number): (number, number, number)
	local shrink = (step - 1) * Plots.ALTAR_TIER_INSET
	return AltarTier.span(Plots.ALTAR_SIZE.x, shrink),
		Plots.ALTAR_TIER_HEIGHT,
		AltarTier.span(Plots.ALTAR_SIZE.z, shrink)
end

return AltarTier
