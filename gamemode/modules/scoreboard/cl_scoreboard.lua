local system = system or {}
local draw = draw
local box = draw.RoundedBox
local lerp = Lerp
local frametime = FrameTime
local ft = frametime
local text = draw.SimpleText
local web = draw.WebImage
local webof = "http://steamcommunity-a.akamaihd.net/public/images/countryflags/<>.gif"

local wtab = {
	[1] = "http://i.imgur.com/QYiylM6.png",
	[2] = "http://i.imgur.com/m32EIeS.png",
	[3] = "http://i.imgur.com/KImuuj4.png"
}

local ed = math.ceil(ScrH() * 0.00162074554)
local buttons = {}

local function addButton(name, icon, func)
	table.insert(buttons, {
		name = name,
		icon = icon,
		func = func
	})
end

addButton("Join our group!", "http://i.imgur.com/HTu2GaE.png", function()
	gui.OpenURL("http://steamcommunity.com/groups/nivogamers")
end)

addButton("Toggle Thirdperson", "http://i.imgur.com/vwIuS8b.png", function()
	_ontp = not _ontp
end)

local colors = {
	A = Color(50, 50, 50, 150),
	B = Color(100, 68, 54),
	C = Color(143, 96, 72),
	D = Color(50, 50, 50 )
}

hook.RunOnce( "HUDPaint", function()
	local st = InitializePanel("FATKID_SCORE_SIDETAB", "DPanel")
	st:MakeBorder(ed, colors.D)
	st:SetPaintedManually( true )
	st.Paint = function(s, w, h)
		box(0, 0, 0, w, h, colors.A)

		if FATKID_SCORE then
			local p = FATKID_SCORE
			s:SetWide(p:GetWide() / 4.5)
			s:SetTall(p:GetTall() - p.TopOf)
			s:SetPos(p:GetHorizontalPos() - p:GetWide() / 4.5, p:GetVerticalPos() + p.TopOf)
		end
	end

	local ic = st:Add("DIconLayout")

	ic:Dock(FILL)
	ic:SetSpaceY(ed)

	for k, v in pairs(buttons) do
		local b = ic:Add("DButton")
		b:SetText("")
		b:MakeBorder(ed, colors.D)
		b:SetTall(ScrH() / 17)
		b.ColorOf = pColor()

		local i = b:Add("DPanel")
		b.Paint = function(s, w, h)
			local h8 = math.ceil( h/8 )
			s:SetWide(ic:GetWide())
			box(0, 0, 0, w, h, s.ColorOf)
			box(0, 0, 0, h8, h8, colors.D)
			box(0, w - h8, h - h8, h8, h8, colors.D)
			box(0, w - h8, 0, h8, h8, colors.D)
			box(0, 0, h - h8, h8, h8, colors.D)

			box(0, 0, h8 - ed*2, w, ed, colors.D)
			box(0, 0, h - h8 + ed, w, ed, colors.D)

			text(v.name, "fatkid_score_side", i:GetHorizontalPos() + i:GetWide() + 4, h/2 - ScrH()/80 )

			if s.Hovered then
				s.ColorOf = s.ColorOf:Approach(pColor() + 25, 5)
			else
				s.ColorOf = s.ColorOf:Approach(pColor() - 5		, 5)
			end
		end
		b.DoClick = v.func
		i.Paint = function( s, w, h )
			s:SetPos( ed*4, ed*4 )
			s:SetWide( b:GetTall() - ed*8 )
			s:SetTall( b:GetTall() - ed*8 )
			box( 0, 0, 0, ed, h, colors.D )
			box( 0, w-ed, 0, ed, h, colors.D )
			web( v.icon, 0, ed, w, h, colors.D )
		end
	end
end)

local pcolors = {
	Human = Color(100, 68, 54)
}

