--!strict

-- Launch shop. Ids and catalog prices stay unset until the account owner
-- creates the products. A missing id keeps the item disabled.

local SECONDS_PER_MINUTE = 60
local MINUTES_PER_HOUR = 60

local function pass(key: string, feature: boolean, looks: boolean): any
	return table.freeze({
		key = key,
		kind = "pass",
		feature = feature,
		looks = looks,
	})
end

local function bundle(key: string, minutes: number, minimum: number, span: string): any
	return table.freeze({
		key = key,
		kind = "bundle",
		feature = true,
		looks = false,
		minutes = minutes,
		minimum = minimum,
		span = span,
	})
end

local ITEMS = table.freeze({
	pass("starterPack", true, false),
	pass("cashDouble", true, false),
	pass("extraPads", true, false),
	pass("lairCosmetics", true, true),
	pass("autoCollect", false, false),
	pass("sigilNameplate", false, true),
	bundle("pouch", 10, 2000, "10 min"),
	bundle("coffer", 45, 10000, "45 min"),
	bundle("chest", 2 * MINUTES_PER_HOUR, 30000, "2 h"),
	bundle("vault", 5 * MINUTES_PER_HOUR, 75000, "5 h"),
})

local BY_KEY: { [string]: any } = {}
for _, entry in ITEMS do
	BY_KEY[entry.key] = entry
end

local Monetisation = {
	GATE_STEP = 8,
	GATE_MINUTES = 5,
	GATE_PLAY_SECONDS = 5 * SECONDS_PER_MINUTE,
	QUOTE_LOCK_MINUTES = 5,
	QUOTE_LOCK_SECONDS = 5 * SECONDS_PER_MINUTE,
	SECONDS_PER_MINUTE = SECONDS_PER_MINUTE,
	LEDGER_CAP = 500,
	POLICY_ATTEMPTS = 3,
	POLICY_BACKOFF = table.freeze({ 1, 2, 4 }),
	OWNERSHIP_ATTEMPTS = 3,
	OWNERSHIP_BACKOFF = table.freeze({ 1, 2, 4 }),
	RARE_REVEAL_SECONDS = 2,
	STARTER_CASH = 5000,
	STARTER_SPECIES = "hidebehind",
	FOUNDERS_CANDLE = "founders_candle",
	LAIR_COSMETIC = "lair_cosmetics",
	RELIC_PADS = table.freeze({ 9, 10 }),
	KEY_MAX = 64,
}

function Monetisation.items(): { any }
	return ITEMS
end

function Monetisation.byKey(key: string): any?
	return BY_KEY[key]
end

function Monetisation.isLive(entry: any): boolean
	if type(entry) ~= "table" or entry.feature ~= true then
		return false
	end
	local id = entry.id
	if type(id) ~= "number" or id ~= id or id == math.huge or id <= 0 or id ~= math.floor(id) then
		return false
	end
	return true
end

function Monetisation.passLive(key: string): boolean
	return Monetisation.isLive(Monetisation.byKey(key))
end

local function findById(kind: string, id: any): any?
	if type(id) ~= "number" then
		return nil
	end
	for _, entry in ITEMS do
		if entry.kind == kind and entry.id == id and Monetisation.isLive(entry) then
			return entry
		end
	end
	return nil
end

function Monetisation.productById(id: any): any?
	return findById("bundle", id)
end

function Monetisation.passById(id: any): any?
	return findById("pass", id)
end

function Monetisation.isRelicPad(index: number): boolean
	for _, pad in Monetisation.RELIC_PADS do
		if pad == index then
			return true
		end
	end
	return false
end

function Monetisation.relicLocked(profile: any, index: number): boolean
	if not Monetisation.isRelicPad(index) or type(profile) ~= "table" then
		return false
	end
	local unlocked = profile.padsUnlocked
	if type(unlocked) ~= "number" then
		return true
	end
	return index > unlocked
end

function Monetisation.shopOpen(profile: any): boolean
	if type(profile) ~= "table" or type(profile.onboarding) ~= "table" then
		return false
	end
	local step = profile.onboarding.step
	local played = profile.onboarding.playSeconds
	if type(step) ~= "number" or type(played) ~= "number" then
		return false
	end
	return step >= Monetisation.GATE_STEP and played >= Monetisation.GATE_PLAY_SECONDS
end

return Monetisation
