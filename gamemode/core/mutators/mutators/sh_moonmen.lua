Mutators.RegisterNewEvent("Moon men", "Server Gravity is extremely low. All the high-jumping abilities become suddenly useful.", function()
	if SERVER then
		RunConsoleCommand("sv_gravity", 200 )
	end
end, function()
	if SERVER then
		RunConsoleCommand("sv_gravity", 600 )
	end
end)