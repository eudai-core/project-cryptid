--!strict

export type MotionKind = "color" | "scale" | "fade" | "fadeSlide" | "count" | "float" | "slide" | "flash"

export type MotionEvent = {
	duration: number,
	easing: string,
	direction: string,
	kind: MotionKind,
	scale: number?,
	offset: number?,
	skipUnderFraction: number?,
}

export type MotionPlan = {
	duration: number,
	allowOffset: boolean,
	allowScale: boolean,
	allowFloat: boolean,
	allowCount: boolean,
}

local palette = table.freeze({
	Void = "0B0A0C",
	Ash = "1A1719",
	Soot = "2A2427",
	Blood = "7A0F12",
	BloodHover = "94171B",
	Gold = "9C7A3C",
	GoldBright = "C9A55A",
	Bone = "E8E0CF",
	BoneDim = "A79F90",
	Rift = "7FA34A",
	RiftDim = "4F6B34",
	Moss = "5E7A4A",
	TarnishedSilver = "8C9AA3",
	LightAmbient = "3C3734",
	LightOutdoor = "5F5852",
})

local world = table.freeze({
	Candle = "FFB36B",
	Ambient = "2C2622",
	OutdoorAmbient = "221E1B",
	Floor = "3A342F",
	Wall = "1C1917",
	Altar = "403932",
})

local UITheme = {
	palette = palette,
	world = world,
	rarity = table.freeze({
		Common = "BoneDim",
		Uncommon = "Moss",
		Rare = "TarnishedSilver",
		Epic = "Blood",
		Legendary = "GoldBright",
		Mythic = "Rift",
	}),
	fonts = table.freeze({
		display = table.freeze({
			family = "GrenzeGotisch",
			weight = "Regular",
			desktop = 36,
			mobile = 28,
		}),
		header = table.freeze({
			family = "Garamond",
			weight = "Bold",
			desktop = 24,
			mobile = 20,
		}),
		body = table.freeze({
			family = "Merriweather",
			weight = "Regular",
			desktop = 18,
			mobile = 16,
		}),
		sigil = table.freeze({
			family = "Garamond",
			weight = "Bold",
		}),
		number = table.freeze({
			family = "Oswald",
			weight = "Regular",
			desktop = 18,
			mobile = 16,
			plaqueDesktop = 28,
			plaqueMobile = 22,
		}),
		income = table.freeze({
			family = "Oswald",
			weight = "Regular",
			desktop = 16,
			mobile = 14,
		}),
	}),
	fontFaces = table.freeze({
		Garamond = "rbxasset://fonts/families/Guru.json",
	}),
	text = table.freeze({
		minSize = 14,
		scaled = false,
	}),
	shape = table.freeze({
		cornerPx = 4,
		strokePx = 1,
		strokeTransparency = 0.4,
		plaqueStrokePx = 2,
		plaqueTopPx = 24,
		plaqueGapPx = 8,
		plaqueBowlPx = 20,
		screenInset = 12,
		offeringPip = 8,
		escapePriority = 3000,
		busyPoll = 0.05,
		touchPx = 44,
		haulPanel = table.freeze({
			desktop = table.freeze({ w = 560, h = 360 }),
			mobileH = 360,
			title = 32,
			body = 18,
			amount = 40,
			detail = 14,
			buttonW = 220,
		}),
		offeringPanel = table.freeze({
			desktop = table.freeze({ w = 720, h = 460 }),
			mobileH = 520,
			title = 32,
			card = 14,
			body = 18,
			detail = 14,
			buttonW = 240,
			cardDesktop = table.freeze({ w = 88, h = 110 }),
			cardMobile = table.freeze({ w = 148, h = 92 }),
		}),
		plaqueSize = table.freeze({
			desktop = table.freeze({ w = 320, h = 72 }),
			mobile = table.freeze({ w = 240, h = 60 }),
		}),
		mobileWidthBreakpoint = 700,
		overlayTransparency = 0.15,
		beamWidth = 0.3,
	}),
	lighting = table.freeze({
		brightness = 1.5,
		exposureCompensation = 0.3,
		clockTime = 1,
		geographicLatitude = 0,
		globalShadows = true,
		ambient = "LightAmbient",
		outdoorAmbient = "LightOutdoor",
		fogStart = 250,
		fogEnd = 1100,
		fogColor = "Ash",
		atmosphereDensity = 0.18,
		atmosphereOffset = 0,
		atmosphereHaze = 0.3,
		atmosphereGlare = 0,
		atmosphereColor = "Ash",
		atmosphereDecay = "Void",
		-- Lighting.Technology is not scriptable. default.project.json writes Future.
		technology = "Future",
	}),
	materials = table.freeze({
		floor = "Slate",
		wall = "Basalt",
		padRing = "CorrodedMetal",
		padCenter = "Slate",
		conveyor = "Basalt",
		neon = "Neon",
		lantern = "Metal",
		candle = "SmoothPlastic",
		altar = "Slate",
		cloth = "Fabric",
		glass = "Glass",
		cobble = "Cobblestone",
		wood = "WoodPlanks",
		iron = "Metal",
	}),
	motion = table.freeze({
		buttonHover = table.freeze({
			duration = 0.10,
			easing = "Linear",
			direction = "Out",
			kind = "color" :: MotionKind,
		}),
		buttonPress = table.freeze({
			duration = 0.12,
			easing = "Quad",
			direction = "Out",
			kind = "scale" :: MotionKind,
			scale = 0.96,
		}),
		panelOpen = table.freeze({
			duration = 0.25,
			easing = "Quad",
			direction = "Out",
			kind = "fadeSlide" :: MotionKind,
			offset = 12,
		}),
		panelClose = table.freeze({
			duration = 0.15,
			easing = "Quad",
			direction = "In",
			kind = "fade" :: MotionKind,
		}),
		cashCount = table.freeze({
			duration = 0.40,
			easing = "Quad",
			direction = "Out",
			kind = "count" :: MotionKind,
			skipUnderFraction = 0.01,
		}),
		incomeFloat = table.freeze({
			duration = 0.80,
			easing = "Quad",
			direction = "Out",
			kind = "float" :: MotionKind,
			offset = 20,
		}),
		goalIn = table.freeze({
			duration = 0.35,
			easing = "Back",
			direction = "Out",
			kind = "slide" :: MotionKind,
			offset = 12,
		}),
		goalComplete = table.freeze({
			duration = 0.50,
			easing = "Quad",
			direction = "Out",
			kind = "flash" :: MotionKind,
		}),
		haulCount = table.freeze({
			duration = 0.60,
			easing = "Quad",
			direction = "Out",
			kind = "count" :: MotionKind,
		}),
	}),
	reducedMotion = table.freeze({
		maxFade = 0.15,
	}),
	-- GrenzeGotisch draws basic Latin only. A star dingbat shows as an empty box.
	sigil = "+",
	disabledMark = "⊘",
}

