local White = color_white
local Phrases = {
	Suicide = {
		"{v}::2491 2535",
	},
	PVP = {
		"{a}::1996::{v}::2491",
	},
	Entities = {
		entityflame = {
			"{v}::1457 2491",
		},
		worldspawn = {
			"{v}::2107 2491",
		},
	},
	Unknown = {
		"{v}::2535"
	}
}

local function ParseEmojis( str )
	if not str:match("::") then return false end
	str = str:gsub(".+::", "" )
	local x = str:Split(" ")
	return #x > 0 and x or false
end

local function SelectSharedPhrase( tab )
	return tab[ ( CurTime() + util.SharedRandom("m_RandomPhrase", 1, 9999, CurTime()) ):floor()%#tab + 1]
end

hook.RunOnce("HUDPaint", function()
	local c = InitializePanel("LavaKillNotifier", "DPanel")
	c:SetSize( ScrW()/3,ScrH()*0.7)
	c:Center()
	c:SetVerticalPos( ScrH()*0.35 )
	c:SetHorizontalPos( ScrW() - ScrW()/3 )
	c.Paint = function( s, w, h )
		for Index, Child in pairs(s:GetChildren()) do
			if Child.m_BeingRemoved then
				Child.Alpha = Child.Alpha:lerp( 0, FrameTime() * 10 )
				Child:SetPos( Child:GetPos() + 5, Child:GetVerticalPos() )
				if Child:GetPos() > w - 1 then
					Child:Remove()
					continue
				end
				continue
			end
			Child.Index = Index - 1
		end
	end

	local function DesiredPos( CurrentIndex )
		return CurrentIndex * (ScrH()/25 + WebElements.Edge/2)
	end

	local function SelectPhrase( Victim, Attacker )
		local SelectedPhrase = Phrases.Unknown

		if type( Attacker ):lower() == "player" then
			SelectedPhrase = Phrases.PVP
		end

		if Victim == Attacker then
			SelectedPhrase = Phrases.Suicide
		end

		if Phrases.Entities[ IsValid( Attacker ) and Attacker:GetClass():lower() or "worldspawn" ] then
			SelectedPhrase = Phrases.Entities[ IsValid( Attacker ) and Attacker:GetClass():lower() or "worldspawn" ]
		end

		return hook.Call("Lava.SelectPlayerDeathPhrase", nil, Victim, Attacker, SelectedPhrase ) or SelectSharedPhrase( SelectedPhrase )
	end

	function AddKill( Player, Attacker )
		chat.PlaySound()
		MsgC(color_white, tostring( Player ) .. " died from " .. tostring( Attacker ) .. "\n")
		local IsKill = false
		local Phrase = SelectPhrase( Player, Attacker )
		local IsPlayer = type( Attacker ):lower() == "player"
		if Phrase:match("::.+::") then
			IsKill = true
		end
		local x = c:Add("DLabel")
		x:SetSize( c:GetSize(), ScrH()/25 )
		x:SetFont("lava_notification_font")
		x:SetTextInset( ScrW()/75, 0 )
		x:SetTextColor( color_white )
		x.Emojis = ParseEmojis( Phrase )

		x:SetText( Phrase:gsub("::.-::", "                " ):gsub("::.+", ""):gsub("{v}", Player:Nick() ):gsub("{a}", IsValid( Attacker ) and Attacker:IsPlayer() and Attacker:Nick() or "?" ))

		x.TextEndPos = FontFunctions.GetWide( x:GetText(), "lava_notification_font") + ScrW()/75 * 2
		x:SetWide( x.TextEndPos + (#( x.Emojis or {}) * ScrH()/30))
		x:SetHorizontalPos( c:GetWide() - x:GetWide())
		x.DeleteTime = CurTime() + 6
		x.Alpha = 0
		x.Index = #c:GetChildren()
		x.Paint = function( s, w, h )
			if not IsValid( Player ) or ( IsPlayer and not IsValid( Attacker ) ) then s:Remove() return end
			s:Declip( function()
				s.Alpha = s.Alpha:lerp( 255 )
				if s.DeleteTime < CurTime() and s:GetVerticalPos() == DesiredPos( s.Index ) then
					s.m_BeingRemoved = true
				end
				if not s.InitialPaint then
					s.InitialPaint = true
					s:SetVerticalPos( DesiredPos( s.Index ) )
				end
				draw.RoundedBox( 6, 0, 0, w, h, pColor():Alpha( s.Alpha ) - 50 )
				draw.RoundedBox( 6, WebElements.Edge/2, WebElements.Edge/2, w - WebElements.Edge, h - WebElements.Edge, pColor():Alpha( s.Alpha ) )
				if s.Emojis then
					for Index, Em in pairs( s.Emojis ) do
						draw.WebImage( Emoji.Get( tonumber( Em ) ), s.TextEndPos + ( Index - 1 ) * h, h/2, h*0.9, h*0.9, White:Alpha( s.Alpha ), 0 )
					end
				end
				if Phrase:match("::.-::") then
					draw.WebImage( Emoji.Get( tonumber(Phrase:match("::.-::"):gsub(":", ""), 10) ), FontFunctions.GetWide( Attacker:Nick(), "lava_notification_font" ) + h, 0, h, h )
				end
				s:SetTextColor( s:GetTextColor():Alpha( s.Alpha ))

				s:SetVerticalPos( s:GetVerticalPos():Approach( DesiredPos( s.Index ), 1 ))
			end)
		end
	end

	net.Receive("lava_player_death", function()
		AddKill( net.ReadEntity(), net.ReadEntity())
	end)
end)