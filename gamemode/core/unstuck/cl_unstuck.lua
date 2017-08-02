

hook.Add("Lava.PopulateWidgetMenu", "CreateUnstuckWidet", function( Context )
	Context.NewWidget( "Unstuck", 2618, function()
		net.Start("lava_unstuck")
		net.SendToServer()
	end)
end)
