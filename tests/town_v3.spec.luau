--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local serde = require("@lune/serde")

local Check = require("./check")
local Town = require("../src/shared/Config/Town")
local TownLook = require("../src/shared/Config/TownLook")
local UITheme = require("../src/shared/UITheme")

local ENUM_MATERIAL = {
	"Plastic",
	"SmoothPlastic",
	"Neon",
	"Wood",
	"WoodPlanks",
	"Marble",
	"Basalt",
	"Slate",
	"CrackedLava",
	"Concrete",
	"Limestone",
	"Granite",
	"Pavement",
	"Brick",
	"Pebble",
	"Cobblestone",
	"Rock",
	"Sandstone",
	"CorrodedMetal",
	"DiamondPlate",
	"Foil",
	"Metal",
	"Grass",
	"LeafyGrass",
	"Sand",
	"Fabric",
	"Snow",
	"Mud",
	"Ground",
	"Asphalt",
	"Salt",
	"Ice",
	"Glacier",
	"Glass",
	"ForceField",
	"Air",
	"Water",
	"Cardboard",
	"Carpet",
	"CeramicTiles",
	"ClayRoofTiles",
	"RoofShingles",
	"Leather",
	"Plaster",
	"Rubber",
}
local VALID_MATERIAL = {}
for _, name in ENUM_MATERIAL do
	VALID_MATERIAL[name] = true
end

local REQUIRED_SHOPS = { "RuneheartApothecary", "HowlingHorn", "VeilAndFate", "DuskAndDial" }
local REQUIRED_PORTALS = { "WhisperingWoods", "SunkenMarsh", "BoneQuarry" }
local REQUIRED_SIGNS = {
	"Runeheart Apothecary",
	"The Howling Horn",
	"Veil & Fate",
	"Dusk & Dial",
	"Whispering Woods",
	"Sunken Marsh",
	"Level 25+",
	"Bone Quarry",
}
local BANNED = { "pumpkin", "jack-o'-lantern", "jack-o-lantern", "witch hat", "witchhat", "cauldron" }
local VISUAL_FILES = {
	"src/server/TownBuilder.luau",
	"src/shared/Config/TownLook.luau",
	"src/client/TownQuality.luau",
	"src/server/LightingSetup.luau",
	"src/shared/UITheme.luau",
}

local function makeInstance(className: string): any
	local inst = {
		ClassName = className,
		_children = {},
		_attrs = {},
		_parent = nil,
	}
	function inst:GetChildren(): { any }
		return self._children
	end
	function inst:GetDescendants(): { any }
		local out = {}
		local function walk(node: any)
			for _, child in node._children do
				table.insert(out, child)
				walk(child)
			end
		end
		walk(self)
		return out
	end
	function inst:IsA(class: string): boolean
		return self.ClassName == class
	end
	function inst:FindFirstChild(name: string): any
		for _, child in self._children do
			if child.Name == name then
				return child
			end
		end
		return nil
	end
	function inst:FindFirstChildOfClass(class: string): any
		for _, child in self._children do
			if child.ClassName == class then
				return child
			end
		end
		return nil
	end
	function inst:WaitForChild(name: string): any
		local found = self:FindFirstChild(name)
		if found == nil then
			error("missing child " .. name, 2)
		end
		return found
	end
	function inst:SetAttribute(name: string, value: any)
		self._attrs[name] = value
	end
	function inst:GetAttribute(name: string): any
		return self._attrs[name]
	end
	function inst:Destroy()
		self.Parent = nil
	end
	function inst:PivotTo(_: any) end
	function inst:AddTag(_: any, _tag: any) end
	function inst:GetPropertyChangedSignal(_: string): any
		return {
			Connect = function()
				return { Disconnect = function() end }
			end,
		}
	end
	return setmetatable(inst, {
		__newindex = function(self, key, value)
			if key == "Parent" then
				local previous = rawget(self, "_parent")
				if previous ~= nil then
					local kids = previous._children
					for index, child in kids do
						if child == self then
							table.remove(kids, index)
							break
						end
					end
				end
				rawset(self, "_parent", value)
				if value ~= nil then
					table.insert(value._children, self)
				end
				return
			end
			rawset(self, key, value)
		end,
		__index = function(self, key)
			if key == "Parent" then
				return rawget(self, "_parent")
			end
			return nil
		end,
	})
