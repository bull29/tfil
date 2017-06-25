local Entity = Entity
local string = string
local tonumber = tonumber
local util = util
local Vector = Vector
local Fourty = Vector(0, 0, 40)
local COLLISION_GROUP_DEBRIS = COLLISION_GROUP_DEBRIS
local cam = cam
local render = render
local _cEnabled = false
local ShouldDrawLP = false
local DarkColor = Color(70, 70, 70)
local ViewPanel

hook.Add("CalcMainActivity", "ClimbingAnims", function(Player, Velocity)
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
	local climbQuery = Player:GetNW2String("$climbquery")
	if climbQuery ~= "" then
		climbQuery = string.Split(climbQuery, " ")
		Player.LerpedSideClimbVar = Player.LerpedSideClimbVar or 0
		Player.LerpedSideClimbVar = Player.LerpedSideClimbVar:lerp(climbQuery[2] * 90)
		Player:SetRenderAngles( Player:GetRenderAngles():SetYaw(climbQuery[3]):SetRoll(Player.LerpedSideClimbVar))
		Player:SetupBones()
		local t = (Player.LerpedSideClimbVar:abs() / 2):min(50):max(12):floor()
		cam.Start3D(EyePos() - Vector(0, 0, t))
		Player:DrawModel()
		cam.End3D()
		return true
	end
end)

hook.Add("SetupMove", "Climbing", function(Player, MoveData, Command)
	local tr = util.TraceLine({
		start = Player:GetShootPos(),
		endpos = Player:GetShootPos() + Player:GetAimVector() * 50,
		filter = Player,
		collisiongroup = COLLISION_GROUP_DEBRIS
	})

	local x = tr.HitNormal:Angle()

	local tr2 = util.TraceLine({
		start = Player:GetPos() + Player:GetForward(),
		endpos = Player:GetPos() + Player:GetForward() - Fourty,
		filter = Player,
		collisiongroup = COLLISION_GROUP_DEBRIS
	})

	if not tr2.Hit and tr.Hit and not tr.HitSky and x.p:floor() == 0 and x.r == 0 then
		if SERVER and not Player:IsInWorld() then return end
		Command:ClearMovement()
		Command:ClearButtons()

		if CLIENT then
			_cEnabled = true
		end

		if hook.Call("LavaCanClimbBrush", nil, Player, tr.HitTexture) == false then return end

		if MoveData:KeyDown(6) then
			MoveData:RemoveKey(6)
		end

		MoveData:SetMoveAngles(Angle(0, x.y + 180, 0))
		MoveData:SetForwardSpeed(1000)
		local cNetString = "" -- Way too much shit to use different NWvars for; why not have it done in one go?

		if MoveData:KeyDown(8) then
			cNetString = cNetString .. "1 " .. (MoveData:GetSideSpeed() / 10000 / 2)

			if SERVER and util.IsInWorld(Player:EyePos() + Vector(0, 0, Player:GetRunSpeed() / 40)) or CLIENT then
				MoveData:SetOrigin(MoveData:GetOrigin() + Vector(0, 0, Player:GetRunSpeed() / 40))
			end
		elseif MoveData:KeyDown(16) then
			cNetString = cNetString .. "-1 " .. (-MoveData:GetSideSpeed() / 10000 / 2)
			MoveData:SetOrigin(MoveData:GetOrigin() + Vector(0, 0, -Player:GetRunSpeed() / 40))
		else
			cNetString = cNetString .. "0 " .. (MoveData:GetSideSpeed() / 10000)
		end

		MoveData:SetMaxClientSpeed(100)
		Player:SetGroundEntity(Entity(0))
		cNetString = cNetString .. " " .. x.y + 180
		Player:SetProperVar("String", "$climbquery", cNetString)
	elseif SERVER then
		Player:SetProperVar("String", "$climbquery", "")
	elseif CLIENT then
		_cEnabled = false
	end
end)

local tr
local OldPos = Vector(0, 0, 0)
local OldAng = Angle(0, 0, 0)

hook.RunOnce("HUDPaint", function()
	ViewPanel = InitializePanel("ClimbViewPanel", "DPanel")
	ViewPanel:SetPaintedManually(true)
	ViewPanel:SetSize(ScrH() / 4, ScrH() / 4)
	ViewPanel:Center()
	ViewPanel:SetVerticalPos(0)
	ViewPanel:MakeBorder((ScrH() / 50):floor(), DarkColor)

	ViewPanel.Paint = function(s, w, h)
		local edge, col = (ScrH() / 20):floor(), GlobalCustomColor(true)

		if not s.HaveSet and LavaCenterHUD then
			s.HaveSet = true
			s:SetSize(LavaCenterHUD:GetSize())
			s:SetPos(LavaCenterHUD:GetPos())
		end

		tr = LocalPlayer():GetEyeTrace()
		local x, y = s:GetPos()
		draw.RoundedBox(0, 0, 0, w, h, color_white)
		OldPos = LerpVector(FrameTime() * 3, OldPos, LocalPlayer():EyePos() - (tr.HitNormal:Angle() + Angle(0, 180, 0)):Forward() * LocalPlayer():GetVelocity():Length():max(60))
		OldAng = LerpAngle(FrameTime() * 3, OldAng, tr.HitNormal:Angle() + Angle(0, 180, 0))
		cam.Start3D()
		ShouldDrawLP = true
		render.SetLightingMode(1)
		render.SuppressEngineLighting(true)

		render.RenderView{
			origin = OldPos,
			angles = OldAng,
			x = x,
			y = y,
			w = w,
			h = h,
			fov = 120,
			aspectratio = w / h,
			drawviewmodel = false
		}

		render.SuppressEngineLighting(false)
		render.SetLightingMode(0)
		cam.End3D()
		ShouldDrawLP = false
		draw.RoundedBox(0, 0, 0, w, edge, col)
		draw.RoundedBox(0, 0, h - edge, w, edge, col)
		draw.RoundedBox(0, 0, 0, edge, h, col)
		draw.RoundedBox(0, w - edge, 0, edge, h, col)
	end
end)

hook.Add("HUDPaint", "DrawClimbPanel", function()
	if ViewPanel and _cEnabled then
		ViewPanel:PaintManual()
	end
end)

hook.Add("ShouldDrawLocalPlayer", "DrawPreview", function()
	if ShouldDrawLP then return true end
end)