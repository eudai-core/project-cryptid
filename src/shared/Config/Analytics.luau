--!strict

-- Funnel names for spec 01 v2. Completing goal G logs funnel step G + 1,
-- which is the onboarding.step you land on. Showing goal 8 also logs step 9.
-- This module only plans the events. Nothing here sends them.

local FUNNEL = table.freeze({
	[1] = "Joined",
	[2] = "Starter Earning",
	[3] = "Claimed Rift Cryptid 1",
	[4] = "Caught Hodag",
	[5] = "Bound Hodag on Pad 3",
	[6] = "Raised Bone Altar I",
	[7] = "Carved Pad 4",
	[8] = "Claimed Rift Cryptid 2",
	[9] = "Rite Complete",
})

local Analytics = {
	FUNNEL = FUNNEL,
	CATCH_STEP = 4,
	CATCH_EVENT = "CatchCompleted",
	RITE_STEP = 9,
	GOAL_COUNT = 8,
}

function Analytics.funnelStep(goal: number): number
	return goal + 1
end

function Analytics.nameFor(step: number): string?
	return FUNNEL[step]
end

function Analytics.joinEvent(): { step: number, stepName: string, catch: boolean, eventName: string? }
	return {
		step = 1,
		stepName = FUNNEL[1],
		catch = false,
		eventName = nil,
	}
end

function Analytics.eventsForTransition(
	fromStep: number,
	toStep: number,
	skipped: boolean
): { { step: number, stepName: string, catch: boolean, eventName: string? } }
	if skipped == true then
		return {}
	end
	local events = {}
	local landed = toStep
	if landed > Analytics.GOAL_COUNT then
		landed = Analytics.GOAL_COUNT
	end
	local goal = fromStep
	if goal < 1 then
		goal = 1
	end
	while goal < landed do
		local step = Analytics.funnelStep(goal)
		local name = FUNNEL[step]
		if name ~= nil then
			local caught = step == Analytics.CATCH_STEP
			table.insert(events, {
				step = step,
				stepName = name,
				catch = caught,
				eventName = if caught then Analytics.CATCH_EVENT else nil,
			})
		end
		goal += 1
	end
	if toStep >= Analytics.GOAL_COUNT and fromStep < Analytics.GOAL_COUNT then
		table.insert(events, {
			step = Analytics.RITE_STEP,
			stepName = FUNNEL[Analytics.RITE_STEP],
			catch = false,
			eventName = nil,
		})
	end
	return events
end

return Analytics
