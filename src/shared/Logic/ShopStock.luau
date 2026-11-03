--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Shop = import("../Config/Shop", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Shop")
end)
local Species = import("../Config/Species", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Species")
end)

local ShopStock = {}

local function periodOf(period: number?): number
	if period == nil then
		return Shop.ROTATION_SECONDS
	end
	return period
end

function ShopStock.rotationId(unix: number, period: number?): number
	return math.floor(unix / periodOf(period))
end

function ShopStock.nextRestockUnix(unix: number, period: number?): number
	local span = periodOf(period)
	return (ShopStock.rotationId(unix, span) + 1) * span
end

function ShopStock.secondsRemaining(unix: number, period: number?): number
	return ShopStock.nextRestockUnix(unix, period) - unix
end

function ShopStock.displaySeconds(now: number, nextRestockUnix: number): number
	local remain = nextRestockUnix - now
	if remain < 0 then
		return 0
	end
	return remain
end

function ShopStock.formatCountdown(seconds: number): string
	local remain = seconds
	if remain < 0 then
		remain = 0
	end
	remain = math.floor(remain)
	local minutes = math.floor(remain / 60)
	local secs = remain % 60
	return string.format("%d:%02d", minutes, secs)
end

function ShopStock.rarityPrice(rarity: string): number
	local row = Shop.RARITIES[rarity]
	if row == nil then
		return 0
	end
	return row.baseIncome * row.paybackSeconds
end

function ShopStock.priceFor(speciesId: string): number
	local species = Species.get(speciesId)
	if species == nil then
		return 0
	end
	local row = Shop.RARITIES[species.rarity]
	if row == nil then
		return 0
	end
	return species.baseIncome * row.paybackSeconds
end

function ShopStock.oddsColumns(): { any }
	local columns = {}
	for _, slot in Shop.SLOTS do
		local rows = {}
		local total = 0
		for _, rarity in Shop.RARITY_ORDER do
			local percent = slot.odds[rarity]
			total += percent
			table.insert(rows, {
				rarity = rarity,
				percent = percent,
			})
		end
		table.insert(columns, {
			slot = slot.index,
			name = slot.name,
			rows = rows,
			total = total,
		})
	end
	return columns
end

function ShopStock.refusal(clientRotation: number, serverRotation: number): string?
	if clientRotation ~= serverRotation then
		return Shop.MOVED_ON
	end
	return nil
end

return ShopStock
