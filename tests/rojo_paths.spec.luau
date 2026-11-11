--!strict

local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local Check = require("./check")

type Node = {
	name: string,
	className: string,
	parent: Node?,
	children: { [string]: Node },
}

local function childMap(rawChildren: { any }?, parent: Node?): { [string]: Node }
	local children: { [string]: Node } = {}
	for _, raw in rawChildren or {} do
		local node: Node = {
			name = raw.name,
			className = raw.className,
			parent = parent,
			children = {},
		}
		node.children = childMap(raw.children, node)
		children[node.name] = node
		if raw.filePaths ~= nil then
			for _, filePath in raw.filePaths do
				-- filled by the caller via a side table
				raw._node = node
			end
		end
	end
	return children
end

local function indexFiles(raw: any, files: { [string]: Node })
	if raw.filePaths ~= nil and raw._node ~= nil then
		for _, filePath in raw.filePaths do
			files[filePath] = raw._node
		end
	end
	for _, child in raw.children or {} do
		indexFiles(child, files)
	end
end

local function loadTree(projectPath: string): ({ [string]: Node }, { [string]: Node })
	local result = process.exec("rojo", { "sourcemap", projectPath })
	local stdout = result.stdout
	local stderr = result.stderr
	Check.eq(result.ok, true, if type(stderr) == "string" then stderr else "rojo sourcemap failed")
	local rootRaw = serde.decode("json", stdout)
	local rootChildren = childMap(rootRaw.children, nil)
	if rootChildren.Workspace == nil then
		rootChildren.Workspace = {
			name = "Workspace",
			className = "Workspace",
			parent = nil,
			children = {},
		}
	end
	local files: { [string]: Node } = {}
	indexFiles(rootRaw, files)
	return rootChildren, files
end

local function pathOf(node: Node?): string
	local names = {}
	local cursor = node
	while cursor ~= nil do
		table.insert(names, 1, cursor.name)
		cursor = cursor.parent
	end
	return table.concat(names, ".")
end