hook.RunOnce( "HUDPaint", function()
	local m = InitializePanel("FATKID_SCORE","DFrame")
	m:SetSize(ScrW() * 0.1, ScrH() * 0.1)
	m:ShowCloseButton(false)
	m:SetTitle"" --("Nivo - Fat kid")
	m.DesiredWidth, m.DesiredHeight = math.floor(ScrW() * 0.6), math.floor(ScrH() * 0.8)
	m:Center()
	m:MakePopup()
	m:MakeBorder(ed, Color(50, 50, 50))
	local topset
	m.ScrollOffset = 0
	m.TopOf = 0

	m.Paint = function(s, w, h)
		if FATKID_SCORE_SIDETAB then
			FATKID_SCORE_SIDETAB:PaintManual()
		end
		topset = h / 10
		s.TopOf = topset
		box(0, 0, 0, w, h, colors.A)
		box(0, 0, 0, w, topset, pColor())
		box(0,0,topset-1,w,ed,colors.D)
		text("Nivo", "fatkid_motd_top", s.ScrollOffset, 5)
		text("[", "fatkid_motd_top", s.ScrollOffset - 15, 5, pColor() + 50)
		text("        ]", "fatkid_motd_top", s.ScrollOffset, 5, pColor() + 50)

		if s.Flip then
			s.ScrollOffset = lerp(ft(), s.ScrollOffset, 0)
		else
			s.ScrollOffset = lerp(ft(), s.ScrollOffset, w - topset * 2.333)
		end

		if s.ScrollOffset > w - (topset * 2.333) - 20 or s.ScrollOffset < 20 then
			s.Flip = not s.Flip
		end

		if s:GetHorizontalPos() ~= s:GetCenterX() or s:GetVerticalPos() ~= s:GetCenterY() then
			s:SetPos(lerp(frametime() * 5, s:GetHorizontalPos(), s:GetCenterX()), lerp(frametime() * 5, s:GetVerticalPos(), s:GetCenterY()))
		end

		if w ~= s.DesiredWidth or h ~= s.DesiredHeight then
			s:SetSize(lerp(frametime() * 5, w, s.DesiredWidth), lerp(frametime() * 5, h, s.DesiredHeight))
		end
	end

	local s = m:Add("DScrollPanel")

	s.Paint = function(self, w, h)
		if w ~= m:GetWide() - 4 then
			self:SetWide(m:GetWide() - 4)
			self:SetPos(3, m:GetTall() / 10 + 2)
		end

		if h ~= m:GetTall() - 4 then
			self:SetTall(m:GetTall() - 29)
			self:SetPos(3, m:GetTall() / 10 + 2)
		end
	end

	local i = s:Add("DIconLayout")
	i:SetSpaceY(1)

	i.PaintOver = function(self, w, h)
		if w ~= s:GetWide() then
			self:SetWide(s:GetWide())
		end

		if h ~= s:GetTall() then
			self:SetTall(s:GetTall())
		end
	end

	m.Redo = function()
		for k, v in pairs( i:GetChildren() ) do
			v:Remove()
		end
		for k, v in pairs(player.GetAll()) do
			local p = i:Add("DButton")
			p:MakeBorder(ed, Color(50, 50, 50))
			p:SetTall(ScrH() / 15)
			p:SetText""
			p.StartCol = Color( v:GetPlayerColor().r*255, v:GetPlayerColor().g*255, v:GetPlayerColor().b*255 )  - 50
			local maxof = math.max(p:GetTall() / 5 * 1.45454545, 16)
			local minof = math.max(p:GetTall() / 5, 11)
			local ih = p:GetTall()
			local av = p:Add("AvatarImage")

			p.Paint = function(se, w, h)
				if not IsValid(v) then
					se:Remove()
					i:Layout()
					return
				end
				if w ~= (s:InnerWidth() - 2) then
					se:SetWide(s:InnerWidth() - 2)
					i:Layout()
				end

				if se.Hovered then
					se.StartCol = se.StartCol:Approach(Color( v:GetPlayerColor().r*255, v:GetPlayerColor().g*255, v:GetPlayerColor().b*255 )  - 50+ 25, 5)
				else
					se.StartCol = se.StartCol:Approach(Color( v:GetPlayerColor().r*255, v:GetPlayerColor().g*255, v:GetPlayerColor().b*255 )  - 50, 5)
				end

				if se.DoExpand and h ~= (ScrH() / 15 * 3) then
					se:SetTall(lerp(ft() * 5, h, ScrH() / 15 * 3))
					i:Layout()
				elseif not se.DoExpand then
					se:SetTall(lerp(ft() * 5, h, ScrH() / 15))
					i:Layout()
				end

				box(0, 0, 0, w, ih, se.StartCol:Alpha(225))
				box(0, 0, ih - 1, w, ed, colors.A:Alpha(225))
				box(0, 0, ih, w, h, colors.A:Alpha(150))
				text(v:Nick(), "fatkid_score", av:GetHorizontalPos() + av:GetWide() + 4, ih / 2 - ScrH() / 60)
			end

			p.DoClick = function(s)
				chat.PlaySound()
				gui.OpenURL("http://steamcommunity.com/profiles/"..v:SteamID64())
			--	s.DoExpand = not s.DoExpand
			end

			--box( 8, w - minof - maxof*2, h / 2 - minof / 2, minof, minof, Color( 0, 0, 0, 150 ))
			--web(wtab[v:GetNWInt("operating_system", 1)], w - minof - maxof*2, h / 2 - minof / 2, minof, minof )
			av:SetSize(p:GetTall() - 6, p:GetTall() - 6)
			av:SetPos(3, 3)
			av:SetPlayer(v, 184)
			av:MakeBorder(ed, Color(50, 50, 50))
		end
	end

	function GAMEMODE:ScoreboardShow()
		m:Show()
		m.Redo()
	end
	function GAMEMODE:ScoreboardHide()
		m:SetSize(ScrW() * 0.1, ScrH() * 0.1)
		m:Hide()
	end
	m:Hide()
end)

surface.CreateFont("fatkid_score", {
	font = "Coolvetica",
	size = ScrH() / 30,
	weight = 100
})
surface.CreateFont("fatkid_score_side", {
	font = "Roboto Lt",
	size = ScrH() / 40,
	weight = 200
})
surface.CreateFont("fatkid_motd_top", {
	font = "Roboto Bold",
	weight = 100,
	outline = false,
	size = ScrH() / 15
})