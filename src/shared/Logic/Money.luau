--!strict

local Money = {}

function Money.round(value: number): number
	return math.round(value * 100) / 100
end

function Money.isFinite(value: any): boolean
	if type(value) ~= "number" then
		return false
	end
	return value == value and value ~= math.huge and value ~= -math.huge
end

return Money
