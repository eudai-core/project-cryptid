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

local HudSlots = {}

function HudSlots.origin(slotIndex: number): number
	local hud = Plots.RETURN_BUTTON
	return hud.margin + slotIndex * (hud.width + hud.gap)
end

function HudSlots.ritesOrigin(): number
	return HudSlots.origin(Plots.RETURN_BUTTON.occupiedSlots)
end

return HudSlots
