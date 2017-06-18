local hook = hook
local cam = cam
local draw = draw
local render = render
local EyePos = EyePos
local CurTime = CurTime
local math = math
local drawOverlay = DrawMaterialOverlay
local drawColor = DrawBloom
local Lava = Lava
local LocalPlayer = LocalPlayer

local v = Vector(-2193.622803, -2168.888184, -350)
local Col = Color(255, 255, 255, 255)
local SmoothLevel = -1000

hook.Add("PostDrawTranslucentRenderables", "DrawLava", function(a, b)
	if b then return end
	SmoothLevel = SmoothLevel:lerp( Lava.GetLevel() )
	cam.Start3D2D(v:SetZ( SmoothLevel ), Angle(0, CurTime()/2, 0), 4000)
	cam.End3D2D()
end)


hook.Add("RenderScreenspaceEffects", "DrawLavaOverlay", function()
	if EyePos().z < Lava.GetLevel() then
		if not LocalPlayer():Alive() then
			drawColor(0, 3, 0, 0, 0, 20, 255, 128, 0)
			return
		end
		drawColor(0, 3, 0, 0, 0, 20, 255, 128, 0)
		drawOverlay("effects/water_warp01", 1)

	elseif LocalPlayer():GetPos().z <= Lava.GetLevel() then

		drawColor(0, (math.sin(CurTime() * 10) * 3):abs(), 0, 0, 0, 20, 255, 128, 0)
	end
end)
