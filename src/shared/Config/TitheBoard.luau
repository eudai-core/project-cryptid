--!strict

-- Spec 07 §3. One stat, written and read on the same cadence.

local TitheBoard = {
	STORE_NAME = "TitheBoard_v1",
	TOP = 50,
	WRITE_SECONDS = 120,
	READ_SECONDS = 120,
	COLUMN = "Tithe",
	TITLE = "The Ledger of Tithes",
	REWRITING = "The ledger is being rewritten…",
	TAG = "TitheLedger",
}

return table.freeze(TitheBoard)
