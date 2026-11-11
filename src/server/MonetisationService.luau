--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Analytics = require(script.Parent:WaitForChild("Analytics"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetisation = require(Shared:WaitForChild("Config"):WaitForChild("Monetisation"))
local Bundles = require(Shared:WaitForChild("Logic"):WaitForChild("Bundles"))
local Passes = require(Shared:WaitForChild("Logic"):WaitForChild("Passes"))
local Receipts = require(Shared:WaitForChild("Logic"):WaitForChild("Receipts"))
local RelicsPip = require(Shared:WaitForChild("Logic"):WaitForChild("RelicsPip"))
local Schema = require(Shared:WaitForChild("Logic"):WaitForChild("Schema"))
local PolicyWrapper = require(script.Parent:WaitForChild("PolicyWrapper"))

local MonetisationService = {}

local api: any = nil
local ownershipCache: { [string]: boolean } = {}

local function cacheKey(userId: number, passId: number): string
	return tostring(userId) .. ":" .. tostring(passId)
end

local function restore(profile: any, snapshot: any)
	for key in profile do
		profile[key] = nil
	end
	for key, value in snapshot do
		profile[key] = value
	end
end

local function confirmOwned(userId: number, passId: number): boolean?
	local key = cacheKey(userId, passId)
	local known = ownershipCache[key]
	if known ~= nil then
		return known
	end
	local owned = Passes.confirm(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, passId)
	end, function(seconds: number)
		task.wait(seconds)
	end)
	if owned ~= nil then
		ownershipCache[key] = owned
	end
	return owned
end

function MonetisationService.paidRandomAllowed(player: Player): boolean
	return PolicyWrapper.allows(player)
end

local function applyPass(session: any, key: string)
	local before = Schema.deepCopy(session.profile)
	local result = Passes.grant(session.profile, key, api.now(), api.newId())
	if result.changed ~= true then
		return
	end
	if api.save(session) ~= true then
		restore(session.profile, before)
		return
	end
	api.spend(session, 0)
	api.publish(session, result.cash)
end

function MonetisationService.sync(session: any)
	if api == nil or session == nil or session.loaded ~= true or session.alive ~= true then
		return
	end
	for _, entry in Monetisation.items() do
		if entry.kind == "pass" and Monetisation.isLive(entry) then
			local owned = confirmOwned(session.player.UserId, entry.id)
			if owned == true then
				applyPass(session, entry.key)
			end
		end
	end
end

function MonetisationService.onOpen(session: any)
	if api == nil or session == nil or not Monetisation.shopOpen(session.profile) then
		return
	end
	local cleared = RelicsPip.clear(session.profile)
	local quoted = Bundles.lockAll(session.profile, api.now(), Bundles.prePassRate(session.profile))
	if cleared or quoted then
		api.queue(session)
	end
	api.publish(session, 0)
end

function MonetisationService.onBuy(session: any, key: any)
	if api == nil or session == nil or type(key) ~= "string" then
		return
	end
	if not Monetisation.shopOpen(session.profile) then
		return
	end
	local entry = Monetisation.byKey(key)
	if entry == nil or Monetisation.isLive(entry) ~= true then
		return
	end
	if entry.kind == "pass" then
		if Passes.owned(session.profile, key) then
			return
		end
		MarketplaceService:PromptGamePassPurchase(session.player, entry.id)
		return
	end
	if entry.kind ~= "bundle" then
		return
	end
	Bundles.lockQuote(session.profile, key, api.now(), Bundles.prePassRate(session.profile))
	api.queue(session)
	api.publish(session, 0)
	MarketplaceService:PromptProductPurchase(session.player, entry.id)
end

local function onPassFinished(player: Player, passId: number, wasPurchased: boolean)
	if api == nil or wasPurchased ~= true or type(passId) ~= "number" then
		return
	end
	local entry = Monetisation.passById(passId)
	if entry == nil then
		return
	end
	local session = api.sessionFor(player.UserId)
	if session == nil or session.loaded ~= true or session.alive ~= true or session.player.Parent == nil then
		return
	end
	if session.riteBusy == true then
		return
	end
	ownershipCache[cacheKey(player.UserId, passId)] = nil
	if confirmOwned(player.UserId, passId) ~= true then
		return
	end
	applyPass(session, entry.key)
end

local function onReceipt(receipt: any): Enum.ProductPurchaseDecision
	if api == nil or type(receipt) ~= "table" or type(receipt.PlayerId) ~= "number" then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local session = api.sessionFor(receipt.PlayerId)
	if session == nil or session.loaded ~= true or session.alive ~= true or session.player.Parent == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if session.riteBusy == true then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local result = Receipts.process(receipt, session.profile, {
		loaded = true,
		now = api.now,
		rate = Bundles.prePassRate,
		lookup = Monetisation.productById,
		save = function()
			return api.save(session)
		end,
		log = function(message: string)
			warn(message)
		end,
	})
	if result.decision == Receipts.GRANTED and result.fresh == true then
		api.spend(session, result.spent)
		api.publish(session, result.cash)
		pcall(function()
			Analytics.live():purchase(session.player, session, Monetisation.productById(receipt.ProductId))
		end)
	end
	if result.decision == Receipts.GRANTED then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function MonetisationService.start(handlers: any)
	api = handlers
	MarketplaceService.ProcessReceipt = onReceipt
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(onPassFinished)
end

return MonetisationService
