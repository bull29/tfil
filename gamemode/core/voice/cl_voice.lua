local ActivePlayers = Table()
local IsLocalTalking = false
local draw = draw
local Emoji
local ScrH = ScrH
local ScrW = ScrW
local LocalPlayer = LocalPlayer
local FontFunctions = FontFunctions

function GM:PlayerStartVoice(Player)
	if LocalPlayer() == Player then
		IsLocalTalking = true
	end

	ActivePlayers[Player] = true

	if LavaVoicePanel then
		LavaVoicePanel:Show()
		LavaVoicePanel:AddPlayer(Player)
	end

	ActivePlayers:CleanKeys()
end

function GM:PlayerEndVoice(Player)
	if IsLocalTalking and Player == LocalPlayer() then
		IsLocalTalking = false
	end

	ActivePlayers[Player] = nil

	if LavaVoicePanel and LavaVoicePanel.Players[Player] then
		LavaVoicePanel.Players[Player]:Remove()
		LavaVoicePanel.Players[Player] = nil
	end

	ActivePlayers:CleanKeys()
end

hook.Add("DrawOverlay", "RenderLocalVoice", function()
	if IsLocalTalking then
		local dV = (CurTime() * 3):sin() * 15
		draw.WebImage(Emoji.Get(1588), ScrW() / 25, ScrH() - ScrH() / 5, ScrH() / 10, ScrH() / 10, nil, dV, true)
		draw.WebImage(Emoji.Get(1337), ScrW() / 10 + dV / 3, ScrH() - ScrH() / 3.8 - dV / 2, ScrH() / 10 + dV, ScrH() / 10 + dV, nil, -dV * 0.7, true)
	end
end)

hook.RunOnce("HUDPaint", function()
	Emoji = _G.Emoji

	local v = InitializePanel("LavaVoicePanel", "DIconLayout")
	v:SetWide(ScrW() / 4)

	v.PaintOver = function(s, w, h)
		s:SetPos(ScrW() - w - w / 15, ScrH() - #s:GetChildren() * (ScrH() / 15) - w / 20)
	end

	v.Players = {}
	v:SetPaintedManually(true)
	v:Hide()

	function v:AddPlayer(pl)
		if self.Players[pl] then return end
		local eID = util.CRC((pl:SteamID64() or "$a35")) % #Emoji.Index
		local x = v:Add("DLabel")
		self.Players[pl] = x
		x:Dock(TOP)
		x:SetFont("lava_voice_panel")
		x:SetTall(ScrH() / 15)
		x:DockMargin(0, 0, 0, 2)
		x:SetTextColor(pl:GetPlayerColor():ToColor())
		x.SmoothVoice = pl:VoiceVolume()
		x.PaintOver = function(s, w, h)
			if not s.SetData or Mutators.IsActive("Mystery Men") then
				s.SetData = true
				s:SetText(pl:Nick())
				s:SetTextInset(w - h + 5 - FontFunctions.GetWide(pl:Nick(), "lava_voice_panel") - h / 5, 0)
			end

			if not ActivePlayers[pl] or not IsValid(pl) then
				s:Remove()

				return
			end

			s.SmoothVoice = s.SmoothVoice:lerp(pl:VoiceVolume() * 1.56, FrameTime() * 5)
			local var = w - s.SmoothVoice * w - h
			draw.WebImage(Emoji.Get(eID), var, 3, h - 6, h - 6)
			draw.WebImage(Emoji.Get(2646), var + h * 0.9, 3, w - var, h - 6)
		end
	end
end)

hook.Add("PostDrawHUD", "RenderOtherNiggasVoice", function()
	if LavaVoicePanel and next(ActivePlayers) then
		LavaVoicePanel:PaintManual()
	elseif LavaVoicePanel then
		LavaVoicePanel:Hide()
	end
end)