--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Plots = import("../Config/Plots", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Plots")
end)
local Town = import("../Config/Town", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Town")
end)

local TownLayout = {}

function TownLayout.townRadius(): number
	return Plots.TOWN_RADIUS
end

function TownLayout.roadAngle(index: number): number
	return (index - 1) * Plots.ANGLE_STEP
end

function TownLayout.districtAngle(index: number): number
	return Town.FIRST_DISTRICT_ANGLE + (index - 1) * Plots.ANGLE_STEP
end

function TownLayout.openingHalfAngle(): number
	return math.atan((Town.ROAD_WIDTH * 0.5) / Plots.TOWN_RADIUS)
end

function TownLayout.opening(index: number): any
	local angle = TownLayout.roadAngle(index)
	local theta = math.rad(angle)
	return {
		index = index,
		angle = angle,
		x = Plots.TOWN_RADIUS * math.sin(theta),
		y = Town.FLOOR_Y,
		z = Plots.TOWN_RADIUS * math.cos(theta),
	}
end

function TownLayout.district(index: number): any
	local angle = TownLayout.districtAngle(index)
	local theta = math.rad(angle)
	local spec = Town.DISTRICTS[index]
	return {
		index = index,
		angle = angle,
		x = Town.DISTRICT_RADIUS * math.sin(theta),
		y = Town.FLOOR_Y,
		z = Town.DISTRICT_RADIUS * math.cos(theta),
		id = spec.id,
		status = spec.status,
		kind = spec.kind,
	}
end

function TownLayout.well(): any
	return {
		x = 0,
		y = 0,
		z = 0,
	}
end

function TownLayout.radius(point: any): number
	return math.sqrt(point.x * point.x + point.z * point.z)
end

function TownLayout.leanDegrees(index: number): number
	local span = Town.LEAN_MAX - Town.LEAN_MIN
	local degrees = Town.LEAN_MIN + (index - 1) * span / (Plots.COUNT - 1)
	if index % 2 == 0 then
		return -degrees
	end
	return degrees
end

function TownLayout.lampRadius(): number
	return Town.LAMP_COUNT * Town.LAMP_SPACING / (2 * math.pi)
end

function TownLayout.front(index: number): any
	local place = TownLayout.district(index)
	local radial = TownLayout.radius(place)
	return {
		x = -place.x / radial,
		z = -place.z / radial,
	}
end

return TownLayout
