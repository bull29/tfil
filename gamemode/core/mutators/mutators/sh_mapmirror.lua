Mutators.RegisterNewEvent( "World Flip!", "The Game World is completely Flipped!\nSurvive...", function()
	MapMirrorToggle = true
end, function()
	MapMirrorToggle = false
end)


Mutators.Events[ "World Flip!"].EndFunction()
