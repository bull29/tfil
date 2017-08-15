hook.Add("Lava.PlayerEgged","Nolan Brian",function(Attacker,EggEnt,Victim)
	if Attacker:HasAbility("Nolan Brian") then
		Victim:SetVelocity(Attacker:GetForward():SetZ(Victim:OnGround() and 0.2 or -0.2) * 1000)
	end
end)

hook.Add( "Lava.PlayerEggDispatched", "Nolan Brian", function( Player, Weapon, Egg )
	if Player:HasAbility("Nolan Brian") then
		Egg:GetPhysicsObject():EnableGravity( false )
		Egg:GetPhysicsObject():AddVelocity(Player:GetAimVector()* 1400)
	end
end)
Abilities.Register("Nolan Brian", [[You are a legendary baseball player with an amazing pitch. Your pitches are so strong, they have enough force to push back other players.]], 2538)
