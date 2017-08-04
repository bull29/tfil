util.AddNetworkString( "lava_unstuck" )
local Values = Values

hook.Add("Lava.FullTick", "CachePlayerPositions", function()
	for Player in Values( player.GetAll() ) do
		local Stuck = Player:CheckHullCollision()
		if not Stuck then
			Player.m_LastValidPosition = Player:GetPos()
		elseif Player:Alive() and Stuck then
			Player:SetPos( Player.m_LastValidPosition )
		end
	end
end)

net.Receive( "lava_unstuck", function( _, Player )
	Player.m_NextUnstuckTime = Player.m_NextUnstuckTime or CurTime()

	if Player.m_NextUnstuckTime > CurTime() then
		Notification.ChatAlert( "Please wait a little before attempting to use unstuck again. ", Player )
	else
		if Player:GetVelocity():Length2D() > 1 then
			return Notification.ChatAlert( "Please stop moving.", Player  )
		end
		if not Player:CheckHullCollision() then
			return Notification.ChatAlert( "You are not stuck.", Player )
		end

		Player.m_NextUnstuckTime = CurTime() + 30
		Player:SetPos( Player.m_LastValidPosition )
	end
end)