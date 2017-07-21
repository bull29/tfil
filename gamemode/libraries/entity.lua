

local ENT = debug.getregistry().Entity

function ENT:SetProperVar( type, key, value, legacy )
	if self[ "GetNW" .. ( legacy and "" or "2") ..type ]( self, key, nil ) ~= value then
		self[ "SetNW" .. ( legacy and "" or "2")  .. type ]( self, key, value )
	end
end

function ENT:GetPhysicsBone( name )
	local c = self:TranslateBoneToPhysBone( self:LookupBone( name ) )
	if not c then return end
	return self:GetPhysicsObjectNum( c )
end

function ENT:DumpSequences()
	for i = 1, self:GetSequenceCount() do
		print( i, self:GetSequenceName( i ), self:GetSequenceActivity( i ))
	end
end

function ENT:DumpBones()
	for i = 1, self:GetBoneCount() do
		print( i, self:GetBoneName( i ) )
	end
end

if SERVER then return end

function SpectatingPlayer()
	if not LocalPlayer():Alive() and LocalPlayer():GetObserverMode() ~= 0 and LocalPlayer():GetObserverMode() ~= 6 then
		return LocalPlayer():GetObserverTarget()
	end
	return false
end