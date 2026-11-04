--!strict

local Remotes = {
	FOLDER = "CryptidRemotes",
	BUY_RIFT = "RequestBuyRift",
	UNLOCK_PAD = "RequestUnlockPad",
	UPGRADE = "RequestUpgrade",
	PLACE = "RequestPlace",
	SKIP = "RequestSkipOnboarding",
	BEGIN_CATCH = "RequestBeginCatch",
	COMPLETE_CATCH = "RequestCompleteCatch",
	REDUCED_MOTION = "RequestSetReducedMotion",
}

return table.freeze(Remotes)
