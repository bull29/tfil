local GetGlobalFloat = GetGlobalFloat
local Lava = Lava or {}

Lava.SetLevel = function( n ) Lava.CurrentLevel = n end
Lava.ShiftLevel = function( n )	Lava.CurrentLevel = Lava.CurrentLevel + n end
Lava.GetLevel = function()
	return CLIENT and GetGlobalFloat("$lavalev", -10000 ) or SERVER and Lava.CurrentLevel
end

if CLIENT then
	Lava.CurrentLevel = -10000
end

_G.Lava = Lava