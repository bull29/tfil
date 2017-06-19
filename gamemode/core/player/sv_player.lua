
function GM:PlayerSpawn(Player)
	hook.Call( "ChoosePlayerClass", GAMEMODE, Player )
	player_manager.OnPlayerSpawn( Player )
	player_manager.RunClass( Player, "Spawn" )
end

function GM:ChoosePlayerClass( Player )
	player_manager.SetPlayerClass( Player, "lava_default" )
end
