--!strict

local function import(lunePath: string, getRoblox: () -> any): any
	-- selene: allow(global_usage)
	if _G.LUNE == true then
		return require(lunePath)
	end
	return require(getRoblox())
end

local SkillConfig = import("../Config/SkillConfig", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("SkillConfig")
end)
local Shop = import("../Config/Shop", function()
	return script.Parent.Parent:WaitForChild("Config"):WaitForChild("Shop")
end)
local Money = import("./Money", function()
	return script.Parent:WaitForChild("Money")
end)
local NumberFormat = import("./NumberFormat", function()
	return script.Parent:WaitForChild("NumberFormat")
end)

local SkillTree = {}

function SkillTree.gateOpen(step: any): boolean
	return type(step) == "number" and step >= Shop.GATE_STEP
end

function SkillTree.stepOf(profile: any): number
	if type(profile) ~= "table" or type(profile.onboarding) ~= "table" then
		return 0
	end
	local step = profile.onboarding.step
	if type(step) ~= "number" then
		return 0
	end
	return step
end

function SkillTree.ownsId(profile: any, id: string): boolean
	if id == SkillConfig.ROOT then
		local root = SkillConfig.get(SkillConfig.ROOT)
		return root ~= nil and root.sealed ~= true
	end
	if type(profile) ~= "table" or type(profile.skills) ~= "table" then
		return false
	end
	local node = SkillConfig.get(id)
	if node == nil or node.sealed == true then
		return false
	end
	for index = 1, #profile.skills do
		if profile.skills[index] == id then
			return true
		end
	end
	return false
end

local function prereqMet(profile: any, node: any): boolean
	if #node.requires == 0 then
		return true
	end
	for _, parentId in node.requires do
		if SkillTree.ownsId(profile, parentId) then
			return true
		end
	end
	return false
end

function SkillTree.state(profile: any, id: string): string
	local node = SkillConfig.get(id)
	if node == nil then
		return "unknown"
	end
	if node.sealed == true then
		return "sealed"
	end
	if SkillTree.ownsId(profile, id) then
		return "owned"
	end
	if prereqMet(profile, node) then
		return "available"
	end
	return "locked"
end

function SkillTree.evaluate(profile: any, nodeId: any): (boolean, string)
	if type(nodeId) ~= "string" or SkillConfig.get(nodeId) == nil then
		return false, "unknown"
	end
	if not SkillTree.gateOpen(SkillTree.stepOf(profile)) then
		return false, "onboarding"
	end
	local node = SkillConfig.get(nodeId)
	if node.sealed == true then
		return false, "sealed"
	end
	if SkillTree.ownsId(profile, nodeId) then
		return false, "owned"
	end
	if not prereqMet(profile, node) then
		return false, "prereq"
	end
	local cash = profile.cash
	if type(cash) ~= "number" or cash ~= cash or cash + 1e-9 < node.cost then
		return false, "afford"
	end
	return true, "ok"
end

function SkillTree.buy(profile: any, nodeId: any, _clientPrice: any?): (boolean, string)
	local ok, reason = SkillTree.evaluate(profile, nodeId)
	if not ok then
		return false, reason
	end
	local node = SkillConfig.get(nodeId)
	if type(profile.skills) ~= "table" then
		profile.skills = {}
	end
	profile.cash = Money.round(profile.cash - node.cost)
	table.insert(profile.skills, nodeId)
	return true, "ok"
end

function SkillTree.pathStyle(profile: any, parentId: string, childId: string): string
	local child = SkillTree.state(profile, childId)
	if child == "sealed" then
		return "sealedChalk"
	end
	local parent = SkillTree.state(profile, parentId)
	if parent == "owned" and child == "owned" then
		return "vein"
	end
	if child == "available" then
		return "bright"
	end
	return "chalk"
end

