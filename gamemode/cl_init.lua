include("include.lua")

function GlobalCustomColor( returnascolor )
	local x = LocalPlayer():GetPlayerColor()
	if returnascolor then
		return returnascolor and Color( x.r*255, x.g*255, x.b*255 ) or x.r*255, x.g*255, x.b*255, 255
	end
end