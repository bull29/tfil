
function GM:PlayerSpawn(Player)
	if Rounds.CurrentState ~= "Preround" then
		return Player:KillSilent()
	end
	hook.Call( "ChoosePlayerClass", GAMEMODE, Player )
	player_manager.OnPlayerSpawn( Player )
	player_manager.RunClass( Player, "Spawn" )
	hook.Call( "PlayerSetModel", GAMEMODE, Player )
	hook.Call( "PlayerLoadout", GAMEMODE, Player )
	hook.Call("Lava.PostPlayerSpawn", nil, Player )
	Player:Extinguish()
end

function GM:ChoosePlayerClass( Player )
	player_manager.SetPlayerClass( Player, "lava_default" )
end

function GM:PlayerLoadout( Player )
	Player:Give("lava_fists")
end

function GM:PlayerSetModel( Player )
	Player:SetModel(("models/player/Group01/male_0${1}.mdl"):fill(math.random(1, 9)))
	Player:SetPlayerColor(Vector((1):random(255) / 255, (1):random(255) / 255, (1):random(255) / 255))
	Player:SetupHands()
end

function GM:PlayerInitialSpawn( Player )
end