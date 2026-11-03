--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local GuideArrow = {}

function GuideArrow.start(player: Player)
	local guide = player:WaitForChild("GuideTarget") :: ObjectValue
	local attachment0: Attachment? = nil
	local attachment1: Attachment? = nil
	local beam: Beam? = nil

	local function clear()
		if beam ~= nil then
			beam:Destroy()
			beam = nil
		end
		if attachment0 ~= nil then
			attachment0:Destroy()
			attachment0 = nil
		end
		if attachment1 ~= nil then
			attachment1:Destroy()
			attachment1 = nil
		end
	end

	local function draw()
		clear()
		local target = guide.Value
		local character = player.Character
		local root = if character ~= nil then character:FindFirstChild("HumanoidRootPart") else nil
		if target == nil or not target:IsA("BasePart") or root == nil or not root:IsA("BasePart") then
			return
		end
		local from = Instance.new("Attachment")
		from.Name = "GuideFrom"
		from.Parent = root
		local to = Instance.new("Attachment")
		to.Name = "GuideTo"
		to.Parent = target
		local link = Instance.new("Beam")
		link.Name = "GuideBeam"
		link.Attachment0 = from
		link.Attachment1 = to
		link.Width0 = UITheme.shape.beamWidth
		link.Width1 = UITheme.shape.beamWidth
		link.Color = ColorSequence.new(UITheme.color("Gold"))
		link.FaceCamera = true
		link.LightEmission = 0.15
		link.LightInfluence = 0
		link.Transparency = NumberSequence.new(0.15)
		link.Parent = root
		attachment0 = from
		attachment1 = to
		beam = link
	end

	guide.Changed:Connect(draw)
	player.CharacterAdded:Connect(function()
		task.defer(draw)
	end)
	draw()
end

return GuideArrow
