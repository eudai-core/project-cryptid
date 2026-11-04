--!strict

-- Studio-only clock and lastSeen tweaks for spec 06 QA.
-- Armed only when the playtest args start with `qa:` and RunService:IsStudio()
-- is true. A published server ignores the args. There is no remote for this.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local QaArgs = require(Shared:WaitForChild("Logic"):WaitForChild("QaArgs"))
local Return = require(Shared:WaitForChild("Config"):WaitForChild("Return"))

local StudioQa = {}

local parsed: any = nil
local startedAt = 0

local function tokens(): any
	if parsed ~= nil then
		return parsed
	end
	parsed = QaArgs.empty()
	startedAt = os.clock()
	if not RunService:IsStudio() then
		return parsed
	end
	local StudioTestService = game:GetService("StudioTestService") :: any
	local ok, args = pcall(function()
		return StudioTestService:GetTestArgs()
	end)
	if ok then
		parsed = QaArgs.parse(args)
	end
	return parsed
end

function StudioQa.rewindLastSeen(profile: any)
	if not RunService:IsStudio() or type(profile) ~= "table" then
		return
	end
	local shift = tokens().offlineSeconds
	if type(shift) ~= "number" or shift <= 0 then
		return
	end
	local seen = profile.lastSeenUnix
	if type(seen) ~= "number" then
		seen = 0
	end
	local rewound = seen - shift
	if rewound < 0 then
		rewound = 0
	end
	profile.lastSeenUnix = rewound
end

function StudioQa.unixNow(): number
	local now = os.time()
	if not RunService:IsStudio() then
		return now
	end
	local spec = tokens()
	local days = spec.utcDays
	if type(days) ~= "number" then
		days = 0
	end
	local jump = spec.utcJumpSeconds
	if type(jump) == "number" and jump > 0 and os.clock() - startedAt >= jump then
		days += 1
	end
	return now + days * Return.DAY_SECONDS
end

return StudioQa
