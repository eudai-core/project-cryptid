--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Kit = import("./Kit", function()
	return script.Parent:WaitForChild("Kit")
end)
local Town = import("../../shared/Config/Town", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Town")
end) :: any
local UITheme = import("../../shared/UITheme", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("UITheme")
end) :: any

local Lanternwright = {}

local MODEL_NAME = "Lanternwright"
local WOOD = UITheme.materials.wood
local STONE = UITheme.materials.altar
local METAL = UITheme.materials.iron
local GLASS = UITheme.materials.glass
local NEON = UITheme.materials.neon
local BRICK = "Brick"
local SHINGLE = "RoofShingles"

-- Preview ne() stores z = -r cos(a), so preview angle 148 is Roblox heading
-- 180 - 148 = 32. Heading 32 lies on the 45 degree road. Angle 25 at the shop
-- ring (radius 44) is the nearest seat that still clears that road, the
-- brazier at 20/32, the lamp ring, the offset well, and the Pale Pedlar stall.
local SLOT_ANGLE = 25
local SLOT_RADIUS = 44

local GLOW = {
	{ token = "Candle", sickly = false },
	{ token = "FlameOrange", sickly = false },
	{ token = "Gold", sickly = false },
	{ token = "Bone", sickly = false },
	{ token = "Moss", sickly = true },
	{ token = "Rift", sickly = true },
}

local function place(parent: Instance, pivot: any, spec: any): any
	spec.cf = pivot * spec.cf
	spec.parent = parent
	return Kit.spawn(spec)
end

local function upright(at: any): any
	return CFrame.new(at) * CFrame.Angles(0, 0, math.rad(90))
end

local function sway(index: number, amount: number): number
	return math.sin(index * 1.7) * amount
end

local function addPoint(parent: Instance, name: string, range: number, brightness: number, token: string)
	local light = Instance.new("PointLight")
	light.Name = name
	light.Color = UITheme.color(token)
	light.Range = range
	light.Brightness = brightness
	light.Shadows = false
	light.Parent = parent
end

local function addSpot(parent: Instance, name: string, range: number, brightness: number, angle: number, token: string)
	local light = Instance.new("SpotLight")
	light.Name = name
	light.Color = UITheme.color(token)
	light.Range = range
	light.Brightness = brightness
	light.Angle = angle
	light.Shadows = false
	light.Face = Enum.NormalId.Front
	light.Parent = parent
end

local function addLife(
	parent: Instance,
	name: string,
	rate: number,
	life: number,
	size: number,
	token: string,
	lift: number
)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = name
	emitter.Rate = rate
	emitter.Lifetime = NumberRange.new(life, life)
	emitter.Speed = NumberRange.new(0.25, 0.7)
	emitter.SpreadAngle = Vector2.new(18, 18)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-14, 14)
	emitter.Acceleration = Vector3.new(0, lift, 0)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.LightInfluence = 0
	emitter.Color = ColorSequence.new(UITheme.color(token))
	emitter.Size = NumberSequence.new(size)
	emitter.Transparency = NumberSequence.new(0.35)
	emitter.Enabled = true
	emitter:SetAttribute("TownEffect", "LanternwrightLife")
	emitter:SetAttribute("TownFlame", "extra")
	emitter.Parent = parent
end

