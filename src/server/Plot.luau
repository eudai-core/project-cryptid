--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CryptidArt = require(Shared:WaitForChild("Config"):WaitForChild("CryptidArt")) :: any
local CryptidModels = require(Shared:WaitForChild("CryptidModels")) :: any
local LairVisual = require(script.Parent:WaitForChild("LairVisual"))
local PlotBuilder = require(script.Parent:WaitForChild("PlotBuilder"))
local PlotSignals = require(script.Parent:WaitForChild("PlotSignals"))
local Economy = require(Shared:WaitForChild("Config"):WaitForChild("Economy")) :: any
local NumberFormat = require(Shared:WaitForChild("Logic"):WaitForChild("NumberFormat")) :: any
local OnboardingGoals = require(Shared:WaitForChild("Logic"):WaitForChild("OnboardingGoals")) :: any
local PlotAccess = require(Shared:WaitForChild("Logic"):WaitForChild("PlotAccess")) :: any
local PlotAssign = require(Shared:WaitForChild("Logic"):WaitForChild("PlotAssign")) :: any
local PlotRing = require(Shared:WaitForChild("Logic"):WaitForChild("PlotRing")) :: any
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local ProfileQuery = require(Shared:WaitForChild("Logic"):WaitForChild("ProfileQuery")) :: any
local Species = require(Shared:WaitForChild("Config"):WaitForChild("Species")) :: any
local SkillEffects = require(script.Parent:WaitForChild("SkillEffects")) :: any
local StealGuard = require(Shared:WaitForChild("Logic"):WaitForChild("StealGuard")) :: any
local Transactions = require(Shared:WaitForChild("Logic"):WaitForChild("Transactions")) :: any

local plots: { any } = {}
local byPlayer: { [Player]: any } = {}
local townSpawn: SpawnLocation? = nil
local insidePlot: { [Player]: number } = {}
local lastSealAt: { [Player]: number } = {}
local watching = false
local activeTicket = 1
local issuedTicket = 0

local Plot = {}

local function acquire()
	issuedTicket += 1
	local ticket = issuedTicket
	while activeTicket ~= ticket do
		task.wait()
	end
end

local function release()
	activeTicket += 1
end

local function locked(body: () -> ()): (boolean, string?)
	acquire()
	local ok, err = pcall(body)
	release()
	return ok, if ok then nil else tostring(err)
end

local function personName(player: Player): string
	if player.DisplayName ~= "" then
		return player.DisplayName
	end
	return player.Name
end

local function rootOf(player: Player): BasePart?
	local character = player.Character
	if character == nil then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root ~= nil and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function contains(plot: any, worldPosition: Vector3): boolean
	local localPos = plot.origin:PointToObjectSpace(worldPosition)
	local half = Plots.FOOTPRINT / 2
	return math.abs(localPos.X) <= half
		and math.abs(localPos.Z) <= half
		and localPos.Y >= -Plots.STAND_HEIGHT
		and localPos.Y <= Plots.THRESHOLD_HEIGHT
end

local function publish(plot: any)
	plot.model:SetAttribute("PlotIndex", plot.index)
	plot.model:SetAttribute("OwnerUserId", plot.userId)
	plot.model:SetAttribute("OwnerName", plot.ownerName)
	plot.model:SetAttribute("PlotState", plot.state)
	plot.model:SetAttribute("Sealed", plot.protected == true and plot.state ~= "free")
	local showSeal = plot.protected == true and plot.state ~= "free"
	plot.seal.Transparency = if showSeal then Plots.SEAL_TRANSPARENCY else 1
end

local function setPrompts(plot: any, userId: number)
	local function apply(plate: ProximityPrompt)
		plate:SetAttribute("OwnerUserId", userId)
	end
	apply(plot.altarPrompt)
	apply(plot.wildPrompt)
	for _, pad in plot.pads do
		apply(pad.prompt)
		pad.center:SetAttribute("OwnerUserId", userId)
	end
	for _, rift in plot.rift do
		apply(rift.prompt)
		rift.part:SetAttribute("OwnerUserId", userId)
	end
	plot.wildPad:SetAttribute("OwnerUserId", userId)
