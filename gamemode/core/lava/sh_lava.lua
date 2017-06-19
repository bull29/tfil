if SERVER then include("sv_lavamaps.lua") end

local GetGlobalFloat = GetGlobalFloat

local Lava = {}

Lava.CurrentLevel = SERVER and GM.ReadLavaData() or CLIENT and -10000
Lava.SetLevel = function( n ) Lava.CurrentLevel = n end
Lava.ShiftLevel = function( n )	Lava.CurrentLevel = Lava.CurrentLevel + n end
Lava.GetLevel = function()
	return CLIENT and GetGlobalFloat("$lavalev", -10000 ) or SERVER and Lava.CurrentLevel
end

_G.Lava = Lava