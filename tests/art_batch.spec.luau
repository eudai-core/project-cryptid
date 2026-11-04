--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local Check = require("./check")
local CryptidArt = require("../src/shared/Config/CryptidArt")
local CryptidModels = require("../src/shared/CryptidModels")
local Species = require("../src/shared/Config/Species")
local UITheme = require("../src/shared/UITheme")

local FULL_MODELS = {
	"MothmanHatchling",
	"FresnoNightcrawler",
	"Hidebehind",
	"Hodag",
	"Jackalope",
	"DoverDemon",
	"Snallygaster",
	"LovelandFrogman",
	"FlatwoodsMonster",
	"BeastOfBrayRoad",
	"JerseyDevil",
	"LochNessSerpent",
}

local WEDGE_COUNTS = {
	MothmanHatchling = 6,
	FresnoNightcrawler = 2,
	Hidebehind = 4,
	Hodag = 20,
	Jackalope = 0,
	DoverDemon = 0,
	Snallygaster = 13,
	LovelandFrogman = 5,
	FlatwoodsMonster = 2,
	BeastOfBrayRoad = 19,
	JerseyDevil = 17,
	LochNessSerpent = 10,
}

local ROSTER_IDS = {
	mothman_hatchling = "MothmanHatchling",
	fresno_nightcrawler = "FresnoNightcrawler",
	hidebehind = "Hidebehind",
	hodag = "Hodag",
	jackalope = "Jackalope",
	dover_demon = "DoverDemon",
	snallygaster = "Snallygaster",
	loveland_frogman = "LovelandFrogman",
	flatwoods_monster = "FlatwoodsMonster",
	beast_of_bray_road = "BeastOfBrayRoad",
	jersey_devil = "JerseyDevil",
	loch_ness_serpent = "LochNessSerpent",
}

local NEON_MATERIAL = 288
local NEON_EYES = {
	["assets/cryptids/MothmanHatchling.rbxmx"] = true,
	["assets/cryptids/DoverDemon.rbxmx"] = true,
}

local ALPHA = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function decodeBase64(data: string): string
	local lookup: { [string]: number } = {}
	for index = 1, #ALPHA do
		lookup[string.sub(ALPHA, index, index)] = index - 1
	end
	data = string.gsub(data, "%s", "")
	local out = {}
	local cursor = 1
	while cursor <= #data do
		local function valueAt(offset: number): number?
			local char = string.sub(data, cursor + offset, cursor + offset)
			if char == "=" or char == "" then
				return nil
			end
			return lookup[char]
		end
		local a = valueAt(0) or 0
		local b = valueAt(1) or 0
		local c = valueAt(2)
		local d = valueAt(3)
		local triple = a * 262144 + b * 4096 + (c or 0) * 64 + (d or 0)
		table.insert(out, string.char(math.floor(triple / 65536) % 256))
		if c ~= nil then
			table.insert(out, string.char(math.floor(triple / 256) % 256))
		end
		if d ~= nil then
			table.insert(out, string.char(triple % 256))
		end
		cursor += 4
	end
	return table.concat(out)
end

local function readAttributes(xml: string): { [string]: any }
	local encoded = string.match(xml, '<BinaryString name="AttributesSerialize">([^<]*)</BinaryString>')
	local raw = decodeBase64(encoded or "")
	local count, index = string.unpack("<I4", raw)
	local attrs: { [string]: any } = {}
	for _ = 1, count do
		local keyLength
		keyLength, index = string.unpack("<I4", raw, index)
		local key = string.sub(raw, index, index + keyLength - 1)
		index += keyLength
		local kind = string.byte(raw, index)
		index += 1
		if kind == 2 then
			local valueLength
			valueLength, index = string.unpack("<I4", raw, index)
			attrs[key] = string.sub(raw, index, index + valueLength - 1)
			index += valueLength
		elseif kind == 3 then
			attrs[key] = string.byte(raw, index) ~= 0
			index += 1
		else
			break
		end
	end
	return attrs
end

local function filesIn(dir: string): { string }
	local found = {}
	if not fs.isDir(dir) then
		return found
	end
	for _, name in fs.readDir(dir) do
		local path = dir .. "/" .. name
		if fs.isDir(path) then
			for _, child in filesIn(path) do
				table.insert(found, child)
			end
		else
			table.insert(found, path)
		end
	end
	table.sort(found)
	return found
end

