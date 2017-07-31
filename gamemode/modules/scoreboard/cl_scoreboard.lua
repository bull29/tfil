local Gray = Color(0, 0, 0, 150)
local s
local Datapoints = {}
local Flag = "https://steamcommunity-a.akamaihd.net/public/images/countryflags/${1}.gif"
local game = game
local draw = draw
local pColor = pColor
local Config = Config

local function AddDatapoint( icon, name, func )
	table.insert( Datapoints, { icon, name, func }  )
end


hook.RunOnce("HUDPaint", function()
	hook.Call( "Lava.PopulateScoreboardPlayerButtons", nil, AddDatapoint )

	s = InitializePanel("LavaScore", "DPanel")
	s:SetSize(ScrW() * 0.6, ScrH() * 0.8)
	s:Center()

	s.Paint = function(s, w, h)
		draw.Rect(0, 0, w, h, Gray)
		draw.Rect(0, 0, w, h / 7, pColor() - 100)
		draw.Rect(0, h / 7, w, 1, pColor() - 50)
		draw.SimpleText(GetHostName(), "lava_score_title", h / 7, h / 14, nil, nil, TEXT_ALIGN_CENTER)
		draw.SimpleText("You're playing on: ", "lava_score_title_sub", h / 7 * 0.9, h / 14 * 0.6, nil, nil, TEXT_ALIGN_CENTER)
	end

	local b = s:Add("DPanel")
	b:Dock( BOTTOM )
	b:SetTall( ScrH()/25 )
	b.Paint = function( s, w, h )
		draw.Rect( 0, 0, w, h, pColor() - 100 )
		draw.WebImage( Emoji.Get( 835 ), h/2, h/2, h * 0.9, h * 0.9, nil, 0 )
		draw.SimpleText( player.GetCount() .. "/" .. game.MaxPlayers(), "lava_score_title_sub", h * 1.2, h/2, nil, 0, 1 )

		draw.WebImage( Emoji.Get( 330 ), w - h/2, h/2, h * 0.85, h * 0.85, nil, 0 )
		draw.SimpleText( game.GetMap(), "lava_score_title_sub", w - h * 1.2, h/2, nil, 2, 1 )

		draw.SimpleText( (Config.GetMapSwitchTime() - GetGlobalInt("$NextMapTime", 0 ):max( 0 ) .. " Round(s) until the next map. "), "lava_score_title_sub", w/2, h/2, nil, 1, 1 )
	end
	local m = s:Add("DCirclePanel")
	m:SetPos(ScrH() * 0.8 / 8 / 16, ScrH() * 0.8 / 8 / 16)
	m:SetSize(ScrH() * 0.8 / 8, ScrH() * 0.8 / 8)

	m.PaintCircle = function(s, w, h)
		draw.WebImage(Emoji.Get(328), w / 2, h / 2, w, h, nil, CurTime():cos() * -15)
		draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor() - 50)
	end

	local l = s:Add("lava_scroller")
	l:DockMargin(0, ScrH() * 0.8 / 6.9, 0, 0)
	l:Dock(FILL)
	s.Canvas = l

	function l:Repopulate()
		self:GetCanvas():RemoveChildren()

		local function AddPlayer(Player, Section )
			local p = l:Add("DLabel")
			p:Dock(TOP)
			p:SetMouseInputEnabled( true )
			p:SetTall(ScrH() / 25)
			p:SetText("")
			p.InitialHeight = p:GetTall()
			local tab = p:GenerateColorShift("sMA", Player:PlayerColor() * 0.75, Player:PlayerColor(), 128)
			p.Paint = function(s, w, h)
				local a_Height = h
				h = s.InitialHeight
				if not IsValid( Player ) then
					s:Remove()
					return
				end
				if Section == "P" and not Player:Alive() then
					s:Remove()
					AddPlayer( Player, "S" )
					return
				end
				tab[1], tab[2] = Player:PlayerColor()* 0.75, Player:PlayerColor(),
				draw.Rect(0, 0, w, h, s.sMA)

				draw.SimpleText( Player:Ping(), "lava_score_player_row", w - h * 1.5, h/2, nil, 1, 1 )

				if Player:GetNWString("$country", false ) then
					draw.WebImage( Flag:fill( Player:GetNWString("$country") ), w - h * 0.6, h / 2, h * 0.7, h * 0.7 * 0.6875 - 1, nil, 0 )
				end
				draw.SimpleText( Player:Nick(), "lava_score_player_row", h * 2+ h/20, h/2, nil, 0, 1 )

				if s.DoExpand then
					s:SetTall( s:GetTall():lerp( s.InitialHeight* 5 ) )
				elseif s:GetTall() ~= s.InitialHeight then
					s:SetTall( s:GetTall():lerp( s.InitialHeight ) )
				end

				draw.Rect(0, h, w, a_Height - h, tab[1] - 10)
			end
			p.DoClick = function( s )
				s.DoExpand = not s.DoExpand
				if s.DoExpand and not s.ExpandedPane then
					s.ExpandedPane = s:Add("DPanel")
					local e = s.ExpandedPane
					e:Dock( FILL )
					e:DockMargin( 0, ScrH()/25, 0, 0)
					e.Paint = nil

					local s2 = e:Add("lava_scroller")
					s2:Dock( RIGHT )
					s2:SetWide( ScrW()/7 )

					for Datapoint in Values( Datapoints ) do
						local v = s2:Add("DButton")
						v:Dock( TOP )
						v:SetTextColor( color_white )
						v:SetContentAlignment( 4 )
						v:SetTextInset( ScrH()/25, 0 )
						v:SetText( Datapoint[2] )
						v:SetFont( "lava_score_button_row")
						local th = v:GenerateColorShift( "caC", Player:PlayerColor()* 0.75, Player:PlayerColor(), 512 )
						v.Paint = function( s, w, h )
							th[1], th[2] = Player:PlayerColor()* 0.75, Player:PlayerColor()
							draw.Rect( 0, 0, w, h, s.caC )
							draw.WebImage( Emoji.Get( Datapoint[1] ), h/2, h/2, h * 0.8, h * 0.8, nil, s.Hovered and CurTime():sin() * 20 or 0 )
						end
						v.DoClick = function( s )
							Datapoint[3]( Player, s )
						end
					end
				end
			end

			local v = p:Add("AvatarImage")
			v:SetSize(ScrH() / 25 - WebElements.Edge/2, ScrH() / 25 - WebElements.Edge/2)
			v:SetPos( ScrH()/25 + WebElements.Edge / 4, WebElements.Edge / 4)
			v:SetPlayer(Player, 184)
			v:MakeBorder( WebElements.Edge/2, Player:GetPlayerColor():ToColor() - 50 )

			local e = p:Add("DCirclePanel")
			e:SetSize(ScrH() / 25 - WebElements.Edge/2, ScrH() / 25 - WebElements.Edge/2)
			e:SetPos(WebElements.Edge / 4, WebElements.Edge / 4)
			e.PaintCircle = function( s, w, h )
				draw.WebImage( Emoji.Get( Player:EmojiID() ), 0, 0, w, h )
				draw.WebImage( WebElements.CircleOutline, 0, 0, w, h, Player:PlayerColor() )
			end
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
			draw.WebImage( Emoji.Get( 1411 ), w - h * 1.9, h * 0.1, h * 0.8, h* 0.8 )
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
	s:Hide()
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

hook.Add("Lava.PopulateScoreboardPlayerButtons", "AddDefaultButtons", function( func )
	func( 2620, "Show Profile", function( Player )
		Player:ShowProfile()
	end)
	func( 1427, "Mute", function( Player, Panel )
		Player:SetMuted( not Player:IsMuted() )
		Panel:SetText( Player:IsMuted() and "Unmute" or "Mute")
		chat.AddText( ("Player ${1} has been ${2}."):fill( Player:Nick(), Player:IsMuted() and "Muted" or "Unmuted") )
	end)
	func( 1453, "Copy SteamID", function( Player )
		SetClipboardText( Player:SteamID64() )
		chat.AddText( ("${1}'s SteamID ${2} has been copied to clipboard."):fill( Player:Nick(), Player:SteamID64()) )
	end)
	func( 2424, "?????", function() end)
end)

hook.RunOnce( "HUDPaint", function() 
	net.Start("lava_country")
	net.WriteString( system.GetCountry() )
	net.SendToServer()
end)