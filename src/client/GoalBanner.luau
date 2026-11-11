--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Motion = require(script.Parent:WaitForChild("Motion"))
local UiFactory = require(script.Parent:WaitForChild("UiFactory"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Onboarding = require(Shared:WaitForChild("Config"):WaitForChild("Onboarding")) :: any
local UITheme = require(Shared:WaitForChild("UITheme")) :: any

local GoalBanner = {}

function GoalBanner.mount(parent: Instance, isReduced: () -> boolean, onAction: (any) -> (), onSkip: () -> ())
	local frame = UiFactory.panel(parent)
	frame.Name = "GoalBanner"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.ClipsDescendants = true
	local stroke = frame:FindFirstChildOfClass("UIStroke")

	local title = UiFactory.label(frame, "display", UITheme.fonts.display.desktop, "Bone")
	title.Name = "Headline"
	title.TextWrapped = true
	title.TextYAlignment = Enum.TextYAlignment.Top
	title.TextXAlignment = Enum.TextXAlignment.Center

	local progress = UiFactory.label(frame, "body", UITheme.fonts.body.desktop, "BoneDim")
	progress.Name = "Progress"
	progress.TextXAlignment = Enum.TextXAlignment.Center
	progress.TextWrapped = true

	local action = UiFactory.button(frame, UITheme.fonts.body.desktop)
	action.Name = "Action"
	action.Text = ""
	local actionEnabled = false
	Motion.wireButton(action, function()
		return actionEnabled
	end, isReduced)

	local skip = Instance.new("TextButton")
	skip.Name = "Skip"
	skip.AutoButtonColor = false
	skip.BackgroundTransparency = 1
	skip.BorderSizePixel = 0
	skip.Text = Onboarding.SKIP_LABEL
	skip.TextColor3 = UITheme.color("BoneDim")
	skip.RichText = false
	skip.Parent = frame
	local ThemeBind = require(script.Parent:WaitForChild("ThemeBind"))
	ThemeBind.apply(skip, "body", UITheme.text.minSize)

	local target = UDim2.new(0.5, 0, 0, 104)
	local seenHeadline = ""
	local seenStep = 0
	local currentGoal: any = nil
	local entered = false
	local busyUntil = 0

	local function hold(seconds: number)
		local untilAt = os.clock() + seconds
		if untilAt > busyUntil then
			busyUntil = untilAt
		end
	end

	local function place(animated: boolean)
		local plan = UITheme.resolveMotion("goalIn", isReduced())
		local offset = UITheme.motion.goalIn.offset or 12
		if animated and plan.allowOffset and plan.duration > 0 then
			frame.Position = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset - offset)
			Motion.play(frame, "goalIn", false, { Position = target })
			hold(plan.duration)
		else
			frame.Position = target
		end
	end

	local api = {}

	function api.layout(isMobile: boolean): number
		local banner = UITheme.shape.goalBanner
		local metrics = if isMobile then banner.mobile else banner.desktop
		frame.Size = UDim2.fromOffset(metrics.w, metrics.h)
		target = UDim2.new(0.5, 0, 0, banner.topPx)
		if not entered then
			entered = true
			place(true)
		else
			frame.Position = target
		end
		local titleSize = if isMobile then banner.titleMobile else banner.titleDesktop
		local bodySize = if isMobile then UITheme.fonts.body.mobile else UITheme.fonts.body.desktop
		local pad = banner.pad
		title.Position = UDim2.fromOffset(pad, pad)
		title.Size = UDim2.new(1, -(pad * 2 + 108), 0, titleSize * 2)
		progress.Position = UDim2.fromOffset(pad, pad + titleSize * 2)
		progress.Size = UDim2.new(1, -pad * 2, 0, bodySize + 2)
		action.AnchorPoint = Vector2.new(0.5, 1)
		action.Position = UDim2.new(0.5, 0, 1, -pad)
		action.Size = UDim2.fromOffset(if isMobile then 180 else 200, banner.buttonH)
		skip.AnchorPoint = Vector2.new(1, 0)
		skip.Position = UDim2.new(1, -pad, 0, 2)
		skip.Size = UDim2.fromOffset(108, UITheme.text.minSize + 4)
		ThemeBind.apply(title, "display", titleSize)
		ThemeBind.apply(progress, "body", bodySize)
		ThemeBind.apply(action, "body", bodySize)
		ThemeBind.apply(skip, "body", UITheme.text.minSize)
		return metrics.h
	end

	function api.isBusy(): boolean
		return os.clock() < busyUntil
	end

	function api.apply(goal: any)
		if type(goal) ~= "table" then
			return
		end
		currentGoal = goal
		local headline = tostring(goal.headline or "")
		local step = goal.step or 0
		if headline ~= seenHeadline then
			local first = seenHeadline == ""
			seenHeadline = headline
			title.Text = headline
			if not first then
				place(true)
			end
		end
		progress.Text = tostring(goal.progressText or "")
		local label = tostring(goal.buttonText or "")
		actionEnabled = goal.buttonEnabled == true
		action.Text = label
		action.Visible = label ~= ""
		action.Active = actionEnabled
		action.AutoButtonColor = false
		if actionEnabled then
			action.BackgroundColor3 = UITheme.color("Blood")
			action.TextColor3 = UITheme.color("Bone")
		else
			action.BackgroundColor3 = UITheme.color("Soot")
			action.TextColor3 = UITheme.color("BoneDim")
		end
		skip.Visible = goal.showSkip == true
		if step > seenStep and seenStep > 0 and stroke ~= nil then
			local plan = UITheme.resolveMotion("goalComplete", isReduced())
			stroke.Color = UITheme.color("GoldBright")
			hold(plan.duration)
			if plan.duration > 0 then
				task.delay(plan.duration, function()
					if stroke.Parent ~= nil then
						stroke.Color = UITheme.color("Gold")
					end
				end)
			else
				stroke.Color = UITheme.color("Gold")
			end
		end
		seenStep = step
	end

	action.Activated:Connect(function()
		if actionEnabled and currentGoal ~= nil then
			onAction(currentGoal)
		end
	end)
	skip.Activated:Connect(onSkip)

	api.layout(false)
	return api
end

return GoalBanner
