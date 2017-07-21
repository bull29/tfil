
function GM:PlayerSpawn(Player)
	hook.Call( "ChoosePlayerClass", GAMEMODE, Player )
	player_manager.OnPlayerSpawn( Player )
	player_manager.RunClass( Player, "Spawn" )
	hook.Call( "PlayerSetModel", GAMEMODE, Player )
	hook.Call( "PlayerLoadout", GAMEMODE, Player )
	hook.Call("Lava.PostPlayerSpawn", nil, Player )
end

function GM:ChoosePlayerClass( Player )
	player_manager.SetPlayerClass( Player, "lava_default" )
end

function GM:PlayerLoadout( Player )
	Player:Give("lava_fists")
end