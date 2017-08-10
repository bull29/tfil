--models/props_phx/games/chess/white_queen.mdl, models/props_combine/portalball001_sheet
hook.Add("HUDPaint", "DrawJiffy", function()
	if LocalPlayer():HasAbility("Jiffy Jerry") and LocalPlayer():Alive() then
		if LocalPlayer():KeyDown(IN_SPEED) then
			if not IsValid(JiffyPointer) then
				JiffyPointer = ClientsideModel("models/props_phx/games/chess/white_queen.mdl")
				JiffyPointer:SetMaterial("models/props_combine/portalball001_sheet")
			end

			JiffyPointer:SetNoDraw(false)

			local tR = util.TraceLine{
				start = LocalPlayer():EyePos(),
				mask = MASK_ALL,
				endpos = LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * 200,
				filter = LocalPlayer()
			}

			local tR2 = util.TraceHull{
				start = tR.HitPos,
				mask = MASK_ALL,
				endpos = tR.HitPos + Vector(0, 0, 64),
				mins = Vector(-16, -16, 1),
				maxs = Vector(16, 16, 71)
			}

			if tR2.Hit then
				JiffyPointer:SetColor(Color(255, 0, 0))
			else
				JiffyPointer:SetColor(Color(0, 255, 0))
			end

			JiffyPointer:SetPos(tR.HitPos)
		elseif IsValid(JiffyPointer) then
			JiffyPointer:SetNoDraw(true)
		end

		if LocalPlayer():GetAbilityMeter() ~= 100 or LocalPlayer():KeyDown(IN_SPEED) then
			draw.WebImage(Emoji.Get(1325), ScrW() / 2, ScrH() - ScrH() / 5, ScrH() / 6, ScrH() / 6, pColor():Alpha(150), 0)
			draw.WebImage(Emoji.Get(1325), ScrW() / 2, ScrH() - ScrH() / 5, (LocalPlayer():GetAbilityMeter() / 100) * ScrH() / 6, (LocalPlayer():GetAbilityMeter() / 100) * ScrH() / 6, nil, 0)
		end
	elseif IsValid(JiffyPointer) then
		JiffyPointer:Remove()
		JiffyPointer = nil
	end
end)

hook.Add("SetupMove", "JiffyJerry", function(Player, Movedata)
	if Player:HasAbility("Jiffy Jerry") then
		Player:UpdateAbilityMeter()
		if not Player:Alive() then return end
		if Movedata:KeyDown(IN_SPEED) and Player:KeyPressedNoSpam(IN_RELOAD, Movedata) and Player:CanUseAbility() and Player:GetAbilityMeter() == 100 then
			local tR = util.TraceLine{
				start = Player:EyePos(),
				mask = MASK_ALL,
				endpos = Player:EyePos() + Player:GetAimVector() * 200,
				filter = Player
			}

			local tR2 = util.TraceHull{
				start = tR.HitPos,
				mask = MASK_ALL,
				endpos = tR.HitPos + Vector(0, 0, 64),
				mins = Vector(-16, -16, 1),
				maxs = Vector(16, 16, 71)
			}

			if not tR2.Hit then
				Player:EmitSound("vo/npc/Barney/ba_ohyeah.wav")
				Player:ShiftAbilityMeter(-100)
				Movedata:SetOrigin(tR.HitPos)
			end
		else
			Player:ShiftAbilityMeter(FrameTime() * 30)
		end
	end
end)

Abilities.Register("Jiffy Jerry", [[Thanks to your quick stealth and reflexes, you can be in and out in a jiffy. Hold SHIFT then R to quickly teleport to locations in a Jiffy.]], 820)