local Gray = Color(0, 0, 0, 150)
local s
local game = game
local draw = draw
local pColor = pColor
local Config = Config

local numberEmoji = {
	[0] = 2645,
	[1] = 2648,
	[2] = 2649,
	[3] = 2652,
	[4] = 2653,
	[5] = 2654,
	[6] = 2655,
	[7] = 2656,
	[8] = 2657,
	[9] = 2658
}

local anims = {
	[1] = {
		"gesture_bow_original",
		"gesture_salute_original",
		"gesture_wave_original",
		"gesture_agree_original",
		"taunt_laugh",
		"taunt_cheer",
		"taunt_dance",
		"taunt_robot",
	}, [2] = {
		"taunt_persistence_base"
	}, [3] = {
		"taunt_muscle_base",
		"gesture_disagree_original"
	}
}


hook.RunOnce("HUDPaint", function()
	s = InitializePanel("LavaWinscreen", "DPanel")
	s:SetSize(ScrW() * 0.6, ScrH() * 0.8)
	s:Center()
	
	local b = s:Add("DPanel")
	b:Dock( BOTTOM )
	b:SetTall( ScrH()/25 )
	b.Paint = function( s, w, h )
		draw.Rect( 0, 0, w, h, pColor() - 100 )
	end

	local l = s:Add("lava_scroller")
	l:DockMargin(0, ScrH() * 0.8 / 1.9, 0, 0)
	l:Dock(FILL)
	s.Canvas = l

	local t = s:Add("DPanel")
	t:SetSize(ScrW() * 0.6, ScrH() * 0.8/2 + ScrH()/50)
	
	local playerPanel = {}
	for i = 1, 3 do
		local x, y = ScrW() * 0.3, ScrH() * 0.15
		
		if i == 2 then
			x, y = ScrW() * 0.15, ScrH() * 0.2
		elseif i == 3 then
			x, y = ScrW() * 0.45, ScrH() * 0.23
		end
		
		local s = ScrH() * 0.2
		
		local ply = t:Add("DModelPanel")
		ply:SetPos(x - s/2, y - s/2)
		ply:SetSize(s, s)
		ply:SetFOV( 5 )
		function ply:PreDrawModel()
			cam.IgnoreZ( true )
		end
		function ply:PostDrawModel()
			cam.IgnoreZ( false )
		end
		playerPanel[i] = ply
	end
	
	function l:Repopulate(ranking)
		self:GetCanvas():RemoveChildren()

		local camPos, camAng = ranking[1]:EyePos(), ranking[1]:EyeAngles()
		local randPos, randAng = Vector((math.min(math.random(), 0.4) - 0.7) * 12, (math.min(math.random(), 0.4) - 0.5) * 12, (math.min(math.random(), 0.4) - 0.7) * -4), (math.min(math.random(), 0.4) - 0.7) * 8

		s.Paint = function(s, w, h)
			draw.Rect(0, 0, w, h, Gray)
			draw.Rect(0, h / 2, w, 1, pColor() - 50)
			local x, y = s:LocalToScreen( 0, 0 )
			render.RenderView({
				drawviewmodel = false,
				origin = camPos,
				angles = camAng,
				aspectratio = (w)/(h/2),
				x = x,
				y = y,
				w = w,
				h = h / 2 + ScrH()/25
			})

			if ranking[1] then
				draw.Rect( w/2.5, 0, w / 5, h / 2 + ScrH()/25, ranking[1]:PlayerColor():Alpha( 125 ) )
			end
			if ranking[2] then
				draw.Rect( w/6.5, 0, w / 5, h / 2 + ScrH()/25, ranking[2]:PlayerColor():Alpha( 125 ) )
			end
			if ranking[3] then
				draw.Rect( w*0.65, 0, w / 5, h / 2 + ScrH()/25, ranking[3]:PlayerColor():Alpha( 125 ) )
			end



			camPos = camPos + Vector(randPos.x * math.cos(math.rad(camAng.yaw)) * FrameTime(), randPos.y * math.sin(math.rad(camAng.yaw)) * FrameTime(), randPos.z * FrameTime())
			camAng = camAng + Angle(0, randAng * FrameTime(), 0)
		end

		t.Paint = function( s, w, h )
			local s = ScrH() * 0.2
			
			local x, y = ScrW() * 0.3, ScrH() * 0.05
			draw.WebImage(Emoji.Get(629), x, y + s*1.6, s*0.3, s*1.45, nil, 180)
			draw.WebImage(Emoji.Get(2188), x, y + s*1.1, s*0.25, s*0.25, nil, 0)
			draw.Rect( w/2.5, h * 0.91, w/5, h / 10, ranking[1]:PlayerColor() )


			draw.SimpleText(ranking[1]:Nick(), "lava_score_player_row", w/2, h * 0.92, nil, 1, 2)

--[[ 			draw.WebImage( WebElements.Circle, w/2, h*0.15, h/5, h/5, ranking[1]:PlayerColor() + 50, 0 )
			draw.WebImage( Emoji.Get( ranking[1]:EmojiID() ), w/2, h*0.15, h/5, h/5, nil, 0 )--]] 
			if #ranking < 2 then return end
			
			x, y = ScrW() * 0.15, ScrH() * 0.1
			draw.WebImage(Emoji.Get(629), x, y + s*1.6, s*0.3, s*1.45, nil, 180)
			draw.WebImage(Emoji.Get(2189), x, y + s*1.1, s*0.25, s*0.25, nil, 0)
			draw.Rect( w/6.5, h * 0.91, w/5, h / 10, ranking[2]:PlayerColor() )


			draw.SimpleText(ranking[2]:Nick(), "lava_score_player_row", w/4, h * 0.92, nil, 1, 2)

--[[ 
			draw.WebImage( WebElements.Circle, w/4, h*0.25, h/5, h/5, ranking[2]:PlayerColor() + 50, 0 )
			draw.WebImage( Emoji.Get( ranking[2]:EmojiID() ), w/4, h*0.25, h/5, h/5, nil, 0 )--]] 
			if #ranking < 3 then return end
			
			x, y = ScrW() * 0.45, ScrH() * 0.15
			draw.WebImage(Emoji.Get(629), x, y + s*1.5, s*0.3, s*1.45, nil, 180)
			draw.WebImage(Emoji.Get(2190), x, y + s*1, s*0.25, s*0.25, nil, 0)
			draw.Rect( w*0.65, h * 0.91, w/5, h / 10, ranking[3]:PlayerColor() )
			draw.SimpleText(ranking[3]:Nick(), "lava_score_player_row", w*0.75, h * 0.92, nil, 1, 2)

--[[ 
			draw.WebImage( WebElements.Circle, w*0.75, h*0.3, h/5, h/5, ranking[3]:PlayerColor() + 50, 0 )
			draw.WebImage( Emoji.Get( ranking[3]:EmojiID() ), w*0.75, h*0.3, h/5, h/5, nil, 0 )--]] 
		end
		local Offset = math.random( 1, 1000 )
		local function AddPlayer(Player, rank)
			if rank <= 3 then
				local ply = playerPanel[rank]
				
				ply:SetModel(Player:GetModel())
				ply:SetAnimated(true)
				function ply.Entity:GetPlayerColor() return Player:GetPlayerColor() end
				function ply:LayoutEntity(ent)
					ply:RunAnimation()
					self:SetCamPos( ent:GetForward() * 900)
					ent:SetAngles(Angle(0, 45, 0))
				end
				
				local anim = ply.Entity:LookupSequence(anims[rank][math.random(1, #anims[rank])])
				ply.Entity:SetSequence(anim)
				
				timer.Simple(ply.Entity:SequenceDuration(anim), function()
					if IsValid( ply ) and IsValid( ply.Entity ) then
						ply.Entity:SetSequence(ply.Entity:LookupSequence("pose_standing_0"..(( rank + Offset )%5 ):Clamp( 1, 4) ))
					end
				end)
				
				return
			end
			
			local p = l:Add("DLabel")
			p:Dock(TOP)
			p:SetMouseInputEnabled(true)
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
				tab[1], tab[2] = Player:PlayerColor()* 0.75, Player:PlayerColor(),
				draw.Rect(0, 0, w, h, s.sMA)

				local r = tostring(rank)
				for i = 1, #r do
					local num = tonumber(string.sub(r, i, i))
					draw.WebImage(Emoji.Get(numberEmoji[num]), w - h*0.6 - h*0.7*(#r - i), h/2, h*0.7, h*0.7, nil, 0)
				end
				
				draw.SimpleText( Player:Nick(), "lava_score_player_row", h*2 + h/20, h/2, nil, 0, 1 )

				draw.Rect(0, h, w, a_Height - h, tab[1] - 10)
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

		local aHeader = l:Add("DLabel")
		aHeader:Dock(TOP)
		aHeader:SetTall(ScrH() / 25)
		aHeader:SetFont("lava_score_header")
		aHeader:SetTextColor(color_white)
		aHeader:SetText("")
		aHeader:SetTextInset(ScrW() / 100, 0)
		aHeader.Paint = function(s, w, h)
			draw.Rect(0, 0, w, h, pColor() - 75)
			draw.WebImage(Emoji.Get(468), w - h, h * 0.1, h * 0.8, h * 0.8)
			draw.WebImage(Emoji.Get(468), h/10, h * 0.1, h * 0.8, h * 0.8)
		end

		for k, Player in pairs(ranking) do
			AddPlayer(Player, k)
		end

		if #ranking < 4 then
			b:SetParent(l)
			b:Dock( TOP )
			b:SetTall( ScrH()/3 + WebElements.Edge + 1 )

			for i = 1, 3 do
				if not ranking[i] then continue end
				local av = b:Add("AvatarMask")
				av:SetSize( b:GetTall() /1.8, b:GetTall() /1.8 )
				if i == 1 then
					av:SetPos( s:GetWide()/2 - av:GetWide()/2, av:GetTall()/3)
				elseif i == 2 then
					av:SetPos( s:GetWide()/4 - av:GetWide()/2, av:GetTall()/3)
				elseif i == 3 then
					av:SetPos( s:GetWide()*0.75 - av:GetWide()/2, av:GetTall()/3)
				end
				av.PaintOver = function( s, w, h )
					draw.WebImage( WebElements.CircleOutline, 0, 0, w, h, ranking[i]:PlayerColor() )
				end
				av:SetPlayer( ranking[i], 184 )
			end
		end
	end
	s:Hide()
end)

net.Receive("lava_winscreen", function()
	if s then
		local tbl = net.ReadTable()

		timer.Simple(3, function()
			s:Show()
			s.Canvas:Repopulate(tbl)
			s:MakePopup()
		end)
	end
end)

hook.Add("Lava.PreroundStart", "CloseWinscreen", function()
	s:Hide()
end)