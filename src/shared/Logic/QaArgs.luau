--!strict

-- Studio playtests pass one string, `qa:<seconds>` plus optional suffixes.
-- `offline:<seconds>` rewinds lastSeen. `utc:<days>` shifts the offering day.
-- `utcjump:<seconds>` adds one more day after that many seconds of the test.
-- Unknown suffixes (such as `plots3`) are ignored so the watchdog still arms.

local QaArgs = {}

export type Tokens = {
	offlineSeconds: number,
	utcDays: number,
	utcJumpSeconds: number,
}

local function empty(): Tokens
	return {
		offlineSeconds = 0,
		utcDays = 0,
		utcJumpSeconds = 0,
	}
end

local function whole(value: string?): number?
	if type(value) ~= "string" then
		return nil
	end
	local parsed = tonumber(value)
	if parsed == nil or parsed ~= parsed or parsed < 0 or parsed == math.huge or parsed > 1e9 then
		return nil
	end
	return math.floor(parsed)
end

function QaArgs.empty(): Tokens
	return empty()
end

function QaArgs.parse(args: any): Tokens
	local tokens = empty()
	if type(args) ~= "string" or string.sub(args, 1, 3) ~= "qa:" then
		return tokens
	end
	local parts = string.split(args, ":")
	local index = 3
	while index <= #parts do
		local key = parts[index]
		if key == "offline" or key == "utc" or key == "utcjump" then
			local amount = whole(parts[index + 1])
			if amount ~= nil then
				if key == "offline" then
					tokens.offlineSeconds = amount
				elseif key == "utc" then
					tokens.utcDays = amount
				else
					tokens.utcJumpSeconds = amount
				end
			end
			index += 2
		else
			index += 1
		end
	end
	return tokens
end

return QaArgs
