--!strict

-- Names, steps, SKUs, and field values for the v1.1 event spec.
-- The server module is the only place that sends them.

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Economy = import("./Economy", function()
	return script.Parent:WaitForChild("Economy")
end)
local Return = import("./Return", function()
	return script.Parent:WaitForChild("Return")
end)
local Shop = import("./Shop", function()
	return script.Parent:WaitForChild("Shop")
end)
local Species = import("./Species", function()
	return script.Parent:WaitForChild("Species")
end)

local FUNNEL = table.freeze({
	[1] = "Joined",
	[2] = "Starter Earning",
	[3] = "Claimed Rift Cryptid 1",
	[4] = "Caught Hodag",
	[5] = "Bound Hodag on Pad 3",
	[6] = "Raised Bone Altar I",
	[7] = "Carved Pad 4",
	[8] = "Claimed Rift Cryptid 2",
	[9] = "Rite Complete",
})

local PEDLAR_STEPS = table.freeze({
	[1] = "Opened",
	[2] = "Buy Pressed",
	[3] = "Bought",
})

local CUSTOM_ORDER = table.freeze({
	"OnboardingSkipped",
	"OnboardingStepTime",
	"SessionEnded",
	"PlayerReturned",
	"LedgerLoadFailed",
	"PedlarOddsViewed",
	"CatchCompleted",
	"PlotAssigned",
})

local CUSTOM_SET: { [string]: boolean } = {}
local CUSTOM: { [string]: string } = {}
for _, name in CUSTOM_ORDER do
	CUSTOM_SET[name] = true
	CUSTOM[name] = name
end

local PAD_SKU = table.freeze({
	[3] = "Pad_3",
	[4] = "Pad_4",
	[5] = "Pad_5",
	[6] = "Pad_6",
})

local ALTAR_SKU = table.freeze({
	[1] = "BoneAltar_1",
	[2] = "BoneAltar_2",
})

local PEDLAR_SKU: { [string]: string } = {}
for _, rarity in Shop.RARITY_ORDER do
	PEDLAR_SKU[rarity] = "Pedlar_" .. rarity
end

local SKU = table.freeze({
	StarterCash = "StarterCash",
	PadIncome = "PadIncome",
	Rift = "Rift_Common",
})

local SKU_SET: { [string]: boolean } = {
	[SKU.StarterCash] = true,
	[SKU.PadIncome] = true,
	[SKU.Rift] = true,
}
for _, sku in PAD_SKU do
	SKU_SET[sku] = true
end
for _, sku in ALTAR_SKU do
	SKU_SET[sku] = true
end
for _, sku in PEDLAR_SKU do
	SKU_SET[sku] = true
end

local KIND = table.freeze({
	Custom = "custom",
	Onboarding = "onboarding",
	Funnel = "funnel",
	Economy = "economy",
})

local FLOW = table.freeze({
	Source = "Source",
	Sink = "Sink",
})

local TX = table.freeze({
	Onboarding = "Onboarding",
	Gameplay = "Gameplay",
	Shop = "Shop",
	IAP = "IAP",
})

local FIELD_KEY = table.freeze({
	One = "CustomField01",
	Two = "CustomField02",
	Three = "CustomField03",
})

local ONBOARDING_FUNNEL = "Onboarding"
local PEDLAR_FUNNEL = "PedlarShop"
local CURRENCY = "Cash"

local allowedValue: { [string]: boolean } = {}

local function allow(value: string)
	allowedValue[value] = true
end

allow("Onboarded - Yes")
allow("Onboarded - No")
allow("Tenure - New")
allow("Tenure - Returning")
allow("PlaySec - 0-30")
allow("PlaySec - 31-60")
allow("PlaySec - 61-120")
allow("PlaySec - 121-180")
allow("PlaySec - 180+")
allow("Day - 0")
allow("Day - 1")
allow("Day - 2-6")
allow("Day - 7")
allow("Day - 7-29")
allow("Day - 8-29")
allow("Day - 30+")
allow("Tutorial - Yes")
allow("Tutorial - No")
allow("Reason - ReadFailed")
allow("Reason - Locked")
allow("Reason - Corrupt")
allow("Rule - Reserved")
allow("Rule - Friend")
allow("Rule - Lowest")

