--!strict

-- Named prompt anchors for Hollowmere shops. The World Builder kits own the
-- parts. This module only names them. It does not create geometry.

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Town = import("./Town", function()
	return script.Parent:WaitForChild("Town")
end)

local function stallId(): string
	for _, spec in Town.DISTRICTS do
		if spec.kind == "pedlar" then
			return spec.id
		end
	end
	return "PalePedlar"
end

local PEDLAR_ID = stallId()
local PEDLAR_PROMPT = if type(Town.PEDLAR_PROMPT_NAME) == "string" then Town.PEDLAR_PROMPT_NAME else "Pedlar"

local function shop(shopId: string, displayName: string, catalogueId: string)
	return table.freeze({
		shopId = shopId,
		displayName = displayName,
		actionText = "Enter",
		mode = "shop",
		catalogueId = catalogueId,
		promptKind = "TownShop",
		anchorPath = table.freeze({ "Hollowmere", shopId, shopId .. "PromptAnchor" }),
	})
end

local LIST = table.freeze({
	shop("HowlingHorn", "The Howling Horn", "HowlingHorn"),
	shop("RuneheartApothecary", "Runeheart Apothecary", "RuneheartApothecary"),
	table.freeze({
		shopId = "VeilAndFate",
		displayName = "Veil & Fate",
		actionText = "Enter",
		mode = "soon",
		catalogueId = "VeilAndFate",
		-- The tarot pull request plugs in here. It stays a coming-soon panel until then.
		plug = "tarot",
		promptKind = "TownShop",
		anchorPath = table.freeze({ "Hollowmere", "VeilAndFate", "VeilAndFatePromptAnchor" }),
	}),
	shop("DuskAndDial", "Dusk & Dial", "DuskAndDial"),
	shop("Lanternwright", "The Lanternwright", "Lanternwright"),
	table.freeze({
		shopId = PEDLAR_ID,
		displayName = "The Pale Pedlar",
		actionText = "Browse",
		mode = "pedlar",
		catalogueId = PEDLAR_ID,
		promptKind = PEDLAR_PROMPT,
		modelPath = table.freeze({ "Districts", PEDLAR_ID }),
		fallbackPath = table.freeze({ "Districts", PEDLAR_ID, PEDLAR_ID .. "PromptAnchor" }),
	}),
})

local BY_ID: { [string]: any } = {}
for _, entry in LIST do
	BY_ID[entry.shopId] = entry
end

local ShopAnchors = {
	PEDLAR_ID = PEDLAR_ID,
	PROMPT_KIND = "TownShop",
	WAIT_SECONDS = 8,
	OPEN_ID = "TownShopId",
	OPEN_TOKEN = "TownShopToken",
	NOTICE = "TownShopNotice",
	NOTICE_TOKEN = "TownShopNoticeToken",
}

function ShopAnchors.list(): { any }
	return LIST
end

function ShopAnchors.get(shopId: any): any
	if type(shopId) ~= "string" then
		return nil
	end
	return BY_ID[shopId]
end

function ShopAnchors.sells(entry: any): boolean
	return type(entry) == "table" and (entry.mode == "shop" or entry.mode == "pedlar")
end

function ShopAnchors.pathText(parts: { string }?): string
	if type(parts) ~= "table" then
		return ""
	end
	return table.concat(parts, ".")
end

return table.freeze(ShopAnchors)
