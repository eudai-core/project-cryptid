--!strict

export type CryptidSource = "starter" | "rift" | "wild" | "pedlar" | "offering"

export type EffectsQuality = "High" | "Medium" | "Low"

export type CryptidRecord = {
	speciesId: string,
	mutation: string,
	traits: { string },
	acquiredAt: number,
	source: CryptidSource,
}

export type OnboardingState = {
	step: number,
	starterGranted: boolean,
	skipped: boolean,
	playSeconds: number,
}

export type Profile = {
	dataVersion: number,
	cash: number,
	totalEarned: number,
	padsUnlocked: number,
	pads: { [string]: string },
	cryptids: { [string]: CryptidRecord },
	upgrades: {
		boneAltar: number,
	},
	onboarding: OnboardingState,
	firstJoinUnix: number,
	lastSeenUnix: number,
	tithe: number,
	bowl: number,
	offline: {
		rate: number,
		rateNoPass: number,
		pending: number,
		pendingTithe: number,
		awaySeconds: number,
		capped: boolean,
		notice: number,
	},
	daily: {
		step: number,
		lastClaimDay: number,
		totalClaims: number,
	},
	settings: {
		reducedMotion: boolean,
		bindAtOnce: boolean,
		sfx: number,
		music: number,
		effectsQuality: EffectsQuality,
	},
	shop: {
		lastRotationId: number,
		boughtSlots: { boolean },
	},
	base: {
		defences: { [number]: string },
	},
}

return {}
