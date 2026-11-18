--!strict

-- Pedlar, town counters, and the tent each keep their own notice.
-- A notice is shown only on the panel that caused it, and opening clears it.

local ShopNotices = {}

function ShopNotices.channel(entry: any): string
	if type(entry) == "table" then
		if entry.mode == "pedlar" then
			return "pedlar"
		end
		if entry.mode == "tarot" or entry.plug == "tarot" then
			return "tarot"
		end
	end
	return "shop"
end

function ShopNotices.accept(openShopId: any, noticeShopId: any): boolean
	return type(openShopId) == "string" and openShopId ~= "" and openShopId == noticeShopId
end

function ShopNotices.onOpen(_shopId: any): string
	return ""
end

return ShopNotices
