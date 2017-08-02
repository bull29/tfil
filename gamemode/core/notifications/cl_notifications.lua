local pColor = pColor
local WebElements = WebElements
local Color = Color
local White = Color(255, 255, 255)
local surface = surface
local draw = draw

hook.RunOnce("HUDPaint", function()
	local t = InitializePanel("LavaNotificationHandler", "DPanel")
	t:SetSize(ScrW(), ScrH() * 0.35)
	t:Center()
	t:SetVerticalPos(ScrH() / 100)
	t:SetMouseInputEnabled( false )
	t:SetZPos( 32000 )
	t.Paint = function(s, w, h)
		for Index, Child in pairs(t:GetChildren()) do
			if Child.m_BeingRemoved then continue end
			Child.Index = Index - 1
		end

		if #s:GetChildren() == 0 then
			s:Hide()
		end
	end

	local function GetPos(CurrentNum)
		return (CurrentNum) * (ScrH() / 20 + ScrH() / 200)
	end

	local function AddNotification(Name, Icon, Time, Sound)
		if Sound then
			surface.PlaySound( Sound )
		end

		local pC = pColor()
		MsgC( pC, "[ NOTIFICATION ] ", -pC, Name, "\n")

		Icon, Time = Icon or 2438, Time or 6
		local x = t:Add("DLabel")
		x:SetSize(FontFunctions.GetWide(Name, "lava_notification_font") + ScrH() / 20 * 2.1, ScrH() / 20)
		x.RemovalTime = CurTime() + Time
		x:CenterHorizontal()
		x.Alpha = 0
		x:SetFont("lava_notification_font")
		x:SetTextColor(White)
		x:SetTextInset(ScrW() / 40, 0)
		x:SetContentAlignment(5)
		x:SetText(Name)

		x.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, pColor():Alpha(self.Alpha))
			draw.WebImage(Emoji.Get(Icon), h / 2, h / 2, h * 0.8, h * 0.8, nil, ( CurTime() * 3 ):sin() * 15)
			draw.WebImage(Emoji.Get(Icon), w - h / 2, h / 2, h * 0.8, h * 0.8, nil, ( CurTime() * 3 ):sin() * 15)

			if CurTime() > self.RemovalTime then
				self.m_BeingRemoved = true
				self:SetVerticalPos(self:GetVerticalPos() - 1)
				self.Alpha = self.Alpha:lerp(0)
			else
				self.Alpha = self.Alpha:lerp(200)

				if self:GetVerticalPos() > GetPos(self.Index or 0) then
					self:SetVerticalPos(self:GetVerticalPos():Approach(GetPos(self.Index or 0), 1))
				else
					self:SetVerticalPos(GetPos(self.Index or 0))
				end
			end

			if (self:GetVerticalPos() + h) < 2 then
				self:Remove()
			end
		end
	end

	net.Receive("lava_notification", function()
		local Table = net.ReadTable()
		local String = net.ReadString()

		AddNotification( String, Table.ICON, Table.TIME, Table.SOUND )

		if IsValid( t ) then
			t:Show()
		end
	end)

	net.Receive("lava_chatalert",function()
		chat.AddText( pColor(), net.ReadString() )
	end)
end)