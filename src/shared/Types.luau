--!strict

export type CryptidSource = "starter" | "rift" | "wild" | "pedlar"

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
	settings: {
		reducedMotion: boolean,
		bindAtOnce: boolean,
	},
	shop: {
		lastRotationId: number,
		boughtSlots: { boolean },
	},
	base: {
		defences: { [number]: string },
	},
	skills: { string },
}

return {}
