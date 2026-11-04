--!strict

_G.LUNE = true

local Check = require("./check")
local NumberFormat = require("../src/shared/Logic/NumberFormat")

Check.test("QA18 full cash below 10,000", function()
	Check.eq(NumberFormat.formatCash(0), "$0")
	Check.eq(NumberFormat.formatCash(25), "$25")
	Check.eq(NumberFormat.formatCash(9999), "$9,999")
	Check.eq(NumberFormat.formatCash(1240), "$1,240")
	Check.eq(NumberFormat.formatCash(11.25), "$11.25")
	Check.eq(NumberFormat.formatCash(17.5), "$17.50")
end)

Check.test("QA18 thousands, millions, and billions", function()
	Check.eq(NumberFormat.formatCash(10000), "$10.0K")
	Check.eq(NumberFormat.formatCash(12345), "$12.3K")
	Check.eq(NumberFormat.formatCash(1234567), "$1.23M")
	Check.eq(NumberFormat.formatCash(4.5e9), "$4.50B")
end)

Check.test("suffix promotion and scientific tail", function()
	Check.eq(NumberFormat.formatCash(999999), "$1.00M")
	Check.eq(NumberFormat.formatCash(1e33), "$1.00Dc")
	Check.eq(NumberFormat.formatCash(1e34), "$1.0e34")
	Check.eq(NumberFormat.formatCash(-12), "-$12")
end)

Check.test("income rate text", function()
	Check.eq(NumberFormat.formatRate(2), "+$2/s")
	Check.eq(NumberFormat.formatRate(5), "+$5/s")
	Check.eq(NumberFormat.formatRate(9), "+$9/s")
	Check.eq(NumberFormat.formatRate(11.25), "+$11.25/s")
	Check.eq(NumberFormat.formatRate(17.5), "+$17.50/s")
end)
