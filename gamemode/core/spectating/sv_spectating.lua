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
			Player.m_NextSpectateToggle = CurTime() + FrameTime() * 2

			if nP == 3 then
				Player:Spectate(Player:GetObserverMode() % 3 + 4)
			elseif nP == 2 and Player:GetObserverMode() ~= 0 then
				Player.m_SpectateIndex = ((Player.m_SpectateIndex - 2) % player.GetCount()) + 1

				while (player.GetCount() ~= 1 and player.GetAll()[Player.m_SpectateIndex] == Player) do
					Player.m_SpectateIndex = ((Player.m_SpectateIndex - 2) % player.GetCount()) + 1
				end
			elseif nP == 1 and Player:GetObserverMode() ~= 0 then
				Player.m_SpectateIndex = ((Player.m_SpectateIndex % player.GetCount() + 1))

				while (player.GetCount() ~= 1 and player.GetAll()[Player.m_SpectateIndex] == Player) do
					Player.m_SpectateIndex = ((Player.m_SpectateIndex % player.GetCount() + 1))
				end
			end

			Player:SpectateEntity(player.GetAll()[Player.m_SpectateIndex])
		end
	end
end)