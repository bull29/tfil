local SetGlobalFloat = SetGlobalFloat
local Rounds = Rounds
local Lava = Lava
local Values = Values
local FrameTime = FrameTime

hook.Add("Think", "LavaSync", function()
	if Lava.CurrentLevel ~= GetGlobalFloat("$lavalev", -10000) then
		SetGlobalFloat("$lavalev", Lava.CurrentLevel)
	end
end)

hook.Add("Think", "LavaMain", function()
	if Rounds.CurrentState == "Preround" then
		--
	elseif Rounds.CurrentState == "Started" then
		local max = 100000
		for Player in Values(player.GetAll()) do
			if not Player:Alive() then continue end
			max = max:min(Player:GetPos().z - Lava.GetLevel())
		end

		if max == 100000 then
			max = 1
		end

		Lava.ShiftLevel((FrameTime() * max / 50))
	elseif Rounds.CurrentState == "Ended" then
		Lava.ShiftLevel(-FrameTime() * 5)
	end
end)

hook.Add("PlayerTick", "LavaHurt", function(Player)
	if Player:GetPos().z <= Lava.CurrentLevel then
		Player:Ignite(0.1, 0)
	end
end)