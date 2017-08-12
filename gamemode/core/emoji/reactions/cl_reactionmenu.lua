local function PointOnCircle(ang, radius, offX, offY)
	ang = math.rad(ang)
	local x = math.cos(ang) * radius + offX
	local y = math.sin(ang) * radius + offY

	return x, y
end


local m_ChatVis
local draw = draw
local White = color_white
local surface = surface
local Color = Color
local Defaults = {1600, 1599, 1631, 1723, 1562, 1329, 385, 396, 1340, 2, 1318, 1463, 1457, 1462, 1622, 9}

if not file.Exists("tfil/emojireactions.txt", "DATA") then
	file.Write("tfil/emojireactions.txt", util.TableToJSON(Defaults))
end

local Emotes = file.Read("tfil/emojireactions.txt"):JSONDecode()
local ValueTable = {}

local function UpdateValueTable()
	table.Empty(ValueTable)

	for k, v in pairs(Emotes) do
		ValueTable[v] = true
	end
end

hook.RunOnce("HUDPaint", function()
	local ls = InitializePanel("LavaReactionMenuPane", "DLabel")
	ls:SetSize(ScrH() * 0.75, ScrH() * 0.75)
	ls:Center()
	ls:SetText("")
	ls:SetMouseInputEnabled(true)
	local config = ls:Add("DButton")
	local LastHovered

	ls.Paint = function(s, w, h)
		local HoveredChild = IsValid(vgui.GetHoveredPanel()) and vgui.GetHoveredPanel().IsEmojiButton and vgui.GetHoveredPanel()

		if not HoveredChild then
			config:Show()
		else
			config:Hide()
		end

		if s.Hovered or HoveredChild then
			local p = pColor()
			surface.SetDrawColor(p.r, p.g, p.b)
			surface.DrawLine(w / 2, h / 2, s:LocalCursorPos())
		end

		if HoveredChild then
			LastHovered = HoveredChild
			draw.WebImage(Emoji.Get(HoveredChild.Emoji), w / 2, h / 2, w * 0.15, h * 0.15, nil, 0)
		else
			LastHovered = nil
		end
	end

	config:SetSize(ScrH() / 20, ScrH() / 20)
	config:SetText""
	config:GenerateColorShift("smo", White - 100, White, 512)

	config.Paint = function(s, w, h)
		config:Center()
		draw.WebImage(Emoji.Get(2528), w / 2, h / 2, w, h, s.smo, CurTime():cos() * 25)
	end

	ls.Repopulate = function()
		for k, v in pairs(ls:GetChildren()) do
			if v ~= config then
				v:Remove()
			end
		end

		local h = 1

		for i = 1, 360, 360 / #Emotes do
			local x, y = PointOnCircle(i, ls:GetWide() / 2 * 0.8, ls:GetWide() / 2, ls:GetTall() / 2)
			local t = ls:Add("DButton")
			t:SetPos(x - ScrH() / 14, y - ScrH() / 14)
			t:SetSize(ScrH() / 7, ScrH() / 7)
			t:SetText("")
			t.IsEmojiButton = true
			t.Emoji = Emotes[h]
			h = h + 1
			local xaf = t:GenerateColorShift("csm", pColor() - 25, pColor() + 25, 512)
			t:GenerateColorShift("csmvf", White - 100, White, 725)

			t.Paint = function(s, w, h)
				xaf[1], xaf[2] = pColor() - 25, pColor() + 25
				draw.WebImage(WebElements.CircleOutline, w / 2, h / 2, w * 0.9, h * 0.9, pColor() - 100, 0)
				draw.WebImage(s.Hovered and WebElements.QuadCircle or WebElements.CircleOutline, w / 2, h / 2, w, h, s.csm, s.Hovered and CurTime():sin() * 180 or 0)
				draw.WebImage(Emoji.Get(s.Emoji), w / 2, h / 2, w * 0.6, h * 0.6, s.csmvf, CurTime():cos() * (s.Hovered and 50 or 5))
			end
		end
	end

	ls.Repopulate()
	ls:Hide()
	local m_WasVisible = false

	hook.Add("StartChat", "Addm_ChatVis", function()
		m_ChatVis = true
	end)

	hook.Add("FinishChat", "Addm_ChatVis", function()
		m_ChatVis = nil
	end)

	hook.Add("Think", "DrawEmojiPane", function()
		if input.IsKeyDown(KEY_G) and LocalPlayer():Alive() and not gui.IsGameUIVisible() and not m_ChatVis then
			if not ls:IsVisible() then
				ls:Show()
			end

			if not vgui.CursorVisible() and not m_WasVisible then
				gui.EnableScreenClicker(true)
				m_WasVisible = true
			end
		elseif ls:IsVisible() then
			if LastHovered then
				RunConsoleCommand("say", "$" .. LastHovered.Emoji)
				LastHovered = nil
			end

			ls:Hide()

			if m_WasVisible then
				gui.EnableScreenClicker(false)
				m_WasVisible = nil
			end
		end
	end)

	local function MakeHelperPanel()
		local eui = InitializePanel("EmojiConfigureUI", "DPanel")
		eui:SetSize(ScrW() / 3, ScrH() * 0.4)
		eui:Center()

		eui.Paint = function(s, w, h)
			draw.Rect(0, 0, w, h, pColor() - 50)

			if not vgui.CursorVisible() then
				gui.EnableScreenClicker(true)
			end
		end

		local cD = eui:Add("DPanel")
		cD:Dock(BOTTOM)
		local Close = cD:Add("DButton")
		Close:Dock(RIGHT)
		Close:SetWide(ScrH() / 6)
		Close:SetText("Close")
		Close:SetFont("lava_emoji_reaction_textpane")
		Close:SetTextColor(color_white)
		Close:GenerateColorShift("aLp", pColor(), pColor() + 50, 255)

		Close.Paint = function(s, w, h)
			draw.Rect(0, 0, w, h, s.aLp)
		end

		Close.DoClick = function()
			eui:Remove()
			gui.EnableScreenClicker(false)
		end

		local DefaultValues = cD:Add("DButton")
		DefaultValues:Dock(LEFT)
		DefaultValues:SetWide(ScrH() / 6)
		DefaultValues:SetFont("lava_emoji_reaction_textpane")
		DefaultValues:SetTextColor(color_white)
		DefaultValues:SetText("Restore Defaults")
		DefaultValues:GenerateColorShift("aLp", pColor(), pColor() + 50, 255)

		DefaultValues.Paint = function(s, w, h)
			draw.Rect(0, 0, w, h, s.aLp)
		end

		DefaultValues.DoClick = function()
			file.Write("tfil/emojireactions.txt", util.TableToJSON(Defaults))
			Emotes = table.Copy(Defaults)
			ls.Repopulate()
			eui:Remove()
			gui.EnableScreenClicker(false)
		end

		local bar = eui:Add("DLabel")
		bar:Dock(BOTTOM)
		bar:SetText""
		bar:SetTall(ScrH() / 10)
		bar:SetMouseInputEnabled(true)

		bar.Paint = function(s, w, h)
			draw.Rect(0, 0, w, h, pColor() - 100)
		end

		local co = bar:Add("DIconLayout")
		co:Dock(FILL)
		co:DockMargin(WebElements.Edge * 1.5, WebElements.Edge, WebElements.Edge * 1.5, WebElements.Edge)
		co:SetSpaceX(WebElements.Edge)
		co:SetSpaceY(WebElements.Edge)

		local function RepopulateBar()
			co:RemoveChildren()

			for Emote in Values(Emotes) do
				local d = co:Add("DLabel")
				d:SetText("")
				d:SetSize((eui:GetWide() / #Emotes):min(ScrH() / 20), (eui:GetWide() / #Emotes):min(ScrH() / 20))
				d:SetMouseInputEnabled(true)
				d:GenerateColorShift("pma", Color(170, 170, 170), White, 512)

				d.Paint = function(s, w, h)
					draw.WebImage(Emoji.Get(s.Hovered and 1581 or Emote), 0, 0, w, h, s.pma)
				end

				d.DoClick = function()
					if #Emotes == 1 then return end
					table.RemoveByValue(Emotes, Emote)
					file.Write("tfil/emojireactions.txt", util.TableToJSON(Emotes))
					UpdateValueTable()
					ls.Repopulate()
					RepopulateBar()
				end
			end
		end

		RepopulateBar()
		local sc = eui:Add("lava_scroller")
		sc:Dock(FILL)
		local dp = sc:Add("DIconLayout")
		dp:DockMargin(WebElements.Edge * 1.5, WebElements.Edge * 1.5, WebElements.Edge, WebElements.Edge)
		dp:Dock(FILL)
		dp:SetSpaceX(WebElements.Edge / 2)
		dp:SetSpaceY(WebElements.Edge / 2)

		for i = 1, #Emoji.Index do
			local ex = dp:Add("DLabel")
			ex:SetSize(eui:GetWide() / 10, eui:GetWide() / 10)
			ex:SetMouseInputEnabled(true)
			ex:SetText("")
			ex:GenerateColorShift("ma", Color(120, 120, 120), White, 512)

			ex.Paint = function(s, w, h)
				draw.WebImage(Emoji.Get(i), 0, 0, w, h, s.ma)
			end

			ex.DoClick = function(s, w, h)
				if ValueTable[i] then return end
				table.insert(Emotes, i)
				file.Write("tfil/emojireactions.txt", util.TableToJSON(Emotes))
				UpdateValueTable()
				ls.Repopulate()
				RepopulateBar()
			end
		end
	end

	config.DoClick = MakeHelperPanel
end)

hook.Add("StartChat", "DrawEmoteBox", function()
	local SizeX, SizeY = chat.GetChatBoxSize()
	local x, y = chat.GetChatBoxPos()
	local Ratio = SizeX / (SizeY / 3 + WebElements.Edge)
	local ao = InitializePanel("ChatEmoteIndicator", "DIconLayout")
	ao:SetSize(SizeX, SizeY / 3 + WebElements.Edge * 2)
	ao:SetPos(x, y - SizeY / 3 - WebElements.Edge * 3)
	ao:SetSpaceX(WebElements.Edge * 2)

	for i = 0, (Ratio):floor() - 1 do
		if not Emotes[#Emotes - i] then continue end
		local t = ao:Add("DButton")
		t:SetText("")
		t:SetSize(SizeY / 3, SizeY / 3)
		t:GenerateColorShift("smd", color_white - 100, color_white, 512)

		t.Paint = function(s, w, h)
			draw.WebImage(WebElements.Circle, w / 2, h / 2, w * 0.98, h * 0.98, pColor() - 100, 0)
			draw.WebImage(s.Hovered and WebElements.QuadCircle or WebElements.CircleOutline, 0, 0, w, h, pColor(), s.Hovered and CurTime():cos() * 180, true)
			draw.WebImage(Emoji.Get(Emotes[#Emotes - i]), w / 2, h / 2, w * 0.7, h * 0.7, s.smd, s.Hovered and CurTime():cos() * 20 or 0)

			if s.Hovered then
				local x, y = s:LocalCursorPos()
				s:Declip(function()
					draw.SimpleText( "Hold G in-game & click the center to edit", "ChatFont", x, y - ScrH()/15, White:Alpha( 50 ), 0 )
				end)
			end
		end

		t.DoClick = function()
			RunConsoleCommand("say", "$" .. Emotes[#Emotes - i])
		end
	end
end)

hook.Add("FinishChat", "RemoveEmotes", function()
	if ChatEmoteIndicator then
		ChatEmoteIndicator:Remove()
		ChatEmoteIndicator = nil
	end
end)