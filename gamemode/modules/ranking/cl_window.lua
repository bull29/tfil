local Gray = Color(0, 0, 0, 150)
local p, s
local game = game
local draw = draw
local pColor = pColor
local asc = false
local sel = "wins"
local White = color_white
local page = 1
local TotalWeight = 0
local Blue = Color( 0, 141, 255 )
local Red = Color( 255, 0, 0 )
local DataDrawPosition = {}

local function q(str)
	return str == "NULL" and "0" or str
end

local Datapoints = {}

local function AddDatapoint( DisplayName, DataMember, DisplayFunction, Weight )
	table.insert( Datapoints, { DisplayName, DataMember, DisplayFunction, Weight or 1 })
	TotalWeight = TotalWeight + ( Weight or 1)
end

local Zerofy = function( str ) return q( str ) end

AddDatapoint( "Rank", "", function( str ) end )
AddDatapoint( "Name", "name", function( str ) return str end, 2 )
AddDatapoint( "Favourite Ability", "ability", function( str ) return str == "NULL" and "N/A" or str end, 2 )
AddDatapoint( "Kills", "kills", Zerofy )
AddDatapoint( "Deaths", "deaths", Zerofy )
AddDatapoint( "Wins", "wins", Zerofy )
AddDatapoint( "Losses", "loses", Zerofy )
AddDatapoint( "Eggs Thrown", "eggsthrown", Zerofy )
AddDatapoint( "Eggs Hit", "eggshit", Zerofy )

