--!strict

export type SeededRng = {
	nextInt: (self: SeededRng, min: number, max: number) -> number,
}

local SeededRng = {}

local function mix(seed: number): number
	local word = bit32.bxor(bit32.band(seed, 0xFFFFFFFF), 0x6C8E9CF5)
	if word == 0 then
		word = 0xA5A5A5A5
	end
	return word
end

local function step(state: number): number
	local nextState = bit32.bxor(state, bit32.lshift(state, 13))
	nextState = bit32.bxor(nextState, bit32.rshift(nextState, 17))
	nextState = bit32.bxor(nextState, bit32.lshift(nextState, 5))
	return nextState
end

function SeededRng.new(seed: number): SeededRng
	local state = mix(seed)
	local rng = {}
	function rng:nextInt(min: number, max: number): number
		local span = max - min + 1
		if span <= 1 then
			return min
		end
		local limit = math.floor(4294967296 / span) * span
		state = step(state)
		while state >= limit do
			state = step(state)
		end
		return min + (state % span)
	end
	return rng :: SeededRng
end

return SeededRng
