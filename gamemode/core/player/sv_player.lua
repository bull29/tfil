
function GM:PlayerSpawn(Player)
	if Player.m_ShouldSpawnAsSpectator then
		Player.m_ShouldSpawnAsSpectator = nil
		return Player:KillSilent()
	end
	hook.Call( "ChoosePlayerClass", GAMEMODE, Player )
	player_manager.OnPlayerSpawn( Player )
	player_manager.RunClass( Player, "Spawn" )
	hook.Call( "PlayerSetModel", GAMEMODE, Player )
	hook.Call( "PlayerLoadout", GAMEMODE, Player )
	hook.Call("Lava.PostPlayerSpawn", nil, Player )
	Player:Extinguish()
	Player:SetCustomCollisionCheck( true )
	Player:CollisionRulesChanged()
end

function GM:ChoosePlayerClass( Player )
	player_manager.SetPlayerClass( Player, "lava_default" )
end

function GM:PlayerLoadout( Player )
	Player:Give("lava_fists")
end

local function ProcessColor( Player )

	local Prefered = Player:GetInfo( "lava_player_color" )
	local Fallback = Vector((1):random(255) / 255, (1):random(255) / 255, (1):random(255) / 255)

	if Prefered ~= "random" then
		Prefered = Prefered:Split( "_" )
		for i = 1, 3 do
			local n = tonumber( Prefered[ i ] )
			if not n or n > 255 or n < 0 then
				return Fallback
			end
			return Vector( Prefered[ 1 ] / 255, Prefered[ 2 ] / 255, Prefered[ 3 ] / 255 )
		end
	end

	return Fallback
end

function GM:PlayerSetModel( Player )
	if Player:IsLavaCreator() then
		Player:SetModel( "models/player/monk.mdl" )
	else
		Player:SetModel(("models/player/Group01/male_0${1}.mdl"):fill(math.random(1, 9)))
	end
	Player:SetPlayerColor( ProcessColor( Player ) )
	Player:SetupHands()
end

function GM:PlayerInitialSpawn( Player )
	if Rounds.CurrentState ~= "Preround" then
		Player.m_ShouldSpawnAsSpectator = true
	end
end