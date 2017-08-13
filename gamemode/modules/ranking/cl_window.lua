local Gray = Color(0, 0, 0, 150)
local s
local game = game
local draw = draw
local pColor = pColor
local asc = false
local sel = "wins"
local sortx = ScrH()/25*4 + ScrW()*0.8/2.8 + ScrH()/25*8.6
local page = 1

local function q(str)
	return str == "NULL" and "0" or str
end

hook.RunOnce("HUDPaint", function()
	s = InitializePanel("LavaRanking", "DPanel")
	s:SetSize(ScrW() * 0.8, ScrH() * 0.8)
	s:Center()
	s.Paint = function(s, w, h)
		draw.Rect(0, 0, w, h, Gray)
		draw.Rect(0, 0, w, ScrH() * 0.05, pColor() - 100)
		draw.Rect(0, ScrH() * 0.05, w, 1, pColor() - 50)
		
		draw.SimpleText("Page: " .. page, "lava_score_header", ScrH() / 500, ScrH() * 0.025, nil, 0, 1)
	end
	
	local b = s:Add("DPanel")
	b:Dock( BOTTOM )
	b:SetTall( ScrH()/10 )
	

	local l = s:Add("lava_scroller")
	l:DockMargin(0, ScrH() * 0.05, 0, 0)
	l:Dock(FILL)
	s.Canvas = l

	local close = s:Add("DButton")
	close:SetText("")
	close:SetPos(ScrW() * 0.8 - ScrW() * 0.05, 0)
	close:SetSize(ScrW() * 0.05, ScrH() * 0.05)
	close.Paint = function(s, w, h)
		draw.Rect(0, 0, w, h, Color(230, 70, 90))
		draw.SimpleText("X", "lava_score_player_row", w/2, h/2, nil, 1, 1)
	end
	close.DoClick = function()
		s:Hide()
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
		
		Ranking.MakeRequest(page, 25, sel, asc, function(data, dataS)
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
		
		Ranking.MakeRequest(page, 25, sel, asc, function(data, dataS)
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
			draw.Rect(0, 0, w, h, pColor() - 100)
			draw.Rect(h/2, h/6, w - h, h/2, pColor() - 50)
			
			local h, w = ScrH()/25, ScrW()*0.8
			
			draw.SimpleText(data.name, "lava_score_player_row", h*4 + h/20, h, nil, 0, 1)
			draw.SimpleText(data.ability, "lava_score_player_row", h*4 + w/5, h, nil, 0, 1)
			draw.SimpleText(q(data.kills), "lava_score_player_row", h*4 + w/2.8, h, nil, 0, 1)
			draw.SimpleText(q(data.deaths), "lava_score_player_row", h*4 + w/2.8 + h*4.3, h, nil, 0, 1)
			draw.SimpleText(q(data.wins), "lava_score_player_row", h*4 + w/2.8 + h*8.6, h, nil, 0, 1)
			draw.SimpleText(q(data.loses), "lava_score_player_row", h*4 + w/2.8 + h*12.9, h, nil, 0, 1)
			draw.SimpleText(q(data.eggsthrown), "lava_score_player_row", h*4 + w/2.8 + h*17.2, h, nil, 0, 1)
			draw.SimpleText(q(data.eggshit), "lava_score_player_row", h*4 + w/2.8 + h*21.5, h, nil, 0, 1)
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
				
				--draw.SimpleText(data.steamid64, "lava_score_player_row", h*2 + h/20, h/2, nil, 0, 1)
				draw.SimpleText(tostring(rank + (tbl.page - 1) * tbl.max), "lava_score_player_row", h/20, h/2, nil, 0, 1)
				draw.SimpleText(data.name, "lava_score_player_row", h*4 + h/20, h/2, nil, 0, 1)
				draw.SimpleText(data.ability, "lava_score_player_row", h*4 + w/5, h/2, nil, 0, 1)
				draw.SimpleText(q(data.kills), "lava_score_player_row", h*4 + w/2.8, h/2, nil, 0, 1)
				draw.SimpleText(q(data.deaths), "lava_score_player_row", h*4 + w/2.8 + h*4.3, h/2, nil, 0, 1)
				draw.SimpleText(q(data.wins), "lava_score_player_row", h*4 + w/2.8 + h*8.6, h/2, nil, 0, 1)
				draw.SimpleText(q(data.loses), "lava_score_player_row", h*4 + w/2.8 + h*12.9, h/2, nil, 0, 1)
				draw.SimpleText(q(data.eggsthrown), "lava_score_player_row", h*4 + w/2.8 + h*17.2, h/2, nil, 0, 1)
				draw.SimpleText(q(data.eggshit), "lava_score_player_row", h*4 + w/2.8 + h*21.5, h/2, nil, 0, 1)

				draw.Rect(0, h, w, a_Height - h, tab[1] - 10)
			end
			local dm
			p.DoClick = function( s )
				gui.OpenURL("http://steamcommunity.com/profiles/" .. data.steamid64)
			end

			local v = p:Add("AvatarImage")
			v:SetSize(ScrH() / 25 - WebElements.Edge/2, ScrH() / 25 - WebElements.Edge/2)
			v:SetPos( ScrH()/25 + WebElements.Edge / 4 + p:GetTall() * 2, WebElements.Edge / 4)
			v:SetSteamID(data.steamid64, 184)
			v:MakeBorder( WebElements.Edge/2, clr - 50 )

			local e = p:Add("DCirclePanel")
			e:SetSize(ScrH() / 25 - WebElements.Edge/2, ScrH() / 25 - WebElements.Edge/2)
			e:SetPos(WebElements.Edge / 4 + p:GetTall() * 2, WebElements.Edge / 4)
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
		aHeader.Paint = function(s, w, h)
			draw.Rect(0, 0, w, h, pColor() - 75)
			
			local w, h = pw, ph
			
			draw.SimpleText("Rank", "lava_score_header", h/20, h/2, nil, 0, 1)
			draw.SimpleText("Name", "lava_score_header", h*4, h/2, nil, 0, 1)
			draw.SimpleText("Favourite Ability", "lava_score_header", h*4 + w/5, h/2, nil, 0, 1)
			draw.SimpleText("Kills", "lava_score_header", h*4 + w/2.8, h/2, nil, 0, 1)
			draw.SimpleText("Deaths", "lava_score_header", h*4 + w/2.8 + h*4.3, h/2, nil, 0, 1)
			draw.SimpleText("Wins", "lava_score_header", h*4 + w/2.8 + h*8.6, h/2, nil, 0, 1)
			draw.SimpleText("Loses", "lava_score_header", h*4 + w/2.8 + h*12.9, h/2, nil, 0, 1)
			draw.SimpleText("Eggs Thrown", "lava_score_header", h*4 + w/2.8 + h*17.2, h/2, nil, 0, 1)
			draw.SimpleText("Eggs Hit", "lava_score_header", h*4 + w/2.8 + h*21.5, h/2, nil, 0, 1)
			
			draw.WebImage(Emoji.Get(asc and 2639 or 2640), sortx - h*0.8, h*0.1, h*0.8, h*0.8)
		end
		aHeader.DoClick = function()
			local w, h = pw, ph
			local x, y = input.GetCursorPos()
			x = x - ScrW() * 0.1
			
			local sort
			local c = true
			if x > h*4 + w/2.8 + h*21.5 then
				sort = "eggshit"
				sortx = h*4 + w/2.8 + h*21.5
			elseif x > h*4 + w/2.8 + h*17.2 then
				sort = "eggsthrown"
				sortx = h*4 + w/2.8 + h*17.2		
			elseif x > h*4 + w/2.8 + h*12.9 then
				sort = "loses"
				sortx = h*4 + w/2.8 + h*12.9
			elseif x > h*4 + w/2.8 + h*8.6 then
				sort = "wins"
				sortx = h*4 + w/2.8 + h*8.6
			elseif x > h*4 + w/2.8 + h*4.3 then
				sort = "deaths"
				sortx = h*4 + w/2.8 + h*4.3
			elseif x > h*4 + w/2.8 then
				sort = "kills"
				sortx = h*4 + w/2.8
			elseif x > h*4 + w/5 then
				sort = "ability"
				sortx = h*4 + w/5
			elseif x > h*4 then
				sort = "name"
				sortx = h*4
			else
				c = false
			end
			
			if sel == sort and c then
				asc = not asc
			end
			
			sel = sort
			
			Ranking.MakeRequest(page, 25, sort, asc, function(data, dataS)
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

	s:Hide()
end)

hook.Add("OnPlayerChat", "LavaRanking", function(ply, text)
	if ply ~= LocalPlayer() then return end
	if text ~= "!stats" and text ~= "!ranking" then return end
	
	if s then
		Ranking.MakeRequest(page, 25, sel, asc, function(data, dataS)
			tbl = {
				data = data,
				dataS = dataS,
				page = page,
				max = 25
			}
			
			s:Show()
			s.Canvas:Repopulate(tbl)
			s:MakePopup()
		end)
	end
end)