local DefaultValues = {
	HULL = {Vector(-16, -16, 0), Vector(16, 16, 72)},
	HULLDUCK = {Vector(-16, -16, 0), Vector(16, 16, 36)},
	OFFSETDUCK = Vector(0, 0, 28),
	OFFSET = Vector(0, 0, 64),
	WALK = 175,
	RUN = 225
}

local function SetDefaultValues(Player)
	Player:SetModelScale(1, 1)
	Player:SetHull(DefaultValues.HULL[1], DefaultValues.HULL[2])
	Player:SetHullDuck(DefaultValues.HULLDUCK[1], DefaultValues.HULLDUCK[2])
	Player:SetViewOffset(DefaultValues.OFFSET)
	Player:SetViewOffsetDucked(DefaultValues.OFFSETDUCK)
	Player:SetRunSpeed(DefaultValues.RUN)
	Player:SetWalkSpeed(DefaultValues.WALK)
end

hook.Add("PlayerTick", "Tinfiy", function(Player, Movedata)
	if Player:HasAbility("Weasel") then
		Player.m_NextWeaselTime = Player.m_NextWeaselTime or CurTime()

		if Movedata:KeyDown(8192) and Player.m_NextWeaselTime < CurTime() then
			Player.m_IsWeasel = Player:GetModelScale() ~= 1
			Player.m_NextWeaselTime = CurTime() + 3

			if Player.m_IsWeasel then
				SetDefaultValues(Player)
			else
				Player:SetModelScale(0.5, 1)
				Player:SetHull(DefaultValues.HULL[1] / 2, DefaultValues.HULL[2] / 2)
				Player:SetHullDuck(DefaultValues.HULLDUCK[1] / 2, DefaultValues.HULLDUCK[2] / 2)
				Player:SetViewOffset(DefaultValues.OFFSET / 2)
				Player:SetViewOffsetDucked(DefaultValues.OFFSETDUCK / 2)
				Player:SetRunSpeed(DefaultValues.RUN * 0.7)
				Player:SetWalkSpeed(DefaultValues.WALK * 0.7)
			end
		end
	end
end)

hook.Add("Lava.PostPlayerSpawn", "SetDefaults", SetDefaultValues )

Abilities.Register("Weasel", [[You have the ability to become tiny
	to fit into otherwise unreachable spaces.
	Press R.]], "1f574-1f3fb", nil, SetDefaultValues )