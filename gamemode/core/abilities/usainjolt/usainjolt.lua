local IN_SPEED = IN_SPEED
local util = util
local draw = draw
local ScrH = ScrH
local pairs = pairs
local CurTime = CurTime

local Range = {
	[200] = 2521,
	[250] = 1901,
	[300] = 520,
	[350] = 1867,
	[400] = 558,
	[450] = 1958,
	[500] = 1818,
	[550] = 1817,
	[600] = 1809,
	[650] = 615,
	[700] = 616,
	[750] = 1792,
	[800] = 1794,
	[850] = 1791,
	[900] = 2584,
	[950] = 1955,
	[1000] = 1790
}

local function GetSpeedEmoji(PlayerSpeed)
	if PlayerSpeed <= 250 then return 2521 end

	for k, v in pairs(Range) do
		if PlayerSpeed:inrange(k, k + 50) then return v end
	end

	return 1790
end

hook.Add("PlayerTick", "UsainBolt", function(Player, MoveData)
	if Player:HasAbility("Usain Jolt") then
		if MoveData:KeyDown(IN_SPEED) and Player:GetVelocity():Length2D() > (Player:GetRunSpeed() - 5) then
			Player:SetRunSpeed(Player:GetRunSpeed() + FrameTime() * util.SharedRandom("m_RandomBolt", 5, 25, CurTime()))
			Player:SetMaxSpeed(Player:GetRunSpeed())
			Player:SetJumpPower( ( Player:GetRunSpeed() ) )
		elseif Player:OnGround() then
			Player:SetRunSpeed((Player:GetRunSpeed()*0.99 ):max(250))
			Player:SetMaxSpeed(Player:GetRunSpeed())
			Player:SetJumpPower( Player:GetRunSpeed() )
		end
	end
end)

hook.Add("HUDPaint", "UsainBolt", function()
	if LocalPlayer():Alive() and LocalPlayer():HasAbility("Usain Jolt") and LocalPlayer():OnGround() then
		local x = (LocalPlayer():GetVelocity():Length2D():max(LocalPlayer():GetRunSpeed())):Round(2)
		local tab = Emoji.ParseNumber(x)
		local var = (ScrH() / 25):floor()
		local speed = GetSpeedEmoji(x)
		draw.WebImage(Emoji.Get(speed), ScrW() / 2 + (CurTime() * (x / 50):floor()):sin() * (x / 50):floor(), var * 2, var * 2, var * 2, nil, CurTime():sin() * 5)

		for i = 1, #tab do
			draw.WebImage(Emoji.Get(tab[i]), ScrW() / 2 - ((#tab):min(5)) * (var / 2) + (var * (i - 1)), ScrH() * 0.15, var, var, nil, 0)
		end
	end
end)

hook.Add("GetFallDamage", "AvoidFallUsain", function(Player, Speed)
	if Player:HasAbility("Usain Jolt") then return GetBaseFallDamage( Speed )/2 end
end)

Abilities.Register("Usain Jolt", [[You gain increasing
	momentum soaring to infinite
	speeds as long as you're still
	sprinting. Your jumping power
	correlates directly to your sprint speed.
	You take half fall damage.]], CLIENT and Emoji.Get(2291))