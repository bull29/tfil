local SetGlobalFloat = SetGlobalFloat
--local Rounds = Rounds
--local Lava = Lava
local Values = Values
local FrameTime = FrameTime
local player_manager = player_manager

hook.Add("Think", "LavaSync", function()
	if Lava.CurrentLevel ~= GetGlobalFloat("$lavalev", -10000) then
		SetGlobalFloat("$lavalev", Lava.CurrentLevel)
	end
end)

hook.Add("Think", "LavaMain", function()
	if Rounds.CurrentState == "Preround" then
		--
	elseif Rounds.CurrentState == "Started" then
		Lava.ShiftLevel( FrameTime() *5 )
	elseif Rounds.CurrentState == "Ended" then
		Lava.ShiftLevel(-FrameTime() * 5)
	end
end)

hook.Add("PlayerTick", "LavaHurt", function(Player)
	if Rounds.CurrentState == "Started" and Player:GetPos().z <= Lava.CurrentLevel and hook.Call("Lava.ShouldTakeLavaDamage", nil, Player ) ~= false then
		Player:Ignite(0.1, 0)
	end
end)
