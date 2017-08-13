local Gray = Color(0, 0, 0, 150)
local s
local game = game
local draw = draw
local pColor = pColor
local Config = Config
local White = color_white
local anims = {
	[1] = {
		"gesture_bow_original",
		"gesture_salute_original",
		"taunt_laugh",
		"taunt_dance",
	}, [2] = {
		"taunt_persistence_base",
		"taunt_robot",
		"gesture_agree_original",
	}, [3] = {
		"gesture_disagree_original",
		"gesture_wave_original",
		"taunt_cheer",
	}
}

hook.RunOnce("HUDPaint", function()
	s = InitializePanel( "LavaWinscreen", "DPanel" )
	s:SetSize(ScrW() * 0.6, ScrH() * 0.8)
	s:SetMouseInputEnabled( true )
	s.Paint = function( s, w, h ) draw.Rect( 0, 0, w, h, pColor() - 50) end
	s:Center()

	local tBar = s:Add("DLabel")
	tBar:Dock( TOP )
	tBar:SetTall( ScrH() / 20)
	tBar:SetMouseInputEnabled( true )
	tBar:SetContentAlignment( 5 )
	tBar:SetText( "Round Report" )
	tBar:SetFont( "lava_round_report_title" )
	tBar.Paint = function( s, w, h )
		draw.Rect( 0, 0, w, h, pColor() - 50 )
		draw.WebImage( Emoji.Get( 468 ), w/3 + w/15, h/2, h * 0.6, h* 0.6, nil, 0 )
		draw.WebImage( Emoji.Get( 468 ), w*0.66 - w/15, h/2, h * 0.6, h* 0.6, nil, 0 )
	end

	local Close = tBar:Add("DButton")
	Close:Dock( RIGHT )
	Close:SetText("")
	Close:SetWide( ScrH()/20 )
	Close:GenerateColorShift( "cVar", White - 100, White, 512 )
	Close.DoClick = function() s:Hide() end
	Close.CanClose = CurTime() + 10
	Close.Paint = function( s, w, h )
		if s.CanClose > CurTime() then
			draw.WebImage( Emoji.Get( Emoji.ParseNumber( ( s.CanClose - CurTime() ):floor() )[1] ), w/2, h/2, w*0.8, h*0.8, nil, 0 )
			return
		end
		draw.WebImage( Emoji.Get( 472 ), w/2, h/2, w*0.8, h*0.8, s.cVar, s.Hovered and CurTime() * -500 or 0 )
	end

	local wBar = s:Add("DPanel")
	wBar:Dock( TOP )
	wBar:SetTall( s:GetTall() / 2 )

	local bBar = s:Add("DLabel")
	bBar:Dock( BOTTOM )
	bBar:SetTall( ScrH() / 50 )
	bBar:SetText("")
	bBar.Paint = function( s, w, h )
		draw.Rect( 0, 0, w, h, pColor() - 50)
	end

	local Scroller = s:Add("lava_scroller")
	Scroller:Dock( BOTTOM )


	local PlayerPanel = {}

	for i = 1, 3 do
		local ModelPanel = wBar:Add("DModelPanel")
		ModelPanel:SetFOV( 5 )
		ModelPanel.PreDrawModel = function()
			cam.IgnoreZ( true )
		end
		ModelPanel.PostDrawModel = function()
			cam.IgnoreZ( false )
		end
		PlayerPanel[ i ] = ModelPanel
		PlayerPanel[ 3 + i ] = wBar:Add("DCirclePanel")
	end

	local function AddPlayer( Player, Ranking, x, y, w, h )
		if PlayerPanel[ Ranking ].Player ~= Player then
			PlayerPanel[ Ranking ].Player = Player
			PlayerPanel[ Ranking ]:SetSize( w / 10, h / 2)
			PlayerPanel[ Ranking ]:SetModel( Player:GetModel() )
			PlayerPanel[ Ranking ]:SetPaintedManually( true )
			PlayerPanel[ Ranking ]:SetPos( x, y )
			PlayerPanel[ Ranking ].Entity.GetPlayerColor = function( self ) return Player:GetPlayerColor() end 
			PlayerPanel[ Ranking ].LayoutEntity = function( self, Entity )
				self:RunAnimation()
				self:SetCamPos( Entity:GetForward() * 500 )
				Entity:SetAngles( Angle( 0, 45, 0 ))
			end
			PlayerPanel[ 3 + Ranking ]:SetSize( w / 10, w / 10 )
			PlayerPanel[ 3 + Ranking ]:SetPos( x, y )
			PlayerPanel[ 3 + Ranking ]:SetPaintedManually( true )
			PlayerPanel[ 3 + Ranking ].PaintCircle = function( s, w, h )
				if not IsValid( Player ) then return end
				draw.WebImage( Emoji.Get( Player:EmojiID() ), w/2, h/2, w*0.7, h*0.7, nil, 0 )
				draw.WebImage( WebElements.CircleOutline, 0, 0, w, h, Player:PlayerColor() )
			end
			local RandomSequence = anims[ Ranking ][ math.random( #( anims[ Ranking ] ) ) ]
			if not PlayerPanel[ Ranking ].Entity:LookupSequence( RandomSequence ) or not PlayerPanel[ Ranking ].Entity:LookupSequence( "pose_standing_0" .. Ranking ) then return end
			PlayerPanel[ Ranking ].Entity:SetSequence( PlayerPanel[ Ranking ].Entity:LookupSequence( RandomSequence ) )

			timer.Simple( PlayerPanel[ Ranking ].Entity:SequenceDuration( PlayerPanel[ Ranking ].Entity:LookupSequence( RandomSequence ) ), function()
				if IsValid( Player ) and IsValid( PlayerPanel[ Ranking ] ) then
					PlayerPanel[ Ranking ].Entity:SetSequence( PlayerPanel[ Ranking ].Entity:LookupSequence( "pose_standing_0" .. Ranking ) )
				end
			end)
		end
		PlayerPanel[ 3 + Ranking ]:PaintManual()
		PlayerPanel[ Ranking ]:PaintManual()
	end

	function s:Repopulate( ranking )
		Scroller:GetCanvas():RemoveChildren()
		Scroller:SetTall( ( #ranking - 3 ):Clamp( 0, 10 ) * ScrH()/25 )
		s:SetTall( wBar:GetTall() + tBar:GetTall() + Scroller:GetTall() + bBar:GetTall())
		s:Center()

		local camPos, camAng = ranking[1]:EyePos() + Vector( 0, 0, 10 ), ranking[1]:EyeAngles()
		local randPos, randAng = Vector((math.min(math.random(), 0.4) - 0.7) * 12, (math.min(math.random(), 0.4) - 0.5) * 12, (math.min(math.random(), 0.4) - 0.7) * -4), (math.min(math.random(), 0.4) - 0.7) * 8

		wBar.Paint = function( s, w, h )
			local x, y = s:LocalToScreen( 0, 0 )
			render.RenderView{
				drawviewmodel = false,
				origin = camPos,
				angles = camAng,
				aspectratio = w/h,
				x = x,
				y = y,
				w = w,
				h = h,
			}

			camPos = camPos + Vector(randPos.x * math.cos(math.rad(camAng.yaw)) * FrameTime(), randPos.y * math.sin(math.rad(camAng.yaw)) * FrameTime(), randPos.z * FrameTime())
			camAng = camAng + Angle(0, randAng * FrameTime(), 0)

			if IsValid( ranking[1] ) then
				local Player = ranking[1]
				draw.Rect( w/2 - w/10, 0, w/5, h, Player:PlayerColor():Alpha( 150 ) )
				draw.WebImage( Emoji.Get( 629 ), w/2, h*0.83, h/7, h * 0.7, nil, 180 )
				draw.WebImage( Emoji.Get( 2188 ), w/2, h*0.56, h/8, h/8, nil, 0 )

				draw.Rect( w/2 - w/10, h - h/10 + 1, w/5, h/10, Player:PlayerColor() )
				draw.SimpleText( Player:Nick(), "lava_winscreen_nick", w / 2, h - h / 18, nil, 1, 1 )
				AddPlayer( Player, 1, w/2 - w/20, h * 0.01, w, h )
			end

			if IsValid( ranking[2] ) then
				local Player = ranking[2]
				draw.Rect( w/4 - w/10, 0, w/5, h, Player:PlayerColor():Alpha( 150 ) )
				draw.WebImage( Emoji.Get( 629 ), w/4, h*0.8, h/7, h * 0.4, nil, 180 )
				draw.WebImage( Emoji.Get( 2189 ), w/4, h*0.672, h/8, h/8, nil, 0 )

				draw.Rect( w/4 - w/10, h - h/10 + 1, w/5, h/10, Player:PlayerColor() )
				draw.SimpleText( Player:Nick(), "lava_winscreen_nick", w / 4, h - h / 18, nil, 1, 1 )
				AddPlayer( Player, 2, w/4 - w/20, h / 8, w, h )
			end

			if IsValid( ranking[3] ) then
				local Player = ranking[3]
				draw.Rect( w*0.75 - w/10, 0, w/5, h, Player:PlayerColor():Alpha( 150 ) )
				draw.WebImage( Emoji.Get( 629 ), w*0.75, h*0.9, h/7, h * 0.3, nil, 180 )
				draw.WebImage( Emoji.Get( 2190 ), w*0.75, h*0.825, h/8, h/8, nil, 0 )

				draw.Rect( w*0.75 - w/10, h - h/10 + 1, w/5, h/10, Player:PlayerColor() )
				draw.SimpleText( Player:Nick(), "lava_winscreen_nick", w * 0.75, h - h / 18, nil, 1, 1 )
				AddPlayer( Player, 3, w*0.75 - w/20, h / 3.7, w, h )
			end
		end

		for Index, Player in pairs( ranking ) do
			if Index < 4 then continue end
			local p = Scroller:Add("DLabel")
			p:Dock(TOP)
			p:SetMouseInputEnabled(true)
			p:SetTall(ScrH() / 25)
			p:SetText("")
			p.InitialHeight = p:GetTall()
			local tab = p:GenerateColorShift("sMA", Player:PlayerColor() * 0.75, Player:PlayerColor(), 128)
			p.Paint = function(s, w, h)
				if not IsValid( Player ) then
					s:Remove()
					return
				end
				tab[1], tab[2] = Player:PlayerColor()* 0.75, Player:PlayerColor(),
				draw.Rect(0, 0, w, h, s.sMA)

				local r = Emoji.ParseNumber(Index)
				for i = 1, #r do
					draw.WebImage(Emoji.Get(r[i]), w - h*0.6 - h*0.7*(#r - i), h/2, h*0.7, h*0.7, nil, 0)
				end

				draw.SimpleText( Player:Nick(), "lava_score_player_row", h*2 + h/20, h/2, nil, 0, 1 )
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
				if not IsValid( Player ) then return end
				draw.WebImage( Emoji.Get( Player:EmojiID() ), 0, 0, w, h )
				draw.WebImage( WebElements.CircleOutline, 0, 0, w, h, Player:PlayerColor() )
			end
		end
	end

	s:Hide()
end)

net.Receive("lava_winscreen", function()
	if IsValid( s ) then
		local tbl = net.ReadTable()

		timer.Simple(2, function()
			if IsValid( s ) then
				s:Show()
				s:Repopulate(tbl)
				s:MakePopup()
			end
		end)
	end
end)

hook.Add("Lava.PreroundStart", "CloseWinscreen", function()
	s:Hide()
end)
