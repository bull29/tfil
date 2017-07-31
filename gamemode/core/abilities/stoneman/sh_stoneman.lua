
hook.Add("Lava.PlayerPushPlayer", "Stoneman", function( Attacker, Victim )
	if Victim:HasAbility("Stoneman") then
		Attacker:SetVelocity( -Attacker:GetForward() * 1000 )
		return true
	end
end)

Abilities.Register("Stoneman", [[You're immune to pushes, any attempts to push you end up whipping the player who pushed you back.]], 1597 )
