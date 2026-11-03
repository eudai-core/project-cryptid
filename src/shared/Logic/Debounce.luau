--!strict

local Debounce = {}

function Debounce.allow(lastAt: number?, now: number, interval: number): (boolean, number)
	if lastAt ~= nil and (now - lastAt) < interval then
		return false, lastAt
	end
	return true, now
end

return Debounce
