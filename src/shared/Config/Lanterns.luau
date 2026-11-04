--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Plots = import("./Plots", function()
	return script.Parent:WaitForChild("Plots")
end)

local Lanterns = {
	COLOR_TOKEN = "Candle",
	BRIGHTNESS = 1.2,
	RANGE = 16,
	SHADOWS = false,
	PER_PLOT_LIGHT_CAP = 8,
	TOWN_INSET = 4,
	GATE_OUTSET = 1.5,
	GATE_FORWARD = 1.5,
	POST_HEIGHT = 5.5,
	POST_THICKNESS = 0.35,
	GLASS_SIZE = 0.9,
	GLASS_TRANSPARENCY = 0.45,
	ACCENT_HEIGHT = 0.16,
	ACCENT_WIDTH = 1.15,
}

function Lanterns.townOffsets(): { { x: number, z: number } }
	local edge = Plots.FALLBACK_SIZE / 2 - Lanterns.TOWN_INSET
	return {
		{ x = edge, z = edge },
		{ x = edge, z = -edge },
		{ x = -edge, z = edge },
		{ x = -edge, z = -edge },
	}
end

function Lanterns.gateOffsets(): { { x: number, z: number } }
	local x = Plots.LAIR_GATE_WIDTH / 2 + Lanterns.GATE_OUTSET
	local z = Plots.LAIR_GATE_Z + Plots.WALL_THICKNESS / 2 + Lanterns.GATE_FORWARD
	return {
		{ x = -x, z = z },
		{ x = x, z = z },
	}
end

function Lanterns.total(plotCount: number): number
	return #Lanterns.townOffsets() + plotCount * #Lanterns.gateOffsets()
end

return Lanterns
