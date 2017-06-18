local uicolors = {
	dark = Color(70, 70, 70)
}

local draw = draw
local hide = m_Table("CHudCrosshair", "CHudMenu", "CHudHealth")
local config = GM.GetConfig()

hook.Add("HUDShouldDraw", "HideHUD", function(name)
	if hide[name] then return false end
end)

hook.RunOnce("HUDPaint", function()
	local m = InitializePanel("LavaCenterHUD", "DPanel")
	m:SetPaintedManually(true)
	m:SetSize(ScrH() / 4, ScrH() / 4)

	m.Paint = function(s, w, h)
		draw.WebImage("http://i.imgur.com/UxNqnnM.png", 0, 0, w, h, uicolors.dark)
		draw.WebImage("http://i.imgur.com/UxNqnnM.png", w / 2, h / 2, w * 0.8, h * 0.8, GlobalCustomColor(true), 0, false)
	end

	m:SetPos(ScrH() / 45, ScrH() - ScrH() / 4 - ScrH() / 45)
	local md = m:Add("DModelPanel")
	md:Dock(FILL)

	local function fM()
		md:SetModel(LocalPlayer():GetModel())
		md:SetFOV(25)
		md.DefaultCam = md.DefaultCam or md:GetCamPos()
		md:SetCamPos(md.DefaultCam + Vector(80, 80, 0))

		function md.Entity:GetPlayerColor()
			return LocalPlayer():GetPlayerColor()
		end

		md.Entity:SetAngles(Angle(0, 45, 0))
		local ShouldZerofiy = false

		md.LayoutEntity = function(s, ent)
			if not LocalPlayer():Alive() then
				if ShouldZerofiy then
					ent:SetCycle(0)
					ShouldZerofiy = false
				end

				ent:ResetSequence(ent:LookupSequence("death_04"))
				s:RunAnimation()

				return
			end

			ShouldZerofiy = true
			local l = LocalPlayer()
			ent:SetSequence(l:GetSequence())
			ent:SetPlaybackRate(l:GetPlaybackRate())
			ent:SetCycle(l:GetCycle())

			for i = 1, l:GetNumPoseParameters() - 1 do
				ent:SetPoseParameter(ent:GetPoseParameterName(i), l:GetPoseParameter(ent:GetPoseParameterName(i)))
			end
		end
	end

	fM()

	m.Think = function()
		if md:GetModel() ~= LocalPlayer():GetModel() then
			fM()
		end
	end
end)

hook.RunOnce("HUDPaint", function()
	local l_Altimeter = InitializePanel("LavaAltimeter", "DPanel")
	l_Altimeter:SetSize(ScrW(), ScrW() / 50)

	l_Altimeter.Paint = function(s, w, h)
		local cfg = config.GetRadarRange()

		if s.ShouldDraw then
			s:SetPos(0, (s:GetVerticalPos() + FrameTime()):min(-1))
		else
			s:SetPos(0, (s:GetVerticalPos() - 1):max(-h + 1))
		end

		draw.RoundedBox(0, 0, 0, w, h, uicolors.dark:Alpha(150))
		draw.RoundedBox(0, 0, 0 or h / 5, w, h - h / 5 * 2, GlobalCustomColor(true):Alpha(150))
		cam.Start3D()
		s.ShouldDraw = false
		local tab = {}

		for Player in Values(player.GetAll()) do
			local toScreen = Player:EyePos():ToScreen()

			if Player:GetPos():Distance(LocalPlayer():GetPos()) < cfg and toScreen.visible and Player:Alive() and Player ~= LocalPlayer() then
				tab[Player] = toScreen.x
			end
		end

		cam.End3D()

		for Player, Vec in pairs(tab) do
			local col = Player:GetPlayerColor()
			local x = Player:GetPos():Distance(LocalPlayer():GetPos())
			s.ShouldDraw = true
			col = Color(col.r * 255, col.g * 255, col.b * 255)
			draw.WebImage("http://i.imgur.com/UxNqnnM.png", Vec - ScrW() / 70 / 2, -(ScrW() / 70 + (cfg / 50 - x / 50)) / 2 + -ScrH() / 150, ScrW() / 70 + (cfg / 50 - x / 50), ScrW() / 70 + (cfg / 50 - x / 50), col)
		end
	end
end)

hook.RunOnce("HUDPaint", function()
	local tM = InitializePanel("TimerPanel", "DLabel")
	tM:SetSize(ScrH() / 5, ScrH() / 10)
	tM:SetContentAlignment( 5 )
	tM:SetTextInset(ScrH() / 50, 0)
	tM:SetFont("lava_round_timer")
	tM.OldText = ""
	tM.Paint = function(s, w, h)

		draw.RoundedBox(4, 0, 0, w, h, uicolors.dark)
		draw.RoundedBox(4, h/10, h/10, w - h/10*2, h - h/10*2, GlobalCustomColor( true ))
		s:SetText(GetGlobalString("$RoundTime","00:00"))
		if s.OldText ~= s:GetText() then
			s.OldText = s:GetText()
			if s.OldText:EndsWith("0") then
				chat.PlaySound()
			end
		end
	--	s:SetTextColor( GlobalCustomColor( true ) *1.5)
	end

	tM:SetPos(ScrW() - ScrH() / 5 - ScrH() / 45, ScrH() - ScrH() / 14 - ScrH() / 45 * 2)
end)

hook.Add("HUDPaint", "RenderDermaHUD", function()
	if LavaCenterHUD then
		LavaCenterHUD:PaintManual()
	end
end)
--[[ 
	if LavaAltimeter then
		LavaAltimeter:PaintManual()
	end--]]