for step = 2, 9 do
	allow("Step - " .. tostring(step))
end
for slot = 1, Shop.SLOT_COUNT do
	allow("Slot - " .. tostring(slot))
end
for _, rarity in Shop.RARITY_ORDER do
	allow("Rarity - " .. rarity)
end
for _, id in Species.ids() do
	allow("Species - " .. id)
end

local RECORD_KEYS = table.freeze({
	kind = true,
	name = true,
	value = true,
	step = true,
	stepName = true,
	funnel = true,
	funnelSessionId = true,
	flow = true,
	currency = true,
	amount = true,
	balance = true,
	transactionType = true,
	sku = true,
	fields = true,
})

local Analytics = {
	FUNNEL = FUNNEL,
	PEDLAR_STEPS = PEDLAR_STEPS,
	CUSTOM = CUSTOM,
	CUSTOM_ORDER = CUSTOM_ORDER,
	SKU = SKU,
	KIND = KIND,
	FLOW = FLOW,
	TX = TX,
	FIELD_KEY = FIELD_KEY,
	ONBOARDING_FUNNEL = ONBOARDING_FUNNEL,
	PEDLAR_FUNNEL = PEDLAR_FUNNEL,
	CURRENCY = CURRENCY,
	CATCH_STEP = 4,
	CATCH_EVENT = CUSTOM.CatchCompleted,
	RITE_STEP = 9,
	GOAL_COUNT = 8,
	RATE_PER_MINUTE = 6,
	RATE_WINDOW_SECONDS = 60,
	MAX_FIELDS = 3,
	MAX_CUSTOM_NAMES = 15,
	MAX_RETURN_DAY = 10000000,
	STARTING_CASH = Economy.STARTING_CASH,
}

function Analytics.utcDay(unix: number): number
	if type(unix) ~= "number" or unix ~= unix or unix < 0 or unix == math.huge then
		return 0
	end
	return math.floor(unix / Return.DAY_SECONDS)
end

function Analytics.playBucket(seconds: number): string
	local whole = seconds
	if type(whole) ~= "number" or whole ~= whole or whole < 0 or whole == math.huge then
		whole = 0
	end
	whole = math.floor(whole)
	if whole <= 30 then
		return "PlaySec - 0-30"
	elseif whole <= 60 then
		return "PlaySec - 31-60"
	elseif whole <= 120 then
		return "PlaySec - 61-120"
	elseif whole <= 180 then
		return "PlaySec - 121-180"
	end
	return "PlaySec - 180+"
end

function Analytics.sessionDay(days: number): string
	if type(days) ~= "number" or days ~= days or days <= 0 then
		return "Day - 0"
	elseif days == 1 then
		return "Day - 1"
	elseif days <= 6 then
		return "Day - 2-6"
	elseif days <= 29 then
		return "Day - 7-29"
	end
	return "Day - 30+"
end

function Analytics.returnDay(days: number): string?
	if type(days) ~= "number" or days ~= days then
		return nil
	elseif days == 1 then
		return "Day - 1"
	elseif days >= 2 and days <= 6 then
		return "Day - 2-6"
	elseif days == 7 then
		return "Day - 7"
	elseif days >= 8 and days <= 29 then
		return "Day - 8-29"
	elseif days >= 30 then
		return "Day - 30+"
	end
	return nil
end

function Analytics.tenure(days: number): string
	if type(days) == "number" and days >= 1 then
		return "Tenure - Returning"
	end
	return "Tenure - New"
end

