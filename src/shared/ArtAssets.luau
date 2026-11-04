--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local CryptidArt = import("./Config/CryptidArt", function()
	return script.Parent:WaitForChild("Config"):WaitForChild("CryptidArt")
end)

local ArtAssets = {}

local function assetsRoot(): Instance?
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return nil
	end
	local replicated = game:GetService("ReplicatedStorage")
	return replicated:FindFirstChild(CryptidArt.folders.assets)
end

function ArtAssets.folder(name: string): Instance?
	local root = assetsRoot()
	if root == nil then
		return nil
	end
	return root:FindFirstChild(name)
end

function ArtAssets.find(folderName: string, modelName: string): Model?
	local folder = ArtAssets.folder(folderName)
	if folder == nil then
		return nil
	end
	local model = folder:FindFirstChild(modelName)
	if model ~= nil and model:IsA("Model") then
		return model
	end
	return nil
end

function ArtAssets.clone(folderName: string, modelName: string): Model?
	local model = ArtAssets.find(folderName, modelName)
	if model == nil then
		return nil
	end
	return model:Clone()
end

return ArtAssets
