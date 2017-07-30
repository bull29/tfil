local Player = debug.getregistry().Player
local Color = debug.getregistry().Color
local setmetatable = setmetatable

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
	return setmetatable( self:GetPlayerColor():ToColor(), Color )
end

function Player:EmojiID()
	return util.CRC((self:Nick() or 1566124349)) % #Emoji.Index
end

local player = player
local pairs = pairs
local table = table

function player.GetAlive()
	local tab = {}
	for Player in Values( player.GetAll() ) do
		if Player:Alive() then
			table.insert( tab, Player )
		end
	end
	return tab
end

function player.GetSpectators()
	local tab = {}
	for Player in Values( player.GetAll() ) do
		if not Player:Alive() then
			table.insert( tab, Player )
		end
	end
	return tab
end

player.GetDead = player.GetSpectators