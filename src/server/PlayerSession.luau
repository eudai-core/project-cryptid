--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Analytics = require(script.Parent:WaitForChild("Analytics"))
local DataStoreGateway = require(script.Parent:WaitForChild("DataStoreGateway"))
local StudioQa = require(script.Parent:WaitForChild("Dev"):WaitForChild("StudioQa"))
local StudioQaHooks = require(script.Parent:WaitForChild("Dev"):WaitForChild("StudioQaHooks"))
local Pedlar = require(script.Parent:WaitForChild("Pedlar"))
local QaGrant = require(script.Parent:WaitForChild("Dev"):WaitForChild("QaGrant"))
local MonetisationService = require(script.Parent:WaitForChild("MonetisationService"))
local Plot = require(script.Parent:WaitForChild("Plot"))
local RateLimiter = require(script.Parent:WaitForChild("RateLimiter"))
local RemoteGuard = require(script.Parent:WaitForChild("RemoteGuard"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))
local Debounce = require(Shared:WaitForChild("Logic"):WaitForChild("Debounce")) :: any
local Economy = require(Shared:WaitForChild("Config"):WaitForChild("Economy")) :: any
local Onboarding = require(Shared:WaitForChild("Config"):WaitForChild("Onboarding")) :: any
local Lair = require(Shared:WaitForChild("Config"):WaitForChild("Lair")) :: any
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local Names = require(Shared:WaitForChild("Config"):WaitForChild("Remotes")) :: any
local ProfileQuery = require(Shared:WaitForChild("Logic"):WaitForChild("ProfileQuery")) :: any
local Shop = require(Shared:WaitForChild("Config"):WaitForChild("Shop")) :: any
local ShopStock = require(Shared:WaitForChild("Logic"):WaitForChild("ShopStock")) :: any
local Town = require(Shared:WaitForChild("Config"):WaitForChild("Town")) :: any
local RemoteArgs = require(Shared:WaitForChild("Logic"):WaitForChild("RemoteArgs")) :: any
local Autosave = require(Shared:WaitForChild("Logic"):WaitForChild("Autosave")) :: any
local Bowl = require(Shared:WaitForChild("Logic"):WaitForChild("Bowl")) :: any
local Daily = require(Shared:WaitForChild("Logic"):WaitForChild("Daily")) :: any
local Offline = require(Shared:WaitForChild("Logic"):WaitForChild("Offline")) :: any
local Ownership = require(Shared:WaitForChild("Logic"):WaitForChild("Ownership")) :: any
local SessionClose = require(Shared:WaitForChild("Logic"):WaitForChild("SessionClose")) :: any
local Settings = require(Shared:WaitForChild("Logic"):WaitForChild("Settings")) :: any
local Save = require(Shared:WaitForChild("Config"):WaitForChild("Save")) :: any
local Schema = require(Shared:WaitForChild("Logic"):WaitForChild("Schema")) :: any
local SkillConfig = require(Shared:WaitForChild("Config"):WaitForChild("SkillConfig")) :: any
local SkillEffects = require(script.Parent:WaitForChild("SkillEffects")) :: any
local SkillTree = require(Shared:WaitForChild("Logic"):WaitForChild("SkillTree")) :: any
local ShutdownFlush = require(Shared:WaitForChild("Logic"):WaitForChild("ShutdownFlush")) :: any
local Snapshot = require(Shared:WaitForChild("Logic"):WaitForChild("Snapshot")) :: any
local StealGuard = require(Shared:WaitForChild("Logic"):WaitForChild("StealGuard")) :: any
local Rebirth = require(Shared:WaitForChild("Logic"):WaitForChild("Rebirth")) :: any
local RebirthRules = require(Shared:WaitForChild("Config"):WaitForChild("Rebirth")) :: any
local TitheLedger = require(script.Parent:WaitForChild("TitheLedger"))
local Transactions = require(Shared:WaitForChild("Logic"):WaitForChild("Transactions")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local sessions: { [Player]: any } = {}
local detaching: { [Player]: any } = {}
local activeTally: { saved: number, released: number }? = nil
local analytics: any = nil

local PlayerSession = {}

local function sink(): any
	if analytics == nil then
		analytics = Analytics.live()
	end
	return analytics
end

local function distanceTo(player: Player, part: BasePart?): number?
	if part == nil then
		return nil
	end
	local character = player.Character
	if character == nil then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return nil
	end
	return (root.Position - part.Position).Magnitude
end

local function findLantern(player: Player): Tool?
	local character = player.Character
	if character ~= nil then
		local equipped = character:FindFirstChild(Economy.TOOL_NAME)
		if equipped ~= nil and equipped:IsA("Tool") then
			return equipped
		end
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack ~= nil then
		local stored = backpack:FindFirstChild(Economy.TOOL_NAME)
		if stored ~= nil and stored:IsA("Tool") then
			return stored
		end
	end
	local starter = player:FindFirstChild("StarterGear")
	if starter ~= nil then
		local gear = starter:FindFirstChild(Economy.TOOL_NAME)
		if gear ~= nil and gear:IsA("Tool") then
			return gear
		end
	end
	return nil
end

local function makeLantern(): Tool
	local tool = Instance.new("Tool")
	tool.Name = Economy.TOOL_NAME
	tool.ToolTip = "Lantern"
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.35, 1.5, 0.35)
	handle.Color = UITheme.color("Gold")
	handle.Material = Enum.Material[UITheme.materials.lantern]
	handle.Parent = tool
	local cage = Instance.new("Part")
	cage.Name = "Cage"
	cage.Size = Vector3.new(0.7, 0.7, 0.7)
	cage.Color = UITheme.color("BoneDim")
	cage.Material = Enum.Material.Metal
	cage.CanCollide = false
	cage.Massless = true
	cage.Parent = tool
	local weld = Instance.new("Weld")
	weld.Part0 = handle
	weld.Part1 = cage
	weld.C0 = CFrame.new(0, 0.9, 0)
	weld.Parent = handle
	handle.CanCollide = false
	local light = Instance.new("PointLight")
	light.Color = UITheme.color("Candle")
	light.Range = Lair.CANDLE_RANGE
	light.Brightness = Lair.CANDLE_BRIGHTNESS
	light.Parent = cage
	return tool