function UITheme.textIsSafe(value: string): boolean
	if type(value) ~= "string" then
		return false
	end
	for _, code in utf8.codes(value) do
		if code < 32 or code > 126 then
			return false
		end
	end
	return true
end

function UITheme.color(token: string): Color3
	local hex = palette[token]
	if hex == nil then
		hex = world[token]
	end
	if hex == nil then
		error("Unknown color token: " .. token, 2)
	end
	return Color3.fromHex(hex)
end

function UITheme.resolveMotion(name: string, reduced: boolean): MotionPlan
	local event = UITheme.motion[name]
	if event == nil then
		error("Unknown motion: " .. name, 2)
	end
	local plan: MotionPlan = {
		duration = event.duration,
		allowOffset = event.kind == "slide" or event.kind == "fadeSlide" or event.kind == "float",
		allowScale = event.kind == "scale",
		allowFloat = event.kind == "float",
		allowCount = event.kind == "count",
	}
	if not reduced then
		return plan
	end
	if event.kind == "slide" or event.kind == "scale" or event.kind == "float" or event.kind == "count" then
		plan.duration = 0
		plan.allowOffset = false
		plan.allowScale = false
		plan.allowFloat = false
		plan.allowCount = false
		return plan
	end
	if event.kind == "fadeSlide" then
		plan.duration = math.min(event.duration, UITheme.reducedMotion.maxFade)
		plan.allowOffset = false
		return plan
	end
	plan.duration = math.min(event.duration, UITheme.reducedMotion.maxFade)
	return plan
end

return UITheme
