--!strict

-- Studio playtests pass one string, `qa:<seconds>` plus optional suffixes.
-- `offline:<seconds>` rewinds lastSeen. `utc:<days>` shifts the offering day.
-- `utcjump:<seconds>` adds one more day after that many seconds of the test.
-- `analytics` marks a Studio playtest that should print the analytics sink banner.
-- Unknown suffixes (such as `plots3`) are ignored so the watchdog still arms.
-- `fresh` asks Studio to load a throwaway key instead of the real save.
-- `relics` opens the shop gate once the rite has reached it.
-- `rebirthready` fills the tier-1 rite requirements. Studio only. No remote.

local QaArgs = {}

export type Tokens = {
	offlineSeconds: number,
	utcDays: number,
	utcJumpSeconds: number,
	openTree: boolean,
	reducedMotion: string,
	fresh: boolean,
	relics: boolean,
	analytics: boolean,
	rebirthReady: boolean,
}

local function empty(): Tokens
	return {
		offlineSeconds = 0,
		utcDays = 0,
		utcJumpSeconds = 0,
		openTree = false,
		reducedMotion = "",
		fresh = false,
		relics = false,
		analytics = false,
		rebirthReady = false,
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
		if key == "relics" then
			tokens.relics = true
			index += 1
		elseif key == "analytics" then
			tokens.analytics = true
			index += 1
		elseif key == "rebirthready" then
			tokens.rebirthReady = true
			index += 1
		elseif key == "opentree" or key == "fresh" then
			if key == "fresh" then
				tokens.fresh = true
			else
				tokens.openTree = true
			end
			index += 1
		elseif key == "reducedmotion" then
			local flag = parts[index + 1]
			if flag == "on" or flag == "off" then
				tokens.reducedMotion = flag
				index += 2
			else
				index += 1
			end
		elseif key == "offline" or key == "utc" or key == "utcjump" then
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

function QaArgs.rebirthReady(isStudio: boolean, args: any): boolean
	if isStudio ~= true then
		return false
	end
	return QaArgs.parse(args).rebirthReady == true
end

function QaArgs.openTree(isStudio: boolean, args: any): boolean
	if isStudio ~= true then
		return false
	end
	return QaArgs.parse(args).openTree == true
end

function QaArgs.wantsFresh(isStudio: boolean, args: any): boolean
	if isStudio ~= true then
		return false
	end
	return QaArgs.parse(args).fresh == true
end

function QaArgs.reducedMotion(isStudio: boolean, args: any): boolean?
	if isStudio ~= true then
		return nil
	end
	local flag = QaArgs.parse(args).reducedMotion
	if flag == "on" then
		return true
	end
	if flag == "off" then
		return false
	end
	return nil
end

return QaArgs
