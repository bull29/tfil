local Gray = Color(0, 0, 0, 150)
local s
local Datapoints = {}
local Flag = "https://steamcommunity-a.akamaihd.net/public/images/countryflags/${1}.gif"
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
		"gesture_bow",
		"gesture_salute",
		"gesture_wave",
		"taunt_laugh",
		"taunt_cheer",
		"taunt_dance",
		"taunt_robot",
		"gesture_agree"
	}, [2] = {
		"gesture_item_give",
		"gesture_disagree"
	}, [3] = {
		"gesture_item_give",
		"gesture_disagree"
	}
}

local function AddDatapoint( icon, name, func )
	table.insert( Datapoints, { icon, name, func }  )
end

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
	t:SetSize(ScrW() * 0.6, ScrH() * 0.4)
	
	local playerPanel = {}
	for i = 1, 3 do
		local x, y = ScrW() * 0.3, ScrH() * 0.15
		
		if i == 2 then
			x, y = ScrW() * 0.15, ScrH() * 0.2
		elseif i == 3 then
			x, y = ScrW() * 0.45, ScrH() * 0.25
		end
		
		local s = ScrH() * 0.2
		
		local ply = t:Add("DModelPanel")
		ply:SetPos(x - s/2, y - s/2)
		ply:SetSize(s, s)
		
		playerPanel[i] = ply
	end
	
	function l:Repopulate(ranking)
		self:GetCanvas():RemoveChildren()

		local camPos, camAng = ranking[1]:EyePos(), ranking[1]:EyeAngles()
		local randPos, randAng = Vector((math.min(math.random(), 0.4) - 0.7) * 12, (math.min(math.random(), 0.4) - 0.5) * 12, (math.min(math.random(), 0.4) - 0.7) * 4), (math.min(math.random(), 0.4) - 0.7) * 8

		s.Paint = function(s, w, h)
			draw.Rect(0, 0, w, h, Gray)
			draw.Rect(0, h / 2, w, 1, pColor() - 50)
			
			render.RenderView({
				drawviewmodel = false,
				origin = camPos,
				angles = camAng,
				x = ScrW() * 0.2,
				y = ScrH() * 0.1,
				w = w,
				h = h / 2
			})
			
			camPos = camPos + Vector(randPos.x * math.cos(math.rad(camAng.yaw)) * FrameTime(), randPos.y * math.sin(math.rad(camAng.yaw)) * FrameTime(), randPos.z * FrameTime())
			camAng = camAng + Angle(0, randAng * FrameTime(), 0)
		end

		t.Paint = function()
			local s = ScrH() * 0.2
			
			local x, y = ScrW() * 0.3, ScrH() * 0.05
			draw.SimpleText(ranking[1]:Nick(), "lava_score_player_row", x, y, nil, 1, 1)
			draw.WebImage(Emoji.Get(629), x, y + s*1.6, s*0.3, s*1.45, nil, 180)
			draw.WebImage(Emoji.Get(2188), x, y + s*1.1, s*0.25, s*0.25, nil, math.cos(math.sin(math.rad(CurTime())) * 90) * 18)
			
			if #ranking < 2 then return end
			
			x, y = ScrW() * 0.15, ScrH() * 0.1
			draw.SimpleText(ranking[2]:Nick(), "lava_score_player_row", x, y, nil, 1, 1)
			draw.WebImage(Emoji.Get(629), x, y + s*1.6, s*0.3, s*1.45, nil, 180)
			draw.WebImage(Emoji.Get(2189), x, y + s*1.1, s*0.25, s*0.25, nil, math.cos(math.sin(math.rad(CurTime())) * 90 + 20) * 18)
			
			if #ranking < 3 then return end
			
			x, y = ScrW() * 0.45, ScrH() * 0.15
			draw.SimpleText(ranking[3]:Nick(), "lava_score_player_row", x, y, nil, 1, 1)
			draw.WebImage(Emoji.Get(629), x, y + s*1.6, s*0.3, s*1.45, nil, 180)
			draw.WebImage(Emoji.Get(2190), x, y + s*1.1, s*0.25, s*0.25, nil, math.cos(math.sin(math.rad(CurTime() + 45)) * 90) * 18)
		end

		local function AddPlayer(Player, rank)
			if rank <= 3 then
				local ply = playerPanel[rank]
				
				ply:SetModel(Player:GetModel())
				ply:SetAnimated(true)
				function ply.Entity:GetPlayerColor() return Player:GetPlayerColor() end
				function ply:LayoutEntity(ent)
					ply:RunAnimation()
					
					ent:SetAngles(Angle(0, 45, 0))
				end
				
				local anim = ply.Entity:LookupSequence(anims[rank][math.random(1, #anims[rank])])
				ply.Entity:SetSequence(anim)
				timer.Simple(ply.Entity:SequenceDuration(anim), function()
					ply.Entity:SetSequence(ply.Entity:LookupSequence("idle_all_01"))
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
			local dm
			p.DoClick = function( s )
				if dm and IsValid( dm ) then
					dm:Remove()
					dm = nil
				end
				dm = vgui.Create("DMenu")
				dm:SetDrawBackground( false )
				for k, v in pairs( Datapoints ) do
					local x = dm:AddOption( v[2], function()
						v[3]( Player, dm )
					end)
					x:SetTextColor( color_white )
					x:SetFont("lava_dmenu")
					x:GenerateColorShift( "hVar", Player:PlayerColor() - 25, Player:PlayerColor() + 25, 255 )
					x.Paint = function( s, w, h )
						draw.Rect( 0, 0, w, h, s.hVar)
						draw.WebImage( Emoji.Get( v[1] ), h/2, h/2, h * 0.7, h * 0.7, nil, s.Hovered and CurTime():cos() * 15 or 0 )
					end
				end
				dm:Open()
				dm.Paint = function( s, w, h )
					if not IsValid( Player ) then
						s:Remove()
						dm = nil
						return
					end
					draw.Rect( 0, 0, w, h, Player:PlayerColor() )
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
				if not IsValid( Player ) then return end
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
			draw.WebImage(Emoji.Get(468), w - h, h * 0.1, h * 0.8, h * 0.8)
		end

		for k, Player in pairs(ranking) do
			AddPlayer(Player, k)
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