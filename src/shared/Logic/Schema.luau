--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
end)
local Plots = import("../Config/Plots", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Plots")
end)
local Save = import("../Config/Save", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Save")
end)
local Shop = import("../Config/Shop", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Shop")
end)
local SkillConfig = import("../Config/SkillConfig", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("SkillConfig")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)

local SOURCES = {
	starter = true,
	rift = true,
	wild = true,
	pedlar = true,
}

local Schema = {}

function Schema.deepCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, child in value do
		copy[Schema.deepCopy(key)] = Schema.deepCopy(child)
	end
	return copy
end

local function cryptidFrom(raw: any): any?
	if type(raw) ~= "table" then
		return nil
	end
	local speciesId = raw.speciesId
	if speciesId == Species.LEGACY_WILD_ID then
		speciesId = Species.WILD_ID
	end
	if type(speciesId) ~= "string" or Species.get(speciesId) == nil then
		return nil
	end
	if type(raw.source) ~= "string" or SOURCES[raw.source] ~= true then
		return nil
	end
	local traits = {}
	if raw.traits == nil then
		traits = {}
	elseif type(raw.traits) ~= "table" then
		return nil
	else
		for _, trait in raw.traits do
			if type(trait) ~= "string" or #trait > 32 then
				return nil
			end
			table.insert(traits, trait)
		end
	end
	local acquiredAt = raw.acquiredAt
	if acquiredAt == nil then
		acquiredAt = 0
	end
	if not Money.isFinite(acquiredAt) then
		return nil
	end
	local mutation = ""
	if raw.mutation ~= nil then
		if type(raw.mutation) ~= "string" or #raw.mutation > 32 then
			return nil
		end
		mutation = raw.mutation
	end
	return {
		speciesId = speciesId,
		mutation = mutation,
		traits = traits,
		acquiredAt = acquiredAt,
		source = raw.source,
	}
end

local function normalizeV1(raw: any): any?
	if not Money.isFinite(raw.cash) or raw.cash < 0 then
		return nil
	end
	if not Money.isFinite(raw.totalEarned) or raw.totalEarned < 0 then
		return nil
	end
	if type(raw.padsUnlocked) ~= "number" or raw.padsUnlocked ~= math.floor(raw.padsUnlocked) then
		return nil
	end
	if raw.padsUnlocked < 1 or raw.padsUnlocked > Economy.MAX_PADS then
		return nil
	end
	if type(raw.pads) ~= "table" or type(raw.cryptids) ~= "table" then
		return nil
	end
	if type(raw.upgrades) ~= "table" or type(raw.upgrades.boneAltar) ~= "number" then
		return nil
	end
	local altar = raw.upgrades.boneAltar
	if altar ~= math.floor(altar) or altar < 0 or altar > Economy.MAX_ALTAR_LEVEL then
		return nil
	end
	if type(raw.onboarding) ~= "table" then
		return nil
	end
	local step = raw.onboarding.step
	if type(step) ~= "number" or step ~= math.floor(step) or step < 0 or step > 8 then
		return nil
	end
	if step == 0 then
		step = 1
	end
	if type(raw.onboarding.starterGranted) ~= "boolean" or type(raw.onboarding.skipped) ~= "boolean" then
		return nil
	end
	local playSeconds = raw.onboarding.playSeconds
	if playSeconds == nil then
		playSeconds = 0
	end
	if not Money.isFinite(playSeconds) or playSeconds < 0 then
		return nil
	end
	if not Money.isFinite(raw.firstJoinUnix) then
		return nil
	end
	local reducedMotion = false
	if raw.settings == nil then
		reducedMotion = false
	elseif type(raw.settings) ~= "table" then
		return nil
	else
		local flag = raw.settings.reducedMotion
		if flag == nil then
			reducedMotion = false
		elseif type(flag) ~= "boolean" then
			return nil
		else
			reducedMotion = flag
		end
	end

	local cryptids = {}
	for instanceId, record in raw.cryptids do
		if type(instanceId) ~= "string" or #instanceId < 1 or #instanceId > 64 then
			return nil
		end
		if string.match(instanceId, "^[%w%-]+$") == nil then
			return nil
		end
		local cryptid = cryptidFrom(record)
		if cryptid == nil then
			return nil
		end
		cryptids[instanceId] = cryptid
	end

	local pads = {}
	local seen: { [string]: boolean } = {}
	for key, value in raw.pads do
		local index: number? = nil
		if type(key) == "number" and key == math.floor(key) then
			index = key
		elseif type(key) == "string" and string.match(key, "^%d+$") ~= nil then
			index = tonumber(key)
		else
			return nil
		end
		if index == nil or index < 1 or index > Economy.MAX_PADS or type(value) ~= "string" then
			return nil
		end
		if cryptids[value] == nil or seen[value] == true then
			return nil
		end
		seen[value] = true
		pads[tostring(index)] = value
	end

	return {
		cash = Money.round(raw.cash),
		totalEarned = Money.round(raw.totalEarned),
		padsUnlocked = raw.padsUnlocked,
		pads = pads,
		cryptids = cryptids,
		upgrades = {
			boneAltar = altar,
		},
		onboarding = {
			step = step,
			starterGranted = raw.onboarding.starterGranted,
			skipped = raw.onboarding.skipped,
			playSeconds = playSeconds,
		},
		firstJoinUnix = raw.firstJoinUnix,
		settings = {
			reducedMotion = reducedMotion,
			bindAtOnce = false,
		},
	}
