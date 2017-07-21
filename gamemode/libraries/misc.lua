local MV = debug.getregistry().CMoveData
local bit = bit
local timer = timer
local FrameTime = FrameTime

function MV:RemoveKey( keys )
	self:SetButtons( bit.band( self:GetButtons(), bit.bnot( keys ) ) )
end

function FrameDelay( func )
	timer.Simple( FrameTime()*2, func )
end