local PLAYER = {}

PLAYER.DisplayName = "Lava Base Class"
PLAYER.WalkSpeed = 150
PLAYER.RunSpeed = 250
PLAYER.CrouchedWalkSpeed = 0.2
PLAYER.JumpPower = 250
PLAYER.MaxHealth = 100
PLAYER.StartHealth = 100
PLAYER.TeammateNoCollide = false

function PLAYER:Spawn()
	self.Player:SetDuckSpeed( 0.2 )
	self.Player:SetUnDuckSpeed( 0.1 )
	self.Player:SetModelScale( 1, 0 )
	self.Player:SetModel(("models/player/Group01/male_0${1}.mdl"):fill(math.random(1, 9)))
	self.Player:SetPlayerColor(Vector((1):random(255) / 255, (1):random(255) / 255, (1):random(255) / 255))
	self.Player:SetupHands()
	self.Player:SetViewOffset( Vector( 0, 0, 64 ))
	self.Player:SetViewOffsetDucked( Vector( 0, 0, 28 ))
end

player_manager.RegisterClass("lava_default", PLAYER, "player_default" )