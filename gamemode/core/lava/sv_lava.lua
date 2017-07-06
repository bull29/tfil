local SetGlobalFloat = SetGlobalFloat
local table = table
local Rounds = Rounds
local Lava = Lava
local Values = Values
local hook = hook
local FrameTime = FrameTime
local player_manager = player_manager
local CurTime = CurTime
Rounds.NextSuperDecentTime = nil

hook.Add("Think", "LavaSync", function()
	if Lava.CurrentLevel ~= GetGlobalFloat("$lavalev", -10000) then
		SetGlobalFloat("$lavalev", Lava.CurrentLevel)
	end
end)

hook.Add("Think", "LavaMainCycle", function()
	if Rounds.CurrentState == "Started" then
		Rounds.NextSuperDecentTime = Rounds.NextSuperDecentTime or CurTime() + 30

		if Rounds.NextSuperDecentTime < CurTime() then
			local tab = player.GetAll()

			for k, v in pairs(tab) do
				if not v:Alive() then
					table.remove(tab, k)
				end
			end

			if tab[1] then
				table.sort(tab, function(a, b) return a:GetPos().z < b:GetPos().z end)
				local t = ((tab[1]:GetPos().z - 32 - Lava.GetLevel()) * FrameTime() / 25):max(FrameTime() * 3)
				Lava.ShiftLevel(t)

				if t == FrameTime() * 3 then
					Rounds.NextSuperDecentTime = CurTime() + 30
				end
			end
		else
			Lava.ShiftLevel(FrameTime() * 3)
		end
	elseif Rounds.CurrentState == "Ended" then
		Rounds.NextSuperDecentTime = nil
	end
end)

hook.Add("PlayerTick", "LavaHurt", function(Player)
	if Rounds.CurrentState == "Started" and Player:GetPos().z <= Lava.CurrentLevel and hook.Call("Lava.ShouldTakeLavaDamage", nil, Player) ~= false then
		Player:Ignite(0.1, 0)
	end
end)