local hook = hook
local cam = cam
local draw = draw
local render = render
local EyePos = EyePos
local CurTime = CurTime
local math = math
local drawOverlay = DrawMaterialOverlay
local drawColor = DrawBloom
local LocalPlayer = LocalPlayer
local surface = surface
local v = Vector()
local LavaTexture = "http://i.imgur.com/swJIriB.jpg"
local SmoothLevel = -1000

hook.Add("PostDrawTranslucentRenderables", "DrawLava", function(a, b)
	if b then return end
	SmoothLevel = SmoothLevel:lerp(Lava.GetLevel())

	cam.Wrap3D2D(function()
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(draw.fetch_asset(LavaTexture, "noclamp"))
		surface.DrawTexturedRectUV(-8, -8, 16, 16, 0, 0, 10, 10)
	end, v:SetZ(SmoothLevel), Angle(0, CurTime() / 3, 0), 4000)
end)

hook.Add("RenderScreenspaceEffects", "DrawLavaOverlay", function()
	if player_manager.GetPlayerClass(LocalPlayer()) == "lava_walker" then return end

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

hook.Add("HUDShouldDraw", "DisableDeathscreen", function(name)
	if name == "CHudDamageIndicator" then return false end
end)