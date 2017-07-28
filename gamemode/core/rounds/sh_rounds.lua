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

if CLIENT then
	local OldState

	hook.Add("Tick", "CallClientsideRoundHooks", function()
		if not OldState then
			OldState = Rounds.GetState()
		end

		if OldState ~= Rounds.GetState() then
			if OldState == "Started" then
				hook.Call("Lava.PostRound")
			elseif OldState == "Ended" then
				hook.Call("Lava.PreroundStart")
			elseif OldState == "PreroundStart" then
				hook.Call("Lava.RoundStart")
			end
			OldState = Rounds.GetState()
		end
	end)
end
	