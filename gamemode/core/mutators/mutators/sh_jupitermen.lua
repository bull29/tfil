
Mutators.RegisterNewEvent("Jupiter Men", "Gravity is extremely high. Missteps are fatal. Jumping is infeasible.", function()
	if SERVER then
		RunConsoleCommand("sv_gravity", 2048 )
	end
end, function()
	if SERVER then
		RunConsoleCommand("sv_gravity", 600 )
	end
end)