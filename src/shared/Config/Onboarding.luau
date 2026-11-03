--!strict

local Onboarding = {
	GOAL_ONE_SECONDS = 5,
	SKIP_LABEL = "Skip the rite",
	BIND_HINT = "Carve a circle to bind it.",
	STEP_ONE_PROGRESS = "The coffers are stirring.",
	CATCH_PROGRESS = "0 / 1",
	PLACE_PROGRESS = "Bind your catch.",
	WARD_LOCKED_LABEL = "The wax is not yet cast.",
	HEADLINES = table.freeze({
		[1] = "Your first familiar stirs. Watch it feed your coffers.",
		[2] = "The Rift offers a creature. Claim it.",
		[3] = "Carve a third circle.",
		[4] = "Bind another from the Rift.",
		[5] = "Raise the Bone Altar.",
		[6] = "Take up your lantern. Something waits in the wild.",
		[7] = "Carve a fourth circle and bind your catch.",
		[8] = "Others hunger for your menagerie. Light the Ward Candles.",
	}),
}

return table.freeze(Onboarding)
