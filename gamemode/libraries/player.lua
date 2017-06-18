

do return end
local Player = debug.getregistry().Player

function Player:EyeEntity()
	return self:GetEyeTrace().Entity
end

function Player:EyeVector()
	return self:GetEyeTrace().HitPos
end

function Player:TeamColor()
	return team.GetColor( self:Team() )
end

if CLIENT then return end

local string = string
local tostring = tostring

Player.o__newindex = Player.o__newindex or Player.__newindex
Player.o__index = Player.o__index or Player.__index

function Player.__index( self, b )
	if string.sub( b, 1, 3 ) == "sQ_" then
		return Player.GetPData( self, b, nil )
	end
	return Player.o__index( self, b )
end

function Player.__newindex( self, a, b )
	if string.sub( a, 1, 3 ) == "sQ_" then
		return Player.SetPData( self, a, tostring( b ) )
	end
	return Player.o__newindex( self, a, b )
end

