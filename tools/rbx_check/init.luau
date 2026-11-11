-- Offline Rojo checks. See LICENSE-THIRDPARTY for the MIT notice.
--!strict

local fs = require("@lune/fs")
local process = require("@lune/process")

local RULES = {
	"remote_validation",
	"client_authority",
	"hot_path_yield",
	"hot_file_alloc",
	"datastore_key",
	"deprecated_api",
	"wait_usage",
	"instance_parent",
	"magic_number",
}

local USER_ID_DIGITS = 19
local KEY_LIMIT = 50
local MAGIC_ASSIGN_MIN = 100
local MAGIC_ANY_MIN = 1000

local HOT_EVENTS = { "Heartbeat", "RenderStepped", "PreRender", "PreSimulation", "PostSimulation", "Stepped" }

local MAGIC_SKIP = {
	"/Config/",
	"UITheme.luau",
	"Builder.luau",
	"/Dev/",
	"MockDataStore.luau",
	"SeededRng.luau",
	"ShopSalt.luau",
	"NumberFormat.luau",
	"Wisp.luau",
	"RiftGlow.luau",
	"LightingSetup.luau",
	"CryptidModels.luau",
}

local KEY_FUNCTIONS = {
	key = true,
	profileKey = true,
	realKey = true,
	sessionKey = true,
}

type Literal = { start: number, stop: number, value: string }
type Finding = { rule: string, path: string, line: number, message: string }
type Fn = {
	name: string?,
	file: string,
	keyStart: number,
	bodyStart: number,
	bodyEnd: number,
	paramNames: { string },
	signatureLine: number,
}

local function join(left: string, right: string): string
	if string.sub(left, -1) == "/" then
		return left .. right
	end
	return left .. "/" .. right
end

