--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local BoneAltar = import("../Config/BoneAltar", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("BoneAltar")
end)
local Monetisation = import("../Config/Monetisation", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Monetisation")
end)
local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
end)
local Onboarding = import("../Config/Onboarding", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Onboarding")
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
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local Ownership = import("./Ownership", function()
	return script.Parent:WaitForChild("Ownership")
end)
local Rebirth = import("./Rebirth", function()
	return script.Parent:WaitForChild("Rebirth")
end)
local SkillEffects = import("./SkillEffects", function()
	return script.Parent:WaitForChild("SkillEffects")
end)
local OnboardingGoals = import("./OnboardingGoals", function()
	return script.Parent:WaitForChild("OnboardingGoals")
end)
local ProfileQuery = import("./ProfileQuery", function()
	return script.Parent:WaitForChild("ProfileQuery")
end)
local RelicsView = import("./RelicsView", function()
	return script.Parent:WaitForChild("RelicsView")
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
	local layers = Ownership.layers(profile)
	local rebirth = layers.rebirth
	local pass = layers.cashPass
	local pads = {}
	for index = 1, Economy.MAX_PADS do
		local priced = SkillEffects.padCost(profile, index)
		local cost = if type(priced) == "number" then priced else 0
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
		if Monetisation.relicLocked(profile, index) then
			entry.state = "sealed"
			entry.cost = 0
			entry.affordable = false
		elseif index > profile.padsUnlocked then
			entry.affordable = index == profile.padsUnlocked + 1
				and type(priced) == "number"
				and profile.cash + 1e-9 >= cost
		elseif instanceId == nil then
			entry.state = "empty"
		else
			local record = profile.cryptids[instanceId]
			local species = if record ~= nil then Species.get(record.speciesId) else nil
			entry.state = "occupied"
			entry.instanceId = instanceId
			entry.displayName = if species ~= nil then species.displayName else ""
			entry.income = if record ~= nil
				then Money.round(
					Income.contribution(
						record.speciesId,
						profile.upgrades.boneAltar,
						BoneAltar.l3Owned(profile),
						SkillEffects.skillIncome(profile)
							+ if record.source == "wild" then SkillEffects.wildIncome(profile) else 0
					)
						* rebirth
						* pass
				)
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

	local skills = {}
	if type(profile.skills) == "table" then
		for index = 1, #profile.skills do
			local id = profile.skills[index]
			if type(id) == "string" then
				table.insert(skills, id)
			end
		end
	end

	local pedlarBought = {}
	for slot = 1, Shop.SLOT_COUNT do
		pedlarBought[slot] = profile.shop.boughtSlots[slot] == true
	end

	local viewNow = 0
	local autoOpen = false
	local relicsBought = 0
	local relicsSpent = 0
	local silentNotice = profile.offline.notice
	if type(silentNotice) ~= "number" or silentNotice < 0 then
		silentNotice = 0
	end
	if type(view) == "table" then
		if type(view.now) == "number" then
			viewNow = view.now
		end
		autoOpen = view.dailyAutoOpen == true
		if type(view.silentNotice) == "number" and view.silentNotice >= 0 then
			silentNotice = view.silentNotice
		end
		if type(view.relicsBought) == "number" and view.relicsBought >= 0 then
			relicsBought = view.relicsBought
		end
		if type(view.relicsSpent) == "number" and view.relicsSpent >= 0 then
			relicsSpent = view.relicsSpent
		end
	end
	local rate = Money.round(Income.perSecond(profile) * rebirth)
	local rite = Rebirth.view(profile)
	rite.noticeSerial = 0
	rite.noticeText = ""
	if type(view) == "table" then
		if type(view.rebirthNotice) == "number" and view.rebirthNotice >= 0 then
			rite.noticeSerial = math.floor(view.rebirthNotice)
		end
		if type(view.rebirthText) == "string" then
			rite.noticeText = view.rebirthText
		end
	end
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
		local needsCircle = offer.pad > profile.padsUnlocked
		table.insert(rift, {
			slot = offer.slot,
			speciesId = offer.speciesId,
			displayName = if species ~= nil then species.displayName else offer.speciesId,
			price = offer.price,
			needsCircle = needsCircle,
			hint = if needsCircle then Onboarding.NEEDS_CIRCLE else "",
		})
	end
	local reveal = nil
	local revealSerial = 0
	if type(view) == "table" and type(view.revealSerial) == "number" and view.revealSerial > 0 then
		revealSerial = math.floor(view.revealSerial)
	end
	if revealSerial > 0 then
		local wild = Species.get(Species.WILD_ID)
		reveal = {
			token = revealSerial,
			speciesName = if wild ~= nil then wild.displayName else "",
			rarity = if wild ~= nil then wild.rarity else "Common",
			line = Onboarding.TEASE_LINE,
			pips = Onboarding.TEASE_PIPS,
			revealSeconds = Onboarding.REVEAL_SECONDS,
			fadeIn = Onboarding.TEASE_FADE_IN,
			hold = Onboarding.TEASE_HOLD,
			fadeOut = Onboarding.TEASE_FADE_OUT,
		}
	end

	return {
		revision = revision,
		cash = profile.cash,
		incomePerSecond = Money.round(rate * pass),
		rebirth = rite,
		lastCredit = lastCredit,
		reducedMotion = profile.settings.reducedMotion,
		padsUnlocked = profile.padsUnlocked,
		boneAltar = profile.upgrades.boneAltar,
		pads = pads,
		inventory = inventory,
		rift = rift,
		goal = goal,
		guide = goal.guide,
		reveal = reveal,
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
			notice = silentNotice,
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
		skills = skills,
		relics = RelicsView.build(profile, viewNow, relicsBought, relicsSpent),
	}
end

return Snapshot
