local Player = debug.getregistry().Player
local Color = debug.getregistry().Color
local util = util
local setmetatable = setmetatable
local CurTime = CurTime

function Player:EyeEntity()
	return self:GetEyeTrace().Entity
end

function Player:EyeVector()
	return self:GetEyeTrace().HitPos
end

function Player:TeamColor()
	return team.GetColor( self:Team() )
end

function Player:CheckHullCollision()
	local tR = util.TraceHull{
		filter = self,
		start = self:GetPos(),
		endpos = self:GetPos(),
		mins = self:OBBMins(),
		maxs = self:OBBMaxs(),
	}

	if self:GetMoveType() ~= 9 and not self:HasAbility("Casper") and tR.Entity and (tR.Entity:IsWorld() or IsValid(tR.Entity) or tR.StartSolid or tR.AllSolid ) then
		return tR
	end

	return false
end

function Player:IsLavaCreator()
	return self:SteamID64() == "76561198045139792" or self:SteamID64() == "76561198240703932"
end

function Player:PlayerColor()
	return setmetatable( self:GetPlayerColor():ToColor(), Color )
end

function Player:EmojiID()
	return util.CRC((self:Nick() or 1566124349)) % #Emoji.Index
end

function Player:KeyHoldNoSpam( key, mcdata, delay )
	delay = delay or 0.5
	self[ "m_LastKeyHoldTime" .. key ] = self[ "m_LastKeyHoldTime" .. key ] or CurTime()
	if self[ "m_LastKeyHoldTime" .. key ] < CurTime() and mcdata:KeyDown( key ) then
		self[ "m_WasKeyDown" .. key ] = true
		return true
	elseif not mcdata:KeyDown( key ) and self[ "m_WasKeyDown" .. key ] then
		self[ "m_LastKeyHoldTime" .. key ] = CurTime() + delay
		self[ "m_WasKeyDown" .. key ] = nil
	end
	return false
end

function Player:KeyPressedNoSpam( key, mcdata, delay )
	delay = delay or 0.5
	self[ "m_LastKeyPressTime" .. key ] = self[ "m_LastKeyPressTime" .. key ] or CurTime()
	if not self[ "m_HasPressedKeyLast" .. key ] and self[ "m_LastKeyPressTime" .. key ] < CurTime() and mcdata:KeyDown( key ) then
		self[ "m_LastKeyPressTime" .. key ] = CurTime() + delay
		self[ "m_HasPressedKeyLast" .. key ] = true
		return true
	elseif not mcdata:KeyDown( key ) then
		self[ "m_HasPressedKeyLast" .. key ] = nil
	end
	return false
end

local player = player
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