end

local function syncLantern(session: any)
	if session.profile.onboarding.step < Onboarding.CATCH_STEP then
		return
	end
	local player = session.player
	if player:FindFirstChild("StarterGear") == nil then
		return
	end
	if findLantern(player) ~= nil then
		return
	end
	local tool = makeLantern()
	tool.Parent = player:FindFirstChild("StarterGear")
	local copy = tool:Clone()
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack ~= nil then
		copy.Parent = backpack
		local character = player.Character
		local humanoid = if character ~= nil then character:FindFirstChildOfClass("Humanoid") else nil
		if humanoid ~= nil then
			humanoid:EquipTool(copy)
		end
	end
end

local function publish(session: any, credit: number)
	session.revision += 1
	local profile = session.profile
	if Rebirth.noteBalance(profile) then
		session.dirty = true
	end
	local _, cashRate = Ownership.leaveRates(profile)
	local offeringNow = StudioQaHooks.unixNow()
	local snap = Snapshot.build(profile, credit, session.revision, {
		now = offeringNow,
		dailyAutoOpen = session.dailyAutoOpen == true,
		silentNotice = session.silentNotice or 0,
		revealSerial = session.revealSerial or 0,
		relicsBought = session.relicsBought or 0,
		relicsSpent = session.relicsSpent or 0,
		rebirthNotice = session.rebirthNotice or 0,
		rebirthText = session.rebirthText or "",
	})
	local player = session.player
	TitheLedger.note(player, profile.tithe)
	player:SetAttribute("Cash", profile.cash)
	player:SetAttribute("IncomePerSecond", cashRate)
	player:SetAttribute("CatchSeconds", SkillEffects.catchSeconds(profile))
	player:SetAttribute("CatchStuds", SkillEffects.catchRange(profile))
	player:SetAttribute("SkillIncome", SkillEffects.skillIncome(profile))
	player:SetAttribute("AltarPerLevel", SkillEffects.altarPerLevel(profile))
	player:SetAttribute("LastCredit", credit)
	local reducedMotion = profile.settings.reducedMotion == true
	local motionOverride = StudioQaHooks.sessionReducedMotion()
	if motionOverride ~= nil then
		reducedMotion = motionOverride
	end
	player:SetAttribute("ReducedMotion", reducedMotion)
	player:SetAttribute("OnboardingStep", profile.onboarding.step)
	player:SetAttribute("StealProtected", StealGuard.isProtected(profile))
	player:SetAttribute("Bowl", profile.bowl)
	player:SetAttribute("Sfx", profile.settings.sfx)
	player:SetAttribute("Music", profile.settings.music)
	player:SetAttribute("EffectsQuality", profile.settings.effectsQuality)
	player:SetAttribute("NextDailyUnix", Daily.nextReset(offeringNow))
	session.snapshot.Value = HttpService:JSONEncode(snap)
	player:SetAttribute("StateRevision", session.revision)
	Plot.sync(session.plot, profile, session.guide)
	syncLantern(session)
end

local performSave: (any) -> (boolean, string)
local queueSave: (any) -> ()

local function stampOnline(session: any)
	Offline.capture(session.profile)
	session.profile.lastSeenUnix = os.time()
end

