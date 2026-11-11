--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local Check = require("./check")
local Economy = require("../src/shared/Config/Economy")
local Names = require("../src/shared/Config/Remotes")
local PedlarBrowse = require("../src/shared/Logic/PedlarBrowse")
local RateLimit = require("../src/shared/Config/RateLimit")
local RateLimiter = require("../src/server/RateLimiter")
local Shop = require("../src/shared/Config/Shop")
local Town = require("../src/shared/Config/Town")

Check.test("a pedlar press in range asks that player to open", function()
	local opened = {}
	local now = 20
	local function fire(player: string)
		table.insert(opened, player)
	end
	local distance = Town.PROMPT_DISTANCE - 2
	local ok, at = PedlarBrowse.tryOpen(
		distance,
		Shop.GATE_STEP,
		Shop.GATE_STEP,
		Town.PROMPT_DISTANCE,
		now,
		nil,
		Economy.PURCHASE_DEBOUNCE_SECONDS
	)
	Check.eq(ok, true)
	Check.eq(at, now)
	if ok then
		fire("keeper")
	end
	Check.eq(opened[1], "keeper")
	Check.eq(#opened, 1)
	local again = PedlarBrowse.tryOpen(
		distance,
		Shop.GATE_STEP,
		Shop.GATE_STEP,
		Town.PROMPT_DISTANCE,
		now + Economy.PURCHASE_DEBOUNCE_SECONDS / 2,
		at,
		Economy.PURCHASE_DEBOUNCE_SECONDS
	)
	Check.eq(again, false)
	Check.eq(#opened, 1)
end)

Check.test("an out of range or early pedlar press does not open", function()
	local far = PedlarBrowse.admit(Town.PROMPT_DISTANCE + 1, Shop.GATE_STEP, Shop.GATE_STEP, Town.PROMPT_DISTANCE)
	Check.eq(far, "distance")
	local early = PedlarBrowse.admit(1, Shop.GATE_STEP - 1, Shop.GATE_STEP, Town.PROMPT_DISTANCE)
	Check.eq(early, "step")
	local missing = PedlarBrowse.admit(nil, Shop.GATE_STEP, Shop.GATE_STEP, Town.PROMPT_DISTANCE)
	Check.eq(missing, "distance")
	local ready = PedlarBrowse.admit(Town.PROMPT_DISTANCE, Shop.GATE_STEP, Shop.GATE_STEP, Town.PROMPT_DISTANCE)
	Check.eq(ready, "ok")
end)

Check.test("pedlar open spam is dropped by the shared limiter", function()
	RateLimiter.reset()
	local name = Names.REQUEST_PEDLAR_OPEN
	Check.eq(RateLimit.perSecond(name), RateLimit.DEFAULT_PER_SECOND)
	local capacity = RateLimit.capacity(name)
	for _ = 1, capacity do
		Check.eq(RateLimiter.consume(7, name, 0).allowed, true)
	end
	local overflow = RateLimiter.consume(7, name, 0)
	Check.eq(overflow.allowed, false)
	Check.eq(overflow.error, "rate_limited")
	local session = fs.readFile("src/server/PlayerSession.luau")
	Check.contains(session, "listen(Names.REQUEST_PEDLAR_OPEN,")
	Check.contains(session, "grantPedlarOpen")
	Check.eq(string.find(session, "OnServerEvent", 1, true), nil)
end)

Check.test("the shop frame becomes visible only when the server says so", function()
	local root = { Visible = false }
	PedlarBrowse.reveal(root)
	Check.eq(root.Visible, true)
	local shop = fs.readFile("src/client/PedlarShop.luau")
	Check.contains(shop, "Shop.OPEN_TOKEN")
	Check.contains(shop, "PedlarBrowse.reveal")
	Check.contains(shop, "showFromServer")
	local interactions = fs.readFile("src/client/Interactions.luau")
	Check.contains(interactions, "names.REQUEST_PEDLAR_OPEN")
	Check.contains(interactions, "PromptTriggered")
	Check.contains(interactions, "gui.Adornee = parent")
	Check.contains(interactions, "gui.Parent = playerGui")
	Check.eq(string.find(interactions, "town.onPedlar", 1, true), nil)
	local server = fs.readFile("src/server/Pedlar.luau")
	Check.contains(server, "PromptTriggered")
	Check.contains(server, "Town.PEDLAR_PROMPT_NAME")
end)
