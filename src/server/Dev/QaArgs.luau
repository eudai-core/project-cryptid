--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local QaConfig = import("./QaConfig", function()
	return script.Parent:WaitForChild("QaConfig")
end)

local QaArgs = {}

local function tokensFor(args: string): { string }?
	if string.sub(args, 1, 3) ~= "qa:" then
		return nil
	end
	local seconds = string.match(args, "^qa:(%d+)")
	if seconds == nil then
		return nil
	end
	local rest = string.sub(args, 4 + #seconds)
	if rest == "" then
		return {}
	end
	if string.sub(rest, 1, 1) ~= ":" then
		return {}
	end
	local tokens = {}
	for token in string.gmatch(string.sub(rest, 2), "[^:]+") do
		table.insert(tokens, token)
	end
	return tokens
end

function QaArgs.cashGrant(args: any): number?
	if type(args) ~= "string" then
		return nil
	end
	local tokens = tokensFor(args)
	if tokens == nil then
		return nil
	end
	local found: number? = nil
	for _, token in tokens do
		local digits = string.match(token, "^cash(%d+)$")
		if digits ~= nil then
			local value = tonumber(digits)
			if value == nil or value ~= value or value == math.huge then
				return nil
			end
			value = math.floor(value)
			if value > QaConfig.MAX_GRANT then
				value = QaConfig.MAX_GRANT
			end
			if found == nil then
				found = value
			end
		elseif string.sub(token, 1, 4) == "cash" then
			return nil
		end
	end
	return found
end

return QaArgs