local function settleDeparture(session: any)
	sink().noteIncome(session, Bowl.bank(session.profile))
	stampOnline(session)
	session.dirty = true
end

performSave = function(session: any): (boolean, string)
	if
		session.ephemeral
		or session.loaded ~= true
		or session.leaving
		or not session.alive
		or session.player.Parent == nil
	then
		return false, "skipped"
	end
	stampOnline(session)
	session.saveBusy = true
	session.dirty = false
	session.lastSaveAt = os.clock()
	local marked = session.rebirthWrite == true
	local ok, status = DataStoreGateway.save(session.player.UserId, session.profile, marked)
	session.saveBusy = false
	if ok then
		session.rebirthWrite = false
		session.lockExpiresAt = os.time() + Save.LOCK_TTL_SECONDS
		if session.dirty and session.alive then
			queueSave(session)
		end
		return true, status
	end
	if status == "lost" and session.alive then
		session.alive = false
		session.player:Kick(Save.KICK_LOCKED)
		return false, status
	end
	if status == "wipe" or status == "downgrade" or status == "unloaded" then
		return false, status
	end
	session.dirty = true
	if session.alive then
		queueSave(session)
	end
	return false, status
end

queueSave = function(session: any)
	session.dirty = true
	if session.ephemeral or session.loaded ~= true or session.leaving or not session.alive then
		return
	end
	if session.saveBusy then
		return
	end
	local now = os.clock()
	if now - session.lastSaveAt < Save.PURCHASE_SAVE_THROTTLE_SECONDS then
		if not session.saveScheduled then
			session.saveScheduled = true
			task.delay(Save.PURCHASE_SAVE_THROTTLE_SECONDS, function()
				session.saveScheduled = false
				if session.dirty and session.alive then
					queueSave(session)
				end
			end)
		end
		return
	end
	task.spawn(performSave, session)
end

local function onCadence(session: any)
	if session.ephemeral or session.loaded ~= true or session.leaving or not session.alive or session.saveBusy then
		return
	end
	Autosave.apply(session.dirty == true, session.lockExpiresAt, os.time(), {
		save = function()
			sink().flushIncome(session.player, session, os.clock(), false)
			return performSave(session)
		end,
		renew = function()
			local ok, status, expiresAt = DataStoreGateway.renew(session.player.UserId)
			if ok and type(expiresAt) == "number" then
				session.lockExpiresAt = expiresAt
			elseif status == "lost" and session.alive then
				session.alive = false
				session.player:Kick(Save.KICK_LOCKED)
			end
			return ok, status
		end,
	})
end

local function ownsPlot(session: any): boolean
	local plot = session.plot
	return plot ~= nil and plot.state == "owned" and plot.userId == session.player.UserId
end

local function allowRequest(session: any): boolean
	return ownsPlot(session)
end

local function allowPurchase(session: any): boolean
	if session.riteBusy == true then
		return false
	end
	local now = os.clock()
	local ok, at = Debounce.allow(session.lastPurchaseAt, now, Economy.PURCHASE_DEBOUNCE_SECONDS)
	if not ok then
		return false
	end
	session.lastPurchaseAt = at
	return true
end

local function commit(session: any, ok: boolean)
	if not ok then
		return
	end
	publish(session, 0)
	queueSave(session)
end

local function onBuy(session: any, slot: any)
	if not allowRequest(session) then
		return
	end
	local parsed = RemoteArgs.slot(slot)
	if parsed == nil or not allowPurchase(session) then
		return
	end
	local offer = nil
	for _, item in Transactions.currentOffers(session.profile) do
		if item.slot == parsed then
			offer = item
		end
	end
	local beforeCash = session.profile.cash
	local fromStep = session.profile.onboarding.step
	local ok = Transactions.buyRift(session.profile, parsed, os.time(), HttpService:GenerateGUID(false))
	if ok == true and offer ~= nil then
		sink().rift(session.player, session, beforeCash, offer.speciesId)
		sink().advanced(session.player, session, fromStep)
	end
	commit(session, ok)
end

local function onUnlock(session: any, padIndex: any)
	if not allowRequest(session) then
		return
	end
	local parsed = RemoteArgs.pad(padIndex)
	if parsed == nil or not allowPurchase(session) then
		return
	end
	local beforeCash = session.profile.cash
	local fromStep = session.profile.onboarding.step
	local ok = Transactions.unlockPad(session.profile, parsed)
	if ok == true then
		sink().pad(session.player, session, parsed, beforeCash)
		sink().advanced(session.player, session, fromStep)
	end
	commit(session, ok)
end

