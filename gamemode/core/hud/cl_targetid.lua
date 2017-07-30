local WebElements = WebElements
local x = NULL
local bPos = Vector()
local cam = cam
local draw = draw

function GM:HUDDrawTargetID()
end

hook.Add("PreDrawOpaqueRenderables", "ThisThing", function()
	x = LocalPlayer():EyeEntity()

	if x:IsValid() and (x:IsPlayer() or x.m_Player) then
		x = x.m_Player or x
		x.m_UniqueEmoji = x.m_UniqueEmoji or util.CRC((x:SteamID64() or 1566124349)) % #Emoji.Index

		bPos = x:GetBonePosition(x:LookupBone("ValveBiped.Bip01_Head1")) + Vector(0, 0, 15)

		cam.Wrap3D2D(function()
			local Wide, Tall = FontFunctions.GetSize(x:Nick(), "ChatFont")
			draw.RoundedBox(4, -Wide * 0.75, 0, Wide * 1.5, Tall * 1.5, x:PlayerColor())
			draw.SimpleText(x:Nick(), "ChatFont", (Wide * 1.5) / 2 -Wide * 0.75, (Tall * 1.5) / 2, nil, 1, 1)

			draw.RoundedBox(4, -Wide - Wide/8, -Wide/4, Tall * 1.5, Tall * 1.5, ( x:PlayerColor() - 50 ) )
			draw.WebImage( Emoji.Get( x.m_UniqueEmoji ), -Wide - Wide/8, -Wide/4, Tall * 1.5, Tall * 1.5 )
		end, bPos - LocalPlayer():GetForward() * 5, Angle(0, 270 + EyeAngles().y, 90), 0.25)
	end
end)