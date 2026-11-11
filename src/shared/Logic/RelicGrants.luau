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

local RelicGrants = {}

function RelicGrants.noteFirst(profile: any, now: number, grants: { string })
	if profile.purchases.firstPurchaseAt ~= nil then
		return
	end
	profile.purchases.firstPurchaseAt = now
	profile.cosmetics.owned[Monetisation.FOUNDERS_CANDLE] = true
	table.insert(grants, "cosmetic:" .. Monetisation.FOUNDERS_CANDLE)
end

return RelicGrants
