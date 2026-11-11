--!strict

_G.LUNE = true

local fs = require("@lune/fs")
local luau = require("@lune/luau")

local Check = require("./check")

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
	function inst:SetAttribute(name: string, value: any)
		self._attrs[name] = value
	end
	function inst:GetAttribute(name: string): any
		return self._attrs[name]
	end
	function inst:Destroy()
		local kids = {}
		for _, child in self._children do
			table.insert(kids, child)
		end
		for _, child in kids do
			child:Destroy()
		end
		self.Parent = nil
	end
	function inst:Clone(): any
		local copy = makeInstance(self.ClassName)
		for _, key in
			{
				"Name",
				"Size",
				"CFrame",
				"Anchored",
				"Material",
				"Color",
				"CanCollide",
				"CanTouch",
				"CanQuery",
				"CastShadow",
				"Transparency",
				"Shape",
			}
		do
			local value = rawget(self, key)
			if value ~= nil then
				copy[key] = value
			end
		end
		for key, value in self._attrs do
			copy:SetAttribute(key, value)
		end
		return copy
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

local function newCFrame(
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
			if key == "LookVector" then
				return vec(-frame.r02, -frame.r12, -frame.r22)
			end
			return nil
		end,
	})
end

local function identity(): any
	return newCFrame(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
end

local services = {}
local roblox = {
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
	CFrame = {
		new = function(x: any, y: number?, z: number?)
			if x == nil then
				return identity()
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
	NumberRange = {
		new = function(minValue: number, maxValue: number?)
			return { Min = minValue, Max = maxValue or minValue }
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
			return makeInstance(className)
		end,
	},
	game = {
		GetService = function(_, name: string)
			if services[name] == nil then
				services[name] = makeInstance(name)
				services[name].Name = name
			end
			return services[name]
		end,
	},
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
			setmetatable = setmetatable,
			getmetatable = getmetatable,
			print = print,
			unpack = table.unpack,
			_G = _G,
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

local WeepingWell = loadModule("src/server/TownKits/WeepingWell.luau")
local TownKits = loadModule("src/server/TownKits/init.luau")
local Town = require("../src/shared/Config/Town")
local TownLook = require("../src/shared/Config/TownLook")
local Plots = require("../src/shared/Config/Plots")
local UITheme = require("../src/shared/UITheme")

local TOKENS = { "Stone", "Void", "Bark", "ShipWood", "Gold", "Spirit", "Ash", "Blood" }
local ALLOWED = {}
for _, token in TOKENS do
	local hex = UITheme.palette[token] or UITheme.world[token]
	Check.truthy(hex, token)
	ALLOWED[hex] = true
end

local COLLIDE = { Voussoir = true, Water = true, Post = true, Lintel = true }
local DECOR_SHADOW = { Roof = true, Ridge = true, Bucket = true }
local DECOR_FLAT = { Chain = true, Rune = true, Weep = true, Glint = true, Sigil = true, Hoop = true }

local function countName(root: any, name: string): number
	local total = 0
	for _, inst in root:GetDescendants() do
		if inst.Name == name then
			total += 1
		end
	end
	return total
end

local function countClass(root: any, className: string): number
	local total = 0
	for _, inst in root:GetDescendants() do
		if inst.ClassName == className then
			total += 1
		end
	end
	return total
end

local function xz(a: any, b: any): number
	local dx = a.X - b.X
	local dz = a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

local function particlesOf(root: any): number
	local total = 0
	for _, inst in root:GetDescendants() do
		if inst.ClassName == "ParticleEmitter" then
			local life = inst.Lifetime
			total += inst.Rate * life.Max
		end
	end
	return total
end

local function buildOldWell(): any
	local town = roblox.Instance.new("Folder")
	town.Name = "Town"
	local model = roblox.Instance.new("Model")
	model.Name = "WeepingWell"
	model:SetAttribute("PlazaRef", "origin-well")
	model.Parent = town
	local y = Plots.FALLBACK_THICKNESS + Town.WELL_HEIGHT / 2
	local centre = roblox.Instance.new("Part")
	centre.Name = "Centre"
	centre.Anchored = true
	centre.CanCollide = false
	centre.CanQuery = false
	centre.Transparency = 1
	centre.CFrame = roblox.CFrame.new(Town.WELL_OFFSET, y, 0)
	centre.Size = roblox.Vector3.new(1, 1, 1)
	centre.Parent = model
	model.PrimaryPart = centre

	local stone = roblox.Instance.new("Part")
	stone.Name = "Stone"
	stone.Anchored = true
	stone.CanCollide = true
	stone.CFrame = centre.CFrame
	stone.Parent = model
	local oldWater = roblox.Instance.new("Part")
	oldWater.Name = "WellWater"
	oldWater.Anchored = true
	oldWater.Transparency = 0.35
	oldWater.CFrame = centre.CFrame
	oldWater.Parent = model

	local drip = roblox.Instance.new("Part")
	drip.Name = "WellDrip"
	drip.Anchored = true
	drip.CanQuery = false
	drip.Transparency = 1
	drip.CFrame = roblox.CFrame.new(Town.WELL_OFFSET, y + 0.15, 0)
	drip.Parent = model
	local mist = roblox.Instance.new("ParticleEmitter")
	mist.Name = "SpiritMist"
	mist.Rate = TownLook.MIST_RATE
	mist.Lifetime = roblox.NumberRange.new(TownLook.MIST_LIFE, TownLook.MIST_LIFE)
	mist:SetAttribute("TownEffect", "WellSpirit")
	mist.Parent = drip
	local drift = roblox.Instance.new("ParticleEmitter")
	drift.Name = "RuneDrift"
	drift.Rate = TownLook.RUNE_DRIFT_RATE
	drift.Lifetime = roblox.NumberRange.new(TownLook.RUNE_DRIFT_LIFE, TownLook.RUNE_DRIFT_LIFE)
	drift:SetAttribute("TownEffect", "WellSpirit")
	drift.Parent = drip
	local light = roblox.Instance.new("PointLight")
	light.Name = "WellLight"
	light.Range = TownLook.WELL_LIGHT_RANGE
	light.Brightness = TownLook.WELL_LIGHT_BRIGHTNESS
	light.Shadows = true
	light.Parent = drip

	local runestoneAt = {}
	for index = 1, Town.WELL_CANDLES do
		local theta = (index - 1) * (2 * math.pi / Town.WELL_CANDLES)
		local markAt = roblox.CFrame.new(
			Town.WELL_OFFSET + Town.WELL_CANDLE_RADIUS * math.sin(theta),
			y,
			Town.WELL_CANDLE_RADIUS * math.cos(theta)
		)
		local runestone = roblox.Instance.new("Part")
		runestone.Name = "Runestone"
		runestone.Anchored = true
		runestone.CFrame = markAt
		runestone.Parent = model
		table.insert(runestoneAt, { X = markAt.X, Y = markAt.Y, Z = markAt.Z })
		local runeMark = roblox.Instance.new("Part")
		runeMark.Name = "RuneMark"
		runeMark.Anchored = true
		runeMark.CFrame = markAt
		runeMark.Parent = model
	end

	local prompt = roblox.Instance.new("ProximityPrompt")
	prompt.Name = "WellPrompt"
	prompt.ActionText = "Peer into the well"
	prompt:SetAttribute("Kind", "Well")
	prompt.Parent = stone
	local spawn = roblox.Instance.new("SpawnLocation")
	spawn.Name = "WellApproach"
	spawn.Anchored = true
	spawn.CFrame = roblox.CFrame.new(Town.WELL_OFFSET, y, 4)
	spawn.Parent = stone

	local lampPost = roblox.Instance.new("Part")
	lampPost.Name = "RoadLamp"
	lampPost.Parent = town
	local lamp = roblox.Instance.new("PointLight")
	lamp.Name = "LampLight"
	lamp.Shadows = true
	lamp.Parent = lampPost
	local stray = roblox.Instance.new("ParticleEmitter")
	stray.Name = "StreetMist"
	stray.Rate = 1
	stray.Lifetime = roblox.NumberRange.new(1, 1)
	stray.Parent = lampPost

	return town, runestoneAt
end

local function assertWell(model: any, detail: boolean, runestoneAt: { any })
	local centre = model.PrimaryPart
	Check.eq(centre.Name, "Centre")
	Check.eq(centre:GetAttribute("TownAnchor"), "Well")
	Check.eq(model:GetAttribute("PlazaRef"), "origin-well")
	local kitParts = 0
	for _, inst in model:GetDescendants() do
		if inst:GetAttribute("TownKitPart") == true then
			kitParts += 1
			Check.eq(inst.Anchored, true, inst.Name)
			Check.eq(inst.Transparency or 0, 0, inst.Name)
			local hex = if inst.Color ~= nil then inst.Color.Hex else nil
			Check.eq(ALLOWED[hex] == true, true, tostring(inst.Name) .. " " .. tostring(hex))
			if COLLIDE[inst.Name] == true then
				Check.eq(inst.CanCollide, true, inst.Name)
				Check.eq(inst.CanTouch, true, inst.Name)
				Check.eq(inst.CanQuery, true, inst.Name)
				Check.eq(inst.CastShadow, true, inst.Name)
				Check.eq(xz(inst.CFrame.Position, centre.CFrame.Position) <= Town.WELL_DIAMETER / 2, true, inst.Name)
			elseif DECOR_SHADOW[inst.Name] == true or DECOR_FLAT[inst.Name] == true then
				Check.eq(inst:GetAttribute("TownDecor"), true, inst.Name)
				Check.eq(inst.CanCollide, false, inst.Name)
				Check.eq(inst.CanTouch, false, inst.Name)
				Check.eq(inst.CanQuery, false, inst.Name)
				Check.eq(inst.CastShadow, DECOR_SHADOW[inst.Name] == true, inst.Name)
			else
				error("unexpected kit part " .. tostring(inst.Name))
			end
			local materialName = if type(inst.Material) == "table" then inst.Material.Name else nil
			if materialName == "Neon" then
				Check.eq(TownLook.NEON_ROLES[inst:GetAttribute("NeonRole")] == true, true, inst.Name)
			end
		end
		if inst.ClassName == "PointLight" or inst.ClassName == "SpotLight" or inst.ClassName == "SurfaceLight" then
			Check.eq(inst.Shadows, false, inst.Name)
		end
	end
	Check.eq(kitParts > 0, true)
	Check.eq(countName(model, "MeshPart"), 0)
	Check.eq(countName(model, "Highlight"), 0)
	Check.eq(countName(model, "Humanoid"), 0)
	Check.eq(countName(model, "Stone"), 0)
	Check.eq(countName(model, "WellWater"), 0)
	Check.eq(countName(model, "Voussoir"), 8)
	Check.eq(countName(model, "Water"), 1)
	Check.eq(countName(model, "Post"), 2)
	Check.eq(countName(model, "Lintel"), 1)
	Check.eq(countName(model, "Roof"), 2)
	Check.eq(countName(model, "Ridge"), 1)
	Check.eq(countName(model, "Bucket"), 1)
	Check.eq(countName(model, "Chain"), 2)
	Check.eq(countName(model, "Runestone"), Town.WELL_CANDLES)
	Check.eq(countName(model, "RuneMark"), Town.WELL_CANDLES)
	Check.eq(countName(model, "WaterGlow"), 1)
	Check.eq(countName(model, "WellLight"), 1)
	local water = nil
	local prompt = nil
	local spawn = nil
	local drip = nil
	local runestones = {}
	for _, inst in model:GetDescendants() do
		if inst.Name == "Water" and inst.ClassName == "Part" then
			water = inst
		elseif inst.ClassName == "ProximityPrompt" then
			prompt = inst
		elseif inst.ClassName == "SpawnLocation" then
			spawn = inst
		elseif inst.Name == "WellDrip" then
			drip = inst
		elseif inst.Name == "Runestone" then
			table.insert(runestones, inst)
		end
	end
	Check.eq(water:GetAttribute("TownAnchor"), "Basin")
	Check.eq(prompt.Parent, water)
	Check.eq(prompt.ActionText, "Peer into the well")
	Check.eq(prompt:GetAttribute("Kind"), "Well")
	Check.eq(spawn.Name, "WellApproach")
	Check.eq(spawn.Parent, model)
	Check.eq(spawn.CFrame.Position.Z, 4)
	Check.near(centre.CFrame.Position.X, Town.WELL_OFFSET)
	Check.near(centre.CFrame.Position.Y, Plots.FALLBACK_THICKNESS + Town.WELL_HEIGHT / 2)
	Check.near(centre.CFrame.Position.Z, 0)
	local waterTop = 0.2 + 0.4 / 2
	Check.eq(drip.CFrame.Position.Y > centre.CFrame.Position.Y + waterTop, true, tostring(drip.CFrame.Position.Y))
	Check.eq(#runestones, #runestoneAt)
	for index, saved in runestoneAt do
		local at = runestones[index].CFrame.Position
		Check.near(at.X, saved.X, 0.001, "runestone x")
		Check.near(at.Y, saved.Y, 0.001, "runestone y")
		Check.near(at.Z, saved.Z, 0.001, "runestone z")
	end
	local glow = nil
	for _, inst in water:GetChildren() do
		if inst.Name == "WaterGlow" then
			glow = inst
		end
	end
	Check.eq(glow.ClassName, "PointLight")
	Check.eq(glow.Range, TownLook.WELL_WATER_GLOW_RANGE)
	Check.eq(glow.Brightness, TownLook.WELL_WATER_GLOW_BRIGHTNESS)
	Check.eq(glow.Shadows, false)
	Check.eq(glow.Color.Hex, UITheme.world.Spirit)
	if detail then
		Check.eq(countName(model, "Rune"), 8)
		Check.eq(countName(model, "RuneGlow"), 8)
		Check.eq(countName(model, "Weep"), 4)
		Check.eq(countName(model, "Glint"), 1)
		Check.eq(countName(model, "Sigil"), 1)
		Check.eq(countName(model, "Hoop"), 1)
		Check.eq(countClass(model, "ParticleEmitter"), 2)
		Check.eq(countName(model, "SpiritMist"), 1)
		Check.eq(countName(model, "RuneDrift"), 1)
		local alive = particlesOf(model)
		Check.eq(alive <= TownLook.VFX_MAX_PARTICLES, true, tostring(alive))
		Check.eq(countClass(model, "ParticleEmitter") <= TownLook.VFX_MAX_EMITTERS, true)
	else
		Check.eq(countName(model, "Rune"), 0)
		Check.eq(countName(model, "RuneGlow"), 0)
		Check.eq(countName(model, "Weep"), 0)
		Check.eq(countName(model, "Glint"), 0)
		Check.eq(countName(model, "Sigil"), 0)
		Check.eq(countName(model, "Hoop"), 0)
		Check.eq(countClass(model, "ParticleEmitter"), 0)
	end
	local wellLight = nil
	for _, inst in drip:GetChildren() do
		if inst.Name == "WellLight" then
			wellLight = inst
		end
	end
	Check.eq(wellLight.Range, TownLook.WELL_LIGHT_RANGE)
	Check.eq(wellLight.Brightness, TownLook.WELL_LIGHT_BRIGHTNESS)
	Check.eq(wellLight.Shadows, false)
end

Check.test("weeping well replaces the drum and keeps the basin anchors", function()
	Check.eq(TownLook.LIGHT_CAP, 200)
	Check.eq(TownLook.PART_CAP, 20000)
	local town, runestoneAt = buildOldWell()
	local report = TownKits.applyAll(town, { qualityLevel = 10 })
	local model = town:FindFirstChild("WeepingWell")
	Check.eq(#report, 1)
	Check.eq(report[1].id, "WeepingWell")
	Check.eq(report[1].detail, true)
	Check.eq(report[1].beforeLights, 1)
	Check.eq(report[1].afterLights, 10)
	Check.eq(report[1].beforeEmitters, 2)
	Check.eq(report[1].afterEmitters, 2)
	Check.eq(report[1].afterParts - report[1].beforeParts, 31)
	assertWell(model, true, runestoneAt)
	local lamp = nil
	local stray = nil
	for _, inst in town:GetDescendants() do
		if inst.Name == "LampLight" then
			lamp = inst
		elseif inst.Name == "StreetMist" then
			stray = inst
		end
	end
	Check.eq(lamp.Shadows, true)
	Check.eq(stray.Parent.Name, "RoadLamp")
	local again = WeepingWell.replace(town, { qualityLevel = 1 })
	Check.eq(again, nil)
	Check.eq(countName(model, "Voussoir"), 8)
	Check.eq(countName(model, "Rune"), 8)
	print(
		string.format(
			"weeping q10 parts=%d lights=%d emitters=%d particles=%.2f beforeParts=%d beforeLights=%d",
			report[1].afterParts,
			report[1].afterLights,
			report[1].afterEmitters,
			particlesOf(model),
			report[1].beforeParts,
			report[1].beforeLights
		)
	)
end)

Check.test("weeping well quality tiers drop ornament, rune lights, and emitters", function()
	for _, level in { 1, TownLook.LOW_QUALITY_MAX } do
		local town, runestoneAt = buildOldWell()
		local report = WeepingWell.replace(town, { qualityLevel = level })
		local model = town:FindFirstChild("WeepingWell")
		Check.eq(report.detail, false)
		Check.eq(report.quality, level)
		Check.eq(report.beforeLights, 1)
		Check.eq(report.afterLights, 2)
		Check.eq(report.beforeEmitters, 2)
		Check.eq(report.afterEmitters, 0)
		Check.eq(report.afterParts - report.beforeParts, 16)
		assertWell(model, false, runestoneAt)
		Check.eq(countName(town, "StreetMist"), 1)
		Check.eq(countName(town, "LampLight"), 1)
		if level == 1 then
			print(
				string.format(
					"weeping q1 parts=%d lights=%d emitters=%d beforeParts=%d",
					report.afterParts,
					report.afterLights,
					report.afterEmitters,
					report.beforeParts
				)
			)
		end
	end
	local town, runestoneAt = buildOldWell()
	local report = WeepingWell.replace(town, { qualityLevel = TownLook.LOW_QUALITY_MAX + 1 })
	Check.eq(report.detail, true)
	Check.eq(report.afterLights, 10)
	Check.eq(report.afterEmitters, 2)
	assertWell(town:FindFirstChild("WeepingWell"), true, runestoneAt)
end)

Check.test("weeping well does no per-frame work and adds no emitters", function()
	local source = fs.readFile("src/server/TownKits/WeepingWell.luau") .. fs.readFile("src/server/TownKits/init.luau")
	for _, needle in { "Heartbeat", "RenderStepped", "Stepped", ":Connect", "task.wait", "task.spawn", "task.defer" } do
		Check.eq(string.find(source, needle, 1, true), nil, needle)
	end
	for _, needle in
		{
			'Instance.new("ParticleEmitter")',
			'Instance.new("Highlight")',
			'Instance.new("MeshPart")',
		}
	do
		Check.eq(string.find(source, needle, 1, true), nil, needle)
	end
	Check.eq(string.find(source, "pumpkin", 1, true), nil)
end)
