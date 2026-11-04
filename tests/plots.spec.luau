--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local Check = require("./check")
local Debounce = require("../src/shared/Logic/Debounce")
local HudSlots = require("../src/shared/Logic/HudSlots")
local SpawnSafety = require("../src/shared/Logic/SpawnSafety")
local AltarTier = require("../src/shared/Logic/AltarTier")
local Economy = require("../src/shared/Config/Economy")
local Income = require("../src/shared/Logic/Income")
local Lair = require("../src/shared/Config/Lair")
local Lanterns = require("../src/shared/Config/Lanterns")
local PlotAccess = require("../src/shared/Logic/PlotAccess")
local PlotAssign = require("../src/shared/Logic/PlotAssign")
local PlotRing = require("../src/shared/Logic/PlotRing")
local Plots = require("../src/shared/Config/Plots")
local RemoteArgs = require("../src/shared/Logic/RemoteArgs")
local Save = require("../src/shared/Config/Save")
local Schema = require("../src/shared/Logic/Schema")
local Transactions = require("../src/shared/Logic/Transactions")
local UITheme = require("../src/shared/UITheme")

local function specCenter(index: number): (number, number)
	local theta = math.rad((index - 1) * 45)
	return 260 * math.sin(theta), 260 * math.cos(theta)
end

Check.test("QA1 and QA3 plot 1 sits at the town's north edge", function()
	Check.eq(Plots.COUNT, 8)
	Check.eq(Plots.MAX_PLAYERS, 8)
	Check.eq(Plots.RING_RADIUS, 260)
	Check.eq(Plots.ANGLE_STEP, 45)
	local center = PlotRing.center(1)
	Check.near(center.x, 0, 1)
	Check.near(center.y, 0, 1)
	Check.near(center.z, 260, 1)
	local state = PlotAssign.empty(Plots.COUNT)
	Check.eq(PlotAssign.take(state, 100, {}), 1)
end)

Check.test("QA2 eight joins take eight different plots and a ninth is refused", function()
	local state = PlotAssign.empty(Plots.COUNT)
	local seen = {}
	for userId = 1, Plots.COUNT do
		local index = PlotAssign.take(state, userId, {})
		Check.truthy(index)
		Check.eq(seen[index], nil)
		seen[index] = userId
		Check.eq(index, userId)
	end
	Check.eq(PlotAssign.take(state, 9, {}), nil)
end)

Check.test("QA3 every plot centre matches the ring formula within a stud", function()
	for index = 1, Plots.COUNT do
		local expectedX, expectedZ = specCenter(index)
		local center = PlotRing.center(index)
		Check.near(center.x, expectedX, 1, "plot " .. tostring(index) .. " x")
		Check.near(center.z, expectedZ, 1, "plot " .. tostring(index) .. " z")
		Check.near(center.y, 0, 1)
	end
	local second = PlotRing.center(2)
	Check.eq(second.x > 0, true)
	Check.eq(second.z > 0, true)
end)

Check.test("QA4 each lair gate's front points at the origin", function()
	for index = 1, Plots.COUNT do
		local center = PlotRing.center(index)
		local axes = PlotRing.axes(index)
		local radial = math.sqrt(center.x * center.x + center.z * center.z)
		Check.near(axes.z.x, -center.x / radial, 1e-6)
		Check.near(axes.z.y, 0, 1e-6)
		Check.near(axes.z.z, -center.z / radial, 1e-6)
		local gate = PlotRing.toWorld(index, { x = 0, y = 0, z = Plots.LAIR_GATE_Z })
		local ahead = PlotRing.toWorld(index, { x = 0, y = 0, z = Plots.LAIR_GATE_Z + 1 })
		Check.eq(PlotRing.radius(ahead) < PlotRing.radius(gate), true)
	end
end)

