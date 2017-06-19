local Ang = debug.getregistry().Angle

function Ang:SetPitch(n, alter)
	if not alter then return Angle(n, self.y, self.r) end
	self.p = n
end

function Ang:SetYaw(n, alter)
	if not alter then return Angle(self.p, n, self.r) end
	self.y = n
end

function Ang:SetRoll(n, alter)
	if not alter then return Angle(self.p, self.y, n) end
	self.r = n
end