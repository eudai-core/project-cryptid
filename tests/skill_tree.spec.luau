--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local Check = require("./check")
local Debounce = require("../src/shared/Logic/Debounce")
local Economy = require("../src/shared/Config/Economy")
local Income = require("../src/shared/Logic/Income")
local Ledger = require("../src/server/Ledger")
local MockDataStore = require("../src/server/MockDataStore")
local NumberFormat = require("../src/shared/Logic/NumberFormat")
local RemoteArgs = require("../src/shared/Logic/RemoteArgs")
local Remotes = require("../src/shared/Config/Remotes")
local Save = require("../src/shared/Config/Save")
local Schema = require("../src/shared/Logic/Schema")
local Shop = require("../src/shared/Config/Shop")
local SkillConfig = require("../src/shared/Config/SkillConfig")
local SkillEffects = require("../src/server/SkillEffects")
local SkillTree = require("../src/shared/Logic/SkillTree")
local UITheme = require("../src/shared/UITheme")

local POSITIONS = {
	root = { 0, 0 },
	h1 = { -240, 0 },
	h2 = { -420, -140 },
	h3 = { -420, 140 },
	h4 = { -600, -200 },
	h5 = { -600, 200 },
	h6 = { -780, 0 },
	h7 = { -960, 0 },
	h8 = { -1160, 0 },
	l1 = { 240, 0 },
	l2 = { 420, -140 },
	l3 = { 420, 140 },
	l4 = { 600, -200 },
	l5 = { 600, 200 },
	l6 = { 780, 0 },
	l7 = { 960, 0 },
	l8 = { 1160, 0 },
}

local SEALED = { "h3", "h5", "h6", "h7", "h8", "l5", "l6", "l7", "l8" }
local LOCKED = { "h2", "h4", "l2", "l3", "l4" }

local function fresh(): any
	local profile = Schema.newProfile(1_700_000_000, "starter")
	profile.onboarding.step = 8
	return profile
end

local function marked(step: number, cash: number): any
	local profile = fresh()
	profile.onboarding.step = step
	profile.cash = cash
	return profile
end

local function between(source: string, from: string, to: string): string
	local startAt = string.find(source, from, 1, true)
	local endAt = string.find(source, to, 1, true)
	Check.truthy(startAt)
	Check.truthy(endAt)
	return string.sub(source, startAt :: number, (endAt :: number) - 1)
end

Check.test("QA1 the skill tree is a ScreenGui", function()
	local client = fs.readFile("src/client/SkillTree.luau")
	Check.contains(client, 'Instance.new("ScreenGui")')
	Check.contains(client, 'Name = "SkillTree"')
	Check.contains(client, "IgnoreGuiInset = true")
	Check.contains(client, "ResetOnSpawn = false")
	Check.contains(client, "DisplayOrder = ui.displayOrder")
	Check.eq(SkillConfig.UI.displayOrder, 20)
	Check.eq(string.find(client, 'Instance.new("Part")', 1, true), nil)
	Check.eq(string.find(client, 'Instance.new("MeshPart")', 1, true), nil)
	Check.eq(string.find(client, "ParticleEmitter", 1, true), nil)
	Check.eq(string.find(client, "Parent = workspace", 1, true), nil)
	Check.eq(string.find(client, "StreamingEnabled", 1, true), nil)
	Check.eq(string.match(client, "%.Technology%s*=") == nil, true)
end)

Check.test("QA2 the rites button and shrine stay shut before step 8", function()
	Check.eq(Shop.GATE_STEP, 8)
	Check.eq(SkillTree.gateOpen(7), false)
	Check.eq(SkillTree.gateOpen(8), true)
	local profile = marked(7, 5000)
	local before = profile.cash
	local ok, reason = SkillTree.buy(profile, "h1")
	Check.eq(ok, false)
	Check.eq(reason, "onboarding")
	Check.eq(profile.cash, before)
	local client = fs.readFile("src/client/SkillTree.luau")
	Check.contains(client, "function SkillTree.mount")
	Check.contains(client, "Town.SHRINE_UNMARKED")
	Check.contains(client, "Town.SHRINE_BODY")
	Check.contains(client, "Shop.GATE_STEP")
	Check.contains(client, "SkillRules.gateOpen")
	Check.contains(client, "rites.Visible")
end)

