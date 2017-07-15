local Lerp = Lerp
local FrameTime = FrameTime

function math.lerp(n, to, val)
	val = val or FrameTime() * 3

	return Lerp(val, n, to)
end

function math.NormalizedInt( n, onNeg, onPos )
	return n == 0 and 0 or n < 0 and (onNeg or -1) or (onPos or 1)
end

function math.inrange( n, min, max )
	return n >= min and n <= max
end

debug.setmetatable(-1, {
	__index = math
})