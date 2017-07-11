

local ENT = debug.getregistry().Entity

function ENT:SetProperVar( type, key, value, legacy )
	if self[ "GetNW" .. ( legacy and "" or "2") ..type ]( self, key, nil ) ~= value then
		self[ "SetNW" .. ( legacy and "" or "2")  .. type ]( self, key, value )
	end
end

if CLIENT then return end
