--!strict

-- Hides client overlays when the server attribute QaNoHud is true.
-- The server sets that attribute only in Studio, and only for `nohud`.
-- This module does not touch onboarding, rewards, or timers.

local Players = game:GetService("Players")

local QaShots = {}

local ATTRIBUTE = "QaNoHud"

function QaShots.hidden(): boolean
	local player = Players.LocalPlayer
	if player == nil then
		return false
	end
	return player:GetAttribute(ATTRIBUTE) == true
end

local function watch(apply: () -> (), signal: RBXScriptSignal, shown: () -> boolean)
	apply()
	signal:Connect(function()
		if shown() then
			apply()
		end
	end)
	local player = Players.LocalPlayer
	if player ~= nil then
		player:GetAttributeChangedSignal(ATTRIBUTE):Connect(apply)
	end
end

function QaShots.conceal(gui: GuiObject)
	watch(
		function()
			if QaShots.hidden() then
				gui.Visible = false
			end
		end,
		gui:GetPropertyChangedSignal("Visible"),
		function()
			return gui.Visible
		end
	)
end

function QaShots.concealEnabled(layer: LayerCollector)
	watch(
		function()
			if QaShots.hidden() then
				layer.Enabled = false
			end
		end,
		layer:GetPropertyChangedSignal("Enabled"),
		function()
			return layer.Enabled
		end
	)
end

return QaShots
