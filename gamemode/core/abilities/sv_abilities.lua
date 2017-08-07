
util.AddNetworkString("Lava.SelectAbility")

hook.Add("PlayerInitialSpawn", "Abilities.SelectRandom", function( Player )
	Player:SetAbility( Player:GetPData("$ability", false ) or table.Random( table.GetKeys( Abilities.Skills ) ) )
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
	Player:SetPData("$ability", desired )
	if Rounds.CurrentState == "Preround" then
		if Player:GetAbility() ~= "" and Abilities.Skills[ Player:GetAbility() ] and Abilities.Skills[ Player:GetAbility() ][4] then
			Abilities.Skills[ Player:GetAbility() ][4]( Player )
		end

		Player:SetAbility( Player.PreferedAbility )
		if Abilities.Skills[ desired ][ 3 ] then
			Abilities.Skills[ desired ][ 3 ]( Player )
		end
	end
end)

debug.getregistry().Player.SetAbility = function( self, ability )
	if hook.Call( "Lava.PlayerSelectAbility", nil, self, ability ) == false then return end

	self.Ability = ability
	self:SetNW2String("$ability", ability )
end