Check.test("QA5 twelve pads sit on a radius-28 ring and pad 1 faces the gate", function()
	Check.eq(Plots.PAD_COUNT, 12)
	Check.eq(Plots.PAD_RING_RADIUS, 28)
	Check.eq(Plots.PAD_ANGLE_STEP, 30)
	local gate = { x = 0, z = Plots.LAIR_GATE_Z }
	local nearest = 0
	local nearestDistance = math.huge
	for padIndex = 1, Plots.PAD_COUNT do
		local pad = PlotRing.padLocal(padIndex)
		local dx = pad.x - Plots.ALTAR_X
		local dz = pad.z - Plots.ALTAR_Z
		Check.near(math.sqrt(dx * dx + dz * dz), 28, 0.5, "pad " .. tostring(padIndex))
		local distance = math.sqrt((pad.x - gate.x) ^ 2 + (pad.z - gate.z) ^ 2)
		if distance < nearestDistance then
			nearestDistance = distance
			nearest = padIndex
		end
	end
	Check.eq(nearest, 1)
	local first = PlotRing.padLocal(1)
	Check.near(first.x, 0, 1e-6)
	Check.eq(first.z > Plots.ALTAR_Z, true)
end)

Check.test("QA6 profile math does not store a plot index", function()
	local profile = Schema.newProfile(1, "starter")
	Check.eq(profile.plotIndex, nil)
	local before = Income.perSecond(profile)
	profile.plotIndex = 5
	Check.eq(Income.perSecond(profile), before)
	local migrated = Schema.migrate(profile)
	Check.eq(migrated.plotIndex, nil)
	Check.eq(migrated.pads["1"], "starter")
	Check.eq(migrated.cash, profile.cash)
end)

Check.test("QA7 a rejoin inside the hold returns the reserved plot", function()
	Check.eq(Plots.HOLD_SECONDS, 30)
	local state = PlotAssign.empty(Plots.COUNT)
	Check.eq(PlotAssign.take(state, 4, {}), 1)
	Check.eq(PlotAssign.reserve(state, 4), 1)
	Check.eq(PlotAssign.holdPhase(10, Plots.HOLD_SECONDS), "reserved")
	Check.eq(PlotAssign.holdPhase(29.999, Plots.HOLD_SECONDS), "reserved")
	Check.eq(PlotAssign.choose(state, 4, { 3 }), 1)
	Check.eq(PlotAssign.releaseIfDue(state, 1, 10, Plots.HOLD_SECONDS), "reserved")
end)

Check.test("QA8 after the hold the plot is free for the next player", function()
	local state = PlotAssign.empty(Plots.COUNT)
	PlotAssign.take(state, 4, {})
	PlotAssign.reserve(state, 4)
	Check.eq(PlotAssign.holdPhase(30, Plots.HOLD_SECONDS), "clear")
	Check.eq(PlotAssign.holdPhase(35, Plots.HOLD_SECONDS), "clear")
	Check.eq(PlotAssign.releaseIfDue(state, 1, 35, Plots.HOLD_SECONDS), "free")
	Check.eq(PlotAssign.take(state, 8, {}), 1)
	Check.eq(PlotAssign.earns("present"), true)
	Check.eq(PlotAssign.earns("reserved"), false)
	Check.eq(PlotAssign.earns("clear"), false)
end)

Check.test("QA9 the saved layout is the profile, not the plot number", function()
	local profile = Schema.newProfile(50, "starter")
	profile.cash = 80
	profile.padsUnlocked = 3
	profile.upgrades.boneAltar = 1
	profile.dataVersion = 2
	profile.base = nil
	local carried = Schema.migrate(profile)
	Check.eq(carried.dataVersion, Save.DATA_VERSION)
	Check.eq(carried.cash, 80)
	Check.eq(carried.padsUnlocked, 3)
	Check.eq(carried.upgrades.boneAltar, 1)
	Check.eq(carried.pads["1"], "starter")
	Check.eq(carried.plotIndex, nil)
	Check.eq(next(carried.base.defences), nil)
	local state = PlotAssign.empty(Plots.COUNT)
	state.plots[1] = { state = "owned", userId = 1 }
	Check.eq(PlotAssign.take(state, 2, {}), 2)
end)

