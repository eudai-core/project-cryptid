--!strict

-- Save-debug suffixes on a bot playtest arg `qa:<seconds>[:suffix]`.
-- Callers pass isStudio. A live server always gets the inert plan.
-- Offline and offering suffixes are applied by StudioQaHooks.

local StudioQa = {}

local HOOKS = {
	["loadfail"] = true,
	["foreignlock"] = true,
	["foreignlock:stale"] = true,
}

function StudioQa.parse(args: any): string?
	if type(args) ~= "string" then
		return nil
	end
	local suffix = string.match(args, "^qa:%d+:(.+)$")
	if suffix == nil or HOOKS[suffix] ~= true then
		return nil
	end
	return suffix
end

function StudioQa.active(isStudio: boolean, args: any): string?
	if isStudio ~= true then
		return nil
	end
	return StudioQa.parse(args)
end

function StudioQa.plan(isStudio: boolean, args: any): string
	local hook = StudioQa.active(isStudio, args)
	if hook == "loadfail" then
		return "kick"
	end
	if hook == "foreignlock" then
		return "seed-fresh"
	end
	if hook == "foreignlock:stale" then
		return "seed-stale"
	end
	return "load"
end

return StudioQa