function Analytics.onboarded(profile: any): string
	local state = if type(profile) == "table" then profile.onboarding else nil
	local step = if type(state) == "table" then state.step else nil
	local skipped = if type(state) == "table" then state.skipped else nil
	if type(step) == "number" and step >= 8 and skipped ~= true then
		return "Onboarded - Yes"
	end
	return "Onboarded - No"
end

function Analytics.stepField(step: number): string?
	if type(step) ~= "number" or step < 2 or step > 9 or step ~= math.floor(step) then
		return nil
	end
	return "Step - " .. tostring(step)
end

function Analytics.slotField(slot: number): string?
	if type(slot) ~= "number" or slot ~= math.floor(slot) or slot < 1 or slot > Shop.SLOT_COUNT then
		return nil
	end
	return "Slot - " .. tostring(slot)
end

function Analytics.speciesField(id: string): string?
	if type(id) ~= "string" or Species.get(id) == nil then
		return nil
	end
	return "Species - " .. id
end

function Analytics.rarityField(rarity: string): string?
	if type(rarity) ~= "string" or PEDLAR_SKU[rarity] == nil then
		return nil
	end
	return "Rarity - " .. rarity
end

function Analytics.tutorialField(tutorial: boolean): string
	if tutorial == true then
		return "Tutorial - Yes"
	end
	return "Tutorial - No"
end

function Analytics.reasonField(code: string): string?
	if code == "read" then
		return "Reason - ReadFailed"
	elseif code == "locked" then
		return "Reason - Locked"
	elseif code == "corrupt" then
		return "Reason - Corrupt"
	end
	return nil
end

function Analytics.ruleField(code: string): string?
	if code == "reserved" then
		return "Rule - Reserved"
	elseif code == "friend" then
		return "Rule - Friend"
	elseif code == "lowest" then
		return "Rule - Lowest"
	end
	return nil
end

function Analytics.padSku(index: number): string?
	if type(index) ~= "number" then
		return nil
	end
	return PAD_SKU[index]
end

function Analytics.altarSku(level: number): string?
	if type(level) ~= "number" then
		return nil
	end
	return ALTAR_SKU[level]
end

function Analytics.pedlarSku(rarity: string): string?
	if type(rarity) ~= "string" then
		return nil
	end
	return PEDLAR_SKU[rarity]
end

function Analytics.fields(first: string?, second: string?, third: string?): { [string]: string }?
	local out: { [string]: string } = {}
	local function put(key: string, value: string?): boolean
		if value == nil then
			return true
		end
		if allowedValue[value] ~= true then
			return false
		end
		out[key] = value
		return true
	end
	if not put(FIELD_KEY.One, first) or not put(FIELD_KEY.Two, second) or not put(FIELD_KEY.Three, third) then
		return nil
	end
	return out
end

function Analytics.skuList(): { string }
	local list = {}
	for sku in SKU_SET do
		table.insert(list, sku)
	end
	table.sort(list)
	return list
end

local function fieldsOk(fields: any): boolean
	if fields == nil then
		return true
	end
	if type(fields) ~= "table" then
		return false
	end
	local count = 0
	for key, value in fields do
		if key ~= FIELD_KEY.One and key ~= FIELD_KEY.Two and key ~= FIELD_KEY.Three then
			return false
		end
		if type(value) ~= "string" or allowedValue[value] ~= true then
			return false
		end
		count += 1
	end
	return count <= Analytics.MAX_FIELDS
end

local function finite(value: any, allowZero: boolean): boolean
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return false
	end
	if allowZero then
		return value >= 0
	end
	return value > 0
end

