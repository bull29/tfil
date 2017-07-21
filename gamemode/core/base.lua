local math = math

function GM:OnGamemodeLoaded()
	GAMEMODE, GM = gmod.GetGamemode(), gmod.GetGamemode()
end

function CalculateBaseFallDamage( Speed )
	return math.max( 15, math.ceil( 0.2418*Speed - 141.75 )*2 )
end

function GM:GetFallDamage( Player, Speed )
	return CalculateBaseFallDamage( Speed )
end