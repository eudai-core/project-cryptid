--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local Check = require("./check")
local UITheme = require("../src/shared/UITheme")

local SPEC_PALETTE = {
	Void = "0B0A0C",
	Ash = "1A1719",
	Soot = "2A2427",
	Blood = "7A0F12",
	BloodHover = "94171B",
	Gold = "9C7A3C",
	GoldBright = "C9A55A",
	Bone = "E8E0CF",
	BoneDim = "A79F90",
	Rift = "7FA34A",
}

Check.test("QA15 palette tokens match the spec", function()
	for token, hex in SPEC_PALETTE do
		Check.eq(UITheme.palette[token], hex, token)
	end
	Check.eq(UITheme.rarity.Common, "BoneDim")
	Check.eq(UITheme.rarity.Epic, "Blood")
	Check.eq(UITheme.rarity.Legendary, "GoldBright")
	Check.eq(UITheme.rarity.Mythic, "Rift")
	Check.eq(UITheme.shape.cornerPx, 4)
	Check.eq(UITheme.shape.plaqueSize.desktop.w, 320)
	Check.eq(UITheme.shape.plaqueSize.desktop.h, 72)
	Check.eq(UITheme.shape.plaqueSize.mobile.w, 240)
	Check.eq(UITheme.shape.plaqueSize.mobile.h, 60)
	Check.eq(UITheme.shape.plaqueTopPx, 24)
	Check.eq(UITheme.shape.goalBanner.topPx, 0)
	Check.eq(UITheme.shape.goalBanner.desktop.h < 168, true)
	Check.eq(UITheme.shape.goalBanner.titleDesktop >= UITheme.text.minSize, true)
	Check.eq(UITheme.shape.goalBanner.titleMobile >= UITheme.text.minSize, true)
	Check.eq(UITheme.rarity.Uncommon, "Moss")
	Check.eq(UITheme.rarity.Rare, "TarnishedSilver")
	Check.eq(UITheme.fonts.display.family, "GrenzeGotisch")
	Check.eq(UITheme.fonts.header.family, "Garamond")
	Check.eq(UITheme.fonts.header.weight, "Bold")
	Check.eq(UITheme.fonts.body.family, "Merriweather")
	Check.eq(UITheme.fonts.number.family, "Oswald")
	Check.eq(UITheme.fonts.number.plaqueDesktop, 28)
	Check.eq(UITheme.fonts.income.desktop, 16)
	Check.eq(UITheme.text.minSize, 14)
	Check.eq(UITheme.text.scaled, false)
	for _, hex in UITheme.palette do
		local red = tonumber(string.sub(hex, 1, 2), 16) or 0
		local green = tonumber(string.sub(hex, 3, 4), 16) or 0
		local blue = tonumber(string.sub(hex, 5, 6), 16) or 0
		local purple = red > 140 and blue > 140 and green < 100
		Check.eq(purple, false, hex)
	end
end)

Check.test("QA17 reduced motion drops slide scale float and count", function()
	local hover = UITheme.resolveMotion("buttonHover", true)
	Check.near(hover.duration, 0.10)
	local press = UITheme.resolveMotion("buttonPress", true)
	Check.eq(press.duration, 0)
	Check.eq(press.allowScale, false)
	local slide = UITheme.resolveMotion("goalIn", true)
	Check.eq(slide.duration, 0)
	Check.eq(slide.allowOffset, false)
	local float = UITheme.resolveMotion("incomeFloat", true)
	Check.eq(float.allowFloat, false)
	Check.eq(float.duration, 0)
	local count = UITheme.resolveMotion("cashCount", true)
	Check.eq(count.allowCount, false)
	local fade = UITheme.resolveMotion("panelClose", true)
	Check.eq(fade.duration <= 0.15, true)
	local open = UITheme.resolveMotion("panelOpen", true)
	Check.eq(open.allowOffset, false)
	Check.eq(open.duration <= 0.15, true)
	local flash = UITheme.resolveMotion("goalComplete", true)
	Check.eq(flash.duration <= 0.15, true)
	local full = UITheme.resolveMotion("goalIn", false)
	Check.near(full.duration, 0.35)
	Check.eq(full.allowOffset, true)
	Check.eq(UITheme.motion.buttonHover.duration, 0.10)
	Check.eq(UITheme.motion.buttonPress.duration, 0.12)
	Check.eq(UITheme.motion.panelOpen.duration, 0.25)
	Check.eq(UITheme.motion.panelClose.duration, 0.15)
	Check.eq(UITheme.motion.cashCount.duration, 0.40)
	Check.eq(UITheme.motion.incomeFloat.duration, 0.80)
	Check.eq(UITheme.motion.goalIn.duration, 0.35)
	Check.eq(UITheme.motion.goalComplete.duration, 0.50)
	Check.eq(UITheme.motion.cashCount.skipUnderFraction, 0.01)
	Check.eq(UITheme.motion.buttonPress.scale, 0.96)
	Check.eq(UITheme.motion.incomeFloat.offset, 20)
end)

local function filesUnder(dir: string, into: { string })
	for _, name in fs.readDir(dir) do
		local path = dir .. "/" .. name
		if fs.isDir(path) then
			filesUnder(path, into)
		elseif string.match(name, "%.luau$") ~= nil then
			table.insert(into, path)
		end
	end
end

Check.test("QA14 and QA15 source guards", function()
	local files = {}
	filesUnder("src", files)
	Check.truthy(#files > 0)
	local shop = "src/server/MonetisationService.luau"
	for _, path in files do
		local text = fs.readFile(path)
		if path ~= shop then
			Check.eq(string.find(text, "MarketplaceService", 1, true), nil, path)
			Check.eq(string.find(text, "PromptProductPurchase", 1, true), nil, path)
			Check.eq(string.find(text, "ProcessReceipt", 1, true), nil, path)
		end
		local allowsColor = path == "src/shared/UITheme.luau"
		if not allowsColor then
			Check.eq(string.find(text, "Color3.new", 1, true), nil, path)
			Check.eq(string.find(text, "Color3.from", 1, true), nil, path)
			Check.eq(string.find(text, "BrickColor", 1, true), nil, path)
		end
		local allowsFont = path == "src/client/ThemeBind.luau"
		if not allowsFont then
			Check.eq(string.find(text, "Enum.Font", 1, true), nil, path)
		end
	end
end)
