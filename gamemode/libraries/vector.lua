

local Vec = debug.getregistry().Vector
local Vector = Vector

function Vec:SetX( n, alter )
	if not alter then
		return Vector( n, self.y, self.z )
	end
	self.x = n
	return self
end

function Vec:SetY( n, alter )
	if not alter then
		return Vector( self.x, n, self.z )
	end
	self.y = n
	return self
end

function Vec:SetZ( n, alter )
	if not alter then
		return Vector( self.x, self.y, n )
	end
	self.z = n
	return self
end
