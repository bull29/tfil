local MV = debug.getregistry().CMoveData
local bit = bit

function MV:RemoveKey( keys )
	self:SetButtons( bit.band( self:GetButtons(), bit.bnot( keys ) ) )
end
