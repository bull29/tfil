

local function func( Player )
	if Player:HasAbility("Thunder Thighs") then
		if ( Player:GetBonePosition( Player:LookupBone("ValveBiped.Bip01_R_Thigh")).z ) > Lava.GetLevel() then
			return false
		end
	end
end

hook.Add("Lava.ShouldRenderDamageOverlay", "ThunderThighs", func )
hook.Add("Lava.ShouldTakeLavaDamage", "ThunderThighs", func )


Abilities.Register("Thunder Thighs", [[You're immune to Lava
	up to your pelvis.
	Guess why.]], CLIENT and Emoji.Get( 832 ) )

