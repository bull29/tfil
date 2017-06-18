
function GM:PlayerSpawn(Player)
	Player:SetMaxHealth( 5 )
	Player:SetHealth( 5 )
	Player:SetModel(("models/player/Group01/male_0<??>.mdl"):fill(math.random(1, 9)))
	Player:SetupHands()
	Player:SetPlayerColor(Vector((1):random(255) / 255, (1):random(255) / 255, (1):random(255) / 255))
end