function Analytics.vet(record: any): boolean
	if type(record) ~= "table" then
		return false
	end
	for key in record do
		if RECORD_KEYS[key] ~= true then
			return false
		end
	end
	if fieldsOk(record.fields) ~= true then
		return false
	end
	if record.kind == KIND.Custom then
		if CUSTOM_SET[record.name] ~= true or finite(record.value, true) ~= true then
			return false
		end
		return true
	elseif record.kind == KIND.Onboarding then
		local step = record.step
		if record.name ~= ONBOARDING_FUNNEL or type(step) ~= "number" or FUNNEL[step] == nil then
			return false
		end
		return record.stepName == FUNNEL[step]
	elseif record.kind == KIND.Funnel then
		local step = record.step
		local id = record.funnelSessionId
		if record.name ~= PEDLAR_FUNNEL or record.funnel ~= PEDLAR_FUNNEL then
			return false
		end
		if type(step) ~= "number" or PEDLAR_STEPS[step] == nil or record.stepName ~= PEDLAR_STEPS[step] then
			return false
		end
		if type(id) ~= "string" or #id < 1 or #id > 64 or string.match(id, "^[%w%-]+$") == nil then
			return false
		end
		return true
	elseif record.kind == KIND.Economy then
		if record.currency ~= CURRENCY or record.name ~= record.sku then
			return false
		end
		if record.flow ~= FLOW.Source and record.flow ~= FLOW.Sink then
			return false
		end
		if
			record.transactionType ~= TX.Onboarding
			and record.transactionType ~= TX.Gameplay
			and record.transactionType ~= TX.Shop
			and record.transactionType ~= TX.IAP
		then
			return false
		end
		if SKU_SET[record.sku] ~= true then
			return false
		end
		return finite(record.amount, false) == true and finite(record.balance, true) == true
	end
	return false
end

function Analytics.encode(record: any): string
	local parts = {}
	local function add(key: string, value: any)
		if value == nil then
			return
		end
		table.insert(parts, key .. "=" .. tostring(value))
	end
	if type(record) ~= "table" then
		return ""
	end
	add("kind", record.kind)
	add("name", record.name)
	add("value", record.value)
	add("step", record.step)
	add("stepName", record.stepName)
	add("funnel", record.funnel)
	add("funnelSessionId", record.funnelSessionId)
	add("flow", record.flow)
	add("currency", record.currency)
	add("amount", record.amount)
	add("balance", record.balance)
	add("transactionType", record.transactionType)
	add("sku", record.sku)
	local fields = record.fields
	if type(fields) == "table" then
		add(FIELD_KEY.One, fields[FIELD_KEY.One])
		add(FIELD_KEY.Two, fields[FIELD_KEY.Two])
		add(FIELD_KEY.Three, fields[FIELD_KEY.Three])
	end
	return table.concat(parts, " ")
end

function Analytics.funnelStep(goal: number): number
	return goal + 1
end

function Analytics.nameFor(step: number): string?
	return FUNNEL[step]
end

function Analytics.joinEvent(): { step: number, stepName: string, catch: boolean, eventName: string? }
	return {
		step = 1,
		stepName = FUNNEL[1],
		catch = false,
		eventName = nil,
	}
end

function Analytics.eventsForTransition(
	fromStep: number,
	toStep: number,
	skipped: boolean
): { { step: number, stepName: string, catch: boolean, eventName: string? } }
	if skipped == true then
		return {}
	end
	local events = {}
	local landed = toStep
	if landed > Analytics.GOAL_COUNT then
		landed = Analytics.GOAL_COUNT
	end
	local goal = fromStep
	if goal < 1 then
		goal = 1
	end
	while goal < landed do
		local step = Analytics.funnelStep(goal)
		local name = FUNNEL[step]
		if name ~= nil then
			local caught = step == Analytics.CATCH_STEP
			table.insert(events, {
				step = step,
				stepName = name,
				catch = caught,
				eventName = if caught then Analytics.CATCH_EVENT else nil,
			})
		end
		goal += 1
	end
	if toStep >= Analytics.GOAL_COUNT and fromStep < Analytics.GOAL_COUNT then
		table.insert(events, {
			step = Analytics.RITE_STEP,
			stepName = FUNNEL[Analytics.RITE_STEP],
			catch = false,
			eventName = nil,
		})
	end
	return events
end

return Analytics
