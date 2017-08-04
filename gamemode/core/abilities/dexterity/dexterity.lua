hook.Add("GetFallDamage", "LessenFallDamageDexitrity", function(Player, Speed )
	if Player:HasAbility("Dexterity") then return CalculateBaseFallDamage( Speed )/2.5 end
end)

hook.Add("Lava.PostPlayerSpawn", "AddDexterity", function( Player )
	if Player:HasAbility("Dexterity") then
		Player:SetRunSpeed( 400 )
		Player:SetWalkSpeed( 300 )
		Player:SetJumpPower( 400 )
	end
end)

Abilities.Register("Dexterity", [[Your running speed
	and jumping power is doubled,
	and you take ~60% less fall damage.]], 2106,
	function( Player )
		Player:SetRunSpeed( 400 )
		Player:SetWalkSpeed( 300 )
		Player:SetJumpPower( 400 )
	end, function( Player )
		Player:SetRunSpeed( 225 )
		Player:SetWalkSpeed( 175 )
		Player:SetJumpPower( 250 )
	end )
