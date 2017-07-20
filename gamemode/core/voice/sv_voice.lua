function GM:PlayerCanHearPlayersVoice()
	return true
end

hook.Add("Lava.PostPlayerSpawn", "SetFlexesForVoice", function( Player )
	Player:SetFlexScale( 1 )
end)