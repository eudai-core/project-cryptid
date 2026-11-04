--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Names = require(Shared:WaitForChild("Config"):WaitForChild("Remotes")) :: any

local Remotes = {}

function Remotes.create(): Folder
	local existing = ReplicatedStorage:FindFirstChild(Names.FOLDER)
	if existing ~= nil and existing:IsA("Folder") then
		return existing
	end
	local folder = Instance.new("Folder")
	folder.Name = Names.FOLDER
	local names = {
		Names.BUY_RIFT,
		Names.UNLOCK_PAD,
		Names.UPGRADE,
		Names.PLACE,
		Names.SKIP,
		Names.BEGIN_CATCH,
		Names.COMPLETE_CATCH,
		Names.REDUCED_MOTION,
		Names.RETURN_TO_LAIR,
		Names.PEDLAR_BUY,
		Names.BIND_AT_ONCE,
		Names.CLAIM_HAUL,
		Names.CLAIM_DAILY,
		Names.SET_SETTINGS,
	}
	for _, name in names do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	folder.Parent = ReplicatedStorage
	return folder
end

function Remotes.get(folder: Folder, name: string): RemoteEvent
	local remote = folder:WaitForChild(name)
	assert(remote:IsA("RemoteEvent"), name)
	return remote
end

return Remotes
