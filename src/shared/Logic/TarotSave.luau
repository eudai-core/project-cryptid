--!strict

-- Additive tarot fields: case inventory, per-family pity, and the purchase ledger.
-- One fill, used by the v10 migration and by a new profile. Missing fields become
-- empty defaults. A present, corrupt field rejects the save. Idempotent.

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
local TarotCases = import("../Config/TarotCases", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("TarotCases")
end)

local TarotSave = {}

local function caseKey(key: any): boolean
	if type(key) ~= "string" or #key < 1 or #key > Monetisation.KEY_MAX then
		return false
	end
	return string.match(key, "^[%w_]+$") ~= nil
end

local function purchaseKey(key: any): boolean
	if type(key) ~= "string" or #key < 1 or #key > Monetisation.KEY_MAX then
		return false
	end
	return string.match(key, "^[%w_%-]+$") ~= nil
end

local function whole(value: any, maximum: number): number?
	if type(value) ~= "number" or value ~= math.floor(value) or value < 0 or value > maximum then
		return nil
	end
	return value
end

local function sourceOf(raw: any): any?
	if type(raw) ~= "table" or type(raw.tarot) ~= "table" then
		return nil
	end
	return raw.tarot
end

local function readCases(source: any): (any?, boolean)
	if source == nil or source.cases == nil then
		return {}, true
	end
	if type(source.cases) ~= "table" then
		return nil, false
	end
	local cases = {}
	for key, value in source.cases do
		if not caseKey(key) then
			return nil, false
		end
		if value ~= 0 then
			local count = whole(value, TarotCases.CASE_CAP)
			if count == nil or count < 1 then
				return nil, false
			end
			cases[key] = count
		end
	end
	return cases, true
end

local function readPity(profile: any, source: any): (any?, boolean)
	local pity = {}
	local deck = profile.tarot.pity
	if source == nil or source.familyPity == nil then
		if type(deck) == "table" then
			pity.pale = deck.pale or 0
			pity.blood = deck.blood or 0
		end
		return pity, true
	end
	if type(source.familyPity) ~= "table" then
		return nil, false
	end
	for key, value in source.familyPity do
		if not caseKey(key) then
			return nil, false
		end
		local count = whole(value, TarotCases.PITY_CAP)
		if count == nil then
			return nil, false
		end
		pity[key] = count
	end
	if pity.pale == nil and type(deck) == "table" and type(deck.pale) == "number" then
		pity.pale = deck.pale
	end
	if pity.blood == nil and type(deck) == "table" and type(deck.blood) == "number" then
		pity.blood = deck.blood
	end
	return pity, true
end

local function readGrants(raw: any): { string }?
	if type(raw) ~= "table" then
		return nil
	end
	local grants = {}
	for index = 1, #raw do
		local grant = raw[index]
		if type(grant) ~= "string" or #grant < 1 or #grant > TarotCases.LINE_MAX then
			return nil
		end
		table.insert(grants, grant)
		if #grants > TarotCases.GRANT_MAX then
			return nil
		end
	end
	return grants
end

local function readLedger(source: any): (any?, boolean)
	if source == nil or source.ledger == nil then
		return {}, true
	end
	if type(source.ledger) ~= "table" then
		return nil, false
	end
	local ledger = {}
	for key, entry in source.ledger do
		if not purchaseKey(key) or type(entry) ~= "table" then
			return nil, false
		end
		local productId = entry.productId
		local grantedAt = entry.grantedAt
		local caseId = entry.caseId
		if type(productId) ~= "number" or productId ~= math.floor(productId) or productId <= 0 then
			return nil, false
		end
		if type(grantedAt) ~= "number" or grantedAt ~= grantedAt or grantedAt < 0 or grantedAt == math.huge then
			return nil, false
		end
		if not caseKey(caseId) then
			return nil, false
		end
		local grants = readGrants(entry.grants)
		if grants == nil then
			return nil, false
		end
		ledger[key] = {
			productId = productId,
			grantedAt = math.floor(grantedAt),
			caseId = caseId,
			grants = grants,
		}
	end
	return ledger, true
end

local function readRequests(source: any): (any?, boolean)
	if source == nil or source.requests == nil then
		return {}, true
	end
	if type(source.requests) ~= "table" then
		return nil, false
	end
	local requests = {}
	local seen: { [string]: boolean } = {}
	local startIndex = 1
	if #source.requests > TarotCases.REQUEST_CAP then
		startIndex = #source.requests - TarotCases.REQUEST_CAP + 1
	end
	for index = startIndex, #source.requests do
		local entry = source.requests[index]
		if type(entry) == "table" then
			local id = entry.id
			local caseId = entry.caseId
			local line = entry.line
			local rarity = entry.rarity
			local rewardId = entry.rewardId
			local cash = entry.cash
			if
				purchaseKey(id)
				and seen[id] ~= true
				and caseKey(caseId)
				and type(line) == "string"
				and #line > 0
				and #line <= TarotCases.LINE_MAX
				and type(rarity) == "string"
				and caseKey(rewardId)
				and type(cash) == "number"
				and cash == math.floor(cash)
				and cash >= 0
			then
				seen[id] = true
				table.insert(requests, {
					id = id,
					caseId = caseId,
					line = line,
					rarity = rarity,
					rewardId = rewardId,
					cash = cash,
				})
			end
		end
	end
	return requests, true
end

local function readKnown(source: any): (any?, boolean)
	if source == nil or source.known == nil then
		return {}, true
	end
	if type(source.known) ~= "table" then
		return nil, false
	end
	local known = {}
	for key, value in source.known do
		if not caseKey(key) or value ~= true then
			return nil, false
		end
		known[key] = true
	end
	return known, true
end

local function readNonce(source: any): (number?, boolean)
	if source == nil or source.nonce == nil then
		return 0, true
	end
	local nonce = whole(source.nonce, TarotCases.NONCE_CAP)
	if nonce == nil then
		return nil, false
	end
	return nonce, true
end

function TarotSave.apply(profile: any, raw: any): boolean
	if type(profile) ~= "table" or type(profile.tarot) ~= "table" then
		return false
	end
	local source = sourceOf(raw)
	local cases, casesOk = readCases(source)
	local pity, pityOk = readPity(profile, source)
	local ledger, ledgerOk = readLedger(source)
	local requests, requestsOk = readRequests(source)
	local known, knownOk = readKnown(source)
	local nonce, nonceOk = readNonce(source)
	if
		casesOk ~= true
		or pityOk ~= true
		or ledgerOk ~= true
		or requestsOk ~= true
		or knownOk ~= true
		or nonceOk ~= true
	then
		return false
	end
	profile.tarot.cases = cases
	profile.tarot.familyPity = pity
	profile.tarot.ledger = ledger
	profile.tarot.requests = requests
	profile.tarot.known = known
	profile.tarot.nonce = nonce
	if type(profile.tarot.pity) == "table" then
		if type(pity.pale) == "number" then
			profile.tarot.pity.pale = pity.pale
		end
		if type(pity.blood) == "number" then
			profile.tarot.pity.blood = pity.blood
		end
	end
	return true
end

return TarotSave