local function onUpgrade(session: any, upgradeId: any)
	if not allowRequest(session) then
		return
	end
	if RemoteArgs.upgradeId(upgradeId) == nil or not allowPurchase(session) then
		return
	end
	local beforeCash = session.profile.cash
	local fromStep = session.profile.onboarding.step
	local ok = Transactions.upgradeBoneAltar(session.profile)
	if ok == true then
		sink().altar(session.player, session, session.profile.upgrades.boneAltar, beforeCash)
		sink().advanced(session.player, session, fromStep)
	end
	commit(session, ok)
end

local function onPlace(session: any, instanceId: any, padIndex: any)
	if not allowRequest(session) then
		return
	end
	local id = RemoteArgs.instanceId(instanceId)
	local pad = RemoteArgs.pad(padIndex)
	if id == nil or pad == nil or not allowPurchase(session) then
		return
	end
	local fromStep = session.profile.onboarding.step
	local ok = Transactions.place(session.profile, id, pad)
	if ok == true then
		sink().advanced(session.player, session, fromStep)
	end
	commit(session, ok)
end

local function onSkip(session: any)
	if not allowRequest(session) then
		return
	end
	local fromStep = session.profile.onboarding.step
	local serial = 0
	local ok = Transactions.skip(session.profile, os.time(), function()
		serial += 1
		return HttpService:GenerateGUID(false) .. "-" .. tostring(serial)
	end)
	if ok == true then
		sink().skipped(session.player, session, fromStep)
	end
	commit(session, ok)
end

local function lanternInHand(player: Player): boolean
	local character = player.Character
	if character == nil then
		return false
	end
	local tool = character:FindFirstChild(Economy.TOOL_NAME)
	return tool ~= nil and tool:IsA("Tool")
end

local function onBeginCatch(session: any)
	if not allowRequest(session) or session.catchBusy then
		return
	end
	if session.profile.onboarding.step ~= Onboarding.CATCH_STEP or ProfileQuery.hasSource(session.profile, "wild") then
		return
	end
	if session.catchStart ~= nil then
		return
	end
	session.catchBusy = true
	syncLantern(session)
	local player = session.player
	local tool = findLantern(player)
	local character = player.Character
	local humanoid = if character ~= nil then character:FindFirstChildOfClass("Humanoid") else nil
	if tool ~= nil and humanoid ~= nil and tool.Parent ~= character then
		humanoid:EquipTool(tool)
		task.wait()
	end
	local distance = distanceTo(player, session.plot.wildPad)
	local ready = lanternInHand(player)
		and RemoteArgs.withinDistance(distance, SkillEffects.catchRange(session.profile))
	session.catchBusy = false
	if not ready or not session.alive or session.catchStart ~= nil then
		return
	end
	session.catchStart = os.clock()
	session.catchToken += 1
	player:SetAttribute("CatchToken", session.catchToken)
end

local function onCompleteCatch(session: any)
	if not allowRequest(session) then
		return
	end
	if session.catchStart == nil then
		return
	end
	local elapsed = os.clock() - session.catchStart
	local distance = distanceTo(session.player, session.plot.wildPad)
	if not RemoteArgs.withinDistance(distance, SkillEffects.catchRange(session.profile)) then
		session.catchStart = nil
		return
	end
	if not RemoteArgs.catchElapsed(elapsed, SkillEffects.catchSeconds(session.profile)) then
		return
	end
	local fromStep = session.profile.onboarding.step
	session.catchStart = nil
	local ok = Transactions.grantWild(session.profile, os.time(), HttpService:GenerateGUID(false))
	if ok == true then
		session.revealSerial = (session.revealSerial or 0) + 1
		sink().advanced(session.player, session, fromStep)
		sink().catch(session.player, session, elapsed, fromStep == Onboarding.CATCH_STEP)
	end
	commit(session, ok)
end

local function onReturn(session: any)
	if not allowRequest(session) then
		return
	end
	local character = session.player.Character
	if character == nil then
		return
	end
	local now = os.clock()
	local allowed, at = Debounce.allow(session.lastReturnAt, now, Plots.RETURN_COOLDOWN_SECONDS)
	if not allowed then
		return
	end
	session.lastReturnAt = at
	character:PivotTo(Plot.spawnCFrame(session.plot))
end

local function notePedlar(session: any, message: string)
	session.pedlarToken += 1
	session.player:SetAttribute("PedlarNotice", message)
	session.player:SetAttribute("PedlarNoticeToken", session.pedlarToken)
end

local function pedlarDistance(player: Player): number?
	local tagged = CollectionService:GetTagged("PedlarStall")
	local model = tagged[1]
	if model == nil or not model:IsA("Model") then
		return nil
	end
	return distanceTo(player, model.PrimaryPart)
end

