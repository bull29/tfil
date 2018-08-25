
hook.Add( "Lava.FistsSecondaryAttack", "AddEggz", function( Player, Weapon )
	if Player:HasAbility("Egg Meister") then
		Weapon:SetEggs( 4 )
	end
end)

hook.Add( "Lava.PlayerEggDispatched", "AddEggz", function( Player, Weapon, Egg )
	if Player:HasAbility("Egg Meister") then
		Egg:GetPhysicsObject():EnableGravity( false )
		return 1536
	end
end)

Abilities.Register("Egg Meister", [[You have infinite Eggs and you 
	whip them with much more power
	like a straight bullet. Where the fuck are you getting these eggs from?]], "1f921" )

