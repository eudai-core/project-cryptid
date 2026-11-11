--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Analytics = import("../Config/Analytics", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Analytics")
end)
local BoneAltar = import("../Config/BoneAltar", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("BoneAltar")
end)
local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
end)
local Monetisation = import("../Config/Monetisation", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Monetisation")
end)
local Onboarding = import("../Config/Onboarding", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Onboarding")
end)
local Shop = import("../Config/Shop", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Shop")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local ProfileQuery = import("./ProfileQuery", function()
	return script.Parent:WaitForChild("ProfileQuery")
end)
local ShopLedger = import("./ShopLedger", function()
	return script.Parent:WaitForChild("ShopLedger")
end)
local ShopStock = import("./ShopStock", function()
	return script.Parent:WaitForChild("ShopStock")
end)
local RemoteArgs = import("./RemoteArgs", function()
	return script.Parent:WaitForChild("RemoteArgs")
end)
local SkillEffects = import("./SkillEffects", function()
	return script.Parent:WaitForChild("SkillEffects")
end)
local SkillTree = import("./SkillTree", function()
	return script.Parent:WaitForChild("SkillTree")
end)
local Town = import("../Config/Town", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Town")
end)
local OnboardingGoals = import("./OnboardingGoals", function()
	return script.Parent:WaitForChild("OnboardingGoals")
end)
local Bowl = import("./Bowl", function()
	return script.Parent:WaitForChild("Bowl")
end)
local Ownership = import("./Ownership", function()
	return script.Parent:WaitForChild("Ownership")
end)
local Passes = import("./Passes", function()
	return script.Parent:WaitForChild("Passes")
end)
local Rebirth = import("./Rebirth", function()
	return script.Parent:WaitForChild("Rebirth")
end)
local RelicsPip = import("./RelicsPip", function()
	return script.Parent:WaitForChild("RelicsPip")
end)

local Transactions = {}

local function addCryptid(profile: any, instanceId: string, speciesId: string, source: string, now: number): boolean
	if profile.cryptids[instanceId] ~= nil then
		return false
	end
	profile.cryptids[instanceId] = {
		speciesId = speciesId,
		mutation = "",
		traits = {},
		acquiredAt = now,
		source = source,
	}
	RelicsPip.note(profile, speciesId)
	return true
end

local function clearPad(profile: any, instanceId: string)
	for index = 1, Economy.MAX_PADS do
		local key = tostring(index)
		if profile.pads[key] == instanceId then
			profile.pads[key] = nil
		end
	end
end

function Transactions.currentOffers(profile: any): { any }
	local offers = {}
	for _, guarantee in Species.GUARANTEES do
		if not ProfileQuery.ownsSpecies(profile, guarantee.speciesId) then
			local species = Species.get(guarantee.speciesId)
			table.insert(offers, {
				slot = guarantee.slot,
				speciesId = guarantee.speciesId,
				price = species.riftPrice,
				pad = guarantee.pad,
			})
			break
		end
	end
	return offers
end

local function offerForSlot(profile: any, slot: number): any?
	for _, offer in Transactions.currentOffers(profile) do
		if offer.slot == slot then
			return offer
		end
	end
	return nil
end

function Transactions.buyRift(profile: any, slot: number, now: number, newId: string): (boolean, string)
	local offer = offerForSlot(profile, slot)
	if offer == nil then
		return false, "offer"
	end
	if profile.cash + 1e-9 < offer.price then
		return false, "afford"
	end
	if not addCryptid(profile, newId, offer.speciesId, "rift", now) then
		return false, "id"
	end
	profile.cash = Money.round(profile.cash - offer.price)
	local padKey = tostring(offer.pad)
	if offer.pad <= profile.padsUnlocked and profile.pads[padKey] == nil then
		profile.pads[padKey] = newId
	end
	OnboardingGoals.advance(profile)
	return true, "ok"
end