-- Same contract as the kit helper another agent is adding: no work under Lune,
-- Heartbeat when the server has it, otherwise a TweenService clock, and the
-- connection drops when the model is destroyed.
local function animate(model: any, step: (number, number) -> ())
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return
	end
	local connection: any = nil
	local function stop()
		if connection ~= nil and type(connection.Disconnect) == "function" then
			pcall(function()
				connection:Disconnect()
			end)
		end
		connection = nil
	end
	local function watch()
		local destroying = if model ~= nil then model.Destroying else nil
		if destroying == nil or type(destroying.Connect) ~= "function" then
			return
		end
		pcall(function()
			destroying:Connect(function()
				stop()
			end)
		end)
	end
	local bound = pcall(function()
		local runService = game:GetService("RunService")
		connection = runService.Heartbeat:Connect(function(dt)
			step(if type(dt) == "number" then dt else 0, os.clock())
		end)
	end)
	if bound and connection ~= nil then
		watch()
		return
	end
	pcall(function()
		local tweens = game:GetService("TweenService")
		if tweens == nil or type(tweens.Create) ~= "function" then
			return
		end
		local clock = Instance.new("NumberValue")
		clock.Name = "SwingClock"
		clock.Value = 0
		clock.Parent = model
		local info = TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tween = tweens:Create(clock, info, { Value = 1 })
		connection = clock:GetPropertyChangedSignal("Value"):Connect(function()
			step(0, clock.Value)
		end)
		tween:Play()
		watch()
	end)
end

local function buildBase(parent: Instance, pivot: any, detail: boolean)
	local stones = if detail then 9 else 5
	for index = 1, stones do
		local x = -3.1 + (index - 0.5) * (6.2 / stones) + sway(index, 0.05)
		place(parent, pivot, {
			name = "Foundation",
			size = Vector3.new(6.2 / stones + 0.08, 0.42, 0.55),
			cf = CFrame.new(x, 0.22, 3.55) * CFrame.Angles(0, sway(index, 0.04), sway(index + 2, 0.03)),
			material = BRICK,
			color = if index % 2 == 0 then "Soot" else "Wall",
		})
		place(parent, pivot, {
			name = "Foundation",
			size = Vector3.new(0.48, 0.38, 1.15),
			cf = CFrame.new(-3.15, 0.2, -3.2 + index * 0.7) * CFrame.Angles(0, 0, sway(index, 0.04)),
			material = BRICK,
			color = "Ash",
		})
		place(parent, pivot, {
			name = "Foundation",
			size = Vector3.new(0.48, 0.38, 1.15),
			cf = CFrame.new(3.15, 0.2, -3.2 + index * 0.7) * CFrame.Angles(0, 0, sway(index, -0.04)),
			material = BRICK,
			color = if index % 3 == 0 then "Bark" else "Soot",
		})
	end
	local planks = if detail then 6 else 4
	for index = 1, planks do
		local z = -2.6 + (index - 0.5) * (5.2 / planks)
		place(parent, pivot, {
			name = "FloorPlank",
			size = Vector3.new(5.6, 0.12, 5.2 / planks - 0.04),
			cf = CFrame.new(sway(index, 0.04), 0.16, z),
			material = WOOD,
			color = if index % 2 == 0 then "Bark" else "ShipWood",
		})
	end
end

local function buildFrame(parent: Instance, pivot: any)
	local posts = {
		Vector3.new(-3.05, 2.7, -3.7),
		Vector3.new(3.05, 2.7, -3.7),
		Vector3.new(-3.15, 2.85, 3.45),
		Vector3.new(3.2, 2.7, 3.4),
	}
	for index, at in posts do
		local lean = if index % 2 == 0 then 2.4 else -2.1
		place(parent, pivot, {
			name = "Post",
			size = Vector3.new(0.28, 5.4, 0.28),
			cf = CFrame.new(at) * CFrame.Angles(0, 0, math.rad(lean)),
			material = WOOD,
			color = "Bark",
		})
	end
	place(parent, pivot, {
		name = "Lintel",
		size = Vector3.new(6.3, 0.22, 0.22),
		cf = CFrame.new(0.05, 5.15, -3.65) * CFrame.Angles(0, 0, math.rad(-1.6)),
		material = WOOD,
		color = "ShipWood",
	})
	place(parent, pivot, {
		name = "Plate",
		size = Vector3.new(6.4, 0.2, 0.2),
		cf = CFrame.new(0.12, 5.35, 3.5) * CFrame.Angles(0, 0, math.rad(2.2)),
		material = WOOD,
		color = "Bark",
	})
	for _, x in { -3.1, 3.1 } do
		place(parent, pivot, {
			name = "Brace",
			size = Vector3.new(0.14, 2.4, 0.14),
			cf = CFrame.new(x * 0.72, 3.6, -3.55) * CFrame.Angles(0, 0, math.rad(if x < 0 then 38 else -36)),
			material = WOOD,
			color = "Bark",
			decor = true,
		})
	end
	place(parent, pivot, {
		name = "Sill",
		size = Vector3.new(1.7, 0.16, 0.7),
		cf = CFrame.new(0, 1.05, -3.15),
		material = WOOD,
		color = "ShipWood",
	})
