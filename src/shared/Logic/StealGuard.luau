--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
end)

local StealGuard = {}

function StealGuard.isProtected(profile: any): boolean
	if profile.onboarding.step >= 8 then
		return false
	end
	if profile.onboarding.playSeconds >= Economy.STEAL_PROTECTION_PLAY_SECONDS then
		return false
	end
	return true
end

function StealGuard.canSteal(actor: any, victim: any): boolean
	return not StealGuard.isProtected(actor) and not StealGuard.isProtected(victim)
end

return StealGuard
