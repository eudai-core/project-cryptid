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

local ProfileQuery = {}

function ProfileQuery.padAt(profile: any, index: number): string?
	local value = profile.pads[tostring(index)]
	if type(value) ~= "string" or value == "" then
		return nil
	end
	return value
end

function ProfileQuery.ownsSpecies(profile: any, speciesId: string): boolean
	for _, record in profile.cryptids do
		if record.speciesId == speciesId then
			return true
		end
	end
	return false
end

function ProfileQuery.instanceOfSpecies(profile: any, speciesId: string): string?
	for instanceId, record in profile.cryptids do
		if record.speciesId == speciesId then
			return instanceId
		end
	end
	return nil
end

function ProfileQuery.hasSource(profile: any, source: string): boolean
	for _, record in profile.cryptids do
		if record.source == source then
			return true
		end
	end
	return false
end

function ProfileQuery.instanceOfSource(profile: any, source: string): string?
	for instanceId, record in profile.cryptids do
		if record.source == source then
			return instanceId
		end
	end
	return nil
end

function ProfileQuery.padOfInstance(profile: any, instanceId: string): number?
	for index = 1, Economy.MAX_PADS do
		if ProfileQuery.padAt(profile, index) == instanceId then
			return index
		end
	end
	return nil
end

function ProfileQuery.placedSpecies(profile: any, speciesId: string, padIndex: number): boolean
	local instanceId = ProfileQuery.padAt(profile, padIndex)
	if instanceId == nil then
		return false
	end
	local record = profile.cryptids[instanceId]
	return record ~= nil and record.speciesId == speciesId
end

function ProfileQuery.wildPlaced(profile: any): boolean
	for index = 1, profile.padsUnlocked do
		local instanceId = ProfileQuery.padAt(profile, index)
		if instanceId ~= nil then
			local record = profile.cryptids[instanceId]
			if record ~= nil and record.source == "wild" then
				return true
			end
		end
	end
	return false
end

function ProfileQuery.countSpecies(profile: any, speciesId: string): number
	local count = 0
	for _, record in profile.cryptids do
		if record.speciesId == speciesId then
			count += 1
		end
	end
	return count
end

return ProfileQuery
