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

local Settings = {}

function Settings.volume(value: any): number?
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return nil
	end
	if value < Return.VOLUME_MIN or value > Return.VOLUME_MAX then
		return nil
	end
	return value
end

function Settings.quality(value: any): string?
	if type(value) ~= "string" then
		return nil
	end
	for _, name in Return.EFFECTS do
		if value == name then
			return name
		end
	end
	return nil
end

function Settings.apply(profile: any, key: any, value: any): boolean
	if type(key) ~= "string" or type(profile) ~= "table" or type(profile.settings) ~= "table" then
		return false
	end
	if key == "sfx" or key == "music" then
		local volume = Settings.volume(value)
		if volume == nil then
			return false
		end
		profile.settings[key] = volume
		return true
	end
	if key == "effectsQuality" then
		local quality = Settings.quality(value)
		if quality == nil then
			return false
		end
		profile.settings.effectsQuality = quality
		return true
	end
	if key == "reducedMotion" then
		if type(value) ~= "boolean" then
			return false
		end
		profile.settings.reducedMotion = value
		return true
	end
	return false
end

return Settings
