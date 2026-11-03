--!strict

local ShopLedger = {}

function ShopLedger.slotBought(lastRotationId: any, boughtSlots: any, rotationId: any, slot: any): boolean
	if type(lastRotationId) ~= "number" or type(rotationId) ~= "number" then
		return false
	end
	if lastRotationId ~= rotationId then
		return false
	end
	if type(boughtSlots) ~= "table" then
		return false
	end
	return boughtSlots[slot] == true
end

function ShopLedger.freshSlots(): { boolean }
	return { false, false, false, false }
end

return ShopLedger
