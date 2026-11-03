--!strict

-- In-memory GlobalDataStore stand-in. DataStoreGateway may construct this only
-- while RunService:IsStudio() is true. Live and published servers never do.

local MockDataStore = {}

local function deepCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, child in value do
		copy[deepCopy(key)] = deepCopy(child)
	end
	return copy
end

local function assertKey(key: any)
	if type(key) ~= "string" or key == "" then
		error("DataStore key must be a non-empty string")
	end
end

function MockDataStore.new(): any
	local records: { [string]: any } = {}
	local store = {}

	function store:GetAsync(key: string): any
		assertKey(key)
		return deepCopy(records[key])
	end

	function store:SetAsync(key: string, value: any)
		assertKey(key)
		if value == nil then
			error("SetAsync value cannot be nil")
		end
		records[key] = deepCopy(value)
	end

	function store:UpdateAsync(key: string, transform: (any) -> any): any
		assertKey(key)
		if type(transform) ~= "function" then
			error("UpdateAsync transform must be a function")
		end
		local updated = transform(deepCopy(records[key]))
		if updated == nil then
			return nil
		end
		records[key] = deepCopy(updated)
		return deepCopy(records[key])
	end

	function store:RemoveAsync(key: string): any
		assertKey(key)
		local previous = records[key]
		records[key] = nil
		return deepCopy(previous)
	end

	return store
end

return MockDataStore
