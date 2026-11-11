--!strict

_G.LUNE = true

local fs = require("@lune/fs")

local Check = require("./check")
local Plots = require("../src/shared/Config/Plots")
local Shop = require("../src/shared/Config/Shop")
local ShopStock = require("../src/shared/Logic/ShopStock")
local SkillConfig = require("../src/shared/Config/SkillConfig")
local SkillRules = require("../src/shared/Logic/SkillTree")
local UITheme = require("../src/shared/UITheme")

local TOUCH = UITheme.shape.touchPx

local function channel(value: number): number
	local unit = value / 255
	if unit <= 0.04045 then
		return unit / 12.92
	end
	return ((unit + 0.055) / 1.055) ^ 2.4
end

local function luminance(hex: string): number
	local red = tonumber(string.sub(hex, 1, 2), 16) or 0
	local green = tonumber(string.sub(hex, 3, 4), 16) or 0
	local blue = tonumber(string.sub(hex, 5, 6), 16) or 0
	return 0.2126 * channel(red) + 0.7152 * channel(green) + 0.0722 * channel(blue)
end

local function contrast(textHex: string, fillHex: string): number
	local lighter = math.max(luminance(textHex), luminance(fillHex))
	local darker = math.min(luminance(textHex), luminance(fillHex))
	return (lighter + 0.05) / (darker + 0.05)
end

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

local function trim(value: string): string
	return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

