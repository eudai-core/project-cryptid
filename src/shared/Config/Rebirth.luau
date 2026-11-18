--!strict

-- Spec 07 v3. Tiers 1–7. Tier 8+ stays sealed.
-- Cost is BASE_COST × COST_GROWTH^(n−1). Income multiplier is MULT_BASE + MULT_STEP × rebirths.
-- Tithe gate: tier 1 is its cost, tier 2 is the sum of costs 1..2, tier 3+ is
-- TITHE_FRACTION × the sum of costs 1..n, rounded to TITHE_ROUND.

local Rebirth = {
	BASE_COST = 5000000,
	COST_GROWTH = 3,
	MULT_BASE = 1,
	MULT_STEP = 0.5,
	TITHE_FRACTION = 0.75,
	TITHE_ROUND = 1000000,
	FULL_SUM_TIER = 2,
	LAUNCH_CAP = 7,
	CASH_AFTER = 100,
	REVEAL_CASH = 1000000,
	DEBOUNCE_SECONDS = 0.25,
	ONBOARDING_STEP = 8,
	KEPT_PAD = 1,
	PRICE_FACTOR = 1.5,
	PRICE_FACTOR_DECIMALS = 2,
	FAMILIAR_MAX = 64,
	TITLE = "The Rite of Rebirth",
	PROMPT = "Rite of Rebirth",
	BODY = "Offer %s to the Rift. Your lair returns to dust, but you return stronger: all income ×%s, forever.",
	KEEP_TITLE = "You keep:",
	KEEP_BODY = "Skills, one familiar, the grimoire, passes, cosmetics, the daily offering, and your Tithe.",
	LOSE_TITLE = "You lose:",
	LOSE_BODY = "Cash (including your other %s), pads 3–8, the altar level, and your other cryptids.",
	PICKER = "Choose one cryptid to follow you through the Rift.",
	CONFIRM = "Begin the Rite",
	SECOND = "This can't be undone. Begin?",
	YES = "Yes",
	NOT_YET = "Not yet",
	TOAST = "You are reborn. Income ×%s.",
	SEALED = "The eighth rite is not yet written.",
	UNFINISHED = "The first rite is unfinished.",
	GATHER = "Gather %s more",
	TITHE_LINE = "Tithe %s / %s",
	NEXT_COST = "Next rite %s",
	MULTIPLIER_LINE = "Income ×%s",
	TITHE_BAR = "Tithe %s / %s",
}

return table.freeze(Rebirth)
