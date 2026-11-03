--!strict

local Lair = {
	PLOT_STRIDE = 220,
	FLOOR_SIZE = table.freeze({ x = 96, y = 1, z = 88 }),
	WALL_HEIGHT = 12,
	WALL_THICKNESS = 2,
	EXIT_GAP = 14,
	PAD_DIAMETER = 8,
	PAD_POSITIONS = table.freeze({
		table.freeze({ x = -18, z = -2 }),
		table.freeze({ x = 0, z = -2 }),
		table.freeze({ x = 18, z = -2 }),
		table.freeze({ x = -18, z = -20 }),
		table.freeze({ x = 0, z = -20 }),
		table.freeze({ x = 18, z = -20 }),
	}),
	CONVEYOR_Z = 16,
	CONVEYOR_LENGTH = 36,
	CONVEYOR_WIDTH = 8,
	ALTAR_Z = -34,
	SPAWN_Z = 30,
	WILD_CLEARING_RADIUS = 7,
	CANDLE_RANGE = 18,
	CANDLE_BRIGHTNESS = 2,
	BEAM_WIDTH = 0.3,
	CATCH_PROMPT_DISTANCE = 12,
	PURCHASE_PROMPT_DISTANCE = 14,
}

return table.freeze(Lair)
