--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Monetisation = import("../Config/Monetisation", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Monetisation")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)

local MonetisationProfile = {}

local function keyOk(key: any): boolean
	if type(key) ~= "string" or #key < 1 or #key > Monetisation.KEY_MAX then
		return false
	end
	return string.match(key, "^[%w_%-]+$") ~= nil
end

local function flagMap(raw: any): { [string]: boolean }?
	if type(raw) ~= "table" then
		return nil
	end
	local map = {}
	for key, value in raw do
		if not keyOk(key) or value ~= true then
			return nil
		end
		map[key] = true
	end
	return map
end

local function whole(value: any, maximum: number): number?
	if type(value) ~= "number" or value ~= math.floor(value) or value < 0 or value > maximum then
		return nil
	end
	return value
end

function MonetisationProfile.defaults(): any
	return {
		purchases = {
			ledger = {},
			ritesOwned = {},
			quotes = {},
			starterPackClaimed = false,
		},
		cosmetics = {
			owned = {},
		},
		giftedPasses = {},
		giftsReceived = {},
		tarot = {
			tokens = { pale = 0, blood = 0 },
			pity = { pale = 0, blood = 0 },
			marks = {},
			milestonesClaimed = {},
		},
		bloodMoon = {
			boughtToday = { utcDay = 0, count = 0 },
		},
		ui = {
			relicsPipShown = false,
			relicsPipCleared = false,
		},
		cashDouble = false,
		autoCollect = false,
		passes = {
			extraPads = false,
			lairCosmetics = false,
			sigilNameplate = false,
		},
	}
end

function MonetisationProfile.applyDefaults(profile: any)
	local fresh = MonetisationProfile.defaults()
	for key, value in fresh do
		profile[key] = value
	end
end

function MonetisationProfile.pruneLedger(ledger: { [string]: any })
	local rows = {}
	for id, entry in ledger do
		table.insert(rows, {
			id = id,
			at = entry.grantedAt,
		})
	end
	if #rows <= Monetisation.LEDGER_CAP then
		return
	end
	table.sort(rows, function(a, b)
		if a.at == b.at then
			return a.id < b.id
		end
		return a.at < b.at
	end)
	local extra = #rows - Monetisation.LEDGER_CAP
	for index = 1, extra do
		ledger[rows[index].id] = nil
	end
end

local function parseGrants(raw: any): { string }?
	if type(raw) ~= "table" then
		return nil
	end
	local grants = {}
	for index = 1, #raw do
		local grant = raw[index]
		if type(grant) ~= "string" or #grant < 1 or #grant > Monetisation.KEY_MAX then
			return nil
		end
		if string.match(grant, "^[%w_:%-.]+$") == nil then
			return nil
		end
		grants[index] = grant
	end
	for key in raw do
		if type(key) ~= "number" then
			return nil
		end
	end
	return grants
end

local function parseLedger(raw: any): { [string]: any }?
	if type(raw) ~= "table" then
		return nil
	end
	local ledger = {}
	for id, entry in raw do
		if not keyOk(id) then
			return nil
		end
		if type(entry) ~= "table" then
			return nil
		end
		local productId = entry.productId
		if type(productId) ~= "number" or productId ~= math.floor(productId) or productId < 0 or productId > 1e15 then
			return nil
		end
		if not Money.isFinite(entry.grantedAt) or entry.grantedAt < 0 then
			return nil
		end
		local grants = parseGrants(entry.grants)
		if grants == nil then
			return nil
		end
		ledger[id] = {
			productId = productId,
			grantedAt = entry.grantedAt,
			grants = grants,
		}
	end
	MonetisationProfile.pruneLedger(ledger)
	return ledger
end

local function parseQuotes(raw: any): { [string]: any }?
	if type(raw) ~= "table" then
		return nil
	end
	local quotes = {}
	for key, entry in raw do
		local spec = if type(key) == "string" then Monetisation.byKey(key) else nil
		if spec == nil or spec.kind ~= "bundle" or type(entry) ~= "table" then
			return nil
		end
		if not Money.isFinite(entry.amount) or entry.amount < 0 then
			return nil
		end
		if not Money.isFinite(entry.expiresAt) or entry.expiresAt < 0 then
			return nil
		end
		quotes[key] = {
			amount = Money.round(entry.amount),
			expiresAt = entry.expiresAt,
		}
	end
	return quotes
end

local function parseGifted(raw: any): { [string]: any }?
	if type(raw) ~= "table" then
		return nil
	end
	local gifted = {}
	for key, entry in raw do
		local spec = if type(key) == "string" then Monetisation.byKey(key) else nil
		if spec == nil or spec.kind ~= "pass" or type(entry) ~= "table" then
			return nil
		end
		local fromUserId = entry.fromUserId
		if type(fromUserId) ~= "number" or fromUserId ~= math.floor(fromUserId) or fromUserId < 0 then
			return nil
		end
		if type(entry.purchaseId) ~= "string" or not keyOk(entry.purchaseId) then
			return nil
		end
		gifted[key] = {
			fromUserId = fromUserId,
			purchaseId = entry.purchaseId,
		}
	end
	return gifted
end

local function parseMarks(raw: any): { [string]: number }?
	if type(raw) ~= "table" then
		return nil
	end
	local marks = {}
	for key, value in raw do
		if not keyOk(key) then
			return nil
		end
		local count = whole(value, 1e12)
		if count == nil then
			return nil
		end
		marks[key] = count
	end
	return marks
end

local function parsePair(raw: any): { pale: number, blood: number }?
	if type(raw) ~= "table" then
		return nil
	end
	local pale = whole(raw.pale, 1e12)
	local blood = whole(raw.blood, 1e12)
	if pale == nil or blood == nil then
		return nil
	end
	return {
		pale = pale,
		blood = blood,
	}
end

function MonetisationProfile.parse(profile: any, raw: any): boolean
	if type(raw) ~= "table" or type(raw.purchases) ~= "table" or type(raw.cosmetics) ~= "table" then
		return false
	end
	if type(raw.tarot) ~= "table" or type(raw.bloodMoon) ~= "table" or type(raw.ui) ~= "table" then
		return false
	end
	if type(raw.passes) ~= "table" then
		return false
	end
	local ledger = parseLedger(raw.purchases.ledger)
	local rites = flagMap(raw.purchases.ritesOwned)
	local quotes = parseQuotes(raw.purchases.quotes)
	if ledger == nil or rites == nil or quotes == nil then
		return false
	end
	if type(raw.purchases.starterPackClaimed) ~= "boolean" then
		return false
	end
	local firstAt = raw.purchases.firstPurchaseAt
	if firstAt ~= nil and (not Money.isFinite(firstAt) or firstAt < 0) then
		return false
	end
	local owned = flagMap(raw.cosmetics.owned)
	local gifts = flagMap(raw.giftsReceived)
	local gifted = parseGifted(raw.giftedPasses)
	if owned == nil or gifts == nil or gifted == nil then
		return false
	end
	local tokens = parsePair(raw.tarot.tokens)
	local pity = parsePair(raw.tarot.pity)
	local marks = parseMarks(raw.tarot.marks)
	local milestones = flagMap(raw.tarot.milestonesClaimed)
	if tokens == nil or pity == nil or marks == nil or milestones == nil then
		return false
	end
	if type(raw.bloodMoon.boughtToday) ~= "table" then
		return false
	end
	local utcDay = whole(raw.bloodMoon.boughtToday.utcDay, 1e12)
	local count = whole(raw.bloodMoon.boughtToday.count, 1e6)
	if utcDay == nil or count == nil then
		return false
	end
	if type(raw.ui.relicsPipShown) ~= "boolean" or type(raw.ui.relicsPipCleared) ~= "boolean" then
		return false
	end
	if type(raw.cashDouble) ~= "boolean" or type(raw.autoCollect) ~= "boolean" then
		return false
	end
	if
		type(raw.passes.extraPads) ~= "boolean"
		or type(raw.passes.lairCosmetics) ~= "boolean"
		or type(raw.passes.sigilNameplate) ~= "boolean"
	then
		return false
	end
	local purchases = {
		ledger = ledger,
		ritesOwned = rites,
		quotes = quotes,
		starterPackClaimed = raw.purchases.starterPackClaimed,
	}
	if firstAt ~= nil then
		purchases.firstPurchaseAt = math.floor(firstAt)
	end
	profile.purchases = purchases
	profile.cosmetics = {
		owned = owned,
	}
	profile.giftedPasses = gifted
	profile.giftsReceived = gifts
	profile.tarot = {
		tokens = tokens,
		pity = pity,
		marks = marks,
		milestonesClaimed = milestones,
	}
	profile.bloodMoon = {
		boughtToday = {
			utcDay = utcDay,
			count = count,
		},
	}
	profile.ui = {
		relicsPipShown = raw.ui.relicsPipShown,
		relicsPipCleared = raw.ui.relicsPipCleared,
	}
	profile.cashDouble = raw.cashDouble
	profile.autoCollect = raw.autoCollect
	profile.passes = {
		extraPads = raw.passes.extraPads,
		lairCosmetics = raw.passes.lairCosmetics,
		sigilNameplate = raw.passes.sigilNameplate,
	}
	return true
end

return MonetisationProfile
