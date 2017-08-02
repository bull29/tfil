local math = math
local m_NextfTick = CurTime()

function GM:Tick()
	if m_NextfTick <= CurTime() then
		m_NextfTick = CurTime() + 1
		hook.Call( "Lava.FullTick" )
	end
end

function GM:OnGamemodeLoaded()
	GAMEMODE, GM = gmod.GetGamemode(), gmod.GetGamemode()
end

function CalculateBaseFallDamage( Speed )
	return math.max( 15, math.ceil( 0.2418*Speed - 141.75 )*2 )
end

function GM:GetFallDamage( Player, Speed )
	return CalculateBaseFallDamage( Speed )
end

function GM:PlayerCanPickupWeapon( Player, Weapon )
	return Weapon:GetClass() == "lava_fists"
end

function GM:GetTeamColor( Entity )
	if Entity.PlayerColor then
		return Entity:PlayerColor()
	end
	return Color( 255, 255, 255 )
end 