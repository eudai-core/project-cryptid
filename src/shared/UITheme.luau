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
	MossText = "8FAE78",
	TarnishedSilver = "8C9AA3",
	LightAmbient = "322848",
	LightOutdoor = "51426E",
})

local world = table.freeze({
	Candle = "FFB36B",
	Ambient = "2C2622",
	OutdoorAmbient = "221E1B",
	Floor = "3A342F",
	Wall = "1C1917",
	Altar = "403932",
	NightSky = "140C22",
	NightMist = "6E5C9A",
	SkyTint = "F3ECFF",
	Spirit = "3EE6D4",
	FlameGreen = "39F06A",
	FlameBlue = "3C92FF",
	FlameViolet = "C45CFF",
	FlameOrange = "FF6A1A",
	FlameCrimson = "E0263A",
	Bark = "4A3024",
	ShipWood = "7B5434",
	MossCanopy = "1E7A3C",
	TentCloth = "4C2878",
	Stone = "7C7784",
	Bottle = "C8FFD8",
	MoonFace = "F3E6C8",
	MoonGlow = "F4E8FF",
})

local TOUCH_PX = 44
local GAP_PX = 8
local BANNER_PAD = 8
local BANNER_TITLE_DESKTOP = 22
local BANNER_TITLE_MOBILE = 18
local BANNER_BODY_DESKTOP = 18
local BANNER_BODY_MOBILE = 16

local function bannerHeight(titlePx: number, bodyPx: number): number
	local titleRow = math.max(titlePx * 2, TOUCH_PX)
	return BANNER_PAD + titleRow + GAP_PX + (bodyPx + 2) + GAP_PX + TOUCH_PX + BANNER_PAD
end

local PEDLAR_PREVIEW = 64
local PEDLAR_NAME = 16
local PEDLAR_PRICE = 18
local PEDLAR_INCOME = 14
local PEDLAR_CHIP = 22
local PEDLAR_CARD_H = GAP_PX * 2
	+ PEDLAR_PREVIEW
	+ PEDLAR_NAME * 2
	+ PEDLAR_CHIP
	+ PEDLAR_PRICE
	+ PEDLAR_INCOME
	+ TOUCH_PX
	+ GAP_PX * 5

local UITheme = {
	palette = palette,
	world = world,
	rarity = table.freeze({
		Common = "BoneDim",
		Uncommon = "Moss",
		Rare = "TarnishedSilver",
		Epic = "Blood",
		Legendary = "GoldBright",
		Mythic = "GoldBright",
	}),
	rarityChip = table.freeze({
		Common = table.freeze({ text = "BoneDim", fill = "Soot" }),
		Uncommon = table.freeze({ text = "MossText", fill = "Soot" }),
		Rare = table.freeze({ text = "TarnishedSilver", fill = "Soot" }),
		Epic = table.freeze({ text = "Bone", fill = "Blood" }),
		Legendary = table.freeze({ text = "GoldBright", fill = "Soot" }),
		Mythic = table.freeze({ text = "GoldBright", fill = "Soot" }),
	}),
	copy = table.freeze({
		menu = "Menu",
		calmOff = "Calm motion: Off",
		calmOn = "Calm motion: On",
		calmReason = "Holds banners, cash, and numbers still.",
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
		plaqueInsetPx = 16,
		promptLift = 5.2,
		promptPlate = table.freeze({
			w = 260,
			h = 48,
		}),
		plaqueGapPx = 8,
		goalBanner = table.freeze({
			topPx = 0,
			pad = BANNER_PAD,
			buttonH = TOUCH_PX,
			skipW = 136,
			actionMobile = 180,
			actionDesktop = 200,
			titleDesktop = BANNER_TITLE_DESKTOP,
			titleMobile = BANNER_TITLE_MOBILE,
			desktop = table.freeze({ w = 460, h = bannerHeight(BANNER_TITLE_DESKTOP, BANNER_BODY_DESKTOP) }),
			mobile = table.freeze({ w = 320, h = bannerHeight(BANNER_TITLE_MOBILE, BANNER_BODY_MOBILE) }),
		}),
		tease = table.freeze({
			pip = 16,
			pipGap = 10,
			desktop = table.freeze({ w = 420, h = 168 }),
			mobile = table.freeze({ w = 300, h = 156 }),
		}),
		plaqueBowlPx = 20,
		screenInset = 12,
		offeringPip = 8,
		relicsPip = 10,
		relicsEscape = 3001,
		escapePriority = 3000,
		busyPoll = 0.05,
		touchPx = TOUCH_PX,
		pedlar = table.freeze({
			detailsW = 120,
			leaveW = 96,
			bindW = 200,
			previewPx = PEDLAR_PREVIEW,
			previewFit = 1.6,
			previewLift = 0.4,
			namePx = PEDLAR_NAME,
			pricePx = PEDLAR_PRICE,
			incomePx = PEDLAR_INCOME,
			chipH = PEDLAR_CHIP,
			cardH = PEDLAR_CARD_H,
		}),
		hudMenu = table.freeze({
			buttonW = 88,
			sheetW = 240,
			reasonLines = 2,
		}),
		chipW = 160,
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
		relicsPanel = table.freeze({
			desktop = table.freeze({ w = 520, h = 480 }),
			mobileH = 520,
			title = 28,
			body = 16,
			detail = 14,
			cardH = 112,
			buttonW = 140,
			padW = 220,
			padH = 96,
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
		fogColor = "NightMist",
		atmosphereDensity = 0.18,
		atmosphereOffset = 0,
		atmosphereHaze = 0.3,
		atmosphereGlare = 0,
		atmosphereColor = "NightMist",
		atmosphereDecay = "NightSky",
		bloomEnabled = true,
		bloomIntensity = 0.45,
		bloomSize = 28,
		bloomThreshold = 1.5,
		colorSaturation = 0.16,
		colorContrast = 0.08,
		colorBrightness = 0.02,
		colorTint = "SkyTint",
		-- Lighting.Technology is not scriptable. default.project.json writes ShadowMap.
		technology = "ShadowMap",
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
		relicsPip = table.freeze({
			duration = 1.5,
			easing = "Quad",
			direction = "Out",
			kind = "scale" :: MotionKind,
			scale = 1.35,
			pulses = 2,
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

function UITheme.chipFor(rarity: string): { text: string, fill: string }
	local chip = UITheme.rarityChip[rarity]
	if chip == nil then
		return UITheme.rarityChip.Common
	end
	return chip
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
