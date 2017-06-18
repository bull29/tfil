
function GM:PlayerSpawn(Player)
	hook.Call( "ChoosePlayerClass", GAMEMODE, Player )
end

function GM:ChoosePlayerClass( Player )
	player_manager.SetPlayerClass( Player, "lava_default" )
end