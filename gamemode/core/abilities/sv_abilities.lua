
util.AddNetworkString("Lava.SelectAbility")

hook.Add("PlayerInitialSpawn", "Abilities.SelectRandom", function( Player )
	Player:SetAbility( table.Random( table.GetKeys( Abilities.Skills ) ) )
end)

hook.Add("PlayerSpawn", "Abilities.SetAbility", function( Player )
	if Player.PreferedAbility then
		Player:SetAbility( Player.PreferedAbility )
	end
end)

net.Receive("Lava.SelectAbility", function( _, Player )
	local desired = net.ReadString()
	if not Abilities.Skills[ desired ] then return end
	Player.PreferedAbility = desired
end)

debug.getregistry().Player.SetAbility = function( self, ability )
	if hook.Call( "Lava.PlayerSelectAbility", nil, self, ability ) == false then return end

	self.Ability = ability
	self:SetNW2String("$ability", ability )
end