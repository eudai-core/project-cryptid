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

function MockDataStore.newOrdered(): any
	local records: { [string]: number } = {}
	local store = {}

	local function assertScore(value: any)
		if type(value) ~= "number" or value ~= math.floor(value) or value ~= value or math.abs(value) == math.huge then
			error("OrderedDataStore value must be an integer")
		end
	end

	function store:GetAsync(key: string): number?
		assertKey(key)
		return records[key]
	end

	function store:SetAsync(key: string, value: number)
		assertKey(key)
		assertScore(value)
		records[key] = value
	end

	function store:UpdateAsync(key: string, transform: (number?) -> number?): number?
		assertKey(key)
		if type(transform) ~= "function" then
			error("UpdateAsync transform must be a function")
		end
		local updated = transform(records[key])
		if updated == nil then
			return nil
		end
		assertScore(updated)
		records[key] = updated
		return updated
	end

	function store:GetSortedAsync(ascending: boolean, pageSize: number, minValue: number?, maxValue: number?): any
		if type(pageSize) ~= "number" or pageSize ~= math.floor(pageSize) or pageSize < 1 then
			error("pageSize must be a positive integer")
		end
		local rows = {}
		for key, value in records do
			if (minValue == nil or value >= minValue) and (maxValue == nil or value <= maxValue) then
				table.insert(rows, { key = key, value = value })
			end
		end
		table.sort(rows, function(left, right)
			if left.value == right.value then
				return left.key < right.key
			end
			if ascending == true then
				return left.value < right.value
			end
			return left.value > right.value
		end)
		local page = {}
		local shown = math.min(pageSize, #rows)
		for index = 1, shown do
			page[index] = { key = rows[index].key, value = rows[index].value }
		end
		local pages = {}
		function pages.GetCurrentPage(): { any }
			local copy = {}
			for index, entry in page do
				copy[index] = { key = entry.key, value = entry.value }
			end
			return copy
		end
		function pages.IsFinished(): boolean
			return shown >= #rows
		end
		return pages
	end

	return store
end

return MockDataStore