local function splitTop(expr: string, op: string): (string?, string?)
	local depth = 0
	local index = #expr
	while index >= 1 do
		local char = string.sub(expr, index, index)
		if char == ")" then
			depth += 1
		elseif char == "(" then
			depth -= 1
		elseif depth == 0 and string.sub(expr, index, index + #op - 1) == op then
			local left = trim(string.sub(expr, 1, index - 1))
			local right = trim(string.sub(expr, index + #op))
			if left ~= "" and right ~= "" then
				return left, right
			end
		end
		index -= 1
	end
	return nil, nil
end

local function lookup(path: string, env: { [string]: any }): number?
	local direct = env[path]
	if type(direct) == "number" then
		return direct
	end
	local cursor: any = nil
	local rest = path
	local head = string.match(path, "^([%w_]+)%.")
	if head == "UITheme" then
		cursor = UITheme
		rest = string.sub(path, #"UITheme" + 2)
	elseif head ~= nil and type(env[head]) == "table" then
		cursor = env[head]
		rest = string.sub(path, #head + 2)
	elseif type(env[path]) == "table" then
		return nil
	else
		return nil
	end
	for piece in string.gmatch(rest, "[%w_]+") do
		if type(cursor) ~= "table" then
			return nil
		end
		cursor = cursor[piece]
	end
	if type(cursor) == "number" then
		return cursor
	end
	return nil
end

local function evalExpr(expr: string, env: { [string]: any }): number
	local text = trim(expr)
	local thenPart, elsePart = string.match(text, "^if%s+.-%s+then%s+(.-)%s+else%s+(.+)$")
	if thenPart ~= nil and elsePart ~= nil then
		return math.min(evalExpr(thenPart, env), evalExpr(elsePart, env))
	end
	local maxLeft, maxRight = string.match(text, "^math%.max%((.+),(.+)%)$")
	if maxLeft ~= nil and maxRight ~= nil then
		return math.max(evalExpr(maxLeft, env), evalExpr(maxRight, env))
	end
	if string.sub(text, 1, 1) == "-" then
		return -evalExpr(string.sub(text, 2), env)
	end
	local left, right = splitTop(text, "+")
	if left ~= nil and right ~= nil then
		return evalExpr(left, env) + evalExpr(right, env)
	end
	left, right = splitTop(text, "*")
	if left ~= nil and right ~= nil then
		return evalExpr(left, env) * evalExpr(right, env)
	end
	local number = tonumber(text)
	if number ~= nil then
		return number
	end
	local found = lookup(text, env)
	if found == nil then
		error("cannot resolve '" .. text .. "'")
	end
	return found
end

local function axis(scale: number, offset: number): number
	if scale >= 1 then
		return TOUCH
	end
	return offset
end

local function readSize(expr: string, env: { [string]: any }): (number, number)
	local text = trim(expr)
	local width, height = string.match(text, "^UDim2%.fromOffset%((.+),(.+)%)$")
	if width ~= nil and height ~= nil then
		return evalExpr(width, env), evalExpr(height, env)
	end
	local xScale, yScale = string.match(text, "^UDim2%.fromScale%((.+),(.+)%)$")
	if xScale ~= nil and yScale ~= nil then
		return axis(evalExpr(xScale, env), 0), axis(evalExpr(yScale, env), 0)
	end
	local xs, xo, ys, yo = string.match(text, "^UDim2%.new%((.+),(.+),(.+),(.+)%)$")
	if xs ~= nil and xo ~= nil and ys ~= nil and yo ~= nil then
		return axis(evalExpr(xs, env), evalExpr(xo, env)), axis(evalExpr(ys, env), evalExpr(yo, env))
	end
	error("unparsed size '" .. text .. "'")
end

local function buttonNames(source: string): { [string]: boolean }
	local names: { [string]: boolean } = {}
	for name in string.gmatch(source, '([%w_]+)%s*=%s*Instance%.new%(%s*"TextButton"%s*%)') do
		names[name] = true
	end
	for name in string.gmatch(source, "([%w_]+)%s*=%s*UiFactory%.button%(") do
		names[name] = true
	end
	for name in string.gmatch(source, "([%w_]+)%s*:%s*TextButton") do
		names[name] = true
	end
	return names
end

local function buttonEnv(source: string): { [string]: any }
	local env: { [string]: any } = {}
	for name, rhs in string.gmatch(source, "local%s+([%w_]+)%s*=%s*([^\n]+)") do
		local path = string.match(rhs, "^(UITheme%.shape%.[%w_]+)")
		if path ~= nil then
			local cursor: any = UITheme.shape
			for piece in string.gmatch(string.sub(path, #"UITheme.shape" + 2), "[%w_]+") do
				if type(cursor) == "table" then
					cursor = cursor[piece]
				end
			end
			if type(cursor) == "number" or type(cursor) == "table" then
				env[name] = cursor
			end
		elseif string.match(rhs, "^Plots%.RETURN_BUTTON") ~= nil then
			env[name] = Plots.RETURN_BUTTON
		elseif string.match(rhs, "^SkillConfig%.UI") ~= nil then
			env[name] = SkillConfig.UI
		elseif string.find(rhs, "hitSize", 1, true) ~= nil then
			env[name] = TOUCH
		end
	end
	return env
end

Check.test("every interactive button is at least touchPx", function()
	Check.eq(TOUCH, 44)
	Check.eq(UITheme.shape.goalBanner.buttonH, TOUCH)
	Check.eq(Plots.RETURN_BUTTON.height >= TOUCH, true)
	Check.eq(Plots.RETURN_BUTTON.steadyHeight >= TOUCH, true)
	Check.eq(SkillConfig.UI.touchMin >= TOUCH, true)
	Check.eq(SkillConfig.UI.closeHeight >= TOUCH, true)
	for _, id in SkillConfig.ORDER do
		local node = SkillConfig.get(id)
		local hit = SkillRules.hitSize(node)
		Check.eq(hit * SkillConfig.UI.zoomMin >= TOUCH, true, id)
	end
	local files = {}
	filesUnder("src/client", files)
	local seen = 0
	for _, path in files do
		local source = fs.readFile(path)
		local names = buttonNames(source)
		local env = buttonEnv(source)
		for name in names do
			local from = 1
			while true do
				local at = string.find(source, name .. ".Size%s*=%s*", from)
				if at == nil then
					break
				end
				local lineEnd = string.find(source, "\n", at) or #source
				local line = string.sub(source, at, lineEnd - 1)
				local expr = string.match(line, "Size%s*=%s*(.+)$")
				if expr == nil then
					error(path .. " missing size expression for " .. name)
				end
				local width, height = readSize(expr, env)
				Check.eq(width >= TOUCH, true, path .. " " .. name .. " width " .. tostring(width) .. " from " .. expr)
				Check.eq(
					height >= TOUCH,
					true,
					path .. " " .. name .. " height " .. tostring(height) .. " from " .. expr
				)
				seen += 1
				from = lineEnd
			end
		end
	end
	Check.eq(seen > 0, true)
end)

Check.test("rarity chip text meets WCAG AA against its fill", function()
	Check.eq(UITheme.palette.MossText, "8FAE78")
	Check.eq(UITheme.chipFor("Epic").fill, "Blood")
	Check.eq(UITheme.chipFor("Epic").text, "Bone")
	Check.eq(UITheme.chipFor("Uncommon").text, "MossText")
	for _, rarity in Shop.RARITY_ORDER do
		local chip = UITheme.chipFor(rarity)
		local ratio = contrast(UITheme.palette[chip.text], UITheme.palette[chip.fill])
		Check.eq(ratio >= 4.5, true, rarity .. " " .. string.format("%.2f", ratio))
	end
	local client = fs.readFile("src/client/PedlarShop.luau")
	local tease = fs.readFile("src/client/RarityTease.luau")
	Check.contains(client, "UiFactory.rarityChip")
	Check.contains(client, "UiFactory.applyChip")
	Check.contains(tease, "UiFactory.rarityChip")
	Check.contains(tease, "UiFactory.applyChip")
end)

Check.test("pedlar details shows the server odds exactly", function()
	Check.eq(Shop.DETAILS, "Details")
	Check.eq(Shop.ODDS_NOTE, "Buying never changes the stock.")
	local columns = ShopStock.oddsColumns()
	Check.eq(#columns, #Shop.SLOTS)
	for index, column in columns do
		local slot = Shop.SLOTS[index]
		Check.eq(column.name, slot.name)
		Check.eq(column.total, 100)
		local summed = 0
		for _, row in column.rows do
			Check.eq(row.percent, slot.odds[row.rarity], column.name .. " " .. row.rarity)
			summed += row.percent
		end
		Check.eq(summed, column.total)
	end
	local client = fs.readFile("src/client/PedlarShop.luau")
	Check.contains(client, "Shop.DETAILS")
	Check.contains(client, "Shop.ODDS_NOTE")
	Check.contains(client, "ShopStock.oddsColumns")
	Check.contains(client, "tostring(row.percent)")
	Check.eq(string.find(client, "OddsLink", 1, true), nil)
	Check.eq(string.find(client, "UITheme.sigil", 1, true), nil)
	Check.contains(client, "CryptidModels.get")
	Check.eq(UITheme.shape.pedlar.pricePx >= UITheme.shape.pedlar.namePx, true)
	Check.eq(UITheme.shape.pedlar.namePx >= UITheme.text.minSize, true)
	Check.eq(UITheme.shape.pedlar.incomePx >= UITheme.text.minSize, true)
	Check.eq(UITheme.shape.pedlar.detailsW >= TOUCH, true)
end)

Check.test("calm motion names the reduced-motion control and says why", function()
	Check.eq(UITheme.copy.menu, "Menu")
	Check.eq(UITheme.copy.calmOff, "Calm motion: Off")
	Check.eq(UITheme.copy.calmOn, "Calm motion: On")
	Check.contains(UITheme.copy.calmReason, "still")
	local menu = fs.readFile("src/client/HudMenu.luau")
	Check.contains(menu, "UITheme.copy.calmReason")
	Check.contains(menu, "UITheme.copy.calmOff")
	Check.contains(menu, "UITheme.copy.calmOn")
	Check.contains(menu, "UITheme.shape.offeringPip")
	Check.contains(menu, 'UITheme.color("Gold")')
	local main = fs.readFile("src/client/Main.client.luau")
	Check.contains(main, "REDUCED_MOTION")
	Check.eq(string.find(main, "Steady gaze", 1, true), nil)
end)
