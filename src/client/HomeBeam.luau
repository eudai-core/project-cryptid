--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Plots = require(Shared:WaitForChild("Config"):WaitForChild("Plots")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local HomeBeam = {}

function HomeBeam.start(player: Player)
	local plots = workspace:WaitForChild("Plots")
	local beam: Beam? = nil
	local from: Attachment? = nil
	local to: Attachment? = nil

	local function clear()
		if beam ~= nil then
			beam:Destroy()
			beam = nil
		end
		if from ~= nil then
			from:Destroy()
			from = nil
		end
		if to ~= nil then
			to:Destroy()
			to = nil
		end
	end

	local function draw()
		clear()
		local index = player:GetAttribute("PlotIndex")
		if type(index) ~= "number" then
			return
		end
		local model = plots:FindFirstChild("Plot" .. tostring(index))
		if model == nil then
			return
		end
		local gate = model:FindFirstChild("LairGate")
		if gate == nil or not gate:IsA("BasePart") then
			return
		end
		local bottom = Instance.new("Attachment")
		bottom.Name = "HomeBeamFrom"
		bottom.Position = Vector3.new(0, Plots.BANNER_LIFT, 0)
		bottom.Parent = gate
		local top = Instance.new("Attachment")
		top.Name = "HomeBeamTo"
		top.Position = Vector3.new(0, Plots.BANNER_LIFT + Plots.HOME_BEAM_HEIGHT, 0)
		top.Parent = gate
		local link = Instance.new("Beam")
		link.Name = "HomeBeam"
		link.Attachment0 = bottom
		link.Attachment1 = top
		link.Width0 = UITheme.shape.beamWidth
		link.Width1 = UITheme.shape.beamWidth
		link.Color = ColorSequence.new(UITheme.color("Gold"))
		link.FaceCamera = true
		link.LightEmission = 0.2
		link.LightInfluence = 0
		link.Transparency = NumberSequence.new(0.2)
		link.Parent = gate
		from = bottom
		to = top
		beam = link
	end

	player:GetAttributeChangedSignal("PlotIndex"):Connect(draw)
	plots.ChildAdded:Connect(function()
		draw()
	end)
	draw()
end

return HomeBeam
