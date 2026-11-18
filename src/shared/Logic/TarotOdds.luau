--!strict

-- One weight table feeds the roll and the odds the player sees.
-- Percents are hundredths of a percent. Leftover hundredths go to the
-- largest remainders so the shown table adds to exactly 100%.

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local TarotCases = import("../Config/TarotCases", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("TarotCases")
end)
local NumberFormat = import("./NumberFormat", function()
	return script.Parent:WaitForChild("NumberFormat")
end)

local TarotOdds = {}

function TarotOdds.percentText(basis: number): string
	local hundredths = basis % 100
	local whole = math.floor(basis / 100)
	if hundredths == 0 then
		return tostring(whole) .. "%"
	end
	return string.format("%d.%02d%%", whole, hundredths)
end

function TarotOdds.percents(rows: { any }): { any }
	local total = 0
	for _, row in rows do
		total += row.weight
	end
	local shown = {}
	local fractions = {}
	local assigned = 0
	local scale = TarotCases.PERCENT_BASIS
	for index, row in rows do
		local exact = 0
		if total > 0 then
			exact = row.weight * scale / total
		end
		local basis = math.floor(exact)
		assigned += basis
		table.insert(shown, {
			rarity = row.rarity,
			weight = row.weight,
			basis = basis,
		})
		table.insert(fractions, {
			index = index,
			frac = exact - basis,
			weight = row.weight,
		})
	end
	table.sort(fractions, function(a, b)
		if a.frac == b.frac then
			if a.weight == b.weight then
				return a.index < b.index
			end
			return a.weight > b.weight
		end
		return a.frac > b.frac
	end)
	local left = scale - assigned
	local cursor = 1
	while left > 0 and #fractions > 0 do
		local pick = fractions[cursor]
		shown[pick.index].basis += 1
		left -= 1
		cursor += 1
		if cursor > #fractions then
			cursor = 1
		end
	end
	for _, row in shown do
		row.text = TarotOdds.percentText(row.basis)
	end
	return shown
end

function TarotOdds.live(case: any, pityCount: number): { any }
	local within = case.pity.within
	local due = type(pityCount) == "number" and pityCount + 1 >= within
	local floor = TarotCases.RANK[case.pity.rarity] or 1
	local rows = {}
	for _, row in case.weights do
		local rank = TarotCases.RANK[row.rarity] or 0
		if row.weight > 0 and (due ~= true or rank >= floor) then
			table.insert(rows, {
				rarity = row.rarity,
				weight = row.weight,
			})
		end
	end
	if #rows == 0 then
		table.insert(rows, {
			rarity = case.pity.rarity,
			weight = 1,
		})
	end
	return rows
end

function TarotOdds.disclose(case: any, pityCount: number): { any }
	return TarotOdds.percents(TarotOdds.live(case, pityCount))
end

function TarotOdds.pick(rows: { any }, rng: any): string
	local total = 0
	for _, row in rows do
		total += row.weight
	end
	if total < 1 then
		return rows[1].rarity
	end
	local roll = rng:NextInteger(1, total)
	local cursor = 0
	for _, row in rows do
		cursor += row.weight
		if roll <= cursor then
			return row.rarity
		end
	end
	return rows[#rows].rarity
end

function TarotOdds.inWindow(case: any, now: number): boolean
	if case.kind ~= "event" then
		return true
	end
	if type(now) ~= "number" or type(case.startsAt) ~= "number" or type(case.endsAt) ~= "number" then
		return false
	end
	return now >= case.startsAt and now < case.endsAt
end

function TarotOdds.endText(case: any): string
	if case.kind ~= "event" or type(case.endsAt) ~= "number" then
		return ""
	end
	local stamp = os.date("!*t", case.endsAt)
	if type(stamp) ~= "table" then
		return ""
	end
	return string.format("Ends %04d-%02d-%02d %02d:%02d UTC", stamp.year, stamp.month, stamp.day, stamp.hour, stamp.min)
end

function TarotOdds.pityLine(case: any, pityCount: number): string
	local within = case.pity.within
	local count = pityCount
	if type(count) ~= "number" or count < 0 then
		count = 0
	end
	local left = within - count
	if left < 1 then
		left = 1
	end
	if left > within then
		left = within
	end
	return string.format("Guaranteed %s or better within %d opens", case.pity.rarity, left)
end

function TarotOdds.duplicateLine(case: any): string
	local prefix = if case.placeholder == true then TarotCases.PLACEHOLDER_RULE else TarotCases.DUPLICATE_RULE
	local parts = {}
	for _, card in case.pool do
		table.insert(parts, card.name .. " " .. NumberFormat.formatCash(card.duplicateCash))
	end
	return prefix .. " " .. table.concat(parts, ", ")
end

function TarotOdds.pityCount(profile: any, family: string): number
	local pity = profile.tarot.familyPity
	if type(pity) ~= "table" then
		return 0
	end
	local count = pity[family]
	if type(count) ~= "number" then
		return 0
	end
	return count
end

return TarotOdds
