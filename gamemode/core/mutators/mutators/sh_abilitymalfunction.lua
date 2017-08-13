

local AddHook = Mutators.RegisterHooks("Ability Rampage", {
	"Tick",
})
local m_NextCycleTime

Mutators.RegisterNewEvent("Ability Rampage", "You've been having an ability identify crisis recently. Your ability cycles to a random one every 30 seconds.", function()
	AddHook( function()
		if CLIENT then return end

		m_NextCycleTime = m_NextCycleTime or CurTime()

		if m_NextCycleTime <= CurTime() then
			for Player in Values( player.GetAll() ) do
				local OldAbility = Player:GetAbility()
				if Abilities.Skills[ OldAbility ][ 4 ] then
					Abilities.Skills[ OldAbility ][ 4 ]( Player )
				end

				repeat
					Player:SetAbility( table.Random( table.GetKeys( Abilities.Skills ) ) )
				until OldAbility ~= Player:GetAbility() and Player:GetAbility() ~= "Limpy Larry"

				if Abilities.Skills[ Player:GetAbility() ][ 3 ] then
					Abilities.Skills[ Player:GetAbility() ][ 3 ]( Player )
				end

				Notification.ChatAlert( "Your new ability is " .. Player:GetAbility() .. "!", Player )
			end
			m_NextCycleTime = CurTime() + 30
		end
	end )
end,
function()
	m_NextCycleTime = nil
end)