local function onPedlarBuy(session: any, rotationId: any, slot: any)
	if not allowRequest(session) then
		return
	end
	sink().pedlarPressed(session.player, session)
	local parsedSlot = RemoteArgs.pedlarSlot(slot)
	local parsedRotation = RemoteArgs.rotationId(rotationId)
	if parsedSlot == nil or parsedRotation == nil then
		return
	end
	local serverRotation = ShopStock.rotationId(os.time(), Shop.ROTATION_SECONDS)
	local refusal = ShopStock.refusal(parsedRotation, serverRotation)
	if refusal ~= nil then
		notePedlar(session, refusal)
		publish(session, 0)
		return
	end
	local distance = pedlarDistance(session.player)
	if not RemoteArgs.withinDistance(distance, Town.BUY_DISTANCE) then
		return
	end
	if not allowPurchase(session) then
		return
	end
	local offers = Pedlar.offers()
	if offers == nil then
		return
	end
	local offer = offers[parsedSlot]
	local speciesId = if type(offer) == "table" then offer.speciesId else nil
	local beforeCash = session.profile.cash
	local ok = Transactions.buyPedlar(
		session.profile,
		serverRotation,
		parsedSlot,
		offers,
		distance,
		os.time(),
		HttpService:GenerateGUID(false)
	)
	if ok == true and type(speciesId) == "string" then
		sink().pedlarPurchase(session.player, session, parsedSlot, speciesId, beforeCash)
	end
	commit(session, ok)
end

local function onBind(session: any, enabled: any)
	if not allowRequest(session) then
		return
	end
	local flag = RemoteArgs.flag(enabled)
	if flag == nil then
		return
	end
	local now = os.clock()
	local allowed, at = Debounce.allow(session.lastBindAt, now, Economy.PURCHASE_DEBOUNCE_SECONDS)
	if not allowed then
		return
	end
	session.lastBindAt = at
	if not Transactions.setBindAtOnce(session.profile, flag) then
		return
	end
	publish(session, 0)
	queueSave(session)
end

local function onClaimHaul(session: any)
	if not allowRequest(session) then
		return
	end
	local amount = Offline.claim(session.profile)
	if amount <= 0 then
		return
	end
	publish(session, amount)
	queueSave(session)
end

local function onClaimDaily(session: any)
	if not allowRequest(session) then
		return
	end
	local serial = 0
	local granted = Daily.claim(session.profile, StudioQaHooks.unixNow(), function()
		serial += 1
		return HttpService:GenerateGUID(false) .. "-offering-" .. tostring(serial)
	end)
	if not granted then
		return
	end
	publish(session, 0)
	queueSave(session)
end

local function onSettings(session: any, key: any, value: any)
	if not allowRequest(session) then
		return
	end
	if type(key) ~= "string" then
		return
	end
	local now = os.clock()
	local allowed, at = Debounce.allow(session.lastSettingAt, now, Economy.PURCHASE_DEBOUNCE_SECONDS)
	if not allowed then
		return
	end
	session.lastSettingAt = at
	if not Settings.apply(session.profile, key, value) then
		return
	end
	publish(session, 0)
	queueSave(session)
end

local function onRebirth(session: any, familiarUid: any)
	if not allowRequest(session) or session.riteBusy == true or session.saveBusy == true then
		return
	end
	local uid = familiarUid
	if uid == nil then
		uid = ""
	end
	if uid ~= "" then
		local parsed = RemoteArgs.instanceId(uid)
		if parsed == nil then
			return
		end
		uid = parsed
	end
	local now = os.clock()
	local allowed, at = Debounce.allow(session.rebirthAt, now, RebirthRules.DEBOUNCE_SECONDS)
	if not allowed then
		return
	end
	session.rebirthAt = at
	session.riteBusy = true
	local ok = Rebirth.commit(session.profile, uid)
	if ok then
		session.rebirthWrite = true
		session.rebirthNotice = (session.rebirthNotice or 0) + 1
		session.rebirthText = Rebirth.toast(session.profile.rebirths)
		publish(session, 0)
		performSave(session)
	end
	session.riteBusy = false
end

local function onBuySkill(session: any, nodeId: any)
	if not allowRequest(session) then
		return
	end
	local parsed = RemoteArgs.skillId(nodeId)
	if parsed == nil then
		warn(string.format("%s rejected skill request", SkillConfig.LOG_PREFIX))
		return
	end
	local ready, reason = SkillTree.evaluate(session.profile, parsed)
	if not ready then
		if reason == "sealed" then
			warn(
				string.format(
					"%s %s user %d",
					SkillConfig.LOG_PREFIX,
					SkillConfig.SEALED_REFUSAL,
					session.player.UserId
				)
			)
		end
		return
	end
	if not allowPurchase(session) then
		return
	end
	local ok = Transactions.buySkill(session.profile, parsed)
	commit(session, ok)
end

