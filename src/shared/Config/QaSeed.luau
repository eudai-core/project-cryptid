--!strict

-- Studio playtest documents. Live servers never read this.

local QaSeed = {
	V9_VERSION = 9,
	V9_CASH = 250000,
	V9_TITHE = 64000,
	V9_PADS_UNLOCKED = 4,
	REBIRTH6_COUNT = 6,
	STARTER_UID = "qa-seed-a",
	SECOND_UID = "qa-seed-b",
	THIRD_UID = "qa-seed-c",
	LOG_PREFIX = "[Cryptid:Qa]",
}

return table.freeze(QaSeed)
