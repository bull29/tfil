if SERVER then
	include( "sv_rounds.lua" )
end

Rounds = SERVER and Rounds or {}

function Rounds.GetState()
	return SERVER and Rounds.CurrentState or CLIENT and GetGlobalString("$RoundState", "Preround")
end

function Rounds.IsState( query )
	return Rounds.GetState():lower() == query:lower()
end