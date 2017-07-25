
local cmeta = debug.getregistry().Color
local ma = math.Approach
local lp = Lerp
local Color = Color
local LastPlayerColor = Vector( 0, 0, 0 )
local cLastPlayerColor = Color( 0, 0, 0 )
local LocalPlayer = LocalPlayer

function cmeta:clamp()
	self.r = self.r:max( 0 )
	self.g = self.g:max( 0 )
	self.b = self.b:max( 0 )
	self.a = self.a:max( 0 )
	return self
end

function cmeta.__unm(s)
	return Color(255 - s.r, 255 - s.g, 255 - s.b, s.a):clamp()
end

function cmeta.__add(a, b)
	if type(b) == 'number' then
		return Color(a.r + b, a.g + b, a.b + b, a.a):clamp()
	elseif b.b then
		return Color(a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a):clamp()
	end
end

function cmeta.__sub(a, b)
	if type(b) == 'number' then
		return Color(a.r - b, a.g - b, a.b - b, a.a):clamp()
	elseif b.b then
		return Color(a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a):clamp()
	end
end

function cmeta.__mul (a, b)
	if type(b) == 'number' then
		return Color(a.r* b, a.g* b, a.b* b, a.a):clamp()
	elseif b.b then
		return Color(a.r* b.r, a.g *b.g, a.b* b.b, a.a* b.a):clamp()
	end
end

function cmeta:Approach(b, n)
	return Color(ma(self.r, b.r, n), ma(self.g, b.g, n), ma(self.b, b.b, n), ma(self.a, b.a, n))
end

function cmeta:Lerp(b, n)
	return Color(lp(n, self.r, b.r), lp(n, self.g, b.g), lp(n, self.b, b.b), lp(n, self.a, b.a))
end

function cmeta:Alpha(n)
	return Color(self.r, self.g, self.b, n)
end

function cmeta:CopyFrom( source )
	self.r = source.r
	self.g = source.g
	self.b = source.b
	self.a = source.a
end

function pColor( NoSpectate )
	if SpectatingPlayer() and not NoSpectate then
		return SpectatingPlayer():GetPlayerColor():ToColor()
	end

	local x = LocalPlayer():GetPlayerColor()
	if x ~= LastPlayerColor then
		LastPlayerColor = x
		cLastPlayerColor = Color( x.r*255, x.g*255, x.b*255)
	end
	return cLastPlayerColor
end