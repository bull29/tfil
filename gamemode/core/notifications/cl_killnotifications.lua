local White = color_white
local Phrases = {
	Suicide = {
		"{v} has offed themselves.::1620 1463",
		"{v} pulled a Kirk Cobain.::1970 499",
		"{v} had a really fatal idea.::1321 2491",
		"{v} self-deded.::2535",
		"{v} received a darwin award.::689 2491",
		"{v} thought he would look better dead.::2491"
	},
	PVP = {
		"{a} + {v} = {v}::2491",
		"{a} schlonged {v}::385 1991",
		"{v} was fisted by {a}.::1992",
		"{a} gave {v} a fatal pee-pee touch.::2038 385",
		"{v} lost a fist fight with {a}.::1651",
		"{v} got bamboozled by {a}.",
		"{a} punched {v} into the fifth dimension.::461 464",
		"{a} popped a capped in {v}'s ass.::1340 396 1341",
		"{a} deded {v}."
	},
	Entities = {
		prop_ragdoll = {
			"{v} somehow died from a corpse. ::2423"
		},
		entityflame = {
			"{v} Skinny dipped into lava.::328",
			"The lava monster devoured {v}::1198 328",
			"{v} Tried to join the X-Men by showering in lava.::1968 328",
			"The Floor is {v}'s remains.::328",
			"{v} appreciates lava a little too much.::328",
			"{v} made a deep spiritual connection with magma.::328",
			"{v} is fatally a Lavasexual.::385 328",
			"The lava made {v} into its' bitch.::328 385"
		},
		worldspawn = {
			"{v} jumped high without a parachute.::1449 2491",
			"{v} thought he could fly.::2455 2491",
			"{v} donated their body to the earth.::2520",
			"{v} played chicken with gravity.::628 2491",
			"{v} fell and died. "
		},
	},
	Unknown = {
		"{v} Died of mysterious causes.::1966 2247"
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
		MsgC(color_white, tostring( Player ) .. " died from " .. tostring( Attacker ) .. "\n")

		local Phrase = SelectPhrase( Player, Attacker )
		local x = c:Add("DLabel")
		x:SetSize( c:GetSize(), ScrH()/25 )
		x:SetFont("lava_notification_font")
		x:SetTextInset( ScrW()/75, 0 )
		x:SetTextColor( color_white )
		x.Emojis = ParseEmojis( Phrase )
		x:SetText( Phrase:gsub(":.+", ""):gsub("{v}", Player:Nick() ):gsub("{a}", IsValid( Attacker ) and Attacker:IsPlayer() and Attacker:Nick() or "?" ))
		x.TextEndPos = FontFunctions.GetWide( x:GetText(), "lava_notification_font") + ScrW()/75 * 2
		x:SetWide( x.TextEndPos + (#( x.Emojis or {}) * ScrH()/30))
		x:SetHorizontalPos( c:GetWide() - x:GetWide())
		x.DeleteTime = CurTime() + 6
		x.Alpha = 0
		x.Index = #c:GetChildren()
		x.Paint = function( s, w, h )
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
			s:SetTextColor( s:GetTextColor():Alpha( s.Alpha ))

			s:SetVerticalPos( s:GetVerticalPos():Approach( DesiredPos( s.Index ), 1 ))

		end
	end
	
	net.Receive("lava_player_death", function()
		AddKill( net.ReadEntity(), net.ReadEntity())
	end)
end)