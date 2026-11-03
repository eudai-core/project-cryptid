--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopRoll = require(script.Parent:WaitForChild("ShopRoll"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Shop = require(Shared:WaitForChild("Config"):WaitForChild("Shop")) :: any
local ShopStock = require(Shared:WaitForChild("Logic"):WaitForChild("ShopStock")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local cached: any = nil
local glowToken = 0

local Pedlar = {}

local function lanternLight(): PointLight?
	local tagged = CollectionService:GetTagged("PedlarLantern")
	local host = tagged[1]
	if host == nil then
		return nil
	end
	local light = host:FindFirstChildOfClass("PointLight")
	if light == nil then
		return nil
	end
	return light
end

local function glow()
	local light = lanternLight()
	if light == nil then
		return
	end
	glowToken += 1
	local token = glowToken
	light.Color = UITheme.color("Rift")
	task.delay(Shop.GLOW_SECONDS, function()
		if token ~= glowToken or light.Parent == nil then
			return
		end
		light.Color = UITheme.color("Candle")
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

function Pedlar.start(onRotation: () -> ())
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