function Transactions.unlockPad(profile: any, index: number): (boolean, string)
	if type(index) ~= "number" or index ~= math.floor(index) then
		return false, "type"
	end
	if index ~= profile.padsUnlocked + 1 or index > Economy.MAX_PADS then
		return false, "order"
	end
	if Monetisation.isRelicPad(index) then
		return false, "relic"
	end
	local cost = SkillEffects.padCost(profile, index)
	if type(cost) ~= "number" then
		return false, "range"
	end
	if profile.cash + 1e-9 < cost then
		return false, "afford"
	end
	profile.cash = Money.round(profile.cash - cost)
	profile.padsUnlocked = index
	if index == Onboarding.HODAG_PAD then
		local wildId = ProfileQuery.instanceOfSource(profile, "wild")
		if
			wildId ~= nil
			and ProfileQuery.padOfInstance(profile, wildId) == nil
			and profile.pads[tostring(index)] == nil
		then
			profile.pads[tostring(index)] = wildId
		end
	end
	Passes.openRelicPads(profile)
	OnboardingGoals.advance(profile)
	return true, "ok"
end

function Transactions.upgradeBoneAltar(profile: any): (boolean, string)
	local nextLevel = profile.upgrades.boneAltar + 1
	local cost = BoneAltar.cost(nextLevel, BoneAltar.rebirths(profile))
	if type(cost) ~= "number" then
		return false, "max"
	end
	if profile.cash + 1e-9 < cost then
		return false, "afford"
	end
	profile.cash = Money.round(profile.cash - cost)
	profile.upgrades.boneAltar = nextLevel
	OnboardingGoals.advance(profile)
	return true, "ok"
end

function Transactions.place(profile: any, instanceId: string, padIndex: number): (boolean, string)
	if type(instanceId) ~= "string" or #instanceId < 1 or #instanceId > 64 then
		return false, "type"
	end
	if type(padIndex) ~= "number" or padIndex ~= math.floor(padIndex) then
		return false, "type"
	end
	if padIndex < 1 or padIndex > profile.padsUnlocked then
		return false, "pad"
	end
	if profile.cryptids[instanceId] == nil then
		return false, "owner"
	end
	local key = tostring(padIndex)
	local occupant = profile.pads[key]
	if occupant ~= nil and occupant ~= instanceId then
		return false, "occupied"
	end
	clearPad(profile, instanceId)
	profile.pads[key] = instanceId
	OnboardingGoals.advance(profile)
	return true, "ok"
end

function Transactions.grantWild(profile: any, now: number, newId: string): (boolean, string)
	if profile.onboarding.step ~= Onboarding.CATCH_STEP then
		return false, "step"
	end
	if ProfileQuery.hasSource(profile, "wild") then
		return false, "already"
	end
	if not addCryptid(profile, newId, Species.WILD_ID, "wild", now) then
		return false, "id"
	end
	OnboardingGoals.advance(profile)
	return true, "ok"
end

function Transactions.skip(profile: any, now: number, makeId: () -> string): (boolean, string, { any })
	if profile.onboarding.step >= 8 then
		return false, "done", {}
	end
	local fromStep = profile.onboarding.step
	for _, guarantee in Species.GUARANTEES do
		if not ProfileQuery.ownsSpecies(profile, guarantee.speciesId) then
			local instanceId = makeId()
			if not addCryptid(profile, instanceId, guarantee.speciesId, "rift", now) then
				return false, "id", {}
			end
		end
	end
	if not ProfileQuery.ownsSpecies(profile, Species.WILD_ID) then
		local instanceId = makeId()
		if not addCryptid(profile, instanceId, Species.WILD_ID, "wild", now) then
			return false, "id", {}
		end
	end
	profile.onboarding.step = 8
	profile.onboarding.skipped = true
	return true, "ok", Analytics.eventsForTransition(fromStep, 8, true)
end

