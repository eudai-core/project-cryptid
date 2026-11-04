--!strict

-- Spec 06. Gameplay numbers live here so the server, the client, and the tests
-- share one source. Pass ids stay empty until the monetisation change lands.

local SECONDS_PER_MINUTE = 60
local SECONDS_PER_HOUR = 3600
local CAP_HOURS = 8

local function reward(
	minutes: number,
	floorCash: number,
	speciesId: string?
): { minutes: number, floor: number, speciesId: string? }
	return table.freeze({
		minutes = minutes,
		floor = floorCash,
		speciesId = speciesId,
	})
end

local Return = {
	GATE_STEP = 8,
	EFFICIENCY = 0.2,
	CAP_HOURS = CAP_HOURS,
	SECONDS_PER_MINUTE = SECONDS_PER_MINUTE,
	SECONDS_PER_HOUR = SECONDS_PER_HOUR,
	CAP_SECONDS = CAP_HOURS * SECONDS_PER_HOUR,
	MIN_AWAY_SECONDS = SECONDS_PER_MINUTE,
	SCREEN_AWAY_SECONDS = 5 * SECONDS_PER_MINUTE,
	SCREEN_MIN_HAUL = 1,
	DAY_SECONDS = 24 * SECONDS_PER_HOUR,
	BUTTON_PLAY_SECONDS = 3 * SECONDS_PER_MINUTE,
	PANEL_GAP_SECONDS = 0.5,
	LADDER_STEPS = 7,
	AUTO_COLLECT_SECONDS = 1,
	AUTO_COLLECT_ENABLED = false,
	AUTO_COLLECT_PASS_ID = nil :: number?,
	CASH_DOUBLE_ENABLED = false,
	CASH_DOUBLE_PASS_ID = nil :: number?,
	CASH_DOUBLE_MULTIPLIER = 2,
	SFX_DEFAULT = 1,
	MUSIC_DEFAULT = 1,
	EFFECTS_DEFAULT = "High",
	VOLUME_MIN = 0,
	VOLUME_MAX = 1,
	EFFECTS = table.freeze({ "High", "Medium", "Low" }),
	HAUL_TITLE = "While you were gone…",
	HAUL_BUTTON = "Take the haul",
	OFFERING_TITLE = "The Nightly Offering",
	OFFERING_BUTTON = "Offering",
	OFFERING_ACCEPT = "Accept the offering",
	OFFERING_TOMORROW = "Return tomorrow for the next offering.",
	OFFERING_WAITED = "The offering waited for you.",
	OFFERING_COUNTDOWN = "Next offering in ",
	BOWL_PREFIX = "In the bowl: ",
	SNALLYGASTER_ID = "snallygaster",
	FLATWOODS_ID = "flatwoods_monster",
	SNALLYGASTER_INCOME = 16,
	FLATWOODS_INCOME = 40,
	SILENT_TOAST_SECONDS = 3,
	SILENT_TOAST = "The lair kept earning: +",
	STEPS = table.freeze({
		reward(5, 250, nil),
		reward(10, 500, nil),
		reward(0, 0, "snallygaster"),
		reward(15, 1000, nil),
		reward(20, 2000, nil),
		reward(30, 3000, nil),
		reward(30, 5000, "flatwoods_monster"),
	}),
}

return table.freeze(Return)
