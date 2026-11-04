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

export type PlotSlot = {
	state: string,
	userId: number,
}

export type AssignState = {
	count: number,
	plots: { PlotSlot },
}

local PlotAssign = {}

function PlotAssign.empty(count: number): AssignState
	local plots = {}
	for index = 1, count do
		plots[index] = {
			state = "free",
			userId = 0,
		}
	end
	return {
		count = count,
		plots = plots,
	}
end

function PlotAssign.ringSteps(a: number, b: number, count: number): number
	local delta = math.abs(a - b)
	return math.min(delta, count - delta)
end

function PlotAssign.reservedIndex(state: AssignState, userId: number): number?
	for index = 1, state.count do
		local plot = state.plots[index]
		if plot.state == "reserved" and plot.userId == userId then
			return index
		end
	end
	return nil
end

function PlotAssign.choose(state: AssignState, userId: number, friendPlots: { number }?): number?
	local reserved = PlotAssign.reservedIndex(state, userId)
	if reserved ~= nil then
		return reserved
	end
	if type(friendPlots) == "table" and #friendPlots > 0 then
		local bestIndex = nil
		local bestSteps = nil
		for index = 1, state.count do
			if state.plots[index].state == "free" then
				local steps = nil
				for _, friendPlot in friendPlots do
					if friendPlot >= 1 and friendPlot <= state.count then
						local distance = PlotAssign.ringSteps(index, friendPlot, state.count)
						if steps == nil or distance < steps then
							steps = distance
						end
					end
				end
				if steps ~= nil and (bestSteps == nil or steps < bestSteps) then
					bestSteps = steps
					bestIndex = index
				end
			end
		end
		if bestIndex ~= nil then
			return bestIndex
		end
	end
	for index = 1, state.count do
		if state.plots[index].state == "free" then
			return index
		end
	end
	return nil
end

function PlotAssign.take(state: AssignState, userId: number, friendPlots: { number }?): number?
	local index = PlotAssign.choose(state, userId, friendPlots)
	if index == nil then
		return nil
	end
	state.plots[index] = {
		state = "owned",
		userId = userId,
	}
	return index
end

function PlotAssign.reserve(state: AssignState, userId: number): number?
	for index = 1, state.count do
		local plot = state.plots[index]
		if plot.state == "owned" and plot.userId == userId then
			plot.state = "reserved"
			return index
		end
	end
	return nil
end

function PlotAssign.holdPhase(elapsed: number, holdSeconds: number): string
	if elapsed >= holdSeconds then
		return "clear"
	end
	return "reserved"
end

function PlotAssign.releaseIfDue(state: AssignState, plotIndex: number, elapsed: number, holdSeconds: number): string
	local plot = state.plots[plotIndex]
	if plot.state == "reserved" and PlotAssign.holdPhase(elapsed, holdSeconds) == "clear" then
		plot.state = "free"
		plot.userId = 0
	end
	return plot.state
end

function PlotAssign.earns(phase: string): boolean
	return phase == "present"
end

function PlotAssign.intrusion(plotIndex: number, userId: number): { name: string, plotIndex: number, userId: number }
	return {
		name = Plots.INTRUSION_EVENT,
		plotIndex = plotIndex,
		userId = userId,
	}
end

return PlotAssign
