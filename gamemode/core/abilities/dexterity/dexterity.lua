hook.Add("GetFallDamage", "LessenFallDamageDexitrity", function(Player, Speed )
	if Player:HasAbility("Dexterity") then return ( 10 ):max( math.ceil( 0.2418*Speed - 141.75 )*1.5 ) end
end)

hook.Add("Lava.PostPlayerSpawn", "AddDexterity", function( Player )
	if Player:HasAbility("Dexterity") then
		Player:SetRunSpeed( 350 )
		Player:SetWalkSpeed( 250 )
		Player:SetJumpPower( 350 )
	end
end)

Abilities.Register("Dexterity", [[Your running speed
	and jumping power is doubled,
	and you take 25% less fall damage.]], CLIENT and Emoji.Get( 2106 ) )
