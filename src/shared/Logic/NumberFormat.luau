--!strict

local SCIENTIFIC_FROM = 1e34
local FULL_BELOW = 10000

local TIERS = {
	{ min = 1e4, div = 1e3, suffix = "K", decimals = 1 },
	{ min = 1e6, div = 1e6, suffix = "M", decimals = 2 },
	{ min = 1e9, div = 1e9, suffix = "B", decimals = 2 },
	{ min = 1e12, div = 1e12, suffix = "T", decimals = 2 },
	{ min = 1e15, div = 1e15, suffix = "Qa", decimals = 2 },
	{ min = 1e18, div = 1e18, suffix = "Qi", decimals = 2 },
	{ min = 1e21, div = 1e21, suffix = "Sx", decimals = 2 },
	{ min = 1e24, div = 1e24, suffix = "Sp", decimals = 2 },
	{ min = 1e27, div = 1e27, suffix = "Oc", decimals = 2 },
	{ min = 1e30, div = 1e30, suffix = "No", decimals = 2 },
	{ min = 1e33, div = 1e33, suffix = "Dc", decimals = 2 },
}

local NumberFormat = {}

local function withCommas(digits: string): string
	local reversed = string.reverse(digits)
	local grouped = string.gsub(reversed, "(%d%d%d)", "%1,")
	local restored = string.reverse(grouped)
	if string.sub(restored, 1, 1) == "," then
		return string.sub(restored, 2)
	end
	return restored
end

local function formatFull(magnitude: number): string
	local cents = math.round(magnitude * 100)
	local whole = math.floor(cents / 100)
	local fraction = cents % 100
	local body = withCommas(tostring(whole))
	if fraction == 0 then
		return "$" .. body
	end
	return string.format("$%s.%02d", body, fraction)
end

local function scientific(magnitude: number): string
	local exponent = math.floor(math.log10(magnitude) + 1e-9)
	local mantissa = magnitude / (10 ^ exponent)
	local rounded = math.round(mantissa * 10) / 10
	if rounded >= 10 then
		rounded /= 10
		exponent += 1
	end
	return string.format("$%.1fe%d", rounded, exponent)
end

local function formatTier(magnitude: number, tierIndex: number): string
	local tier = TIERS[tierIndex]
	local factor = 10 ^ tier.decimals
	local rounded = math.round((magnitude / tier.div) * factor) / factor
	local crossed = rounded >= 1000 or (tierIndex == #TIERS and rounded >= 10)
	if crossed then
		if tierIndex >= #TIERS then
			return scientific(magnitude)
		end
		return formatTier(magnitude, tierIndex + 1)
	end
	return string.format("$%." .. tostring(tier.decimals) .. "f%s", rounded, tier.suffix)
end

local function formatMagnitude(magnitude: number): string
	if magnitude < FULL_BELOW then
		return formatFull(magnitude)
	end
	if magnitude >= SCIENTIFIC_FROM then
		return scientific(magnitude)
	end
	local tierIndex = 1
	for index, tier in TIERS do
		if magnitude >= tier.min then
			tierIndex = index
		end
	end
	return formatTier(magnitude, tierIndex)
end

function NumberFormat.formatCash(value: number): string
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return "$0"
	end
	if value < 0 then
		return "-" .. formatMagnitude(-value)
	end
	return formatMagnitude(value)
end

function NumberFormat.formatRate(perSecond: number): string
	if type(perSecond) ~= "number" or perSecond ~= perSecond then
		return "+$0/s"
	end
	local prefix = if perSecond < 0 then "-" else "+"
	return prefix .. NumberFormat.formatCash(math.abs(perSecond)) .. "/s"
end

return NumberFormat
