local Gray = Color(0, 0, 0, 150)
local s
local Datapoints = {}

local function AddDatapoint( func )
	table.insert( Datapoints, func  )
end

AddDatapoint( function( Player )
	return Player:Ping()
end)

hook.RunOnce("HUDPaint", function()
	s = InitializePanel("LavaScore", "DPanel")
	s:SetSize(ScrW() * 0.6, ScrH() * 0.8)
	s:Center()

	s.Paint = function(s, w, h)
		draw.Rect(0, 0, w, h, Gray)
		draw.Rect(0, 0, w, h / 7, pColor() - 100)
		draw.Rect(0, h / 7, w, 1, pColor() - 50)
		draw.SimpleText(GetHostName(), "lava_score_title", h / 7, h / 14, nil, nil, TEXT_ALIGN_CENTER)
		draw.SimpleText("You're playing on:", "lava_score_title_sub", h / 7 * 0.9, h / 14 * 0.6, nil, nil, TEXT_ALIGN_CENTER)
	end

	local m = s:Add("DCirclePanel")
	m:SetPos(ScrH() * 0.8 / 8 / 16, ScrH() * 0.8 / 8 / 16)
	m:SetSize(ScrH() * 0.8 / 8, ScrH() * 0.8 / 8)

	m.PaintCircle = function(s, w, h)
		draw.WebImage(Emoji.Get(328), w / 2, h / 2, w, h, nil, CurTime():cos() * -15)
		draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor() - 50)
	end

	local l = s:Add("DScrollPanel")
	s.Canvas = l
	local m_H = l:GetVBar():GetChildren()[2]:GetTall() * 0.7
	local ts = l:GetVBar():GetChildren()[3]
	l:Dock(FILL)
	l:DockMargin(0, ScrH() * 0.8 / 6.9, 0, 0)
	l.Paint = function() end
	l:GetVBar():GetChildren()[1].Paint = nil
	l:GetVBar():GetChildren()[2].Paint = nil
	local tab = ts:GenerateColorShift("sMA", pColor() - 50, pColor(), 255)

	ts.Paint = function(s, w, h)
		tab[1], tab[2] = pColor() - 50, pColor()
		s:Declip(function()
			draw.Rect(0, -m_H, w, h + m_H * 2, s.sMA)
		end)
	end

	function l:Repopulate()
		self:GetCanvas():RemoveChildren()

		local function AddPlayer(Player, Section )
			local p = l:Add("DLabel")
			p:Dock(TOP)
			p:SetMouseInputEnabled( true )
			p:SetTall(ScrH() / 25)
			p:SetTextColor(color_white)
			p:SetFont("lava_score_player_row")
			p:SetTextInset(ScrW() / 40, 0)
			local tab = p:GenerateColorShift("sMA", Player:PlayerColor(), Player:PlayerColor() + 25, 128)
			p.Paint = function(s, w, h)
				if not IsValid( Player ) then
					s:Remove()
					return
				end
				if Section == "P" and not Player:Alive() then
					s:Remove()
					AddPlayer( Player, "S" )
					return
				end
				tab[1], tab[2] = Player:PlayerColor(), Player:PlayerColor() + 25,
				draw.Rect(0, 0, w, h, s.sMA)
				s:SetText(Player:Nick())
			end

			local v = p:Add("AvatarImage")
			v:SetSize(ScrH() / 25 - WebElements.Edge/2, ScrH() / 25 - WebElements.Edge/2)
			v:SetPos(WebElements.Edge / 4, WebElements.Edge / 4)
			v:SetPlayer(Player, 184)
			v:MakeBorder( WebElements.Edge/2, Player:GetPlayerColor():ToColor() - 50 )
		end

		local aHeader = l:Add("DLabel")
		aHeader:Dock(TOP)
		aHeader:SetTall(ScrH() / 25)
		aHeader:SetFont("lava_score_header")
		aHeader:SetText("Players")
		aHeader:SetTextColor(color_white)
		aHeader:SetTextInset(ScrW() / 100, 0)

		aHeader.Paint = function(s, w, h)
			draw.Rect(0, 0, w, h, pColor() - 75)
		end

		for Player in Values(player.GetAlive()) do
			AddPlayer(Player, "P")
		end

		local bHeader = l:Add("DLabel")
		bHeader:Dock(TOP)
		bHeader:SetTall(ScrH() / 25)
		bHeader:SetFont("lava_score_header")
		bHeader:SetText("Spectators")
		bHeader:SetTextInset(ScrW() / 100, 0)

		bHeader.Paint = function(s, w, h)
			draw.Rect(0, 0, w, h, pColor() - 75)
		end

		for Player in Values(player.GetDead()) do
			AddPlayer(Player, "S")
		end
	end

	l:Repopulate()
end)

function GM:ScoreboardShow()
	if s then
		s:Show()
		s.Canvas:Repopulate()
		s:MakePopup()
	end
end

function GM:ScoreboardHide()
	if s then
		s:Hide()
	end
end