function Transactions.creditIncome(
	profile: any,
	seconds: number,
	inside: boolean?,
	autoCollect: boolean?
): (number, boolean)
	if seconds <= 0 then
		return 0, false
	end
	local tick = Ownership.cryptidTick(profile, seconds)
	if tick.tithe > 0 then
		profile.tithe = Money.round(profile.tithe + tick.tithe)
	end
	profile.onboarding.playSeconds += seconds
	OnboardingGoals.advance(profile)
	local gained, changed = Bowl.route(profile, tick.cash, inside == true, autoCollect == true)
	local noted = Rebirth.noteBalance(profile)
	return gained, changed or tick.tithe > 0 or noted
end

function Transactions.buySkill(profile: any, nodeId: any): (boolean, string)
	return SkillTree.buy(profile, nodeId)
end

function Transactions.canSell(profile: any): boolean
	return profile.onboarding.step >= 8
end

function Transactions.setReducedMotion(profile: any, enabled: boolean): boolean
	if type(enabled) ~= "boolean" then
		return false
	end
	profile.settings.reducedMotion = enabled
	return true
end

function Transactions.setBindAtOnce(profile: any, enabled: boolean): boolean
	if type(enabled) ~= "boolean" then
		return false
	end
	profile.settings.bindAtOnce = enabled
	return true
end

local function firstEmptyPad(profile: any): number?
	for index = 1, profile.padsUnlocked do
		if ProfileQuery.padAt(profile, index) == nil then
			return index
		end
	end
	return nil
end

function Transactions.grantOffering(profile: any, speciesId: string, now: number, newId: string): (boolean, string)
	if type(speciesId) ~= "string" or Species.get(speciesId) == nil then
		return false, "species"
	end
	if not addCryptid(profile, newId, speciesId, "offering", now) then
		return false, "id"
	end
	if profile.settings.bindAtOnce == true then
		local pad = firstEmptyPad(profile)
		if pad ~= nil then
			profile.pads[tostring(pad)] = newId
		end
	end
	return true, "ok"
end

function Transactions.buyPedlar(
	profile: any,
	rotationId: number,
	slot: number,
	offers: any,
	distance: number?,
	now: number,
	newId: string
): (boolean, string)
	if not RemoteArgs.withinDistance(distance, Town.BUY_DISTANCE) then
		return false, "range"
	end
	if profile.onboarding.step < Shop.GATE_STEP then
		return false, "onboarding"
	end
	if type(slot) ~= "number" or slot ~= math.floor(slot) or slot < 1 or slot > Shop.SLOT_COUNT then
		return false, "slot"
	end
	if type(rotationId) ~= "number" or rotationId ~= math.floor(rotationId) then
		return false, "rotation"
	end
	if type(offers) ~= "table" then
		return false, "slot"
	end
	local offer = offers[slot]
	if type(offer) ~= "table" or type(offer.speciesId) ~= "string" then
		return false, "slot"
	end
	local species = Species.get(offer.speciesId)
	if species == nil then
		return false, "species"
	end
	if ShopLedger.slotBought(profile.shop.lastRotationId, profile.shop.boughtSlots, rotationId, slot) then
		return false, "bought"
	end
	local price = ShopStock.priceFor(offer.speciesId)
	if profile.cash + 1e-9 < price then
		return false, "afford"
	end
	if not addCryptid(profile, newId, offer.speciesId, "pedlar", now) then
		return false, "id"
	end
	profile.cryptids[newId].mutation = ""
	profile.cash = Money.round(profile.cash - price)
	if profile.shop.lastRotationId ~= rotationId then
		profile.shop.boughtSlots = ShopLedger.freshSlots()
	end
	profile.shop.boughtSlots[slot] = true
	profile.shop.lastRotationId = rotationId
	if profile.settings.bindAtOnce == true then
		local pad = firstEmptyPad(profile)
		if pad ~= nil then
			profile.pads[tostring(pad)] = newId
		end
	end
	return true, "ok"
end

return Transactions
