

--[[-------------------------------------------------------------------------
 		FullTick - For something you'd rather not use a timer for
---------------------------------------------------------------------------]]

GM.f_NextTick = CurTime()

function GM:Tick()
	if self.f_NextTick <= CurTime() then
		self.f_NextTick = CurTime() + 1
		hook.Call( "fTick", GAMEMODE )
	end
end

function GM:OnGamemodeLoaded()
	GAMEMODE, GM = gmod.GetGamemode(), gmod.GetGamemode()
end

function GM:GetFallDamage( Player )
	return 4
end
