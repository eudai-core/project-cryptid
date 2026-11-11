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

local SessionClose = {}

function SessionClose.count(detaching: { [any]: any }): number
	local total = 0
	for _ in detaching do
		total += 1
	end
	return total
end

function SessionClose.begin(active: { [any]: any }, detaching: { [any]: any }, id: any): (string, any?)
	local session = active[id]
	if session == nil then
		local pending = detaching[id]
		if pending == nil then
			return "missing", nil
		end
		return "pending", pending
	end
	session.leaving = true
	session.alive = false
	active[id] = nil
	detaching[id] = session
	return "owner", session
end

function SessionClose.finish(detaching: { [any]: any }, id: any)
	detaching[id] = nil
end

function SessionClose.note(tally: { saved: number, released: number }, saved: boolean, released: boolean)
	if saved then
		tally.saved += 1
	end
	if released then
		tally.released += 1
	end
end

function SessionClose.acquire(session: any, deps: any): boolean
	local started = deps.now()
	while session.saveBusy == true do
		if deps.budgetSeconds <= 0 or deps.now() - started >= deps.budgetSeconds then
			return false
		end
		deps.waitFor(Save.SHUTDOWN_POLL_SECONDS)
	end
	session.saveBusy = true
	return true
end

function SessionClose.persist(session: any, deps: any): (boolean, boolean, string)
	if not SessionClose.acquire(session, deps) then
		return false, false, "busy"
	end
	local didSave = false
	local didRelease = false
	local ran, err = pcall(function()
		if session.loaded == true and session.ephemeral ~= true then
			if session.dirty == true then
				didSave = deps.save(session) == true
			end
			didRelease = deps.release(session) == true
		end
	end)
	session.saveBusy = false
	if not ran then
		if deps.warn ~= nil then
			deps.warn(tostring(err))
		end
		return false, false, "error"
	end
	return didSave, didRelease, "closed"
end

function SessionClose.shutdown(active: { [any]: any }, detaching: { [any]: any }, deps: any): any
	local started = deps.now()
	local ids = {}
	for id in active do
		table.insert(ids, id)
	end
	for _, id in ids do
		local role, session = SessionClose.begin(active, detaching, id)
		if role == "owner" then
			deps.spawn(function()
				deps.persist(id, session)
			end)
		end
	end
	while SessionClose.count(detaching) > 0 do
		if deps.budgetSeconds <= 0 or deps.now() - started >= deps.budgetSeconds then
			break
		end
		deps.waitFor(Save.SHUTDOWN_POLL_SECONDS)
	end
	return {
		pending = SessionClose.count(detaching),
		elapsed = deps.now() - started,
	}
end

return SessionClose
