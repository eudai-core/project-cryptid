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
local Bundles = import("./Bundles", function()
	return script.Parent:WaitForChild("Bundles")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local MonetisationProfile = import("./MonetisationProfile", function()
	return script.Parent:WaitForChild("MonetisationProfile")
end)
local RelicGrants = import("./RelicGrants", function()
	return script.Parent:WaitForChild("RelicGrants")
end)
local Schema = import("./Schema", function()
	return script.Parent:WaitForChild("Schema")
end)

local Receipts = {}

Receipts.NOT_PROCESSED = "NotProcessedYet"
Receipts.GRANTED = "PurchaseGranted"

local function purchaseKey(receipt: any): string?
	local id = receipt.PurchaseId
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

local function restore(profile: any, snapshot: any)
	for key in profile do
		profile[key] = nil
	end
	for key, value in snapshot do
		profile[key] = value
	end
end

function Receipts.process(
	receipt: any,
	profile: any,
	deps: any
): { decision: string, cash: number, fresh: boolean, spent: number }
	local held = {
		decision = Receipts.NOT_PROCESSED,
		cash = 0,
		fresh = false,
		spent = 0,
	}
	if type(deps) ~= "table" or deps.loaded ~= true or type(profile) ~= "table" then
		return held
	end
	if type(profile.purchases) ~= "table" or type(profile.purchases.ledger) ~= "table" then
		return held
	end
	local purchaseId = if type(receipt) == "table" then purchaseKey(receipt) else nil
	if purchaseId == nil then
		return held
	end
	if profile.purchases.ledger[purchaseId] ~= nil then
		held.decision = Receipts.GRANTED
		return held
	end
	local productId = receipt.ProductId
	local lookup = deps.lookup
	if type(lookup) ~= "function" then
		return held
	end
	local item = lookup(productId)
	if type(item) ~= "table" or item.kind ~= "bundle" or Monetisation.isLive(item) ~= true then
		return held
	end
	if
		item.catalogPrice ~= nil
		and type(receipt.CurrencySpent) == "number"
		and receipt.CurrencySpent ~= item.catalogPrice
	then
		if type(deps.log) == "function" then
			deps.log("catalog price differs from CurrencySpent")
		end
	end
	local now = deps.now
	if type(now) ~= "function" then
		return held
	end
	local clock = now()
	if not Money.isFinite(clock) or clock < 0 then
		return held
	end
	local rateOf = deps.rate
	if type(rateOf) ~= "function" then
		return held
	end
	local rate = rateOf(profile)
	if not Money.isFinite(rate) or rate < 0 then
		rate = 0
	end
	local save = deps.save
	if type(save) ~= "function" then
		return held
	end
	local snapshot = Schema.deepCopy(profile)
	local amount = Bundles.grantAmount(profile, item.key, clock, rate)
	local grants = { "cash:" .. tostring(amount) }
	profile.cash = Money.round(profile.cash + amount)
	RelicGrants.noteFirst(profile, clock, grants)
	profile.purchases.ledger[purchaseId] = {
		productId = productId,
		grantedAt = clock,
		grants = grants,
	}
	MonetisationProfile.pruneLedger(profile.purchases.ledger)
	local savedOk, saved = pcall(save)
	if savedOk ~= true or saved ~= true then
		restore(profile, snapshot)
		return held
	end
	local spent = 0
	if
		type(receipt.CurrencySpent) == "number"
		and receipt.CurrencySpent > 0
		and receipt.CurrencySpent == receipt.CurrencySpent
	then
		spent = receipt.CurrencySpent
	end
	return {
		decision = Receipts.GRANTED,
		cash = amount,
		fresh = true,
		spent = spent,
	}
end

return Receipts