end

local function setLivedIn(plot: any, livedIn: boolean)
	for _, light in plot.lights do
		light.Enabled = livedIn
	end
	for _, flame in plot.flames do
		flame.Transparency = if livedIn then 0 else 1
	end
	for _, door in plot.doors do
		door.CanCollide = not livedIn
		door.CanTouch = not livedIn
		door.Transparency = if livedIn then 1 else 0
	end
	plot.spawnLocation.Enabled = livedIn
	plot.spawnLocation.Neutral = livedIn
end

local function destroyNamed(host: Instance, name: string)
	local existing = host:FindFirstChild(name)
	if existing ~= nil then
		existing:Destroy()
	end
end

local function padRestState(pad: any): string
	if PlotRing.isSealedPad(pad.index) then
		return CryptidArt.states.sealed
	end
	return CryptidArt.states.empty
end

local function showPad(pad: any, state: string, affordable: boolean)
	LairVisual.applyPad(pad.visual, pad.states, state, affordable)
	local sealed = state == CryptidArt.states.sealed
	pad.center:SetAttribute("Sealed", sealed)
	if pad.visual ~= nil then
		pad.visual:SetAttribute("Sealed", sealed)
		pad.visual:SetAttribute("beingStolen", false)
	end
end

local function clearCreatures(plot: any)
	for _, pad in plot.pads do
		destroyNamed(pad.center, "Creature")
		pad.center:SetAttribute("beingStolen", false)
		pad.prompt:SetAttribute("Available", false)
		showPad(pad, padRestState(pad), false)
	end
	for _, rift in plot.rift do
		destroyNamed(rift.part, "Creature")
		rift.prompt:SetAttribute("Available", false)
	end
	destroyNamed(plot.wildPad, "Creature")
	plot.wildPrompt:SetAttribute("Available", false)
	plot.altarPrompt:SetAttribute("Available", false)
	LairVisual.applyAltar(plot.altarModel, plot.altarTiers, 0)
end

local function outsideGate(plot: any): CFrame
	local position =
		plot.origin:PointToWorldSpace(Vector3.new(0, Plots.STAND_HEIGHT, Plots.LAIR_GATE_Z + Plots.SEAL_PUSH_STUDS))
	local further = plot.origin:PointToWorldSpace(
		Vector3.new(0, Plots.STAND_HEIGHT, Plots.LAIR_GATE_Z + Plots.SEAL_PUSH_STUDS + Plots.SEAL_PUSH_STUDS)
	)
	return CFrame.lookAt(position, further)
end

local function townEdge(index: number): CFrame
	local edge = PlotRing.townEdge(index)
	return CFrame.lookAt(Vector3.new(edge.x, edge.y, edge.z), Vector3.new(0, edge.y, 0))
end

local function ejectVisitors(plot: any)
	local ownerId = plot.userId
	for _, player in Players:GetPlayers() do
		if player.UserId ~= ownerId then
			local character = player.Character
			local root = rootOf(player)
			if character ~= nil and root ~= nil and contains(plot, root.Position) then
				character:PivotTo(townEdge(plot.index))
				insidePlot[player] = nil
			end
		end
	end
end

local function clearPlot(plot: any)
	ejectVisitors(plot)
	clearCreatures(plot)
	setPrompts(plot, 0)
	setLivedIn(plot, false)
	plot.state = "free"
	plot.userId = 0
	plot.ownerName = ""
	plot.protected = false
	plot.profile = nil
	publish(plot)
end

local function snapshot(): any
	local state = PlotAssign.empty(Plots.COUNT)
	for _, plot in plots do
		if plot.state == "owned" or plot.state == "reserved" then
			state.plots[plot.index] = {
				state = plot.state,
				userId = plot.userId,
			}
		end
	end
	return state
end

