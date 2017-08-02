
local function NextPlayer( CurrentNumber )
	return ((CurrentNumber % player.GetCount() + 1))
end

local function PreviousPlayer( CurrentNumber )
	return ((CurrentNumber - 2) % player.GetCount()) + 1
end

hook.Add("Lava.DeathThink", "LavaSpectating", function(Player)
	Player.m_NextSpectateToggle = Player.m_NextSpectateToggle or CurTime()

	if Player.m_NextSpectateToggle < CurTime() then
		if not Player.m_SpectateIndex then
			Player.m_SpectateIndex = 1
		end

		if Player:GetObserverMode() == 0 and ( Player:KeyDown(1) or Player:KeyDown(2) ) then -- Expected cliche behaviour
			Player:Spectate(Player:GetObserverMode() % 3 + 4)
		end

		local nP = Player:KeyDown(1) and 1 or Player:KeyDown(2048) and 2 or Player:KeyDown(8192) and 3

		if nP then
			Player.m_NextSpectateToggle = CurTime() + 0.25
			local Tries = 0
			if nP == 3 then
				Player:Spectate(Player:GetObserverMode() % 3 + 4)
			elseif nP == 2 and Player:GetObserverMode() ~= 0 then
				Player.m_SpectateIndex = PreviousPlayer( Player.m_SpectateIndex )

				while (player.GetCount() ~= 1 and player.GetAll()[Player.m_SpectateIndex] == Player) or not player.GetAll()[Player.m_SpectateIndex]:Alive() do
					Player.m_SpectateIndex = PreviousPlayer( Player.m_SpectateIndex )
					Tries = Tries + 1
					if Tries > player.GetCount() + 1 then
						break
					end
				end
			elseif nP == 1 and Player:GetObserverMode() ~= 0 then
				Player.m_SpectateIndex = NextPlayer( Player.m_SpectateIndex )

				while (player.GetCount() ~= 1 and player.GetAll()[Player.m_SpectateIndex] == Player) or not player.GetAll()[Player.m_SpectateIndex]:Alive() do
					Player.m_SpectateIndex = NextPlayer( Player.m_SpectateIndex )
					Tries = Tries + 1
					if Tries > player.GetCount() + 1 then
						break
					end
				end
			end

			Player:SpectateEntity(player.GetAll()[Player.m_SpectateIndex])
		end
	end
end)