Check.test("QA10 and QA11 the seal blocks protected lairs and finished players may visit", function()
	local visitor = Schema.newProfile(1, "visitor")
	local owner = Schema.newProfile(1, "owner")
	visitor.onboarding.step = 8
	Check.eq(PlotAccess.mayEnter(visitor, owner, false), false)
	Check.eq(PlotAccess.blocksWithSeal(visitor, owner, false), true)
	owner.onboarding.step = 8
	Check.eq(PlotAccess.mayEnter(visitor, owner, false), true)
	Check.eq(PlotAccess.blocksWithSeal(visitor, owner, false), false)
	Check.eq(PlotAccess.mayEnter(owner, owner, true), true)
	Check.eq(PlotAccess.mayEnter(visitor, nil, false), false)
	visitor.onboarding.step = 2
	Check.eq(PlotAccess.mayEnter(visitor, owner, false), false)
	Check.eq(PlotAccess.toastFor(visitor, owner, false), "Finish your own rite first.")
	visitor.onboarding.step = 8
	owner.onboarding.step = 1
	Check.eq(PlotAccess.toastFor(visitor, owner, false), "A warding seal holds this lair.")
	Check.eq(PlotAccess.toastFor(visitor, owner, true), nil)
	Check.eq(Plots.SEAL_TOAST, "A warding seal holds this lair.")
	Check.eq(Plots.RITE_TOAST, "Finish your own rite first.")
	Check.eq(Plots.SEAL_TOAST_COOLDOWN, 3)
end)

Check.test("QA12 return to lair refuses a second press inside 10 seconds", function()
	Check.eq(Plots.RETURN_COOLDOWN_SECONDS, 10)
	local allowed, at = Debounce.allow(nil, 100, Plots.RETURN_COOLDOWN_SECONDS)
	Check.eq(allowed, true)
	local again = Debounce.allow(at, 109.9, Plots.RETURN_COOLDOWN_SECONDS)
	Check.eq(again, false)
	local later = Debounce.allow(at, 110, Plots.RETURN_COOLDOWN_SECONDS)
	Check.eq(later, true)
	Check.eq(Plots.RETURN_LABEL, "Return to Lair")
end)

Check.test("QA13 pads 7 through 12 are sealed and cannot be bought", function()
	local profile = Schema.newProfile(1, "starter")
	profile.padsUnlocked = Economy.MAX_PADS
	profile.cash = 100000
	for padIndex = Plots.SEALED_PAD_START, Plots.PAD_COUNT do
		Check.eq(PlotRing.isSealedPad(padIndex), true)
		Check.eq(Economy.PAD_COST[padIndex], nil)
		local cash = profile.cash
		Check.eq(Transactions.unlockPad(profile, padIndex), false)
		Check.eq(profile.cash, cash)
		Check.eq(profile.padsUnlocked, Economy.MAX_PADS)
	end
	Check.eq(RemoteArgs.pad(7), nil)
	Check.eq(RemoteArgs.pad(6), 6)
	Check.eq(Plots.SEALED_LABEL, "Sealed")
end)

