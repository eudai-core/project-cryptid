--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Save = import("../Config/Save", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Save")
end)

local Autosave = {}

function Autosave.plan(dirty: boolean, lockExpiresAt: number, now: number): string
	if dirty then
		return "save"
	end
	if type(lockExpiresAt) ~= "number" or lockExpiresAt - now <= Save.LOCK_REFRESH_SECONDS then
		return "renew"
	end
	return "skip"
end

function Autosave.apply(dirty: boolean, lockExpiresAt: number, now: number, actions: any): string
	local plan = Autosave.plan(dirty, lockExpiresAt, now)
	if plan == "skip" then
		return "skipped"
	end
	if plan == "renew" then
		local ok, status = actions.renew()
		if ok then
			return "renewed"
		end
		return tostring(status)
	end
	local ok, status = actions.save()
	if ok then
		if type(actions.onSaved) == "function" then
			actions.onSaved()
		end
		return "saved"
	end
	return tostring(status)
end

return Autosave
