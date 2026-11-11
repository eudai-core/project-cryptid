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
local Monetisation = import("../Config/Monetisation", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Monetisation")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local RelicGrants = import("./RelicGrants", function()
	return script.Parent:WaitForChild("RelicGrants")
end)

local Passes = {}

function Passes.owned(profile: any, key: string): boolean
	if type(profile) ~= "table" then
		return false
	end
	if key == "starterPack" then
		return type(profile.purchases) == "table" and profile.purchases.starterPackClaimed == true
	end
	if key == "cashDouble" then
		return profile.cashDouble == true
	end
	if key == "autoCollect" then
		return profile.autoCollect == true
	end
	if type(profile.passes) ~= "table" then
		return false
	end
	if key == "extraPads" then
		return profile.passes.extraPads == true
	end
	if key == "lairCosmetics" then
		return profile.passes.lairCosmetics == true
	end
	if key == "sigilNameplate" then
		return profile.passes.sigilNameplate == true
	end
	return false
end

function Passes.openRelicPads(profile: any): boolean
	if not Passes.owned(profile, "extraPads") or type(profile) ~= "table" then
		return false
	end
	local unlocked = profile.padsUnlocked
	if type(unlocked) ~= "number" or unlocked < Economy.CASH_PAD_MAX or unlocked >= Economy.MAX_PADS then
		return false
	end
	profile.padsUnlocked = Economy.MAX_PADS
	return true
end

function Passes.grant(
	profile: any,
	key: string,
	now: number,
	instanceId: string?
): { changed: boolean, cash: number, grants: { string } }
	local empty = {
		changed = false,
		cash = 0,
		grants = {},
	}
	local spec = Monetisation.byKey(key)
	if spec == nil or spec.kind ~= "pass" or type(profile) ~= "table" then
		return empty
	end
	if Passes.owned(profile, key) then
		return empty
	end
	local grants: { string } = {}
	local cash = 0
	if key == "starterPack" then
		if type(instanceId) ~= "string" or profile.cryptids[instanceId] ~= nil then
			return empty
		end
		if Species.get(Monetisation.STARTER_SPECIES) == nil then
			return empty
		end
		cash = Monetisation.STARTER_CASH
		profile.cash = Money.round(profile.cash + cash)
		profile.cryptids[instanceId] = {
			speciesId = Monetisation.STARTER_SPECIES,
			mutation = "",
			traits = {},
			acquiredAt = now,
			source = "relic",
		}
		profile.purchases.starterPackClaimed = true
		table.insert(grants, "cash:" .. tostring(cash))
		table.insert(grants, "species:" .. Monetisation.STARTER_SPECIES)
	elseif key == "cashDouble" then
		profile.cashDouble = true
		table.insert(grants, "pass:cashDouble")
	elseif key == "extraPads" then
		profile.passes.extraPads = true
		Passes.openRelicPads(profile)
		table.insert(grants, "pass:extraPads")
	elseif key == "lairCosmetics" then
		profile.passes.lairCosmetics = true
		profile.cosmetics.owned[Monetisation.LAIR_COSMETIC] = true
		table.insert(grants, "cosmetic:" .. Monetisation.LAIR_COSMETIC)
	elseif key == "autoCollect" then
		profile.autoCollect = true
		table.insert(grants, "pass:autoCollect")
	elseif key == "sigilNameplate" then
		profile.passes.sigilNameplate = true
		table.insert(grants, "pass:sigilNameplate")
	else
		return empty
	end
	RelicGrants.noteFirst(profile, now, grants)
	return {
		changed = true,
		cash = cash,
		grants = grants,
	}
end

function Passes.confirm(fetch: () -> any, sleep: (number) -> ()): boolean?
	local tries = Monetisation.OWNERSHIP_ATTEMPTS
	local waits = Monetisation.OWNERSHIP_BACKOFF
	for attempt = 1, tries do
		local ok, owned = pcall(fetch)
		if ok and owned == true then
			return true
		end
		if ok and owned == false then
			return false
		end
		if attempt < tries then
			local pause = waits[attempt]
			if type(pause) == "number" and pause > 0 then
				sleep(pause)
			end
		end
	end
	return nil
end

return Passes
