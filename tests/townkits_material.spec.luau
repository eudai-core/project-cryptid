--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local luau = require("@lune/luau")

local Check = require("./check")
local TownLook = require("../src/shared/Config/TownLook")
local TownMaterials = require("../src/shared/Config/TownMaterials")

local PALETTE = {
	["0B0A0C"] = true,
	["7A0F12"] = true,
	["9C7A3C"] = true,
	["E8E0CF"] = true,
	["4F6B34"] = true,
}

local function makeInstance(className: string): any
	local inst = {
		ClassName = className,
		_children = {},
		_attrs = {},
		_parent = nil,
		Name = className,
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
		if self.PrimaryPart ~= nil and self.PrimaryPart.CFrame ~= nil then
			return self.PrimaryPart.CFrame
		end
		return newCFrame(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
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
	return setmetatable({ X = x, Y = y, Z = z }, {
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
			if key == "LookVector" then
				return vec(-frame.r02, -frame.r12, -frame.r22)
			end
			return nil
		end,
	})
end

local tags: { [string]: { any } } = {}
local services: { [string]: any } = {}

local function colorFromHex(hex: string): any
	local raw = string.gsub(string.upper(hex), "#", "")
	local function channel(startAt: number): number
		return (tonumber(string.sub(raw, startAt, startAt + 1), 16) or 0) / 255
	end
	local color = {
		R = channel(1),
		G = channel(3),
		B = channel(5),
	}
	function color:ToHex(): string
		local function byte(value: number): number
			return math.clamp(math.floor(value * 255 + 0.5), 0, 255)
		end
		return string.format("#%02X%02X%02X", byte(self.R), byte(self.G), byte(self.B))
	end
	return setmetatable(color, {
		__index = function(_, key)
			if key == "Hex" then
				error("Hex is not a valid member of Color3", 2)
			end
			return nil
		end,
	})
end

local roblox = {
	Color3 = {
		fromHex = colorFromHex,
	},
	Vector3 = {
		new = function(x: number?, y: number?, z: number?)
			return vec(x or 0, y or 0, z or 0)
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
	},
	Enum = setmetatable({}, {
		__index = function(self, enumName)
			local bucket = setmetatable({}, {
				__index = function(items, itemName)
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
			local inst = makeInstance(className)
			if className == "CollectionService" then
				function inst:GetTagged(tag: string): { any }
					return tags[tag] or {}
				end
				function inst:AddTag(target: any, tag: string)
					if tags[tag] == nil then
						tags[tag] = {}
					end
					table.insert(tags[tag], target)
				end
			end
			return inst
		end,
	},
}
roblox.game = {
	GetService = function(_, name: string)
		if services[name] == nil then
			services[name] = roblox.Instance.new(name)
			services[name].Name = name
		end
		return services[name]
	end,
}

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
	error("module not found: " .. spec .. " from " .. fromFile, 2)
end

local function sandboxRequire(spec: string): any
	if string.sub(spec, 1, 6) == "@lune/" then
		return require(spec)
	end
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
			warn = warn,
			unpack = table.unpack,
			task = task,
			debug = debug,
			_G = _G,
			bit32 = bit32,
		}
		sandboxEnv = setmetatable({
			require = sandboxRequire,
			Instance = roblox.Instance,
			game = roblox.game,
			Color3 = roblox.Color3,
			Enum = roblox.Enum,
			Vector3 = roblox.Vector3,
			CFrame = roblox.CFrame,
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

local MaterialPass = loadModule("src/server/TownKits/MaterialPass.luau")
local TownKits = loadModule("src/server/TownKits/init.luau")

local function hexOf(inst: any): string
	if inst.Color == nil or type(inst.Color.ToHex) ~= "function" then
		return ""
	end
	return string.upper(string.gsub(inst.Color:ToHex(), "#", ""))
end

local function materialOf(inst: any): string
	if type(inst.Material) == "table" then
		return inst.Material.Name
	end
	return tostring(inst.Material)
end

local function countKind(root: any, className: string): number
	local total = 0
	for _, inst in root:GetDescendants() do
		if inst.ClassName == className then
			total += 1
		end
	end
	return total
end

local function countParts(root: any): number
	local total = 0
	local classes = { Part = true, WedgePart = true, MeshPart = true, UnionOperation = true }
	for _, inst in root:GetDescendants() do
		if classes[inst.ClassName] == true then
			total += 1
		end
	end
	return total
end

local function makePart(parent: any, name: string, material: string, hex: string, at: any, size: any): any
	local piece = roblox.Instance.new("Part")
	piece.Name = name
	piece.Anchored = true
	piece.Material = roblox.Enum.Material[material]
	piece.Color = roblox.Color3.fromHex(hex)
	piece.CFrame = roblox.CFrame.new(at)
	piece.Size = size
	piece.Transparency = 0
	piece.Parent = parent
	return piece
end

local function buildSample(): any
	local town = roblox.Instance.new("Folder")
	town.Name = "Town"
	makePart(town, "TownWall", "Brick", "FFFFFF", vec(70, 2, 0), vec(8, 4, 1))
	makePart(town, "Cobble", "Cobblestone", "2A2427", vec(0, 0, 0), vec(0.4, 90, 90))
	makePart(town, "Post", "Wood", "4A3024", vec(14, 2, 0), vec(0.6, 4, 0.6))
	makePart(town, "Roof", "WoodPlanks", "7B5434", vec(14, 5, 0), vec(6, 0.4, 6))
	makePart(town, "Plinth", "Basalt", "7C7784", vec(18, 0.3, 4), vec(4, 0.6, 4))
	makePart(town, "Tooth", "SmoothPlastic", "E8E0CF", vec(6, 1, 6), vec(0.3, 0.5, 0.2))
	local flame = makePart(town, "Flame", "Neon", "39F06A", vec(30, 2, 0), vec(0.4, 0.8, 0.4))
	flame:SetAttribute("NeonRole", "flame")
	local root = makePart(town, "Root", "WoodPlanks", "4A3024", vec(0, 0, 0), vec(1, 1, 1))
	root.Transparency = 1
	local sign = makePart(town, "Sign", "WoodPlanks", "1A1719", vec(22, 5, 8), vec(6, 2, 0.3))
	local gui = roblox.Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Parent = sign
	local anchor = makePart(town, "ShopPromptAnchor", "WoodPlanks", "FF00FF", vec(-12, 1, 4), vec(2, 2, 1))
	anchor:SetAttribute("ShopId", "Sample")
	local door = makePart(town, "Door", "WoodPlanks", "4A3024", vec(70, 2, -14), vec(2, 3, 0.3))
	door:SetAttribute("TownAnchor", "Door")
	makePart(town, "TownRoad", "Cobblestone", "2A2427", vec(0, 0.2, 24), vec(16, 0.25, 30))
	local pedlar = roblox.Instance.new("Model")
	pedlar.Name = "PalePedlar"
	pedlar.Parent = town
	makePart(pedlar, "PedlarBrick", "Brick", "AAAAAA", vec(40, 2, 40), vec(4, 3, 1))
	local lantern = makePart(town, "PedlarLantern", "WoodPlanks", "123456", vec(-20, 3, -8), vec(1, 1, 1))
	roblox.game:GetService("CollectionService"):AddTag(lantern, "PedlarLantern")
	local lamp = makePart(town, "Lamp", "Metal", "8C9AA3", vec(-8, 4, 12), vec(1, 1, 1))
	local light = roblox.Instance.new("PointLight")
	light.Name = "LampLight"
	light.Brightness = 3
	light.Range = 12
	light.Parent = lamp
	local host = makePart(town, "MistHost", "Glass", "3EE6D4", vec(8, 1, 18), vec(1, 0.2, 1))
	local emitter = roblox.Instance.new("ParticleEmitter")
	emitter.Name = "SpiritMist"
	emitter.Rate = 6
	emitter.Parent = host
	local portal = roblox.Instance.new("Model")
	portal.Name = "WhisperingWoods"
	portal.Parent = town
	makePart(portal, "Trunk", "WoodPlanks", "4A3024", vec(-16, 3, -18), vec(2, 6, 2))
	local vortex = makePart(portal, "Vortex", "Neon", "39F06A", vec(-16, 4, -18), vec(0.4, 6, 6))
	vortex:SetAttribute("NeonRole", "portal")
	local tree = roblox.Instance.new("Model")
	tree.Name = "RuneheartApothecary"
	tree.Parent = town
	makePart(tree, "Bole", "Wood", "4A3024", vec(16, 4, -20), vec(3, 8, 3))
	local well = roblox.Instance.new("Model")
	well.Name = "WeepingWell"
	well.Parent = town
	local centre = makePart(well, "Centre", "Slate", "7C7784", vec(0, 1, 0), vec(1, 1, 1))
	centre.Transparency = 1
	makePart(well, "Voussoir", "Slate", "7C7784", vec(2, 1, 0), vec(1, 2, 1))
	return town
end

local function snapshot(town: any): { [any]: string }
	local colors = {}
	for _, inst in town:GetDescendants() do
		if inst.ClassName == "Part" and inst:GetAttribute(TownMaterials.ROLE_ATTRIBUTE) ~= nil then
			colors[inst] = hexOf(inst) .. ":" .. materialOf(inst) .. ":" .. tostring(inst.Reflectance)
		end
	end
	return colors
end

Check.test("material pass order is last and empty variants stay unapplied", function()
	Check.eq(TownMaterials.ORDER, 1000)
	Check.eq(TownMaterials.APPLY_EMPTY_VARIANTS, false)
	Check.eq(TownMaterials.NATURE_MIN_QUALITY, 4)
	Check.eq(TownMaterials.DOOR_CLEARANCE, 6)
	Check.eq(MaterialPass.order, 1000)
	Check.eq(MaterialPass.name, "MaterialPass")
	Check.eq(MaterialPass.isKit, true)
	local found = TownKits.discover()
	Check.eq(found[#found].name, "MaterialPass")
	Check.eq(found[#found].order, 1000)
	local source = fs.readFile("src/server/TownKits/MaterialPass.luau")
		.. fs.readFile("src/shared/Config/TownMaterials.luau")
	Check.eq(string.find(source, "rbxasset", 1, true), nil)
	Check.eq(string.find(source, "rbxassetid", 1, true), nil)
	Check.eq(string.find(string.lower(source), "creator store", 1, true), nil)
end)

Check.test("material pass is idempotent, skips protected parts, and stays inside the census guard", function()
	local town = buildSample()
	local beforeLights = countKind(town, "PointLight")
	local beforeEmitters = countKind(town, "ParticleEmitter")
	Check.eq(MaterialPass.replace(town, { qualityLevel = 10 }), nil)
	local first = MaterialPass.last
	Check.eq(first.variantsApplied, 0)
	Check.eq(first.quality, 10)
	Check.eq(first.natureParts > 0, true, "nature " .. tostring(first.natureParts))
	Check.eq(first.tinted > 0, true)
	Check.eq(first.parts <= TownLook.PART_CAP, true, tostring(first.parts))
	Check.eq(first.lights <= TownLook.LIGHT_CAP, true, tostring(first.lights))
	Check.eq(first.emitters <= TownLook.EMITTER_CAP, true, tostring(first.emitters))
	Check.eq(first.parts <= 20000, true)
	Check.eq(first.lights <= 200, true)
	Check.eq(first.emitters <= 200, true)
	Check.eq(countKind(town, "PointLight"), beforeLights)
	Check.eq(countKind(town, "ParticleEmitter"), beforeEmitters)
	local light = nil
	local emitter = nil
	for _, inst in town:GetDescendants() do
		if inst.Name == "LampLight" then
			light = inst
		elseif inst.Name == "SpiritMist" then
			emitter = inst
		end
	end
	Check.eq(light.Brightness, 3)
	Check.eq(light.Range, 12)
	Check.eq(emitter.Rate, 6)

	local function must(name: string): any
		for _, inst in town:GetDescendants() do
			if inst.Name == name then
				return inst
			end
		end
		error("missing " .. name, 2)
	end

	local function untouched(name: string, hex: string, material: string)
		local inst = must(name)
		Check.eq(hexOf(inst), hex, name)
		Check.eq(materialOf(inst), material, name)
		Check.eq(inst:GetAttribute(TownMaterials.ROLE_ATTRIBUTE), nil, name)
	end

	untouched("Flame", "39F06A", "Neon")
	Check.eq(must("Flame"):GetAttribute("NeonRole"), "flame")
	untouched("Vortex", "39F06A", "Neon")
	local root = must("Root")
	Check.eq(root.Transparency, 1)
	Check.eq(root:GetAttribute(TownMaterials.ROLE_ATTRIBUTE), nil)
	untouched("Sign", "1A1719", "WoodPlanks")
	Check.eq(must("Sign"):FindFirstChild("SignGui").ClassName, "SurfaceGui")
	untouched("ShopPromptAnchor", "FF00FF", "WoodPlanks")
	untouched("PedlarBrick", "AAAAAA", "Brick")
	untouched("PedlarLantern", "123456", "WoodPlanks")
	untouched("Lamp", "8C9AA3", "Metal")
	untouched("MistHost", "3EE6D4", "Glass")
	Check.eq(must("Door"):GetAttribute(TownMaterials.ROLE_ATTRIBUTE), nil, "door anchor")

	local wall = must("TownWall")
	Check.eq(wall:GetAttribute(TownMaterials.ROLE_ATTRIBUTE), "AgedBrick")
	Check.eq(materialOf(wall), "Brick")
	Check.eq(PALETTE[hexOf(wall)] == true, true, hexOf(wall))
	Check.eq(wall.MaterialVariant, nil)
	local cobble = must("Cobble")
	Check.eq(cobble:GetAttribute(TownMaterials.ROLE_ATTRIBUTE), "MossyCobble")
	Check.eq(materialOf(cobble), "Cobblestone")
	Check.eq(PALETTE[hexOf(cobble)] == true, true, hexOf(cobble))
	local post = must("Post")
	Check.eq(post:GetAttribute(TownMaterials.ROLE_ATTRIBUTE), "WornDarkTimber")
	Check.eq(materialOf(post), "WoodPlanks")
	Check.eq(PALETTE[hexOf(post)] == true, true, hexOf(post))
	local roof = must("Roof")
	Check.eq(roof:GetAttribute(TownMaterials.ROLE_ATTRIBUTE), "SlateShingle")
	Check.eq(materialOf(roof), "Slate")
	local plinth = must("Plinth")
	Check.eq(plinth:GetAttribute(TownMaterials.ROLE_ATTRIBUTE), "WeatheredStone")
	Check.eq(materialOf(plinth), "Basalt")
	local tooth = must("Tooth")
	Check.eq(tooth:GetAttribute(TownMaterials.ROLE_ATTRIBUTE), "Bone")
	Check.eq(materialOf(tooth), "Limestone")
	Check.eq(PALETTE[hexOf(tooth)] == true, true, hexOf(tooth))
	local bole = must("Bole")
	Check.eq(bole:GetAttribute(TownMaterials.ROLE_ATTRIBUTE), "WornDarkTimber")
	local road = must("TownRoad")
	Check.eq(road:GetAttribute(TownMaterials.ROLE_ATTRIBUTE), "MossyCobble")

	local variantNames = {}
	for _, spec in TownMaterials.VARIANTS do
		variantNames[spec.name] = spec
	end
	local service = roblox.game:GetService("MaterialService")
	for name, spec in variantNames do
		local variant = service:FindFirstChild(name)
		Check.eq(variant.ClassName, "MaterialVariant", name)
		Check.eq(variant.StudsPerTile, spec.studsPerTile, name)
		Check.eq(variant.ColorMap, nil, name)
		Check.eq(variant.NormalMap, nil, name)
		Check.eq(variant.RoughnessMap, nil, name)
		Check.eq(variant.MetalnessMap, nil, name)
		Check.eq(variant:GetAttribute("MapsApplied"), false, name)
		if variant.BaseMaterial ~= nil then
			Check.eq(variant.BaseMaterial.Name, spec.base, name)
		end
	end
	for _, inst in town:GetDescendants() do
		local assigned = inst.MaterialVariant
		Check.eq(assigned == nil or assigned == "", true, tostring(inst.Name))
		if inst:GetAttribute(TownMaterials.NATURE_ATTRIBUTE) ~= nil then
			Check.eq(inst.CanCollide, false, inst.Name)
			Check.eq(inst.CanTouch, false, inst.Name)
			Check.eq(inst.CanQuery, false, inst.Name)
			Check.eq(inst.Anchored, true, inst.Name)
		end
	end

	local nature = town:FindFirstChild(TownMaterials.NATURE_FOLDER)
	Check.eq(nature.ClassName, "Folder")
	local moss = 0
	local ivy = 0
	local roots = 0
	local caps = 0
	for _, inst in nature:GetDescendants() do
		local kind = inst:GetAttribute(TownMaterials.NATURE_ATTRIBUTE)
		if kind == "Moss" then
			moss += 1
		elseif kind == "Ivy" then
			ivy += 1
		elseif kind == "Roots" then
			roots += 1
		elseif kind == "Mushrooms" then
			caps += 1
		end
	end
	Check.eq(moss > 0, true, "moss")
	Check.eq(ivy > 0, true, "ivy")
	Check.eq(roots > 0, true, "roots")
	Check.eq(caps > 0, true, "mushrooms")
	Check.eq(moss + ivy + roots + caps, first.natureParts)

	local colors = snapshot(town)
	local partsBefore = countParts(town)
	local aged = service:FindFirstChild("AgedBrick")
	Check.eq(MaterialPass.replace(town, { qualityLevel = 10 }), nil)
	local second = MaterialPass.last
	Check.eq(second.natureParts, first.natureParts)
	Check.eq(second.tinted, first.tinted)
	Check.eq(second.variantsCreated, 0)
	Check.eq(second.variantsReused, #TownMaterials.VARIANTS)
	Check.eq(service:FindFirstChild("AgedBrick"), aged)
	Check.eq(countParts(town), partsBefore)
	for inst, mark in colors do
		local again = hexOf(inst) .. ":" .. materialOf(inst) .. ":" .. tostring(inst.Reflectance)
		Check.eq(again, mark, inst.Name)
	end
	print(
		string.format(
			"material pass sample tinted=%d nature=%d moss=%d ivy=%d roots=%d mushrooms=%d parts=%d lights=%d emitters=%d",
			first.tinted,
			first.natureParts,
			moss,
			ivy,
			roots,
			caps,
			first.parts,
			first.lights,
			first.emitters
		)
	)
end)

Check.test("quality 1 to 3 adds no nature detail", function()
	for _, level in { 1, 2, 3 } do
		local town = buildSample()
		MaterialPass.replace(town, { qualityLevel = level })
		local report = MaterialPass.last
		Check.eq(report.quality, level)
		Check.eq(report.natureParts, 0, "q" .. tostring(level))
		Check.eq(town:FindFirstChild(TownMaterials.NATURE_FOLDER), nil, "q" .. tostring(level))
		Check.eq(report.tinted > 0, true)
	end
	local town = buildSample()
	MaterialPass.replace(town, { qualityLevel = 10 })
	Check.eq(MaterialPass.last.natureParts > 0, true)
	local withNature = countParts(town)
	MaterialPass.replace(town, { qualityLevel = 2 })
	Check.eq(MaterialPass.last.natureParts, 0)
	Check.eq(town:FindFirstChild(TownMaterials.NATURE_FOLDER), nil)
	Check.eq(countParts(town) < withNature, true)
end)

Check.test("Color3 matches Studio: ToHex and channels, and Hex is not a member", function()
	local color = roblox.Color3.fromHex("E8E0CF")
	Check.eq(color:ToHex(), "#E8E0CF")
	Check.near(color.R, 232 / 255, 0.0001)
	Check.near(color.G, 224 / 255, 0.0001)
	Check.near(color.B, 207 / 255, 0.0001)
	local ok, err = pcall(function()
		return color.Hex
	end)
	Check.eq(ok, false)
	Check.eq(string.find(tostring(err), "Hex is not a valid member of Color3", 1, true) ~= nil, true)
	local source = fs.readFile("src/server/TownKits/MaterialPass.luau")
	Check.eq(string.find(source, ".Hex", 1, true), nil)
	for _, kit in { "Longship", "WeepingWell", "ApothecaryTree", "TarotTent", "Kit" } do
		local kitSource = fs.readFile("src/server/TownKits/" .. kit .. ".luau")
		Check.eq(string.find(kitSource, ".Hex", 1, true), nil, kit)
	end
	local town = buildSample()
	Check.eq(MaterialPass.replace(town, { qualityLevel = 1 }), nil)
	local tooth = nil
	for _, inst in town:GetDescendants() do
		if inst.Name == "Tooth" then
			tooth = inst
		end
	end
	Check.eq(tooth:GetAttribute(TownMaterials.ROLE_ATTRIBUTE), "Bone")
	Check.eq(hexOf(tooth), "E8E0CF")
	local cf = roblox.CFrame.lookAt(roblox.Vector3.new(30, 2, 10), roblox.Vector3.new(0, 2, 10))
	local origin = cf:Inverse() * cf.Position
	Check.near(origin.X, 0, 0.001)
	Check.near(origin.Y, 0, 0.001)
	Check.near(origin.Z, 0, 0.001)
	local raised = cf:Inverse() * (cf.Position + cf.UpVector * 5)
	Check.near(raised.Y, 5, 0.001)
	local beside = cf:Inverse() * (cf.Position + cf.RightVector * 2)
	Check.near(beside.X, 2, 0.001)
end)
