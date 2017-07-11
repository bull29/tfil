local GetGlobalFloat = GetGlobalFloat
local Lava = Lava or {}

Lava.SetLevel = function( n ) Lava.CurrentLevel = n end
Lava.ShiftLevel = function( n )	Lava.CurrentLevel = Lava.CurrentLevel + n end
Lava.StartingLevel = false
Lava.CurrentLevel = -32768
Lava.GetLevel = function()
	return CLIENT and GetGlobalFloat("$lavalev", -32768 ) or SERVER and Lava.CurrentLevel
end


_G.Lava = Lava