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
	RETURN_TO_LAIR = "RequestReturnToLair",
	PEDLAR_BUY = "RequestPedlarBuy",
	BIND_AT_ONCE = "RequestSetBindAtOnce",
	CLAIM_HAUL = "RequestClaimHaul",
	CLAIM_DAILY = "RequestClaimDaily",
	SET_SETTINGS = "RequestSetSettings",
	OPEN_RELICS = "RequestOpenRelics",
	BUY_RELIC = "RequestRelic",
}

return table.freeze(Remotes)