Check.test("QA14 intrusion, defence sockets, and empty defences", function()
	local record = PlotAssign.intrusion(5, 42)
	Check.eq(record.name, "PlotIntruded")
	Check.eq(Plots.INTRUSION_EVENT, "PlotIntruded")
	Check.eq(record.plotIndex, 5)
	Check.eq(record.userId, 42)
	Check.eq(#Plots.DEFENCE_SOCKETS, 4)
	local expected = {
		{ x = -54, z = -54 },
		{ x = 54, z = -54 },
		{ x = 54, z = 54 },
		{ x = -54, z = 54 },
	}
	for index, socket in expected do
		Check.eq(PlotRing.socketName(index), "DefenceSocket" .. tostring(index))
		Check.eq(PlotRing.socketLocal(index).x, socket.x)
		Check.eq(PlotRing.socketLocal(index).z, socket.z)
	end
	local profile = Schema.newProfile(3, "starter")
	Check.eq(next(profile.base.defences), nil)
	local legacy = Schema.migrate(profile)
	Check.eq(next(legacy.base.defences), nil)
end)

Check.test("QA15 income is only credited while the owner is present", function()
	Check.eq(PlotAssign.earns("present"), true)
	Check.eq(PlotAssign.earns("reserved"), false)
	Check.eq(PlotAssign.earns("clear"), false)
	local profile = Schema.newProfile(1, "starter")
	local gained = Transactions.creditIncome(profile, 1)
	Check.eq(gained, Income.perSecond(profile))
	local heldCash = profile.cash
	local bystander = Schema.newProfile(1, "other")
	local bystanderCash = bystander.cash
	if PlotAssign.earns("reserved") then
		Transactions.creditIncome(profile, Plots.HOLD_SECONDS)
		Transactions.creditIncome(bystander, Plots.HOLD_SECONDS)
	end
	Check.eq(profile.cash, heldCash)
	Check.eq(bystander.cash, bystanderCash)
	local session = fs.readFile("src/server/PlayerSession.luau")
	local aliveAt = string.find(session, "session.alive = false", 1, true)
	local holdAt = string.find(session, "Plot.hold(player)", 1, true)
	local loopAt = string.find(session, "while session.alive do", 1, true)
	local creditAt = string.find(session, "Transactions.creditIncome", 1, true)
	Check.truthy(aliveAt)
	Check.truthy(holdAt)
	Check.truthy(loopAt)
	Check.truthy(creditAt)
	Check.eq((aliveAt :: number) < (holdAt :: number), true)
	Check.eq((loopAt :: number) < (creditAt :: number), true)
end)

Check.test("friend plots win over the lowest free plot and ties take the low index", function()
	local beside = PlotAssign.empty(Plots.COUNT)
	beside.plots[1] = { state = "owned", userId = 10 }
	Check.eq(PlotAssign.choose(beside, 11, { 1 }), 2)
	local around = PlotAssign.empty(Plots.COUNT)
	around.plots[1] = { state = "owned", userId = 10 }
	around.plots[2] = { state = "owned", userId = 11 }
	Check.eq(PlotAssign.choose(around, 12, { 1 }), 8)
	Check.eq(PlotAssign.ringSteps(1, 8, 8), 1)
	Check.eq(PlotAssign.ringSteps(1, 3, 8), 2)
end)

Check.test("a failed friend lookup falls back to the lowest free plot", function()
	local state = PlotAssign.empty(Plots.COUNT)
	state.plots[1] = { state = "owned", userId = 10 }
	Check.eq(PlotAssign.choose(state, 11, nil), 2)
	Check.eq(PlotAssign.choose(state, 11, {}), 2)
end)

Check.test("reservation beats a nearby friend", function()
	local state = PlotAssign.empty(Plots.COUNT)
	state.plots[1] = { state = "owned", userId = 10 }
	state.plots[5] = { state = "reserved", userId = 7 }
	Check.eq(PlotAssign.choose(state, 7, { 1 }), 5)
end)

Check.test("migration from v2 lands on the current data version and keeps the ledger", function()
	Check.eq(Save.DATA_VERSION, 6)
	local v2 = Schema.newProfile(9, "starter")
	v2.dataVersion = 2
	v2.totalEarned = 40
	v2.cash = 65
	v2.base = nil
	local migrated = Schema.migrate(v2)
	Check.eq(migrated.dataVersion, 6)
	Check.eq(migrated.totalEarned, 40)
	Check.eq(migrated.cash, 65)
	Check.eq(next(migrated.base.defences), nil)
	Check.eq(v2.totalEarned, 40)
	Check.eq(v2.base, nil)

	local v1 = Schema.newProfile(9, "starter")
	v1.dataVersion = 1
	v1.totalEarned = 45
	v1.cash = 45
	local fromV1 = Schema.migrate(v1)
	Check.eq(fromV1.dataVersion, 6)
	Check.eq(fromV1.totalEarned, 20)
	Check.eq(next(fromV1.base.defences), nil)

	local kept = Schema.newProfile(9, "starter")
	kept.base = { defences = { ["2"] = "ward_candle" } }
	local round = Schema.migrate(kept)
	Check.eq(round.base.defences[2], "ward_candle")
	Check.eq(kept.base.defences["2"], "ward_candle")

	local corrupt = Schema.newProfile(9, "starter")
	corrupt.base = { defences = "no" }
	Check.eq(Schema.migrate(corrupt), nil)
	Check.eq(corrupt.base.defences, "no")

	local future = Schema.newProfile(9, "starter")
	future.dataVersion = 7
	Check.eq(Schema.migrate(future), nil)

	local encoded = serde.encode("json", Schema.newProfile(9, "starter"))
	Check.eq(string.find(encoded, "plotIndex", 1, true), nil)
	Check.eq(string.find(encoded, "PlotIndex", 1, true), nil)
	local decoded = Schema.migrate(serde.decode("json", encoded))
	Check.eq(decoded.dataVersion, 6)
	Check.eq(next(decoded.base.defences), nil)
end)

Check.test("the wild spawn is 20 studs outside the wild gate and past the wilds line", function()
	Check.eq(Plots.WILDS_RADIUS, 330)
	Check.eq(Economy.WILD_SPAWN_STUDS, 20)
	local localWild = PlotRing.wildLocal()
	Check.near(localWild.z, Plots.WILD_GATE_Z - Economy.WILD_SPAWN_STUDS, 1e-6)
	for index = 1, Plots.COUNT do
		Check.eq(PlotRing.radius(PlotRing.toWorld(index, localWild)) > Plots.WILDS_RADIUS, true)
	end
	local spawn = PlotRing.spawnLocal()
	Check.eq(spawn.z, Plots.SPAWN_Z)
	Check.eq(Plots.ALTAR_Z < spawn.z, true)
end)

Check.test("a spawn stands on a solid floor and the plot move waits for that floor", function()
	local half = Plots.FALLBACK_SIZE / 2
	local stand = { x = 0, y = Plots.FALLBACK_THICKNESS + Plots.STAND_HEIGHT, z = 0 }
	Check.eq(
		SpawnSafety.aboveBox(stand, -half, half, -half, half, Plots.FALLBACK_THICKNESS, Plots.SPAWN_RAY_STUDS),
		true
	)
	local void = { x = 0, y = -400, z = 0 }
	Check.eq(
		SpawnSafety.aboveBox(void, -half, half, -half, half, Plots.FALLBACK_THICKNESS, Plots.SPAWN_RAY_STUDS),
		false
	)
	local slabHalf = Plots.FOOTPRINT / 2
	for index = 1, Plots.COUNT do
		local worldSpawn = PlotRing.toWorld(index, PlotRing.spawnLocal())
		local localSpawn = PlotRing.toLocal(index, worldSpawn)
		Check.eq(
			SpawnSafety.aboveSlab(localSpawn, slabHalf, Plots.FLOOR_THICKNESS, Plots.SPAWN_RAY_STUDS),
			true,
			tostring(index)
		)
	end
	Check.eq(SpawnSafety.placeTarget(false, true), "fallback")
	Check.eq(SpawnSafety.placeTarget(true, false), "fallback")
	Check.eq(SpawnSafety.placeTarget(true, true), "plot")
	Check.eq(SpawnSafety.spawnTarget(false), "town")
	Check.eq(SpawnSafety.spawnTarget(true), "plot")
	local plotOne = PlotRing.toWorld(1, PlotRing.spawnLocal())
	Check.near(plotOne.x, 0, 0.05)
	Check.near(plotOne.y, Plots.STAND_HEIGHT, 0.05)
	Check.near(plotOne.z, 212, 0.05)
	Check.eq(SpawnSafety.spawnTarget(true), "plot")
	Check.eq(Plots.SPAWN_CHECK_SECONDS, 10)
	local builder = fs.readFile("src/server/PlotBuilder.luau")
	local ground = string.match(builder, "function PlotBuilder.buildGround%(.-%\nfunction PlotBuilder.buildPlot")
	Check.truthy(ground)
	Check.eq(string.find(ground :: string, "Cylinder", 1, true), nil)
	Check.eq(string.find(ground :: string, "TownPlatform", 1, true) ~= nil, true)
	Check.eq(string.find(ground :: string, "TownSpawn", 1, true) ~= nil, true)
	Check.eq(string.find(ground :: string, "Neutral = true", 1, true) ~= nil, true)
	local spawnCheck = fs.readFile("src/server/SpawnCheck.luau")
	Check.eq(string.find(spawnCheck, "PASS spawn %s health %.0f floor %s %.2f studs", 1, true) ~= nil, true)
	Check.eq(string.find(spawnCheck, "if not RunService:IsStudio() then", 1, true) ~= nil, true)
	local session = fs.readFile("src/server/PlayerSession.luau")
	local respawnAt = string.find(session, "player.RespawnLocation = fallback", 1, true)
	local loadAt = string.find(session, "DataStoreGateway.load(player.UserId, created)", 1, true)
	Check.truthy(respawnAt)
	Check.truthy(loadAt)
	Check.eq(respawnAt < loadAt, true)
end)

Check.test("Technology and StreamingEnabled live in the place file, not in scripts", function()
	local project = serde.decode("json", fs.readFile("default.project.json"))
	Check.eq(project.tree.Workspace["$properties"].StreamingEnabled, false)
	Check.eq(project.tree.Lighting["$properties"].Technology, "Future")
	Check.eq(UITheme.lighting.technology, project.tree.Lighting["$properties"].Technology)
	local files = {}
	local function walk(dir: string)
		for _, name in fs.readDir(dir) do
			local path = dir .. "/" .. name
			if fs.isDir(path) then
				walk(path)
			elseif string.match(name, "%.luau$") ~= nil then
				table.insert(files, path)
			end
		end
	end
	walk("src")
	Check.truthy(#files > 0)
	for _, path in files do
		local text = fs.readFile(path)
		Check.eq(string.match(text, "StreamingEnabled%s*=") == nil, true, path)
		Check.eq(string.match(text, "%.Technology%s*=") == nil, true, path)
		Check.eq(string.find(text, "203785492", 1, true), nil, path)
	end
	Check.eq(string.find(fs.readFile("default.project.json"), "203785492", 1, true), nil)
end)

Check.test("the cash sigil uses the header face, not Oswald", function()
	Check.eq(UITheme.fonts.sigil.family, UITheme.fonts.header.family)
	Check.eq(UITheme.fonts.sigil.weight, UITheme.fonts.header.weight)
	Check.eq(UITheme.fonts.header.family, "Garamond")
	Check.eq(UITheme.fonts.number.family, "Oswald")
	Check.eq(UITheme.fontFaces.Garamond, "rbxasset://fonts/families/Guru.json")
	local plaque = fs.readFile("src/client/CashPlaque.luau")
	Check.eq(string.find(plaque, 'ThemeBind.apply(sigil, "sigil"', 1, true) ~= nil, true)
end)

Check.test("world trim uses RiftDim metal and no neon emission", function()
	Check.eq(UITheme.palette.Rift, "7FA34A")
	Check.eq(UITheme.palette.RiftDim, "4F6B34")
	Check.eq(UITheme.materials.lantern, "Metal")
	local builders = {
		"src/server/PlotBuilder.luau",
		"src/server/TownBuilder.luau",
		"src/server/Pedlar.luau",
		"src/server/Wisp.luau",
		"src/server/RiftGlow.luau",
	}
	for _, path in builders do
		local builder = fs.readFile(path)
		Check.eq(string.find(builder, "materials.neon", 1, true), nil, path)
		Check.eq(string.find(builder, "Enum.Material.Neon", 1, true), nil, path)
		Check.eq(string.find(builder, "LightEmission", 1, true), nil, path)
	end
	local builder = fs.readFile("src/server/PlotBuilder.luau")
	Check.eq(string.find(builder, '"RiftDim"', 1, true) ~= nil, true)
	local town = fs.readFile("src/server/TownBuilder.luau")
	Check.eq(Lanterns.RIFT_SURFACE, "RiftDim")
	Check.eq(Lanterns.RIFT_MATERIAL, "lantern")
	Check.eq(string.find(town, "Lanterns.RIFT_SURFACE", 1, true) ~= nil, true)
	Check.eq(string.find(town, "RiftGlow.attach", 1, true) ~= nil, true)
	Check.eq(string.find(fs.readFile("src/server/PlotBuilder.luau"), "RiftGlow.attach", 1, true) ~= nil, true)
	local riftUses = 0
	local cursor = 1
	while true do
		local found = string.find(builder, '"Rift"', cursor, true)
		if found == nil then
			break
		end
		riftUses += 1
		cursor = found + 1
	end
	Check.eq(riftUses, 0)
end)

Check.test("gate lanterns fit the per-plot light cap", function()
	Check.eq(Lanterns.PER_PLOT_LIGHT_CAP, 8)
	Check.eq(#Lanterns.townOffsets(), 4)
	Check.eq(#Lanterns.gateOffsets(), 2)
	local plotLights = Lair.CANDLE_LIGHT_COUNT + #Lanterns.gateOffsets() + Lanterns.FISSURE_LIGHTS
	Check.eq(plotLights <= Lanterns.PER_PLOT_LIGHT_CAP, true)
	Check.eq(plotLights, Lanterns.PER_PLOT_LIGHT_CAP)
	Check.eq(Lanterns.SHADOWS, false)
	Check.eq(Lanterns.COLOR_TOKEN, "Candle")
	Check.eq(UITheme.world.Candle, "FFB36B")
	Check.eq(Lanterns.BRIGHTNESS >= 1 and Lanterns.BRIGHTNESS <= 1.5, true)
	Check.eq(Lanterns.RANGE >= 14 and Lanterns.RANGE <= 18, true)
end)

Check.test("the home beam tip is inside the clear fog band under the live atmosphere", function()
	Check.eq(UITheme.lighting.fogStart, 250)
	Check.eq(UITheme.lighting.fogEnd, 1100)
	Check.eq(UITheme.lighting.fogColor, "Ash")
	Check.eq(UITheme.lighting.atmosphereDensity, 0.18)
	Check.eq(UITheme.lighting.atmosphereHaze, 0.3)
	Check.eq(UITheme.lighting.atmosphereOffset, 0)
	Check.eq(UITheme.lighting.atmosphereGlare, 0)
	Check.eq(UITheme.lighting.atmosphereColor, "Ash")
	Check.eq(UITheme.lighting.atmosphereDecay, "Void")
	Check.eq(UITheme.lighting.brightness, 1.5)
	Check.eq(UITheme.lighting.exposureCompensation, 0.3)
	Check.near(PlotRing.townEdgeToCentre(), 140, 1e-6)
	local slant = PlotRing.homeBeamTipDistance()
	Check.eq(slant < UITheme.lighting.fogStart, true)
	Check.eq(slant < UITheme.lighting.fogEnd, true)
	local across = Plots.RING_RADIUS * 2
	Check.eq(across > UITheme.lighting.fogStart, true)
	Check.eq(across < UITheme.lighting.fogEnd, true)
end)

Check.test("the slot to the right of both lair buttons stays empty", function()
	local hud = Plots.RETURN_BUTTON
	Check.eq(hud.occupiedSlots, 2)
	Check.eq(HudSlots.origin(0), hud.margin)
	Check.eq(HudSlots.origin(1), hud.margin + hud.width + hud.gap)
	local rites = HudSlots.ritesOrigin()
	Check.eq(rites, HudSlots.origin(2))
	Check.eq(rites >= HudSlots.origin(1) + hud.width + hud.gap, true)
	local files = {}
	local function walk(dir: string)
		for _, name in fs.readDir(dir) do
			local path = dir .. "/" .. name
			if fs.isDir(path) then
				walk(path)
			elseif string.match(name, "%.luau$") ~= nil then
				table.insert(files, path)
			end
		end
	end
	walk("src/client")
	for _, path in files do
		local text = fs.readFile(path)
		Check.eq(string.find(text, "HudSlots.origin(2)", 1, true), nil, path)
		Check.eq(string.find(text, "HudSlots.ritesOrigin", 1, true), nil, path)
	end
end)

Check.test("lair stone stays the playtest colours and the live light follows v1.2", function()
	Check.eq(Lair.CANDLE_RANGE, 18)
	Check.eq(Lair.CANDLE_BRIGHTNESS, 2)
	Check.eq(UITheme.world.Candle, "FFB36B")
	Check.eq(UITheme.world.Ambient, "2C2622")
	Check.eq(UITheme.world.OutdoorAmbient, "221E1B")
	Check.eq(UITheme.world.Floor, "3A342F")
	Check.eq(UITheme.world.Wall, "1C1917")
	Check.eq(UITheme.world.Altar, "403932")
	Check.eq(UITheme.lighting.brightness, 1.5)
	Check.eq(UITheme.lighting.exposureCompensation, 0.3)
	Check.eq(UITheme.lighting.ambient, "LightAmbient")
	Check.eq(UITheme.lighting.outdoorAmbient, "LightOutdoor")
	Check.eq(UITheme.palette.LightAmbient, "3C3734")
	Check.eq(UITheme.palette.LightOutdoor, "5F5852")
	Check.eq(UITheme.lighting.technology, "Future")
	Check.eq(UITheme.lighting.fogStart, 250)
	Check.eq(UITheme.lighting.fogEnd, 1100)
	Check.eq(UITheme.lighting.atmosphereDensity, 0.18)
	Check.eq(UITheme.lighting.atmosphereHaze, 0.3)
	Check.eq(UITheme.lighting.atmosphereOffset, 0)
	Check.eq(UITheme.lighting.atmosphereGlare, 0)
	Check.eq(UITheme.lighting.atmosphereColor, "Ash")
	Check.eq(UITheme.lighting.atmosphereDecay, "Void")
end)

Check.test("altar tiers stay positive through level X", function()
	local earlyShrink = Plots.ALTAR_TIER_INSET
	Check.eq(AltarTier.span(Plots.ALTAR_SIZE.z, earlyShrink), Plots.ALTAR_SIZE.z - Plots.PAD_RING_MARGIN - earlyShrink)
	local topShrink = (Economy.MAX_ALTAR_LEVEL - 1) * Plots.ALTAR_TIER_INSET
	Check.eq(AltarTier.span(Plots.ALTAR_SIZE.z, topShrink), Plots.ALTAR_TIER_MIN)
	local width, height, depth = AltarTier.size(Economy.MAX_ALTAR_LEVEL)
	Check.eq(width > 0, true)
	Check.eq(height > 0, true)
	Check.eq(depth > 0, true)
end)
