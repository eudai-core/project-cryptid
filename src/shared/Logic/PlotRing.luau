--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local Economy = import("../Config/Economy", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Economy")
end)
local Plots = import("../Config/Plots", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Plots")
end)

export type Vec3 = {
	x: number,
	y: number,
	z: number,
}

export type Axes = {
	x: Vec3,
	y: Vec3,
	z: Vec3,
}

local PlotRing = {}

local function vec(x: number, y: number, z: number): Vec3
	return { x = x, y = y, z = z }
end

function PlotRing.center(index: number): Vec3
	local theta = math.rad((index - 1) * Plots.ANGLE_STEP)
	return vec(Plots.RING_RADIUS * math.sin(theta), 0, Plots.RING_RADIUS * math.cos(theta))
end

function PlotRing.axes(index: number): Axes
	local center = PlotRing.center(index)
	local radial = math.sqrt(center.x * center.x + center.z * center.z)
	local zx = -center.x / radial
	local zz = -center.z / radial
	return {
		x = vec(zz, 0, -zx),
		y = vec(0, 1, 0),
		z = vec(zx, 0, zz),
	}
end

function PlotRing.toWorld(index: number, localPoint: Vec3): Vec3
	local center = PlotRing.center(index)
	local axes = PlotRing.axes(index)
	return vec(
		center.x + localPoint.x * axes.x.x + localPoint.y * axes.y.x + localPoint.z * axes.z.x,
		center.y + localPoint.x * axes.x.y + localPoint.y * axes.y.y + localPoint.z * axes.z.y,
		center.z + localPoint.x * axes.x.z + localPoint.y * axes.y.z + localPoint.z * axes.z.z
	)
end

function PlotRing.padLocal(padIndex: number): Vec3
	local theta = math.rad((padIndex - 1) * Plots.PAD_ANGLE_STEP)
	return vec(
		Plots.ALTAR_X + Plots.PAD_RING_RADIUS * math.sin(theta),
		0,
		Plots.ALTAR_Z + Plots.PAD_RING_RADIUS * math.cos(theta)
	)
end

function PlotRing.isSealedPad(padIndex: number): boolean
	return padIndex >= Plots.SEALED_PAD_START and padIndex <= Plots.PAD_COUNT
end

function PlotRing.socketName(socketIndex: number): string
	return "DefenceSocket" .. tostring(socketIndex)
end

function PlotRing.socketLocal(socketIndex: number): Vec3
	local socket = Plots.DEFENCE_SOCKETS[socketIndex]
	return vec(socket.x, 0, socket.z)
end

function PlotRing.wildLocal(): Vec3
	return vec(0, 0, Plots.WILD_GATE_Z - Economy.WILD_SPAWN_STUDS)
end

function PlotRing.spawnLocal(): Vec3
	return vec(0, Plots.STAND_HEIGHT, Plots.SPAWN_Z)
end

function PlotRing.townEdge(index: number): Vec3
	local center = PlotRing.center(index)
	local radial = math.sqrt(center.x * center.x + center.z * center.z)
	local scale = Plots.TOWN_RADIUS / radial
	return vec(center.x * scale, Plots.STAND_HEIGHT, center.z * scale)
end

function PlotRing.radius(point: Vec3): number
	return math.sqrt(point.x * point.x + point.z * point.z)
end

return PlotRing
