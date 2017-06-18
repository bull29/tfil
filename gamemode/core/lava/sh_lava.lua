if SERVER then
	include("sv_lavamaps.lua")
end

Lava = {}
Lava.CurrentLevel = SERVER and GM.ReadLavaData() or CLIENT and -10000
local Lava = Lava

Lava.GetLevel = function()
	return CLIENT and GetGlobalFloat("$lavalev", -10000 ) or SERVER and Lava.CurrentLevel
end

Lava.SetLevel = function( n )
	Lava.CurrentLevel = n
end

Lava.ShiftLevel = function( n )
	Lava.CurrentLevel = Lava.CurrentLevel + n
end


