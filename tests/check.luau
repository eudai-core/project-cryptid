--!strict

local process = require("@lune/process")

local Check = {}
local passed = 0
local failed = 0

function Check.eq(actual: any, expected: any, message: string?)
	if actual ~= expected then
		error(
			(message or "expected match")
				.. "\n  actual:   "
				.. tostring(actual)
				.. "\n  expected: "
				.. tostring(expected),
			2
		)
	end
end

function Check.near(actual: number, expected: number, epsilon: number?, message: string?)
	local limit = epsilon or 0.001
	if math.abs(actual - expected) > limit then
		error(
			(message or "expected near")
				.. "\n  actual:   "
				.. tostring(actual)
				.. "\n  expected: "
				.. tostring(expected),
			2
		)
	end
end

function Check.truthy(value: any, message: string?)
	if not value then
		error(message or "expected truthy", 2)
	end
end

function Check.contains(haystack: string, needle: string)
	if string.find(haystack, needle, 1, true) == nil then
		error("missing '" .. needle .. "' in '" .. haystack .. "'", 2)
	end
end

function Check.test(name: string, fn: () -> ())
	local ok, err = pcall(fn)
	if ok then
		passed += 1
		print("PASS " .. name)
	else
		failed += 1
		print("FAIL " .. name)
		print(tostring(err))
	end
end

function Check.finish()
	print(string.format("%d passed, %d failed", passed, failed))
	if failed > 0 then
		process.exit(1)
	end
end

return Check