function SkillTree.pathLook(style: string): any
	local ui = SkillConfig.UI
	if style == "vein" then
		return {
			color = "Blood",
			glow = "BloodHover",
			transparency = 0,
			glowTransparency = ui.veinGlowTransparency,
			thickness = ui.veinCore,
			glowThickness = ui.veinGlow,
			dashed = false,
			flow = true,
			pulse = false,
		}
	end
	if style == "bright" then
		return {
			color = "Bone",
			glow = "Bone",
			transparency = ui.brightTransparency,
			glowTransparency = 1,
			thickness = ui.pathThickness,
			glowThickness = 0,
			dashed = false,
			flow = false,
			pulse = false,
		}
	end
	if style == "sealedChalk" then
		return {
			color = "Bone",
			glow = "Bone",
			transparency = ui.sealedPathTransparency,
			glowTransparency = 1,
			thickness = ui.pathThickness,
			glowThickness = 0,
			dashed = true,
			flow = false,
			pulse = false,
		}
	end
	return {
		color = "Bone",
		glow = "Bone",
		transparency = ui.chalkTransparency,
		glowTransparency = 1,
		thickness = ui.pathThickness,
		glowThickness = 0,
		dashed = true,
		flow = false,
		pulse = false,
	}
end

function SkillTree.visual(state: string, reduced: boolean, _zoom: number?): any
	local ui = SkillConfig.UI
	if state == "owned" then
		return {
			fill = "Blood",
			stroke = "GoldBright",
			strokePx = ui.ownedStroke,
			strokeTransparency = 0,
			sigil = "Bone",
			sigilTransparency = 0,
			pulse = false,
			sparks = not reduced,
			glow = false,
			flame = false,
			seal = false,
			lock = false,
			cracks = false,
		}
	end
	if state == "available" then
		return {
			fill = "Ash",
			stroke = "Gold",
			strokePx = ui.availableStroke,
			strokeTransparency = ui.pulseMin,
			sigil = "Bone",
			sigilTransparency = 0,
			pulse = not reduced,
			sparks = false,
			glow = false,
			flame = true,
			seal = false,
			lock = false,
			cracks = false,
		}
	end
	if state == "sealed" then
		return {
			fill = "Soot",
			stroke = "BoneDim",
			strokePx = ui.lockedStroke,
			strokeTransparency = 0,
			sigil = "Bone",
			sigilTransparency = ui.sigilSealed,
			pulse = false,
			sparks = false,
			glow = false,
			flame = false,
			seal = true,
			lock = false,
			cracks = true,
		}
	end
	return {
		fill = "Soot",
		stroke = "BoneDim",
		strokePx = ui.lockedStroke,
		strokeTransparency = 0,
		sigil = "Bone",
		sigilTransparency = ui.sigilLocked,
		pulse = false,
		sparks = false,
		glow = false,
		flame = false,
		seal = false,
		lock = true,
		cracks = true,
	}
end

local function requiresLine(node: any): string?
	if #node.requires == 0 then
		return nil
	end
	local names = {}
	for _, parentId in node.requires do
		local parent = SkillConfig.get(parentId)
		if parent ~= nil then
			table.insert(names, parent.name)
		end
	end
	if #names == 0 then
		return nil
	end
	return SkillConfig.REQUIRES .. table.concat(names, SkillConfig.OR_JOIN)
end

function SkillTree.tooltip(profile: any, id: string): any?
	local node = SkillConfig.get(id)
	if node == nil then
		return nil
	end
	local state = SkillTree.state(profile, id)
	local tip = {
		title = node.name,
		branch = if node.branchLine ~= "" then node.branchLine else nil,
		effect = nil,
		sealedLine = nil,
		requires = nil,
		cost = nil,
		need = nil,
		buy = "hidden",
		bound = false,
	}
	if state == "sealed" then
		tip.sealedLine = SkillConfig.SEALED_LINE
		return tip
	end
	if node.effect.text ~= "" then
		tip.effect = node.effect.text
	end
	if state == "locked" then
		tip.requires = requiresLine(node)
	end
	if node.cost > 0 then
		tip.cost = NumberFormat.formatCash(node.cost)
	end
	if state == "owned" then
		tip.buy = "owned"
		tip.bound = true
		return tip
	end
	if state ~= "available" then
		return tip
	end
	local cash = if type(profile.cash) == "number" then profile.cash else 0
	local short = node.cost - cash
	if short > 1e-9 then
		tip.buy = "broke"
		tip.need = string.format(SkillConfig.NEED_MORE, NumberFormat.formatCash(short))
		return tip
	end
	tip.buy = "ready"
	return tip
end