local function friendPlots(player: Player): { number }?
	local found = {}
	for _, other in Players:GetPlayers() do
		if other ~= player then
			local plot = byPlayer[other]
			if plot ~= nil then
				local ok, isFriend = pcall(function()
					return player:IsFriendsWith(other.UserId)
				end)
				if not ok then
					return nil
				end
				if isFriend == true then
					table.insert(found, plot.index)
				end
			end
		end
	end
	return found
end

local function occupy(plot: any, player: Player)
	plot.ownerName = personName(player)
	setPrompts(plot, player.UserId)
	setLivedIn(plot, true)
	publish(plot)
	player:SetAttribute("PlotIndex", plot.index)
	player.RespawnLocation = plot.spawnLocation
end

function Plot.fallbackSpawn(): SpawnLocation?
	return townSpawn
end

function Plot.floorReady(plot: any): boolean
	local floor = plot.model:FindFirstChild("Floor")
	return plot.model.Parent ~= nil and floor ~= nil and floor:IsA("BasePart") and floor.Anchored and floor.CanCollide
end

function Plot.build()
	if #plots > 0 then
		return
	end
	plots = PlotBuilder.build()
	local town = workspace:FindFirstChild("Town")
	local spawn = if town ~= nil then town:FindFirstChild("TownSpawn") else nil
	if spawn ~= nil and spawn:IsA("SpawnLocation") then
		townSpawn = spawn
	end
end

function Plot.tryPlace(player: Player, character: Model): boolean
	local plot = byPlayer[player]
	if plot == nil or not Plot.floorReady(plot) then
		return false
	end
	local spawnPart = plot.spawnLocation
	if workspace.StreamingEnabled then
		local streamed = pcall(function()
			player:RequestStreamAroundAsync(spawnPart.Position)
		end)
		if not streamed or not Plot.floorReady(plot) then
			return false
		end
	end
	character:PivotTo(spawnPart.CFrame)
	local root = character:FindFirstChild("HumanoidRootPart")
	if root ~= nil and root:IsA("BasePart") then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil or humanoid.Health <= 0 or root == nil or not root:IsA("BasePart") then
		return false
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local hit = workspace:Raycast(root.Position, Vector3.new(0, -Plots.SPAWN_RAY_STUDS, 0), params)
	return hit ~= nil and hit.Instance.CanCollide
end

function Plot.claim(player: Player): (any?, string)
	local claimed = nil
	local why = "full"
	local ok, err = locked(function()
		if player.Parent == nil then
			why = "left"
			return
		end
		local state = snapshot()
		local friends = nil
		if PlotAssign.reservedIndex(state, player.UserId) == nil then
			friends = friendPlots(player)
			if player.Parent == nil then
				why = "left"
				return
			end
			state = snapshot()
		end
		local index = PlotAssign.choose(state, player.UserId, friends)
		if index == nil then
			why = "full"
			return
		end
		local plot = plots[index]
		plot.generation += 1
		plot.state = "owned"
		plot.userId = player.UserId
		plot.ownerName = personName(player)
		byPlayer[player] = plot
		claimed = plot
		why = "ok"
	end)
	if not ok then
		warn("Plot assignment failed: " .. tostring(err))
		local partial = byPlayer[player]
		if partial ~= nil then
			byPlayer[player] = nil
			clearPlot(partial)
		end
		return nil, "full"
	end
	if claimed == nil then
		return nil, why
	end
	occupy(claimed, player)
	if player.Parent == nil then
		byPlayer[player] = nil
		clearPlot(claimed)
		return nil, "left"
	end
	return claimed, "ok"
end

function Plot.hold(player: Player)
	local plot = byPlayer[player]
	byPlayer[player] = nil
	insidePlot[player] = nil
	lastSealAt[player] = nil
	player:SetAttribute("PlotIndex", nil)
	if plot == nil or plot.userId ~= player.UserId or plot.state ~= "owned" then
		return
	end
	plot.state = "reserved"
	plot.generation += 1
	local generation = plot.generation
	local userId = plot.userId
	publish(plot)
	task.delay(Plots.HOLD_SECONDS, function()
		if plot.generation ~= generation then
			return
		end
		if plot.state ~= "reserved" or plot.userId ~= userId then
			return
		end
		clearPlot(plot)
	end)
