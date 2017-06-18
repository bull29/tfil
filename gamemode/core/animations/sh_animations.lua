
hook.Add( "CalcMainActivity", "BaseAnimations", function( Player, Velocity )
	if not Player.LastOnGround and not Player:OnGround() then
		Player.LastOnGround = true
	end
	if Player:IsOnGround() and Player.LastOnGround then
		Player:AddVCDSequenceToGestureSlot( GESTURE_SLOT_FLINCH, Player:LookupSequence("gmod_jump_land"), 0.6, true )
		Player.LastOnGround = false
	end
	if Player:IsOnGround() and Velocity:Length() > Player:GetRunSpeed() - 10 then
		return ACT_HL2MP_RUN_FAST, -1
	end
end)


function GM:PlayerNoClip()
	return true
end