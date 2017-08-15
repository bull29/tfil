local AddHook = Mutators.RegisterHooks("Flametag", {
	"PlayerShouldTakeDamage",
	"Think",
	"PlayerTick"
})

Mutators.RegisterNewEvent("Flametag", "A Randomly chosen player is flaming. If he comes near you, you catch on fire too. Just give him a hug!", function()
	if SERVER then
		local Player = Mutators.GetRandomPlayerForEvent("Flametag")
		if not IsValid( Player ) then return end
		Mutators.DesignateSpecialPlayer(Player)

		if Mutators.GetSpecialPlayer() then
			local sPlayer = Mutators.GetSpecialPlayer()
			sPlayer:SetModel("models/player/charple.mdl")
			sPlayer:SetWalkSpeed( 100 )
			sPlayer:SetRunSpeed( 200 )
			Notification.SendType( "Mutator", sPlayer:Nick() .. " is the Flamer! Go give him a peepee touch!" )
			if SERVER then
				sPlayer:Ignite(500, 128)
				sPlayer.PreferedAbility = sPlayer:GetAbility()
				sPlayer:SetAbility("$none")
			end

			AddHook(function(Player, Attacker)
				if Player == sPlayer and IsValid(Attacker) and Attacker:GetClass() == "entityflame" and Attacker:GetPos().z > Lava.GetLevel() then return false end
			end)
			AddHook(function() end)
		end
	end
	if CLIENT then
		AddHook( function() end)
		AddHook( function()	end)
	end
	AddHook( function( Player )
		local Special = Mutators.GetSpecialPlayer()
		if Player ~= Special and IsValid( Special ) then
			if SERVER and Player:GetPos():Distance( Special:GetPos() ) < 75 then
				Player:Ignite( 0.1, 0 )
			end
		end
	end)
end, function()
	Mutators.ClearSpecialPlayer()
end)