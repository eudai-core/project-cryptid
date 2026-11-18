--!strict

-- Binds one prompt per named PromptAnchor. The existing Pedlar prompt is kept.
-- Lookup of a missing part waits on its own task and then gives up.

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local ShopAnchors = import("../Config/ShopAnchors", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("ShopAnchors")
end)

local ShopPrompts = {}

local function walk(root: any, path: { string }, waitSeconds: number): (any?, string)
	local full = table.concat(path, ".")
	local node = root
	for _, name in path do
		if node == nil or type(node.FindFirstChild) ~= "function" then
			return nil, full
		end
		local child = node:FindFirstChild(name)
		if child == nil and type(node.WaitForChild) == "function" then
			child = node:WaitForChild(name, waitSeconds)
		end
		if child == nil then
			return nil, full
		end
		node = child
	end
	return node, full
end

local function shopIdOk(node: any, shopId: string): boolean
	if node == nil or type(node.GetAttribute) ~= "function" then
		return true
	end
	local marked = node:GetAttribute("ShopId")
	if marked == nil then
		return true
	end
	return marked == shopId
end

local function existingPrompt(node: any, findPrompt: ((any) -> any)?): any
	if findPrompt ~= nil then
		return findPrompt(node)
	end
	if node ~= nil and type(node.FindFirstChildWhichIsA) == "function" then
		return node:FindFirstChildWhichIsA("ProximityPrompt")
	end
	return nil
end

local function bindOne(town: any, entry: any, deps: any)
	local waitSeconds = deps.waitSeconds
	if type(waitSeconds) ~= "number" then
		waitSeconds = ShopAnchors.WAIT_SECONDS
	end
	local function missing(path: string)
		if deps.onMissing ~= nil then
			deps.onMissing(entry.shopId, path)
		end
	end
	local function ready(host: any, created: boolean)
		if deps.onReady ~= nil then
			deps.onReady(entry.shopId, host, created)
		end
	end
	if entry.mode == "pedlar" then
		local prompt = walk(town, entry.promptPath, waitSeconds)
		if prompt ~= nil then
			local host = prompt.Parent
			if host == nil then
				host = prompt
			end
			ready(host, false)
			return
		end
		local anchor, anchorPath = walk(town, entry.fallbackPath, waitSeconds)
		if anchor == nil then
			missing(anchorPath)
			return
		end
		if not shopIdOk(anchor, entry.shopId) then
			missing(anchorPath)
			return
		end
		if existingPrompt(anchor, deps.findPrompt) ~= nil then
			ready(anchor, false)
			return
		end
		deps.createPrompt(anchor, entry)
		ready(anchor, true)
		return
	end
	local anchor, path = walk(town, entry.anchorPath, waitSeconds)
	if anchor == nil or not shopIdOk(anchor, entry.shopId) then
		missing(path)
		return
	end
	if existingPrompt(anchor, deps.findPrompt) ~= nil then
		ready(anchor, false)
		return
	end
	deps.createPrompt(anchor, entry)
	ready(anchor, true)
end

function ShopPrompts.bind(town: any, deps: any)
	local spawnFn = if deps ~= nil then deps.spawn else nil
	for _, entry in ShopAnchors.list() do
		local function run()
			bindOne(town, entry, deps)
		end
		if spawnFn ~= nil then
			spawnFn(run)
		else
			run()
		end
	end
end

return ShopPrompts
