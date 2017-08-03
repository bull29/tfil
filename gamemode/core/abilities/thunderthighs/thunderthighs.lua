

local function func( Player )
	if Player:HasAbility("Thunder Thighs") and Player:LookupBone("ValveBiped.Bip01_R_Thigh") then
		if ( Player:GetBonePosition( Player:LookupBone("ValveBiped.Bip01_R_Thigh")).z ) > Lava.GetLevel() then
			return false
		end
	end
end

hook.Add("Lava.ShouldRenderDamageOverlay", "ThunderThighs", func )
hook.Add("Lava.ShouldTakeLavaDamage", "ThunderThighs", func )
hook.Add("GetFallDamage", "AvoidFallDamageTT", function(Player)
	if Player:HasAbility("Thunder Thighs") then return false end
end)

Abilities.Register("Thunder Thighs", [[Due to intense and
	frequent repetitive physical thrust-like
	exertions you're immune to Lava
	up to your pelvis. 
	Guess why. You also take
	no fall damage.]], 832 )

