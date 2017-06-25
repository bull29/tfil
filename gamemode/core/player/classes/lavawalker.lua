local pScale = 0.5
local player_manager = player_manager
local PLAYER = {}

PLAYER.DisplayName = "Lava Walker"
PLAYER.WalkSpeed = 150*pScale*1.2
PLAYER.RunSpeed = 250*pScale*1.2
PLAYER.CrouchedWalkSpeed = 0.2
PLAYER.JumpPower = 250*pScale*1.2
PLAYER.MaxHealth = 1
PLAYER.StartHealth = 1	
PLAYER.TeammateNoCollide = false

function PLAYER:Spawn()
	self.Player:SetModel("models/player/skeleton.mdl")
	self.Player:SetPlayerColor( Vector( 0, 0, 0 )  )
	self.Player:SetupHands()
	self.Player:SetModelScale( pScale, 0 )
	self.Player:SetViewOffset( (Vector( 0, 0, 64 ) * pScale) + Vector( 0, 0, 1.5 ) )
	self.Player:SetViewOffsetDucked( (Vector( 0, 0, 28 ) * pScale)  + Vector( 0, 0, 1.5 ) )
end

player_manager.RegisterClass("lava_walker", PLAYER, "lava_default" )


hook.Add("SetupMove", "Lavawalkers",function( Player, MoveData, Command )
	if player_manager.GetPlayerClass( Player ) == "lava_walker" then
		Player:SetGravity( 0.0001 )
		MoveData:SetOrigin( Player:GetPos():SetZ( Lava.GetLevel() -	 1 ) )
		MoveData:SetVelocity( MoveData:GetVelocity():SetZ( 0 ))
			Player:SetGroundEntity( Entity( 0 ) )
	elseif Player:GetGravity() ~= 1 then
		Player:SetGravity( 1 )
	end
end)

hook.Add("PlayerRender", "FixLavawalkerJitter", function( Player )
	if player_manager.GetPlayerClass( Player ) == "lava_walker" then
		
	end
end)