local function lineOf(source: string, index: number): number
	local line = 1
	local stop = math.min(index, #source)
	for i = 1, stop do
		if string.sub(source, i, i) == "\n" then
			line += 1
		end
	end
	return line
end

local function trim(value: string): string
	return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

local function isIdentChar(char: string): boolean
	return string.match(char, "[%w_]") ~= nil
end

local function maskSource(source: string): (string, { Literal })
	local literals: { Literal } = {}
	local out: { string } = {}
	local i = 1
	local n = #source

	local function put(chunk: string)
		for p = 1, #chunk do
			local char = string.sub(chunk, p, p)
			if char == "\n" then
				table.insert(out, "\n")
			else
				table.insert(out, " ")
			end
		end
	end

	while i <= n do
		local two = string.sub(source, i, i + 1)
		local longOpen = string.match(source, "^%[(=*)%[", i)
		if two == "--" then
			local eqs = string.match(source, "^%-%-%[(=*)%[", i)
			if eqs ~= nil then
				local closer = "]" .. eqs .. "]"
				local finish = string.find(source, closer, i + 4 + #eqs, true)
				local stop = if finish == nil then n else finish + #closer - 1
				put(string.sub(source, i, stop))
				i = stop + 1
			else
				local finish = string.find(source, "\n", i, true)
				local stop = if finish == nil then n else finish - 1
				put(string.sub(source, i, stop))
				i = stop + 1
			end
		elseif longOpen ~= nil and two ~= "--" then
			local eqs = longOpen
			local closer = "]" .. eqs .. "]"
			local contentStart = i + 2 + #eqs
			local finish = string.find(source, closer, contentStart, true)
			local stop = if finish == nil then n else finish + #closer - 1
			local value = if finish == nil
				then string.sub(source, contentStart)
				else string.sub(source, contentStart, finish - 1)
			table.insert(literals, { start = i, stop = stop, value = value })
			put(string.sub(source, i, stop))
			i = stop + 1
		elseif string.sub(source, i, i) == '"' or string.sub(source, i, i) == "'" then
			local quote = string.sub(source, i, i)
			local j = i + 1
			local value = {}
			while j <= n do
				local char = string.sub(source, j, j)
				if char == "\\" then
					table.insert(value, string.sub(source, j + 1, j + 1))
					j += 2
				elseif char == quote then
					j += 1
					break
				else
					table.insert(value, char)
					j += 1
				end
			end
			table.insert(literals, { start = i, stop = j - 1, value = table.concat(value) })
			put(string.sub(source, i, j - 1))
			i = j
		else
			table.insert(out, string.sub(source, i, i))
			i += 1
		end
	end

	return table.concat(out), literals
end

local function scanFunctions(file: string, masked: string): { Fn }
	local functions: { Fn } = {}
	local stack: {
		{
			kind: string,
			closer: string,
			awaitingDo: boolean,
			name: string?,
			keyStart: number,
			bodyStart: number,
			signatureLine: number,
			paramNames: { string },
		}
	} =
		{}
	local i = 1
	local n = #masked

	local function skipSpace(index: number): number
		while index <= n and string.match(string.sub(masked, index, index), "%s") do
			index += 1
		end
		return index
	end

	local function readName(index: number): (number, string?)
		index = skipSpace(index)
		if index <= n and string.sub(masked, index, index) == "(" then
			return index, nil
		end
		local start = index
		while index <= n do
			local char = string.sub(masked, index, index)
			if isIdentChar(char) or char == "." or char == ":" then
				index += 1
			else
				break
			end
		end
		if index == start then
			return index, nil
		end
		return index, string.sub(masked, start, index - 1)
	end

	local function readParams(index: number): (number, { string })
		local names: { string } = {}
		if string.sub(masked, index, index) ~= "(" then
			return index, names
		end
		local depth = 1
		local brace = 0
		local piece = {}
		local pieces: { string } = {}
		local j = index + 1
		while j <= n and depth > 0 do
			local char = string.sub(masked, j, j)
			if char == "(" then
				depth += 1
				if depth > 1 then
					table.insert(piece, char)
				end
			elseif char == ")" then
				depth -= 1
				if depth > 0 then
					table.insert(piece, char)
				elseif #piece > 0 then
					table.insert(pieces, table.concat(piece))
				end
			elseif char == "{" then
				brace += 1
				table.insert(piece, char)
			elseif char == "}" then
				brace -= 1
				table.insert(piece, char)
			elseif char == "," and depth == 1 and brace == 0 then
				table.insert(pieces, table.concat(piece))
				piece = {}
			else
				table.insert(piece, char)
			end
			j += 1
		end
		for _, raw in pieces do
			local name = string.match(trim(raw), "^([%w_]+)")
			if name == nil and string.match(trim(raw), "^%.%.%.") then
				name = "..."
			end
			if name ~= nil then
				table.insert(names, name)
			end
		end
		return j, names
	end

	while i <= n do
		local char = string.sub(masked, i, i)
		if not isIdentChar(char) then
			i += 1
			continue
		end
		local start = i
		while i <= n and isIdentChar(string.sub(masked, i, i)) do
			i += 1
		end
		local word = string.sub(masked, start, i - 1)
		local top = stack[#stack]
		if word == "do" and top ~= nil and top.awaitingDo then
			top.awaitingDo = false
		elseif word == "function" then
			local afterName, name = readName(i)
			local afterParams, params = readParams(skipSpace(afterName))
			table.insert(stack, {
				kind = "function",
				closer = "end",
				awaitingDo = false,
				name = name,
				keyStart = start,
				bodyStart = afterParams,
				signatureLine = lineOf(masked, start),
				paramNames = params,
			})
			i = afterParams
		elseif word == "if" or word == "do" then
			table.insert(stack, {
				kind = word,
				closer = "end",
				awaitingDo = false,
				name = nil,
				keyStart = start,
				bodyStart = i,
				signatureLine = 0,
				paramNames = {},
			})
		elseif word == "for" or word == "while" then
			table.insert(stack, {
				kind = word,
				closer = "end",
				awaitingDo = true,
				name = nil,
				keyStart = start,
				bodyStart = i,
				signatureLine = 0,
				paramNames = {},
			})
		elseif word == "repeat" then
			table.insert(stack, {
				kind = word,
				closer = "until",
				awaitingDo = false,
				name = nil,
				keyStart = start,
				bodyStart = i,
				signatureLine = 0,
				paramNames = {},
			})
		elseif top ~= nil and word == top.closer then
			local frame = table.remove(stack)
			if frame ~= nil and frame.kind == "function" then
				table.insert(functions, {
					name = frame.name,
					file = file,
					keyStart = frame.keyStart,
					bodyStart = frame.bodyStart,
					bodyEnd = start,
					paramNames = frame.paramNames,
					signatureLine = frame.signatureLine,
				})
			end
		end
	end

	return functions
end

local function blankNested(source: string, fn: Fn, all: { Fn }): string
	local chars: { string } = {}
	for index = 1, #source do
		chars[index] = string.sub(source, index, index)
	end
	for _, other in all do
		if other.file == fn.file and other.keyStart > fn.keyStart and other.bodyEnd < fn.bodyEnd then
			local stop = math.min(other.bodyEnd + 3, #source)
			for index = other.keyStart, stop do
				if chars[index] ~= "\n" then
					chars[index] = " "
				end
			end
		end
	end
	return table.concat(chars)
end

local function bodySlice(source: string, fn: Fn, all: { Fn }, blank: boolean): string
	local text = if blank then blankNested(source, fn, all) else source
	return string.sub(text, fn.bodyStart, fn.bodyEnd - 1)
end

local function harvestConstants(files: { [string]: string }): { [string]: string }
	local constants: { [string]: string } = {}
	local numbers: { [string]: number } = {}
	for path, source in files do
		local masked, literals = maskSource(source)
		local litAt: { [number]: string } = {}
		for _, literal in literals do
			litAt[literal.start] = literal.value
		end
		local stack: { string } = {}
		local brace = 0
		local i = 1
		local n = #masked
		while i <= n do
			if litAt[i] ~= nil then
				i += 1
				continue
			end
			local localName = string.match(masked, "^local%s+([%w_]+)%s*=%s*{", i)
			if localName ~= nil then
				table.insert(stack, localName)
				local braceAt = string.find(masked, "{", i, true)
				i = if braceAt == nil then i + 1 else braceAt + 1
				brace += 1
				continue
			end
			local char = string.sub(masked, i, i)
			if char == "{" then
				brace += 1
				if #stack == 0 then
					table.insert(stack, "")
				end
			elseif char == "}" then
				brace -= 1
				if #stack > 0 and brace >= 0 then
					table.remove(stack)
				end
			else
				local beforeField = if i == 1 then "" else string.sub(masked, i - 1, i - 1)
				local field = if beforeField ~= "" and isIdentChar(beforeField)
					then nil
					else string.match(masked, "^([%w_]+)%s*=%s*", i)
				if field ~= nil then
					local matched = string.match(source, "^[%w_]+%s*=%s*", i) :: string
					local after = i + #matched
					local literalValue = litAt[after]
					local owner = stack[#stack]
					if literalValue ~= nil and owner ~= nil and owner ~= "" then
						constants[owner .. "." .. field] = literalValue
						constants[field] = literalValue
					elseif literalValue ~= nil then
						constants[field] = literalValue
					else
						local numeric = string.match(masked, "^(%d+)", after)
						if numeric ~= nil and owner ~= nil and owner ~= "" then
							numbers[owner .. "." .. field] = tonumber(numeric) :: number
						end
					end
				end
			end
			i += 1
		end
		for name, value in numbers do
			if string.match(name, "MAX_KEY_LENGTH$") and value > KEY_LIMIT then
				constants["__MAX_KEY_LENGTH_OVERFLOW__"] = tostring(value)
			end
		end
	end
	return constants
end

local function loadTree(root: string): { [string]: string }?
	local src = join(root, "src")
	if not fs.isDir(src) then
		return nil
	end
	local files: { [string]: string } = {}
	local function walk(dir: string, relative: string)
		for _, name in fs.readDir(dir) do
			local full = join(dir, name)
			local child = if relative == "" then name else relative .. "/" .. name
			if fs.isDir(full) then
				walk(full, child)
			elseif string.sub(name, -5) == ".luau" then
				files[child] = fs.readFile(full)
			end
		end
	end
	walk(src, "src")
	return files
end

local function addFinding(
	findings: { Finding },
	seen: { [string]: boolean },
	rule: string,
	path: string,
	line: number,
	message: string
)
	local key = rule .. "\0" .. path .. "\0" .. tostring(line) .. "\0" .. message
	if seen[key] then
		return
	end
	seen[key] = true
	table.insert(findings, { rule = rule, path = path, line = line, message = message })
end

local function magicSkipped(path: string): boolean
	for _, piece in MAGIC_SKIP do
		if string.find(path, piece, 1, true) ~= nil then
			return true
		end
	end
	return false
end

local function splitConcat(expr: string): { string }
	local parts: { string } = {}
	local depth = 0
	local start = 1
	local i = 1
	while i <= #expr do
		local char = string.sub(expr, i, i)
		if char == '"' or char == "'" then
			local quote = char
			i += 1
			while i <= #expr do
				if string.sub(expr, i, i) == "\\" then
					i += 2
				elseif string.sub(expr, i, i) == quote then
					i += 1
					break
				else
					i += 1
				end
			end
			continue
		elseif char == "(" then
			depth += 1
		elseif char == ")" then
			depth -= 1
		elseif depth == 0 and string.sub(expr, i, i + 1) == ".." then
			table.insert(parts, string.sub(expr, start, i - 1))
			i += 2
			start = i
			continue
		end
		i += 1
	end
	table.insert(parts, string.sub(expr, start))
	return parts
end

local function stripLineComment(expr: string): string
	local i = 1
	while i <= #expr do
		local char = string.sub(expr, i, i)
		if char == '"' or char == "'" then
			local quote = char
			i += 1
			while i <= #expr do
				if string.sub(expr, i, i) == "\\" then
					i += 2
				elseif string.sub(expr, i, i) == quote then
					i += 1
					break
				else
					i += 1
				end
			end
		elseif string.sub(expr, i, i + 1) == "--" then
			return string.sub(expr, 1, i - 1)
		else
			i += 1
		end
	end
	return expr
end

local function check(files: { [string]: string }): { Finding }
	local findings: { Finding } = {}
	local seen: { [string]: boolean } = {}
	local functions: { Fn } = {}
	local maskedOf: { [string]: string } = {}
	local literalsOf: { [string]: { Literal } } = {}
	local byName: { [string]: { Fn } } = {}

	for path, source in files do
		local masked, literals = maskSource(source)
		maskedOf[path] = masked
		literalsOf[path] = literals
		for _, fn in scanFunctions(path, masked) do
			table.insert(functions, fn)
			if fn.name ~= nil then
				local bucket = byName[fn.name]
				if bucket == nil then
					bucket = {}
					byName[fn.name] = bucket
				end
				table.insert(bucket, fn)
			end
		end
	end

	local constants = harvestConstants(files)
	if constants["__MAX_KEY_LENGTH_OVERFLOW__"] ~= nil then
		addFinding(
			findings,
			seen,
			"datastore_key",
			"src/shared/Config/Save.luau",
			1,
			"MAX_KEY_LENGTH is above the DataStore limit of " .. tostring(KEY_LIMIT)
		)
	end
	for name, value in constants do
		if name == "__MAX_KEY_LENGTH_OVERFLOW__" then
			continue
		end
		local field = string.match(name, "([%w_]+)$")
		if (field == "KEY_PREFIX" or field == "STORE_NAME") and #value > KEY_LIMIT then
			addFinding(
				findings,
				seen,
				"datastore_key",
				"config",
				1,
				field .. " is " .. tostring(#value) .. " characters (limit " .. tostring(KEY_LIMIT) .. ")"
			)
		end
	end

	local function findFn(name: string, file: string): Fn?
		local bucket = byName[name]
		if bucket == nil then
			return nil
		end
		local same: Fn? = nil
		for _, fn in bucket do
			if fn.file == file then
				same = fn
			end
		end
		if same ~= nil then
			return same
		end
		if #bucket == 1 then
			return bucket[1]
		end
		return nil
	end

	local estimating: { [Fn]: boolean } = {}
	local estimateCache: { [Fn]: number? } = {}

	local function estimateTerm(term: string, env: { [string]: number? }, file: string): number?
		term = trim(term)
		if term == "" then
			return 0
		end
		local quoted = string.match(term, '^"(.*)"$') or string.match(term, "^'(.*)'$")
		if quoted ~= nil then
			return #quoted
		end
		if string.match(term, "^tostring%s*%(") then
			return USER_ID_DIGITS
		end
		local lowered = string.match(term, "^string%.lower%s*%(%s*(.+)%s*%)$")
			or string.match(term, "^string%.upper%s*%(%s*(.+)%s*%)$")
		if lowered ~= nil then
			return estimateTerm(lowered, env, file)
		end
		local subEnd = string.match(term, "^string%.sub%s*%(.-,%s*%d+%s*,%s*(%d+)%s*%)$")
		if subEnd ~= nil then
			return tonumber(subEnd)
		end
		local callName = string.match(term, "^([%w_%.]+)%s*%(")
		if callName ~= nil and string.sub(term, -1) == ")" then
			local callee = findFn(callName, file)
			if callee == nil then
				return nil
			end
			return estimateFn(callee)
		end
		if string.match(term, "^[%w_%.]+$") then
			if env[term] ~= nil then
				return env[term]
			end
			local constant = constants[term]
			if constant ~= nil then
				return #constant
			end
		end
		return nil
	end

	function estimateFn(fn: Fn): number?
		if estimateCache[fn] ~= nil or estimating[fn] then
			return estimateCache[fn]
		end
		estimating[fn] = true
		local source = files[fn.file]
		local blanked = bodySlice(source, fn, functions, true)
		local env: { [string]: number? } = {}
		local known: { [string]: boolean } = {}
		for rawLine in string.gmatch(blanked, "[^\n]+") do
			local line = stripLineComment(rawLine)
			local assignName, expr = string.match(line, "^%s*local%s+([%w_]+)%s*=%s*(.+)$")
			if assignName == nil then
				assignName, expr = string.match(line, "^%s*([%w_]+)%s*=%s*([^=].*)$")
			end
			if assignName ~= nil and expr ~= nil and not string.find(assignName, "^return$") then
				local value = estimateTerm(expr, env, fn.file)
				if known[assignName] ~= true then
					env[assignName] = value
					known[assignName] = value ~= nil
				elseif value == nil then
					env[assignName] = nil
					known[assignName] = false
				else
					local previous = env[assignName]
					if previous == nil or value > previous then
						env[assignName] = value
					end
				end
			end
		end
		local best: number? = nil
		local saw = false
		for rawLine in string.gmatch(blanked, "[^\n]+") do
			local line = stripLineComment(rawLine)
			local expr = string.match(line, "^%s*return%s+(.+)$")
			if expr ~= nil then
				local returned = trim(expr)
				local comma = string.find(returned, ",", 1, true)
				if comma ~= nil and string.find(returned, "..", 1, true) == nil then
					returned = trim(string.sub(returned, 1, comma - 1))
				end
				local total = 0
				local ok = true
				for _, part in splitConcat(returned) do
					local piece = estimateTerm(part, env, fn.file)
					if piece == nil then
						ok = false
						break
					end
					total += piece
				end
				saw = true
				if ok and (best == nil or total > best) then
					best = total
				elseif not ok then
					best = nil
					break
				end
			end
		end
		estimating[fn] = nil
		if saw then
			estimateCache[fn] = best
		end
		return if saw then best else nil
	end

	for _, fn in functions do
		if fn.name ~= nil and KEY_FUNCTIONS[fn.name] == true then
			local length = estimateFn(fn)
			if length ~= nil and length > KEY_LIMIT then
				addFinding(
					findings,
					seen,
					"datastore_key",
					fn.file,
					fn.signatureLine,
					fn.name
						.. " builds a key of about "
						.. tostring(length)
						.. " characters (limit "
						.. tostring(KEY_LIMIT)
						.. "; a user id counts as "
						.. tostring(USER_ID_DIGITS)
						.. " digits)"
				)
			end
		end
	end

	for path, source in files do
		local masked = maskedOf[path]
		local searchFrom = 1
		while true do
			local at = string.find(masked, "Async%s*%(", searchFrom)
			local kind = "Async"
			local storeAt = string.find(masked, "GetDataStore%s*%(", searchFrom)
			local orderedAt = string.find(masked, "GetOrderedDataStore%s*%(", searchFrom)
			local chosen = at
			if storeAt ~= nil and (chosen == nil or storeAt < chosen) then
				chosen = storeAt
				kind = "store"
			end
			if orderedAt ~= nil and (chosen == nil or orderedAt < chosen) then
				chosen = orderedAt
				kind = "store"
			end
			if chosen == nil then
				break
			end
			local paren = string.find(masked, "(", chosen, true)
			if paren == nil then
				break
			end
			local argStart = paren + 1
			while string.match(string.sub(source, argStart, argStart), "%s") do
				argStart += 1
			end
			local argEnd = argStart
			local depth = 0
			while argEnd <= #source do
				local char = string.sub(source, argEnd, argEnd)
				if char == "(" then
					depth += 1
				elseif char == ")" and depth == 0 then
					break
				elseif char == ")" then
					depth -= 1
				elseif char == "," and depth == 0 then
					break
				end
				argEnd += 1
			end
			local arg = trim(string.sub(source, argStart, argEnd - 1))
			local owner: Fn? = nil
			for _, fn in functions do
				if fn.file == path and fn.bodyStart <= chosen and chosen < fn.bodyEnd then
					if owner == nil or fn.bodyStart > owner.bodyStart then
						owner = fn
					end
				end
			end
			local length: number? = nil
			if string.match(arg, '^".*"$') or string.match(arg, "^'.*'$") then
				length = #arg - 2
			elseif owner ~= nil then
				estimateFn(owner)
				local env: { [string]: number? } = {}
				local blanked = bodySlice(source, owner, functions, true)
				for rawLine in string.gmatch(blanked, "[^\n]+") do
					local line = stripLineComment(rawLine)
					local assignName, expr = string.match(line, "^%s*local%s+([%w_]+)%s*=%s*(.+)$")
					if assignName == nil then
						assignName, expr = string.match(line, "^%s*([%w_]+)%s*=%s*([^=].*)$")
					end
					if assignName ~= nil and expr ~= nil then
						env[assignName] = estimateTerm(expr, env, path)
					end
				end
				local total = 0
				local ok = true
				for _, part in splitConcat(arg) do
					local piece = estimateTerm(part, env, path)
					if piece == nil then
						ok = false
						break
					end
					total += piece
				end
				if ok then
					length = total
				end
			end
			if length ~= nil and length > KEY_LIMIT then
				addFinding(
					findings,
					seen,
					"datastore_key",
					path,
					lineOf(source, chosen),
					kind .. " key is about " .. tostring(length) .. " characters (limit " .. tostring(KEY_LIMIT) .. ")"
				)
			end
			searchFrom = paren + 1
		end
	end

	local remotes: { { name: string, value: string, line: number } } = {}
	local remoteFile = files["src/shared/Config/Remotes.luau"]
	if remoteFile ~= nil then
		local masked = maskedOf["src/shared/Config/Remotes.luau"]
		local _, literals = maskSource(remoteFile)
		local litAt: { [number]: string } = {}
		for _, literal in literals do
			litAt[literal.start] = literal.value
		end
		local i = 1
		while i <= #masked do
			local beforeName = if i == 1 then "" else string.sub(masked, i - 1, i - 1)
			local name = if beforeName ~= "" and isIdentChar(beforeName)
				then nil
				else string.match(masked, "^([%w_]+)%s*=%s*", i)
			if name ~= nil and name ~= "FOLDER" then
				local matched = string.match(remoteFile, "^[%w_]+%s*=%s*", i)
				local literalValue = if matched == nil then nil else litAt[i + #matched]
				if literalValue ~= nil and string.sub(literalValue, 1, 7) == "Request" then
					table.insert(remotes, { name = name, value = literalValue, line = lineOf(remoteFile, i) })
				end
			end
			i += 1
		end
	end

	local function serverHas(pattern: string): boolean
		for path, _source in files do
			if string.find(path, "src/server/", 1, true) ~= nil and string.find(maskedOf[path], pattern) ~= nil then
				return true
			end
		end
		return false
	end

	for _, remote in remotes do
		local listened = serverHas("listen%s*%(%s*Names%." .. remote.name .. "[%s,)]")
		if not listened then
			addFinding(
				findings,
				seen,
				"remote_validation",
				"src/shared/Config/Remotes.luau",
				remote.line,
				remote.name .. " (" .. remote.value .. ") has no server listen()"
			)
		end
		local created = false
		local remotesSource = files["src/server/Remotes.luau"]
		if
			remotesSource ~= nil
			and string.find(maskedOf["src/server/Remotes.luau"], "Names%." .. remote.name .. "[^%w_]") ~= nil
		then
			created = true
		end
		if not created then
			addFinding(
				findings,
				seen,
				"remote_validation",
				"src/server/Remotes.luau",
				1,
				remote.name .. " is not created in Remotes.luau"
			)
		end
	end

	local function hasValidator(text: string): boolean
		if string.find(text, "RemoteArgs", 1, true) ~= nil then
			return true
		end
		if string.find(text, "type(", 1, true) ~= nil or string.find(text, "typeof(", 1, true) ~= nil then
			return true
		end
		if string.find(text, "assert(", 1, true) ~= nil then
			return true
		end
		if
			string.find(text, "Monetisation.byKey", 1, true) ~= nil
			or string.find(text, "Settings.apply", 1, true) ~= nil
		then
			return true
		end
		return false
	end

	local function callTouches(args: string, param: string): boolean
		if param == "..." then
			return string.find(args, "...", 1, true) ~= nil
		end
		return string.find(args, "[^%w_]" .. param .. "[^%w_]") ~= nil
			or string.find(args, "[^%w_]" .. param .. "$") ~= nil
			or string.match(args, "^" .. param .. "[^%w_]") ~= nil
			or string.match(args, "^" .. param .. "$") ~= nil
	end

	for path, source in files do
		if string.find(path, "src/server/", 1, true) == nil then
			continue
		end
		local masked = maskedOf[path]
		if string.find(masked, "listen%s*%(%s*Names%.") == nil then
			continue
		end
		local listenFn = findFn("listen", path)
		local gate = if listenFn == nil then "" else bodySlice(source, listenFn, functions, false)
		if
			listenFn == nil
			or (
				string.find(gate, "sessions[", 1, true) == nil
				and string.find(gate, "session == nil", 1, true) == nil
				and string.find(gate, "RemoteGuard", 1, true) == nil
			)
		then
			addFinding(
				findings,
				seen,
				"remote_validation",
				path,
				if listenFn == nil then 1 else listenFn.signatureLine,
				"listen() does not keep the remote on the server session"
			)
		end
		local searchFrom = 1
		while true do
			local nameStart, nameEnd, remoteName = string.find(masked, "listen%s*%(%s*Names%.([%w_]+)", searchFrom)
			if nameStart == nil or remoteName == nil or nameEnd == nil then
				break
			end
			local after = nameEnd + 1
			local handlerName = string.match(masked, "^%s*,%s*([%w_]+)", after)
			local functionAt = string.find(masked, "^%s*,%s*function", after)
			local handler: Fn? = nil
			if handlerName ~= nil and handlerName ~= "function" then
				handler = findFn(handlerName, path)
			elseif functionAt ~= nil then
				local keyword = string.find(masked, "function", after, true)
				if keyword ~= nil then
					for _, fn in functions do
						if fn.file == path and fn.keyStart == keyword then
							handler = fn
							break
						end
					end
				end
			end
			if handler ~= nil then
				local body = bodySlice(source, handler, functions, true)
				local used: { string } = {}
				for index, param in handler.paramNames do
					if index > 1 then
						local referenced = false
						if param == "..." then
							referenced = string.find(body, "...", 1, true) ~= nil
						else
							referenced = string.find(body, "[^%w_]" .. param .. "[^%w_]") ~= nil
								or string.match(body, "^%s*" .. param .. "[^%w_]") ~= nil
						end
						if referenced then
							table.insert(used, param)
						end
					end
				end
				if #used > 0 and not hasValidator(body) then
					local validated = false
					for callName, args in string.gmatch(body, "([%w_%.]+)%s*%(([^%)]*)%)") do
						local touches = false
						for _, param in used do
							if callTouches(args, param) then
								touches = true
							end
						end
						if touches then
							local callee = findFn(callName, path)
							if
								callee ~= nil and hasValidator(bodySlice(files[callee.file], callee, functions, false))
							then
								validated = true
							end
						end
					end
					if not validated then
						addFinding(
							findings,
							seen,
							"remote_validation",
							path,
							handler.signatureLine,
							remoteName .. " uses a client argument without a server-side check"
						)
					end
				end
			end
			searchFrom = nameEnd + 1
		end
	end

	for path, source in files do
		if string.find(path, "src/client/", 1, true) == nil then
			continue
		end
		local masked = maskedOf[path]
		local function flagClient(at: number, message: string)
			addFinding(findings, seen, "client_authority", path, lineOf(source, at), message)
		end
		local shop = string.find(masked, "[^%w_]ShopRoll[^%w_]")
		if shop ~= nil then
			flagClient(shop, "client reaches ShopRoll")
		end
		local rng = string.find(masked, "[^%w_]SeededRng[^%w_]")
		if rng ~= nil then
			flagClient(rng, "client reaches SeededRng")
		end
		local store = string.find(masked, "DataStoreService")
		if store ~= nil then
			flagClient(store, "client reaches DataStoreService")
		end
		local cashAt = string.find(masked, "[^%w_](profile|state|data|snapshot)%s*%.%s*cash%s*[%+]?=")
		if cashAt ~= nil then
			flagClient(cashAt, "client writes cash")
		end
		local earnedAt = string.find(masked, "[^%w_](profile|state|data|snapshot)%s*%.%s*totalEarned%s*[%+]?=")
		if earnedAt ~= nil then
			flagClient(earnedAt, "client writes totalEarned")
		end
		local from = 1
		while true do
			local at = string.find(masked, "math%.random%s*%(", from)
			if at == nil then
				break
			end
			local lineStart = at
			while lineStart > 1 and string.sub(masked, lineStart - 1, lineStart - 1) ~= "\n" do
				lineStart -= 1
			end
			local lineEnd = string.find(masked, "\n", at, true) or (#masked + 1)
			local line = string.sub(masked, lineStart, lineEnd - 1)
			if
				string.find(line, "rarity")
				or string.find(line, "weight")
				or string.find(line, "species")
				or string.find(line, "price")
			then
				flagClient(at, "client rolls a reward")
			end
			from = at + 1
		end
	end

	local yieldPattern = {
		"task%.wait%s*%(",
		"task%.delay%s*%(",
		"[^%w_%.]wait%s*%(",
		"[^%w_%.]delay%s*%(",
		"WaitForChild%s*%(",
		":Wait%s*%(",
		"coroutine%.yield%s*%(",
	}

	local function yields(text: string): number?
		for _, pattern in yieldPattern do
			local at = string.find(text, pattern)
			if at ~= nil then
				return at
			end
		end
		return nil
	end

	for _, eventName in HOT_EVENTS do
		for path, _source in files do
			local masked = maskedOf[path]
			local from = 1
			while true do
				local at = string.find(masked, "[^%w_]" .. eventName .. "%s*:%s*Connect%s*%(", from)
				if at == nil then
					break
				end
				local paren = string.find(masked, "(", at, true)
				local ident = if paren == nil then nil else string.match(masked, "^%s*([%w_]+)", paren + 1)
				local fn: Fn? = nil
				if ident ~= nil and ident ~= "function" then
					fn = findFn(ident, path)
				else
					local keyword = if paren == nil then nil else string.find(masked, "function", paren, true)
					if keyword ~= nil then
						for _, candidate in functions do
							if candidate.file == path and candidate.keyStart == keyword then
								fn = candidate
								break
							end
						end
					end
				end
				if fn ~= nil then
					local text = bodySlice(files[path], fn, functions, true)
					if yields(text) ~= nil then
						addFinding(
							findings,
							seen,
							"hot_path_yield",
							path,
							fn.signatureLine,
							eventName .. " callback yields (" .. (fn.name or "function") .. ")"
						)
					end
				end
				from = at + #eventName
			end
		end
	end

	for path, source in files do
		if string.match(path, "%.hot%.luau$") == nil then
			continue
		end
		for _, fn in functions do
			if fn.file ~= path then
				continue
			end
			local text = bodySlice(source, fn, functions, true)
			if yields(text) ~= nil then
				addFinding(
					findings,
					seen,
					"hot_path_yield",
					path,
					fn.signatureLine,
					".hot.luau function yields (" .. (fn.name or "function") .. ")"
				)
			end
			if
				string.find(text, "Instance.new", 1, true)
				or string.find(text, "table.create", 1, true)
				or string.find(text, "table.clone", 1, true)
			then
				addFinding(
					findings,
					seen,
					"hot_file_alloc",
					path,
					fn.signatureLine,
					".hot.luau function allocates (" .. (fn.name or "function") .. ")"
				)
			end
			local brace = string.find(text, "{", 1, true)
			if brace ~= nil then
				local absolute = fn.bodyStart + brace - 1
				local previous = absolute - 1
				while previous > 0 and string.match(string.sub(source, previous, previous), "%s") do
					previous -= 1
				end
				local prev = if previous > 0 then string.sub(source, previous, previous) else ""
				if
					prev == "="
					or prev == "("
					or prev == ","
					or prev == "{"
					or string.match(string.sub(source, math.max(1, previous - 5), previous), "return%s*$")
				then
					addFinding(
						findings,
						seen,
						"hot_file_alloc",
						path,
						lineOf(source, absolute),
						".hot.luau builds a table"
					)
				end
			end
		end
	end

	for path, source in files do
		local masked = maskedOf[path]
		local function flagAt(rule: string, pattern: string, message: string)
			local from = 1
			while true do
				local at = string.find(masked, pattern, from)
				if at == nil then
					break
				end
				addFinding(findings, seen, rule, path, lineOf(source, at), message)
				from = at + 1
			end
		end
		local function flagCall(rule: string, word: string, message: string)
			local from = 1
			while true do
				local at = string.find(masked, word .. "%s*%(", from)
				if at == nil then
					break
				end
				local before = if at == 1 then "" else string.sub(masked, at - 1, at - 1)
				if before == "" or string.match(before, "[%w_%.]") == nil then
					addFinding(findings, seen, rule, path, lineOf(source, at), message)
				end
				from = at + 1
			end
		end
		flagCall("wait_usage", "wait", "wait() is deprecated; use task.wait")
		flagCall("deprecated_api", "delay", "delay() is deprecated; use task.delay")
		flagCall("deprecated_api", "spawn", "spawn() is deprecated; use task.spawn")
		flagCall("deprecated_api", "tick", "tick() is deprecated; use os.clock or workspace:GetServerTimeNow")
		flagCall("deprecated_api", "elapsedTime", "elapsedTime() is deprecated")
		flagAt("deprecated_api", ":connect%s*%(", ":connect() is deprecated; use :Connect")
		flagAt("deprecated_api", ":remove%s*%(", ":remove() is deprecated; use :Destroy")
		flagAt("deprecated_api", ":Remove%s*%(", ":Remove() is deprecated; use :Destroy")
		flagCall("deprecated_api", "ypcall", "ypcall() is deprecated; use pcall")
		flagAt("deprecated_api", "FindPartsInRegion3", "FindPartsInRegion3 is deprecated")
		flagAt(
			"instance_parent",
			"Instance%.new%s*%(%s*[^%(%),]+%s*,",
			"Instance.new parent belongs after the properties, not in the constructor"
		)
		if
			(string.find(path, "src/server/", 1, true) ~= nil or string.find(path, "src/shared/Logic/", 1, true) ~= nil)
			and not magicSkipped(path)
		then
			local from = 1
			while true do
				local startAt, endAt = string.find(masked, "%d+", from)
				if startAt == nil or endAt == nil then
					break
				end
				local before = if startAt == 1 then "" else string.sub(masked, startAt - 1, startAt - 1)
				local after = string.sub(masked, endAt + 1, endAt + 1)
				if string.match(before, "[%d%.]") == nil and string.match(after, "[%d%.]") == nil then
					local value = tonumber(string.sub(masked, startAt, endAt)) or 0
					local lineStart = startAt
					while lineStart > 1 and string.sub(masked, lineStart - 1, lineStart - 1) ~= "\n" do
						lineStart -= 1
					end
					local prefix = string.sub(masked, lineStart, startAt - 1)
					local assigned = string.match(prefix, "[%w_]+%s*=%s*$") ~= nil
					if value >= MAGIC_ANY_MIN or (assigned and value >= MAGIC_ASSIGN_MIN) then
						addFinding(
							findings,
							seen,
							"magic_number",
							path,
							lineOf(source, startAt),
							"integer " .. tostring(value) .. " belongs in Config"
						)
					end
				end
				from = endAt + 1
			end
		end
	end

	table.sort(findings, function(a: Finding, b: Finding): boolean
		if a.rule ~= b.rule then
			return a.rule < b.rule
		end
		if a.path ~= b.path then
			return a.path < b.path
		end
		if a.line ~= b.line then
			return a.line < b.line
		end
		return a.message < b.message
	end)
	return findings
end

local function summarize(findings: { Finding }, fileCount: number)
	local failed: { [string]: boolean } = {}
	for _, finding in findings do
		failed[finding.rule] = true
		print(string.format("fail %s %s:%d %s", finding.rule, finding.path, finding.line, finding.message))
	end
	local passCount = 0
	local failCount = 0
	for _, rule in RULES do
		if failed[rule] then
			failCount += 1
			if #findings > 0 then
				local shown = false
				for _, finding in findings do
					if finding.rule == rule then
						shown = true
						break
					end
				end
				if not shown then
					print("fail " .. rule)
				end
			end
		else
			passCount += 1
			print("pass " .. rule)
		end
	end
	print(string.format("scanned %d luau files", fileCount))
	print(string.format("rbx_check: %d passed, %d failed", passCount, failCount))
	return failCount
end

local function countFiles(files: { [string]: string }): number
	local count = 0
	for _ in files do
		count += 1
	end
	return count
end

local function expect(name: string, files: { [string]: string }, rule: string?): (boolean, string)
	local findings = check(files)
	if rule == nil then
		if #findings == 0 then
			return true, ""
		end
		local first = findings[1]
		return false,
			name
				.. " expected clean, got "
				.. first.rule
				.. " "
				.. first.path
				.. ":"
				.. tostring(first.line)
				.. " "
				.. first.message
	end
	for _, finding in findings do
		if finding.rule == rule then
			return true, ""
		end
	end
	return false, name .. " expected " .. rule
end

local function selfTest(): number
	local clean = {
		["src/shared/Config/Remotes.luau"] = [[
local Remotes = {
	FOLDER = "CryptidRemotes",
	PING = "RequestPing",
}
return Remotes
]],
		["src/shared/Config/Save.luau"] = [[
local Save = {
	KEY_PREFIX = "player_",
	STORE_NAME = "ProjectCryptid_Player_v1",
	MAX_KEY_LENGTH = 50,
}
return Save
]],
		["src/server/Remotes.luau"] = [[
local names = { Names.PING }
]],
		["src/server/Session.luau"] = [[
local function onPing(session: any)
	if session == nil then
		return
	end
end
local function listen(name: string, handler: (any) -> ())
	remote.OnServerEvent:Connect(function(player: Player)
		local session = sessions[player]
		if session == nil then
			return
		end
		handler(session)
	end)
end
listen(Names.PING, onPing)
local function profileKey(userId: number): string
	return Save.KEY_PREFIX .. tostring(userId)
end
]],
		["src/client/Main.client.luau"] = [[
local function fire(name: string, ...: any)
	remote:FireServer(...)
end
fire(Names.PING)
local function stepMotion(dt: number)
	local x = dt
end
RunService.Heartbeat:Connect(stepMotion)
task.wait(1)
local jitter = math.random()
]],
		["src/server/Visual.luau"] = [[
local part = Instance.new("Part")
part.Parent = folder
]],
	}

	local function with(path: string, source: string): { [string]: string }
		local copy: { [string]: string } = {}
		for key, value in clean do
			copy[key] = value
		end
		copy[path] = source
		return copy
	end

	local cases = {
		{ "clean", clean, nil },
		{
			"validated hop",
			with(
				"src/server/Session.luau",
				[[
local function Shop_onBuy(session: any, key: any)
	if type(key) ~= "string" then
		return
	end
end
local function onPing(session: any, key: any)
	Shop_onBuy(session, key)
end
local function listen(name: string, handler: (any) -> ())
	remote.OnServerEvent:Connect(function(player: Player)
		local session = sessions[player]
		if session == nil then
			return
		end
		handler(session)
	end)
end
listen(Names.PING, onPing)
]]
			),
			nil,
		},
		{
			"unvalidated remote",
			with(
				"src/server/Session.luau",
				[[
local function onPing(session: any, amount: any)
	session.profile.cash = amount
end
local function listen(name: string, handler: (any) -> ())
	remote.OnServerEvent:Connect(function(player: Player)
		local session = sessions[player]
		if session == nil then
			return
		end
		handler(session)
	end)
end
listen(Names.PING, onPing)
]]
			),
			"remote_validation",
		},
		{
			"client cash",
			with(
				"src/client/Main.client.luau",
				[[
local function fire(name: string)
	remote:FireServer()
end
fire(Names.PING)
profile.cash = 10
ShopRoll.generate(1)
]]
			),
			"client_authority",
		},
		{
			"hot yield",
			with(
				"src/client/Main.client.luau",
				[[
local function fire(name: string)
	remote:FireServer()
end
fire(Names.PING)
local function stepMotion(dt: number)
	task.wait()
end
RunService.Heartbeat:Connect(stepMotion)
]]
			),
			"hot_path_yield",
		},
		{
			"hot alloc",
			with(
				"src/server/Tick.hot.luau",
				[[
local function step()
	local part = Instance.new("Part")
	return part
end
]]
			),
			"hot_file_alloc",
		},
		{
			"long key",
			with(
				"src/server/Session.luau",
				[[
local function onPing(session: any)
	if session == nil then
		return
	end
end
local function listen(name: string, handler: (any) -> ())
	remote.OnServerEvent:Connect(function(player: Player)
		local session = sessions[player]
		if session == nil then
			return
		end
		handler(session)
	end)
end
listen(Names.PING, onPing)
local function profileKey(userId: number): string
	return Save.KEY_PREFIX .. tostring(userId) .. "0123456789012345678901234567890123456789"
end
]]
			),
			"datastore_key",
		},
		{
			"deprecated",
			with("src/server/Old.luau", "spawn(function()\nend)\n"),
			"deprecated_api",
		},
		{
			"wait",
			with("src/server/Old.luau", "wait(1)\n"),
			"wait_usage",
		},
		{
			"instance parent",
			with("src/server/Visual.luau", 'local part = Instance.new("Part", workspace)\n'),
			"instance_parent",
		},
		{
			"magic",
			with("src/server/Balance.luau", "local PRICE = 500\n"),
			"magic_number",
		},
	}

	local failed = 0
	for _, case in cases do
		local name, files, rule = case[1], case[2], case[3]
		local ok, detail = expect(name, files, rule)
		if ok then
			print("PASS " .. name)
		else
			failed += 1
			print("FAIL " .. detail)
		end
	end
	print(string.format("self-test: %d passed, %d failed", #cases - failed, failed))
	return failed
end

local self = false
local root = process.cwd
local index = 1
while index <= #process.args do
	local arg = process.args[index]
	if arg == "--self-test" then
		self = true
	elseif arg == "--root" then
		index += 1
		root = process.args[index] or root
	elseif arg ~= "--" then
		root = arg
	end
	index += 1
end

if self then
	process.exit(if selfTest() == 0 then 0 else 1)
end

if string.sub(root, -1) == "/" then
	root = string.sub(root, 1, -2)
end

local files = loadTree(root)
if files == nil then
	print("rbx_check: no src directory in " .. root)
	process.exit(2)
end

local failCount = summarize(check(files), countFiles(files))
process.exit(if failCount == 0 then 0 else 1)
