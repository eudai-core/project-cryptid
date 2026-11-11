--!strict

-- Save-debug suffixes on a bot playtest arg `qa:<seconds>[:suffix]`.
-- Callers pass isStudio. A live server always gets the inert plan.
-- Offline and offering suffixes are applied by StudioQaHooks.

local StudioQa = {}

local HOOKS = {
	["loadfail"] = true,
	["foreignlock"] = true,
	["foreignlock:stale"] = true,
}

function StudioQa.parse(args: any): string?
	if type(args) ~= "string" then
		return nil
	end
	local suffix = string.match(args, "^qa:%d+:(.+)$")
	if suffix == nil or HOOKS[suffix] ~= true then
		return nil
	end
	return suffix
end

function StudioQa.active(isStudio: boolean, args: any): string?
	if isStudio ~= true then
		return nil
	end
	return StudioQa.parse(args)
end

function StudioQa.plan(isStudio: boolean, args: any): string
	local hook = StudioQa.active(isStudio, args)
	if hook == "loadfail" then
		return "kick"
	end
	if hook == "foreignlock" then
		return "seed-fresh"
	end
	if hook == "foreignlock:stale" then
		return "seed-stale"
	end
	return "load"
end

function StudioQa.armRelics(profile: any)
	-- selene: allow(global_usage)
	if _G.LUNE == true or type(profile) ~= "table" or type(profile.onboarding) ~= "table" then
		return
	end
	if not game:GetService("RunService"):IsStudio() then
		return
	end
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Shared = ReplicatedStorage:WaitForChild("Shared")
	local Monetisation = require(Shared:WaitForChild("Config"):WaitForChild("Monetisation"))
	local QaArgs = require(Shared:WaitForChild("Logic"):WaitForChild("QaArgs"))
	local StudioQaHooks = require(script.Parent:WaitForChild("StudioQaHooks"))
	if QaArgs.parse(StudioQaHooks.args()).relics ~= true then
		return
	end
	if profile.onboarding.step < Monetisation.GATE_STEP then
		return
	end
	if profile.onboarding.playSeconds < Monetisation.GATE_PLAY_SECONDS then
		profile.onboarding.playSeconds = Monetisation.GATE_PLAY_SECONDS
	end
end

return StudioQa
