

local draw = draw
local dark = Color( 70, 70, 70 )
local pColor = pColor

hook.RunOnce("HUDPaint", function()
	local x = InitializePanel("LavaAbiltiesSelector")
	x:SetSize( ScrW()/4, ScrH()*0.87 )
	x:SetTitle( "Abilities" )
	x:MakePopup()
	x:Center()
	x.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, dark  )
	end

	local m = x:Add( "DPanel" )
	m:Dock( FILL )
	m.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, pColor() )
	end

	local s = m:Add"DScrollPanel"
	s:Dock( TOP )
	s:SetHeight( ScrH()/2 )

	local a = s:Add("DIconLayout")
	a:Dock( FILL )
	a:SetSpaceX( 1 )
	a:SetSpaceY( 1 )

	local d = m:Add("DPanel")
	d:Dock( BOTTOM )
	d.Desc = ""
	d.Header = ""
	d:SetHeight( ScrH()/3 )
	d.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, dark:Alpha( 225 ) )
		draw.SimpleText( s.Header, "lava_abilities_header", ScrH()/100, ScrH()/100 )
		draw.DrawText( s.Desc, "lava_abilities_desc", ScrH()/100, ScrH()/100 + ScrH()/15 )
	end

	for k, v in pairs(Abilities.Skills) do
		local c = a:Add("DButton")
		c:SetSize( ScrH()/10 , ScrH()/10 )
		c:SetText("")
		c.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, dark:Alpha( s.Hovered and 200 or 150 ) )
			draw.WebImage( v[2], h*0.1, h*0.1, w - h*0.2, h - h*0.2 )
			if s.Hovered then
				d.Header = k
				d.Desc = v[ 1 ]:gsub("\t", "")
			end
		end
		c.DoClick = function()
			chat.AddText( pColor(), "You've selected the " .. k .. " ability! Your selection will take place the next time you spawn." )
			net.Start("Lava.SelectAbility")
			net.WriteString( k )
			net.SendToServer()
		end
	end
end)