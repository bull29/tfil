

--[[-------------------------------------------------------------------------
		Since we're not relying on any base gamemodes
---------------------------------------------------------------------------]]
DEVMODE = false

if DEVMODE then
	for Hook in pairs( hook.GetTable() ) do
		hook.Flush( Hook )
	end

	function GM:PlayerNoClip()
		return true
	end
end