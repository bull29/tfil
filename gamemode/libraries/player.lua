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

function Player:PlayerColor()
	return self:GetPlayerColor():ToColor()
end

local player = player
local pairs = pairs

function player.GetAlive()
	local tab = player.GetAll()
	for Index, Player in pairs( tab ) do
		if not Player:Alive() then
			tab[ Index ] = nil
		end
	end
	return tab
end