local function onReducedMotion(session: any, enabled: any)
	if not allowRequest(session) then
		return
	end
	local flag = RemoteArgs.flag(enabled)
	if flag == nil then
		return
	end
	local now = os.clock()
	local allowed, at = Debounce.allow(session.lastSettingAt, now, Economy.PURCHASE_DEBOUNCE_SECONDS)
	if not allowed then
		return
	end
	session.lastSettingAt = at
	if not Transactions.setReducedMotion(session.profile, flag) then
		return
	end
	publish(session, 0)
	queueSave(session)
end

local function bind(folder: Folder)
	local function listen(name: string, handler: (any, ...any) -> ())
		RemoteGuard.bindEvent(Remotes.get(folder, name), function(player: Player, ...: any)
			local session = sessions[player]
			if session == nil or not session.alive then
				return
			end
			handler(session, ...)
		end)
	end
	listen(Names.BUY_RIFT, onBuy)
	listen(Names.UNLOCK_PAD, onUnlock)
	listen(Names.UPGRADE, onUpgrade)
	listen(Names.PLACE, onPlace)
	listen(Names.SKIP, onSkip)
	listen(Names.BEGIN_CATCH, onBeginCatch)
	listen(Names.COMPLETE_CATCH, onCompleteCatch)
	listen(Names.REDUCED_MOTION, onReducedMotion)
	listen(Names.RETURN_TO_LAIR, onReturn)
	listen(Names.PEDLAR_BUY, onPedlarBuy)
	listen(Names.BIND_AT_ONCE, onBind)
	listen(Names.CLAIM_HAUL, onClaimHaul)
	listen(Names.CLAIM_DAILY, onClaimDaily)
	listen(Names.SET_SETTINGS, onSettings)
	listen(Names.BUY_SKILL, onBuySkill)
	listen(Names.OPEN_RELICS, function(session)
		if not allowRequest(session) then
			return
		end
		MonetisationService.onOpen(session)
	end)
	listen(Names.REBIRTH, onRebirth)
	listen(Names.BUY_RELIC, function(session, key)
		if not allowRequest(session) or not allowPurchase(session) then
			return
		end
		MonetisationService.onBuy(session, key)
	end)
end

local function startLoops(session: any)
	session.workers += 1
	task.spawn(function()
		local acc = 0
		while session.alive do
			local dt = task.wait(0.25)
			if not session.alive then
				break
			end
			local inside = Plot.insideOwn(session.plot, session.player)
			local floated = 0
			local changed = false
			local fromStep = session.profile.onboarding.step
			if inside then
				local banked = Bowl.bank(session.profile)
				if banked > 0 then
					floated += banked
					changed = true
					sink().noteIncome(session, banked)
				end
			end
			acc += dt
			local ticked = false
			if acc >= Economy.INCOME_INTERVAL_SECONDS then
				ticked = true
				local ticks = math.floor(acc / Economy.INCOME_INTERVAL_SECONDS)
				acc -= ticks * Economy.INCOME_INTERVAL_SECONDS
				local auto = Ownership.autoCollect(session.profile)
				local amount, incomeChanged =
					Transactions.creditIncome(session.profile, ticks * Economy.INCOME_INTERVAL_SECONDS, inside, auto)
				floated += amount
				if amount > 0 then
					sink().noteIncome(session, amount)
				end
				if incomeChanged then
					changed = true
				end
				if
					session.profile.onboarding.step ~= fromStep and sink().advanced(session.player, session, fromStep)
				then
					changed = true
				end
			end
			if changed then
				session.dirty = true
			end
			if changed or ticked then
				publish(session, floated)
			end
		end
		session.workers -= 1
	end)

	session.workers += 1
	task.spawn(function()
		local remaining = Save.LOCK_REFRESH_SECONDS
		while session.alive do
			local step = math.min(0.25, remaining)
			task.wait(step)
			if not session.alive then
				break
			end
			remaining -= step
			if remaining <= 0 then
				onCadence(session)
				remaining = Save.LOCK_REFRESH_SECONDS
			end
		end
		session.workers -= 1
	end)
end

local function pivot(session: any, character: Model)
	task.spawn(function()
		for _ = 1, Plots.SPAWN_ATTEMPTS do
			if character.Parent == nil or not session.alive then
				return
			end
			if Plot.tryPlace(session.player, character) then
				syncLantern(session)
				task.defer(function()
					if character.Parent ~= nil and session.alive then
						Plot.tryPlace(session.player, character)
					end
				end)
				return
			end
			task.wait(Plots.SPAWN_RETRY_SECONDS)
		end
	end)
end

