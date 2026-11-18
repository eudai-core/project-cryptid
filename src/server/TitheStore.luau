--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local StudioDataStore = import("../shared/Config/StudioDataStore", function()
	return game:GetService("ReplicatedStorage")
		:WaitForChild("Shared")
		:WaitForChild("Config")
		:WaitForChild("StudioDataStore")
end)
local StudioStore = import("../shared/Logic/StudioStore", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Logic"):WaitForChild("StudioStore")
end)

local TitheStore = {}

function TitheStore.open(options: {
	getStore: () -> any,
	createMock: () -> any,
	allowMock: () -> boolean,
	isStudio: boolean?,
	placeId: number?,
	warn: (string) -> (),
}): any
	local mock: any = nil
	local warned = false

	local function studioNow(): boolean
		if options.allowMock() ~= true then
			return false
		end
		if options.isStudio ~= nil then
			return options.isStudio == true
		end
		return true
	end

	local function placeNow(): number?
		if type(options.placeId) == "number" then
			return options.placeId
		end
		return nil
	end

	local function target(): any
		if mock ~= nil then
			return mock
		end
		return options.getStore()
	end

	local function armMock()
		if mock ~= nil then
			return
		end
		if not warned then
			warned = true
			options.warn(StudioDataStore.MOCK_WARNING)
		end
		mock = options.createMock()
	end

	if StudioStore.preferMock(studioNow(), placeNow(), nil) then
		armMock()
	end

	local function installMockIfDenied(err: any): boolean
		if not StudioStore.preferMock(studioNow(), placeNow(), err) then
			return false
		end
		armMock()
		return mock ~= nil
	end

	local function call(method: string, first: any, second: any, third: any): (boolean, any)
		local function invoke(): any
			local store = target()
			local fn = store[method]
			if third ~= nil then
				return fn(store, first, second, third)
			end
			if second ~= nil then
				return fn(store, first, second)
			end
			return fn(store, first)
		end
		local ok, result = pcall(invoke)
		if not ok and installMockIfDenied(result) then
			ok, result = pcall(invoke)
		end
		return ok, result
	end

	local api = {}

	function api.getSorted(ascending: boolean, pageSize: number): (boolean, any)
		return call("GetSortedAsync", ascending, pageSize, nil)
	end

	function api.set(key: string, value: number): boolean
		local ok = call("SetAsync", key, value, nil)
		return ok == true
	end

	function api.update(key: string, transform: (number?) -> number?): (boolean, any)
		return call("UpdateAsync", key, transform, nil)
	end

	function api.usingMock(): boolean
		return mock ~= nil
	end

	return api
end

return TitheStore
