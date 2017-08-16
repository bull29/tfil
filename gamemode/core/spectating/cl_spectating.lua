local tShouldDisable
local tH
local tVH

hook.RunOnce("HUDPaint", function()
	tH = InitializePanel("LavaSpecHelperPanel", "DPanel")
	tH:SetSize(ScrW() / 4, ScrH() / 32 * 4.5)
	tH:SetMouseInputEnabled(false)
	tH:Center()
	tH:SetVerticalPos(ScrH() - tH:GetTall())
	tH.Paint = nil
	local hE = tH:Add("DLabel")
	hE:Dock(TOP)
	hE:SetText("Spectate Controls: ")
	hE:SetFont("lava_spectate_helper")

	hE.Paint = function(s, w, h)
		s:SetTextColor(pColor())
		if LocalPlayer():GetObserverMode() ~= 0 and LocalPlayer():GetObserverMode() ~= 6 then end
	end

	local function AddHelper(ui, name, key)
		local m_HaveTicked
		local h = tH:Add("DLabel")
		h:Dock(TOP)
		h:SetTall(ScrH() / 32)
		h:SetText(name)
		h:SetFont("lava_spectate_helper")

		h.Paint = function(s, w, h)
			local m_Press = LocalPlayer():KeyDown(key)
			s:SetTextColor(pColor() + (m_Press and 150 or 50))
			s:SetTextInset(h * 1.5, 0)
			draw.Rect(0, 0, h, h, m_Press and color_white or color_white - 50, ui)

			if not m_HaveTicked and m_Press then
				m_HaveTicked = true
				chat.PlaySound()
			elseif not m_Press and m_HaveTicked then
				m_HaveTicked = nil
			end
		end
	end

	AddHelper("gui/r.png", "Switch Spectate Mode", IN_RELOAD)
	AddHelper("gui/rmb.png", "Next Player", IN_ATTACK2)
	AddHelper("gui/lmb.png", "Last Player", IN_ATTACK)
	tH:Hide()
	tH:SetPaintedManually(true)
end)

