local AddHook = Mutators.RegisterHooks("Eggplosive Annihilation", {
	"Lava.PlayerEggDispatched",
	"EntityTakeDamage",
	"PlayerShouldTakeDamage",
	"PropBreak",
})

Mutators.RegisterNewEvent("Eggplosive Annihilation", "Everyone has infinite eggs. Eggs explode on impact, sending players flying away. Fall damage is disabled. Bonus: Master the art of traveling with egg-rocket jumps.", function()
	AddHook( function( Player, Weapon, Egg )
		Egg:Ignite( 500, 0 )
		Weapon:SetEggs( Weapon:GetEggs() + 1 )
	end)

	AddHook( function( Entity, Damage )
		if Entity:GetModel() == "models/props_phx/misc/egg.mdl" then
			if Damage:GetInflictor():IsValid() and Damage:GetInflictor():GetClass() == "entityflame" then
				return true
			end
		end

		if Entity:IsPlayer() and (Damage:IsFallDamage() or Damage:IsExplosionDamage()) then
			return true
		end
	end)

	AddHook( function( Player, Attacker )
		if Attacker:IsValid() and Attacker:GetClass() == "env_explosion" then
			Player:SetVelocity( ( Player:GetPos() - Attacker:GetPos() ) * 10 + Vector( 0, 0, 200 ))
			return false
		end
	end)

	AddHook( function( Player, Entity )
		if SERVER then
			if Entity:GetModel() == "models/props_phx/misc/egg.mdl" then
				local Explosion = ents.Create("env_explosion")
				Explosion:SetPos( Entity:GetPos() )
				Explosion:SetOwner( Player )
				Explosion:SetKeyValue( "iMagnitude", 200 )
				Explosion:SetKeyValue( "iRadiusOverride", 200 )
				Explosion:Fire( "Explode", 0, 0 )
				Explosion:EmitSound( "weapon_AWP.Single", 400, 400 )
			end
		end
	end)
end)
