--!strict

local SpawnSafety = {}

function SpawnSafety.aboveBox(
	point: { x: number, y: number, z: number },
	minX: number,
	maxX: number,
	minZ: number,
	maxZ: number,
	floorTop: number,
	maxDrop: number
): boolean
	local drop = point.y - floorTop
	return point.x >= minX
		and point.x <= maxX
		and point.z >= minZ
		and point.z <= maxZ
		and drop >= -0.05
		and drop <= maxDrop
end

function SpawnSafety.aboveSlab(
	point: { x: number, y: number, z: number },
	half: number,
	floorTop: number,
	maxDrop: number
): boolean
	return SpawnSafety.aboveBox(point, -half, half, -half, half, floorTop, maxDrop)
end

function SpawnSafety.placeTarget(built: boolean, floorReady: boolean): string
	if built and floorReady then
		return "plot"
	end
	return "fallback"
end

return SpawnSafety
