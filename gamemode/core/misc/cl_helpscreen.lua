local draw = draw
local sCol = Color( 0, 141, 255 )
local pColor = pColor
local m_ShouldDrawHelperScreen
local NextHelperPress = CurTime()
local tab = {
	["$pp_colour_colour"] = 0,
	["$pp_colour_contrast"] = 0.5,
}

hook.Add( "HUDPaint", "CheckHelper", function()
	if LocalPlayer():Alive() then
		if not cookie.GetString("$lava.helperscreen") then
			m_ShouldDrawHelperScreen = true
			cookie.Set("$lava.helperscreen", "FAAAAT")
		end
		hook.Remove( "HUDPaint", "CheckHelper" )
	end
end)

hook.Add("RenderScreenspaceEffects", "Helpscreen", function()
	if not m_ShouldDrawHelperScreen or not LocalPlayer():Alive() then return end

	DrawColorModify( tab )
end)

hook.Add("PostRenderVGUI", "DrawHelperscreen", function()
	if not m_ShouldDrawHelperScreen or not LocalPlayer():Alive() then return end

	draw.WebImage( Emoji.Get( "2753" ), ScrW()/2 + ScrH()/40, ScrH() * 0.125, ScrH()/15, ScrH()/15, nil, ( CurTime() * 5 ):sin() * -15 )
	draw.WebImage( Emoji.Get( "2754" ), ScrW()/2 - ScrH()/40, ScrH() * 0.125, ScrH()/15, ScrH()/15, nil, ( CurTime() * 5 ):sin() * 15 )
	draw.SimpleText( "HELP SCREEN", "lava_help_title", ScrW()/2, ScrH() * 0.2, sCol + 50, 1, 1 )
	draw.SimpleText( "Press F2 at any time to close/view this screen again.", "lava_help_title_sub", ScrW()/2, ScrH() * 0.35, sCol, 1, 1 )

	draw.SimpleText( "<<< Your current ability (Use C to change it)", "lava_help_title_subsub", ScrW()/4.9, ScrH() * 0.91, sCol, 0, 1 )

	draw.SimpleText( "Your number of eggs. >>>", "lava_help_title_subsub", ScrW()*0.87, ScrH() * 0.91, sCol, 2, 1 )
	draw.SimpleText( "Throw eggs at players to disorient them using rmb.", "lava_help_title_subsub", ScrW()*0.83, ScrH() * 0.94, sCol, 2, 1 )
	draw.SimpleText( "Gain bonus eggs by successfully hitting players.", "lava_help_title_subsub", ScrW()*0.83, ScrH() * 0.97, sCol, 2, 1 )

	draw.SimpleText( "The current round timer. >>>", "lava_help_title_subsub", ScrW() * 0.87, ScrH()/10, sCol, 2)
	draw.SimpleText( "This is not a clock.", "lava_help_title_subsub", ScrW() * 0.86, ScrH()/10 + ScrH()/40, sCol, 2)

	draw.SimpleText( "The current round state. >>>", "lava_help_title_subsub", ScrW() * 0.87, ScrH()/4 - ScrH()/60, sCol, 2)


	draw.SimpleText( "<<< Your current elevation from the Lava in meters", "lava_help_title_subsub", ScrW()/7, ScrH() * 0.72, sCol, 0, 1 )


	draw.SimpleText( "<<< Your current ranking relative to other players based on your height from the lava.", "lava_help_title_subsub", ScrW()/5.5, ScrH() * 0.79, sCol, 0, 1 )


	draw.SimpleText( "Your health percentage", "lava_help_title_subsub", ScrW()/50, ScrH() * 0.63, sCol, 0, 1 )
	draw.SimpleText( "vvv", "lava_help_title_subsub", ScrW()/47, ScrH() * 0.655, sCol, 0, 1 )


	draw.SimpleText( "<<< Hold C to access the context menu and widgets.", "lava_help_title_subsub", ScrW()/10, ScrH()/8, sCol, 0, 1 )

	draw.SimpleText( "Hold Q to access EmojiSense mode.", "lava_help_title_subsub", ScrW()*0.98, ScrH()/2, sCol, 2, 1 )
	draw.SimpleText( "Use your +zoom bind for enhanced zooming.", "lava_help_title_subsub", ScrW()*0.98, ScrH()*0.53, sCol, 2, 1 )
end)

hook.Add("Think", "HelperScreen",function()
	if input.IsKeyDown( KEY_F2 ) and NextHelperPress < CurTime() then
		NextHelperPress = CurTime() + 0.25
		m_ShouldDrawHelperScreen = not m_ShouldDrawHelperScreen
	end
end)