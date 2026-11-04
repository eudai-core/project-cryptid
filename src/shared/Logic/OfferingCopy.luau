--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Return = import("../Config/Return", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Return")
end)
local Duration = import("./Duration", function()
	return script.Parent:WaitForChild("Duration")
end)
local NumberFormat = import("./NumberFormat", function()
	return script.Parent:WaitForChild("NumberFormat")
end)

local OfferingCopy = {}

function OfferingCopy.haulDetail(): string
	local percent = math.floor(Return.EFFICIENCY * 100 + 0.5)
	return "Lairs earn at "
		.. tostring(percent)
		.. "% while you're away, for up to "
		.. tostring(Return.CAP_HOURS)
		.. " hours."
end

function OfferingCopy.haulCap(): string
	return "Your lair stops gathering after " .. tostring(Return.CAP_HOURS) .. " hours away."
end

function OfferingCopy.haulBody(seconds: number): string
	return "Your menagerie fed the coffers for " .. Duration.phrase(seconds) .. "."
end

function OfferingCopy.haulBodyRich(seconds: number): string
	return "Your menagerie fed the coffers for <b>" .. Duration.phrase(seconds) .. "</b>."
end

function OfferingCopy.countdown(seconds: number): string
	return Return.OFFERING_COUNTDOWN .. Duration.phrase(seconds)
end

function OfferingCopy.progress(step: number): string
	return tostring(step) .. " of " .. tostring(Return.LADDER_STEPS)
end

function OfferingCopy.minutes(minutes: number): string
	if type(minutes) ~= "number" or minutes <= 0 then
		return ""
	end
	return tostring(math.floor(minutes)) .. " min"
end

function OfferingCopy.bowlLine(amount: number): string
	return Return.BOWL_PREFIX .. NumberFormat.formatCash(amount)
end

return OfferingCopy
