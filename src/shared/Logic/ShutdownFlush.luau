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

local ShutdownFlush = {}

function ShutdownFlush.budget(isStudio: boolean): number
	if isStudio then
		return Save.STUDIO_SHUTDOWN_TIMEOUT_SECONDS
	end
	return Save.SHUTDOWN_TIMEOUT_SECONDS
end

function ShutdownFlush.run(entries: { any }, deps: any): any
	local pending = 0
	local saved = 0
	local released = 0
	for _, entry in entries do
		if entry.loaded == true then
			pending += 1
			deps.spawn(function()
				local saveOk = false
				local releaseOk = false
				local ran, err = pcall(function()
					if entry.dirty == true then
						saveOk = deps.save(entry) == true
					end
					releaseOk = deps.release(entry) == true
				end)
				if not ran and deps.warn ~= nil then
					deps.warn(tostring(err))
				end
				if saveOk then
					saved += 1
				end
				if releaseOk then
					released += 1
				end
				pending -= 1
			end)
		end
	end
	local started = deps.now()
	while pending > 0 do
		if deps.budgetSeconds <= 0 then
			break
		end
		if deps.now() - started >= deps.budgetSeconds then
			break
		end
		deps.waitFor(Save.SHUTDOWN_POLL_SECONDS)
	end
	return {
		saved = saved,
		released = released,
		pending = pending,
	}
end

return ShutdownFlush
