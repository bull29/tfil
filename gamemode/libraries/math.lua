local Lerp = Lerp
local FrameTime = FrameTime

function math.lerp(n, to, val)
	val = val or FrameTime() * 3

	return Lerp(val, n, to)
end

debug.setmetatable(-1, {
	__index = math
})