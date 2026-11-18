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

local services = {}
local roblox = {
	Color3 = {
		fromHex = colorFromHex,
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
	UDim2 = {
		fromScale = function(x: number, y: number)
			return { X = x, Y = y }
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

local Kit = loadModule("src/server/TownKits/Kit.luau")
local ClockTower = loadModule("src/server/TownKits/ClockTower.luau")
local TownKits = loadModule("src/server/TownKits/init.luau")
local TownLook = require("../src/shared/Config/TownLook")

local PIVOT = roblox.Vector3.new(18, 4, -8)

local ALLOWED = {
	["0B0A0C"] = true,
	["1A1719"] = true,
	["1C1917"] = true,
	["2A2427"] = true,
	["7A0F12"] = true,
	["9C7A3C"] = true,
	["C9A55A"] = true,
	["E8E0CF"] = true,
	["A79F90"] = true,
	["F3E6C8"] = true,
	["7C7784"] = true,
	["140C22"] = true,
	["4A3024"] = true,
	["7B5434"] = true,
	["E0263A"] = true,
	["5E7A4A"] = true,
}

local BANNED_HEX = {
	["C45CFF"] = true,
	["F4E8FF"] = true,
	["4C2878"] = true,
	["6E5C9A"] = true,
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

local function buildOldClock(): any
	local town = roblox.Instance.new("Folder")
	town.Name = "Town"
	local model = roblox.Instance.new("Model")
	model.Name = "DuskAndDial"
	model.Parent = town
	local root = part(model, "Root", PIVOT)
	root.Transparency = 1
	model.PrimaryPart = root
	for _ = 1, 5 do
		part(model, "Shaft", PIVOT)
	end
	part(model, "ClockFace", PIVOT)
	part(model, "MoonPhase", PIVOT)
	part(model, "MoonShadow", PIVOT)
	part(model, "Spire", PIVOT)
	local sign = part(model, "Sign", roblox.Vector3.new(PIVOT.X, PIVOT.Y + 6.2, PIVOT.Z - 3.3))
	sign.Size = roblox.Vector3.new(8.6, 2.5, 0.28)
	local gui = roblox.Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Parent = sign
	local label = roblox.Instance.new("TextLabel")
	label.Name = "SignText"
	label.Text = "Dusk & Dial"
	label.Parent = gui
	part(model, "SignTrim", roblox.Vector3.new(PIVOT.X, PIVOT.Y + 6.2, PIVOT.Z - 3.1))
	part(model, "CrowBody", PIVOT)
	part(model, "CrowWing", PIVOT)
	local prompt = roblox.Instance.new("ProximityPrompt")
	prompt.Name = "ClockPrompt"
	prompt.ActionText = "Read the dial"
	prompt:SetAttribute("Kind", "Clock")
	prompt.Parent = model
	local spawn = roblox.Instance.new("SpawnLocation")
	spawn.Name = "ClockApproach"
	spawn.Anchored = true
	spawn.CFrame = roblox.CFrame.new(PIVOT.X, PIVOT.Y, PIVOT.Z - 6)
	spawn.Parent = model
	return town
end

local function localOf(inst: any): any
	return roblox.Vector3.new(
		inst.CFrame.Position.X - PIVOT.X,
		inst.CFrame.Position.Y - PIVOT.Y,
		inst.CFrame.Position.Z - PIVOT.Z
	)
end

local function assertTower(model: any, detail: boolean)
	local kitParts = 0
	local maxY = -math.huge
	local spread = 0
	for _, inst in model:GetDescendants() do
		if inst:GetAttribute("TownKitPart") == true then
			kitParts += 1
			Check.eq(inst.Anchored, true, inst.Name)
			local hex = if inst.Color ~= nil and type(inst.Color.ToHex) == "function"
				then string.gsub(inst.Color:ToHex(), "#", "")
				else nil
			Check.eq(ALLOWED[hex] == true, true, tostring(inst.Name) .. " " .. tostring(hex))
			Check.eq(BANNED_HEX[hex] == true, false, tostring(inst.Name) .. " " .. tostring(hex))
			local localPos = localOf(inst)
			if localPos.Y > maxY then
				maxY = localPos.Y
			end
			spread = math.max(spread, math.abs(localPos.X), math.abs(localPos.Z))
			if inst:GetAttribute("TownDecor") == true then
				Check.eq(inst.CanCollide, false, inst.Name)
				Check.eq(inst.CanTouch, false, inst.Name)
				Check.eq(inst.CanQuery, false, inst.Name)
			end
			if inst.CanCollide == true then
				local blocksDoor = localPos.Z < -2.7
					and localPos.Z > -4.3
					and math.abs(localPos.X) < 0.75
					and localPos.Y > 0.45
					and localPos.Y < 3.05
				Check.eq(blocksDoor, false, inst.Name .. " blocks the door")
			end
			local materialName = if type(inst.Material) == "table" then inst.Material.Name else nil
			if materialName == "Neon" then
				Check.eq(TownLook.NEON_ROLES[inst:GetAttribute("NeonRole")] == true, true, inst.Name)
			end
		end
	end
	Check.eq(kitParts >= 280, true, "kit parts " .. tostring(kitParts))
	if detail then
		Check.eq(kitParts >= 6000, true, "detail kit parts " .. tostring(kitParts))
		Check.eq(countName(model, "MinuteTick"), 48)
		Check.eq(countName(model, "Bezel"), 24)
		Check.eq(countName(model, "Dentil"), 104)
	else
		Check.eq(countName(model, "Dentil"), 0)
	end
	Check.eq(maxY > 19, true, tostring(maxY))
	Check.eq(spread > 3.2 and spread < 8, true, tostring(spread))
	Check.eq(countClass(model, "MeshPart"), 0)
	Check.eq(countClass(model, "Highlight"), 0)
	Check.eq(countClass(model, "Humanoid"), 0)
	Check.eq(countName(model, "Shaft"), 0)
	Check.eq(countName(model, "MoonPhase"), 0)
	Check.eq(countName(model, "MoonShadow"), 0)
	Check.eq(countName(model, "Root"), 1)
	Check.eq(countName(model, "Dial"), 1)
	Check.eq(countName(model, "HourHand"), 1)
	Check.eq(countName(model, "MinuteHand"), 1)
	Check.eq(countName(model, "PendulumRod"), 1)
	Check.eq(countName(model, "PendulumBob"), 1)
	Check.eq(countName(model, "Bell"), 1)
	Check.eq(countName(model, "SpireFace"), 4)
	Check.eq(countName(model, "HourMark"), 12)
	Check.eq(countName(model, "Numeral"), 12)
	Check.eq(countName(model, "DoorAnchor"), 1)
	Check.eq(countName(model, "RavenBody"), 2)
	Check.eq(countName(model, "CrowBody"), 1)
	Check.eq(countName(model, "Gear") >= 2, true)
	if detail then
		Check.eq(countName(model, "Shingle") > 200, true, tostring(countName(model, "Shingle")))
		Check.eq(countName(model, "Gargoyle"), 4)
		Check.eq(countName(model, "GearTooth") > 0, true)
	else
		Check.eq(countName(model, "Shingle"), 0)
		Check.eq(countName(model, "Gargoyle"), 0)
		Check.eq(countName(model, "GearTooth"), 0)
	end
	local door = nil
	local prompt = nil
	local anchor = nil
	local text = nil
	local sign = nil
	local faceGlow = nil
	for _, inst in model:GetDescendants() do
		if inst.Name == "DoorAnchor" then
			door = inst
		elseif inst.Name == "DuskAndDialPromptAnchor" then
			anchor = inst
		elseif inst.ClassName == "ProximityPrompt" then
			prompt = inst
		elseif inst.Name == "SignText" then
			text = inst.Text
		elseif inst.Name == "Sign" and inst.ClassName == "Part" then
			sign = inst
		elseif inst.Name == "FaceGlow" then
			faceGlow = inst
		end
	end
	Check.eq(text, "Dusk & Dial")
	Check.eq(model.PrimaryPart.Name, "Root")
	Check.eq(model.PrimaryPart.Transparency, 1)
	Check.near(model.PrimaryPart.CFrame.Position.X, PIVOT.X)
	Check.near(model.PrimaryPart.CFrame.Position.Y, PIVOT.Y)
	Check.near(model.PrimaryPart.CFrame.Position.Z, PIVOT.Z)
	Check.eq(prompt.Parent, door)
	Check.eq(prompt.ActionText, "Read the dial")
	Check.eq(prompt:GetAttribute("Kind"), "Clock")
	Check.eq(door:GetAttribute("TownAnchor"), "Door")
	Check.eq(door:GetAttribute("ShopId"), nil)
	Check.eq(anchor.Parent, model)
	Check.eq(anchor.Transparency, 1)
	Check.eq(anchor.Anchored, true)
	Check.eq(anchor.CanCollide, false)
	Check.eq(anchor.CanTouch, false)
	Check.eq(anchor.CanQuery, false)
	Check.eq(anchor:GetAttribute("ShopId"), "DuskAndDial")
	Check.eq(anchor:GetAttribute("TownAnchor"), nil)
	Check.eq(countName(model, "DuskAndDialPromptAnchor"), 1)
	Check.eq(countClass(model, "ProximityPrompt"), 1)
	local anchorLocal = localOf(anchor)
	Check.near(anchorLocal.X, 0, 0.05)
	Check.near(anchorLocal.Y, 3, 0.05)
	Check.near(anchorLocal.Z, -3.85, 0.05)
	local signLocal = localOf(sign)
	Check.near(signLocal.Y, 4.55, 0.05, "sign height")
	Check.near(signLocal.Z, -3.9, 0.05, "sign depth")
	local crow = nil
	for _, inst in model:GetDescendants() do
		if inst.Name == "CrowBody" then
			crow = inst
		end
	end
	local crowLocal = localOf(crow)
	Check.near(crowLocal.X, -0.9, 0.05)
	Check.near(crowLocal.Y, 15, 0.05)
	Check.eq(string.gsub(faceGlow.Color:ToHex(), "#", ""), "E0263A")
	Check.eq(faceGlow.Shadows, false)
	local dial = nil
	for _, inst in model:GetDescendants() do
		if inst.Name == "Dial" then
			dial = inst
		end
	end
	Check.eq(string.gsub(dial.Color:ToHex(), "#", ""), "F3E6C8")
	local life = 0
	local grouped = 0
	for _, inst in model:GetDescendants() do
		if inst.ClassName == "ParticleEmitter" then
			local weight = inst.Rate * inst.Lifetime.Max
			Check.eq(weight <= TownLook.VFX_MAX_PARTICLES, true, inst.Name)
			if inst:GetAttribute("TownEffect") == "ClockLife" then
				life += 1
				grouped += weight
				Check.eq(inst:GetAttribute("TownFlame"), "extra")
			end
		end
		if inst.ClassName == "PointLight" or inst.ClassName == "SpotLight" or inst.ClassName == "SurfaceLight" then
			Check.eq(inst.Shadows, false, inst.Name)
		end
	end
	Check.eq(grouped <= TownLook.VFX_MAX_PARTICLES, true, tostring(grouped))
	if detail then
		Check.eq(life, 4)
		Check.eq(countClass(model, "PointLight"), 3)
		Check.eq(countClass(model, "SpotLight"), 1)
	else
		Check.eq(life, 0)
		Check.eq(countClass(model, "PointLight"), 2)
		Check.eq(countClass(model, "SpotLight"), 0)
		Check.eq(countClass(model, "ParticleEmitter"), 0)
	end
	return kitParts
end

Check.test("clock tower quality tiers keep the silhouette and drop the dense pass", function()
	Check.eq(Kit.detailEnabled(1), false)
	Check.eq(Kit.detailEnabled(TownLook.LOW_QUALITY_MAX), false)
	Check.eq(Kit.detailEnabled(TownLook.LOW_QUALITY_MAX + 1), true)
	local lowParts = 0
	local highParts = 0
	for _, level in { 1, TownLook.LOW_QUALITY_MAX } do
		local town = buildOldClock()
		local report = ClockTower.replace(town, { qualityLevel = level })
		local model = town:FindFirstChild("DuskAndDial")
		lowParts = assertTower(model, false)
		Check.eq(report.detail, false)
		Check.eq(report.quality, level)
		Check.eq(report.id, "DuskAndDial")
		Check.eq(report.beforeParts, 15)
		Check.eq(report.afterLights, 2)
		Check.eq(report.afterEmitters, 0)
		Check.eq(model:GetAttribute("TownKit"), "ClockTower")
		Check.eq(model:GetAttribute("KitDetail"), false)
		local again = ClockTower.replace(town, { qualityLevel = 10 })
		Check.eq(again, nil)
		Check.eq(countName(model, "Dial"), 1)
	end
	local town = buildOldClock()
	local report = ClockTower.replace(town, { qualityLevel = 10 })
	local model = town:FindFirstChild("DuskAndDial")
	highParts = assertTower(model, true)
	Check.eq(report.detail, true)
	Check.eq(report.afterLights, 4)
	Check.eq(report.afterEmitters, 4)
	Check.eq(highParts > lowParts, true, tostring(highParts) .. " vs " .. tostring(lowParts))
	print(
		string.format(
			"clock q1 parts=%d lights=%d emitters=%d q10 parts=%d lights=%d emitters=%d",
			lowParts,
			2,
			0,
			highParts,
			report.afterLights,
			report.afterEmitters
		)
	)
end)

Check.test("clock tower is discovered and applyAll builds it", function()
	local found = false
	for _, kit in TownKits.discover() do
		if kit.name == "ClockTower" then
			found = true
		end
	end
	Check.eq(found, true)
	TownKits.strict = true
	TownKits.forceQuality = 10
	local town = buildOldClock()
	local reports, failures = TownKits.applyAll(town, {})
	TownKits.strict = false
	TownKits.forceQuality = nil
	Check.eq(#failures, 0)
	local hit = false
	for _, report in reports do
		if report.id == "DuskAndDial" then
			hit = true
			Check.eq(report.detail, true)
			Check.eq(report.afterParts >= 6000, true, tostring(report.afterParts))
		end
	end
	Check.eq(hit, true)
	local source = fs.readFile("src/server/TownKits/ClockTower.luau")
	Check.eq(string.find(source, 'script.Parent:WaitForChild("Kit")', 1, true) ~= nil, true)
	Check.eq(string.find(source, "Kit.animate", 1, true) ~= nil, true)
	Check.eq(string.find(source, "local function animate", 1, true), nil)
	Check.eq(string.find(source, "Heartbeat", 1, true), nil)
	Check.eq(string.find(source, "GetServerTimeNow", 1, true) ~= nil, true)
	Check.eq(string.find(source, "_G.LUNE", 1, true) ~= nil, true)
	Check.eq(string.find(source, "ServerScriptService", 1, true), nil)
	Check.eq(string.find(source, "FlameViolet", 1, true), nil)
	Check.eq(string.find(source, "MoonGlow", 1, true), nil)
	Check.eq(string.find(string.lower(source), "pumpkin", 1, true), nil)
end)
