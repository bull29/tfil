local pScale = 0.5
local player_manager = player_manager
local PLAYER = {}

PLAYER.DisplayName = "Lava Walker"
PLAYER.WalkSpeed = 150 * pScale * 1.2
PLAYER.RunSpeed = 250 * pScale * 1.2
PLAYER.CrouchedWalkSpeed = 0.2
PLAYER.JumpPower = 250 * pScale * 1.2
PLAYER.MaxHealth = 1
PLAYER.StartHealth = 1
PLAYER.TeammateNoCollide = false

function PLAYER:Spawn()
	self.Player:SetModel("models/player/skeleton.mdl")
	self.Player:SetPlayerColor(Vector(0, 0, 0))
	self.Player:SetupHands()
	self.Player:SetModelScale(pScale, 0)
	self.Player:SetViewOffset((Vector(0, 0, 64) * pScale) + Vector(0, 0, 1.5))
	self.Player:SetViewOffsetDucked((Vector(0, 0, 28) * pScale) + Vector(0, 0, 1.5))
end

player_manager.RegisterClass("lava_walker", PLAYER, "lava_default")

debug.getregistry().Player.IsLavaSurfer = function( self )
	return player_manager.GetPlayerClass(self) == "lava_walker"
end

hook.Add("SetupMove", "Lavawalkers", function(Player, MoveData, Command)
	if Player:IsLavaSurfer() then
		Player.WasLavaSurfer = true
		if MoveData:GetOrigin().z < Lava.GetLevel() then
			Player:SetMoveType(MOVETYPE_FLY)
			Player:SetGravity(0.001)
			Player:SetGroundEntity(Entity(0))
			MoveData:SetOrigin(Player:GetPos():SetZ(Lava.GetLevel() + 2))
			if MoveData:KeyDown(2) then
				local AimVec = Player:GetAimVector()
				AimVec.z = AimVec.z:max( 0.2 )
				MoveData:SetVelocity(AimVec * 600)
			end
		elseif not Player:OnGround() then
			Player:SetGravity(1)
			Player:SetMoveType(MOVETYPE_FLYGRAVITY)
		else
			Player:SetMoveType( 2 )
		end
	elseif Player.WasLavaSurfer then
		Player.WasLavaSurfer = nil
		Player:SetGravity(1)
		Player:SetMoveType( 2 )
	end
end)

hook.Add("PlayerRender", "FixLavawalkerJitter", function(Player)
	if Player:IsLavaSurfer() then
		if not Player.LavaSurfboard or not Player.LavaSurfboard:IsValid() then
			Player.LavaSurfboard = ClientsideModel("models/xqm/hoverboard.mdl")
			Player.LavaSurfboard:SetModelScale(0.5, 0)
			Player.LavaSurfboard:SetAngles(Player:GetAngles() + Angle(0, 90, 0))
			Player.LavaSurfboard:SetParent(Player, 4)
			Player.LavaSurfboard:SetPos(Player:GetPos() + Vector(0, 0, -24))

			Player.LavaSurfboard.RenderOverride = function( self )
				if not self:GetParent():IsValid() or not self:GetParent():IsLavaSurfer() then
					self:Remove()
					return
				end
				self:DrawModel()
			end
		end


		if Player:OnGround() then
			Player.LavaSurfboard:SetNoDraw( true )
		else
			Player:SetRenderAngles(Player:GetAngles():SetPitch(EyeAngles().p))
			Player.LavaSurfboard:SetNoDraw( false )
		end
		
		Player:DrawModel()

		return true
	end
end)

hook.Add("CalcMainActivity", "LavaSurferConst", function(Player, Velocity)
	if Player:IsLavaSurfer() and not Player:OnGround() then return ACT_MP_JUMP, -1 end
end)

hook.Add("Lava.CanClimb","DisableSurfClimb", function( Player )
	if Player:IsLavaSurfer() then return false end
end)

hook.Add("Lava.ShouldTakeLavaDamage", "DisableSurferDamage", function( Player )
	if Player:IsLavaSurfer() then return false end
end )

hook.Add("Lava.ShouldRenderDamageOverlay", "DisableSurferOverlay",function()
	if LocalPlayer():IsLavaSurfer() then return false end
end)

hook.Add("Lava.DeathThink", "LavaWalkerDeath",function( Player )
	--[[ if not Player:Alive() and Rounds.CurrentState ~= "Preround" then
		Player.ShouldBecomeWalker = true
		return true
	end--]] 
end)

hook.Add( "PlayerUse", "DisableSurferInteraction", function( Player, ent )
	if Player:IsLavaSurfer() then
		return false
	end
end)

hook.mAdd( { "Lava.PreroundStart", "Lava.RoundStart" }, "ResetSurfers",function()
	for Player in Values( player.GetAll() ) do
		Player.ShouldBecomeWalker = nil
	end
end)

hook.Add("ChoosePlayerClass", "LavaWalker", function( Player )
	if Player.ShouldBecomeWalker then
		Player.ShouldBecomeWalker = nil
		player_manager.SetPlayerClass( Player, "lava_walker" )
		return true
	end
end )

hook.Add("Lava.RoundStart", "RespawnSurfers", function()
	for Player in Values( player.GetAll() ) do
		if Player:IsLavaSurfer() then
			Player:Spawn()
		end
	end
end)

local drawColor = DrawColorModify
local bTab = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 0,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

hook.Add("RenderScreenspaceEffects", "DrawSurferOverlay", function()
	if LocalPlayer():IsLavaSurfer() then
		drawColor( bTab )
	end
end)