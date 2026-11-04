--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopRoll = require(script.Parent:WaitForChild("ShopRoll"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Shop = require(Shared:WaitForChild("Config"):WaitForChild("Shop")) :: any
local ShopStock = require(Shared:WaitForChild("Logic"):WaitForChild("ShopStock")) :: any

local cached: any = nil
local glowToken = 0

local Pedlar = {}

local function stockGlow(): ParticleEmitter?
	local tagged = CollectionService:GetTagged("PedlarLantern")
	local host = tagged[1]
	if host == nil then
		return nil
	end
	local emitter = host:FindFirstChild("StockGlow")
	if emitter == nil or not emitter:IsA("ParticleEmitter") then
		return nil
	end
	return emitter
end

local function glow()
	local emitter = stockGlow()
	if emitter == nil then
		return
	end
	glowToken += 1
	local token = glowToken
	emitter.Enabled = true
	task.delay(Shop.GLOW_SECONDS, function()
		if token ~= glowToken or emitter.Parent == nil then
			return
		end
		emitter.Enabled = false
	end)
end

local function publish(board: StringValue, glowNow: boolean)
	local now = os.time()
	local rotationId = ShopStock.rotationId(now)
	local rolled = ShopRoll.generate(rotationId)
	for _, warning in rolled.warnings do
		warn(warning)
	end
	cached = rolled.bySlot
	local offers = {}
	for _, offer in rolled.offers do
		table.insert(offers, {
			slot = offer.slot,
			slotName = offer.slotName,
			speciesId = offer.speciesId,
			displayName = offer.displayName,
			rarity = offer.rarity,
			price = offer.price,
		})
	end
	board.Value = HttpService:JSONEncode({
		rotationId = rotationId,
		nextRestockUnix = ShopStock.nextRestockUnix(now),
		offers = offers,
	})
	if glowNow then
		glow()
	end
end

function Pedlar.offers(): any
	return cached
end

local function bindBrowse(onBrowse: (Player) -> ())
	local function bind(prompt: ProximityPrompt)
		if prompt:GetAttribute("AnalyticsBound") == true then
			return
		end
		if prompt.ActionText ~= Shop.PROMPT then
			return
		end
		prompt:SetAttribute("AnalyticsBound", true)
		prompt.Triggered:Connect(function(player)
			onBrowse(player)
		end)
	end
	for _, model in CollectionService:GetTagged("PedlarStall") do
		for _, desc in model:GetDescendants() do
			if desc:IsA("ProximityPrompt") then
				bind(desc)
			end
		end
	end
end

function Pedlar.start(onRotation: () -> (), onBrowse: ((Player) -> ())?)
	local existing = ReplicatedStorage:FindFirstChild("PedlarBoard")
	local board: StringValue
	if existing ~= nil and existing:IsA("StringValue") then
		board = existing
	else
		board = Instance.new("StringValue")
		board.Name = "PedlarBoard"
		board.Parent = ReplicatedStorage
	end
	publish(board, false)
	if onBrowse ~= nil then
		bindBrowse(onBrowse)
	end
	onRotation()
	task.spawn(function()
		local seen = ShopStock.rotationId(os.time())
		while board.Parent ~= nil do
			task.wait(Shop.RESTOCK_POLL_SECONDS)
			local rotationId = ShopStock.rotationId(os.time())
			if rotationId ~= seen then
				seen = rotationId
				publish(board, true)
				onRotation()
			end
		end
	end)
end

return Pedlar
