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

local Kit = loadModule("src/server/TownKits/Kit.luau")
local Longship = loadModule("src/server/TownKits/Longship.luau")
local TownKits = loadModule("src/server/TownKits/init.luau")
local TownLook = require("../src/shared/Config/TownLook")

local ALLOWED = {
	["0B0A0C"] = true,
	["7A0F12"] = true,
	["9C7A3C"] = true,
	["E8E0CF"] = true,
	["7B5434"] = true,
	["4A3024"] = true,
	["7C7784"] = true,
	["3C92FF"] = true,
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

local function buildOldTavern(): any
	local town = roblox.Instance.new("Folder")
	town.Name = "Town"
	local model = roblox.Instance.new("Model")
	model.Name = "HowlingHorn"
	model.Parent = town
	local root = roblox.Instance.new("Part")
	root.Name = "Root"
	root.Anchored = true
	root.CFrame = roblox.CFrame.new(0, 0, 0)
	root.Parent = model
	model.PrimaryPart = root
	local hull = roblox.Instance.new("Part")
	hull.Name = "Hull"
	hull.Anchored = true
	hull.CFrame = roblox.CFrame.new()
	hull.Parent = model
	for _, name in { "Keel", "Deck", "SerpentNeck", "SerpentHead", "SerpentJaw", "Eye", "Eye" } do
		local piece = roblox.Instance.new("Part")
		piece.Name = name
		piece.Anchored = true
		piece.CFrame = roblox.CFrame.new()
		piece.Parent = model
	end
	for _ = 1, 3 do
		local rib = roblox.Instance.new("Part")
		rib.Name = "Rib"
		rib.Anchored = true
		rib.Parent = model
	end
	local prompt = roblox.Instance.new("ProximityPrompt")
	prompt.Name = "TavernPrompt"
	prompt.ActionText = "Enter the hall"
	prompt:SetAttribute("Kind", "Tavern")
	prompt.Parent = hull
	local spawn = roblox.Instance.new("SpawnLocation")
	spawn.Name = "TavernApproach"
	spawn.Anchored = true
	spawn.CFrame = roblox.CFrame.new(0, 0, -4)
	spawn.Parent = hull
	local sign = roblox.Instance.new("Part")
	sign.Name = "Sign"
	sign.Anchored = true
	sign.Size = roblox.Vector3.new(8.6, 2.5, 0.28)
	sign.CFrame = roblox.CFrame.new(0, 8.2, -4.2)
	sign.Parent = model
	local gui = roblox.Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Parent = sign
	local label = roblox.Instance.new("TextLabel")
	label.Name = "SignText"
	label.Text = "The Howling Horn"
	label.Parent = gui
	local trim = roblox.Instance.new("Part")
	trim.Name = "SignTrim"
	trim.Anchored = true
	trim.CFrame = roblox.CFrame.new(0, 8.2, -4.08)
	trim.Parent = model
	for _, name in { "Bowl", "Flame", "FlameHost", "CrowBody", "CrowWing" } do
		local piece = roblox.Instance.new("Part")
		piece.Name = name
		piece.Anchored = true
		piece.CFrame = roblox.CFrame.new()
		piece.Parent = model
	end
	return town
end

local function assertKit(model: any)
	local kitParts = 0
	for _, inst in model:GetDescendants() do
		if inst:GetAttribute("TownKitPart") == true then
			kitParts += 1
			Check.eq(inst.Anchored, true, inst.Name)
			Check.eq(inst.Transparency or 0, 0, inst.Name)
			local hex = if inst.Color ~= nil then inst.Color.Hex else nil
			Check.eq(ALLOWED[hex] == true, true, tostring(inst.Name) .. " " .. tostring(hex))
			if inst:GetAttribute("TownDecor") == true then
				Check.eq(inst.CanCollide, false, inst.Name)
				Check.eq(inst.CanTouch, false, inst.Name)
				Check.eq(inst.CanQuery, false, inst.Name)
			end
			local materialName = if type(inst.Material) == "table" then inst.Material.Name else nil
			if materialName == "Neon" then
				Check.eq(TownLook.NEON_ROLES[inst:GetAttribute("NeonRole")] == true, true, inst.Name)
			end
		end
	end
	Check.eq(kitParts > 0, true)
	Check.eq(countName(model, "MeshPart"), 0)
	Check.eq(countName(model, "Highlight"), 0)
	Check.eq(countName(model, "Humanoid"), 0)
	Check.eq(countName(model, "PointLight") + countName(model, "SpotLight") + countName(model, "SurfaceLight"), 0)
	Check.eq(countName(model, "SerpentNeck"), 0)
	Check.eq(countName(model, "SerpentHead"), 0)
	Check.eq(countName(model, "ProwHead") >= 1, true)
	Check.eq(countName(model, "DoorAnchor"), 1)
	Check.eq(countName(model, "HallPost") >= 8, true)
	Check.eq(countName(model, "HullRib") >= 6, true)
	Check.eq(countName(model, "BowStrake") >= 4, true)
	local door = nil
	local prompt = nil
	local spawn = nil
	local text = nil
	for _, inst in model:GetDescendants() do
		if inst.Name == "DoorAnchor" then
			door = inst
		elseif inst.ClassName == "ProximityPrompt" then
			prompt = inst
		elseif inst.ClassName == "SpawnLocation" then
			spawn = inst
		elseif inst.Name == "SignText" then
			text = inst.Text
		end
	end
	Check.eq(text, "The Howling Horn")
	Check.eq(model.PrimaryPart.Name, "Root")
	Check.eq(prompt.Parent, door)
	Check.eq(prompt.ActionText, "Enter the hall")
	Check.eq(prompt:GetAttribute("Kind"), "Tavern")
	Check.eq(spawn.Name, "TavernApproach")
	Check.eq(spawn.Parent, model)
	Check.eq(door:GetAttribute("TownAnchor"), "Door")
	Check.eq(door.CFrame.Position.Z < -8, true, tostring(door.CFrame.Position.Z))
	local headZ = nil
	local headY = nil
	for _, inst in model:GetDescendants() do
		if inst.Name == "ProwHead" then
			headY = inst.CFrame.Position.Y
			headZ = inst.CFrame.Position.Z
		end
	end
	Check.eq(headY > 16, true, tostring(headY))
	Check.eq(headZ < -12, true, tostring(headZ))
end

Check.test("longship quality tiers drop ornament and keep the hull", function()
	Check.eq(Kit.detailEnabled(1), false)
	Check.eq(Kit.detailEnabled(TownLook.LOW_QUALITY_MAX), false)
	Check.eq(Kit.detailEnabled(5), true)
	Check.eq(Kit.detailEnabled(10), true)
	Check.eq(Kit.detailEnabled(0), true)
	Check.eq(Kit.resolveQuality(nil), 10)
	Check.eq(Kit.resolveQuality({}), 10)
	Check.eq(Kit.resolveQuality({ qualityLevel = 1 }), 1)

	Kit.clearGeometryCache()
	local lowTown = buildOldTavern()
	local low = Longship.replace(lowTown, { qualityLevel = 1 })
	local lowModel = lowTown:FindFirstChild("HowlingHorn")
	assertKit(lowModel)
	Check.eq(low.detail, false)
	Check.eq(low.beforeLights, 0)
	Check.eq(low.afterLights, 0)
	Check.eq(low.beforeEmitters, low.afterEmitters)
	Check.eq(countName(lowModel, "Shield"), 0)
	Check.eq(countName(lowModel, "Strake"), 0)
	Check.eq(countName(lowModel, "Rune"), 0)
	Check.eq(countName(lowModel, "Tooth"), 0)
	Check.eq(countName(lowModel, "Shell") + countName(lowModel, "Hull") >= 1, true)
	local again = Longship.replace(lowTown, { qualityLevel = 10 })
	Check.eq(again, nil)
	Check.eq(countName(lowModel, "ProwHead"), 1)

	local highTown = buildOldTavern()
	local high = TownKits.applyAll(highTown, { qualityLevel = 10 })
	local highModel = highTown:FindFirstChild("HowlingHorn")
	assertKit(highModel)
	Check.eq(#high, 1)
	Check.eq(high[1].detail, true)
	Check.eq(high[1].afterLights, 0)
	Check.eq(countName(highModel, "Shield") >= 8, true)
	Check.eq(countName(highModel, "Strake") > 0, true)
	Check.eq(countName(highModel, "Rune") >= 4, true)
	Check.eq(countName(highModel, "Tooth") >= 5, true)
	Check.eq(
		high[1].afterParts > low.afterParts,
		true,
		tostring(high[1].afterParts) .. " vs " .. tostring(low.afterParts)
	)
	print(
		string.format(
			"longship q1 parts=%d lights=%d q10 parts=%d lights=%d before=%d",
			low.afterParts,
			low.afterLights,
			high[1].afterParts,
			high[1].afterLights,
			low.beforeParts
		)
	)
end)

Check.test("longship hull union is one cached call with a part fallback", function()
	Kit.clearGeometryCache()
	local calls = 0
	local seenOptions = nil
	local geo = roblox.game:GetService("GeometryService")
	function geo:UnionAsync(base, others, options)
		calls += 1
		seenOptions = options
		Check.eq(base.ClassName, "Part")
		Check.eq(base.Name, "Shell")
		Check.eq(#others, 3)
		Check.eq(others[1].ClassName ~= "UnionOperation", true)
		local union = roblox.Instance.new("UnionOperation")
		union.Name = "Pending"
		union.Size = base.Size
		union.CFrame = base.CFrame
		union.Material = base.Material
		union.Color = base.Color
		union.Anchored = true
		return union
	end

	local firstTown = buildOldTavern()
	Longship.replace(firstTown, { qualityLevel = 1 })
	local secondTown = buildOldTavern()
	Longship.replace(secondTown, { qualityLevel = 10 })
	Check.eq(calls, 1)
	Check.eq(seenOptions.SplitApart, false)
	Check.eq(seenOptions.CollisionFidelity.Name, "Hull")
	Check.eq(seenOptions.RenderFidelity.Name, "Automatic")
	for _, town in { firstTown, secondTown } do
		local model = town:FindFirstChild("HowlingHorn")
		Check.eq(countName(model, "Hull"), 1)
		Check.eq(countName(model, "Shell"), 0)
		Check.eq(countName(model, "TownKitOperands"), 0)
		local hull = nil
		for _, inst in model:GetDescendants() do
			if inst.Name == "Hull" then
				hull = inst
			end
		end
		Check.eq(hull.ClassName, "UnionOperation")
		Check.eq(hull.Anchored, true)
		Check.eq(hull.CanCollide, true)
		Check.eq(hull:GetAttribute("TownKitPart"), true)
		Check.eq(hull:GetAttribute("TownDecor"), nil)
	end
end)

Check.test("town kits do no per-frame work", function()
	local source = fs.readFile("src/server/TownKits/Kit.luau")
		.. fs.readFile("src/server/TownKits/Longship.luau")
		.. fs.readFile("src/server/TownKits/init.luau")
	for _, needle in { "Heartbeat", "RenderStepped", "Stepped", ":Connect", "task.wait", "task.spawn", "task.defer" } do
		Check.eq(string.find(source, needle, 1, true), nil, needle)
	end
end)