end

local function freshShop(): any
	local bought = {}
	for slot = 1, Shop.SLOT_COUNT do
		bought[slot] = false
	end
	return {
		lastRotationId = 0,
		boughtSlots = bought,
	}
end

local function readSlot(slots: any, index: number): boolean?
	local value = slots[index]
	if value == nil then
		value = slots[tostring(index)]
	end
	if type(value) ~= "boolean" then
		return nil
	end
	return value
end

local function parseShop(raw: any, version: number): any?
	if version < 4 then
		return freshShop()
	end
	if type(raw.shop) ~= "table" then
		return nil
	end
	local rotationId = raw.shop.lastRotationId
	if type(rotationId) ~= "number" or rotationId ~= math.floor(rotationId) then
		return nil
	end
	if rotationId < 0 or rotationId > 1e12 then
		return nil
	end
	if type(raw.shop.boughtSlots) ~= "table" then
		return nil
	end
	local bought = {}
	for slot = 1, Shop.SLOT_COUNT do
		local flag = readSlot(raw.shop.boughtSlots, slot)
		if flag == nil then
			return nil
		end
		bought[slot] = flag
	end
	return {
		lastRotationId = rotationId,
		boughtSlots = bought,
	}
end

local function parseSkills(raw: any): { string }?
	if type(raw) ~= "table" or raw.skills == nil then
		return {}
	end
	if type(raw.skills) ~= "table" then
		return nil
	end
	local list = {}
	local seen: { [string]: boolean } = {}
	local function take(id: any): boolean
		if type(id) ~= "string" then
			return false
		end
		if #id < 1 or #id > SkillConfig.ID_MAX or string.match(id, "^[%w]+$") == nil or SkillConfig.get(id) == nil then
			warn("[Cryptid:Skill] ignored unknown rite")
			return true
		end
		if id == SkillConfig.ROOT or seen[id] == true then
			return true
		end
		seen[id] = true
		table.insert(list, id)
		return true
	end
	local count = #raw.skills
	if count > SkillConfig.SAVE_MAX then
		return nil
	end
	if count > 0 then
		for index = 1, count do
			if not take(raw.skills[index]) then
				return nil
			end
		end
		return list
	end
	local extras = 0
	for _, value in raw.skills do
		extras += 1
		if extras > SkillConfig.SAVE_MAX then
			return nil
		end
		if not take(value) then
			return nil
		end
	end
	return list
end

