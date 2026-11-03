--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlotAssign = require(Shared:WaitForChild("Logic"):WaitForChild("PlotAssign")) :: any

local event = script:FindFirstChild("PlotIntruded")
if event == nil or not event:IsA("BindableEvent") then
	event = Instance.new("BindableEvent")
	event.Name = "PlotIntruded"
	event.Parent = script
end

local PlotSignals = {}

function PlotSignals.fire(plotIndex: number, intruder: Player)
	local record = PlotAssign.intrusion(plotIndex, intruder.UserId)
	print(string.format("%s %d %d", record.name, record.plotIndex, record.userId))(event :: BindableEvent):Fire(
		plotIndex,
		intruder
	)
end

return PlotSignals
