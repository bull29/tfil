

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

