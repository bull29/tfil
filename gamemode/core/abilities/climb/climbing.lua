local Entity = Entity
local string = string
local tonumber = tonumber
local util = util
local Vector = Vector
local COLLISION_GROUP_DEBRIS = COLLISION_GROUP_DEBRIS
local cam = cam
local draw = draw
local surface = surface
local render = render
local _cEnabled = false
local ShouldDrawLP = false
local DarkColor = Color(70, 70, 70)
local ViewPanel

local function CanClimb(Player)
	return Player:HasAbility("Chameleon")
end

hook.Add("CalcMainActivity", "ClimbingAnims", function(Player, Velocity)
	if not CanClimb(Player) then return end

	if CLIENT and Player:GetNW2String("$climbquery") ~= "" then
		local Query = string.Split(Player:GetNW2String("$climbquery"), " ")

		if Query[1] ~= "0" then
			Player:SetCycle((CurTime() * 1.4 * (Query[1])):abs())
		elseif Query[2] ~= "0" then
			Player:SetCycle((CurTime() * 1.6 * (Query[2])):abs())
		else
			Player:SetCycle(0.7)
		end

		return ACT_ZOMBIE_CLIMB_UP, -1
	end
end)

hook.Add("PlayerRender", "DrawClimbingAnims", function(Player)
	if not CanClimb(Player) then return end

	local climbQuery = Player:GetNW2String("$climbquery")

	if climbQuery ~= "" then
		climbQuery = string.Split(climbQuery, " ")
		Player.LerpedSideClimbVar = Player.LerpedSideClimbVar or 0
		Player.LerpedSideClimbVar = Player.LerpedSideClimbVar:lerp(climbQuery[2] * 90)
		Player:SetRenderAngles(Player:GetRenderAngles():SetYaw(climbQuery[3]):SetRoll(Player.LerpedSideClimbVar))
		Player:SetupBones()

		cam.Wrap3D(function()
			Player:DrawModel()
		end, EyePos() - Vector(0, 0, (Player.LerpedSideClimbVar:abs() / 2):min(50):max(12):floor()))

		return true
	end
end)

hook.Add("SetupMove", "Climbing", function(Player, MoveData, Command)
	if not CanClimb(Player) then return end
	Player:UpdateAbilityMeter()
	if not Player:Alive() then return end

	local tr = util.TraceLine({
		start = Player:GetShootPos(),
		endpos = Player:GetShootPos() + Player:GetAimVector() * 50,
		filter = Player,
		collisiongroup = COLLISION_GROUP_DEBRIS
	})

	local x = tr.HitNormal:Angle()

	if Player:KeyHoldNoSpam( IN_JUMP, MoveData ) and Player:CanUseAbility() and tr.Hit and not tr.HitSky and x.p:floor() == 0 and x.r == 0 then
		if SERVER and not Player:IsInWorld() then return end
		if hook.Call("Lava.CanClimb", nil, Player, tr.HitTexture) == false then return end
		Player.m_HasClimbedLast = true

		Player:ShiftAbilityMeter(-FrameTime() * 10)

		if CLIENT then
			_cEnabled = true
		end

		Command:RemoveKey( IN_DUCK )
		MoveData:RemoveKey( IN_DUCK )

		MoveData:SetMoveAngles(Angle(0, x.y + 180, 0))
		MoveData:SetForwardSpeed(1000)
		local cNetString = "" -- Way too much shit to use different NWvars for; why not have it done in one go?

		if MoveData:KeyDown(8) then
			if Player:OnGround() then
				MoveData:SetOrigin(MoveData:GetOrigin() + Vector(0, 0, 42))
			end

			cNetString = cNetString .. "1 " .. (MoveData:GetSideSpeed() / 10000 / 2)

			if SERVER and util.IsInWorld(Player:EyePos() + Vector(0, 0, FrameTime() * 48)) or CLIENT then
				MoveData:SetOrigin(MoveData:GetOrigin() + Vector(0, 0, FrameTime() * 48))
			end
		elseif MoveData:KeyDown(16) then
			cNetString = cNetString .. "-1 " .. (-MoveData:GetSideSpeed() / 10000 / 2)
			MoveData:SetOrigin(MoveData:GetOrigin() + Vector(0, 0, -FrameTime() * 48))
		else
			cNetString = cNetString .. "0 " .. (MoveData:GetSideSpeed() / 10000)
		end

		MoveData:SetMaxClientSpeed(100)
		Player:SetGroundEntity(Entity(0))
		cNetString = cNetString .. " " .. x.y + 180

		if SERVER then
			Player:SetProperVar("String", "$climbquery", cNetString)
		end
	elseif Player.m_HasClimbedLast then
		if not Player:OnGround() then
			local pos = Player:GetShootPos() + MoveData:GetMoveAngles():Forward() * 25 + Player:GetUp() * 50

			local tre = util.TraceLine({
				start = pos,
				endpos = pos - Player:GetUp() * 64,
				filter = Player,
				collisiongroup = COLLISION_GROUP_DEBRIS
			})

			local pRTre = util.TraceLine({
				start = Player:GetShootPos(),
				endpos = pos,
				filter = Player,
			})

			if not pRTre.Hit and tre.Hit and tre.HitWorld and not tre.HitNoDraw and not tre.AllSolid then
				MoveData:SetOrigin(tre.HitPos + Vector( 0, 0, 5 ))
			end
		end

		Player.m_HasClimbedLast = nil
	elseif SERVER then
		Player:SetProperVar("String", "$climbquery", "")

		Player:ShiftAbilityMeter(FrameTime() * 2)

	elseif CLIENT then
		_cEnabled = false
	end
end)

