hook.Add("Lava.PostPlayerSpawn", "JuanEggz", function( Player )
	if Player:HasAbility("Egg Meister") and Player:GetActiveWeapon().SetEggs then
		Player:GetActiveWeapon():SetEggs( 3 )
	end
end)

hook.Add( "Lava.FistsSecondaryAttack", "AddEggz", function( Player, Weapon )
	if Player:HasAbility("Egg Meister") then
		Weapon:SetEggs( Weapon:GetEggs() + 1 )
	end
end)

hook.Add( "Lava.PlayerEggDispatched", "AddEggz", function( Player, Weapon, Egg )
	if Player:HasAbility("Egg Meister") then
		Egg:GetPhysicsObject():EnableGravity( false )
		return 2048
	end
end)

Abilities.Register("Egg Meister", [[You have infinite Eggs and you 
	whip them with much more power
	like a straight bullet.]], 2014 )