end

local function panelField(
	parent: Instance,
	pivot: any,
	origin: any,
	axis: string,
	cols: number,
	rows: number,
	span: number,
	rise: number,
	roll: number
)
	for row = 1, rows do
		for col = 1, cols do
			local along = -span / 2 + (col - 0.5) * (span / cols) + sway(row * 5 + col, 0.06)
			local y = origin.Y + (row - 0.5) * (rise / rows) + sway(col, 0.03)
			local shift = if row % 2 == 0 then 0.08 else -0.05
			local cf
			local size
			if axis == "x" then
				size = Vector3.new(span / cols + 0.04, rise / rows - 0.06, 0.16)
				cf = CFrame.new(origin.X + along + shift, y, origin.Z) * CFrame.Angles(0, 0, math.rad(roll))
			else
				size = Vector3.new(0.16, rise / rows - 0.06, span / cols + 0.04)
				cf = CFrame.new(origin.X, y, origin.Z + along + shift) * CFrame.Angles(0, 0, math.rad(roll))
			end
			local token = "Soot"
			if (row + col) % 4 == 0 then
				token = "Wall"
			elseif (row + col) % 5 == 0 then
				token = "Bark"
			end
			place(parent, pivot, {
				name = "Brick",
				size = size,
				cf = cf,
				material = BRICK,
				color = token,
			})
		end
	end
end

local function buildWalls(parent: Instance, pivot: any, detail: boolean)
	local cols = if detail then 14 else 8
	local rows = if detail then 11 else 6
	panelField(parent, pivot, Vector3.new(-3.2, 1.35, 0.1), "z", cols, rows, 6.2, 3.6, -2.4)
	panelField(parent, pivot, Vector3.new(3.25, 1.4, -0.05), "z", cols, rows, 6.2, 3.5, 2.8)
	panelField(parent, pivot, Vector3.new(0.08, 1.45, 3.55), "x", cols, rows, 5.6, 3.4, 1.5)
	if detail then
		panelField(parent, pivot, Vector3.new(-3.05, 4.35, 0.2), "z", 5, 2, 5.4, 1.5, -3.2)
		panelField(parent, pivot, Vector3.new(3.15, 4.3, 0.15), "z", 5, 2, 5.4, 1.45, 3.4)
		for row = 1, 6 do
			for col = 1, 8 do
				place(parent, pivot, {
					name = "Filigree",
					size = Vector3.new(0.7, 0.05, 0.05),
					cf = CFrame.new(-3.02, 1.6 + row * 0.55, -2.6 + col * 0.62)
						* CFrame.Angles(0, math.rad(90), math.rad(if (row + col) % 2 == 0 then 28 else -28)),
					material = METAL,
					color = "Gold",
					decor = true,
					shadow = false,
					shape = Enum.PartType.Cylinder,
				})
			end
		end
	end
	for _, side in { -1, 1 } do
		place(parent, pivot, {
			name = "WindowFrame",
			size = Vector3.new(0.12, 1.15, 0.85),
			cf = CFrame.new(side * 3.28, 2.7, -1.4),
			material = WOOD,
			color = "Bark",
		})
		local pane = place(parent, pivot, {
			name = "Window",
			size = Vector3.new(0.06, 0.85, 0.58),
			cf = CFrame.new(side * 3.34, 2.72, -1.4),
			material = GLASS,
			color = "Candle",
			decor = true,
			shadow = false,
		})
		pane.Transparency = 0.35
	end
	place(parent, pivot, {
		name = "DoorPlank",
		size = Vector3.new(0.34, 2.15, 0.1),
		cf = CFrame.new(-0.42, 1.35, -3.05) * CFrame.Angles(0, math.rad(18), 0),
		material = WOOD,
		color = "ShipWood",
	})
	place(parent, pivot, {
		name = "DoorPlank",
		size = Vector3.new(0.34, 2.05, 0.1),
		cf = CFrame.new(0.28, 1.28, -2.95) * CFrame.Angles(0, math.rad(-14), math.rad(2)),
		material = WOOD,
		color = "Bark",
	})
