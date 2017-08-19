hook.Add( "Lava.PlayerEgged", "Telsiter", function( Attacker, Egg, Victim )
	if Attacker:HasAbility("Teleyolker") then
		Attacker.m_ToTeleportTo = Victim:GetPos()
		Victim.m_ToTeleportTo = Attacker:GetPos()

		Attacker.m_TeleportAngles = Victim:EyeAngles()
		Victim.m_TeleportAngles = Attacker:EyeAngles()

		if IsValid( Attacker:GetActiveWeapon() ) and Attacker:GetActiveWeapon().SetEggs then
			Attacker:GetActiveWeapon():SetEggs( Attacker:GetActiveWeapon():GetEggs() + 1 )
		end
	end
end)

hook.Add("SetupMove", "SwapTele", function( Player, Movedata, Command )
	if Player.m_ToTeleportTo and Player.m_TeleportAngles then
		Command:SetViewAngles( Player.m_TeleportAngles )
		Movedata:SetOrigin( Player.m_ToTeleportTo )
		Player.m_ToTeleportTo = nil
		Player.m_TeleportAngles = nil
	end
end)

Abilities.Register("Teleyolker", [[You're an egg wizard. Any player you successfully egg will swap their positions with you. You gain two eggs per player hit instead of just one.]], 1328 )
