-- The following is derived from ULX's ragdoll code.
-- https://github.com/TeamUlysses/ulx/blob/master/lua/ulx/modules/sh/fun.lua

local Ragdoll = {}

function Ragdoll.Enable( Player )
	if CLIENT then return end

	if Player.m_Ragdoll then
		Player.m_Ragdoll:Remove()
		Player.m_Ragdoll = nil
	end

	if hook.Call( "Lava.PrePlayerRagdolled", nil, Player, ragdoll ) == false then return end

	Player.m_RagdollData = {
		Angles = Player:EyeAngles(),
		Model = Player:GetModel(),
		pColor = Player:GetPlayerColor(),
		Health = Player:Health(),
		Eggs = Player:GetActiveWeapon():IsValid() and Player:GetActiveWeapon():GetClass() == "lava_fists" and Player:GetActiveWeapon():GetEggs()
	}

	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll:SetPos( Player:GetPos() )
	ragdoll:SetAngles( Player:GetAngles():SetPitch( 0 ) )
	ragdoll:SetModel( Player:GetModel() )
	ragdoll:Spawn()
	ragdoll:DrawShadow(false )
	ragdoll:SetNW2Entity( "m_PlayerParent", Player )
	ragdoll:Activate()
	hook.Add("Tick", ragdoll, function()
		if not IsValid( Player ) then
			ragdoll:Remove()
		end
	end)
	for i = 0, Player:GetBoneCount() - 1 do
		local bone = ragdoll:GetPhysicsObjectNum( i )
		
		if IsValid( bone ) then
			local pos, ang = Player:GetBonePosition( ragdoll:TranslatePhysBoneToBone( i ) )
			
			if pos and ang then
				bone:SetPos( pos )
				bone:SetAngles( ang )
			end
		end
	end
	Player:SetParent( ragdoll )

	local velocity = Player:GetVelocity()
	local j = 2
	while true do -- Break inside
		local phys_obj = ragdoll:GetPhysicsObjectNum( j )

		if phys_obj then
			phys_obj:SetVelocity( velocity )
			phys_obj:EnableDrag( false )
			phys_obj:EnableGravity( false )
			j = j + 1
		else
			break
		end
	end

	Player:Spectate( OBS_MODE_CHASE )
	Player:SpectateEntity( ragdoll )
	Player:StripWeapons() -- Otherwise they can still use the weapons.
	Player.m_Ragdoll = ragdoll

	hook.Call( "Lava.PostPlayerRagdolled", nil, Player, ragdoll )
end


function Ragdoll.Disable( Player, h_DisableSpawn , force )
	if not force then
		if not Player.m_Ragdoll then return end

		local pos = Player.m_Ragdoll:GetBonePosition(1)
		local trace = util.TraceLine({
			start = Vector(pos.x, pos.y, pos.z + 65),
			endpos = Vector(pos.x, pos.y, pos.z + 5),
			mask = MASK_PLAYERSOLID_BRUSHONLY
		})

		if trace.Hit then return end
	end

	Player.m_RagdollData.Angles = Player:EyeAngles()
	Player:SetParent()
	Player:UnSpectate()
	FrameDelay(function()
		if not Player:IsValid() or not IsValid( Player.m_Ragdoll ) then return end
		Player:SetPos( Player.m_Ragdoll:GetBonePosition( 1 ) + Vector( 0, 0, 5 ))
		Player:Extinguish()
		Player.m_Ragdoll:Remove()
		Player.m_Ragdoll = nil
		if Player.m_RagdollData.Eggs then
			Player:GetActiveWeapon():SetEggs( Player.m_RagdollData.Eggs )
		end
		Player:SetHealth( Player.m_RagdollData.Health )
	end)

	if not h_DisableSpawn then
		Player:Spawn()
		Player:SetEyeAngles( Player.m_RagdollData.Angles )
		Player:SetPlayerColor( Player.m_RagdollData.pColor )
		Player:SetModel( Player.m_RagdollData.Model )
		Player:SetVelocity( Player.m_Ragdoll:GetVelocity() )
		Player:SetPos( Player.m_Ragdoll:GetBonePosition( 1 ) + Vector( 0, 0, 5 ))
	end
end

hook.Add("NetworkEntityCreated", "ExposeRagdoll", function( ent )
	if IsValid( ent ) and ent:GetClass() == "prop_ragdoll" and ent:GetNW2Entity( "m_PlayerParent", NULL ):IsValid() then
		ent.m_Player = ent:GetNW2Entity( "m_PlayerParent", NULL )
		ent.m_Player.m_Ragdoll = ent
		ent:DestroyShadow()
		ent:SnatchModelInstance( ent.m_Player )
		ent.GetPlayerColor = function( self )
			if not self:IsValid() then return end
			return self.m_Player:GetPlayerColor()
		end
	end
end)


_G.Ragdoll = Ragdoll

local Player = debug.getregistry().Player

Player.OldSpawn = Player.OldSpawn or debug.getregistry().Entity.Spawn

function Player:Spawn()
	if self.m_Ragdoll then
		Ragdoll.Disable( self, true )
	end

	return self:OldSpawn()
end