end

local function buildRoof(parent: Instance, pivot: any, detail: boolean)
	local courses = if detail then 18 else 8
	local across = if detail then 20 else 10
	for course = 1, courses do
		local t = (course - 0.5) / courses
		local zFront = -3.3 + t * 3.1
		local zBack = 3.5 - t * 3.1
		local y = 5.55 + t * 1.35
		for index = 1, across do
			local x = -3.05 + (index - 0.5) * (6.1 / across) + sway(course * 3 + index, 0.05)
			local token = if (course + index) % 3 == 0 then "Ash" else "Wall"
			place(parent, pivot, {
				className = "WedgePart",
				name = "Shingle",
				size = Vector3.new(6.1 / across + 0.08, 0.18, 0.62),
				cf = CFrame.new(x, y, zFront) * CFrame.Angles(math.rad(-28), 0, math.rad(sway(index, 3))),
				material = SHINGLE,
				color = token,
				decor = true,
			})
			place(parent, pivot, {
				className = "WedgePart",
				name = "Shingle",
				size = Vector3.new(6.1 / across + 0.08, 0.18, 0.62),
				cf = CFrame.new(x, y + 0.04, zBack)
					* CFrame.Angles(math.rad(28), math.rad(180), math.rad(sway(index, -3))),
				material = SHINGLE,
				color = if index % 2 == 0 then "Soot" else token,
				decor = true,
			})
		end
	end
	place(parent, pivot, {
		name = "Ridge",
		size = Vector3.new(6.4, 0.16, 0.22),
		cf = CFrame.new(0.08, 7.05, 0.15) * CFrame.Angles(0, 0, math.rad(-1.4)),
		material = METAL,
		color = "Gold",
		decor = true,
	})
	for _, z in { -3.45, 3.55 } do
		place(parent, pivot, {
			name = "Eave",
			size = Vector3.new(6.5, 0.1, 0.16),
			cf = CFrame.new(0, 5.25, z),
			material = WOOD,
			color = "Bark",
			decor = true,
		})
	end
	if detail then
		for index = 1, 10 do
			place(parent, pivot, {
				name = "Barge",
				size = Vector3.new(0.08, 0.14, 0.55),
				cf = CFrame.new(-3.35, 5.5 + index * 0.14, -3.2 + index * 0.32),
				material = WOOD,
				color = "Blood",
				decor = true,
				shadow = false,
			})
		end
	end
end

local function buildChimney(parent: Instance, pivot: any, detail: boolean): any
	local courses = if detail then 7 else 4
	for index = 1, courses do
		local y = 5.3 + index * 0.32
		place(parent, pivot, {
			name = "Chimney",
			size = Vector3.new(0.85 + sway(index, 0.06), 0.3, 0.7),
			cf = CFrame.new(1.85 + sway(index, 0.04), y, 2.55) * CFrame.Angles(0, sway(index, 0.08), sway(index, 0.05)),
			material = BRICK,
			color = if index % 2 == 0 then "Soot" else "Bark",
		})
	end
	local cap = place(parent, pivot, {
		name = "ChimneyCap",
		size = Vector3.new(1.05, 0.12, 0.9),
		cf = CFrame.new(1.88, 5.4 + courses * 0.32, 2.55),
		material = STONE,
		color = "Ash",
	})
	if detail then
		addLife(cap, "ChimneySmoke", 5, 2.2, 0.42, "BoneDim", 0.85)
	end
	return cap
end

