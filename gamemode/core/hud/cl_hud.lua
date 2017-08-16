local draw = draw
local WebElements = WebElements
local pColor = pColor
local color_white = color_white
local rTab = {}
local tonumber = tonumber
local tPane
local m_HavePlayedSound

local tTranslateTable = {
	snooze = "Snooze",
	preround = "Preparation",
	started = "In Progress",
	ended = "Postround"
}

hook.RunOnce("HUDPaint", function()
	local g = InitializePanel("LavaMainCircleHUD", "DLabel")
	g:SetText("")
	local x = g:Add("AvatarMask")
	g:SetSize(ScrH() / 5, ScrH() / 5)
	g:SetPos(ScrH() / 50, ScrH() - ScrH() / 5 - ScrH() / 50)

	g.Paint = function(s, w, h)
		x:PaintManual()
		local floor = (h / 25):floor()

		if Mutators.IsActive("Mystery Men") then
			draw.WebImage(Emoji.Get(1531), h / 5, h / 2 + h / 10, h / 4, w / 4, color_white:Alpha(200), -45, true)
		end

		draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor())
		draw.WebImage(WebElements.CircleOutline, floor, floor, w - floor * 2, h - floor * 2, pColor() - 50)
	end

	x:Dock(FILL)
	x:DockMargin((g:GetTall() / 25):floor() * 2, (g:GetTall() / 25):floor() * 2, (g:GetTall() / 25):floor() * 2, (g:GetTall() / 25):floor() * 2)
	x:SetPaintedManually(true)
	x:SetPlayer(LocalPlayer(), 184)
	--;;
	local h = InitializePanel("LavaMainHealthHUD", "DLabel")
	h:SetSize(ScrH() / 10, ScrH() / 10)
	h:SetContentAlignment(5)
	h:SetFont("lava_altimeter_panel")
	h:SetTextColor(Color(255, 255, 255))
	h:SetPos(ScrH() / 50, ScrH() - ScrH() / 5 - ScrH() / 50 * 6)

	h.Paint = function(s, w, h)
		s:SetText(((LocalPlayer():Health() / LocalPlayer():GetMaxHealth()) * 100):Round():Clamp(0, 100))
		local floor = (h / 20):floor()
		draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor() - 50)
		draw.WebImage(WebElements.Circle, floor, floor, w - floor * 2, h - floor * 2, (pColor() - 100))
		draw.WebImage(Emoji.Get(2628), h / 4.8, h / 4, w - h / 2.4, h - h / 2.4)
		draw.WebImage(WebElements.CircleOutline, floor, floor, w - floor * 2, h - floor * 2, pColor())
	end

	--;; -- This HUD element is a placeholder for an upcoming feature: Gadgets and Equipment.
	local t = InitializePanel("LavaMainToolbar", "DLabel")
	local tt = t:Add("DCirclePanel")
	tt:SetPaintedManually(true)
	tt:Dock(FILL)
	tt:DockMargin(WebElements.Edge * 2, WebElements.Edge * 2, WebElements.Edge * 2, WebElements.Edge * 2)
	t:SetSize(ScrH() / 10, ScrH() / 10)
	t:SetContentAlignment(5)
	t:SetFont("ChatFont")
	t:SetPos(ScrH() / 4 - ScrH() / 30, ScrH() - ScrH() / 10 - ScrH() / 50 * 7.6)
	t:SetText""
	local iDex = 1

	t.Paint = function(s, w, h)
		local floor = (h / 20):floor()
		draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor() - 50)
		draw.WebImage(WebElements.Circle, floor, floor, w - floor * 2, h - floor * 2, (pColor() - 100))
		draw.WebImage(WebElements.CircleOutline, floor, floor, w - floor * 2, h - floor * 2, pColor())
		tt:PaintManual()
		local tab = player.GetAlive()
		table.sort(tab, function(a, b) return (a:GetPos().z - Lava.GetLevel()) > (b:GetPos().z - Lava.GetLevel()) end)
		iDex = 1

		for Index, Player in pairs(tab) do
			if Player == LocalPlayer() then
				iDex = Index
				break
			end
		end

		local ET = Emoji.ParseNumber(iDex)

		if iDex > 3 then
			for i = 1, #ET do
				draw.WebImage(Emoji.Get(ET[i]), h / (1 + #ET) + (i - 1) * h / 3, h / 2, h / 3, h / 3, nil, 0)
			end
		end
	end

	tt.PaintCircle = function(s, w, h)
		if iDex < 4 then
			draw.WebImage(Emoji.Get(495), h / 2, h / 2, h, h, nil, -CurTime():cos() * 25)
			draw.WebImage(Emoji.Get(iDex == 1 and 2188 or iDex == 2 and 2189 or 2190), h / 2, h / 2, h * 0.8, h * 0.8, nil, CurTime():cos() * 30)
		else
			draw.WebImage(Emoji.Get(2189), h / 3, h / 3 * 2, h / 2, h / 2, nil, CurTime():sin() * 10)
			draw.WebImage(Emoji.Get(2190), h / 3 * 2, h / 3 * 2, h / 2, h / 2, nil, CurTime():sin() * -10)
			draw.WebImage(Emoji.Get(2188), h / 2, h / 3, h / 2, h / 2, nil, 0)
		end
	end

	--
	local c = InitializePanel("LavaAbilityPane", "DLabel")
	c:SetText("")
	local a = c:Add("DCirclePanel")
	c:SetSize(ScrH() / 8, ScrH() / 8)
	c:SetPos(ScrH() / 4.4, ScrH() - ScrH() / 8 - ScrH() / 40)

	c.Paint = function(s, w, h)
		local floor = (h / 25):floor()
		draw.WebImage(WebElements.Circle, floor, floor, w - floor * 2, h - floor * 2, (pColor() - 100))
		draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor() - 50)
		draw.WebImage(WebElements.CircleOutline, floor, floor, w - floor * 2, h - floor * 2, pColor() - 20)
		a:PaintManual()
	end

	a:Dock(FILL)
	a:SetPaintedManually(true)
	a:DockMargin((c:GetTall() / 25):floor() * 2, (c:GetTall() / 25):floor() * 2, (c:GetTall() / 25):floor() * 2, (c:GetTall() / 25):floor() * 2)

	a.PaintCircle = function(s, w, h)
		if not Abilities.Skills or not Abilities.Skills[LocalPlayer():GetAbility()] then return end
		local floor = (h / 25):floor()
		draw.WebImage(Emoji.Get(Abilities.Skills[LocalPlayer():GetAbility()][2]), h / 2, h / 2, w - floor * 5, h - floor * 5, nil, CurTime():sin() * 5)
	end

	--
	local d = InitializePanel("LavaAltimeterPane", "DLabel")
	local k = d:Add("DCirclePanel")
	d:SetSize(ScrH() / 10, ScrH() / 10)
	d:SetContentAlignment(5)
	d:SetPos(ScrH() / 7.5, ScrH() - ScrH() / 4 - ScrH() / 16)
	k:Dock(FILL)
	d:SetFont("lava_altimeter_panel")
	d:SetTextColor(color_white)
	k:SetPaintedManually(true)
	k:DockMargin((k:GetTall() / 25 / 2):floor() * 2, (k:GetTall() / 25 / 2):floor() * 2, (k:GetTall() / 25 / 2):floor() * 2, (k:GetTall() / 25 / 2):floor() * 2)

	d.Paint = function(s, w, h)
		local floor = (h / 25):floor()
		draw.WebImage(WebElements.Circle, floor, floor, w - floor * 2, h - floor * 2, (pColor() - 100))
		k:PaintManual()
		draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor() - 50)
		draw.WebImage(WebElements.CircleOutline, floor, floor, w - floor * 2, h - floor * 2, pColor() - 20)
		s:SetText(((LocalPlayer():GetPos().z - Lava.GetLevel()) / 52):Round(1) .. "m")
	end

	k.PaintCircle = function(s, w, h)
		draw.WebImage(Emoji.Get(1457), 0, 0, w, h, nil, CurTime():sin() * 15, true)
		draw.WebImage(Emoji.Get(2440), h / 6, h / 2 + CurTime():sin() * h / 4, h / 5, h / 5, nil, 0)
		draw.WebImage(Emoji.Get(531), w - h / 6, h / 2 + -CurTime():sin() * h / 4, h / 3, h / 3, nil, 0)
	end

	-- 1499
	local o = InitializePanel("LavaTimerPanel", "DLabel")
	o:SetText("")
	tPane = o
	o:SetSize(ScrH() / 5, ScrH() / 5)
	o:SetPos(ScrW() - ScrH() / 6 - ScrH() / 20, ScrH() / 50)

	o.Paint = function(s, w, h)
		local floor = (h / 25):floor()
		local x = GetGlobalString("$RoundTime", "00:00"):Split(":")
		if not x or not x[1] or not x[2] then return end
		local min = Emoji.ParseNumber(x[1])
		local sec = Emoji.ParseNumber(x[2])
		local size = h / 8

		if tonumber(x[2]) == 0 and not m_HavePlayedSound then
			m_HavePlayedSound = true
			surface.PlaySound("ambient/alarms/warningbell1.wav")
		elseif m_HavePlayedSound then
			m_HavePlayedSound = nil
		end

		for i = 1, #min do
			draw.WebImage(Emoji.Get(min[i]), size * 2.5 + size * (i - 1), h / 2, size, size, nil, 0)
		end

		for i = 1, #sec do
			draw.WebImage(Emoji.Get(sec[i]), h / 2 + size / 2 + size * (i - 1), h / 2, size, size, nil, 0)
		end

		draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor() - 50)
		draw.WebImage(WebElements.CircleOutline, floor, floor, w - floor * 2, h - floor * 2, pColor() - 20)
		draw.WebImage(WebElements.ClockHand, h / 2, h / 2, w * 1.2, h * 1.2, nil, -x[2] * 6)
		draw.WebImage(WebElements.ClockHand, h / 2, h / 2, w * 0.8, h * 0.8, nil, -x[1] * 6 * 5 - (x[2] / 60 * 6) * 5) --- ( x[2]/60 ) ))

		s:Declip(function()
			local var = (h / 25):ceil()
			draw.RoundedBox(8, 0, h * 1.05, w, h / 5, pColor() - 50)
			draw.RoundedBox(8, var, var / 2 + h * 1.05, w - var * 2, h / 5 - var, pColor())

			if tTranslateTable[GetGlobalString("$RoundState", "_"):lower()] then
				draw.SimpleText(tTranslateTable[GetGlobalString("$RoundState", "_"):lower()]:upper(), "lava_hud_state", w / 2, h * 1.05 + h / 30, nil, 1, 0)
			end

			if Mutators.GetActive() then
				local width = FontFunctions.GetWide(Mutators.GetActive():upper(), "lava_hud_state")
				draw.RoundedBox(8, w - width * 1.2, h * 1.3, width * 1.2, h/5, pColor() - 75)
				draw.RoundedBox(8, var/2 + w - width * 1.2, var/2 + h * 1.3, width * 1.2- var, h/5 - var, pColor())
				draw.SimpleText( Mutators.GetActive():upper(), "lava_hud_state", w - var, h * 1.3 + h/10, nil, 2, 1 )
			end
		end)
	end

	rTab[d] = true
	rTab[g] = true
	rTab[h] = true
	rTab[o] = true
	rTab[c] = true
	rTab[t] = true

	for Element in pairs(rTab) do
		Element:SetPaintedManually(true)
		Element:SetMouseInputEnabled(true)
		Element.HaveStartedDrag = false

		Element.DoClick = function(s)
			if s.HaveStartedDrag then end
			s.HaveStartedDrag = not s.HaveStartedDrag
		end

		local v = Element:GenerateOverwrite("PaintOver")

		Element.PaintOver = function(s, w, h)
			v(s, w, h)

			if s.HaveStartedDrag and input.IsKeyDown(KEY_C) then
				local x, y = gui.MousePos()
				s:SetPos(x - w / 2, y - h / 2)
			end
		end
	end
end)

hook.Add("HUDPaint", "RenderLavaElements", function()
	if not LocalPlayer():Alive() then
		if tPane then
			tPane:PaintManual()
		end

		return
	end

	for Element in pairs(rTab) do
		Element:PaintManual()
	end
end)

local tDisable = m_Table("CHudCrosshair", "CHudMenu", "CHudHealth", "CHudZoom")

function GM:HUDShouldDraw(n)
	return not tDisable[n]
end