local function parseBind(raw: any, version: number): boolean?
	if version < 4 then
		return false
	end
	if type(raw.settings) ~= "table" or type(raw.settings.bindAtOnce) ~= "boolean" then
		return nil
	end
	return raw.settings.bindAtOnce
end

local function parseDefences(base: any): { [number]: string }?
	if base == nil then
		return {}
	end
	if type(base) ~= "table" then
		return nil
	end
	local raw = base.defences
	if raw == nil then
		return {}
	end
	if type(raw) ~= "table" then
		return nil
	end
	local defences = {}
	for key, value in raw do
		local index: number? = nil
		if type(key) == "number" and key == math.floor(key) then
			index = key
		elseif type(key) == "string" and string.match(key, "^%d+$") ~= nil then
			index = tonumber(key)
		else
			return nil
		end
		if index == nil or index < 1 or index > Plots.DEFENCE_KEY_MAX then
			return nil
		end
		if type(value) ~= "string" or string.match(value, "^[%w_%-]+$") == nil then
			return nil
		end
		defences[index] = value
	end
	return defences
end

function Schema.migrate(raw: any): any?
	if type(raw) ~= "table" then
		return nil
	end
	local version = raw.dataVersion
	if type(version) ~= "number" or version ~= math.floor(version) then
		return nil
	end
	if version > Save.DATA_VERSION or version < 1 then
		return nil
	end
	local profile = normalizeV1(raw)
	if profile == nil then
		return nil
	end
	if version < 2 then
		local incomeOnly = profile.totalEarned - Economy.STARTING_CASH
		if incomeOnly < 0 then
			incomeOnly = 0
		end
		profile.totalEarned = Money.round(incomeOnly)
	end
	local defences = {}
	if version >= 3 then
		local parsed = parseDefences(raw.base)
		if parsed == nil then
			return nil
		end
		defences = parsed
	end
	local shop = parseShop(raw, version)
	if shop == nil then
		return nil
	end
	local bindAtOnce = parseBind(raw, version)
	if bindAtOnce == nil then
		return nil
	end
	local skills = parseSkills(raw)
	if skills == nil then
		return nil
	end
	profile.dataVersion = Save.DATA_VERSION
	profile.base = {
		defences = defences,
	}
	profile.shop = shop
	profile.settings.bindAtOnce = bindAtOnce
	profile.skills = skills
	return profile
end

function Schema.newProfile(now: number, starterInstanceId: string): any
	local starter = Species.get(Species.STARTER_ID)
	assert(starter ~= nil, "starter species missing")
	return {
		dataVersion = Save.DATA_VERSION,
		cash = Economy.STARTING_CASH,
		totalEarned = 0,
		padsUnlocked = Economy.STARTING_PADS_UNLOCKED,
		pads = {
			["1"] = starterInstanceId,
		},
		cryptids = {
			[starterInstanceId] = {
				speciesId = Species.STARTER_ID,
				mutation = "",
				traits = {},
				acquiredAt = now,
				source = "starter",
			},
		},
		upgrades = {
			boneAltar = 0,
		},
		onboarding = {
			step = 1,
			starterGranted = true,
			skipped = false,
			playSeconds = 0,
		},
		firstJoinUnix = now,
		settings = {
			reducedMotion = false,
			bindAtOnce = false,
		},
		shop = freshShop(),
		base = {
			defences = {},
		},
		skills = {},
	}
end

function Schema.ensureStarter(profile: any, now: number, starterInstanceId: string): boolean
	if profile.onboarding.starterGranted == true then
		return false
	end
	if profile.cryptids[starterInstanceId] ~= nil then
		return false
	end
	profile.cryptids[starterInstanceId] = {
		speciesId = Species.STARTER_ID,
		mutation = "",
		traits = {},
		acquiredAt = now,
		source = "starter",
	}
	if profile.pads["1"] == nil then
		profile.pads["1"] = starterInstanceId
	end
	profile.onboarding.starterGranted = true
	if profile.onboarding.step < 1 then
		profile.onboarding.step = 1
	end
	return true
end

return Schema