local function hangingLantern(parent: Instance, pivot: any, at: any, token: string, lit: boolean)
	place(parent, pivot, {
		name = "LanternHook",
		size = Vector3.new(0.55, 0.06, 0.06),
		cf = upright(at + Vector3.new(0, 0.35, 0)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	local globe = place(parent, pivot, {
		name = "LanternGlobe",
		size = Vector3.new(0.42, 0.55, 0.42),
		cf = CFrame.new(at),
		material = GLASS,
		color = token,
		decor = true,
		shadow = false,
	})
	globe.Transparency = 0.2
	place(parent, pivot, {
		name = "LanternCap",
		size = Vector3.new(0.36, 0.1, 0.36),
		cf = CFrame.new(at + Vector3.new(0, 0.32, 0)),
		material = METAL,
		color = "Soot",
		decor = true,
		shadow = false,
	})
	place(parent, pivot, {
		name = "LanternLip",
		size = Vector3.new(0.08, 0.4, 0.4),
		cf = CFrame.new(at + Vector3.new(0, -0.28, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	if lit then
		addPoint(globe, "LanternGlow", 9, 0.45, token)
	end
end

local function buildLanterns(parent: Instance, pivot: any, detail: boolean)
	local frontCount = if detail then 12 else 8
	for index = 1, frontCount do
		local x = -3.05 + (index - 0.5) * (6.1 / frontCount)
		local y = 4.15 + math.sin(index * 1.4) * 0.16
		hangingLantern(parent, pivot, Vector3.new(x, y, -3.88), "Candle", index % 3 == 1)
	end
	if not detail then
		return
	end
	for index = 1, 8 do
		local x = -2.6 + (index - 0.5) * (5.2 / 8)
		hangingLantern(parent, pivot, Vector3.new(x, 4.85 + sway(index, 0.08), -3.15), "Candle", false)
	end
	for index = 1, 5 do
		place(parent, pivot, {
			name = "Tool",
			size = Vector3.new(0.12, 0.55, 0.08),
			cf = CFrame.new(-2.85, 2.4 + index * 0.35, 1.2) * CFrame.Angles(0, math.rad(90), math.rad(sway(index, 12))),
			material = METAL,
			color = if index == 3 then "Gold" else "BoneDim",
			decor = true,
			shadow = false,
		})
	end
	place(parent, pivot, {
		name = "Compass",
		size = Vector3.new(0.08, 0.55, 0.55),
		cf = CFrame.new(2.9, 2.8, 0.6) * CFrame.Angles(0, math.rad(90), 0),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
end

local function buildSign(model: any, parent: Instance, pivot: any)
	local hingeLocal = CFrame.new(0, 6.35, -4.15)
	local board = place(parent, pivot, {
		name = "Sign",
		size = Vector3.new(2.7, 1.15, 0.12),
		cf = CFrame.new(0, 5.55, -4.2),
		material = WOOD,
		color = "Ash",
		decor = true,
	})
	local trim = place(parent, pivot, {
		name = "SignTrim",
		size = Vector3.new(2.95, 1.35, 0.06),
		cf = CFrame.new(0, 5.55, -4.05),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
	})
	local glyph = place(parent, pivot, {
		name = "SignGlyph",
		size = Vector3.new(0.42, 0.55, 0.08),
		cf = CFrame.new(-1.85, 5.55, -4.2),
		material = NEON,
		color = "Candle",
		decor = true,
		shadow = false,
		neonRole = "sign",
	})
	local cap = place(parent, pivot, {
		className = "WedgePart",
		name = "SignCap",
		size = Vector3.new(0.5, 0.22, 0.16),
		cf = CFrame.new(-1.85, 5.95, -4.2),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
	})
	place(parent, pivot, {
		name = "SignChain",
		size = Vector3.new(0.7, 0.05, 0.05),
		cf = upright(Vector3.new(-0.9, 6.15, -4.15)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	place(parent, pivot, {
		name = "SignChain",
		size = Vector3.new(0.7, 0.05, 0.05),
		cf = upright(Vector3.new(0.9, 6.15, -4.15)),
		material = METAL,
		color = "Gold",
		decor = true,
		shadow = false,
		shape = Enum.PartType.Cylinder,
	})
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Name = "SignText"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Text = "The Lanternwright"
	label.TextColor3 = UITheme.color("Bone")
	label.TextScaled = false
	label.TextSize = 28
	label.Parent = gui
	addSpot(board, "SignSpot", 16, 0.7, 46, "Candle")
	local swung = { board, trim, glyph, cap }
	local hinge = pivot * hingeLocal
	local rest = {}
	for _, part in swung do
		rest[part] = hinge:Inverse() * part.CFrame
	end
	animate(model, function(_dt: number, t: number)
		local spun = hinge * CFrame.Angles(math.sin(t * 0.85) * 0.07, 0, 0)
		for part, localCf in rest do
			if part.Parent ~= nil then
				part.CFrame = spun * localCf
			end
		end
	end)
end

local function buildCounter(parent: Instance, pivot: any, detail: boolean)
	place(parent, pivot, {
		name = "Counter",
		size = Vector3.new(3.4, 1.05, 0.85),
		cf = CFrame.new(0.05, 0.85, -2.55) * CFrame.Angles(0, math.rad(-2), 0),
		material = WOOD,
		color = "ShipWood",
	})
	place(parent, pivot, {
		name = "CounterTrim",
		size = Vector3.new(3.55, 0.08, 0.12),
		cf = CFrame.new(0.05, 1.4, -2.95),
		material = METAL,
		color = "Gold",
		decor = true,
	})
	place(parent, pivot, {
		name = "Anvil",
		size = Vector3.new(0.7, 0.28, 0.38),
		cf = CFrame.new(2.15, 1.15, -1.7),
		material = METAL,
		color = "Soot",
	})
	place(parent, pivot, {
		name = "AnvilHorn",
		size = Vector3.new(0.42, 0.12, 0.16),
		cf = CFrame.new(2.5, 1.22, -1.7),
		material = METAL,
		color = "Ash",
		decor = true,
	})
	local flame = place(parent, pivot, {
		name = "ForgeFlame",
		size = Vector3.new(0.38, 0.55, 0.38),
		cf = CFrame.new(2.15, 1.55, -1.35),
		material = NEON,
		color = "FlameOrange",
		decor = true,
		shadow = false,
		neonRole = "flame",
		shape = Enum.PartType.Ball,
	})
	flame.Transparency = 0.15
	addPoint(flame, "ForgeGlow", 8, 0.4, "FlameOrange")
	if detail then
		addLife(flame, "ForgeMotes", 3, 2.4, 0.12, "Gold", 0.4)
		for index = 1, 4 do
			place(parent, pivot, {
				name = "ShelfJar",
				size = Vector3.new(0.38, 0.22, 0.22),
				cf = upright(Vector3.new(-2.2 + index * 0.35, 1.55, 1.8)),
				material = GLASS,
				color = if index == 2 then "Moss" else "Bone",
				decor = true,
				shadow = false,
				shape = Enum.PartType.Cylinder,
			})
		end
	end
	local windowHost = place(parent, pivot, {
		name = "WindowWick",
		size = Vector3.new(0.2, 0.2, 0.2),
		cf = CFrame.new(0, 2.7, -1.2),
		material = GLASS,
		color = "Candle",
		decor = true,
		shadow = false,
	})
	windowHost.Transparency = 1
	if detail then
		addPoint(windowHost, "WindowGlow", 11, 0.55, "Candle")
	end
end

local function retireShutteredStall(townFolder: Instance)
	local districts = townFolder:FindFirstChild("Districts")
	if districts == nil then
		return
	end
	local stall = districts:FindFirstChild(MODEL_NAME)
	if stall ~= nil then
		stall:Destroy()
	end
end

function Lanternwright.replace(townFolder: Instance, refs: any): any
	retireShutteredStall(townFolder)
	local hollow = townFolder:FindFirstChild("Hollowmere")
	if hollow == nil or hollow:FindFirstChild(MODEL_NAME) ~= nil then
		return nil
	end
	local level = Kit.resolveQuality(refs)
	local detail = Kit.detailEnabled(level)
	local model = Instance.new("Model")
	model.Name = MODEL_NAME
	local root = Kit.spawn({
		name = "Root",
		size = Vector3.new(1, 1, 1),
		cf = CFrame.new(),
		material = WOOD,
		color = "Void",
		decor = true,
		shadow = false,
		parent = model,
	})
	root.Transparency = 1
	model.PrimaryPart = root
	model.Parent = hollow
	local theta = math.rad(SLOT_ANGLE)
	local y = Town.FLOOR_Y
	local cf = CFrame.lookAt(
		Vector3.new(SLOT_RADIUS * math.sin(theta), y, SLOT_RADIUS * math.cos(theta)),
		Vector3.new(0, y, 0)
	)
	if type(model.PivotTo) == "function" then
		model:PivotTo(cf)
	else
		root.CFrame = cf
	end
	local pivot = root.CFrame
	local beforeParts = Kit.countParts(model)
	local beforeLights = Kit.countLights(model)
	local beforeEmitters = Kit.countEmitters(model)

	local folder = Instance.new("Folder")
	folder.Name = "Workshop"
	folder.Parent = model
	buildBase(folder, pivot, detail)
	buildFrame(folder, pivot)
	buildWalls(folder, pivot, detail)
	buildRoof(folder, pivot, detail)
	buildChimney(folder, pivot, detail)
	buildLanterns(folder, pivot, detail)
	buildSign(model, folder, pivot)
	if detail then
		for row = 1, 8 do
			for col = 1, 14 do
				place(folder, pivot, {
					name = "Nogging",
					size = Vector3.new(0.28, 0.16, 0.1),
					cf = CFrame.new(-2.4 + col * 0.32, 0.55 + row * 0.42, 3.42)
						* CFrame.Angles(0, sway(row + col, 0.08), 0),
					material = BRICK,
					color = if (row + col) % 3 == 0 then "Bark" else "Soot",
					decor = true,
				})
			end
		end
		for index = 1, 48 do
			local x = -2.8 + (index % 12) * 0.48
			local z = -1.6 + math.floor((index - 1) / 12) * 0.7
			place(folder, pivot, {
				name = "Bottle",
				size = Vector3.new(0.28, 0.14, 0.14),
				cf = upright(Vector3.new(x, 1.7 + (index % 3) * 0.08, z)),
				material = GLASS,
				color = GLOW[(index % #GLOW) + 1].token,
				decor = true,
				shadow = false,
				shape = Enum.PartType.Cylinder,
			})
		end
	end
	buildCounter(folder, pivot, detail)
	Kit.promptAnchor(model, CFrame.new(0, 2.2, -4.15))

	local afterParts = Kit.countParts(model)
	local afterLights = Kit.countLights(model)
	local afterEmitters = Kit.countEmitters(model)
	model:SetAttribute("TownKit", "Lanternwright")
	model:SetAttribute("KitQuality", level)
	model:SetAttribute("KitDetail", detail)
	model:SetAttribute("KitSlotAngle", SLOT_ANGLE)
	model:SetAttribute("KitSlotRadius", SLOT_RADIUS)
	model:SetAttribute("KitBeforeParts", beforeParts)
	model:SetAttribute("KitAfterParts", afterParts)
	model:SetAttribute("KitBeforeLights", beforeLights)
	model:SetAttribute("KitAfterLights", afterLights)
	model:SetAttribute("KitBeforeEmitters", beforeEmitters)
	model:SetAttribute("KitAfterEmitters", afterEmitters)
	return {
		id = MODEL_NAME,
		quality = level,
		detail = detail,
		beforeParts = beforeParts,
		afterParts = afterParts,
		beforeLights = beforeLights,
		afterLights = afterLights,
		beforeEmitters = beforeEmitters,
		afterEmitters = afterEmitters,
	}
end

return Lanternwright
