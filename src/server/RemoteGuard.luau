--!strict

local RateLimiter = require(script.Parent:WaitForChild("RateLimiter"))

local RemoteGuard = {}

-- The bucket is checked before the handler, so a dropped call never reaches
-- argument checks or profile writes.
local function admit(player: Player, remoteName: string): boolean
	local decision = RateLimiter.consume(player.UserId, remoteName, os.clock())
	return decision.allowed
end

function RemoteGuard.bindEvent(remote: RemoteEvent, handler: (Player, ...any) -> ())
	remote.OnServerEvent:Connect(function(player: Player, ...: any)
		if not admit(player, remote.Name) then
			return
		end
		handler(player, ...)
	end)
end

function RemoteGuard.bindFunction(remote: RemoteFunction, handler: (Player, ...any) -> ...any)
	remote.OnServerInvoke = function(player: Player, ...: any): ...any
		if not admit(player, remote.Name) then
			return RateLimiter.rejected()
		end
		return handler(player, ...)
	end
end

return RemoteGuard
