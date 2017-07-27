DefaultGravity = DefaultGravity or GetConVar("sv_gravity"):GetInt()

Mutators.RegisterNewEvent("Moon men", "Server Gravity is extremely low. All the high-jumping abilities become suddenly useful.", function()
	RunConsoleCommand("sv_gravity", 200 )
end, function()
	RunConsoleCommand("sv_gravity", DefaultGravity )
end)