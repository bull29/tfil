-- Derived from Map Mirror by Kurt Stolle.

-- https://github.com/kurt-stolle/mapmirror/
-- https://github.com/kurt-stolle/mapmirror/blob/master/LICENSE

local AddHook = Mutators.RegisterHooks("World Flip!", {"Think", "RenderScene", "InputMouseApply", "CreateMove"})

Mutators.RegisterNewEvent("World Flip!", "The Game World is completely Flipped!", function()
	if SERVER then return end

	MapMirrorToggle = true

	local render = render
	local lastSetting = false

	AddHook(function()
		if lastSetting ~= MapMirrorToggle then
			lastSetting = MapMirrorToggle

			for _, tab in ipairs(weapons.GetList()) do
				tab = weapons.GetStored(tab.ClassName)
				tab.ViewModelFlip = not tab.ViewModelFlip
			end

			for _, tab in ipairs(LocalPlayer():GetWeapons()) do
				tab.ViewModelFlip = not tab.ViewModelFlip
			end
		end
	end)

	local View
	local rtMirror = render.GetMorphTex0()

	local MirroredMaterial = CreateMaterial("MirroredMaterial", "UnlitGeneric", {
		['$basetexture'] = rtMirror,
		['$basetexturetransform'] = "center .5 .5 scale -1 1 rotate 0 translate 0 0",
		['$nocull'] = "1"
	})

	AddHook(function(pos, ang)
		if MapMirrorToggle then
			rtPrev = render.GetRenderTarget()

			View = {
				x = 0,
				y = 0,
				w = ScrW(),
				h = ScrH(),
				origin = pos,
				angles = ang
			}

			render.SetRenderTarget(rtMirror)
			render.Clear(0, 0, 0, 255, true)
			render.ClearDepth()
			render.ClearStencil()
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
			render.RenderView(View)
			render.PopFilterMag()
			render.PopFilterMin()

			if MapMirrorToggle then
				render.RenderHUD(0, 0, ScrW(), ScrH())
			end

			render.SetRenderTarget(oldrt)
			MirroredMaterial:SetTexture("$basetexture", rtMirror)
			render.SetMaterial(MirroredMaterial)
			render.DrawScreenQuad()

			if not MapMirrorToggle then
				render.RenderHUD(0, 0, ScrW(), ScrH())
			end

			return true
		end
	end)

	local VECTOR = FindMetaTable("Vector")
	VECTOR.ToScreenOld = VECTOR.ToScreenOld or VECTOR.ToScreen

	function VECTOR:ToScreen()
		if not MapMirrorToggle then return self.ToScreenOld(self) end
		local pos = self.ToScreenOld(self)
		pos.x = pos.x * -1 + ScrW()

		return pos
	end

	AddHook(function(cmd, x, y, angle)
		if MapMirrorToggle then
			local pitchchange = y * GetConVar("m_pitch"):GetFloat()
			local yawchange = x * -GetConVar("m_yaw"):GetFloat()
			angle.p = angle.p + pitchchange * 1
			angle.y = angle.y + yawchange * -1
			cmd:SetViewAngles(angle)

			return true
		end
	end)

	AddHook(function(cmd)
		if MapMirrorToggle then
			local forward = 0
			local right = 0
			local maxspeed = LocalPlayer():GetMaxSpeed()

			if cmd:KeyDown(IN_FORWARD) then
				forward = forward + maxspeed
			end

			if cmd:KeyDown(IN_BACK) then
				forward = forward - maxspeed
			end

			if cmd:KeyDown(IN_MOVERIGHT) then
				right = right - maxspeed
			end

			if cmd:KeyDown(IN_MOVELEFT) then
				right = right + maxspeed
			end

			cmd:SetForwardMove(forward)
			cmd:SetSideMove(right)
		end
	end)
end, function()
	MapMirrorToggle = false
end)

--Mutators.StartEvent("World Flip!")
