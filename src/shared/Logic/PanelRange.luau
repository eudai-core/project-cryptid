--!strict

-- Client panels close a little past the prompt. The server buy gate is separate.

local PanelRange = {}

function PanelRange.limit(activation: number, hysteresis: number): number
	local base = activation
	if type(base) ~= "number" or base ~= base or base < 0 or base == math.huge then
		base = 0
	end
	local slack = hysteresis
	if type(slack) ~= "number" or slack ~= slack or slack < 0 or slack == math.huge then
		slack = 0
	end
	return base + slack
end

function PanelRange.outOfRange(distance: number?, limit: number): boolean
	if type(distance) ~= "number" or distance ~= distance or distance < 0 or distance == math.huge then
		return false
	end
	if type(limit) ~= "number" or limit ~= limit or limit < 0 then
		return false
	end
	return distance > limit
end

function PanelRange.due(now: number, last: number, interval: number): boolean
	if type(now) ~= "number" or type(last) ~= "number" or type(interval) ~= "number" then
		return false
	end
	if interval ~= interval or interval < 0 or interval == math.huge then
		return false
	end
	return now - last >= interval
end

return PanelRange