local function stripNoise(source: string): string
	local out = table.create(#source)
	local i = 1
	local n = #source
	local quote: string? = nil
	while i <= n do
		local ch = string.sub(source, i, i)
		local two = string.sub(source, i, i + 1)
		if quote ~= nil then
			table.insert(out, ch)
			i += 1
			if ch == "\\" then
				if i <= n then
					table.insert(out, string.sub(source, i, i))
					i += 1
				end
			elseif ch == quote then
				quote = nil
			end
		elseif two == "--" then
			if string.sub(source, i, i + 3) == "--[[" then
				local closeAt = string.find(source, "]]", i + 4, true)
				local stop = if closeAt == nil then n else closeAt + 1
				for j = i, stop do
					local commentCh = string.sub(source, j, j)
					table.insert(out, if commentCh == "\n" then "\n" else " ")
				end
				i = stop + 1
			else
				while i <= n and string.sub(source, i, i) ~= "\n" do
					table.insert(out, " ")
					i += 1
				end
			end
		elseif ch == '"' or ch == "'" then
			quote = ch
			table.insert(out, ch)
			i += 1
		else
			table.insert(out, ch)
			i += 1
		end
	end
	return table.concat(out)
end

local function isWord(ch: string): boolean
	return string.match(ch, "[%w_]") ~= nil
end

local function skipWs(source: string, i: number): number
	local n = #source
	while i <= n and string.match(string.sub(source, i, i), "%s") ~= nil do
		i += 1
	end
	return i
end

local function lineOf(source: string, i: number): number
	local line = 1
	for pos = 1, i - 1 do
		if string.sub(source, pos, pos) == "\n" then
			line += 1
		end
	end
	return line
end

local function matchAt(source: string, i: number, pattern: string): ...any
	return string.match(string.sub(source, i), pattern)
end

local function parseExpr(
	source: string,
	i: number,
	scriptNode: Node,
	locals: { [string]: Node },
	misses: { string },
	checked: { string },
	filePath: string
): (Node?, number, boolean)
	i = skipWs(source, i)
	local node: Node? = nil
	if string.sub(source, i, i + 5) == "script" and not isWord(string.sub(source, i + 6, i + 6)) then
		node = scriptNode
		i += 6
	elseif string.sub(source, i, i + 8) == "workspace" and not isWord(string.sub(source, i + 9, i + 9)) then
		node = locals["service:Workspace"]
		i += 9
	elseif string.sub(source, i, i + 3) == "game" and not isWord(string.sub(source, i + 4, i + 4)) then
		local serviceName, relativeEnd = matchAt(source, i, '^game%s*:%s*GetService%s*%(%s*"([^"]+)"%s*%)()')
		if serviceName == nil or relativeEnd == nil then
			return nil, i, false
		end
		node = locals["service:" .. serviceName]
		i += relativeEnd - 1
	else
		local ident, relativeEnd = matchAt(source, i, "^([%a_][%w_]*)()")
		if ident == nil or relativeEnd == nil or locals[ident] == nil then
			return nil, i, false
		end
		node = locals[ident]
		i += relativeEnd - 1
	end
	local hadWait = false
	while node ~= nil do
		local j = skipWs(source, i)
		local parentEnd = matchAt(source, j, "^%.%s*Parent()")
		if parentEnd ~= nil and not isWord(string.sub(source, j + parentEnd - 1, j + parentEnd - 1)) then
			local afterParent = j + parentEnd - 1
			node = node.parent
			i = afterParent
			if node == nil then
				table.insert(misses, filePath .. ":" .. tostring(lineOf(source, j)) .. " climbed above the data model")
				return nil, afterParent, hadWait
			end
		else
			local name, relativeEnd = matchAt(source, j, '^:%s*WaitForChild%s*%(%s*"([^"]+)"[^%)]*%)()')
			if name == nil or relativeEnd == nil then
				break
			end
			local nextI = j + relativeEnd - 1
			hadWait = true
			local child = node.children[name]
			local full = pathOf(node) .. "." .. name
			table.insert(checked, filePath .. " -> " .. full)
			if child == nil then
				table.insert(misses, filePath .. ":" .. tostring(lineOf(source, j)) .. " missing " .. full)
				return nil, nextI, true
			end
			node = child
			i = nextI
		end
	end
	return node, i, hadWait
end

local function scanFile(
	source: string,
	scriptNode: Node,
	services: { [string]: Node },
	filePath: string
): ({ string }, { string })
	local clean = stripNoise(source)
	local locals: { [string]: Node } = {}
	for name, node in services do
		locals["service:" .. name] = node
	end
	local misses = {}
	local checked = {}
	local i = 1
	local n = #clean
	while i <= n do
		i = skipWs(clean, i)
		if i > n then
			break
		end
		if matchAt(clean, i, "^local%s+function") ~= nil then
			i += 5
			continue
		end
		local localName, relativeExpr = matchAt(clean, i, "^local%s+([%a_][%w_]*)%s*=%s*()")
		local exprAt = if relativeExpr == nil then nil else i + relativeExpr - 1
		if localName ~= nil and exprAt ~= nil then
			local node, nextI, hadWait = parseExpr(clean, exprAt, scriptNode, locals, misses, checked, filePath)
			if hadWait or node ~= nil then
				local after = skipWs(clean, nextI)
				local nextCh = string.sub(clean, after, after)
				if node ~= nil and nextCh ~= ":" and nextCh ~= "." then
					locals[localName] = node
				end
				i = math.max(nextI, i + 1)
				continue
			end
		end
		local _, nextI, hadWait = parseExpr(clean, i, scriptNode, locals, misses, checked, filePath)
		if hadWait then
			i = math.max(nextI, i + 1)
		else
			i += 1
		end
	end
	return misses, checked
end

local function listSources(dir: string, out: { string })
	for _, name in fs.readDir(dir) do
		local path = dir .. "/" .. name
		if fs.isDir(path) then
			listSources(path, out)
		elseif string.sub(name, -5) == ".luau" then
			table.insert(out, path)
		end
	end
end

local function scanProject(projectPath: string): ({ string }, { string })
	local services, files = loadTree(projectPath)
	local sources = {}
	listSources("src", sources)
	table.sort(sources)
	local misses = {}
	local checked = {}
	for _, filePath in sources do
		local scriptNode = files[filePath]
		if scriptNode == nil then
			table.insert(misses, filePath .. " is not in the rojo tree for " .. projectPath)
			continue
		end
		local fileMisses, fileChecked = scanFile(fs.readFile(filePath), scriptNode, services, filePath)
		for _, miss in fileMisses do
			table.insert(misses, projectPath .. " " .. miss)
		end
		for _, item in fileChecked do
			table.insert(checked, projectPath .. " " .. item)
		end
	end
	return misses, checked
end

Check.test("a script.Parent wait from an init module does not see its own children", function()
	local services, files = loadTree("default.project.json")
	local scriptNode = files["src/server/TownKits/init.luau"]
	Check.truthy(scriptNode)
	Check.eq(scriptNode.name, "TownKits")
	Check.eq(scriptNode.children.Longship ~= nil, true)
	Check.eq(services.ServerScriptService.children.Longship, nil)
	local bad = 'return script.Parent:WaitForChild("Longship")\n'
	local misses = scanFile(bad, scriptNode, services, "src/server/TownKits/init.luau")
	Check.eq(#misses, 1, table.concat(misses, "\n"))
	local good = 'return script:WaitForChild("Longship")\n'
	local goodMisses = scanFile(good, scriptNode, services, "src/server/TownKits/init.luau")
	Check.eq(#goodMisses, 0, table.concat(goodMisses, "\n"))
end)

-- These names are created at runtime, or by the engine, so they are not in the Rojo tree.
local RUNTIME_PATH = {
	["ReplicatedStorage.PedlarBoard"] = true,
	["Workspace.Plots"] = true,
	["Workspace.Town"] = true,
	["Workspace.Camera"] = true,
}

local function isRuntimeMiss(miss: string): boolean
	for path in RUNTIME_PATH do
		local at = string.find(miss, "missing " .. path, 1, true)
		if at ~= nil and string.sub(miss, at + #"missing " + #path, at + #"missing " + #path) ~= "." then
			return true
		end
	end
	return false
end

Check.test("every static WaitForChild path in src exists in the rojo tree", function()
	local projects = { "default.project.json", "serve.test.project.json" }
	local total = 0
	local sawInit = false
	for _, projectPath in projects do
		local misses, checked = scanProject(projectPath)
		local authored = {}
		for _, miss in misses do
			if not isRuntimeMiss(miss) then
				table.insert(authored, miss)
			end
		end
		total += #checked
		for _, item in checked do
			if
				string.find(item, "src/server/TownKits/init.luau -> ServerScriptService.TownKits.Longship", 1, true)
				~= nil
			then
				sawInit = true
			end
		end
		Check.eq(#authored, 0, table.concat(authored, "\n"))
	end
	Check.eq(sawInit, true)
	Check.eq(total > 100, true, "checked " .. tostring(total))
	print(string.format("rojo paths checked=%d", total))
end)