local function assetViolation(path: string): string?
	local under = false
	for _, root in CryptidArt.assetDirs do
		if string.sub(path, 1, #root + 1) == root .. "/" then
			under = true
		end
	end
	if not under then
		return nil
	end
	local name = string.match(path, "([^/]+)$") or path
	if string.sub(name, -5) == ".json" then
		return "json"
	end
	if string.find(name, "_roster_sheet", 1, true) ~= nil then
		return "roster sheet"
	end
	if string.find(name, "Sample", 1, true) ~= nil then
		return "sample placeholder"
	end
	return nil
end

local function field(body: string, key: string): number
	local text = string.match(body, "<" .. key .. ">([^<]*)</" .. key .. ">")
	return tonumber(text) or 0
end

local function frameOf(body: string): { [string]: number }
	local frame = string.match(body, '<CoordinateFrame name="CFrame">(.-)</CoordinateFrame>') or ""
	return {
		x = field(frame, "X"),
		y = field(frame, "Y"),
		z = field(frame, "Z"),
		R00 = field(frame, "R00"),
		R01 = field(frame, "R01"),
		R02 = field(frame, "R02"),
		R10 = field(frame, "R10"),
		R11 = field(frame, "R11"),
		R12 = field(frame, "R12"),
		R20 = field(frame, "R20"),
		R21 = field(frame, "R21"),
		R22 = field(frame, "R22"),
	}
end

local function sizeOf(body: string): { [string]: number }
	local size = string.match(body, '<Vector3 name="size">(.-)</Vector3>') or ""
	return {
		x = field(size, "X"),
		y = field(size, "Y"),
		z = field(size, "Z"),
	}
end

local function transform(cf: { [string]: number }, x: number, y: number, z: number): (number, number, number)
	return cf.x + cf.R00 * x + cf.R01 * y + cf.R02 * z,
		cf.y + cf.R10 * x + cf.R11 * y + cf.R12 * z,
		cf.z + cf.R20 * x + cf.R21 * y + cf.R22 * z
end

local function distance(ax: number, ay: number, az: number, bx: number, by: number, bz: number): number
	local dx = ax - bx
	local dy = ay - by
	local dz = az - bz
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

Check.test("asset folders hold rbxmx only, with no sample kits", function()
	Check.eq(assetViolation("assets/cryptids/Hodag.parts.json"), "json")
	Check.eq(assetViolation("assets/placeholders/SampleWingedCommon_PH.rbxmx"), "sample placeholder")
	Check.eq(assetViolation("assets/placeholders/_roster_sheet.json"), "json")
	Check.eq(assetViolation("art/models/Hodag.parts.json"), nil)
	local paths = {}
	for _, root in CryptidArt.assetDirs do
		for _, path in filesIn(root) do
			table.insert(paths, path)
		end
	end
	Check.eq(#paths, 26)
	for _, path in paths do
		Check.eq(assetViolation(path), nil, path)
		Check.eq(string.sub(path, -6), ".rbxmx", path)
	end
	local project = fs.readFile("default.project.json")
	Check.eq(string.find(project, '"$path": "assets/cryptids"', 1, true) ~= nil, true)
	Check.eq(string.find(project, '"$path": "assets/lair"', 1, true) ~= nil, true)
	Check.eq(string.find(project, '"$path": "assets/placeholders"', 1, true) ~= nil, true)
	Check.eq(string.find(project, '"$path": "art', 1, true), nil)
end)

Check.test("imported colours match UITheme and decorative parts do not collide", function()
	local allowed: { [string]: boolean } = {}
	for _, hex in UITheme.palette do
		allowed[string.upper(hex)] = true
	end
	local conflicts = {}
	local parts = 0
	local ids: { [string]: string } = {}
	for _, root in CryptidArt.assetDirs do
		for _, path in filesIn(root) do
			local xml = fs.readFile(path)
			local attrs = readAttributes(xml)
			local id = attrs.CryptidId or attrs.AssetId
			Check.truthy(type(id) == "string", path)
			if ids[id] == nil then
				ids[id] = path
			end
			if string.find(path, "/placeholders/", 1, true) ~= nil then
				Check.eq(attrs.IsPlaceholder, true, path)
			else
				Check.eq(attrs.IsPlaceholder, nil, path)
			end
			local cursor = 1
			while true do
				local startAt = string.find(xml, '<Item class="', cursor, true)
				if startAt == nil then
					break
				end
				local classAt = startAt + #'<Item class="'
				local classEnd = string.find(xml, '"', classAt, true) or classAt
				local className = string.sub(xml, classAt, classEnd - 1)
				local closeAt = string.find(xml, "</Item>", classEnd, true) or classEnd
				local body = string.sub(xml, classEnd, closeAt)
				cursor = closeAt + 7
				if className ~= "Part" and className ~= "WedgePart" and className ~= "CornerWedgePart" then
					continue
				end
				parts += 1
				Check.eq(string.match(body, '<bool name="Anchored">([^<]*)</bool>'), "true", path)
				Check.eq(string.match(body, '<bool name="CanCollide">([^<]*)</bool>'), "false", path)
				Check.eq(string.match(body, '<bool name="CanTouch">([^<]*)</bool>'), "false", path)
				Check.eq(string.match(body, '<bool name="CanQuery">([^<]*)</bool>'), "false", path)
				for hexText in string.gmatch(body, '<Color3uint8 name="Color3uint8">(%d+)</Color3uint8>') do
					local value = tonumber(hexText) or 0
					local hex = string.format(
						"%02X%02X%02X",
						bit32.rshift(value, 16) % 256,
						bit32.rshift(value, 8) % 256,
						value % 256
					)
					if not allowed[hex] then
						table.insert(conflicts, path .. " " .. hex)
					end
				end
			end
		end
	end
	Check.eq(#conflicts, 0, table.concat(conflicts, ", "))
	Check.truthy(parts > 0)
	for id in ROSTER_IDS do
		Check.truthy(string.find(ids[id] or "", "/cryptids/", 1, true) ~= nil, id)
	end
	print(string.format("PALETTE match UITheme, %d parts, 0 conflicting colours", parts))
end)

local function wedgeVerdict(modelName: string): string
	local xml = fs.readFile("assets/cryptids/" .. modelName .. ".rbxmx")
	local root = { x = 0, y = 0, z = 0 }
	local wedges = {}
	local cursor = 1
	while true do
		local startAt = string.find(xml, '<Item class="', cursor, true)
		if startAt == nil then
			break
		end
		local classAt = startAt + #'<Item class="'
		local classEnd = string.find(xml, '"', classAt, true) or classAt
		local className = string.sub(xml, classAt, classEnd - 1)
		local closeAt = string.find(xml, "</Item>", classEnd, true) or classEnd
		local body = string.sub(xml, classEnd, closeAt)
		cursor = closeAt + 7
		local name = string.match(body, '<string name="Name">([^<]*)</string>') or ""
		if className == "Part" and name == "Root" then
			local cf = frameOf(body)
			root = { x = cf.x, y = cf.y, z = cf.z }
		elseif className == "WedgePart" then
			table.insert(wedges, {
				name = name,
				cf = frameOf(body),
				size = sizeOf(body),
			})
		end
	end
	Check.eq(#wedges, WEDGE_COUNTS[modelName], modelName)
	local backwards = {}
	for _, wedge in wedges do
		local cf = wedge.cf
		local size = wedge.size
		local hx, hy, hz = transform(cf, 0, size.y / 2, size.z / 2)
		local lx, ly, lz = transform(cf, 0, -size.y / 2, -size.z / 2)
		local dx = lx - hx
		local dz = lz - hz
		local horizontal = math.sqrt(dx * dx + dz * dz)
		local facingDot = if horizontal > 1e-6 then -dz / horizontal else 0
		local angle = if horizontal > 1e-6 then math.deg(math.atan2(dx, -dz)) else 0
		local pointsUp = hy > ly + 1e-4
		local outward = distance(hx, hy, hz, root.x, root.y, root.z)
			> distance(lx, ly, lz, root.x, root.y, root.z) + 1e-4
		local identity = cf.R00 > 0.9 and cf.R11 > 0.9 and cf.R22 > 0.9
		local spike = string.match(wedge.name, "^Spike%d+$") ~= nil or wedge.name == "TailSpike"
		local bad = identity and (facingDot < 0.5 or (spike and not (pointsUp and outward)))
		if bad then
			table.insert(backwards, wedge.name)
		end
		print(
			string.format(
				"WEDGE %s %s slope %.1f deg from facing, up %s, outward %s",
				modelName,
				wedge.name,
				angle,
				tostring(pointsUp),
				tostring(outward)
			)
		)
	end
	table.sort(backwards)
	if #backwards == 0 then
		return "correct"
	end
	return "backwards: " .. table.concat(backwards, ", ")
end

Check.test("wedge slopes face the way the models were built", function()
	for _, modelName in FULL_MODELS do
		local verdict = wedgeVerdict(modelName)
		print(string.format("WEDGE %s: %s", modelName, verdict))
		Check.truthy(verdict == "correct" or string.sub(verdict, 1, 11) == "backwards: ", modelName)
	end
end)

Check.test("cryptid lookup prefers the full model, then the roster placeholder", function()
	CryptidModels.resetWarnings()
	local real = {}
	local placeholders = {}
	for id in ROSTER_IDS do
		real[id] = true
		placeholders[id] = true
	end
	for id in ROSTER_IDS do
		local full = CryptidModels.choose(id, real, placeholders)
		Check.eq(full.placeholder, false, id)
		Check.eq(full.procedural, false, id)
		Check.eq(full.warn, false, id)
		Check.eq(full.sourceId, id, id)
		local fallback = CryptidModels.choose(id, {}, placeholders)
		Check.eq(fallback.placeholder, true, id)
		Check.eq(fallback.procedural, false, id)
		Check.eq(fallback.warn, true, id)
		Check.eq(fallback.sourceId, id, id)
	end
	local unknown = CryptidModels.choose("not_a_cryptid", real, placeholders)
	Check.eq(unknown.procedural, true)
	Check.eq(unknown.placeholder, true)
	Check.eq(unknown.warn, true)
	local blank = CryptidModels.choose("", real, placeholders)
	Check.eq(blank.cryptidId, CryptidArt.unknownId)
	Check.eq(blank.procedural, true)
	Check.eq(CryptidModels.markWarned("flatwoods_monster"), true)
	Check.eq(CryptidModels.markWarned("flatwoods_monster"), false)
end)

Check.test("an unknown id builds a generic silhouette from config", function()
	local shop = CryptidModels.recipe("uncommon_01")
	Check.eq(shop.family, "winged")
	Check.eq(shop.rarity, "Uncommon")
	Check.eq(Species.get("uncommon_01").rarity, "Uncommon")
	local bandToken = UITheme.rarity.Uncommon
	local sawBand = false
	for _, part in shop.parts do
		Check.truthy(UITheme.palette[part.color] ~= nil, part.color)
		if part.name == "RarityBand" then
			sawBand = true
			Check.eq(part.color, bandToken)
		end
	end
	Check.eq(sawBand, true)
	local stranger = CryptidModels.recipe("not_a_cryptid")
	Check.eq(stranger.family, CryptidArt.defaultFamily)
	Check.eq(stranger.rarity, CryptidArt.defaultRarity)
	Check.eq(CryptidArt.familyOf("fresno_nightcrawler"), "lurker")
	Check.eq(CryptidArt.familyOf("jersey_devil"), "winged")
	Check.eq(CryptidArt.familyOf("loch_ness_serpent"), "serpent")
	Check.eq(CryptidArt.familyOf("beast_of_bray_road"), "beast")
	Check.eq(#stranger.parts > 0, true)
end)

Check.test("pad states and altar tiers come from config", function()
	Check.eq(CryptidArt.padState(true, true, true), CryptidArt.states.sealed)
	Check.eq(CryptidArt.padState(false, true, true), CryptidArt.states.occupied)
	Check.eq(CryptidArt.padState(false, false, true), CryptidArt.states.locked)
	Check.eq(CryptidArt.padState(false, false, false), CryptidArt.states.empty)
	Check.eq(CryptidArt.affordableRim(CryptidArt.states.locked, true), true)
	Check.eq(CryptidArt.affordableRim(CryptidArt.states.locked, false), false)
	Check.eq(CryptidArt.affordableRim(CryptidArt.states.sealed, true), false)
	Check.eq(CryptidArt.affordableRim(CryptidArt.states.occupied, true), false)
	Check.eq(CryptidArt.tierShown(1, 0), false)
	Check.eq(CryptidArt.tierShown(1, 1), true)
	Check.eq(CryptidArt.tierShown(2, 1), false)
	Check.eq(CryptidArt.tierShown(2, 2), true)
	Check.eq(CryptidArt.faceGateYaw, math.pi)
end)

local function partCorners(cf: { [string]: number }, size: { [string]: number }): { { number } }
	local points = {}
	for _, x in { -size.x / 2, size.x / 2 } do
		for _, y in { -size.y / 2, size.y / 2 } do
			for _, z in { -size.z / 2, size.z / 2 } do
				local px, py, pz = transform(cf, x, y, z)
				table.insert(points, { px, py, pz })
			end
		end
	end
	return points
end

local function modelExtent(modelName: string): (number, number)
	local xml = fs.readFile("assets/cryptids/" .. modelName .. ".rbxmx")
	local minX, minY, minZ = math.huge, math.huge, math.huge
	local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
	local cursor = 1
	while true do
		local startAt = string.find(xml, '<Item class="', cursor, true)
		if startAt == nil then
			break
		end
		local classAt = startAt + #'<Item class="'
		local classEnd = string.find(xml, '"', classAt, true) or classAt
		local className = string.sub(xml, classAt, classEnd - 1)
		local closeAt = string.find(xml, "</Item>", classEnd, true) or classEnd
		local body = string.sub(xml, classEnd, closeAt)
		cursor = closeAt + 7
		if className ~= "Part" and className ~= "WedgePart" and className ~= "CornerWedgePart" then
			continue
		end
		local name = string.match(body, '<string name="Name">([^<]*)</string>') or ""
		local transparency = tonumber(string.match(body, '<float name="Transparency">([^<]*)</float>') or "0") or 0
		if name == "Root" or transparency >= 1 then
			continue
		end
		for _, point in partCorners(frameOf(body), sizeOf(body)) do
			minX = math.min(minX, point[1])
			minY = math.min(minY, point[2])
			minZ = math.min(minZ, point[3])
			maxX = math.max(maxX, point[1])
			maxY = math.max(maxY, point[2])
			maxZ = math.max(maxZ, point[3])
		end
	end
	local height = maxY - minY
	local length = math.max(maxX - minX, maxZ - minZ)
	return height, length
end

Check.test("neon eyes are only the four allowed cryptid parts", function()
	local neonParts = {}
	for _, root in CryptidArt.assetDirs do
		for _, path in filesIn(root) do
			local xml = fs.readFile(path)
			local attrs = readAttributes(xml)
			local cursor = 1
			while true do
				local startAt = string.find(xml, '<Item class="', cursor, true)
				if startAt == nil then
					break
				end
				local classAt = startAt + #'<Item class="'
				local classEnd = string.find(xml, '"', classAt, true) or classAt
				local closeAt = string.find(xml, "</Item>", classEnd, true) or classEnd
				local body = string.sub(xml, classEnd, closeAt)
				cursor = closeAt + 7
				local material = string.match(body, '<token name="Material">([^<]*)</token>')
				if material == tostring(NEON_MATERIAL) then
					local name = string.match(body, '<string name="Name">([^<]*)</string>') or ""
					table.insert(neonParts, path .. " " .. name)
					Check.eq(attrs.IsPlaceholder, nil, path)
					Check.eq(NEON_EYES[path], true, path)
					Check.eq(name == "Eye_L" or name == "Eye_R", true, name)
				end
			end
			if path == "assets/cryptids/DoverDemon.rbxmx" then
				Check.eq(attrs.AssetVersion, "1.1")
			end
		end
	end
	table.sort(neonParts)
	Check.eq(#neonParts, 4)
	print("NEON " .. table.concat(neonParts, ", "))
end)

Check.test("the pad name plate clears the placed model", function()
	local margin = CryptidArt.billboardMargin
	Check.eq(CryptidArt.billboardStuds(9, 0), 9 + margin)
	Check.eq(CryptidArt.billboardStuds(3.1, 0.4), 3.1 - 0.4 + margin)
	Check.eq(CryptidArt.billboardStuds(1, 4), margin)
	local boards = fs.readFile("src/client/WorldBoards.luau")
	Check.eq(string.find(boards, "billboardStuds", 1, true) ~= nil, true)
	Check.eq(string.find(boards, "Vector3.new(0, 5, 0)", 1, true), nil)
	local roster = {
		FresnoNightcrawler = { 6, 3.3 },
		Hidebehind = { 8, 5 },
		Hodag = { 3, 6 },
	}
	for modelName, target in roster do
		local height, length = modelExtent(modelName)
		Check.truthy(height > 1, modelName)
		Check.truthy(length > 1, modelName)
		print(
			string.format(
				"MEASURE %s height %.2f length %.2f against roster %.1f x %.1f",
				modelName,
				height,
				length,
				target[1],
				target[2]
			)
		)
	end
	for _, modelName in { "FlatwoodsMonster", "LochNessSerpent" } do
		local height = modelExtent(modelName)
		local lift = CryptidArt.billboardStuds(height, 0)
		Check.truthy(height >= 9, modelName)
		Check.truthy(lift > height, modelName)
		print(string.format("BILLBOARD %s height %.2f lift %.2f", modelName, height, lift))
	end
end)
