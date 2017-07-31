

hook.Add("Lava.PlayerPushPlayer", "Iron Fist", function( Attacker, Victim )
	if Attacker:HasAbility("Iron Fist") and not Victim:HasAbility("Stoneman") then
		Victim:SetVelocity(Attacker:GetForward():SetZ(Victim:OnGround() and 0.5 or -0.5) * 2000)
		return true
	end
end)

Abilities.Register("Iron Fist", [[Because of vigorous use of both your hands, your punches cause players to go flying towards wherever you happen to be aiming, much stronger than the right-handed normies.]], 1990 )
