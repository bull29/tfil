hook.RunOnce("HUDPaint", function()
	local PlayerAlphas = {}
	local White = color_white
	file.CreateDir("tfil")

	if not file.Exists("tfil/emojidictionary.txt", "DATA") then
		file.Write("tfil/emojidictionary.txt", "[]")
	end

	local EmojiDictionary = file.Read("tfil/emojidictionary.txt"):JSONDecode()

	hook.Add("Lava.PostLavaRender", "EmojiReactions", function(a, b)
		if b then return end

		for Player in Values(player.GetAll()) do
			if not Player:Alive() or (Player == LocalPlayer() and not Player:ShouldDrawLocalPlayer()) then continue end

			Player:OnBoneExisting("ValveBiped.Bip01_Head1", function(bid)
				if Player.m_CurrentEmoji then
					PlayerAlphas[Player] = PlayerAlphas[Player] or 0

					if Player.m_EmojiShowTime > CurTime() then
						PlayerAlphas[Player] = PlayerAlphas[Player]:lerp(255)
					end

					if PlayerAlphas[Player] > 1 then
						if Player.m_EmojiShowTime < CurTime() then
							PlayerAlphas[Player] = PlayerAlphas[Player]:lerp(0)
						end

						cam.Wrap3D2D(function()
							draw.WebImage(WebElements.SpeechBubble, 0, -40, 40, 40, (Player:PlayerColor() - 50):Alpha(PlayerAlphas[Player]))
							draw.WebImage(Emoji.Get(Player.m_CurrentEmoji), 20, -25, 10, 10, White:Alpha(PlayerAlphas[Player]), 0)
						end, Player:GetBonePosition(bid), Angle(0, 270 + EyeAngles().y, 90), 1)

						if Player.m_EmojiPreText then
							if Player.m_EmojiPostText == "" then
								Player.m_EmojiPostText = nil
							end

							cam.Wrap3D2D(function()
								draw.SimpleText(Player.m_EmojiPreText, "lava_emoji_reaction", not Player.m_EmojiPostText and 400 or 275, not Player.m_EmojiPostText and -725 or -575, White:Alpha(PlayerAlphas[Player]), not Player.m_EmojiPostText and 1 or 2)

								if Player.m_EmojiPostText then
									draw.SimpleText(Player.m_EmojiPostText, "lava_emoji_reaction", 525, -575, White:Alpha(PlayerAlphas[Player]), 0)
								end
							end, Player:GetBonePosition(bid), Angle(0, 270 + EyeAngles().y, 90), 0.05)
						end
					else
						Player.m_EmojiPreText = nil
						Player.m_EmojiPostText = nil
					end
				end
			end)
		end
	end)

	hook.Add("OnPlayerChat", "EmojiInterperate", function(Player, Text)
		--if (not Player.m_EmojiShowTime or Player.m_EmojiShowTime < CurTime()) then
			if Text:match("^%$%d+$") then
				local int = tonumber((Text:match("^%$%d+"):gsub("%D", "")))
				if int > 2661 or int < 0 then return end
				Player.m_CurrentEmoji = int
				Player.m_EmojiShowTime = CurTime() + 10
				Player:EmitSound("garrysmod/balloon_pop_cute.wav")
				return true
			end

			if Text:match("%{%$%d+%}") then
				local data = Text:match("%{%$%d+%}")
				local EmojiNum = data:gsub("[%{%$%}]", "")
				local Prepend = Text:Split(data)[1]
				local Postend = Text:Split(data)[2]
				Player.m_CurrentEmoji = tonumber(EmojiNum)
				Player.m_EmojiShowTime = CurTime() + 10
				Player.m_EmojiPreText = Prepend
				Player.m_EmojiPostText = Postend:gsub("^%s", "")
				Player:EmitSound("garrysmod/balloon_pop_cute.wav")
				return true
			end
	--	end

		local x = Text:match("^%$%a+%=%d+$")

		if x then
			if Player == LocalPlayer() then
				local Variable = x:gsub("^%$", ""):gsub("%=.+", "")
				local EmojiBind = tonumber((x:gsub("^%$.+%=", ""))):max(0):min(2661)
				chat.AddText(pColor(), "Word " .. Variable .. " has been binded to Emoji #" .. EmojiBind)
				EmojiDictionary[Variable] = EmojiBind
				file.Write("tfil/emojidictionary.txt", util.TableToJSON(EmojiDictionary))
			end

			return true
		end
	end)

	hook.Add("OnChatTab", "EmojiBind", function(Text)
		if Text:sub(1, 1) == "$" and EmojiDictionary[Text:gsub("%$", "")] then
			return "$" .. EmojiDictionary[Text:gsub("%$", "")]
		elseif Text:match("%{%a+}") then
			local match = Text:match("%{%a+}")
			if EmojiDictionary[match:gsub("%A", "")] then return Text:gsub("%{" .. match:gsub("%A", "") .. "%}", "{$" .. EmojiDictionary[match:gsub("%A", "")] .. "}") end
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

		if Text:sub(1,1) == "$" and Text:match("%$%d+$") then
			cNum = tonumber( (Text:gsub("%D", "" )) )
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

		draw.WebImage( Emoji.Get( cNum ), x + sx + WebElements.Edge * 2, y + sy - ScrH()/25 - WebElements.Edge, ScrH()/25, ScrH()/25 )
	end)

	local LocalPlayerAlpha = 0

	hook.Add("HUDPaint", "RenderLocalPlayer", function()
		if LocalPlayer():Alive() and LocalPlayer().m_CurrentEmoji and LocalPlayer().m_EmojiShowTime > CurTime() and not LocalPlayer():ShouldDrawLocalPlayer() then
			LocalPlayerAlpha = LocalPlayerAlpha:lerp(255)
		elseif LocalPlayerAlpha > 1 then
			LocalPlayerAlpha = LocalPlayerAlpha:lerp(0)
		end

		if LocalPlayerAlpha > 1 and LocalPlayer():Alive() and LocalPlayer().m_CurrentEmoji then
			draw.WebImage(WebElements.SpeechBubble, ScrW() * 0.25, ScrH() - ScrH() / 8, ScrH() / 4, ScrH() / 4, (pColor() - 50):Alpha(LocalPlayerAlpha), 0)
			draw.WebImage(Emoji.Get(LocalPlayer().m_CurrentEmoji), ScrW() * 0.25, ScrH() - ScrH() / 32 - ScrH() / 8, ScrH() / 16, ScrH() / 16, White:Alpha(LocalPlayerAlpha), CurTime():sin() * -15)
		end
	end)
end)