hook.RunOnce("HUDPaint", function()
	local c = InitializePanel("ClimbMeterDisplay", "DPanel")
	c:SetSize(ScrW() / 2, ScrH() / 25)
	c:Center()
	c:SetPaintedManually(true)
	c:SetVerticalPos(ScrH() - ScrH() / 25 * 1.5)
	c.Meter = 100
	c.Paint = function(s, w, h)
		draw.Rect( 0, 0, w, h, DarkColor)
		draw.Rect( h * 0.1, h * 0.1, w - h * 0.2, h * 0.8, pColor():Alpha(50))
		draw.Rect(h * 0.1, h * 0.1, (s.Meter / 100) * (w - h * 0.2), h * 0.8, LocalPlayer():HasUsedUpAbility() and (pColor() - 50):Alpha(100) or pColor())
		draw.WebImage( Emoji.Get( 2236 ), h * 0.1 + (s.Meter / 100) * (w - h * 0.2), h/2, h, h, nil, CurTime():cos() * 360 )
	end
end)

local LerpedMeter = 100

hook.Add("HUDPaint", "DrawClimbMeter", function()
	local cMeter = LocalPlayer():GetAbilityMeter()

	if cMeter ~= 100 and ClimbMeterDisplay and CanClimb(LocalPlayer()) then
		LerpedMeter = LerpedMeter:lerp(cMeter, FrameTime() * 20)
		ClimbMeterDisplay.Meter = LerpedMeter
		ClimbMeterDisplay:PaintManual()
	end
end)

hook.Add("Lava.PostPlayerSpawn", "ClimbSpeed", function( Player )
	if CanClimb( Player ) then
		Player:SetWalkSpeed( Player:GetWalkSpeed()*0.8 )
		Player:SetRunSpeed( Player:GetRunSpeed()*0.8 )
		Player:SetMaxSpeed( Player:GetMaxSpeed()*0.8 )
	end
end)

hook.Add("HUDPaint", "DrawClimbPanel", function()
	if ViewPanel and _cEnabled and CanClimb(LocalPlayer()) then
		ViewPanel:Show()
		ViewPanel:PaintManual()
	elseif ViewPanel then
		ViewPanel:Hide()
	end
end)

hook.Add("ShouldDrawLocalPlayer", "DrawPreview", function()
	if ShouldDrawLP then return true end
end)


Abilities.Register("Chameleon", [[( NOTE: This Ability is present for showcase purposes and is currently in Beta. ) At the cost of slower movespeeds
	You can climb any world brush and parkour! Hold Space while facing a flat wall!
	Careful though!]], 2236)
