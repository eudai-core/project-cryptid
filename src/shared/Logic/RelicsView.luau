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
local Return = import("../Config/Return", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Return")
end)
local Bundles = import("./Bundles", function()
	return script.Parent:WaitForChild("Bundles")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local NumberFormat = import("./NumberFormat", function()
	return script.Parent:WaitForChild("NumberFormat")
end)
local Passes = import("./Passes", function()
	return script.Parent:WaitForChild("Passes")
end)
local RelicsCopy = import("./RelicsCopy", function()
	return script.Parent:WaitForChild("RelicsCopy")
end)
local RelicsPip = import("./RelicsPip", function()
	return script.Parent:WaitForChild("RelicsPip")
end)

local TITLES = {
	starterPack = RelicsCopy.STARTER_TITLE,
	cashDouble = RelicsCopy.CASH_DOUBLE_TITLE,
	extraPads = RelicsCopy.PADS_TITLE,
	lairCosmetics = RelicsCopy.LAIR_TITLE,
	pouch = "Pouch",
	coffer = "Coffer",
	chest = "Chest",
	vault = "Vault",
}

local BODIES = {
	starterPack = RelicsCopy.STARTER_BODY,
	extraPads = RelicsCopy.PADS_BODY,
	lairCosmetics = RelicsCopy.LAIR_BODY,
}

local RelicsView = {}

function RelicsView.showRelicPad(view: any): boolean
	return type(view) == "table" and view.visible == true and view.extraPadsOwned ~= true
end

function RelicsView.buttonFor(entry: any, owned: boolean): string
	if owned == true or Monetisation.isLive(entry) ~= true then
		return ""
	end
	if entry.looks == true then
		return RelicsCopy.VIEW_ITEM
	end
	return RelicsCopy.SEE_PRICE
end

local function rateText(value: number): string
	return NumberFormat.formatCash(value) .. "/s"
end

local function lineFor(profile: any, entry: any, now: number): string
	if entry.key == "cashDouble" then
		local noPass = Bundles.prePassRate(profile)
		local doubled = Money.round(noPass * Return.CASH_DOUBLE_MULTIPLIER)
		return RelicsCopy.cashDoubleLine(rateText(noPass), rateText(doubled))
	end
	if entry.kind == "bundle" then
		local amount = Bundles.grantAmount(profile, entry.key, now, Bundles.prePassRate(profile))
		local tag = if entry.key == "vault" then RelicsCopy.VAULT_TAG else nil
		return RelicsCopy.bundleLine(TITLES[entry.key], entry.span, NumberFormat.formatCash(amount), tag)
	end
	return RelicsCopy.passLine(TITLES[entry.key], BODIES[entry.key])
end

function RelicsView.build(profile: any, now: number, bought: number?, spent: number?): any
	local cards = {}
	for _, entry in Monetisation.items() do
		if entry.feature == true then
			local owned = entry.kind == "pass" and Passes.owned(profile, entry.key)
			table.insert(cards, {
				key = entry.key,
				kind = entry.kind,
				line = lineFor(profile, entry, now),
				button = RelicsView.buttonFor(entry, owned),
				owned = owned,
				live = Monetisation.isLive(entry),
			})
		end
	end
	local count = if type(bought) == "number" and bought >= 0 then math.floor(bought) else 0
	local robux = if type(spent) == "number" and spent >= 0 then math.floor(spent) else 0
	return {
		visible = Monetisation.shopOpen(profile),
		pip = RelicsPip.shouldShow(profile),
		header = RelicsCopy.HEADER,
		sub = RelicsCopy.SUB,
		button = RelicsCopy.BUTTON,
		spend = RelicsCopy.spend(count, robux),
		padLine = RelicsCopy.RELIC_PAD,
		padButton = RelicsCopy.OPEN_SHOP,
		ownedLabel = RelicsCopy.OWNED,
		extraPadsOwned = Passes.owned(profile, "extraPads"),
		cards = cards,
	}
end

return RelicsView
