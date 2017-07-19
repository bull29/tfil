local IsValid = IsValid
local os = os
local util = util

hook.Add( "CalcMainActivity", "BaseAnimations", function( Player, Velocity )
	if not Player.LastOnGround and not Player:OnGround() then
		Player.LastOnGround = true
	end
	if Player:IsOnGround() and Player.LastOnGround then
		Player:AddVCDSequenceToGestureSlot( GESTURE_SLOT_FLINCH, Player:LookupSequence("jump_land"), 0, true )
		Player.LastOnGround = false
	end
	if Player:GetNW2Bool("$attacking", false ) and IsValid( Player:GetActiveWeapon() ) and Player:GetActiveWeapon():GetClass() == "lava_fists" then
		local sequence = "zombie_attack_0" .. util.SharedRandom( "m_ZattackAnim", 1, 7, os.time() ):floor()
		Player:GetActiveWeapon():SetNextPrimaryFire( CurTime() + 0.5*Player:SequenceDuration( Player:LookupSequence( sequence )))
		Player:AddVCDSequenceToGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD, Player:LookupSequence( sequence ), 0.5, true )
		Player:SetNW2Bool("$attacking", false )
	end
	if Player:IsOnGround() and Velocity:Length() > Player:GetRunSpeed() - 10 then
		return ACT_HL2MP_RUN_FAST, -1
	end
end)

hook.Add("NetworkEntityCreated", "HookOntoRender", function( Object )
	if not Object:IsPlayer() then return end
	if not Object.RenderOverride then
		Object.RenderOverride = function( self )
			if hook.Call("PlayerRender", nil, self ) == nil then
				self:DrawModel()
			end
		end
	end
end)

function GM:PlayerNoClip()
	return true
end