function PlayerSession.start(folder: Folder)
	bind(folder)
	MonetisationService.start({
		now = os.time,
		newId = function()
			return HttpService:GenerateGUID(false)
		end,
		sessionFor = function(userId: number)
			for player, session in sessions do
				if player.UserId == userId then
					return session
				end
			end
			return nil
		end,
		save = function(session: any)
			if session.saveBusy then
				return false
			end
			local ok = performSave(session)
			return ok == true
		end,
		queue = queueSave,
		publish = function(session: any, credit: number)
			publish(session, credit)
		end,
		spend = function(session: any, spent: number)
			session.relicsBought = (session.relicsBought or 0) + 1
			if type(spent) == "number" and spent > 0 then
				session.relicsSpent = (session.relicsSpent or 0) + math.floor(spent)
			end
		end,
	})
	Plot.start(function(player: Player)
		return sessions[player]
	end)
end

function PlayerSession.onPlayer(player: Player): boolean
	if sessions[player] ~= nil then
		return true
	end
	local fallback = Plot.fallbackSpawn()
	if fallback ~= nil then
		player.RespawnLocation = fallback
	end
	local plan = StudioQa.plan(RunService:IsStudio(), StudioQaHooks.args())
	if plan == "kick" then
		player:Kick(Save.KICK_LOAD_FAILED)
		return false
	end
	if plan == "seed-fresh" or plan == "seed-stale" then
		DataStoreGateway.seedForeignLock(player.UserId, plan == "seed-stale")
	end
	local seedKind = StudioQa.seedKind(RunService:IsStudio(), StudioQaHooks.args())
	if seedKind ~= nil then
		local seeded = StudioQa.seedDocument(seedKind, os.time())
		if seeded ~= nil then
			print(StudioQa.seedLine(seedKind, "before", seeded))
			DataStoreGateway.seedProfile(player.UserId, seeded)
		end
	end
	local created = Schema.newProfile(os.time(), HttpService:GenerateGUID(false))
	local loaded = DataStoreGateway.load(player.UserId, created)
	if seedKind ~= nil and loaded.ok and loaded.profile ~= nil then
		print(StudioQa.seedLine(seedKind, "after", loaded.profile))
	end
	if player.Parent == nil then
		if loaded.ok and loaded.ephemeral ~= true and loaded.profile ~= nil then
			DataStoreGateway.release(player.UserId, loaded.profile)
		end
		return false
	end
	if not loaded.ok or loaded.profile == nil then
		sink().ledger(player, loaded.attempts, loaded.reason)
		player:Kick(loaded.message or Save.KICK_LOAD_FAILED)
		return false
	end
	local profile = loaded.profile
	local grantedStarter = Schema.ensureStarter(profile, os.time(), HttpService:GenerateGUID(false))
	local playedBefore = profile.onboarding.playSeconds
	StudioQa.armRelics(profile)
	local armedRite = StudioQa.armRebirth(profile)
	local armedShop = profile.onboarding.playSeconds ~= playedBefore
	local silentNotice = 0
	if type(profile.offline.notice) == "number" and profile.offline.notice > 0 then
		silentNotice = profile.offline.notice
		profile.offline.notice = 0
	end
	local offeringNow = StudioQaHooks.unixNow()
	local dailyAutoOpen = Daily.shouldAutoOpen(Daily.offerButton(profile), Daily.ready(profile, offeringNow))

	local state = Instance.new("Folder")
	state.Name = "CryptidState"
	local snapshot = Instance.new("StringValue")
	snapshot.Name = "Snapshot"
	snapshot.Parent = state
	state.Parent = player
	local guide = Instance.new("ObjectValue")
	guide.Name = "GuideTarget"
	guide.Parent = player

	local plot, claimStatus, rule = Plot.claim(player)
	if player.Parent == nil or claimStatus == "left" then
		if plot ~= nil then
			Plot.hold(player)
		end
		if loaded.ok and loaded.ephemeral ~= true and loaded.profile ~= nil then
			DataStoreGateway.release(player.UserId, loaded.profile)
		end
		return false
	end
	if plot == nil then
		if loaded.ok and loaded.ephemeral ~= true and loaded.profile ~= nil then
			DataStoreGateway.release(player.UserId, loaded.profile)
		end
		player:Kick(Plots.KICK_NO_LAIR)
		return false
	end

	QaGrant.apply(profile, player.UserId)

	local lockExpiresAt = os.time() + Save.LOCK_TTL_SECONDS
	if type(loaded.lockExpiresAt) == "number" then
		lockExpiresAt = loaded.lockExpiresAt
	end
	local session = {
		player = player,
		profile = profile,
		ephemeral = loaded.ephemeral == true,
		loaded = true,
		alive = true,
		leaving = false,
		dirty = grantedStarter or silentNotice > 0 or armedShop or armedRite,
		dailyAutoOpen = dailyAutoOpen,
		silentNotice = silentNotice,
		lockExpiresAt = lockExpiresAt,
		saveBusy = false,
		saveScheduled = false,
		lastSaveAt = 0,
		lastPurchaseAt = nil,
		lastSettingAt = nil,
		rebirthAt = nil,
		riteBusy = false,
		rebirthWrite = false,
		rebirthNotice = 0,
		rebirthText = "",
		revision = 0,
		catchStart = nil,
		catchToken = 0,
		revealSerial = 0,
		relicsBought = 0,
		relicsSpent = 0,
		bornAt = os.clock(),
		pendingIncome = 0,
		analyticsKey = HttpService:GenerateGUID(false),
		lastReturnAt = nil,
		lastBindAt = nil,
		pedlarToken = 0,
		workers = 0,
		plot = plot,
		snapshot = snapshot,
		guide = guide,
	}
	sessions[player] = session
	local analyticsDirty = sink().bootstrap(player, session, {
		fresh = loaded.fresh == true,
		seenUnix = loaded.seenUnix,
		now = os.time(),
		rule = rule,
	})
	if analyticsDirty then
		session.dirty = true
	end
	publish(session, 0)
	if grantedStarter or analyticsDirty then
		queueSave(session)
	end
	startLoops(session)

	player.CharacterAdded:Connect(function(character)
		pivot(session, character)
	end)
	if player.Character ~= nil then
		pivot(session, player.Character)
	end
	task.spawn(function()
		if session.alive then
			MonetisationService.sync(session)
		end
	end)
	return true
