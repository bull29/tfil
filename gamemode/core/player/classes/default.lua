local PLAYER = {}

PLAYER.DisplayName = "Lava Base Class"
PLAYER.WalkSpeed = 150
PLAYER.RunSpeed = 250
PLAYER.CrouchedWalkSpeed = 0.2
PLAYER.JumpPower = 250
PLAYER.MaxHealth = 5
PLAYER.StartHealth = 5
PLAYER.TeammateNoCollide = false

function PLAYER:Spawn()
	self.Player:SetModel(("models/player/Group01/male_0<??>.mdl"):fill(math.random(1, 9)))
	self.Player:SetPlayerColor(Vector((1):random(255) / 255, (1):random(255) / 255, (1):random(255) / 255))
	self.Player:SetupHands()
end

player_manager.RegisterClass("lava_default", PLAYER, "player_default" )
