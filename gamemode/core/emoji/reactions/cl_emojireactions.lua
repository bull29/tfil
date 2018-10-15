hook.RunOnce("HUDPaint", function()
	local PlayerAlphas = {}
	local White = color_white
	file.CreateDir("tfil")

	if not file.Exists("tfil/emojidictionary.txt", "DATA") then
		file.Write("tfil/emojidictionary.txt", "[]")
	end

	local EmojiDictionary = file.Read("tfil/emojidictionary.txt"):JSONDecode()

	hook.Add("Lava.PostLavaRender", "EmojiReactions", function(a, b)
		for _, Player in pairs( player.GetAll() ) do
			Player.m_BubbleAlpha = Player.m_BubbleAlpha or 0
			if Player.m_EmojiDisappearTime and Player.m_EmojiDisappearTime < CurTime() and Player.m_BubbleAlpha then
				Player.m_BubbleAlpha = Player.m_BubbleAlpha:lerp( 0 )
				if Player.m_BubbleAlpha < 5 then
					Player.m_ActiveEmojis = {}
				end
			end
			if Player.m_ActiveEmojis and Player.m_ActiveEmojis[ 1 ] then
			--if Player == LocalPlayer() then continue end
				if Player.m_EmojiDisappearTime > CurTime() then
					Player.m_BubbleAlpha = Player.m_BubbleAlpha:lerp( 255 )
				end
				cam.Wrap3D2D( function()
					surface.SetAlphaMultiplier( Player.m_BubbleAlpha / 255 )
					draw.WebImage( "https://i.imgur.com/rrSZw9C.png", 0, 0, 50, 50, pColor() )

					local Amount = #Player.m_ActiveEmojis
					for i = 1, Amount do
						local Size = (20 / Amount * 1.8 ):min(10):max( 3 )
						draw.WebImage(Emoji.Get(Player.m_ActiveEmojis[i]), 24 + (i - 1) * Size - (Amount - 1) * Size / 2, 19, Size, Size, nil, 0)
					end
					surface.SetAlphaMultiplier( 1 )
				end, Player:EyePos() + Vector( 0, 0, 50 ), Angle(0, 270 + EyeAngles().y, 90), 1 )
			end
		end
	end)

	hook.Add("OnPlayerChat", "EmojiInterperate", function(Player, Text)
		if not Text:StartWith( "$<em>{" ) then return end

		local Emote = Text:match( "$<em>%{.+%}" ):gsub( "$<em>%{", "" ):gsub( "%}", "" )
		
		if Emoji.Get( Emote ) then
			if not Player.m_ActiveEmojis then
				Player.m_ActiveEmojis = {}
			end
			Player:EmitSound("garrysmod/balloon_pop_cute.wav")
			table.insert( Player.m_ActiveEmojis, Emote )
			if #Player.m_ActiveEmojis == 7 then
				table.remove( Player.m_ActiveEmojis, 1 )
			end
			Player.m_EmojiDisappearTime = CurTime() + 6
			return true
		end
	end)

	local cNum

	hook.Add("ChatTextChanged", "EmojiBindLookup", function(Text)
		if Text:sub(1, 1) == "$" and EmojiDictionary[Text:gsub("%$", "")] then
			gui.InternalKeyCodeTyped(KEY_TAB)
		end

		if Text:match("%{%a+}") and EmojiDictionary[Text:match("%{%a+}"):gsub("%A", "")] and not input.IsKeyDown(KEY_LSHIFT) then
			gui.InternalKeyCodeTyped(KEY_TAB)
		end

		if Text:sub(1, 1) == "$" and Text:match("%$%d+$") then
			cNum = tonumber((Text:gsub("%D", "")))

			if cNum > #Emoji.Index then
				cNum = nil
			end
		else
			cNum = nil
		end
	end)

	hook.Add("HUDPaint", "EmotePreview", function()
		if not cNum then return end
		local x, y = chat.GetChatBoxPos()
		local sx, sy = chat.GetChatBoxSize()
		draw.WebImage(Emoji.Get(cNum), x + sx + WebElements.Edge * 2, y + sy - ScrH() / 25 - WebElements.Edge, ScrH() / 25, ScrH() / 25)
	end)

	local LocalPlayerAlpha = 0

	hook.Add("HUDPaint", "RenderLocalPlayer", function()
		if LocalPlayer():Alive() and LocalPlayer().m_ActiveEmojis and LocalPlayer().m_EmojiDisappearTime and LocalPlayer().m_EmojiDisappearTime > CurTime() and not LocalPlayer():ShouldDrawLocalPlayer() then
			LocalPlayerAlpha = LocalPlayerAlpha:lerp(255)
		elseif LocalPlayerAlpha > 1 then
			LocalPlayerAlpha = LocalPlayerAlpha:lerp(0)
		elseif LocalPlayerAlpha < 1 and not LocalPlayer():ShouldDrawLocalPlayer() then
			LocalPlayer().m_ActiveEmojis = {}
		end

		if LocalPlayerAlpha > 1 and LocalPlayer():Alive() and LocalPlayer().m_ActiveEmojis then
			draw.WebImage(WebElements.SpeechBubble, ScrW() * 0.25, ScrH() - ScrH() / 8, ScrH() / 4, ScrH() / 4, (pColor() - 50):Alpha(LocalPlayerAlpha), 0)
			local Amount = #LocalPlayer().m_ActiveEmojis

			for i = 1, Amount do
				local Size = (ScrW() * 0.05 / Amount):min(ScrW() * 0.5):max(ScrH() / 32)
				draw.WebImage(Emoji.Get(LocalPlayer().m_ActiveEmojis[i]), ScrW() * 0.25 + (i - 1) * Size - (Amount - 1) * Size / 2, ScrH() - ScrH() / 32 - ScrH() / 8, Size, Size, White:Alpha(LocalPlayerAlpha), 0)
			end
		end
	end)
end)