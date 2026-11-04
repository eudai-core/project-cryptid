--!strict

local Save = {
	DATA_VERSION = 2,
	STORE_NAME = "ProjectCryptid_Player_v1",
	KEY_PREFIX = "player_",
	MAX_ATTEMPTS = 3,
	BACKOFF_BASE_SECONDS = 1,
	AUTOSAVE_SECONDS = 60,
	LOCK_TTL_SECONDS = 90,
	LOCK_REFRESH_SECONDS = 30,
	PURCHASE_SAVE_THROTTLE_SECONDS = 2,
	KICK_LOAD_FAILED = "The ledger would not open. Rejoin.",
	KICK_LOCKED = "The ledger is open elsewhere. Rejoin.",
}

return table.freeze(Save)