hook.RunOnce("HUDPaint", function()
	p = InitializePanel("LavaRanking", "DFrame")
	p:SetSize(ScrW() * 0.8, ScrH() * 0.8)
	p:Center()
	p:SetTitle("")
	p:ShowCloseButton(false)
	
	s = p:Add("DPanel")
	s:SetSize(ScrW() * 0.8, ScrH() * 0.8)
	s.Paint = function(s, w, h)
		draw.Rect(0, 0, w, h, Gray)
		draw.Rect(0, 0, w, h/15, pColor() - 100)
		
		draw.SimpleText("  Page: " .. page, "lava_score_header", ScrH() / 500, h/35, nil, 0, 1)
	end
	
	local b = s:Add("DPanel")
	b:Dock( BOTTOM )
	b:SetTall( ScrH()/10 )

	local l = s:Add("lava_scroller")
	l:DockMargin(0, ScrH() * 0.05, 0, 0)
	l:Dock(FILL)
	s.Canvas = l

	local Close = s:Add("DButton")
	Close:SetSize( s:GetTall()/15,s:GetTall()/15 )
	Close:SetPos( s:GetWide() - Close:GetWide() )
	Close:SetText("")
	Close:GenerateColorShift( "cVar", White - 100, White, 512 )
	Close.DoClick = function() p:Hide() end
	Close.Paint = function( s, w, h )
		draw.WebImage( Emoji.Get( 472 ), w/2, h/2, w*0.8, h*0.8, s.cVar, s.Hovered and CurTime() * -500 or 0 )
	end

	local search = p:Add("DTextEntry")
	search:SetPos(ScrW() * 0.8 - ScrH() * 0.3, ScrH() * 0.0125)
	search:SetSize(ScrH() * 0.2, ScrH() * 0.025)
	search:SetFont("lava_score_player_row")
	search.OnChange = function()
		search:SetValue(string.sub(search:GetValue(), 1, 25))
	end
	search.OnEnter = function()
		Ranking.MakeRequest(page, 25, sel, asc, search:GetValue(), function(data, dataS)
			tbl = {
				data = data,
				dataS = dataS,
				page = page,
				max = 25
			}
			
			s.Canvas:Repopulate(tbl)
		end)
	end

	local prevpage = s:Add("DButton")
	prevpage:SetText("")
	prevpage:SetPos(ScrH() * 0.12, ScrH() * 0.0125)
	prevpage:SetSize(ScrH() * 0.025, ScrH() * 0.025)
	prevpage.Paint = function(s, w, h)
		draw.WebImage(Emoji.Get(2638), 0, 0, w, h)
	end
	prevpage.DoClick = function()
		page = math.max(page - 1, 1)
		
		Ranking.MakeRequest(page, 25, sel, asc, search:GetValue(), function(data, dataS)
			tbl = {
				data = data,
				dataS = dataS,
				page = page,
				max = 25
			}
			
			s.Canvas:Repopulate(tbl)
		end)
	end

	local nextpage = s:Add("DButton")
	nextpage:SetText("")
	nextpage:SetPos(ScrH() * 0.145, ScrH() * 0.0125)
	nextpage:SetSize(ScrH() * 0.025, ScrH() * 0.025)
	nextpage.Paint = function(s, w, h)
		draw.WebImage(Emoji.Get(2632), 0, 0, w, h)
	end
	nextpage.DoClick = function()
		page = page + 1
		
		Ranking.MakeRequest(page, 25, sel, asc, search:GetValue(), function(data, dataS)
			tbl = {
				data = data,
				dataS = dataS,
				page = page,
				max = 25
			}
			
			s.Canvas:Repopulate(tbl)
		end)
	end

	function l:Repopulate(tbl)
		local pw, ph = ScrW() * 0.8
		
		self:GetCanvas():RemoveChildren()

		local data = tbl.dataS
		b.Paint = function( s, w, h )
			if not data or not istable( data ) then return end
			draw.Rect(0, 0, w, h, pColor() - 100)
			draw.Rect(h/2, h/6, w - h, h/2, pColor() - 50)
			
			for Index, Datapoint in pairs( Datapoints ) do
				if Datapoint[2] == "" then continue end
				draw.SimpleText( Datapoint[3]( data[ Datapoint[2] ] ), "lava_score_player_row", ( DataDrawPosition[ Index ] or 0) + WebElements.Edge, h/2.5, White, 0, 1 )
			end
		end

		local data = tbl.data

		local function AddPlayer(data, rank)
			local clr = Color(util.CRC(data.steamid64)%256, util.CRC(data.name)%256, util.CRC(data.steamid64 .. data.name)%256)--Color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
			
			local p = l:Add("DLabel")
			p:Dock(TOP)
			p:SetMouseInputEnabled(true)
			p:SetTall(ScrH() / 25)
			p:SetText("")
			p.InitialHeight = p:GetTall()
			local tab = p:GenerateColorShift("sMA", clr * 0.75, clr, 128)
			p.Paint = function(s, w, h)
				local a_Height = h
				h = s.InitialHeight
				
				tab[1], tab[2] = clr * 0.75, clr,
				draw.Rect(0, 0, w, h, s.sMA)
				
				draw.SimpleText(tostring(rank + (tbl.page - 1) * tbl.max), "lava_score_player_row", h/20, h/2, nil, 0, 1)
			
				for Index, Datapoint in pairs( Datapoints ) do
					if Datapoint[2] == "" then continue end
					draw.SimpleText( Datapoint[3]( data[ Datapoint[2] ] ), "lava_score_player_row", DataDrawPosition[ Index ] + h/5, h/2, nil, 0, 1 )
				end

				draw.Rect(0, h, w, a_Height - h, tab[1] - 10)
			end

			p.DoClick = function( s )
				gui.OpenURL("http://steamcommunity.com/profiles/" .. data.steamid64)
			end

			local v = p:Add("AvatarImage")
			v:SetSize(ScrH() / 25 - WebElements.Edge/2, ScrH() / 25 - WebElements.Edge/2)
			v:SetPos( ScrH()/25 + WebElements.Edge * 2 + p:GetTall(), WebElements.Edge / 4)
			v:SetSteamID(data.steamid64, 184)
			v:MakeBorder( WebElements.Edge/2, clr - 50 )

			local e = p:Add("DCirclePanel")
			e:SetSize(ScrH() / 25 - WebElements.Edge/2, ScrH() / 25 - WebElements.Edge/2)
			e:SetPos( p:GetTall() + WebElements.Edge * 2, WebElements.Edge / 4)
			e.PaintCircle = function( s, w, h )
				draw.WebImage( Emoji.Get( util.CRC((data.name or 1566124349)) % #Emoji.Index ), 0, 0, w, h )
				draw.WebImage( WebElements.CircleOutline, 0, 0, w, h, clr)
			end

			ph = p:GetTall()
		end

		local aHeader = l:Add("DButton")
		aHeader:SetText("")
		aHeader:Dock(TOP)
		aHeader:SetTall(ScrH() / 25)
		local sort
		local CurrentlyHoveredMember = "wins"
		aHeader.Paint = function(s, w, h)
			draw.Rect(0, 0, w, h, pColor() - 75)

			local DrawPoint = 0
			local xPos = s:LocalCursorPos()

			for Index, Datapoint in pairs(Datapoints) do
				local Text = Datapoint[1]
				local Font = FontFunctions.GenerateFont( Text, (w/(TotalWeight)) * Datapoint[4], "Roboto Bold", h*0.6 )
				local Width = FontFunctions.GetWide( Text, Font )
				if s.Hovered and xPos < (DrawPoint + ( w/TotalWeight) * Datapoint[4]) and xPos > DrawPoint then
					CurrentlyHoveredMember = Datapoint[2]
				end
				draw.SimpleText( Text, Font, DrawPoint + WebElements.Edge, h/2, CurrentlyHoveredMember == Datapoint[2] and White or White - 100, 0, 1)
				DataDrawPosition[ Index ] = DrawPoint

				for i = 1, Datapoint[4] do
					DrawPoint = DrawPoint + (w/(TotalWeight))
				end
				draw.Rect( DrawPoint, WebElements.Edge, 1, h - WebElements.Edge*2, pColor() )
			end
			
		end
		aHeader.DoClick = function()
			sort = CurrentlyHoveredMember
			local c = true
			if sel == sort and c then
				asc = not asc
			end

			sel = sort

			Ranking.MakeRequest(page, 25, sort, asc, search:GetValue(), function(data, dataS)
				tbl = {
					data = data,
					dataS = dataS,
					page = page,
					max = 25
				}
				
				s.Canvas:Repopulate(tbl)
			end)
		end

		for k, v in pairs(data) do
			AddPlayer(v, k)
		end
	end
	p:Hide()
end)

hook.Add("OnPlayerChat", "LavaRanking", function(ply, text)
	if ply ~= LocalPlayer() then return end
	if text ~= "!stats" and text ~= "!ranking" then return end

	if p then
		Ranking.MakeRequest(page, 25, sel, asc, "", function(data, dataS)
			tbl = {
				data = data,
				dataS = dataS,
				page = page,
				max = 25
			}

			p:Show()
			s.Canvas:Repopulate(tbl)
			p:MakePopup()
		end)
	end
end)


hook.Add("Lava.PopulateWidgetMenu", "MakeStatsWindow", function( Context )
	Context.NewWidget( "Server Leaderboards", "1f3c6", function()
		Ranking.MakeRequest(page, 25, sel, asc, "", function(data, dataS)
			tbl = {
				data = data,
				dataS = dataS,
				page = page,
				max = 25
			}

			p:Show()
			s.Canvas:Repopulate(tbl)
			p:MakePopup()
		end)
	end)
end)