Check.test("QA3 K, the rites button, and the shrine open it; Esc, B, and close shut it", function()
	Check.eq(SkillConfig.OPEN_LABEL, "Rites")
	Check.eq(SkillConfig.OPEN_KEY, "K")
	Check.eq(SkillConfig.CLOSE_KEY, "Escape")
	Check.eq(SkillConfig.GAMEPAD_OPEN, "ButtonSelect")
	Check.eq(SkillConfig.GAMEPAD_CLOSE, "ButtonB")
	Check.eq(SkillConfig.GAMEPAD_RESET, "ButtonY")
	Check.eq(SkillConfig.CLOSE_LABEL, "Close the circle")
	local client = fs.readFile("src/client/SkillTree.luau")
	Check.contains(client, "Enum.KeyCode[SkillConfig.OPEN_KEY]")
	Check.contains(client, "Enum.KeyCode[SkillConfig.CLOSE_KEY]")
	Check.contains(client, "Enum.KeyCode[SkillConfig.GAMEPAD_OPEN]")
	Check.contains(client, "Enum.KeyCode[SkillConfig.GAMEPAD_CLOSE]")
	Check.contains(client, "SkillConfig.CLOSE_LABEL")
	Check.contains(client, "HudSlots.ritesOrigin")
	Check.contains(client, "characterAlive")
	Check.contains(client, "Humanoid")
	Check.contains(client, "closeTree")
	local main = fs.readFile("src/client/Main.client.luau")
	Check.contains(main, "onShrine = skill.open")
end)