function SkillTree.hitSize(node: any): number
	local ui = SkillConfig.UI
	local padded = node.size + ui.hitPad
	local touch = math.ceil(ui.touchMin / ui.zoomMin)
	if padded >= touch then
		return padded
	end
	return touch
end

function SkillTree.clampZoom(zoom: number): number
	local ui = SkillConfig.UI
	if type(zoom) ~= "number" or zoom ~= zoom then
		return ui.zoomDefault
	end
	if zoom < ui.zoomMin then
		return ui.zoomMin
	end
	if zoom > ui.zoomMax then
		return ui.zoomMax
	end
	return zoom
end

function SkillTree.wheelZoom(zoom: number, notches: number): number
	if type(notches) ~= "number" or notches ~= notches then
		return SkillTree.clampZoom(zoom)
	end
	return SkillTree.clampZoom(zoom * (SkillConfig.UI.zoomWheel ^ notches))
end

function SkillTree.clampPan(panX: number, panY: number, zoom: number): (number, number)
	local scale = SkillTree.clampZoom(zoom)
	local limit = SkillConfig.UI.panLimit * scale
	if type(panX) ~= "number" or panX ~= panX then
		panX = 0
	end
	if type(panY) ~= "number" or panY ~= panY then
		panY = 0
	end
	local mag = math.sqrt(panX * panX + panY * panY)
	if mag <= limit or mag == 0 then
		return panX, panY
	end
	local kept = limit / mag
	return panX * kept, panY * kept
end

function SkillTree.zoomToward(
	panX: number,
	panY: number,
	zoom: number,
	cursorX: number,
	cursorY: number,
	nextZoom: number
): (number, number, number)
	local current = SkillTree.clampZoom(zoom)
	local goal = SkillTree.clampZoom(nextZoom)
	if current == 0 then
		return SkillTree.clampPan(panX, panY, goal)
	end
	local ratio = goal / current
	local movedX = cursorX - (cursorX - panX) * ratio
	local movedY = cursorY - (cursorY - panY) * ratio
	local clampedX, clampedY = SkillTree.clampPan(movedX, movedY, goal)
	return clampedX, clampedY, goal
end

function SkillTree.resetView(): (number, number, number)
	return 0, 0, SkillConfig.UI.zoomDefault
end

function SkillTree.pastDrag(dx: number, dy: number): boolean
	local limit = SkillConfig.UI.dragThreshold
	return dx * dx + dy * dy >= limit * limit
end

function SkillTree.tooltipOrigin(
	anchorX: number,
	anchorY: number,
	viewW: number,
	viewH: number,
	tipW: number,
	tipH: number,
	gap: number
): (number, number)
	local x = anchorX + gap
	local y = anchorY - tipH / 2
	if x + tipW > viewW then
		x = anchorX - gap - tipW
	end
	if x < 0 then
		x = 0
	end
	if y < 0 then
		y = 0
	end
	if y + tipH > viewH then
		y = math.max(0, viewH - tipH)
	end
	return x, y
end

function SkillTree.ignitePlan(reduced: boolean): any
	local ui = SkillConfig.UI
	if reduced then
		return {
			total = ui.igniteReduced,
			scale = false,
			ring = false,
			embers = false,
			sparks = false,
			flow = false,
			fade = true,
			play = true,
		}
	end
	return {
		total = ui.igniteTotal,
		scale = true,
		ring = true,
		embers = true,
		sparks = true,
		flow = true,
		fade = false,
		play = true,
		scaleSeconds = ui.igniteScale,
		ringSeconds = ui.igniteRing,
		emberSeconds = ui.igniteEmbers,
		pathSeconds = ui.ignitePath,
		pathDelay = ui.ignitePathDelay,
	}
end

function SkillTree.shouldIgnite(before: { [string]: boolean }, id: string): boolean
	if before[id] == true then
		return false
	end
	local node = SkillConfig.get(id)
	if node == nil or node.sealed == true or id == SkillConfig.ROOT then
		return false
	end
	return true
end

function SkillTree.ring1Total(): number
	local total = 0
	for _, id in SkillConfig.ORDER do
		local node = SkillConfig.get(id)
		if node.ring == 1 and node.sealed ~= true and node.cost > 0 then
			total += node.cost
		end
	end
	return total
end

return SkillTree
