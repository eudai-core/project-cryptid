--!strict

-- Save-debug suffixes on a bot playtest arg `qa:<seconds>[:suffix]`.
-- Callers pass isStudio. A live server always gets the inert plan.
-- Offline and offering suffixes are applied by StudioQaHooks.

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local QaArgs = import("../../shared/Logic/QaArgs", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("QaArgs")
end)
local QaSeed = import("../../shared/Logic/QaSeed", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("QaSeed")
end)

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

function StudioQa.seedKind(isStudio: boolean, args: any): string?
	if isStudio ~= true then
		return nil
	end
	if QaArgs.seedV9(true, args) then
		return "seedv9"
	end
	if QaArgs.rebirth6(true, args) then
		return "rebirth6"
	end
	return nil
end

function StudioQa.seedDocument(kind: string, now: number): any?
	if kind == "seedv9" then
		return QaSeed.v9(now)
	end
	if kind == "rebirth6" then
		return QaSeed.rebirth6(now)
	end
	return nil
end

function StudioQa.seedLine(kind: string, phase: string, profile: any): string
	return QaSeed.line(kind, phase, profile)
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

function StudioQa.armRebirth(profile: any): boolean
	-- selene: allow(global_usage)
	if _G.LUNE == true or type(profile) ~= "table" or type(profile.onboarding) ~= "table" then
		return false
	end
	if not game:GetService("RunService"):IsStudio() then
		return false
	end
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Shared = ReplicatedStorage:WaitForChild("Shared")
	local Rebirth = require(Shared:WaitForChild("Logic"):WaitForChild("Rebirth"))
	local StudioQaHooks = require(script.Parent:WaitForChild("StudioQaHooks"))
	if QaArgs.parse(StudioQaHooks.args()).rebirthReady ~= true then
		return false
	end
	return Rebirth.prepareQa(profile) == true
end

function StudioQa.analytics(): boolean
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return false
	end
	if not game:GetService("RunService"):IsStudio() then
		return false
	end
	local StudioQaHooks = require(script.Parent:WaitForChild("StudioQaHooks"))
	return QaArgs.parse(StudioQaHooks.args()).analytics == true
end

return StudioQa
