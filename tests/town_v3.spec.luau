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

local BASE_PART = {
	Part = true,
	MeshPart = true,
	SpawnLocation = true,
	Seat = true,
	VehicleSeat = true,
	TrussPart = true,
	WedgePart = true,
	CornerWedgePart = true,
	UnionOperation = true,
	NegateOperation = true,
	IntersectOperation = true,
}
local LIGHT = {
	PointLight = true,
	SpotLight = true,
	SurfaceLight = true,
}

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
	"src/server/TownKits/init.luau",
	"src/server/TownKits/Kit.luau",
	"src/server/TownKits/Longship.luau",
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
	function inst:GetPivot(): any
		local primary = rawget(self, "PrimaryPart")
		if primary ~= nil and primary.CFrame ~= nil then
			return primary.CFrame
		end
		if rawget(self, "CFrame") ~= nil then
			return self.CFrame
		end
		return newCFrame(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	end
	function inst:PivotTo(target: any)
		local delta = target * self:GetPivot():Inverse()
		if rawget(self, "CFrame") ~= nil then
			self.CFrame = delta * self.CFrame
		end
		for _, desc in self:GetDescendants() do
			if desc.CFrame ~= nil then
				desc.CFrame = delta * desc.CFrame
			end
		end
	end
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

local newCFrame: (number, number, number, number, number, number, number, number, number, number, number, number) -> any
local vec: (number, number, number) -> any

local function dot(a: any, b: any): number
	return a.X * b.X + a.Y * b.Y + a.Z * b.Z
end

local function cross(a: any, b: any): any
	return vec(a.Y * b.Z - a.Z * b.Y, a.Z * b.X - a.X * b.Z, a.X * b.Y - a.Y * b.X)
end

local function length(a: any): number
	return math.sqrt(dot(a, a))
end

local function unit(a: any): any
	local scale = length(a)
	if scale < 1e-8 then
		return vec(0, 0, 0)
	end
	return vec(a.X / scale, a.Y / scale, a.Z / scale)
end

function vec(x: number, y: number, z: number): any
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

function newCFrame(
	px: number,
	py: number,
	pz: number,
	r00: number,
	r01: number,
	r02: number,
	r10: number,
	r11: number,
	r12: number,
	r20: number,
	r21: number,
	r22: number
): any
	local self = {
		X = px,
		Y = py,
		Z = pz,
		r00 = r00,
		r01 = r01,
		r02 = r02,
		r10 = r10,
		r11 = r11,
		r12 = r12,
		r20 = r20,
		r21 = r21,
		r22 = r22,
	}
	function self:Inverse(): any
		local x = -(self.r00 * self.X + self.r10 * self.Y + self.r20 * self.Z)
		local y = -(self.r01 * self.X + self.r11 * self.Y + self.r21 * self.Z)
		local z = -(self.r02 * self.X + self.r12 * self.Y + self.r22 * self.Z)
		return newCFrame(
			x,
			y,
			z,
			self.r00,
			self.r10,
			self.r20,
			self.r01,
			self.r11,
			self.r21,
			self.r02,
			self.r12,
			self.r22
		)
	end
	function self:ToWorldSpace(point: any): any
		return self * point
	end
	return setmetatable(self, {
		__mul = function(a: any, b: any): any
			if b.r00 == nil then
				return vec(
					a.X + a.r00 * b.X + a.r01 * b.Y + a.r02 * b.Z,
					a.Y + a.r10 * b.X + a.r11 * b.Y + a.r12 * b.Z,
					a.Z + a.r20 * b.X + a.r21 * b.Y + a.r22 * b.Z
				)
			end
			return newCFrame(
				a.X + a.r00 * b.X + a.r01 * b.Y + a.r02 * b.Z,
				a.Y + a.r10 * b.X + a.r11 * b.Y + a.r12 * b.Z,
				a.Z + a.r20 * b.X + a.r21 * b.Y + a.r22 * b.Z,
				a.r00 * b.r00 + a.r01 * b.r10 + a.r02 * b.r20,
				a.r00 * b.r01 + a.r01 * b.r11 + a.r02 * b.r21,
				a.r00 * b.r02 + a.r01 * b.r12 + a.r02 * b.r22,
				a.r10 * b.r00 + a.r11 * b.r10 + a.r12 * b.r20,
				a.r10 * b.r01 + a.r11 * b.r11 + a.r12 * b.r21,
				a.r10 * b.r02 + a.r11 * b.r12 + a.r12 * b.r22,
				a.r20 * b.r00 + a.r21 * b.r10 + a.r22 * b.r20,
				a.r20 * b.r01 + a.r21 * b.r11 + a.r22 * b.r21,
				a.r20 * b.r02 + a.r21 * b.r12 + a.r22 * b.r22
			)
		end,
		__index = function(frame: any, key: string): any
			if key == "Position" then
				return vec(frame.X, frame.Y, frame.Z)
			end
			if key == "RightVector" or key == "XVector" then
				return vec(frame.r00, frame.r10, frame.r20)
			end
			if key == "UpVector" or key == "YVector" then
				return vec(frame.r01, frame.r11, frame.r21)
			end
			if key == "ZVector" then
				return vec(frame.r02, frame.r12, frame.r22)
			end
			if key == "LookVector" then
				return vec(-frame.r02, -frame.r12, -frame.r22)
			end
			return nil
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
			new = function(x: any, y: number?, z: number?)
				if x == nil then
					return newCFrame(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				end
				if type(x) ~= "number" then
					return newCFrame(x.X, x.Y, x.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				end
				return newCFrame(x, y or 0, z or 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			end,
			lookAt = function(eye: any, target: any, up: any?)
				local forward = unit(vec(target.X - eye.X, target.Y - eye.Y, target.Z - eye.Z))
				local worldUp = up or vec(0, 1, 0)
				local right = cross(forward, worldUp)
				if length(right) < 1e-6 then
					right = cross(forward, vec(0, 0, 1))
				end
				right = unit(right)
				local back = vec(-forward.X, -forward.Y, -forward.Z)
				local raised = cross(back, right)
				return newCFrame(
					eye.X,
					eye.Y,
					eye.Z,
					right.X,
					raised.X,
					back.X,
					right.Y,
					raised.Y,
					back.Y,
					right.Z,
					raised.Z,
					back.Z
				)
			end,
			Angles = function(rx: number, ry: number, rz: number)
				local cx, sx = math.cos(rx), math.sin(rx)
				local cy, sy = math.cos(ry), math.sin(ry)
				local cz, sz = math.cos(rz), math.sin(rz)
				return newCFrame(
					0,
					0,
					0,
					cz * cy,
					cz * sy * sx - sz * cx,
					cz * sy * cx + sz * sx,
					sz * cy,
					sz * sy * sx + cz * cx,
					sz * sy * cx - cz * sx,
					-sy,
					cy * sx,
					cy * cx
				)
			end,
			fromMatrix = function(pos: any, vx: any, vy: any, vz: any?)
				local back = vz
				if back == nil then
					back = cross(vx, vy)
				end
				return newCFrame(pos.X, pos.Y, pos.Z, vx.X, vy.X, back.X, vx.Y, vy.Y, back.Y, vx.Z, vy.Z, back.Z)
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
	if fs.isFile(path .. "/init.luau") then
		return path .. "/init.luau"
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
		local roblox = installRoblox()
		local PlotBuilder = loadModule("src/server/PlotBuilder.luau")
		local TownBuilder = loadModule("src/server/TownBuilder.luau")
		local folder = roblox.Instance.new("Folder")
		folder.Name = "Town"
		folder.Parent = roblox.workspace
		PlotBuilder.buildGround(folder)
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

local function townCensus(root: any): (number, number, { [string]: { parts: number, lights: number } })
	local parts = 0
	local lights = 0
	local byName: { [string]: { parts: number, lights: number } } = {}
	local function bump(name: string, partDelta: number, lightDelta: number)
		local row = byName[name]
		if row == nil then
			row = { parts = 0, lights = 0 }
			byName[name] = row
		end
		row.parts += partDelta
		row.lights += lightDelta
	end
	for _, inst in descendants(root) do
		local owner = inst
		while owner.Parent ~= nil and owner.Parent ~= root do
			owner = owner.Parent
		end
		if BASE_PART[inst.ClassName] == true then
			parts += 1
			bump(owner.Name, 1, 0)
		elseif LIGHT[inst.ClassName] == true then
			lights += 1
			bump(owner.Name, 0, 1)
		end
	end
	return parts, lights, byName
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
	local skyNode = project.tree.Lighting.HollowmereSky
	Check.eq(skyNode["$className"], "Sky")
	local skyProps = skyNode["$properties"]
	Check.eq(skyProps.SkyboxBk, TownLook.SKYBOX_FACE.bk)
	Check.eq(skyProps.SkyboxDn, TownLook.SKYBOX_FACE.dn)
	Check.eq(skyProps.SkyboxFt, TownLook.SKYBOX_FACE.ft)
	Check.eq(skyProps.SkyboxLf, TownLook.SKYBOX_FACE.lf)
	Check.eq(skyProps.SkyboxRt, TownLook.SKYBOX_FACE.rt)
	Check.eq(skyProps.SkyboxUp, TownLook.SKYBOX_FACE.up)
	Check.eq(skyProps.StarCount, TownLook.SKY_STAR_COUNT)
	Check.eq(skyProps.SunAngularSize, TownLook.SKY_SUN_ANGULAR_SIZE)
	Check.eq(skyProps.MoonAngularSize, TownLook.SKY_MOON_ANGULAR_SIZE)
	Check.eq(skyProps.CelestialBodiesShown, TownLook.SKY_CELESTIAL_BODIES_SHOWN)
	for _, assetId in TownLook.SKYBOX_FACE do
		Check.eq(string.sub(assetId, 1, 11), "rbxasset://", assetId)
		Check.eq(string.find(assetId, "rbxassetid://", 1, true), nil, assetId)
	end
	Check.eq(TownLook.starCount(1), TownLook.SKY_STAR_COUNT_LOW)
	Check.eq(TownLook.starCount(TownLook.LOW_QUALITY_MAX), TownLook.SKY_STAR_COUNT_LOW)
	Check.eq(TownLook.starCount(0), TownLook.SKY_STAR_COUNT)
	Check.eq(TownLook.starCount(8), TownLook.SKY_STAR_COUNT)
	local lightingSource = fs.readFile("src/server/LightingSetup.luau")
	Check.contains(lightingSource, "BloomEffect")
	Check.contains(lightingSource, "ColorCorrectionEffect")
	Check.contains(lightingSource, "TownLook.SKY_ATMOSPHERE_DENSITY")
	Check.contains(lightingSource, "TownLook.SKYBOX_FACE")
	Check.eq(string.find(lightingSource, ".Technology", 1, true), nil)
	Check.eq(string.find(lightingSource, "rbxassetid://", 1, true), nil)
	local quality = fs.readFile("src/client/TownQuality.luau")
	Check.contains(quality, "TownLook.bloomEnabled")
	Check.contains(quality, "TownLook.flameTierEnabled")
	Check.contains(quality, "TownLook.starCount")
	Check.contains(quality, "BloomEffect")
	Check.contains(quality, "SavedQualityLevel")
	Check.contains(quality, 'FindFirstChildOfClass("Sky")')

	local LightingSetup = loadModule("src/server/LightingSetup.luau")
	LightingSetup.apply()
	local lighting = installRoblox().game:GetService("Lighting")
	Check.eq(lighting.Technology, nil)
	Check.eq(lighting.ClockTime, UITheme.lighting.clockTime)
	Check.eq(lighting.Ambient.Hex, TownLook.SKY_AMBIENT)
	Check.eq(lighting.OutdoorAmbient.Hex, TownLook.SKY_OUTDOOR_AMBIENT)
	Check.eq(lighting.ColorShift_Top.Hex, TownLook.SKY_COLOR_SHIFT_TOP)
	Check.eq(lighting.FogColor.Hex, UITheme.world.NightMist)
	Check.eq(lighting.FogStart, 250)
	Check.eq(lighting.FogEnd, 1100)
	Check.eq(lighting.Brightness, 1.5)
	local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
	Check.eq(atmosphere.Density, TownLook.SKY_ATMOSPHERE_DENSITY)
	Check.eq(atmosphere.Haze, TownLook.SKY_ATMOSPHERE_HAZE)
	Check.eq(atmosphere.Glare, TownLook.SKY_ATMOSPHERE_GLARE)
	Check.eq(atmosphere.Color.Hex, TownLook.SKY_ATMOSPHERE_COLOR)
	Check.eq(atmosphere.Decay.Hex, TownLook.SKY_ATMOSPHERE_DECAY)
	local bloom = lighting:FindFirstChildOfClass("BloomEffect")
	Check.eq(bloom.Enabled, true)
	Check.eq(bloom.Intensity, 0.45)
	Check.eq(bloom.Size, 28)
	Check.eq(bloom.Threshold, 1.5)
	local grade = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	Check.eq(grade.TintColor.Hex, TownLook.SKY_GRADE_TINT)
	Check.eq(grade.Saturation, TownLook.SKY_GRADE_SATURATION)
	Check.eq(grade.Saturation < UITheme.lighting.colorSaturation, true)
	local gradeRed, gradeGreen, gradeBlue = channels(TownLook.SKY_GRADE_TINT)
	Check.eq(gradeGreen > 100, true, "grade tint stays pale")
	Check.eq(gradeBlue - gradeRed < 20, true, "grade tint is not a bright violet")
	local skyRed, skyGreen, skyBlue = channels(TownLook.SKY_ATMOSPHERE_COLOR)
	Check.eq(skyRed > skyGreen and skyBlue > skyGreen, true, "horizon violet")
	Check.eq(skyBlue < 140 and skyRed < 140, true, "horizon stays muted")
	local shiftRed, shiftGreen, shiftBlue = channels(TownLook.SKY_COLOR_SHIFT_TOP)
	Check.eq(shiftRed > shiftGreen and shiftBlue > shiftGreen, true, "zenith shift")
	Check.eq(shiftBlue < 80, true, "zenith shift stays dark")
	local sky = lighting:FindFirstChildOfClass("Sky")
	Check.eq(sky.ClassName, "Sky")
	Check.eq(sky.Name, "HollowmereSky")
	Check.eq(sky.SkyboxBk, TownLook.SKYBOX_FACE.bk)
	Check.eq(sky.SkyboxDn, TownLook.SKYBOX_FACE.dn)
	Check.eq(sky.SkyboxFt, TownLook.SKYBOX_FACE.ft)
	Check.eq(sky.SkyboxLf, TownLook.SKYBOX_FACE.lf)
	Check.eq(sky.SkyboxRt, TownLook.SKYBOX_FACE.rt)
	Check.eq(sky.SkyboxUp, TownLook.SKYBOX_FACE.up)
	Check.eq(sky.StarCount, TownLook.SKY_STAR_COUNT)
	Check.eq(sky.SunAngularSize, 0)
	Check.eq(sky.MoonAngularSize, TownLook.SKY_MOON_ANGULAR_SIZE)
	Check.eq(sky.CelestialBodiesShown, true)
end)

Check.test("town part and light counts stay inside the sanity guard", function()
	local root = townRoot()
	Check.eq(root.Parent.ClassName, "Workspace")
	Check.eq(named(root, "Ground") ~= nil, true)
	Check.eq(named(root, "TownPlatform") ~= nil, true)
	Check.eq(named(root, "TownSpawn") ~= nil, true)
	Check.eq(named(root, "Cobble") ~= nil, true)
	Check.eq(countClass(root, "SpawnLocation"), 1)
	local parts, lights, byName = townCensus(root)
	print(
		string.format(
			"town census parts=%d lights=%d capParts=%d capLights=%d",
			parts,
			lights,
			TownLook.PART_CAP,
			TownLook.LIGHT_CAP
		)
	)
	local names = {}
	for name in byName do
		table.insert(names, name)
	end
	table.sort(names)
	for _, name in names do
		local row = byName[name]
		print(string.format("  %s %d/%d", name, row.parts, row.lights))
	end
	Check.eq(byName.Ground.parts, 1)
	Check.eq(byName.TownPlatform.parts, 1)
	Check.eq(byName.TownSpawn.parts, 1)
	Check.eq(byName.Cobble.parts, 1)
	Check.eq(byName.LanternGlass.lights, 4)
	Check.eq(countClass(root, "Highlight"), 0)
	-- Sanity guard only. There is no part budget.
	Check.eq(TownLook.PART_CAP, 20000)
	Check.eq(parts <= 20000, true, "parts " .. tostring(parts))
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

Check.test("player join is hooked before the town build, and TownSpawn is a SpawnLocation", function()
	local main = fs.readFile("src/server/Main.server.luau")
	local connectAt = string.find(main, "Players.PlayerAdded:Connect", 1, true)
	local spawnWatchAt = string.find(main, "SpawnCheck.start()", 1, true)
	local buildAt = string.find(main, "Plot.build()", 1, true)
	Check.truthy(connectAt)
	Check.truthy(spawnWatchAt)
	Check.truthy(buildAt)
	local catchUpAt = string.find(main, "Players:GetPlayers()", buildAt :: number, true)
	Check.truthy(catchUpAt)
	Check.eq((connectAt :: number) < (buildAt :: number), true)
	Check.eq((spawnWatchAt :: number) < (buildAt :: number), true)
	Check.eq((buildAt :: number) < (catchUpAt :: number), true)
	local root = townRoot()
	local spawn = named(root, "TownSpawn")
	Check.truthy(spawn)
	Check.eq(spawn.ClassName, "SpawnLocation")
	Check.eq(spawn.Enabled, true)
	Check.eq(spawn.Neutral, true)
	Check.eq(spawn.Parent, root)
end)

Check.test("town build yields so Play can admit a player", function()
	local function body(source: string, header: string): string
		local at = string.find(source, header, 1, true)
		Check.truthy(at)
		return string.sub(source, at :: number)
	end
	local townBuild = body(fs.readFile("src/server/TownBuilder.luau"), "function TownBuilder.build")
	local plotBuild = body(fs.readFile("src/server/PlotBuilder.luau"), "function PlotBuilder.build(")
	Check.eq(string.find(townBuild, "task.wait()", 1, true) ~= nil, true)
	Check.eq(string.find(plotBuild, "task.wait()", 1, true) ~= nil, true)
	local spawnAt = string.find(plotBuild, "PlotBuilder.buildGround", 1, true)
	local waitAt = string.find(plotBuild, "task.wait()", 1, true)
	local townAt = string.find(plotBuild, "TownBuilder.build", 1, true)
	Check.truthy(spawnAt)
	Check.truthy(waitAt)
	Check.truthy(townAt)
	Check.eq((spawnAt :: number) < (waitAt :: number), true)
	Check.eq((waitAt :: number) < (townAt :: number), true)
end)

Check.test("no part covers a sign's front text", function()
	local depth = 1.1
	local root = townRoot()
	local parts = {}
	for _, inst in root:GetDescendants() do
		if BASE_PART[inst.ClassName] == true and (inst.Transparency or 0) < 1 then
			table.insert(parts, inst)
		end
	end
	local function localPoint(frame: any, point: any): any
		return frame:Inverse() * point
	end
	local function inside(partInst: any, point: any): boolean
		local localPos = localPoint(partInst.CFrame, point)
		local hx = partInst.Size.X / 2
		local hy = partInst.Size.Y / 2
		local hz = partInst.Size.Z / 2
		local shape = if partInst.Shape ~= nil then partInst.Shape.Name else "Block"
		if shape == "Ball" then
			if hx < 1e-4 or hy < 1e-4 or hz < 1e-4 then
				return false
			end
			local nx = localPos.X / hx
			local ny = localPos.Y / hy
			local nz = localPos.Z / hz
			return nx * nx + ny * ny + nz * nz <= 1
		end
		if shape == "Cylinder" then
			if math.abs(localPos.X) > hx then
				return false
			end
			local radius = math.max(hy, hz)
			return localPos.Y * localPos.Y + localPos.Z * localPos.Z <= radius * radius
		end
		return math.abs(localPos.X) <= hx and math.abs(localPos.Y) <= hy and math.abs(localPos.Z) <= hz
	end
	local function ownerName(inst: any): string
		local cursor = inst
		while cursor ~= nil and cursor.ClassName ~= "Model" do
			cursor = cursor.Parent
		end
		if cursor == nil then
			return inst.Name
		end
		return cursor.Name .. "/" .. inst.Name
	end
	local hits = {}
	local signs = 0
	for _, sign in parts do
		local gui = sign:FindFirstChild("SignGui")
		if gui == nil then
			continue
		end
		signs += 1
		local halfX = sign.Size.X / 2 - 0.15
		local halfY = sign.Size.Y / 2 - 0.15
		for row = 0, 4 do
			for col = 0, 6 do
				local x = -halfX + halfX * 2 * (col / 6)
				local y = -halfY + halfY * 2 * (row / 4)
				for layer = 0, 3 do
					local z = -(sign.Size.Z / 2) - 0.05 - depth * (layer / 3)
					local point = sign.CFrame * roblox.Vector3.new(x, y, z)
					for _, other in parts do
						if other ~= sign and inside(other, point) then
							table.insert(hits, ownerName(sign) .. " covered by " .. ownerName(other))
						end
					end
				end
			end
		end
	end
	local unique = {}
	local listed = {}
	for _, hit in hits do
		if unique[hit] ~= true then
			unique[hit] = true
			table.insert(listed, hit)
		end
	end
	Check.eq(signs >= 8, true)
	Check.eq(#listed, 0, table.concat(listed, "; "))
end)

Check.test("longship kit keeps the tavern anchors and stays inside the sanity guard", function()
	local root = townRoot()
	local horn = nil
	for _, inst in descendants(root) do
		if inst.Name == "HowlingHorn" and inst.ClassName == "Model" then
			horn = inst
		end
	end
	Check.truthy(horn, "HowlingHorn")
	Check.eq(horn:GetAttribute("TownKit"), "Longship")
	Check.eq(horn:GetAttribute("KitQuality"), 10)
	Check.eq(horn:GetAttribute("KitDetail"), true)
	Check.eq(horn:GetAttribute("KitBeforeLights"), horn:GetAttribute("KitAfterLights"))
	Check.eq(horn:GetAttribute("KitAfterLights"), 0)
	Check.eq(horn:GetAttribute("KitBeforeEmitters"), horn:GetAttribute("KitAfterEmitters"))
	Check.eq(horn.PrimaryPart.Name, "Root")
	local signText = nil
	local door = nil
	local prompts = 0
	local serpentNeck = 0
	local crow = 0
	local lights = 0
	local highlights = 0
	local mesh = 0
	local humanoids = 0
	local emitters = 0
	local particles = 0
	local kitParts = 0
	for _, inst in descendants(horn) do
		if inst.Name == "SignText" then
			signText = inst.Text
		elseif inst.Name == "DoorAnchor" then
			door = inst
		elseif inst.Name == "SerpentNeck" then
			serpentNeck += 1
		elseif inst.Name == "CrowBody" then
			crow += 1
		end
		if inst.ClassName == "ProximityPrompt" then
			prompts += 1
		elseif inst.ClassName == "PointLight" or inst.ClassName == "SpotLight" or inst.ClassName == "SurfaceLight" then
			lights += 1
		elseif inst.ClassName == "Highlight" then
			highlights += 1
		elseif inst.ClassName == "MeshPart" then
			mesh += 1
		elseif inst.ClassName == "Humanoid" then
			humanoids += 1
		elseif inst.ClassName == "ParticleEmitter" then
			emitters += 1
			local life = inst.Lifetime
			particles += inst.Rate * life.Max
		end
		if inst:GetAttribute("TownKitPart") == true then
			kitParts += 1
			Check.eq(inst.Anchored, true, inst.Name)
			if inst:GetAttribute("TownDecor") == true then
				Check.eq(inst.CanCollide, false, inst.Name)
				Check.eq(inst.CanTouch, false, inst.Name)
				Check.eq(inst.CanQuery, false, inst.Name)
			end
		end
	end
	print(
		string.format(
			"howling beforeParts=%s afterParts=%s beforeLights=%s afterLights=%s emitters=%d particles=%.2f kitParts=%d",
			tostring(horn:GetAttribute("KitBeforeParts")),
			tostring(horn:GetAttribute("KitAfterParts")),
			tostring(horn:GetAttribute("KitBeforeLights")),
			tostring(horn:GetAttribute("KitAfterLights")),
			emitters,
			particles,
			kitParts
		)
	)
	Check.eq(signText, "The Howling Horn")
	Check.truthy(door, "DoorAnchor")
	Check.eq(door:GetAttribute("TownAnchor"), "Door")
	Check.eq(prompts, 0)
	Check.eq(serpentNeck, 0)
	Check.eq(crow, 1)
	Check.eq(lights, 0)
	Check.eq(highlights, 0)
	Check.eq(mesh, 0)
	Check.eq(humanoids, 0)
	Check.eq(emitters <= TownLook.VFX_MAX_EMITTERS, true, tostring(emitters))
	Check.eq(particles <= TownLook.VFX_MAX_PARTICLES, true, tostring(particles))
	Check.eq(kitParts > 0, true)
	local builder = fs.readFile("src/server/TownBuilder.luau")
	local _, hooks = string.gsub(builder, "TownKits.applyAll", "")
	Check.eq(hooks, 1)
end)