end

local function closeOwned(player: Player, session: any, bounded: boolean): (boolean, boolean)
	sink().beginExit(session)
	local started = os.clock()
	local budget = ShutdownFlush.budget(RunService:IsStudio())
	while session.saveBusy or session.workers > 0 do
		if bounded and os.clock() - started >= budget then
			break
		end
		task.wait(Save.SHUTDOWN_POLL_SECONDS)
	end
	local remaining = budget
	if bounded then
		remaining = budget - (os.clock() - started)
		if remaining < 0 then
			remaining = 0
		end
	end
	settleDeparture(session)
	sink().finishExit(player, session, os.time(), os.clock())
	local saved, released, state = SessionClose.persist(session, {
		now = os.clock,
		budgetSeconds = remaining,
		waitFor = function(seconds: number)
			task.wait(seconds)
		end,
		save = function(current: any): boolean
			local ok = DataStoreGateway.save(player.UserId, current.profile, current.rebirthWrite == true)
			if ok then
				current.rebirthWrite = false
				current.dirty = false
				current.lockExpiresAt = os.time() + Save.LOCK_TTL_SECONDS
			end
			return ok
		end,
		release = function(current: any): boolean
			local ok = DataStoreGateway.release(player.UserId, current.profile, current.rebirthWrite == true)
			return ok
		end,
	})
	if state == "busy" then
		return false, false
	end
	Plot.hold(player)
	SessionClose.finish(detaching, player)
	if activeTally ~= nil then
		SessionClose.note(activeTally, saved, released)
	end
	return saved, released
end

function PlayerSession.onRemoving(player: Player)
	RateLimiter.forget(player.UserId)
	local role, session = SessionClose.begin(sessions, detaching, player)
	if role ~= "owner" or session == nil then
		return
	end
	closeOwned(player, session, false)
end

function PlayerSession.onPedlarOpen(player: Player)
	local session = sessions[player]
	if session == nil or session.alive ~= true then
		return
	end
	sink().pedlarOpen(
		player,
		session,
		ShopStock.rotationId(os.time(), Shop.ROTATION_SECONDS),
		HttpService:GenerateGUID(false)
	)
end

function PlayerSession.onPedlarRotation()
	for _, session in sessions do
		if session.alive == true then
			sink().pedlarStale(session)
		end
	end
end

function PlayerSession.republish()
	for _, session in sessions do
		if session.alive then
			publish(session, 0)
		end
	end
end

function PlayerSession.shutdown()
	local studio = RunService:IsStudio()
	DataStoreGateway.setHurry(studio)
	activeTally = { saved = 0, released = 0 }
	local outcome = SessionClose.shutdown(sessions, detaching, {
		budgetSeconds = ShutdownFlush.budget(studio),
		now = os.clock,
		waitFor = function(seconds: number)
			task.wait(seconds)
		end,
		spawn = function(body: () -> ())
			task.spawn(body)
		end,
		persist = function(player: Player, session: any)
			RateLimiter.forget(player.UserId)
			closeOwned(player, session, true)
		end,
	})
	print(
		string.format(
			"[Cryptid:DataStore] shutdown flush saved=%d released=%d pending=%d elapsed=%.2f",
			activeTally.saved,
			activeTally.released,
			outcome.pending,
			outcome.elapsed
		)
	)
	activeTally = nil
end

return PlayerSession
