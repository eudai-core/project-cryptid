--!strict

local SaveHooks = {}

local listeners: { any } = {}

function SaveHooks.connect(listener: (number, any, string) -> ()): () -> ()
	table.insert(listeners, listener)
	return function()
		local index = table.find(listeners, listener)
		if index ~= nil then
			table.remove(listeners, index)
		end
	end
end

function SaveHooks.fire(userId: number, profile: any, reason: string)
	for _, listener in listeners do
		local ok, err = pcall(listener, userId, profile, reason)
		if not ok then
			warn("[Cryptid:DataStore] save hook failed: " .. tostring(err))
		end
	end
end

return SaveHooks
