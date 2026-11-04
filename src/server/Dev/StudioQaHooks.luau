--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local QaArgs = require(Shared:WaitForChild("Logic"):WaitForChild("QaArgs"))
local Return = require(Shared:WaitForChild("Config"):WaitForChild("Return"))

local StudioQaHooks = {}

local parsed: any = nil
local startedAt = 0

function StudioQaHooks.args(): any
	if not RunService:IsStudio() then
		return nil
	end
	local ok, args = pcall(function()
		return (game:GetService("StudioTestService") :: any):GetTestArgs()
	end)
	if not ok then
		return nil
	end
	return args
end

local function tokens(): any
	if parsed ~= nil then
		return parsed
	end
	parsed = QaArgs.empty()
	startedAt = os.clock()
	local args = StudioQaHooks.args()
	if type(args) == "string" then
		parsed = QaArgs.parse(args)
	end
	return parsed
end

function StudioQaHooks.rewindLastSeen(profile: any)
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

function StudioQaHooks.sessionReducedMotion(): boolean?
	return QaArgs.reducedMotion(RunService:IsStudio(), StudioQaHooks.args())
end

function StudioQaHooks.unixNow(): number
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

return StudioQaHooks
