

local ENT = debug.getregistry().Entity

function ENT:SetProperVar( type, key, value )
	if self[ "GetNW2"..type ]( self, key, nil ) ~= value then
		self[ "SetNW2" .. type ]( self, key, value )
	end
end