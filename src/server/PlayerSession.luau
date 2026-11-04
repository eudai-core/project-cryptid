--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local DataStoreGateway = require(script.Parent:WaitForChild("DataStoreGateway"))
local Pedlar = require(script.Parent:WaitForChild("Pedlar"))
local Plot = require(script.Parent:WaitForChild("Plot"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))
local Debounce = require(Shared:WaitForChild("Logic"):WaitForChild("Debounce")) :: any
local Economy = require(Shared:WaitForChild("Config"):WaitForChild("Economy")) :: any
local Lair = require(Shared:WaitForChild("Config"):WaitForChild("Lair")) :: any
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local Income = require(Shared:WaitForChild("Logic"):WaitForChild("Income")) :: any
local Names = require(Shared:WaitForChild("Config"):WaitForChild("Remotes")) :: any
local ProfileQuery = require(Shared:WaitForChild("Logic"):WaitForChild("ProfileQuery")) :: any
local Shop = require(Shared:WaitForChild("Config"):WaitForChild("Shop")) :: any
local ShopStock = require(Shared:WaitForChild("Logic"):WaitForChild("ShopStock")) :: any
local Town = require(Shared:WaitForChild("Config"):WaitForChild("Town")) :: any
local RemoteArgs = require(Shared:WaitForChild("Logic"):WaitForChild("RemoteArgs")) :: any
local Autosave = require(Shared:WaitForChild("Logic"):WaitForChild("Autosave")) :: any
local Save = require(Shared:WaitForChild("Config"):WaitForChild("Save")) :: any
local Schema = require(Shared:WaitForChild("Logic"):WaitForChild("Schema")) :: any
local ShutdownFlush = require(Shared:WaitForChild("Logic"):WaitForChild("ShutdownFlush")) :: any
local Snapshot = require(Shared:WaitForChild("Logic"):WaitForChild("Snapshot")) :: any
local StealGuard = require(Shared:WaitForChild("Logic"):WaitForChild("StealGuard")) :: any
local Transactions = require(Shared:WaitForChild("Logic"):WaitForChild("Transactions")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local sessions: { [Player]: any } = {}

local PlayerSession = {}

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
	if session.profile.onboarding.step < 6 then
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
	local income = Income.perSecond(profile)
	local snap = Snapshot.build(profile, credit, session.revision)
	local player = session.player
	player:SetAttribute("Cash", profile.cash)
	player:SetAttribute("IncomePerSecond", income)
	player:SetAttribute("LastCredit", credit)
	player:SetAttribute("ReducedMotion", profile.settings.reducedMotion == true)
	player:SetAttribute("OnboardingStep", profile.onboarding.step)
	player:SetAttribute("StealProtected", StealGuard.isProtected(profile))
	session.snapshot.Value = HttpService:JSONEncode(snap)
	player:SetAttribute("StateRevision", session.revision)
	Plot.sync(session.plot, profile, session.guide)
	syncLantern(session)
end

local performSave: (any) -> (boolean, string)
local queueSave: (any) -> ()

performSave = function(session: any): (boolean, string)
	if session.ephemeral or session.loaded ~= true or not session.alive or session.player.Parent == nil then
		return false, "skipped"
	end
	session.saveBusy = true
	session.dirty = false
	session.lastSaveAt = os.clock()
	local ok, status = DataStoreGateway.save(session.player.UserId, session.profile)
	session.saveBusy = false
	if ok then
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
	if session.ephemeral or session.loaded ~= true or not session.alive then
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
	if session.ephemeral or session.loaded ~= true or not session.alive or session.saveBusy then
		return
	end
	Autosave.apply(session.dirty == true, session.lockExpiresAt, os.time(), {
		save = function()
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
	if not ownsPlot(session) then
		return false
	end
	local now = os.clock()
	if now - session.windowStart >= 1 then
		session.windowStart = now
		session.windowCount = 0
	end
	session.windowCount += 1
	return session.windowCount <= Economy.REMOTE_REQUESTS_PER_SECOND
end

local function allowPurchase(session: any): boolean
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
	local ok = Transactions.buyRift(session.profile, parsed, os.time(), HttpService:GenerateGUID(false))
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
	local ok = Transactions.unlockPad(session.profile, parsed)
	commit(session, ok)
end

local function onUpgrade(session: any, upgradeId: any)
	if not allowRequest(session) then
		return
	end
	if RemoteArgs.upgradeId(upgradeId) == nil or not allowPurchase(session) then
		return
	end
	local ok = Transactions.upgradeBoneAltar(session.profile)
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
	local ok = Transactions.place(session.profile, id, pad)
	commit(session, ok)
end

local function onSkip(session: any)
	if not allowRequest(session) then
		return
	end
	local serial = 0
	local ok = Transactions.skip(session.profile, os.time(), function()
		serial += 1
		return HttpService:GenerateGUID(false) .. "-" .. tostring(serial)
	end)
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
	if session.profile.onboarding.step ~= 6 or ProfileQuery.hasSource(session.profile, "wild") then
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
	local ready = lanternInHand(player) and RemoteArgs.withinDistance(distance, Economy.CATCH_DISTANCE_STUDS)
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
	if not RemoteArgs.withinDistance(distance, Economy.CATCH_DISTANCE_STUDS) then
		session.catchStart = nil
		return
	end
	if not RemoteArgs.catchElapsed(elapsed, Economy.CATCH_SECONDS) then
		return
	end
	session.catchStart = nil
	local ok = Transactions.grantWild(session.profile, os.time(), HttpService:GenerateGUID(false))
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
	local ok = Transactions.buyPedlar(
		session.profile,
		serverRotation,
		parsedSlot,
		offers,
		distance,
		os.time(),
		HttpService:GenerateGUID(false)
	)
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
		Remotes.get(folder, name).OnServerEvent:Connect(function(player: Player, ...: any)
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
			acc += dt
			if acc >= Economy.INCOME_INTERVAL_SECONDS then
				local ticks = math.floor(acc / Economy.INCOME_INTERVAL_SECONDS)
				acc -= ticks * Economy.INCOME_INTERVAL_SECONDS
				local amount = Transactions.creditIncome(session.profile, ticks * Economy.INCOME_INTERVAL_SECONDS)
				if amount > 0 then
					session.dirty = true
				end
				publish(session, amount)
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
	Plot.start(function(player: Player)
		return sessions[player]
	end)
end

function PlayerSession.onPlayer(player: Player)
	if sessions[player] ~= nil then
		return
	end
	local fallback = Plot.fallbackSpawn()
	if fallback ~= nil then
		player.RespawnLocation = fallback
	end
	local created = Schema.newProfile(os.time(), HttpService:GenerateGUID(false))
	local loaded = DataStoreGateway.load(player.UserId, created)
	if player.Parent == nil then
		if loaded.ok and loaded.ephemeral ~= true and loaded.profile ~= nil then
			DataStoreGateway.release(player.UserId, loaded.profile)
		end
		return
	end
	if not loaded.ok or loaded.profile == nil then
		player:Kick(loaded.message or Save.KICK_LOAD_FAILED)
		return
	end
	local profile = loaded.profile
	local grantedStarter = Schema.ensureStarter(profile, os.time(), HttpService:GenerateGUID(false))

	local state = Instance.new("Folder")
	state.Name = "CryptidState"
	local snapshot = Instance.new("StringValue")
	snapshot.Name = "Snapshot"
	snapshot.Parent = state
	state.Parent = player
	local guide = Instance.new("ObjectValue")
	guide.Name = "GuideTarget"
	guide.Parent = player

	local plot, claimStatus = Plot.claim(player)
	if player.Parent == nil or claimStatus == "left" then
		if plot ~= nil then
			Plot.hold(player)
		end
		if loaded.ok and loaded.ephemeral ~= true and loaded.profile ~= nil then
			DataStoreGateway.release(player.UserId, loaded.profile)
		end
		return
	end
	if plot == nil then
		if loaded.ok and loaded.ephemeral ~= true and loaded.profile ~= nil then
			DataStoreGateway.release(player.UserId, loaded.profile)
		end
		player:Kick(Plots.KICK_NO_LAIR)
		return
	end

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
		dirty = grantedStarter,
		lockExpiresAt = lockExpiresAt,
		saveBusy = false,
		saveScheduled = false,
		lastSaveAt = 0,
		lastPurchaseAt = nil,
		lastSettingAt = nil,
		windowStart = 0,
		windowCount = 0,
		revision = 0,
		catchStart = nil,
		catchToken = 0,
		lastReturnAt = nil,
		lastBindAt = nil,
		pedlarToken = 0,
		workers = 0,
		plot = plot,
		snapshot = snapshot,
		guide = guide,
	}
	sessions[player] = session
	publish(session, 0)
	if grantedStarter then
		queueSave(session)
	end
	startLoops(session)

	player.CharacterAdded:Connect(function(character)
		pivot(session, character)
	end)
	if player.Character ~= nil then
		pivot(session, player.Character)
	end
end

local function detach(player: Player, hurry: boolean)
	local session = sessions[player]
	if session == nil or session.leaving then
		return
	end
	session.leaving = true
	session.alive = false
	sessions[player] = nil
	if not hurry then
		while session.saveBusy or session.workers > 0 do
			task.wait()
		end
	end
	if session.loaded == true and session.ephemeral ~= true then
		if session.dirty then
			DataStoreGateway.save(player.UserId, session.profile)
		end
		DataStoreGateway.release(player.UserId, session.profile)
	end
	Plot.hold(player)
end

function PlayerSession.onRemoving(player: Player)
	detach(player, false)
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
	local entries = {}
	local prepared: { [any]: boolean } = {}
	local function prepare(entry: any)
		if prepared[entry] then
			return
		end
		prepared[entry] = true
		if studio then
			return
		end
		local session = entry.session
		while session.saveBusy or session.workers > 0 do
			task.wait()
		end
	end
	for _, player in Players:GetPlayers() do
		local session = sessions[player]
		if session ~= nil and session.leaving ~= true then
			session.leaving = true
			session.alive = false
			sessions[player] = nil
			table.insert(entries, {
				loaded = true,
				dirty = session.dirty == true and session.loaded == true and session.ephemeral ~= true,
				player = player,
				session = session,
			})
		end
	end
	ShutdownFlush.run(entries, {
		save = function(entry)
			prepare(entry)
			local ok, status = DataStoreGateway.save(entry.player.UserId, entry.session.profile)
			if ok then
				entry.session.dirty = false
				entry.session.lockExpiresAt = os.time() + Save.LOCK_TTL_SECONDS
			end
			return ok, status
		end,
		release = function(entry)
			prepare(entry)
			local ok = true
			local status = "released"
			if entry.session.loaded == true and entry.session.ephemeral ~= true then
				ok, status = DataStoreGateway.release(entry.player.UserId, entry.session.profile)
			end
			Plot.hold(entry.player)
			return ok, status
		end,
		spawn = function(body)
			if studio then
				body()
			else
				task.spawn(body)
			end
		end,
		waitFor = function(seconds: number)
			if studio then
				return
			end
			task.wait(seconds)
		end,
		now = os.clock,
		budgetSeconds = ShutdownFlush.budget(studio),
	})
end

return PlayerSession
