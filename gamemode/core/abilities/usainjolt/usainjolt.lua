local IN_SPEED = IN_SPEED
local util = util
local draw = draw
local ScrH = ScrH
local pairs = pairs
local CurTime = CurTime

local Range = {
	[200] = "267f",
	[250] = "1f6b6-1f3fb",
	[300] = "1f3c3-1f3fb",
	[350] = "1f6b4-1f3fb-200d-2642-fe0f",
	[400] = "1f6f4",
	[450] = "1f3c7",
	[500] = "1f68e",
	[550] = "1f695",
	[600] = "1f693",
	[650] = "1f3cd",
	[700] = "1f3ce",
	[750] = "1f54a",
	[800] = "1f685",
	[850] = "1f681",
	[900] = "1f6e9",
	[950] = "1f6f0",
	[1000] = "1f680"
}

local function GetSpeedEmoji(PlayerSpeed)
	if PlayerSpeed <= 250 then return "267f" end

	for k, v in pairs(Range) do
		if PlayerSpeed:inrange(k, k + 50) then return v end
	end

	return "2728"
end

hook.Add("PlayerTick", "UsainBolt", function(Player, MoveData)
	if Player:HasAbility("Usain Jolt") then
		if MoveData:KeyDown(IN_SPEED) and Player:GetVelocity():Length2D() > (Player:GetRunSpeed() - 5) then
			Player:SetRunSpeed(Player:GetRunSpeed() + FrameTime() * util.SharedRandom("m_RandomBolt", 5, 25, CurTime()))
			Player:SetMaxSpeed(Player:GetRunSpeed())
			Player:SetJumpPower( ( Player:GetRunSpeed() ) )
		elseif Player:OnGround() then
			Player:SetRunSpeed((Player:GetRunSpeed()*0.95 ):max(250))
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
	if Player:HasAbility("Usain Jolt") then return CalculateBaseFallDamage( Speed )/2 end
end)

Abilities.Register("Usain Jolt", [[You gain increasing
	momentum soaring to infinite
	speeds as long as you're still
	sprinting. Your jumping power
	correlates directly to your sprint speed.
	You take half fall damage.]], "1f9d6-1f3ff-200d-2642-fe0f")