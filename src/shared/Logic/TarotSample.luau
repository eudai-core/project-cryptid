--!strict

-- Studio playtests may grant one free deck token. A live server never does.

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local TarotCases = import("../Config/TarotCases", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("TarotCases")
end)

local TarotSample = {}

function TarotSample.grant(profile: any, tokenName: any, isStudio: any, requested: any): boolean
	if isStudio ~= true or requested ~= true then
		return false
	end
	if type(tokenName) ~= "string" or tokenName == "" then
		return false
	end
	if type(profile) ~= "table" or type(profile.tarot) ~= "table" or type(profile.tarot.tokens) ~= "table" then
		return false
	end
	local count = profile.tarot.tokens[tokenName]
	if type(count) ~= "number" then
		return false
	end
	local nextCount = count + TarotCases.STUDIO_SAMPLE
	if nextCount > TarotCases.CASE_CAP then
		return false
	end
	profile.tarot.tokens[tokenName] = nextCount
	return true
end

return TarotSample
