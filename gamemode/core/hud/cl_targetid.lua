local WebElements = WebElements
local x = NULL
local bPos = Vector()
local cam = cam
local draw = draw

local bPosV = {
	x = 0,
	y = 0
}

function GM:HUDDrawTargetID()
	if x:IsValid() and ( x:IsPlayer() or x.m_Player ) then
		local x = ( x:IsPlayer() and x ) or x.m_Player
		draw.SimpleText(x:Nick(), "lava_abilities_header", ScrW() / 2 - FontFunctions.GetWide(x:Nick(), "lava_abilities_header") / 2, ScrH() / 50, x:PlayerColor())
		surface.SetDrawColor(x:PlayerColor())
		surface.DrawLine(ScrW() / 2, ScrH() / 50  + ScrH() / 15, bPosV.x, bPosV.y)
	end
end

hook.Add("PostDrawTranslucentRenderables", "ThisThing", function()
	x = LocalPlayer():EyeEntity()

	if x:IsValid() and ( x:IsPlayer() or x.m_Player ) then
		bPos = x:GetBonePosition(x:LookupBone("ValveBiped.Bip01_Head1")) + Vector(0, 0, 3)

		cam.Wrap3D2D(function()
			bPosV = ( bPos + Vector( 0, 0, 10 ) ):ToScreen()
			cam.IgnoreZ(true)
			draw.WebImage(WebElements.QuadCircle, 0, 0, 10, 10, x.PlayerColor and x:PlayerColor() or x.m_Player:PlayerColor(), CurTime():sin() * 360)
			cam.IgnoreZ(false)
		end, bPos, Angle(-90, EyeAngles().y, 0), 1.75)
	end
end)