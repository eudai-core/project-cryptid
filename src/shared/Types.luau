--!strict

export type CryptidSource = "starter" | "rift" | "wild" | "pedlar" | "offering" | "relic"

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
	purchases: {
		ledger: { [string]: { productId: number, grantedAt: number, grants: { string } } },
		ritesOwned: { [string]: boolean },
		quotes: { [string]: { amount: number, expiresAt: number } },
		firstPurchaseAt: number?,
		starterPackClaimed: boolean,
	},
	cosmetics: {
		owned: { [string]: boolean },
	},
	giftedPasses: { [string]: { fromUserId: number, purchaseId: string } },
	giftsReceived: { [string]: boolean },
	tarot: {
		tokens: { pale: number, blood: number },
		pity: { pale: number, blood: number },
		marks: { [string]: number },
		milestonesClaimed: { [string]: boolean },
	},
	bloodMoon: {
		boughtToday: { utcDay: number, count: number },
	},
	ui: {
		relicsPipShown: boolean,
		relicsPipCleared: boolean,
	},
	cashDouble: boolean,
	autoCollect: boolean,
	passes: {
		extraPads: boolean,
		lairCosmetics: boolean,
		sigilNameplate: boolean,
	},
}

return {}