hook.RunOnce("HUDPaint", function()
	tVH = InitializePanel("LavaSpectatingPlayerProfile", "DPanel")
	tVH:SetSize(ScrW() / 3, ScrH() / 2)
	tVH:Center()
	tVH:SetHorizontalPos(ScrW() / 100)
	tVH.Paint = nil
	tVH.Player = LocalPlayer()
	local tP = tVH:Add("DLabel")
	tP:Dock(TOP)
	tP:SetTall(ScrH() / 12)
	tP:SetTextInset(ScrH() / 11, 0)
	tP:SetFont("lava_spectate_title")

	tP.PaintOver = function(s, w, h)
		s:SetText(tVH.Player:Nick())
		s:SetTextColor(pColor())
	end

	local av = tP:Add("AvatarMask")
	av:SetSize(ScrH() / 12, ScrH() / 12)
	av:SetPlayer(LocalPlayer(), 184)

	av.PaintOver = function(s, w, h)
		s:SetPlayer(tVH.Player, 184)
		draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor())
	end

	local function AddHelper(iconfunc, exception)
		local eV = tVH:Add("DPanel")
		local eVOld
		local hCirclePanel
		eV:Dock(TOP)
		eV:SetTall(ScrH() / 16)
		eV:DockMargin(0, ScrH() / 200, 0, 0)
		eV.Paint = nil

		if exception then
			eVOld = eV
			eV = eV:Add("DCirclePanel")
			eV:SetSize(ScrH() / 16, ScrH() / 16)
			eV:SetHorizontalPos(ScrH() / 12 - ScrH() / 16 - ScrH() / 16 / 7)

			eV.PaintCircle = function(s, w, h)
				if hCirclePanel then
					hCirclePanel:PaintManual()
				end
			end
		end

		local iCO = eV:Add("DLabel")
		iCO:SetSize(ScrH() / 16, ScrH() / 16)
		iCO:SetHorizontalPos(exception and 0 or ScrH() / 12 - ScrH() / 16 - ScrH() / 16 / 7)
		iCO:SetContentAlignment(5)
		iCO:SetText("")
		iCO:SetFont("lava_spectate_hp")
		iCO:SetTextColor( color_white )
		iCO.Paint = function(s, w, h)
			if exception then
				iconfunc(tVH.Player, s, w, h)
				draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor())
			else
				draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor())
				iconfunc(tVH.Player, s, w, h)
			end
		end

		hCirclePanel = iCO

		if exception then
			iCO:SetPaintedManually(true)
		end
	end

	AddHelper(function(Player, s, w, h)
		s:SetText(((Player:Health() / Player:GetMaxHealth()) * 100):Round():Clamp(0, 100))
		local floor = (h / 20):floor()
		draw.WebImage(WebElements.CircleOutline, floor, floor, w - floor * 2, h - floor * 2, pColor())
		draw.WebImage(Emoji.Get(2628), h / 2, h / 2 + h / 20, w - h / 7, h - h / 7, nil, 0)
	end)

	AddHelper(function(Player, s, w, h)
		if not Abilities.Skills or not Abilities.Skills[Player:GetAbility()] then return end
		local floor = (h / 25):floor()
		draw.WebImage( Emoji.Get( Abilities.Skills[Player:GetAbility()][2] ), h / 2, h / 2, w - floor * 5, h - floor * 5, nil, CurTime():sin() * 5)
	end)

	local iDex = 1
	AddHelper(function(CurPlayer, s, w, h)
		local floor = (h / 20):floor()
		draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor() - 50)
		draw.WebImage(WebElements.Circle, floor, floor, w - floor * 2, h - floor * 2, (pColor() - 100))
		draw.WebImage(WebElements.CircleOutline, floor, floor, w - floor * 2, h - floor * 2, pColor())

		local tab = player.GetAlive()
		table.sort(tab, function(a, b) return (a:GetPos().z - Lava.GetLevel()) > (b:GetPos().z - Lava.GetLevel()) end)
		iDex = 1

		for Index, Player in pairs(tab) do
			if Player == CurPlayer then
				iDex = Index
				break
			end
		end

		if iDex < 4 then
			draw.WebImage(Emoji.Get(495), h / 2, h / 2, h, h, nil, -CurTime():cos() * 25)
			draw.WebImage(Emoji.Get(iDex == 1 and 2188 or iDex == 2 and 2189 or 2190), h / 2, h / 2, h * 0.8, h * 0.8, nil, CurTime():cos() * 30)
		else
			draw.WebImage(Emoji.Get(2189), h / 3, h / 3 * 2, h / 2, h / 2, nil, CurTime():sin() * 10)
			draw.WebImage(Emoji.Get(2190), h / 3 * 2, h / 3 * 2, h / 2, h / 2, nil, CurTime():sin() * -10)
			draw.WebImage(Emoji.Get(2188), h / 2, h / 3, h / 2, h / 2, nil, 0)
		end


		local ET = Emoji.ParseNumber(iDex)

		if iDex > 3 then
			for i = 1, #ET do
				draw.WebImage(Emoji.Get(ET[i]), h / (1 + #ET) + (i - 1) * h / 3, h / 2, h / 3, h / 3, nil, 0)
			end
		end
	end, true)

	AddHelper(function(Player, s, w, h)
		local floor = (h / 25):floor()
		draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor() - 50)
		draw.WebImage(WebElements.CircleOutline, floor, floor, w - floor * 2, h - floor * 2, pColor() - 20)
		s:SetText(((Player:GetPos().z - Lava.GetLevel()) / 52):floor() .. "m")
		draw.WebImage(Emoji.Get(1457), 0, 0, w, h, nil, CurTime():sin() * 15, true)
		draw.WebImage(Emoji.Get(2440), h / 6, h / 2 + CurTime():sin() * h / 4, h / 5, h / 5, nil, 0)
		draw.WebImage(Emoji.Get(531), w - h / 6, h / 2 + -CurTime():sin() * h / 4, h / 3, h / 3, nil, 0)
	end, true)

	tVH:Hide()
end)

hook.Add("HUDPaint", "RenderSpectateControls", function()
	if LocalPlayer():GetObserverMode() ~= 0 and not IsValid(LocalPlayer().m_Ragdoll) and tH then
		if not tH:IsVisible() then
			tH:Show()
		end

		tH:PaintManual()
	elseif tH and tH:IsVisible() then
		tH:Hide()
	end

	if SpectatingPlayer() and SpectatingPlayer():Alive() and not IsValid(LocalPlayer().m_Ragdoll) and tVH and not tShouldDisable then
		if not tVH:IsVisible() then
			tVH:Show()
		end
		tVH.Player = SpectatingPlayer()
		tVH:PaintManual()
	elseif tVH and tVH:IsVisible() then
		tVH:Hide()
	end
end)

hook.Add("OnContextMenuOpen", "DisableSpecContextRender", function()
	tShouldDisable = true
end)

hook.Add("OnContextMenuClose", "DisableSpecContextRender", function()
	tShouldDisable = false
end)

hook.Add("Lava.PopulateWidgetMenu", "AddSpecatorModeWidget", function( Context )
	Context.NewWidget("Spectating Mode", 2546, function()
		net.Start("lava_afk")
		net.SendToServer()
	end)
end)