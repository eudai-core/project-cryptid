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
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)

local Bowl = {}

local function credit(profile: any, amount: number)
	if amount <= 0 then
		return
	end
	profile.cash = Money.round(profile.cash + amount)
	profile.totalEarned = Money.round(profile.totalEarned + amount)
end

function Bowl.bank(profile: any): number
	local amount = profile.bowl
	if type(amount) ~= "number" or amount ~= amount or amount <= 0 or amount == math.huge then
		profile.bowl = 0
		return 0
	end
	profile.bowl = 0
	credit(profile, amount)
	return amount
end

function Bowl.route(profile: any, amount: number, inside: boolean, autoCollect: boolean): (number, boolean)
	local safe = amount
	if type(safe) ~= "number" or safe ~= safe or safe < 0 or safe == math.huge then
		safe = 0
	end
	safe = Money.round(safe)
	local gate = profile.onboarding.step >= Return.GATE_STEP
	if not gate or inside then
		local banked = 0
		if gate and inside then
			banked = Bowl.bank(profile)
		end
		credit(profile, safe)
		return banked + safe, banked > 0 or safe > 0
	end
	if safe > 0 then
		profile.bowl = Money.round(profile.bowl + safe)
	end
	if autoCollect then
		local banked = Bowl.bank(profile)
		return banked, banked > 0 or safe > 0
	end
	return 0, safe > 0
end

return Bowl
