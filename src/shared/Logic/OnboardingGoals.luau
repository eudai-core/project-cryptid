--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Analytics = import("../Config/Analytics", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Analytics")
end)
local BoneAltar = import("../Config/BoneAltar", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("BoneAltar")
end)
local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
end)
local Onboarding = import("../Config/Onboarding", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Onboarding")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)
local NumberFormat = import("./NumberFormat", function()
	return script.Parent:WaitForChild("NumberFormat")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local ProfileQuery = import("./ProfileQuery", function()
	return script.Parent:WaitForChild("ProfileQuery")
end)
local UITheme = import("../UITheme", function()
	return script.Parent.Parent:WaitForChild("UITheme")
end)

local OnboardingGoals = {}

local function moneyPair(cash: number, cost: number): string
	return NumberFormat.formatCash(cash) .. " / " .. NumberFormat.formatCash(cost)
end

local function costButton(cash: number, cost: number, verb: string): (string, boolean)
	if cash + 1e-9 >= cost then
		return verb .. " · " .. NumberFormat.formatCash(cost), true
	end
	local need = Money.round(cost - cash)
	return UITheme.disabledMark .. " Need " .. NumberFormat.formatCash(need) .. " more", false
end

local function goalMet(profile: any, step: number): boolean
	if step == 1 then
		return profile.onboarding.playSeconds >= Onboarding.GOAL_ONE_SECONDS
	elseif step == 2 then
		return ProfileQuery.placedSpecies(profile, Species.RIFT_1_ID, 2)
	elseif step == 3 then
		return ProfileQuery.hasSource(profile, "wild")
	elseif step == 4 then
		return profile.padsUnlocked >= Onboarding.HODAG_PAD and ProfileQuery.wildPlaced(profile)
	elseif step == 5 then
		return profile.upgrades.boneAltar >= 1
	elseif step == 6 then
		return profile.padsUnlocked >= Onboarding.RIFT_2_PAD
	elseif step == 7 then
		return ProfileQuery.placedSpecies(profile, Species.RIFT_2_ID, Onboarding.RIFT_2_PAD)
	end
	return false
end

function OnboardingGoals.advance(profile: any): (boolean, { any })
	local fromStep = profile.onboarding.step
	local changed = false
	local guard = 0
	while profile.onboarding.step < 8 and goalMet(profile, profile.onboarding.step) do
		profile.onboarding.step += 1
		changed = true
		guard += 1
		if guard > 8 then
			break
		end
	end
	local events = Analytics.eventsForTransition(fromStep, profile.onboarding.step, false)
	return changed, events
end

local function baseView(step: number): any
	local headline = Onboarding.HEADLINES[step] or Onboarding.HEADLINES[8]
	return {
		step = step,
		headline = headline,
		progressText = "",
		buttonText = "",
		buttonEnabled = false,
		actionKind = "none",
		actionSlot = 0,
		actionPad = 0,
		actionInstanceId = "",
		showSkip = step < 8,
		showArrow = step < 8,
		guide = "none",
	}
end

local function emptyPad(profile: any, preferred: number): number
	if preferred >= 1 and preferred <= profile.padsUnlocked and ProfileQuery.padAt(profile, preferred) == nil then
		return preferred
	end
	for index = 1, profile.padsUnlocked do
		if ProfileQuery.padAt(profile, index) == nil then
			return index
		end
	end
	return preferred
end

local function setCostAction(
	view: any,
	profile: any,
	kind: string,
	pad: number,
	slot: number,
	cost: number,
	verb: string
)
	view.actionKind = kind
	view.actionPad = pad
	view.actionSlot = slot
	view.progressText = moneyPair(profile.cash, cost)
	local label, enabled = costButton(profile.cash, cost, verb)
	view.buttonText = label
	view.buttonEnabled = enabled
end

function OnboardingGoals.view(profile: any): any
	local step = profile.onboarding.step
	if step > 8 then
		step = 8
	end
	if step < 1 then
		step = 1
	end
	local view = baseView(step)
	if step == 1 then
		view.progressText = Onboarding.STEP_ONE_PROGRESS
		view.guide = "pad:1"
	elseif step == 2 then
		local species = Species.get(Species.RIFT_1_ID)
		local owned = ProfileQuery.instanceOfSpecies(profile, Species.RIFT_1_ID)
		if owned == nil then
			setCostAction(view, profile, "buyRift", 2, 1, species.riftPrice, "Claim")
			view.guide = "rift:1"
		else
			view.progressText = "Bind it to circle 2."
			view.actionKind = "place"
			view.actionPad = 2
			view.actionInstanceId = owned
			view.buttonText = "Bind"
			view.buttonEnabled = ProfileQuery.padAt(profile, 2) == nil
			view.guide = "pad:2"
		end
	elseif step == 3 then
		view.progressText = Onboarding.CATCH_PROGRESS
		view.guide = "wild"
	elseif step == 4 then
		local wildId = ProfileQuery.instanceOfSource(profile, "wild") or ""
		if profile.padsUnlocked < Onboarding.HODAG_PAD then
			local cost = Economy.PAD_COST[Onboarding.HODAG_PAD]
			setCostAction(view, profile, "unlockPad", Onboarding.HODAG_PAD, 0, cost, "Carve")
			view.progressText = Onboarding.BIND_HINT .. "  " .. moneyPair(profile.cash, cost)
			view.guide = "pad:" .. tostring(Onboarding.HODAG_PAD)
		else
			local pad = emptyPad(profile, Onboarding.HODAG_PAD)
			view.progressText = Onboarding.PLACE_PROGRESS
			view.actionKind = "place"
			view.actionInstanceId = wildId
			view.actionPad = pad
			local occupant = ProfileQuery.padAt(profile, pad)
			if occupant == nil and wildId ~= "" then
				view.buttonText = "Bind"
				view.buttonEnabled = true
			else
				view.buttonText = UITheme.disabledMark .. " Need an empty circle"
				view.buttonEnabled = false
			end
			view.guide = "pad:" .. tostring(pad)
		end
	elseif step == 5 then
		local cost = BoneAltar.cost(1, BoneAltar.rebirths(profile)) or Economy.ALTAR_COST[1]
		setCostAction(view, profile, "upgradeAltar", 0, 0, cost, "Raise")
		view.guide = "altar"
	elseif step == 6 then
		local cost = Economy.PAD_COST[Onboarding.RIFT_2_PAD]
		setCostAction(view, profile, "unlockPad", Onboarding.RIFT_2_PAD, 0, cost, "Carve")
		view.guide = "pad:" .. tostring(Onboarding.RIFT_2_PAD)
	elseif step == 7 then
		local species = Species.get(Species.RIFT_2_ID)
		local owned = ProfileQuery.instanceOfSpecies(profile, Species.RIFT_2_ID)
		if owned == nil then
			setCostAction(view, profile, "buyRift", Onboarding.RIFT_2_PAD, 2, species.riftPrice, "Claim")
			if profile.padsUnlocked < Onboarding.RIFT_2_PAD then
				view.progressText = Onboarding.NEEDS_CIRCLE .. "  " .. view.progressText
			end
			view.guide = "rift:2"
		else
			view.progressText = "Bind it to circle " .. tostring(Onboarding.RIFT_2_PAD) .. "."
			view.actionKind = "place"
			view.actionPad = Onboarding.RIFT_2_PAD
			view.actionInstanceId = owned
			view.buttonText = "Bind"
			view.buttonEnabled = ProfileQuery.padAt(profile, Onboarding.RIFT_2_PAD) == nil
			view.guide = "pad:" .. tostring(Onboarding.RIFT_2_PAD)
		end
	else
		view.progressText = moneyPair(profile.cash, Economy.WARD_CANDLES_COST)
		view.actionKind = "none"
		if profile.cash + 1e-9 >= Economy.WARD_CANDLES_COST then
			view.buttonText = Onboarding.WARD_LOCKED_LABEL
			view.buttonEnabled = false
		end
		view.guide = "none"
		view.showArrow = false
		view.showSkip = false
	end
	return view
end

return OnboardingGoals
