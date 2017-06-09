

--[[-------------------------------------------------------------------------
		Since we're not relying on any base gamemodes
---------------------------------------------------------------------------]]

for Hook in pairs( hook.GetTable() ) do
	hook.Flush( Hook )
end