end

local function creatureMount(pad: any): CFrame
	if pad.mount ~= nil and pad.mount:IsA("BasePart") then
		return pad.mount.CFrame
	end
	return pad.stand
end

local function replaceCreature(host: Instance, speciesId: string?, cf: CFrame)
	local existing = host:FindFirstChild("Creature")
	if speciesId == nil then
		if existing ~= nil then
			existing:Destroy()
		end
		return
	end
	if existing ~= nil and existing:GetAttribute(CryptidArt.attr.speciesId) == speciesId then
		return
	end
	if existing ~= nil then
		existing:Destroy()
	end
	local model = CryptidModels.get(speciesId)
	model.Name = "Creature"
	model:SetAttribute(CryptidArt.attr.speciesId, speciesId)
	model.Parent = host
	CryptidModels.pivotTo(model, cf)
end

local function guidePart(plot: any, guide: string): BasePart?
	if guide == "altar" then
		return plot.altar
	end
	if guide == "wild" then
		return plot.wildPad
	end
	local padIndex = string.match(guide, "^pad:(%d+)$")
	if padIndex ~= nil then
		local pad = plot.pads[tonumber(padIndex)]
		if pad ~= nil then
			return pad.center
		end
	end
	local slot = string.match(guide, "^rift:(%d+)$")
	if slot ~= nil then
		local rift = plot.rift[tonumber(slot)]
		if rift ~= nil then
			return rift.part
		end
	end
	return nil
end

function Plot.sync(plot: any, profile: any, guideValue: ObjectValue)
	plot.profile = profile
	plot.protected = StealGuard.isProtected(profile)
	publish(plot)
	LairVisual.applyAltar(plot.altarModel, plot.altarTiers, profile.upgrades.boneAltar)

	for _, pad in plot.pads do
		pad.center:SetAttribute("beingStolen", false)
		local mount = creatureMount(pad)
		if PlotRing.isSealedPad(pad.index) then
			replaceCreature(pad.center, nil, mount)
			pad.prompt:SetAttribute("Available", false)
			showPad(pad, CryptidArt.states.sealed, false)
			continue
		end
		local instanceId = ProfileQuery.padAt(profile, pad.index)
		local speciesId = nil
		if instanceId ~= nil then
			local record = profile.cryptids[instanceId]
			if record ~= nil then
				speciesId = record.speciesId
			end
		end
		replaceCreature(pad.center, speciesId, mount)
		local lockedPad = pad.index > profile.padsUnlocked
		local nextPad = pad.index == profile.padsUnlocked + 1
		local cost = SkillEffects.padCost(profile, pad.index)
		local occupied = speciesId ~= nil
		local canAfford = lockedPad and nextPad and type(cost) == "number" and profile.cash + 1e-9 >= cost
		showPad(pad, CryptidArt.padState(false, occupied, lockedPad), canAfford)
		pad.prompt:SetAttribute("Pad", pad.index)
		if lockedPad and nextPad and type(cost) == "number" then
			pad.prompt:SetAttribute("Kind", "UnlockPad")
			pad.prompt:SetAttribute("Available", true)
			pad.prompt.ActionText = "Carve"
			pad.prompt.ObjectText = NumberFormat.formatCash(cost)
		elseif not lockedPad and instanceId == nil then
			local goal = OnboardingGoals.view(profile)
			local wantsPlace = goal.actionKind == "place"
				and goal.actionPad == pad.index
				and goal.actionInstanceId ~= ""
			pad.prompt:SetAttribute("Kind", "Place")
			pad.prompt:SetAttribute("InstanceId", if wantsPlace then goal.actionInstanceId else "")
			pad.prompt:SetAttribute("Available", wantsPlace)
			pad.prompt.ActionText = "Bind"
			pad.prompt.ObjectText = "Circle " .. tostring(pad.index)
		else
			pad.prompt:SetAttribute("Available", false)
			pad.prompt.ActionText = ""
		end
	end

	local offers = Transactions.currentOffers(profile)
	local offerBySlot = {}
	for _, offer in offers do
		offerBySlot[offer.slot] = offer
	end
	for _, rift in plot.rift do
		local offer = offerBySlot[rift.slot]
		if offer == nil then
			replaceCreature(rift.part, nil, rift.stand)
			rift.prompt:SetAttribute("Available", false)
		else
			replaceCreature(rift.part, offer.speciesId, rift.stand)
			rift.prompt:SetAttribute("Available", true)
			rift.prompt:SetAttribute("Slot", offer.slot)
			rift.prompt.ActionText = "Claim"
			rift.prompt.ObjectText = NumberFormat.formatCash(offer.price)
		end
	end

	local showWild = profile.onboarding.step == 6 and not ProfileQuery.hasSource(profile, "wild")
	replaceCreature(plot.wildPad, if showWild then Species.WILD_ID else nil, plot.wildStand)
	plot.wildPrompt:SetAttribute("Available", showWild)
	plot.wildPrompt.MaxActivationDistance = SkillEffects.catchRange(profile)
	plot.wildPrompt.ActionText = "Catch"
	local wildSpecies = Species.get(Species.WILD_ID)
	plot.wildPrompt.ObjectText = wildSpecies.displayName

	local nextAltar = profile.upgrades.boneAltar + 1
	local altarCost = Economy.ALTAR_COST[nextAltar]
	if type(altarCost) == "number" then
		plot.altarPrompt:SetAttribute("Available", true)
		plot.altarPrompt.ActionText = "Raise"
		plot.altarPrompt.ObjectText = NumberFormat.formatCash(altarCost)
	else
		plot.altarPrompt:SetAttribute("Available", false)
	end

	local goal = OnboardingGoals.view(profile)
	guideValue.Value = guidePart(plot, goal.guide)
