--!strict

-- Ends a Studio test the bot started with args `qa:<seconds>`, so a dropped
-- bridge cannot leave the playtest running. Manual Play (no qa arg) is ignored.
-- GetTestArgs preserves the value the plugin passed. The wrapper sends one
-- string, so a table argument does not arm this script.

local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return
end

local StudioTestService = game:GetService("StudioTestService") :: any
local WatchdogBudget = require(script.Parent:WaitForChild("WatchdogBudget"))

local ok, args = pcall(function()
	return StudioTestService:GetTestArgs()
end)
if not ok or type(args) ~= "string" then
	return
end

local seconds = WatchdogBudget.secondsFor(args)
if seconds == nil then
	return
end

warn("[Cryptid:Watchdog] armed for " .. tostring(seconds) .. "s (args " .. string.format("%q", args) .. ")")
task.delay(seconds, function()
	warn("[Cryptid:Watchdog] ending bot playtest after " .. tostring(seconds) .. "s")
	pcall(function()
		StudioTestService:EndTest("watchdog-timeout")
	end)
end)
