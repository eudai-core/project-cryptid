--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
end)
local Return = import("../Config/Return", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Return")
end)
local Shop = import("../Config/Shop", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Shop")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local Daily = import("./Daily", function()
	return script.Parent:WaitForChild("Daily")
end)
local Income = import("./Income", function()
	return script.Parent:WaitForChild("Income")
end)
local OnboardingGoals = import("./OnboardingGoals", function()
	return script.Parent:WaitForChild("OnboardingGoals")
end)
local ProfileQuery = import("./ProfileQuery", function()
	return script.Parent:WaitForChild("ProfileQuery")
end)
local StealGuard = import("./StealGuard", function()
	return script.Parent:WaitForChild("StealGuard")
end)
local Transactions = import("./Transactions", function()
	return script.Parent:WaitForChild("Transactions")
end)

local Snapshot = {}

function Snapshot.build(profile: any, lastCredit: number, revision: number, view: any?): any
	local goal = OnboardingGoals.view(profile)
	local pads = {}
	for index = 1, Economy.MAX_PADS do
		local cost = Economy.PAD_COST[index] or 0
		local instanceId = ProfileQuery.padAt(profile, index)
		local entry = {
			index = index,
			state = "locked",
			displayName = "",
			income = 0,
			cost = cost,
			affordable = false,
			instanceId = "",
		}
		if index > profile.padsUnlocked then
			entry.affordable = index == profile.padsUnlocked + 1 and profile.cash + 1e-9 >= cost
		elseif instanceId == nil then
			entry.state = "empty"
		else
			local record = profile.cryptids[instanceId]
			local species = if record ~= nil then Species.get(record.speciesId) else nil
			entry.state = "occupied"
			entry.instanceId = instanceId
			entry.displayName = if species ~= nil then species.displayName else ""
			entry.income = if record ~= nil
				then Income.contribution(record.speciesId, profile.upgrades.boneAltar)
				else 0
		end
		table.insert(pads, entry)
	end

	local placed = {}
	for index = 1, Economy.MAX_PADS do
		local instanceId = ProfileQuery.padAt(profile, index)
		if instanceId ~= nil then
			placed[instanceId] = true
		end
	end
	local inventory = {}
	for instanceId, record in profile.cryptids do
		if placed[instanceId] ~= true then
			local species = Species.get(record.speciesId)
			table.insert(inventory, {
				instanceId = instanceId,
				speciesId = record.speciesId,
				displayName = if species ~= nil then species.displayName else record.speciesId,
				source = record.source,
			})
		end
	end
	table.sort(inventory, function(a, b)
		return a.instanceId < b.instanceId
	end)

	local pedlarBought = {}
	for slot = 1, Shop.SLOT_COUNT do
		pedlarBought[slot] = profile.shop.boughtSlots[slot] == true
	end

	local viewNow = 0
	local autoOpen = false
	if type(view) == "table" then
		if type(view.now) == "number" then
			viewNow = view.now
		end
		autoOpen = view.dailyAutoOpen == true
	end
	local rate = Income.perSecond(profile)
	local steps = {}
	for index = 1, Return.LADDER_STEPS do
		local preview = Daily.preview(index, rate)
		if preview ~= nil then
			table.insert(steps, preview)
		end
	end
	local pending = profile.offline.pending
	if type(pending) ~= "number" then
		pending = 0
	end
	local awaySeconds = profile.offline.awaySeconds
	if type(awaySeconds) ~= "number" then
		awaySeconds = 0
	end

	local rift = {}
	for _, offer in Transactions.currentOffers(profile) do
		local species = Species.get(offer.speciesId)
		table.insert(rift, {
			slot = offer.slot,
			speciesId = offer.speciesId,
			displayName = if species ~= nil then species.displayName else offer.speciesId,
			price = offer.price,
		})
	end

	return {
		revision = revision,
		cash = profile.cash,
		incomePerSecond = Income.perSecond(profile),
		lastCredit = lastCredit,
		reducedMotion = profile.settings.reducedMotion,
		padsUnlocked = profile.padsUnlocked,
		boneAltar = profile.upgrades.boneAltar,
		pads = pads,
		inventory = inventory,
		rift = rift,
		goal = goal,
		guide = goal.guide,
		stealProtected = StealGuard.isProtected(profile),
		pedlar = {
			lastRotationId = profile.shop.lastRotationId,
			boughtSlots = pedlarBought,
			bindAtOnce = profile.settings.bindAtOnce == true,
		},
		bowl = profile.bowl,
		settings = {
			sfx = profile.settings.sfx,
			music = profile.settings.music,
			effectsQuality = profile.settings.effectsQuality,
			reducedMotion = profile.settings.reducedMotion == true,
		},
		haul = {
			pending = pending,
			awaySeconds = awaySeconds,
			capped = profile.offline.capped == true,
			show = pending >= Return.SCREEN_MIN_HAUL and awaySeconds >= Return.SCREEN_AWAY_SECONDS,
		},
		daily = {
			step = profile.daily.step,
			lastClaimDay = profile.daily.lastClaimDay,
			totalClaims = profile.daily.totalClaims,
			ready = Daily.ready(profile, viewNow),
			missed = Daily.missed(profile, viewNow),
			nextDailyUnix = Daily.nextReset(viewNow),
			serverNow = viewNow,
			button = Daily.offerButton(profile),
			autoOpen = autoOpen,
			progress = profile.daily.step,
			steps = steps,
		},
	}
end

return Snapshot