end

local function cf(): any
	return setmetatable({}, {
		__mul = function()
			return cf()
		end,
	})
end

local function vec(x: number, y: number, z: number): any
	return setmetatable({
		X = x,
		Y = y,
		Z = z,
	}, {
		__add = function(a, b)
			return vec(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
		end,
		__sub = function(a, b)
			return vec(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
		end,
		__mul = function(a, b)
			if type(a) == "number" then
				return vec(b.X * a, b.Y * a, b.Z * a)
			end
			if type(b) == "number" then
				return vec(a.X * b, a.Y * b, a.Z * b)
			end
			return vec(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
		end,
		__unm = function(a)
			return vec(-a.X, -a.Y, -a.Z)
		end,
	})
end

local roblox: any = nil

local function installRoblox(): any
	if roblox ~= nil then
		return roblox
	end
	local services = {}
	roblox = {
		Color3 = {
			fromHex = function(hex: string)
				return { Hex = hex }
			end,
		},
		Vector3 = {
			new = function(x: number?, y: number?, z: number?)
				return vec(x or 0, y or 0, z or 0)
			end,
		},
		Vector2 = {
			new = function(x: number, y: number)
				return { X = x, Y = y }
			end,
		},
		CFrame = {
			new = function()
				return cf()
			end,
			lookAt = function()
				return cf()
			end,
			Angles = function()
				return cf()
			end,
		},
		ColorSequence = {
			new = function(color: any)
				return { color = color }
			end,
		},
		NumberRange = {
			new = function(minValue: number, maxValue: number?)
				return { Min = minValue, Max = maxValue or minValue }
			end,
		},
		NumberSequence = {
			new = function(value: any)
				return { value = value }
			end,
		},
		UDim2 = {
			fromScale = function(x: number, y: number)
				return { X = x, Y = y }
			end,
		},
		Enum = setmetatable({}, {
			__index = function(self, enumName)
				local bucket = setmetatable({}, {
					__index = function(items, itemName)
						if enumName == "Material" and VALID_MATERIAL[itemName] ~= true then
							error(tostring(itemName) .. " is not a valid member of Enum.Material", 2)
						end
						local item = { Name = itemName, EnumType = enumName, Value = 0 }
						rawset(items, itemName, item)
						return item
					end,
				})
				rawset(self, enumName, bucket)
				return bucket
			end,
		}),
		Instance = {
			new = function(className: string)
				return makeInstance(className)
			end,
		},
		game = {
			GetService = function(_, name: string)
				if services[name] == nil then
					services[name] = makeInstance(name)
				end
				return services[name]
			end,
		},
		workspace = makeInstance("Workspace"),
	}
	return roblox
end

local moduleCache: { [string]: any } = {}
local sandboxEnv: any = nil

local function modulePath(fromFile: string, spec: string): string
	local dir = string.match(fromFile, "^(.*)/[^/]+$") or ""
	local parts = {}
	for part in string.gmatch(dir .. "/" .. spec, "[^/]+") do
		if part == ".." then
			table.remove(parts)
		elseif part ~= "." then
			table.insert(parts, part)
		end
	end
	local path = table.concat(parts, "/")
	if fs.isFile(path .. ".luau") then
		return path .. ".luau"
	end
	if fs.isFile(path) then
		return path
	end
	error("module not found: " .. spec .. " from " .. fromFile, 2)
end

local function sandboxRequire(spec: string): any
	local caller = debug.info(2, "s")
	local fromFile = string.match(caller, '^%[string "(.*)"%]$') or caller
	local path = modulePath(fromFile, spec)
	if moduleCache[path] ~= nil then
		return moduleCache[path]
	end
	local chunk = luau.load(fs.readFile(path), {
		debugName = path,
		environment = sandboxEnv,
	})
	local loaded = chunk()
	moduleCache[path] = loaded
	return loaded
end

local function loadModule(path: string): any
	installRoblox()
	if sandboxEnv == nil then
		local base = {
			math = math,
			string = string,
			table = table,
			tostring = tostring,
			tonumber = tonumber,
			error = error,
			assert = assert,
			type = type,
			typeof = typeof,
			pairs = pairs,
			ipairs = ipairs,
			next = next,
			select = select,
			pcall = pcall,
			xpcall = xpcall,
			rawget = rawget,
			rawset = rawset,
			rawequal = rawequal,
			setmetatable = setmetatable,
			getmetatable = getmetatable,
			print = print,
			unpack = table.unpack,
			task = task,
			debug = debug,
			_G = _G,
			os = os,
			utf8 = utf8,
			coroutine = coroutine,
			bit32 = bit32,
		}
		sandboxEnv = setmetatable({
			require = sandboxRequire,
			Instance = roblox.Instance,
			game = roblox.game,
			workspace = roblox.workspace,
			Color3 = roblox.Color3,
			Enum = roblox.Enum,
			Vector3 = roblox.Vector3,
			Vector2 = roblox.Vector2,
			CFrame = roblox.CFrame,
			ColorSequence = roblox.ColorSequence,
			NumberRange = roblox.NumberRange,
			NumberSequence = roblox.NumberSequence,
			UDim2 = roblox.UDim2,
		}, {
			__index = base,
		})
	end
	if moduleCache[path] ~= nil then
		return moduleCache[path]
	end
	local chunk = luau.load(fs.readFile(path), {
		debugName = path,
		environment = sandboxEnv,
	})
	local loaded = chunk()
	moduleCache[path] = loaded
	return loaded
end

local builtTown: any = nil
local function townRoot(): any
	if builtTown == nil then
		local TownBuilder = loadModule("src/server/TownBuilder.luau")
		local folder = installRoblox().Instance.new("Folder")
		folder.Name = "Town"
		TownBuilder.build(folder)
		builtTown = folder
	end
	return builtTown
end

local function descendants(root: any): { any }
	return root:GetDescendants()
end

local function materialName(inst: any): string?
	local material = inst.Material
	if type(material) == "table" then
		return material.Name
	end
	return nil
end

local function named(root: any, name: string): any
	for _, inst in descendants(root) do
		if inst.Name == name then
			return inst
		end
	end
	return nil
end

local function countClass(root: any, className: string): number
	local total = 0
	for _, inst in descendants(root) do
		if inst.ClassName == className then
			total += 1
		end
	end
	return total
end

local function channels(hex: string): (number, number, number)
	local red = tonumber(string.sub(hex, 1, 2), 16) or 0
	local green = tonumber(string.sub(hex, 3, 4), 16) or 0
	local blue = tonumber(string.sub(hex, 5, 6), 16) or 0
	return red, green, blue
end

Check.test("v3 night is purple mist with budgeted bloom and a low-quality fallback", function()
	local red, green, blue = channels(UITheme.world.NightMist)
	Check.eq(blue > red and blue > green, true, "NightMist")
	local ambientRed, ambientGreen, ambientBlue = channels(UITheme.palette.LightAmbient)
	Check.eq(ambientBlue > ambientRed and ambientBlue > ambientGreen, true, "LightAmbient")
	local outdoorRed, outdoorGreen, outdoorBlue = channels(UITheme.palette.LightOutdoor)
	Check.eq(outdoorBlue > outdoorRed and outdoorBlue > outdoorGreen, true, "LightOutdoor")
	local violetRed, violetGreen, violetBlue = channels(UITheme.world.FlameViolet)
	Check.eq(violetRed > 140 and violetBlue > 140 and violetGreen < 100, true, "FlameViolet")
	Check.eq(UITheme.lighting.technology, "ShadowMap")
	Check.eq(UITheme.lighting.atmosphereDensity, 0.18)
	Check.eq(UITheme.lighting.atmosphereHaze, 0.3)
	Check.eq(UITheme.lighting.bloomIntensity, 0.45)
	Check.eq(UITheme.lighting.bloomSize, 28)
	Check.eq(UITheme.lighting.bloomThreshold, 1.5)
	Check.eq(UITheme.lighting.bloomEnabled, true)
	Check.eq(TownLook.bloomEnabled(1, true), false)
	Check.eq(TownLook.bloomEnabled(TownLook.LOW_QUALITY_MAX, true), false)
	Check.eq(TownLook.bloomEnabled(0, true), true)
	Check.eq(TownLook.bloomEnabled(10, true), true)
	Check.eq(TownLook.bloomEnabled(10, false), false)
	Check.eq(TownLook.flameTierEnabled("extra", 2), false)
	Check.eq(TownLook.flameTierEnabled("core", 2), true)
	Check.eq(TownLook.flameTierEnabled("extra", 8), true)
	local project = serde.decode("json", fs.readFile("default.project.json"))
	Check.eq(project.tree.Lighting["$properties"].Technology, "ShadowMap")
	local lightingSource = fs.readFile("src/server/LightingSetup.luau")
	Check.contains(lightingSource, "BloomEffect")
	Check.contains(lightingSource, "ColorCorrectionEffect")
	Check.contains(lightingSource, "lighting.atmosphereDensity")
	Check.eq(string.find(lightingSource, ".Technology", 1, true), nil)
	local quality = fs.readFile("src/client/TownQuality.luau")
	Check.contains(quality, "TownLook.bloomEnabled")
	Check.contains(quality, "TownLook.flameTierEnabled")
	Check.contains(quality, "BloomEffect")
	Check.contains(quality, "SavedQualityLevel")

	local LightingSetup = loadModule("src/server/LightingSetup.luau")
	LightingSetup.apply()
	local lighting = installRoblox().game:GetService("Lighting")
	Check.eq(lighting.Technology, nil)
	Check.eq(lighting.Ambient.Hex, UITheme.palette.LightAmbient)
	Check.eq(lighting.OutdoorAmbient.Hex, UITheme.palette.LightOutdoor)
	Check.eq(lighting.FogColor.Hex, UITheme.world.NightMist)
	Check.eq(lighting.FogStart, 250)
	Check.eq(lighting.FogEnd, 1100)
	Check.eq(lighting.Brightness, 1.5)
	local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
	Check.eq(atmosphere.Density, 0.18)
	Check.eq(atmosphere.Haze, 0.3)
	Check.eq(atmosphere.Color.Hex, UITheme.world.NightMist)
	Check.eq(atmosphere.Decay.Hex, UITheme.world.NightSky)
	local bloom = lighting:FindFirstChildOfClass("BloomEffect")
	Check.eq(bloom.Enabled, true)
	Check.eq(bloom.Intensity, 0.45)
	Check.eq(bloom.Size, 28)
	Check.eq(bloom.Threshold, 1.5)
	local grade = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	Check.eq(grade.TintColor.Hex, UITheme.world.SkyTint)
	Check.eq(grade.Saturation, UITheme.lighting.colorSaturation)
end)

Check.test("town part and light counts stay inside the mobile caps", function()
	local root = townRoot()
	local parts = countClass(root, "Part")
	local lights = countClass(root, "PointLight") + countClass(root, "SpotLight") + countClass(root, "SurfaceLight")
	print(
		string.format(
			"town census parts=%d lights=%d capParts=%d capLights=%d",
			parts,
			lights,
			TownLook.PART_CAP,
			TownLook.LIGHT_CAP
		)
	)
	Check.eq(parts <= TownLook.PART_CAP, true, "parts " .. tostring(parts) .. " cap " .. tostring(TownLook.PART_CAP))
	Check.eq(
		lights <= TownLook.LIGHT_CAP,
		true,
		"lights " .. tostring(lights) .. " cap " .. tostring(TownLook.LIGHT_CAP)
	)
	Check.eq(TownLook.LIGHT_CAP, 24)
	Check.eq(TownLook.VFX_MAX_EMITTERS, 6)
	Check.eq(TownLook.VFX_MAX_PARTICLES, 120)
	Check.eq(parts > 0, true)
	Check.eq(lights > 0, true)

	local groups: { [string]: { emitters: number, particles: number } } = {}
	local lone = 0
	for _, inst in descendants(root) do
		if inst.ClassName == "ParticleEmitter" then
			local life = inst.Lifetime
			Check.truthy(life, inst.Name)
			local particles = inst.Rate * life.Max
			local effect = inst:GetAttribute("TownEffect")
			if type(effect) ~= "string" then
				lone += 1
				Check.eq(particles <= TownLook.VFX_MAX_PARTICLES, true, tostring(inst.Name))
			else
				local group = groups[effect]
				if group == nil then
					group = { emitters = 0, particles = 0 }
					groups[effect] = group
				end
				group.emitters += 1
				group.particles += particles
			end
		end
	end
	Check.eq(lone <= 16, true, "untagged emitters " .. tostring(lone))
	for effect, group in groups do
		Check.eq(group.emitters <= TownLook.VFX_MAX_EMITTERS, true, effect .. " emitters " .. tostring(group.emitters))
		Check.eq(
			group.particles <= TownLook.VFX_MAX_PARTICLES,
			true,
			effect .. " particles " .. tostring(group.particles)
		)
	end
	for _, effect in
		{
			"WellSpirit",
			"ApothecaryFlame",
			"TavernFlame",
			"TarotFlame",
			"CrimsonFlame",
			"WhisperingWoods",
			"SunkenMarsh",
			"BoneQuarry",
		}
	do
		Check.truthy(groups[effect], effect)
		Check.eq(groups[effect].emitters >= 1, true, effect)
	end

	local lowOn = 0
	local highOn = 0
	for _, inst in descendants(root) do
		if inst.ClassName == "ParticleEmitter" then
			local tier = inst:GetAttribute("TownFlame")
			if type(tier) == "string" then
				if TownLook.flameTierEnabled(tier, 1) then
					lowOn += 1
				end
				if TownLook.flameTierEnabled(tier, 10) then
					highOn += 1
				end
			end
		end
	end
	Check.eq(lowOn > 0, true)
	Check.eq(lowOn < highOn, true, "low " .. tostring(lowOn) .. " high " .. tostring(highOn))
end)

Check.test("hollowmere is the mythic plaza and neon stays on flames portals runes signs and eyes", function()
	local root = townRoot()
	local hollow = named(root, "Hollowmere")
	Check.truthy(hollow, "Hollowmere")
	for _, id in REQUIRED_SHOPS do
		Check.truthy(named(hollow, id), id)
	end
	for _, id in REQUIRED_PORTALS do
		Check.truthy(named(hollow, id), id)
	end
	local locks = 0
	local vortexes = 0
	local runestones = 0
	local prompts = 0
	local hollowPrompts = 0
	local text = ""
	local hollowIds = {}
	for _, inst in descendants(hollow) do
		hollowIds[inst] = true
	end
	for _, inst in descendants(root) do
		if inst.Name == "LockIcon" and inst.ClassName == "Model" then
			locks += 1
		end
		if inst.Name == "Vortex" then
			vortexes += 1
			Check.eq(materialName(inst), "Neon", "Vortex")
			Check.eq(inst:GetAttribute("NeonRole"), "portal")
		end
		if inst.Name == "Runestone" then
			runestones += 1
		end
		if inst.ClassName == "ProximityPrompt" then
			prompts += 1
			if hollowIds[inst] == true then
				hollowPrompts += 1
			end
		end
		if inst.ClassName == "TextLabel" and type(inst.Text) == "string" then
			text ..= "\n" .. inst.Text
		end
		if materialName(inst) == "Neon" then
			local role = inst:GetAttribute("NeonRole")
			Check.eq(TownLook.NEON_ROLES[role] == true, true, tostring(inst.Name) .. " role " .. tostring(role))
		end
	end
	Check.eq(locks, 3)
	Check.eq(vortexes, 3)
	Check.eq(runestones, Town.WELL_CANDLES)
	Check.eq(prompts, 2)
	Check.eq(hollowPrompts, 0)
	Check.eq(named(root, "WellLight") ~= nil, true)
	Check.eq(countClass(root, "PointLight"), TownLook.LIGHT_CAP)
	for _, sign in REQUIRED_SIGNS do
		Check.contains(text, sign)
	end
	Check.contains(text, Town.SHUTTERED)
	local shutters = 0
	local cursor = 1
	while true do
		local at = string.find(text, Town.SHUTTERED, cursor, true)
		if at == nil then
			break
		end
		shutters += 1
		cursor = at + #Town.SHUTTERED
	end
	Check.eq(shutters, 4)
	local pedlar = named(root, "PalePedlar")
	Check.truthy(pedlar)
	for _, inst in descendants(pedlar) do
		Check.eq(materialName(inst) == "Neon", false, "pedlar " .. tostring(inst.Name))
	end
	local builder = fs.readFile("src/server/TownBuilder.luau")
	Check.eq(string.find(builder, "RemoteEvent", 1, true), nil)
	Check.eq(string.find(builder, "TeleportService", 1, true), nil)
	Check.eq(string.find(builder, "MarketplaceService", 1, true), nil)
	for _, path in VISUAL_FILES do
		local source = string.lower(fs.readFile(path))
		for _, word in BANNED do
			Check.eq(string.find(source, word, 1, true), nil, path .. " " .. word)
		end
	end
	Check.eq(countClass(named(root, "Hollowmere"), "Part") > 0, true)
	local crows = 0
	for _, inst in descendants(root) do
		if inst.Name == "CrowBody" then
			crows += 1
		end
	end
	Check.eq(crows, TownLook.CROW_COUNT)
end)

Check.test("every town material string is a real Enum.Material", function()
	Check.eq(#ENUM_MATERIAL, 45)
	Check.eq(VALID_MATERIAL.Slate, true)
	Check.eq(VALID_MATERIAL.Basalt, true)
	Check.eq(VALID_MATERIAL.altar, nil)
	local configured = 0
	for token, name in UITheme.materials do
		configured += 1
		Check.eq(type(name), "string", tostring(token))
		Check.eq(VALID_MATERIAL[name] == true, true, tostring(token) .. " -> " .. tostring(name))
	end
	Check.eq(configured > 0, true)
	local builder = fs.readFile("src/server/TownBuilder.luau")
	for token, _name in UITheme.materials do
		if VALID_MATERIAL[token] ~= true then
			Check.eq(
				string.find(builder, '"' .. token .. '"', 1, true),
				nil,
				"TownBuilder quotes material key " .. token
			)
		end
	end
	local root = townRoot()
	local used = 0
	for _, inst in descendants(root) do
		if inst.ClassName ~= "Part" then
			continue
		end
		local mat = materialName(inst)
		if mat == nil then
			continue
		end
		used += 1
		Check.eq(VALID_MATERIAL[mat] == true, true, tostring(inst.Name) .. " " .. mat)
	end
	Check.eq(used > 0, true)
	Check.eq(used <= countClass(root, "Part"), true)
end)
