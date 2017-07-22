local m_DisableRenderHUD

hook.Add("Lava.PopulateWidgetMenu", "CreateScreenshotPane", function( Context )
	Context.NewWidget( "Screenshot Mode", 1413, function()
		m_DisableRenderHUD = not m_DisableRenderHUD
	end)
end)

hook.Add( "HUDShouldDraw", "ScreenshotPane", function( name )
	if m_DisableRenderHUD and ( name == "CHudGMod" or name == "CHudChat") then
		return false
	end
end)