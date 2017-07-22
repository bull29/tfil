

hook.Add("GetFallDamage", "AvoidFallDamageHH", function(Player, Speed )
	if Player:HasAbility("Hippity Hoppity") then
		if not Player:Crouching() then
			Player:SetVelocity( ( Player:GetAimVector() * 0.35 ):SetZ( 1.2 ) * ( Speed*0.75 ) )
		end
		return ( CalculateBaseFallDamage( Speed ) * 0.75 ):min( 15 )
	end
end)

Abilities.Register("Hippity Hoppity", [[When you hit the ground
	at a high velocity, you hop
	extremely high, taking a flat maximum of 15
	fall damage no matter the height. 
	Similar to Skippy feet. Extremely useful for
	vertical-oriented maps. 
	Hold down crouch when landing to 
	avoid hopping.]], 724 )

