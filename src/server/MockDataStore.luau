--!strict

-- In-memory GlobalDataStore stand-in. DataStoreGateway may construct this only
-- while RunService:IsStudio() is true. Live and published servers never do.
-- Tests inject faults with FailNext, ThrottleNext, SetBudget, and SeedLock.

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
	local faults: { [string]: any } = {}
	local budget = 1000
	local store = {}

	local function consume(method: string)
		local fault = faults[method]
		if fault == nil or fault.remaining <= 0 then
			return
		end
		fault.remaining -= 1
		error(fault.message)
	end

	function store:GetAsync(key: string): any
		assertKey(key)
		consume("GetAsync")
		return deepCopy(records[key])
	end

	function store:SetAsync(key: string, value: any)
		assertKey(key)
		consume("SetAsync")
		if value == nil then
			error("SetAsync value cannot be nil")
		end
		records[key] = deepCopy(value)
	end

	function store:UpdateAsync(key: string, transform: (any) -> any): any
		assertKey(key)
		consume("UpdateAsync")
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
		consume("RemoveAsync")
		local previous = records[key]
		records[key] = nil
		return deepCopy(previous)
	end

	function store:FailNext(method: string, times: number, message: string)
		faults[method] = {
			remaining = times,
			message = message,
		}
	end

	function store:ThrottleNext(method: string, times: number)
		budget = 0
		faults[method] = {
			remaining = times,
			message = "Request was throttled (429)",
		}
	end

	function store:SetBudget(value: number)
		budget = value
	end

	function store:GetRequestBudget(): number
		return budget
	end

	function store:SeedLock(key: string, jobId: string, expiresAt: number, profile: any)
		assertKey(key)
		records[key] = {
			lockJobId = jobId,
			lockTimestamp = expiresAt,
			lockLeaseSeconds = 0,
			lockExpiresAt = expiresAt,
			profile = deepCopy(profile),
		}
	end

	return store
end

return MockDataStore
