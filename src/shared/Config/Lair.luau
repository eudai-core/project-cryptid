--!strict

local Lair = {
	PAD_DIAMETER = 8,
	WILD_CLEARING_RADIUS = 7,
	CANDLE_RANGE = 18,
	CANDLE_BRIGHTNESS = 2,
	CANDLE_STICK = table.freeze({ x = 0.35, y = 0.9, z = 0.35 }),
	CANDLE_FLAME = table.freeze({ x = 0.25, y = 0.35, z = 0.25 }),
	BEAM_WIDTH = 0.3,
	CATCH_PROMPT_DISTANCE = 12,
	PURCHASE_PROMPT_DISTANCE = 14,
}

return table.freeze(Lair)