end

local function plotAt(position: Vector3): any?
	for _, plot in plots do
		if contains(plot, position) then
			return plot
		end
	end
	return nil
end

local function push(character: Model, cf: CFrame)
	character:PivotTo(cf)
end

local function noteSeal(player: Player, message: string)
	local now = os.clock()
	local previous = lastSealAt[player]
	if previous ~= nil and now - previous < Plots.SEAL_TOAST_COOLDOWN then
		return
	end
	lastSealAt[player] = now
	local pulse = player:GetAttribute("SealPulse")
	if type(pulse) ~= "number" then
		pulse = 0
	end
	player:SetAttribute("SealMessage", message)
	player:SetAttribute("SealPulse", pulse + 1)
end

function Plot.start(getSession: (Player) -> any?)
	if watching then
		return
	end
	watching = true
	task.spawn(function()
		while watching do
			task.wait(Plots.WATCH_SECONDS)
			for _, player in Players:GetPlayers() do
				local root = rootOf(player)
				local character = player.Character
				if root == nil or character == nil then
					insidePlot[player] = nil
					continue
				end
				local plot = plotAt(root.Position)
				if plot == nil then
					insidePlot[player] = nil
					continue
				end
				local session = getSession(player)
				local owns = plot.userId == player.UserId and plot.state ~= "free"
				if owns then
					insidePlot[player] = plot.index
					continue
				end
				local visitor = if session ~= nil then session.profile else nil
				local owner = if plot.state == "free" then nil else plot.profile
				if visitor == nil then
					continue
				end
				if not PlotAccess.mayEnter(visitor, owner, false) then
					push(character, outsideGate(plot))
					insidePlot[player] = nil
					local toast = PlotAccess.toastFor(visitor, owner, false)
					if toast ~= nil then
						noteSeal(player, toast)
					end
					continue
				end
				if insidePlot[player] ~= plot.index then
					PlotSignals.fire(plot.index, player)
				end
				insidePlot[player] = plot.index
			end
		end
	end)
end

function Plot.spawnCFrame(plot: any): CFrame
	return plot.spawnLocation.CFrame
end

return Plot