Check.test("QA4 layout draws 17 nodes and 9 of them are sealed", function()
	Check.eq(#SkillConfig.ORDER, 17)
	local sealed = 0
	for _, id in SkillConfig.ORDER do
		local node = SkillConfig.get(id)
		local expected = POSITIONS[id]
		Check.truthy(expected)
		Check.near(node.x, expected[1], 2, id)
		Check.near(node.y, expected[2], 2, id)
		Check.eq(node.currency, "cash", id)
		if id == "h3" then
			Check.eq(node.ring, 1)
			Check.eq(node.sealed, true)
		elseif node.ring == 1 then
			Check.eq(node.sealed, false, id)
		else
			Check.eq(node.sealed, true, id)
		end
		if node.sealed then
			sealed += 1
		end
		local hit = SkillTree.hitSize(node)
		Check.eq(hit * SkillConfig.UI.zoomMin >= SkillConfig.UI.touchMin, true, id)
	end
	Check.eq(sealed, 9)
	Check.eq(SkillConfig.UI.canvas, 2800)
	Check.eq(SkillConfig.UI.node, 96)
	Check.eq(SkillConfig.UI.capstone, 128)
	Check.eq(SkillConfig.get("root").size, 128)
	Check.eq(SkillConfig.get("h8").size, 128)
	Check.eq(SkillConfig.get("l8").size, 128)
	Check.eq(SkillConfig.UI.touchMin >= 44, true)
	Check.eq(SkillConfig.UI.closeHeight >= 44, true)
	Check.eq(SkillConfig.UI.buySeal >= 44, true)
	Check.eq(#SkillConfig.UI.rings, 4)
	Check.eq(SkillConfig.UI.rings[2], 600)
end)

Check.test("QA5 pan and zoom clamp, and a double-click resets the circle", function()
	Check.eq(SkillTree.clampZoom(0.1), SkillConfig.UI.zoomMin)
	Check.eq(SkillTree.clampZoom(3), SkillConfig.UI.zoomMax)
	Check.eq(SkillTree.clampZoom(SkillConfig.UI.zoomDefault), 0.5)
	Check.eq(SkillConfig.UI.zoomMin, 0.35)
	Check.eq(SkillConfig.UI.zoomMax, 1.5)
	Check.near(SkillTree.wheelZoom(0.5, 1), 0.55)
	Check.eq(SkillTree.wheelZoom(0.5, 40), 1.5)
	Check.eq(SkillTree.wheelZoom(0.5, -40), 0.35)
	local farX, farY = SkillTree.clampPan(2000, 0, 1)
	Check.near(farX, SkillConfig.UI.panLimit)
	Check.eq(farY, 0)
	local halfX, halfY = SkillTree.clampPan(2000, 0, 0.5)
	Check.near(halfX, SkillConfig.UI.panLimit * 0.5)
	Check.eq(halfY, 0)
	local keptX, keptY = SkillTree.clampPan(100, 40, 1)
	Check.eq(keptX, 100)
	Check.eq(keptY, 40)
	local panX, panY, zoom = SkillTree.zoomToward(0, 0, 1, 100, 0, 1.1)
	Check.near(panX + 100 * zoom, 100)
	Check.near(panY, 0)
	local resetX, resetY, resetZoom = SkillTree.resetView()
	Check.eq(resetX, 0)
	Check.eq(resetY, 0)
	Check.eq(resetZoom, 0.5)
	Check.eq(SkillConfig.UI.resetSeconds, 0.3)
	Check.eq(SkillTree.pastDrag(5, 0), false)
	Check.eq(SkillTree.pastDrag(6, 0), true)
	Check.eq(SkillConfig.UI.dragThreshold, 6)
end)

Check.test("QA6 a fresh profile owns the root, offers h1 and l1, and seals the outer rites", function()
	local profile = fresh()
	Check.eq(SkillTree.state(profile, "root"), "owned")
	Check.eq(SkillTree.state(profile, "h1"), "available")
	Check.eq(SkillTree.state(profile, "l1"), "available")
	for _, id in LOCKED do
		Check.eq(SkillTree.state(profile, id), "locked", id)
	end
	for _, id in SEALED do
		Check.eq(SkillTree.state(profile, id), "sealed", id)
	end
	local offered = SkillTree.visual("available", false, 1)
	Check.eq(offered.pulse, true)
	local cracked = SkillTree.visual("locked", false, 1)
	Check.eq(cracked.cracks, true)
	Check.eq(cracked.pulse, false)
end)

Check.test("QA7 buying Steady Hand spends 1000 and opens only Long Reach", function()
	local profile = marked(8, 1000)
	local ok, reason = SkillTree.buy(profile, "h1", 1)
	Check.eq(ok, true)
	Check.eq(reason, "ok")
	Check.eq(profile.cash, 0)
	Check.eq(SkillTree.state(profile, "h1"), "owned")
	Check.eq(SkillTree.pathStyle(profile, "root", "h1"), "vein")
	Check.eq(SkillTree.state(profile, "h2"), "available")
	Check.eq(SkillTree.state(profile, "h3"), "sealed")
	Check.eq(SkillTree.state(profile, "h4"), "locked")
	local owned = SkillTree.visual(SkillTree.state(profile, "h1"), false, 1)
	Check.eq(owned.fill, "Blood")
	Check.eq(owned.sparks, true)
	local again, againReason = SkillTree.buy(profile, "h1", 1)
	Check.eq(again, false)
	Check.eq(againReason, "owned")
	Check.eq(profile.cash, 0)
end)

Check.test("QA9 a short purse cracks the seal and the server keeps the cash", function()
	local profile = marked(8, 999)
	local tip = SkillTree.tooltip(profile, "h1")
	Check.eq(tip.buy, "broke")
	Check.eq(tip.need, string.format(SkillConfig.NEED_MORE, NumberFormat.formatCash(1)))
	local before = profile.cash
	local ok, reason = SkillTree.buy(profile, "h1", 0)
	Check.eq(ok, false)
	Check.eq(reason, "afford")
	Check.eq(profile.cash, before)
	local priced = marked(8, 1000)
	Check.eq(SkillTree.buy(priced, "h1", 1), true)
	Check.eq(priced.cash, 0)
	local skipped = marked(8, 50000)
	local blocked, why = SkillTree.buy(skipped, "h2", 1)
	Check.eq(blocked, false)
	Check.eq(why, "prereq")
	Check.eq(skipped.cash, 50000)
	Check.eq(RemoteArgs.skillId("nope"), nil)
	Check.eq(RemoteArgs.skillId(1), nil)
	Check.eq(RemoteArgs.skillId(""), nil)
	Check.eq(RemoteArgs.skillId("h1"), "h1")
	local allowed, at = Debounce.allow(10, 10.24, Economy.PURCHASE_DEBOUNCE_SECONDS)
	Check.eq(allowed, false)
	Check.eq(at, 10)
	local later = Debounce.allow(10, 10.25, Economy.PURCHASE_DEBOUNCE_SECONDS)
	Check.eq(later, true)
	local session = fs.readFile("src/server/PlayerSession.luau")
	local body = between(session, "local function onBuySkill", "local function onReducedMotion")
	Check.contains(body, "allowRequest")
	Check.contains(body, "allowPurchase")
	Check.contains(body, "RemoteArgs.skillId")
	Check.contains(body, "SkillTree.evaluate")
	Check.contains(body, "Transactions.buySkill(session.profile, parsed)")
	Check.eq(string.find(body, "buySkill(session.profile, parsed,", 1, true), nil)
	local client = fs.readFile("src/client/SkillTree.luau")
	local request = between(client, "local function requestBuy", "local function presentIgnite")
	Check.contains(request, "FireServer(nodeId)")
	Check.eq(string.find(request, "FireServer(nodeId,", 1, true), nil)
	Check.contains(client, 'tip.buy == "broke"')
end)

Check.test("QA10 l1 plus l4 multiplies income by 1.15, catch time is 2.25 s, and pad 5 is 1080", function()
	local income = marked(8, 100000)
	local before = Income.perSecond(income)
	Check.eq(SkillTree.buy(income, "l1"), true)
	Check.eq(SkillTree.buy(income, "l2"), true)
	Check.eq(SkillTree.buy(income, "l4"), true)
	Check.near(SkillEffects.skillIncome(income), 0.15)
	Check.near(Income.perSecond(income), before * 1.15)
	local hunter = marked(8, 100000)
	Check.eq(SkillTree.buy(hunter, "h1"), true)
	Check.eq(SkillTree.buy(hunter, "h2"), true)
	Check.eq(SkillTree.buy(hunter, "h4"), true)
	Check.near(SkillEffects.catchSeconds(hunter), 2.25)
	Check.eq(SkillEffects.catchRange(hunter), Economy.CATCH_DISTANCE_STUDS + 2)
	local mason = marked(8, 100000)
	Check.eq(SkillTree.buy(mason, "l1"), true)
	Check.eq(SkillTree.buy(mason, "l2"), true)
	Check.eq(SkillEffects.padCost(mason, 5), 1080)
	Check.eq(SkillEffects.padCost(mason, 6), 2700)
	local sealedMark = marked(8, 0)
	sealedMark.skills = { "h8", "l6" }
	Check.eq(SkillEffects.wildIncome(sealedMark), 0)
	Check.eq(SkillEffects.skillIncome(sealedMark), 0)
end)

Check.test("QA11 Altar Devotion raises altar II from 1.50 to 1.60", function()
	local profile = marked(8, 20000)
	profile.upgrades.boneAltar = 2
	Check.near(SkillEffects.altarMultiplier(profile), 1.5)
	Check.near(Income.multiplier(2), 1.5)
	Check.eq(SkillTree.buy(profile, "l1"), true)
	Check.eq(SkillTree.buy(profile, "l3"), true)
	Check.near(SkillEffects.altarPerLevel(profile), 0.30)
	Check.near(SkillEffects.altarMultiplier(profile), 1.60)
end)

Check.test("QA14 the ignite burst waits for the server and lasts 0.9 s", function()
	local plan = SkillTree.ignitePlan(false)
	Check.eq(plan.play, true)
	Check.eq(plan.total, 0.9)
	Check.eq(plan.scale, true)
	Check.eq(plan.embers, true)
	Check.eq(plan.flow, true)
	Check.eq(SkillTree.shouldIgnite({}, "h1"), true)
	Check.eq(SkillTree.shouldIgnite({ h1 = true }, "h1"), false)
	Check.eq(SkillTree.shouldIgnite({}, "h3"), false)
	Check.eq(SkillTree.shouldIgnite({}, "root"), false)
	local client = fs.readFile("src/client/SkillTree.luau")
	local request = between(client, "local function requestBuy", "local function presentIgnite")
	Check.eq(string.find(request, "presentIgnite", 1, true), nil)
	Check.contains(client, "presentIgnite(id)")
	local apply = between(client, "local function applySkills", "buySeal.Activated")
	Check.contains(apply, "presentIgnite(id)")
end)

Check.test("QA15 reduced motion keeps a colour fade and drops the burst", function()
	local plan = SkillTree.ignitePlan(true)
	Check.eq(plan.scale, false)
	Check.eq(plan.ring, false)
	Check.eq(plan.embers, false)
	Check.eq(plan.sparks, false)
	Check.eq(plan.flow, false)
	Check.eq(plan.fade, true)
	Check.eq(plan.total, 0.15)
	Check.eq(plan.total, UITheme.reducedMotion.maxFade)
	local owned = SkillTree.visual("owned", true, 1)
	Check.eq(owned.sparks, false)
	local offered = SkillTree.visual("available", true, 1)
	Check.eq(offered.pulse, false)
	local vein = SkillTree.pathLook("vein")
	Check.eq(vein.flow, true)
	local client = fs.readFile("src/client/SkillTree.luau")
	Check.contains(client, "isReduced()")
	Check.contains(client, "SkillRules.ignitePlan")
end)

Check.test("the rites circle text stays inside the fonts we draw", function()
	Check.eq(UITheme.textIsSafe(UITheme.sigil), true)
	Check.eq(UITheme.sigil, "+")
	local labels = {
		SkillConfig.TITLE,
		SkillConfig.OPEN_LABEL,
		SkillConfig.CLOSE_LABEL,
		SkillConfig.BUY_LABEL,
		SkillConfig.BOUND_LABEL,
		SkillConfig.SEALED_LINE,
		SkillConfig.HUNTER_LABEL,
		SkillConfig.LAIR_LABEL,
		SkillConfig.NEED_MORE,
		SkillConfig.REQUIRES,
		SkillConfig.OR_JOIN,
	}
	for _, label in labels do
		Check.eq(UITheme.textIsSafe(label), true, label)
	end
	for _, id in SkillConfig.ORDER do
		local node = SkillConfig.get(id)
		Check.eq(UITheme.textIsSafe(node.name), true, node.name)
		Check.eq(UITheme.textIsSafe(node.effect.text), true, node.effect.text)
		Check.eq(UITheme.textIsSafe(node.branchLine), true, id)
	end
	local tree = fs.readFile("src/client/SkillTree.luau")
	Check.eq(string.find(tree, "UITheme.sigil", 1, true) ~= nil, true)
	Check.eq(string.find(tree, utf8.char(10038), 1, true), nil)
	Check.eq(string.find(tree, 'lock.Name = "Lock"', 1, true) ~= nil, true)
	Check.eq(string.find(tree, "lock.Text", 1, true), nil)
	Check.eq(string.find(tree, 'shackle.Name = "Shackle"', 1, true) ~= nil, true)
end)

Check.test("QA16 owned rites survive a mock rejoin", function()
	Check.eq(Save.DATA_VERSION, 10)
	local legacy = Schema.newProfile(10, "starter")
	legacy.dataVersion = 4
	legacy.skills = nil
	local filled = Schema.migrate(legacy)
	Check.truthy(filled)
	Check.eq(filled.dataVersion, Save.DATA_VERSION)
	Check.eq(#filled.skills, 0)

	local messy = Schema.newProfile(10, "starter")
	messy.onboarding.step = 8
	messy.skills = { "h3", "nope", "h1", "h1", "root" }
	local cleaned = Schema.migrate(messy)
	Check.eq(cleaned.skills[1], "h3")
	Check.eq(cleaned.skills[2], "h1")
	Check.eq(#cleaned.skills, 2)
	Check.eq(SkillTree.state(cleaned, "h3"), "sealed")
	Check.eq(SkillTree.state(cleaned, "h1"), "owned")
	Check.near(SkillEffects.catchSeconds(cleaned), Economy.CATCH_SECONDS * 0.9)
	Check.eq(SkillEffects.skillIncome(cleaned), 0)

	local profile = marked(8, 5000)
	Check.eq(SkillTree.buy(profile, "h1"), true)
	local encoded = serde.encode("json", profile)
	local decoded = Schema.migrate(serde.decode("json", encoded))
	Check.eq(decoded.dataVersion, Save.DATA_VERSION)
	Check.eq(decoded.skills[1], "h1")
	Check.eq(decoded.cash, 4000)

	local store = MockDataStore.new()
	local now = 1000
	local clock = function()
		return now
	end
	local key = Save.KEY_PREFIX .. "4"
	store:SetAsync(key, {
		lockJobId = "",
		lockExpiresAt = 0,
		profile = profile,
	})
	local function open(jobId: string)
		return Ledger.open({
			getStore = function()
				return store
			end,
			createMock = function()
				error("the test store is already open")
			end,
			allowMock = function()
				return false
			end,
			jobId = jobId,
			now = clock,
			waitFor = function() end,
			warn = function() end,
		})
	end
	local job = open("job-a")
	local loaded = job.load(4, Schema.newProfile(1, "decoy"))
	Check.eq(loaded.ok, true)
	Check.eq(loaded.profile.skills[1], "h1")
	Check.eq(loaded.profile.cash, 4000)
	Check.eq(SkillTree.state(loaded.profile, "h1"), "owned")
	Check.eq(SkillTree.pathStyle(loaded.profile, "root", "h1"), "vein")
	Check.eq(job.release(4, loaded.profile), true)
	now = 2000
	local rejoined = open("job-b").load(4, Schema.newProfile(1, "decoy"))
	Check.eq(rejoined.ok, true)
	Check.eq(rejoined.profile.skills[1], "h1")
	Check.eq(rejoined.profile.cash, 4000)
	Check.eq(SkillTree.pathStyle(rejoined.profile, "root", "h1"), "vein")
end)

Check.test("QA17 the circle uses only theme tokens and parchment is dark on light", function()
	local files = {
		"src/client/SkillTree.luau",
		"src/shared/Config/SkillConfig.luau",
		"src/shared/Logic/SkillTree.luau",
		"src/shared/Logic/SkillEffects.luau",
		"src/server/SkillEffects.luau",
	}
	for _, path in files do
		local text = fs.readFile(path)
		Check.eq(string.find(text, "Color3.new", 1, true), nil, path)
		Check.eq(string.find(text, "Color3.from", 1, true), nil, path)
		Check.eq(string.find(text, "BrickColor", 1, true), nil, path)
		Check.eq(string.find(text, "Enum.Font", 1, true), nil, path)
		Check.eq(string.find(text, "MarketplaceService", 1, true), nil, path)
		Check.eq(string.match(text, "StreamingEnabled%s*=") == nil, true, path)
		Check.eq(string.match(text, "%.Technology%s*=") == nil, true, path)
	end
	local client = fs.readFile("src/client/SkillTree.luau")
	Check.contains(client, 'UITheme.color("Void")')
	Check.contains(client, 'UITheme.color("Bone")')
	Check.contains(client, 'UITheme.color("Blood")')
	Check.contains(client, '"Gold"')
	Check.contains(client, '"GoldBright"')
	Check.contains(client, '"Soot"')
	Check.contains(client, 'UiFactory.label(tooltip, "display", ui.tooltipTitle, "Void")')
	Check.contains(client, 'BackgroundColor3 = UITheme.color("Bone")')
	Check.eq(UITheme.palette.Void, "0B0A0C")
	Check.eq(UITheme.palette.Blood, "7A0F12")
	Check.eq(UITheme.palette.Gold, "9C7A3C")
	Check.eq(UITheme.palette.Bone, "E8E0CF")
end)

Check.test("QA18 buying every ring-1 rite costs exactly 34000", function()
	local hunter = 0
	local lair = 0
	for _, id in SkillConfig.ORDER do
		local node = SkillConfig.get(id)
		if node.ring == 1 and node.sealed ~= true then
			if node.branch == "Hunter" then
				hunter += node.cost
			elseif node.branch == "Lair" then
				lair += node.cost
			end
		end
	end
	Check.eq(hunter, 9500)
	Check.eq(lair, 24500)
	Check.eq(hunter + lair, 34000)
	Check.eq(SkillTree.ring1Total(), 34000)
	local profile = marked(8, 34000)
	local order = { "h1", "h2", "h4", "l1", "l2", "l3", "l4" }
	for _, id in order do
		local ok, reason = SkillTree.buy(profile, id)
		Check.eq(ok, true, id .. " " .. reason)
	end
	Check.eq(profile.cash, 0)
	Check.eq(#profile.skills, 7)
	for _, id in SEALED do
		local before = profile.cash
		Check.eq(SkillTree.buy(profile, id), false)
		Check.eq(profile.cash, before)
	end
end)

Check.test("QA-A a sealed rite shows the later-moon line and no price or buy seal", function()
	local profile = marked(8, 1000000)
	for _, id in SEALED do
		local tip = SkillTree.tooltip(profile, id)
		Check.eq(tip.title, SkillConfig.get(id).name, id)
		Check.eq(tip.branch ~= nil, true, id)
		Check.eq(tip.sealedLine, "Sealed. This rite wakes in a later moon.", id)
		Check.eq(tip.effect, nil, id)
		Check.eq(tip.cost, nil, id)
		Check.eq(tip.need, nil, id)
		Check.eq(tip.buy, "hidden", id)
	end
	local client = fs.readFile("src/client/SkillTree.luau")
	Check.contains(client, "tip.sealedLine")
	Check.contains(client, 'tip.buy == "hidden"')
end)

Check.test("QA-B a sealed remote is refused and the cash stays put", function()
	local profile = marked(8, 100000)
	for _, id in SEALED do
		local before = profile.cash
		local ok, reason = SkillTree.buy(profile, id, 1)
		Check.eq(ok, false, id)
		Check.eq(reason, "sealed", id)
		Check.eq(profile.cash, before, id)
		Check.eq(RemoteArgs.skillId(id), id)
	end
	Check.eq(#profile.skills, 0)
	local session = fs.readFile("src/server/PlayerSession.luau")
	local body = between(session, "local function onBuySkill", "local function onReducedMotion")
	Check.contains(body, "SkillConfig.SEALED_REFUSAL")
	Check.contains(body, "allowRequest")
	Check.eq(SkillConfig.SEALED_REFUSAL, "This rite is sealed.")
	Check.eq(Remotes.BUY_SKILL, "RequestBuySkill")
end)

Check.test("QA-C Quiet Step costs 6000 after Long Reach and a catch takes 2.25 s", function()
	local node = SkillConfig.get("h4")
	Check.eq(node.cost, 6000)
	Check.eq(node.requires[1], "h2")
	Check.eq(#node.requires, 1)
	Check.eq(node.sealed, false)
	local profile = marked(8, 20000)
	Check.eq(SkillTree.buy(profile, "h1"), true)
	Check.eq(SkillTree.buy(profile, "h2"), true)
	Check.eq(SkillTree.state(profile, "h3"), "sealed")
	Check.eq(SkillTree.state(profile, "h4"), "available")
	local tip = SkillTree.tooltip(profile, "h4")
	Check.eq(tip.buy, "ready")
	Check.eq(tip.cost, NumberFormat.formatCash(6000))
	Check.eq(SkillTree.buy(profile, "h4", 15000), true)
	Check.eq(profile.cash, 20000 - 1000 - 2500 - 6000)
	Check.near(SkillEffects.catchSeconds(profile), 2.25)
	Check.near(Economy.CATCH_SECONDS * (1 - 0.10 - 0.15), 2.25)
end)

Check.test("QA-D sealed nodes never pulse or spark at any zoom", function()
	for _, zoom in { 0.35, 0.5, 1, 1.5 } do
		local look = SkillTree.visual("sealed", false, zoom)
		Check.eq(look.pulse, false, tostring(zoom))
		Check.eq(look.sparks, false, tostring(zoom))
		Check.eq(look.glow, false, tostring(zoom))
		Check.eq(look.flame, false, tostring(zoom))
		Check.eq(look.seal, true, tostring(zoom))
		Check.eq(look.lock, false, tostring(zoom))
	end
	local profile = fresh()
	for _, id in SEALED do
		local style = SkillTree.pathLook(SkillTree.pathStyle(profile, "root", id))
		if SkillConfig.get(id).requires[1] ~= "root" then
			local parentId = SkillConfig.get(id).requires[1]
			style = SkillTree.pathLook(SkillTree.pathStyle(profile, parentId, id))
		end
		Check.eq(style.dashed, true, id)
		Check.eq(style.flow, false, id)
		Check.eq(style.pulse, false, id)
		Check.eq(style.transparency, SkillConfig.UI.sealedPathTransparency, id)
	end
end)

Check.test("QA-E the tree never calls the marketplace", function()
	Check.eq(SkillConfig.RESPEC, false)
	for _, id in SkillConfig.ORDER do
		local node = SkillConfig.get(id)
		Check.eq(node.currency, "cash", id)
		Check.eq(node.robux, nil, id)
	end
	local names = fs.readFile("src/shared/Config/Remotes.luau")
	Check.eq(string.find(names, "Respec", 1, true), nil)
	Check.eq(string.find(names, "Robux", 1, true), nil)
	local files = {
		"src/client/SkillTree.luau",
		"src/shared/Config/SkillConfig.luau",
		"src/shared/Logic/SkillTree.luau",
		"src/server/SkillEffects.luau",
		"src/server/PlayerSession.luau",
	}
	for _, path in files do
		local text = fs.readFile(path)
		Check.eq(string.find(text, "MarketplaceService", 1, true), nil, path)
		Check.eq(string.find(text, "PromptProductPurchase", 1, true), nil, path)
		Check.eq(string.find(text, "ProcessReceipt", 1, true), nil, path)
	end
end)
