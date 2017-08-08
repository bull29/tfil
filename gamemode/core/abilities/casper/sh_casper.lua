hook.Add("Lava.PostPlayerSpawn", "CASPER", function(Player)
	if Player:HasAbility("Casper") then
		Player:SetRunSpeed(Player:GetRunSpeed() * 1.3)
		Player:SetWalkSpeed(Player:GetWalkSpeed() * 1.3)
		Player:SetAvoidPlayers(false)
	end

	Player:CollisionRulesChanged()
end)

hook.Add("ShouldCollide", "DisableCasperCollisions", function(A, B)
	if A:IsPlayer() and B:IsPlayer() and (A:HasAbility("Casper") or B:HasAbility("Casper")) then return false end
end)

hook.Add("SetupMove", "CASPER", function(Player, Movedata, Command)
	if Player:HasAbility("Casper") then
		if not Player:Alive() then
			Player.m_CasperMeter = 100
			return
		end
		Player.m_CasperMeter = Player.m_CasperMeter or 100

		if Command:KeyDown(IN_RELOAD) and Movedata:GetVelocity().z > -25 and not Player.m_HasUsedupCasperMeter and not Player:OnGround() then
			Player:SetGroundEntity(Entity(0))

			if SERVER then
				Player:SetNW2Bool("$casper", true)
				Player.m_CasperMeter = (Player.m_CasperMeter - (FrameTime()) * 15):max(0)

				if Player.m_CasperMeter < 1 then
					Player.m_HasUsedupCasperMeter = true
				end

				Player:SetProperVar("Float", "$caspermeter", Player.m_CasperMeter)
			end
		elseif SERVER then
			Player:SetNW2Bool("$casper", false)
			Player.m_CasperMeter = (Player.m_CasperMeter + (FrameTime()) * 15):min(100)
			Player:SetProperVar("Float", "$caspermeter", Player.m_CasperMeter)

			if Player.m_CasperMeter == 100 then
				Player.m_HasUsedupCasperMeter = nil
			end
		end
	end
end)

local White = color_white
local m_Meter = 100
local m_HasPlayerUsedupMeter

hook.Add("HUDPaint", "CasperMeter", function()
	m_Meter = LocalPlayer():GetNW2Int("$caspermeter", 100)
	if m_Meter == 100 or not LocalPlayer():HasAbility("Casper") or not LocalPlayer():Alive() then return end
	draw.WebImage(Emoji.Get(1200), ScrW() / 2, ScrH() - ScrH() / 10, ScrH() / 7, ScrH() / 7, pColor():Alpha(100), 0)
	draw.WebImage(Emoji.Get(1200), ScrW() / 2, ScrH() - ScrH() / 10, m_Meter / 100 * ScrH() / 7, m_Meter / 100 * ScrH() / 7, White:Alpha(m_HasPlayerUsedupMeter and 100 or 255), 0)

	if not m_HasPlayerUsedupMeter and m_Meter < 2 then
		m_HasPlayerUsedupMeter = true
	elseif m_HasPlayerUsedupMeter and m_Meter == 90 then
		m_HasPlayerUsedupMeter = nil
	end
end)

local GhostMat = Material("models/shiny")

hook.Add("PlayerRender", "CASPERMAT", function(Player)
	if Player:HasAbility("Casper") and Player:GetNW2Bool("$casper") and not Player:OnGround() then
		render.MaterialOverride(GhostMat)
		Player:DrawModel()
		render.MaterialOverride()

		return true
	end
end)

hook.Add("CalcMainActivity", "CASPERANIM", function(Player)
	if Player:HasAbility("Casper") and not Player:OnGround() and Player:GetNW2Bool("$casper") then return ACT_HL2MP_SWIM, -1 end
end)

Abilities.Register("Casper", [[You don't collide with players and move slightly faster than others. Extremely beneficial on maps with narrow pathways. You can also hold R to hover above ground for a limited amount of time.]], 1200, function(Player)
	Player:CollisionRulesChanged()
	Player:SetRunSpeed(225 * 1.3)
	Player:SetWalkSpeed(175 * 1.3)
end, function(Player)
	Player:CollisionRulesChanged()
	Player:SetRunSpeed(225)
	Player:SetWalkSpeed(175)
end)