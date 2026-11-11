--!strict

local Onboarding = {
	GOAL_ONE_SECONDS = 5,
	CATCH_STEP = 3,
	HODAG_PAD = 3,
	RIFT_2_PAD = 4,
	SKIP_LABEL = "Skip the rite",
	BIND_HINT = "Carve a circle to bind it.",
	NEEDS_CIRCLE = "Needs a free circle",
	STEP_ONE_PROGRESS = "The coffers are stirring.",
	CATCH_PROGRESS = "0 / 1",
	PLACE_PROGRESS = "Bind your catch.",
	WARD_LOCKED_LABEL = "The wax is not yet cast.",
	TEASE_LINE = "Three marks. Rarer things are watching.",
	REVEAL_SECONDS = 0.6,
	TEASE_FADE_IN = 0.2,
	TEASE_HOLD = 2.5,
	TEASE_FADE_OUT = 0.3,
	TEASE_PIPS = table.freeze({ "Common", "Uncommon", "Rare" }),
	HEADLINES = table.freeze({
		[1] = "Your first familiar stirs. Watch it feed your coffers.",
		[2] = "The Rift offers a creature. Claim it.",
		[3] = "Take up your lantern. Something waits in the wild.",
		[4] = "Carve a third circle and bind your catch.",
		[5] = "Raise the Bone Altar.",
		[6] = "Carve a fourth circle.",
		[7] = "Bind another from the Rift.",
		[8] = "Others hunger for your menagerie. Light the Ward Candles.",
	}),
}

return table.freeze(Onboarding)
