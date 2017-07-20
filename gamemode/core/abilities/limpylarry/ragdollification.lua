-- The following is derived from ULX's ragdoll code.
-- https://github.com/TeamUlysses/ulx/blob/master/lua/ulx/modules/sh/fun.lua

local Ragdoll = {}

function Ragdoll.Enable( Player )
	if CLIENT then return end

	if Player.m_Ragdoll then
		Player.m_Ragdoll:Remove()
		Player.m_Ragdoll = nil
	end

	Player.m_RagdollData = {
		Angles = Player:EyeAngles(),
		Model = Player:GetModel(),
		pColor = Player:GetPlayerColor()
	}

	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll:SetPos( Player:GetPos() )
	ragdoll:SetAngles( Player:GetAngles():SetPitch( 0 ) )
	ragdoll:SetModel( Player:GetModel() )
	ragdoll:Spawn()
	ragdoll:DrawShadow(false )
	ragdoll:SetNW2Entity( "m_PlayerParent", Player )
	ragdoll:Activate()

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
end


function Ragdoll.Disable( Player )
	if not Player.m_Ragdoll then return end
	Player.m_RagdollData.Angles = Player:EyeAngles()
	Player:SetParent()
	Player:UnSpectate()
	Player:Spawn()
	Player:SetEyeAngles( Player.m_RagdollData.Angles )
	Player:SetPlayerColor( Player.m_RagdollData.pColor )
	Player:SetModel( Player.m_RagdollData.Model )
	Player:SetVelocity( Player.m_Ragdoll:GetVelocity() )

	timer.Simple( 0, function()
		if not Player:IsValid() or not IsValid( Player.m_Ragdoll ) then return end
		Player:SetPos( Player.m_Ragdoll:GetBonePosition( 1 ) + Vector( 0, 0, 5 ))
		Player.m_Ragdoll:Remove()
		Player.m_Ragdoll = nil
	end)
end

hook.Add("NetworkEntityCreated", "ExposeRagdoll", function( ent )
	if IsValid( ent ) and ent:GetClass() == "prop_ragdoll" and ent:GetNW2Entity( "m_PlayerParent", NULL ):IsValid() then
		ent.m_Player = ent:GetNW2Entity( "m_PlayerParent", NULL )
		ent.m_Player.m_Ragdoll = ent
		ent:DestroyShadow()
		ent.GetPlayerColor = function( self )
			return self.m_Player:GetPlayerColor()
		end
	end
end)


_G.Ragdoll = Ragdoll

