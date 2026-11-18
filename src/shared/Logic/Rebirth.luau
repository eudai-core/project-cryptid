--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local BoneAltar = import("../Config/BoneAltar", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("BoneAltar")
end)
local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
end)
local Rules = import("../Config/Rebirth", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Rebirth")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local Bowl = import("./Bowl", function()
	return script.Parent:WaitForChild("Bowl")
end)
local Debounce = import("./Debounce", function()
	return script.Parent:WaitForChild("Debounce")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local NumberFormat = import("./NumberFormat", function()
	return script.Parent:WaitForChild("NumberFormat")
end)
local SkillEffects = import("./SkillEffects", function()
	return script.Parent:WaitForChild("SkillEffects")
end)

local Rebirth = {}

local function wholeTier(tier: any): number?
	if type(tier) ~= "number" or tier ~= math.floor(tier) or tier < 1 or tier > Rules.LAUNCH_CAP then
		return nil
	end
	return tier
end

function Rebirth.cost(tier: number): number?
	local index = wholeTier(tier)
	if index == nil then
		return nil
	end
	return Rules.BASE_COST * (Rules.COST_GROWTH ^ (index - 1))
end

function Rebirth.sum(tier: number): number?
	local index = wholeTier(tier)
	if index == nil then
		return nil
	end
	local total = 0
	for step = 1, index do
		total += Rebirth.cost(step) :: number
	end
	return total
end

function Rebirth.titheGate(tier: number): number?
	local index = wholeTier(tier)
	if index == nil then
		return nil
	end
	if index == 1 then
		return Rebirth.cost(1)
	end
	local total = Rebirth.sum(index)
	if total == nil then
		return nil
	end
	if index <= Rules.FULL_SUM_TIER then
		return total
	end
	local raw = Rules.TITHE_FRACTION * total
	return math.round(raw / Rules.TITHE_ROUND) * Rules.TITHE_ROUND
end

function Rebirth.multiplierFor(count: number): number
	local rebirths = count
	if type(rebirths) ~= "number" or rebirths ~= math.floor(rebirths) or rebirths < 0 then
		rebirths = 0
	end
	if rebirths > BoneAltar.MAX_REBIRTHS then
		rebirths = BoneAltar.MAX_REBIRTHS
	end
	return Rules.MULT_BASE + Rules.MULT_STEP * rebirths
end

function Rebirth.multiplier(profile: any): number
	return Rebirth.multiplierFor(BoneAltar.rebirths(profile))
end

function Rebirth.priceFactor(rebirths: number): number
	local count = rebirths
	if type(count) ~= "number" or count ~= math.floor(count) or count < 0 then
		count = 0
	end
	return Rules.PRICE_FACTOR ^ count
end

function Rebirth.priceFactorShown(rebirths: number): number
	local scale = 10 ^ Rules.PRICE_FACTOR_DECIMALS
	return math.round(Rebirth.priceFactor(rebirths) * scale) / scale
end

function Rebirth.multText(count: number): string
	return string.format("%.1f", Rebirth.multiplierFor(count))
end

local function cashOf(profile: any): number
	if type(profile) ~= "table" or not Money.isFinite(profile.cash) or profile.cash < 0 then
		return 0
	end
	return profile.cash
end

local function titheOf(profile: any): number
	if type(profile) ~= "table" or not Money.isFinite(profile.tithe) or profile.tithe < 0 then
		return 0
	end
	return profile.tithe
end

local function stepOf(profile: any): number
	if type(profile) ~= "table" or type(profile.onboarding) ~= "table" then
		return 0
	end
	local step = profile.onboarding.step
	if type(step) ~= "number" then
		return 0
	end
	return step
end

function Rebirth.countCryptids(profile: any): number
	if type(profile) ~= "table" or type(profile.cryptids) ~= "table" then
		return 0
	end
	local total = 0
	for _ in profile.cryptids do
		total += 1
	end
	return total
end

function Rebirth.refusal(profile: any): string?
	if type(profile) ~= "table" then
		return "type"
	end
	local count = BoneAltar.rebirths(profile)
	if count >= Rules.LAUNCH_CAP then
		return "sealed"
	end
	if stepOf(profile) < Rules.ONBOARDING_STEP then
		return "onboarding"
	end
	local tier = count + 1
	local gate = Rebirth.titheGate(tier)
	local cost = Rebirth.cost(tier)
	if gate == nil or cost == nil then
		return "sealed"
	end
	if titheOf(profile) + 1e-9 < gate then
		return "tithe"
	end
	if cashOf(profile) + 1e-9 < cost then
		return "cash"
	end
	return nil
end

function Rebirth.blockReason(profile: any): string
	local code = Rebirth.refusal(profile)
	if code == "sealed" then
		return Rules.SEALED
	end
	if code == "onboarding" then
		return Rules.UNFINISHED
	end
	local count = BoneAltar.rebirths(profile)
	local tier = count + 1
	if code == "tithe" then
		local gate = Rebirth.titheGate(tier) or 0
		return string.format(Rules.TITHE_LINE, NumberFormat.formatCash(titheOf(profile)), NumberFormat.formatCash(gate))
	end
	if code == "cash" then
		local cost = Rebirth.cost(tier) or 0
		local short = Money.round(cost - cashOf(profile))
		if short < 0 then
			short = 0
		end
		return string.format(Rules.GATHER, NumberFormat.formatCash(short))
	end
	return ""
end

function Rebirth.noteBalance(profile: any): boolean
	if type(profile) ~= "table" or profile.everHeld1M == true then
		return false
	end
	if cashOf(profile) + 1e-9 < Rules.REVEAL_CASH then
		return false
	end
	profile.everHeld1M = true
	return true
end

function Rebirth.prepareQa(profile: any): boolean
	if type(profile) ~= "table" or type(profile.onboarding) ~= "table" then
		return false
	end
	if stepOf(profile) < Rules.ONBOARDING_STEP then
		profile.onboarding.step = Rules.ONBOARDING_STEP
	end
	profile.everHeld1M = true
	local cost = Rebirth.cost(1) or 0
	if cashOf(profile) < cost then
		profile.cash = cost
	end
	local gate = Rebirth.titheGate(1) or 0
	if titheOf(profile) < gate then
		profile.tithe = gate
	end
	return true
end

function Rebirth.preview(profile: any, record: any, nextCount: number): number
	if type(record) ~= "table" then
		return 0
	end
	local species = Species.get(record.speciesId)
	if species == nil then
		return 0
	end
	local skill = SkillEffects.skillIncome(profile)
	if record.source == "wild" then
		skill += SkillEffects.wildIncome(profile)
	end
	return Money.round(species.baseIncome * (1 + skill) * Rebirth.multiplierFor(nextCount))
end

local function choices(profile: any, nextCount: number): { any }
	local list = {}
	if type(profile.cryptids) ~= "table" then
		return list
	end
	for instanceId, record in profile.cryptids do
		if type(instanceId) == "string" and type(record) == "table" then
			local species = Species.get(record.speciesId)
			local income = Rebirth.preview(profile, record, nextCount)
			table.insert(list, {
				instanceId = instanceId,
				speciesId = record.speciesId,
				displayName = if species ~= nil then species.displayName else record.speciesId,
				income = income,
				incomeText = NumberFormat.formatRate(income),
			})
		end
	end
	table.sort(list, function(a, b)
		return a.instanceId < b.instanceId
	end)
	return list
end

function Rebirth.toast(count: number): string
	return string.format(Rules.TOAST, Rebirth.multText(count))
end

function Rebirth.view(profile: any): any
	local count = BoneAltar.rebirths(profile)
	local sealed = count >= Rules.LAUNCH_CAP
	local tier = if sealed then nil else count + 1
	local cost = if tier ~= nil then Rebirth.cost(tier) else nil
	local gate = if tier ~= nil then Rebirth.titheGate(tier) else nil
	local nextCount = if sealed then count else count + 1
	local cash = cashOf(profile)
	local tithe = titheOf(profile)
	local other = 0
	if cost ~= nil then
		other = Money.round(cash - cost)
		if other < 0 then
			other = 0
		end
	end
	local ratio = 0
	if gate ~= nil and gate > 0 then
		ratio = tithe / gate
		if ratio < 0 then
			ratio = 0
		end
		if ratio > 1 then
			ratio = 1
		end
	end
	local body = Rules.SEALED
	if cost ~= nil then
		body = string.format(Rules.BODY, NumberFormat.formatCash(cost), Rebirth.multText(nextCount))
	end
	return {
		revealed = profile.everHeld1M == true,
		sealed = sealed,
		rebirths = count,
		canBegin = Rebirth.refusal(profile) == nil,
		blockReason = Rebirth.blockReason(profile),
		title = Rules.TITLE,
		body = body,
		keepTitle = Rules.KEEP_TITLE,
		keepBody = Rules.KEEP_BODY,
		loseTitle = Rules.LOSE_TITLE,
		loseBody = string.format(Rules.LOSE_BODY, NumberFormat.formatCash(other)),
		picker = Rules.PICKER,
		confirm = Rules.CONFIRM,
		second = Rules.SECOND,
		yes = Rules.YES,
		notYet = Rules.NOT_YET,
		sealedText = Rules.SEALED,
		cost = cost or 0,
		costText = if cost ~= nil then string.format(Rules.NEXT_COST, NumberFormat.formatCash(cost)) else "",
		multiplierText = string.format(Rules.MULTIPLIER_LINE, Rebirth.multText(nextCount)),
		tithe = tithe,
		titheGate = gate or 0,
		titheText = if gate ~= nil
			then string.format(Rules.TITHE_BAR, NumberFormat.formatCash(tithe), NumberFormat.formatCash(gate))
			else "",
		bar = ratio,
		choices = choices(profile, nextCount),
		needsFamiliar = Rebirth.countCryptids(profile) > 0,
	}
end

local function familiarOf(profile: any, familiarUid: any): (string?, any, string?)
	local total = Rebirth.countCryptids(profile)
	if total == 0 then
		if familiarUid == nil or familiarUid == "" then
			return nil, nil, nil
		end
		return nil, nil, "familiar"
	end
	if type(familiarUid) ~= "string" or familiarUid == "" then
		return nil, nil, "familiar"
	end
	local record = profile.cryptids[familiarUid]
	if type(record) ~= "table" then
		return nil, nil, "familiar"
	end
	return familiarUid, record, nil
end

function Rebirth.commit(profile: any, familiarUid: any): (boolean, string)
	local code = Rebirth.refusal(profile)
	if code ~= nil then
		return false, code
	end
	local keptId, kept, familiarReason = familiarOf(profile, familiarUid)
	if familiarReason ~= nil then
		return false, familiarReason
	end
	Bowl.bank(profile)
	local nextCryptids = {}
	if keptId ~= nil and kept ~= nil then
		nextCryptids[keptId] = kept
	end
	profile.cryptids = nextCryptids
	local pads = {}
	if keptId ~= nil then
		pads[tostring(Rules.KEPT_PAD)] = keptId
	end
	profile.pads = pads
	profile.padsUnlocked = Economy.STARTING_PADS_UNLOCKED
	profile.upgrades.boneAltar = 0
	profile.cash = Rules.CASH_AFTER
	profile.rebirths = BoneAltar.rebirths(profile) + 1
	profile.familiarId = if kept ~= nil then kept.speciesId else ""
	if profile.bowl ~= 0 then
		profile.bowl = 0
	end
	return true, "ok"
end

function Rebirth.attempt(profile: any, familiarUid: any, now: number, gate: any): (boolean, string)
	if type(gate) ~= "table" or type(now) ~= "number" then
		return false, "type"
	end
	local allowed, at = Debounce.allow(gate.at, now, Rules.DEBOUNCE_SECONDS)
	if not allowed then
		return false, "debounce"
	end
	gate.at = at
	return Rebirth.commit(profile, familiarUid)
end

return Rebirth
