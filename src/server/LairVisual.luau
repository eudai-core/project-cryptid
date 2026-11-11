--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local CryptidArt = import("../shared/Config/CryptidArt", function()
	return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("CryptidArt")
end) :: any

local LairVisual = {}

function LairVisual.faceGate(cf: CFrame): CFrame
	return cf * CFrame.Angles(0, CryptidArt.faceGateYaw, 0)
end

function LairVisual.preparePad(model: Model, cf: CFrame): ({ [string]: Model }, BasePart?)
	model:PivotTo(cf)
	local states: { [string]: Model } = {}
	local mount: BasePart? = nil
	for _, child in model:GetChildren() do
		if child:IsA("Model") then
			local state = child:GetAttribute(CryptidArt.attr.state)
			if type(state) == "string" then
				states[state] = child
				child.Parent = nil
			end
		elseif child.Name == CryptidArt.mountName and child:IsA("BasePart") then
			mount = child
		end
	end
	return states, mount
end

function LairVisual.applyPad(model: Model?, states: { [string]: Model }?, state: string, affordable: boolean)
	if model == nil or states == nil then
		return
	end
	for name, group in states do
		local on = name == state
		if name == CryptidArt.states.affordable then
			on = CryptidArt.affordableRim(state, affordable)
		end
		local parent: Instance? = if on then model else nil
		if group.Parent ~= parent then
			group.Parent = parent
		end
	end
end

function LairVisual.prepareAltar(model: Model, cf: CFrame): { [number]: Model }
	model:PivotTo(cf)
	local tiers: { [number]: Model } = {}
	for _, child in model:GetChildren() do
		if child:IsA("Model") then
			local tierValue = child:GetAttribute(CryptidArt.attr.tier)
			local tier = nil
			if type(tierValue) == "number" then
				tier = tierValue
			elseif type(tierValue) == "string" then
				tier = tonumber(tierValue)
			end
			if tier ~= nil then
				tiers[tier] = child
				child.Parent = nil
			end
		end
	end
	return tiers
end

function LairVisual.applyAltar(model: Model?, tiers: { [number]: Model }?, level: number)
	if tiers == nil then
		return
	end
	for tier, group in tiers do
		local parent: Instance? = if model ~= nil and CryptidArt.tierShown(tier, level) then model else nil
		if group.Parent ~= parent then
			group.Parent = parent
		end
	end
end

return LairVisual
