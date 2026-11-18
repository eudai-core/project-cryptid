--!strict

-- Tarot developer products share the receipt handler. A PurchaseId is written
-- before PurchaseGranted. A failed save rolls the grant back and returns
-- NotProcessedYet. Unknown product ids are not tarot receipts.

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
local MonetisationProfile = import("./MonetisationProfile", function()
	return script.Parent:WaitForChild("MonetisationProfile")
end)
local Schema = import("./Schema", function()
	return script.Parent:WaitForChild("Schema")
end)
local TarotSave = import("./TarotSave", function()
	return script.Parent:WaitForChild("TarotSave")
end)

local TarotReceipts = {}

TarotReceipts.NOT_PROCESSED = "NotProcessedYet"
TarotReceipts.GRANTED = "PurchaseGranted"

local function purchaseKey(id: any): string?
	if type(id) == "number" and id == math.floor(id) and id >= 0 then
		id = tostring(id)
	end
	if type(id) ~= "string" or #id < 1 or #id > Monetisation.KEY_MAX then
		return nil
	end
	if string.match(id, "^[%w_%-]+$") == nil then
		return nil
	end
	return id
end

local function held(decision: string, fresh: boolean): any
	return {
		decision = decision,
		cash = 0,
		fresh = fresh,
		spent = 0,
		tarot = true,
	}
end

local function restore(profile: any, snapshot: any)
	for key in profile do
		profile[key] = nil
	end
	for key, value in snapshot do
		profile[key] = value
	end
end

function TarotReceipts.process(receipt: any, profile: any, deps: any): any?
	if type(receipt) ~= "table" or type(profile) ~= "table" or type(deps) ~= "table" then
		return nil
	end
	local findCase = deps.findCase
	if type(findCase) ~= "function" then
		return nil
	end
	local case = findCase(receipt.ProductId)
	if case == nil then
		return nil
	end
	local purchaseId = purchaseKey(receipt.PurchaseId)
	if purchaseId == nil or TarotSave.apply(profile, profile) ~= true then
		return held(TarotReceipts.NOT_PROCESSED, false)
	end
	if profile.tarot.ledger[purchaseId] ~= nil then
		return held(TarotReceipts.GRANTED, false)
	end
	local productId = case.productId
	if
		deps.paidEnabled ~= true
		or type(productId) ~= "number"
		or productId ~= receipt.ProductId
		or productId <= 0
		or productId ~= math.floor(productId)
	then
		return held(TarotReceipts.NOT_PROCESSED, false)
	end
	local allows = deps.policyAllows
	if allows == nil and type(deps.policy) == "function" then
		local ok, result = pcall(deps.policy)
		allows = ok and result == true
	end
	if allows ~= true then
		return held(TarotReceipts.NOT_PROCESSED, false)
	end
	local now = deps.now
	if type(now) == "function" then
		now = now()
	end
	if type(now) ~= "number" or now ~= now or now < 0 or now == math.huge then
		return held(TarotReceipts.NOT_PROCESSED, false)
	end
	local save = deps.save
	if type(save) ~= "function" then
		return held(TarotReceipts.NOT_PROCESSED, false)
	end
	local count = profile.tarot.cases[case.id]
	if type(count) ~= "number" then
		count = 0
	end
	if count >= TarotCases.CASE_CAP then
		return held(TarotReceipts.NOT_PROCESSED, false)
	end
	local snapshot = Schema.deepCopy(profile)
	profile.tarot.cases[case.id] = count + 1
	profile.tarot.ledger[purchaseId] = {
		productId = productId,
		grantedAt = math.floor(now),
		caseId = case.id,
		grants = { "case:" .. case.id },
	}
	MonetisationProfile.pruneLedger(profile.tarot.ledger)
	local savedOk, saved = pcall(save)
	if savedOk ~= true or saved ~= true then
		restore(profile, snapshot)
		return held(TarotReceipts.NOT_PROCESSED, false)
	end
	local spent = 0
	if
		type(receipt.CurrencySpent) == "number"
		and receipt.CurrencySpent > 0
		and receipt.CurrencySpent == receipt.CurrencySpent
	then
		spent = receipt.CurrencySpent
	end
	local granted = held(TarotReceipts.GRANTED, true)
	granted.spent = spent
	return granted
end

return TarotReceipts
