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
	Vector2 = {
		new = function(x: number, y: number)
			return { X = x, Y = y }
		end,
	},
	NumberRange = {
		new = function(minValue: number, maxValue: number?)
			return { Min = minValue, Max = maxValue or minValue }
		end,
	},
	ColorSequence = {
		new = function(color: any)
			return { color = color }
		end,
	},
	NumberSequence = {
		new = function(value: any)
			return { value = value }
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
			Vector2 = roblox.Vector2,
			CFrame = roblox.CFrame,
			NumberRange = roblox.NumberRange,
			ColorSequence = roblox.ColorSequence,
			NumberSequence = roblox.NumberSequence,
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

local Kit = loadModule("src/server/TownKits/Kit.luau")
local TarotTent = loadModule("src/server/TownKits/TarotTent.luau")
local TownKits = loadModule("src/server/TownKits/init.luau")
local TownLook = require("../src/shared/Config/TownLook")

local PIVOT = roblox.Vector3.new(12, 4, -6)
local SPAWN_AT = roblox.Vector3.new(12, 4, -10)

local ALLOWED = {
	["0B0A0C"] = true,
	["7A0F12"] = true,
	["9C7A3C"] = true,
	["E8E0CF"] = true,
	["7FA34A"] = true,
	["4A3024"] = true,
	["140C22"] = true,
	["4C2878"] = true,
	["7C7784"] = true,
}

local BRIGHT = {
	["C45CFF"] = true,
	["6E5C9A"] = true,
	["F3ECFF"] = true,
	["F4E8FF"] = true,
}

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

local function part(parent: any, name: string, at: any): any
	local piece = roblox.Instance.new("Part")
	piece.Name = name
	piece.Anchored = true
	piece.CFrame = roblox.CFrame.new(at)
	piece.Size = roblox.Vector3.new(1, 1, 1)
	piece.Parent = parent
	return piece
end

local function emitOn(host: any, tier: string)
	local emitter = roblox.Instance.new("ParticleEmitter")
	emitter.Name = "TarotFlame" .. tier
	emitter.Rate = if tier == "core" then 16 else 8
	emitter.Lifetime = roblox.NumberRange.new(if tier == "core" then 1 else 1.2, if tier == "core" then 1 else 1.2)
	emitter:SetAttribute("TownEffect", "TarotFlame")
	emitter:SetAttribute("TownFlame", tier)
	emitter.Parent = host
end

local function buildOldTarot(): any
	local town = roblox.Instance.new("Folder")
	town.Name = "Town"
	local model = roblox.Instance.new("Model")
	model.Name = "VeilAndFate"
	model.Parent = town
	local root = part(model, "Root", PIVOT)
	model.PrimaryPart = root
	local pole = part(model, "Pole", PIVOT)
	for _ = 1, 3 do
		part(model, "Pole", PIVOT)
	end
	part(model, "Roof", PIVOT)
	for _ = 1, 3 do
		part(model, "Drape", PIVOT)
	end
	part(model, "Rug", PIVOT)
	part(model, "EyeSigil", PIVOT)
	part(model, "Eye", PIVOT)
	part(model, "Pupil", PIVOT)
	local prompt = roblox.Instance.new("ProximityPrompt")
	prompt.Name = "TarotPrompt"
	prompt.ActionText = "Read the veil"
	prompt:SetAttribute("Kind", "Tarot")
	prompt.Parent = pole
	local spawn = roblox.Instance.new("SpawnLocation")
	spawn.Name = "TarotApproach"
	spawn.Anchored = true
	spawn.CFrame = roblox.CFrame.new(SPAWN_AT)
	spawn.Parent = pole
	local sign = part(model, "Sign", roblox.Vector3.new(12, 13.4, -8.8))
	sign.Size = roblox.Vector3.new(8.6, 2.5, 0.28)
	local gui = roblox.Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Parent = sign
	local label = roblox.Instance.new("TextLabel")
	label.Name = "SignText"
	label.Text = "Veil & Fate"
	label.Parent = gui
	part(model, "SignTrim", roblox.Vector3.new(12, 13.4, -8.68))
	local bowlAt = roblox.Vector3.new(12, 4.3, -10.8)
	part(model, "Bowl", bowlAt)
	part(model, "Flame", roblox.Vector3.new(bowlAt.X, bowlAt.Y + 0.85, bowlAt.Z))
	local host = part(model, "FlameHost", roblox.Vector3.new(bowlAt.X, bowlAt.Y + 1.1, bowlAt.Z))
	emitOn(host, "core")
	emitOn(host, "extra")
	return town
end

local function localOf(inst: any): any
	return roblox.Vector3.new(
		inst.CFrame.Position.X - PIVOT.X,
		inst.CFrame.Position.Y - PIVOT.Y,
		inst.CFrame.Position.Z - PIVOT.Z
	)
end

local function assertTent(model: any, detail: boolean)
	local kitParts = 0
	local maxY = -math.huge
	local spread = 0
	for _, inst in model:GetDescendants() do
		if inst:GetAttribute("TownKitPart") == true then
			kitParts += 1
			Check.eq(inst.Anchored, true, inst.Name)
			Check.eq(inst.Transparency or 0, 0, inst.Name)
			local hex = if inst.Color ~= nil then inst.Color.Hex else nil
			Check.eq(ALLOWED[hex] == true, true, tostring(inst.Name) .. " " .. tostring(hex))
			Check.eq(BRIGHT[hex] == true, false, tostring(inst.Name) .. " bright " .. tostring(hex))
			local localPos = localOf(inst)
			if localPos.Y > maxY then
				maxY = localPos.Y
			end
			spread = math.max(spread, math.abs(localPos.X))
			if inst:GetAttribute("TownDecor") == true then
				Check.eq(inst.CanCollide, false, inst.Name)
				Check.eq(inst.CanTouch, false, inst.Name)
				Check.eq(inst.CanQuery, false, inst.Name)
			end
			if inst.CanCollide == true then
				local blocksDoor = localPos.Z < -2.8
					and localPos.Z > -6
					and math.abs(localPos.X) < 1.55
					and localPos.Y > 0.45
					and localPos.Y < 5.3
				Check.eq(blocksDoor, false, inst.Name .. " blocks the door")
			end
			local materialName = if type(inst.Material) == "table" then inst.Material.Name else nil
			if materialName == "Neon" then
				Check.eq(TownLook.NEON_ROLES[inst:GetAttribute("NeonRole")] == true, true, inst.Name)
			end
		end
	end
	Check.eq(kitParts, if detail then 87 else 36)
	Check.eq(maxY > 11, true, tostring(maxY))
	Check.eq(spread > 3.5, true, tostring(spread))
	Check.eq(countName(model, "MeshPart"), 0)
	Check.eq(countName(model, "Highlight"), 0)
	Check.eq(countName(model, "Humanoid"), 0)
	Check.eq(countName(model, "Pole"), 0)
	Check.eq(countName(model, "Roof"), 0)
	Check.eq(countName(model, "Drape"), 0)
	Check.eq(countName(model, "Rug"), 0)
	Check.eq(countName(model, "EyeSigil"), 0)
	Check.eq(countName(model, "Root"), 1)
	Check.eq(countName(model, "CentrePole"), 1)
	Check.eq(countName(model, "CornerPole"), 4)
	Check.eq(countName(model, "RoofFront"), 1)
	Check.eq(countName(model, "RoofBack"), 1)
	Check.eq(countName(model, "SideGore"), 2)
	Check.eq(countName(model, "Flap"), 2)
	Check.eq(countName(model, "DoorAnchor"), 1)
	Check.eq(countName(model, "DoorPost"), 2)
	Check.eq(countName(model, "Eye"), 1)
	Check.eq(countName(model, "Pupil"), 1)
	Check.eq(countName(model, "Finial"), 1)
	local door = nil
	local prompt = nil
	local spawn = nil
	local text = nil
	local sign = nil
	for _, inst in model:GetDescendants() do
		if inst.Name == "DoorAnchor" then
			door = inst
		elseif inst.ClassName == "ProximityPrompt" then
			prompt = inst
		elseif inst.ClassName == "SpawnLocation" then
			spawn = inst
		elseif inst.Name == "SignText" then
			text = inst.Text
		elseif inst.Name == "Sign" and inst.ClassName == "Part" then
			sign = inst
		end
	end
	Check.eq(text, "Veil & Fate")
	Check.eq(model.PrimaryPart.Name, "Root")
	Check.near(model.PrimaryPart.CFrame.Position.X, PIVOT.X)
	Check.near(model.PrimaryPart.CFrame.Position.Y, PIVOT.Y)
	Check.near(model.PrimaryPart.CFrame.Position.Z, PIVOT.Z)
	Check.eq(prompt.Parent, door)
	Check.eq(prompt.ActionText, "Read the veil")
	Check.eq(prompt:GetAttribute("Kind"), "Tarot")
	Check.eq(spawn.Name, "TarotApproach")
	Check.eq(spawn.Parent, model)
	Check.near(spawn.CFrame.Position.X, SPAWN_AT.X)
	Check.near(spawn.CFrame.Position.Y, SPAWN_AT.Y)
	Check.near(spawn.CFrame.Position.Z, SPAWN_AT.Z)
	Check.eq(door:GetAttribute("TownAnchor"), "Door")
	Check.eq(door.CanQuery, true)
	Check.eq(door.CanCollide, true)
	local signLocal = localOf(sign)
	Check.near(signLocal.Y, 9.6, 0.05, "sign height")
	Check.eq(signLocal.Z < -5, true, tostring(signLocal.Z))
	Check.eq(countClass(model, "PointLight"), if detail then 6 else 3)
	for _, inst in model:GetDescendants() do
		if inst.ClassName == "PointLight" or inst.ClassName == "SpotLight" or inst.ClassName == "SurfaceLight" then
			Check.eq(inst.Shadows, false, inst.Name)
		end
	end
	local life = 0
	for _, inst in model:GetDescendants() do
		if inst.ClassName == "ParticleEmitter" and inst:GetAttribute("TownEffect") == "TarotLife" then
			life += 1
			Check.eq(inst:GetAttribute("TownFlame"), "extra")
			Check.eq(inst.Rate <= 8, true, inst.Name)
			Check.eq(inst.Lifetime.Max <= 3, true, inst.Name)
			Check.eq(inst.Rate * inst.Lifetime.Max <= 120, true, inst.Name)
		end
	end
	if detail then
		Check.eq(countName(model, "Scallop"), 6)
		Check.eq(countName(model, "Tassel"), 6)
		Check.eq(countName(model, "Card"), 3)
		Check.eq(countName(model, "Crystal"), 1)
		Check.eq(countName(model, "CrystalCore"), 1)
		Check.eq(countName(model, "Moon"), 1)
		Check.eq(countName(model, "Incense"), 1)
		Check.eq(countName(model, "IncenseSmoke"), 1)
		Check.eq(countName(model, "MoteDrift"), 1)
		Check.eq(life, 2)
		Check.eq(countClass(model, "ParticleEmitter"), 4)
	else
		Check.eq(countName(model, "Scallop"), 0)
		Check.eq(countName(model, "Tassel"), 0)
		Check.eq(countName(model, "Card"), 0)
		Check.eq(countName(model, "Crystal"), 0)
		Check.eq(countName(model, "Moon"), 0)
		Check.eq(countName(model, "IncenseSmoke"), 0)
		Check.eq(countName(model, "MoteDrift"), 0)
		Check.eq(life, 0)
		Check.eq(countClass(model, "ParticleEmitter"), 2)
	end
	local alive = 0
	local grouped = 0
	for _, inst in model:GetDescendants() do
		if inst.ClassName == "ParticleEmitter" then
			local weight = inst.Rate * inst.Lifetime.Max
			Check.eq(weight <= TownLook.VFX_MAX_PARTICLES, true, inst.Name)
			alive += weight
			if inst:GetAttribute("TownEffect") == "TarotLife" then
				grouped += weight
			end
		end
	end
	Check.eq(grouped <= TownLook.VFX_MAX_PARTICLES, true, tostring(grouped))
	Check.eq(alive <= TownLook.VFX_MAX_PARTICLES, true, tostring(alive))
end

Check.test("tarot tent quality tiers drop ornament, extra lights, and emitters", function()
	Check.eq(Kit.detailEnabled(1), false)
	Check.eq(Kit.detailEnabled(TownLook.LOW_QUALITY_MAX), false)
	Check.eq(Kit.detailEnabled(TownLook.LOW_QUALITY_MAX + 1), true)
	Check.eq(TownLook.EMITTER_CAP, 200)

	for _, level in { 1, TownLook.LOW_QUALITY_MAX } do
		local town = buildOldTarot()
		local report = TarotTent.replace(town, { qualityLevel = level })
		local model = town:FindFirstChild("VeilAndFate")
		assertTent(model, false)
		Check.eq(report.detail, false)
		Check.eq(report.quality, level)
		Check.eq(report.beforeParts, 19)
		Check.eq(report.beforeLights, 0)
		Check.eq(report.afterLights, 3)
		Check.eq(report.beforeEmitters, 2)
		Check.eq(report.afterEmitters, 2)
		Check.eq(report.afterParts, 43)
		Check.eq(report.id, "VeilAndFate")
		local again = TarotTent.replace(town, { qualityLevel = 10 })
		Check.eq(again, nil)
		Check.eq(countName(model, "CentrePole"), 1)
		if level == 1 then
			print(
				string.format(
					"tarot q1 parts=%d lights=%d emitters=%d beforeParts=%d",
					report.afterParts,
					report.afterLights,
					report.afterEmitters,
					report.beforeParts
				)
			)
		end
	end

	local highTown = buildOldTarot()
	local high = TownKits.applyAll(highTown, { qualityLevel = 10 })
	local highModel = highTown:FindFirstChild("VeilAndFate")
	assertTent(highModel, true)
	Check.eq(#high, 1)
	Check.eq(high[1].id, "VeilAndFate")
	Check.eq(high[1].detail, true)
	Check.eq(high[1].beforeParts, 19)
	Check.eq(high[1].beforeLights, 0)
	Check.eq(high[1].afterLights, 6)
	Check.eq(high[1].beforeEmitters, 2)
	Check.eq(high[1].afterEmitters, 4)
	Check.eq(high[1].afterParts, 94)
	local eye = nil
	local lantern = nil
	for _, inst in highModel:GetDescendants() do
		if inst.Name == "EyeGlow" then
			eye = inst
		elseif inst.Name == "LanternGlow" then
			lantern = inst
		end
	end
	Check.eq(eye.ClassName, "PointLight")
	Check.eq(eye.Range, TownLook.TAROT_LIGHT.eye.range)
	Check.eq(eye.Brightness, TownLook.TAROT_LIGHT.eye.brightness)
	Check.eq(eye.Shadows, false)
	Check.eq(eye.Color.Hex, "4C2878")
	Check.eq(lantern.Color.Hex, "9C7A3C")
	Check.eq(lantern.Range, TownLook.TAROT_LIGHT.lantern.range)
	print(
		string.format(
			"tarot q10 parts=%d lights=%d emitters=%d beforeParts=%d beforeLights=%d beforeEmitters=%d",
			high[1].afterParts,
			high[1].afterLights,
			high[1].afterEmitters,
			high[1].beforeParts,
			high[1].beforeLights,
			high[1].beforeEmitters
		)
	)
end)

Check.test("tarot tent does no per-frame work and does not wait on a service root", function()
	local source = fs.readFile("src/server/TownKits/TarotTent.luau") .. fs.readFile("src/server/TownKits/init.luau")
	for _, needle in { "Heartbeat", "RenderStepped", "Stepped", ":Connect", "task.wait", "task.spawn", "task.defer" } do
		Check.eq(string.find(source, needle, 1, true), nil, needle)
	end
	for _, needle in { 'Instance.new("Highlight")', 'Instance.new("MeshPart")', "pumpkin", "GetService" } do
		Check.eq(string.find(source, needle, 1, true), nil, needle)
	end
	Check.eq(string.find(source, 'script.Parent:WaitForChild("Kit")', 1, true) ~= nil, true)
	Check.eq(string.find(source, 'sibling("TarotTent")', 1, true) ~= nil, true)
	Check.eq(string.find(source, "script:WaitForChild(name)", 1, true) ~= nil, true)
	Check.eq(string.find(source, 'script.Parent:WaitForChild("Longship")', 1, true), nil)
	Check.eq(string.find(source, 'script.Parent:WaitForChild("TarotTent")', 1, true), nil)
	Check.eq(string.find(source, 'Instance.new("ParticleEmitter")', 1, true) ~= nil, true)
end)
