-- To allow other mods to mirror the world, we add this get/set function
if SERVER then return end

if MapMirrorToggle == nil then
	MapMirrorToggle = false
end

local render = render

-- View model flip
local lastSetting = false

hook.Add("Think", "Mirror.Think", function()
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

-- Variables
local View
local rtMirror = render.GetMorphTex0()


-- Set up the render target and material to do the transformation
local MirroredMaterial = CreateMaterial("MirroredMaterial", "UnlitGeneric", {
	['$basetexture'] = rtMirror,
	['$basetexturetransform'] = "center .5 .5 scale -1 1 rotate 0 translate 0 0",
	['$nocull'] = "1"
})

-- Render our mirrored scene
hook.Add("RenderScene", "Mirror.RenderScene", function(pos, ang)
	if MapMirrorToggle then
		-- Save our previous RT
		rtPrev = render.GetRenderTarget()

		-- Setup the view table
		View = {
			x = 0,
			y = 0,
			w = ScrW(),
			h = ScrH(),
			origin = pos,
			angles = ang
		}

		-- Push the RT and render
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

		-- Go back to the previous RT we stored earlier
		render.SetRenderTarget(oldrt)
		-- Setup our MirroredMaterial.
		MirroredMaterial:SetTexture("$basetexture", rtMirror)
		-- Draw
		render.SetMaterial(MirroredMaterial)
		render.DrawScreenQuad()

		if not MapMirrorToggle then
			-- We don't want the HUD to get mirrored too, so we draw it here.
			render.RenderHUD(0, 0, ScrW(), ScrH())
		end

		return true
	end
end)

-- Apply some transformations to the Vector.ToScreen method.
local VECTOR = FindMetaTable("Vector")
VECTOR.ToScreenOld = VECTOR.ToScreenOld or VECTOR.ToScreen

function VECTOR:ToScreen()
	if not MapMirrorToggle then return self.ToScreenOld(self) end
	local pos = self.ToScreenOld(self)
	pos.x = pos.x * -1 + ScrW()

	return pos
end

-- Parse input from the mouse and keyboard to work with out new view.
hook.Add("InputMouseApply", "com.casualbananas.MirrorWorld.FlipMouse", function(cmd, x, y, angle)
	if MapMirrorToggle then
		local pitchchange = y * GetConVar("m_pitch"):GetFloat()
		local yawchange = x * -GetConVar("m_yaw"):GetFloat()
		angle.p = angle.p + pitchchange * 1
		angle.y = angle.y + yawchange * -1
		cmd:SetViewAngles(angle)

		return true
	end
end)

hook.Add("CreateMove", "com.casualbananas.MirrorWorld.FlipMovement", function(cmd)
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
