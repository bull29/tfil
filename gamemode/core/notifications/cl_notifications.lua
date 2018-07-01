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
		local Result = ""
		
		if (Table[2]) then -- If locale locator exists
			if istable(Table[2]) then -- if locale locator is more than one
				local info = Table[2]
				
				for i = 1, #info do
					print(info[i])
					local Case = string.sub(info[i], 1, 1)
					print(Case)
					if Case=="~" then -- if there's special indicator
						local locale = string.sub(info[i], 2, string.len(info[i]))
						print(locale)
						if (lang[locale]) then
							print('yes wehave@!!!!')
							Result = Result .. lang[locale]
						else
							print('no we havent.....')
							Result = String .. " By The Way It's not Localized"
							break
						end
					else -- if not, treat as a normal string
						Result = Result .. info[i]
					end
				end
				
			else
				local Case = string.sub(Table[2], 1, 1)
				if Case=="~" then -- if there's special indicator for locale
					local locale = string.sub(Table[2], 2, string.len(Table[2]))
					if (lang[locale]) then
						Result = lang[locale]
					else
						Result = String .. " By The Way It's not Localized huh"
					end
				else
					Result = String .. " By The Way It's not Localized huh"
				end
			end
		end
		
		AddNotification( Result, Table[1].ICON, Table[1].TIME, Table[1].SOUND )

		if IsValid( t ) then
			t:Show()
		end
	end)

	net.Receive("lava_chatalert",function()
		local Table = net.ReadTable()
		local String = Table[1]
		local Result = ""
		
		if (Table[2]) then -- If locale locator exists
			if istable(Table[2]) then -- if locale locator is more than one
				local info = Table[2]
				
				for i = 1, #info do
					local Case = string.sub(info[i], 1, 1)
					if Case=="~" then -- if there's special indicator
						local locale = string.sub(info[i], 2, string.len(info[i]))
						if (lang[locale]) then
							Result = Result .. lang[locale]
						else
							Result = String .. " By The Way It's not Localized"
							break
						end
					else -- if not, treat as a normal string
						Result = Result .. info[i]
					end
				end
				
			else
				local Case = string.sub(Table[2], 1, 1)
				if Case=="~" then -- if there's special indicator for locale
					local locale = string.sub(Table[2], 2, string.len(Table[2]))
					if (lang[locale]) then
						Result = lang[locale]
					else
						Result = String .. " By The Way It's not Localized huh"
					end
				else
					Result = String .. " By The Way It's not Localized huh"
				end
			end
		end
		
		chat.AddText( pColor(), Result )
		chat.PlaySound()
	end)
end)

hook.Add( "ChatText", "HideDefaultShit", function( _, _, _, type )
	if type == "joinleave" then return true end
end )