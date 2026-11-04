--!strict

local RelicsCopy = {
	BUTTON = "Relics",
	HEADER = "Relics of the Hollow",
	SUB = "Your first Relic also lights a Founder's Candle.",
	SEE_PRICE = "See Price",
	VIEW_ITEM = "View Item",
	OPEN_SHOP = "Open Shop",
	OWNED = "Owned",
	VAULT_TAG = "Most cash per Robux",
	RELIC_PAD = "Relic pad · View Item",
	CASH_DOUBLE_TITLE = "2x Cash",
	CASH_DOUBLE_BODY = "Your cryptids earn double.",
	PADS_TITLE = "+2 Pads",
	PADS_BODY = "Unlocks Pads 9–10. Kept through rebirth.",
	LAIR_TITLE = "Lair Cosmetics",
	LAIR_BODY = "Gilded and Bone Rite banners, Bone-wax candles.",
	STARTER_TITLE = "Starter Pack",
	STARTER_BODY = "$5,000 + 1 Hidebehind.",
	SESSION_LEFT = "This session: ",
	SESSION_MID = " Relics · ",
	SESSION_RIGHT = " R$",
}

function RelicsCopy.spend(count: number, catalogSpent: number): string
	return RelicsCopy.SESSION_LEFT
		.. tostring(count)
		.. RelicsCopy.SESSION_MID
		.. tostring(catalogSpent)
		.. RelicsCopy.SESSION_RIGHT
end

function RelicsCopy.cashDoubleLine(nowText: string, nextText: string): string
	return RelicsCopy.CASH_DOUBLE_TITLE
		.. " · "
		.. RelicsCopy.CASH_DOUBLE_BODY
		.. " Now "
		.. nowText
		.. " → "
		.. nextText
		.. "."
end

function RelicsCopy.bundleLine(title: string, span: string, amountText: string, tag: string?): string
	local line = title .. " · " .. span .. " of your income · " .. amountText
	if tag ~= nil and tag ~= "" then
		line ..= " · " .. tag
	end
	return line
end

function RelicsCopy.passLine(title: string, body: string): string
	return title .. " · " .. body
end

return RelicsCopy
