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
local QaSeedConfig = import("../Config/QaSeed", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("QaSeed")
end)
local RebirthRules = import("../Config/Rebirth", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Rebirth")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local Rebirth = import("./Rebirth", function()
	return script.Parent:WaitForChild("Rebirth")
end)
local Schema = import("./Schema", function()
	return script.Parent:WaitForChild("Schema")
end)

local QaSeed = {}

local function cryptid(speciesId: string, source: string, now: number): any
	return {
		speciesId = speciesId,
		mutation = "",
		traits = {},
		acquiredAt = now,
		source = source,
	}
end

function QaSeed.countPads(profile: any): number
	if type(profile) ~= "table" or type(profile.pads) ~= "table" then
		return 0
	end
	local total = 0
	for _ in profile.pads do
		total += 1
	end
	return total
end

function QaSeed.countCryptids(profile: any): number
	if type(profile) ~= "table" or type(profile.cryptids) ~= "table" then
		return 0
	end
	local total = 0
	for _ in profile.cryptids do
		total += 1
	end
	return total
end

function QaSeed.line(kind: string, phase: string, profile: any): string
	local cash = 0
	local version = "missing"
	if type(profile) == "table" then
		if type(profile.cash) == "number" then
			cash = profile.cash
		end
		if profile.dataVersion ~= nil then
			version = tostring(profile.dataVersion)
		end
	end
	return string.format(
		"%s %s %s cash=%d pads=%d cryptids=%d version=%s",
		QaSeedConfig.LOG_PREFIX,
		kind,
		phase,
		cash,
		QaSeed.countPads(profile),
		QaSeed.countCryptids(profile),
		version
	)
end

function QaSeed.v9(now: number): any
	local profile = Schema.newProfile(now, QaSeedConfig.STARTER_UID)
	profile.dataVersion = QaSeedConfig.V9_VERSION
	profile.rebirths = nil
	profile.familiarId = nil
	profile.everHeld1M = nil
	profile.cash = QaSeedConfig.V9_CASH
	profile.totalEarned = QaSeedConfig.V9_CASH
	profile.tithe = QaSeedConfig.V9_TITHE
	profile.padsUnlocked = QaSeedConfig.V9_PADS_UNLOCKED
	profile.cryptids = {
		[QaSeedConfig.STARTER_UID] = cryptid(Species.STARTER_ID, "starter", now),
		[QaSeedConfig.SECOND_UID] = cryptid(Species.RIFT_1_ID, "rift", now),
		[QaSeedConfig.THIRD_UID] = cryptid(Species.RIFT_2_ID, "rift", now),
	}
	profile.pads = {
		["1"] = QaSeedConfig.STARTER_UID,
		["2"] = QaSeedConfig.SECOND_UID,
		["3"] = QaSeedConfig.THIRD_UID,
	}
	return profile
end

function QaSeed.rebirth6(now: number): any
	local profile = Schema.newProfile(now, QaSeedConfig.STARTER_UID)
	local nextTier = QaSeedConfig.REBIRTH6_COUNT + 1
	profile.rebirths = QaSeedConfig.REBIRTH6_COUNT
	profile.cash = Rebirth.cost(nextTier)
	profile.tithe = Rebirth.titheGate(nextTier)
	profile.totalEarned = profile.tithe
	profile.everHeld1M = true
	profile.onboarding.step = RebirthRules.ONBOARDING_STEP
	profile.familiarId = ""
	profile.padsUnlocked = Economy.STARTING_PADS_UNLOCKED
	return profile
end

return QaSeed
