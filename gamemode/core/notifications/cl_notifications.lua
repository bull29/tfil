local function CreateNotification(title, time, InitialColor, sound )
	InitialColor = InitialColor or pColor()
	MsgC( Color( 255, 0, 0 ), "\nNotification: " )
	MsgC( InitialColor, "\n"..title:gsub("\t", "").."\n" )
	surface.PlaySound( sound )

	local CurrentNotification = InitializePanel("CurrentNotification", "DLabel")
	CurrentNotification:Dock(FILL)
	CurrentNotification:SetContentAlignment(9)
	CurrentNotification:SetFont("lava_mutator_notifier")
	CurrentNotification:SetPaintedManually(true)
	CurrentNotification:SetTextColor(InitialColor)
	CurrentNotification.Removal = CurTime() + time
	CurrentNotification:SetText( title )
	local OldVal = 2500

	CurrentNotification.PaintOver = function(s)
		if s.Removal < CurTime() then
			s.CurrentColor = s.CurrentColor or s:GetTextColor()
			s.CurrentColor = s.CurrentColor:Lerp(Color(255, 255, 255), FrameTime() * 3)
			s:SetTextColor(s.CurrentColor)
			OldVal = OldVal:lerp(OldVal + 200)

			if OldVal > 2500 then
				hook.Remove("PostDrawTranslucentRenderables", "DrawNotifications")
				s:Remove()
			end
		else
			OldVal = OldVal:lerp(LocalPlayer():GetVelocity():Length() / 20)
		end
	end

	hook.Add("PostDrawTranslucentRenderables", "DrawNotifications", function()
		cam.Start3D2D(EyeAngles():Right() * -ScrH()*0.1 + LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * (50 + OldVal), Angle(0, -90 + EyeAngles().y, 90), 0.1)
		CurrentNotification:PaintManual()
		cam.End3D2D()
	end)
end

function GM.CreateNotification( title, time, color, sound )
	CreateNotification( title, time, color, sound )
end

net.Receive("lava_notification",function()
	GAMEMODE.CreateNotification( net.ReadString(), net.ReadInt( 32 ), pColor(), net.ReadString())
end)