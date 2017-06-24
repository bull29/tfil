include("include.lua")

function GlobalCustomColor( returnascolor )
	local x = LocalPlayer():GetPlayerColor()
	if returnascolor then
		return Color( x.r*255, x.g*255, x.b*255 )
	end
	return x.r*255, x.g*255, x.b*255, 255
end