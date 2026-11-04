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
local Shop = import("../Config/Shop", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Shop")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local Income = import("./Income", function()
	return script.Parent:WaitForChild("Income")
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
local StealGuard = import("./StealGuard", function()
	return script.Parent:WaitForChild("StealGuard")
end)
local Transactions = import("./Transactions", function()
	return script.Parent:WaitForChild("Transactions")
end)

local Snapshot = {}

function Snapshot.build(profile: any, lastCredit: number, revision: number): any
	local goal = OnboardingGoals.view(profile)
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
				then Income.contribution(
					record.speciesId,
					profile.upgrades.boneAltar,
					SkillEffects.altarPerLevel(profile),
					SkillEffects.skillIncome(profile)
						+ if record.source == "wild" then SkillEffects.wildIncome(profile) else 0
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
		skills = skills,
	}
end

return Snapshot
