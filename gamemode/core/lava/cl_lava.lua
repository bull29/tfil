local hook = hook
local cam = cam
local draw = draw
local render = render
local EyePos = EyePos
local CurTime = CurTime
local math = math
local drawOverlay = DrawMaterialOverlay
local drawColor = DrawBloom
local GetGlobalVector = GetGlobalVector
local LocalPlayer = LocalPlayer
local surface = surface
local v = Vector()
local LavaTexture = "http://i.imgur.com/swJIriB.jpg"
local SmoothLevel = -1000
local MapScale = 1
local SkyboxScale = 1
local MapBounds = Vector()
local ClipTab = {}

local dirs = {
	left = Vector(-1, 0, 0),
	frwd = Vector(0, -1, 0)
}

local function GetMapBounds()
	local a, b = Entity(0):GetModelRenderBounds()
	a.z, b.z = 0, 0

	return a:Distance(b)
end

hook.RunOnce("SetupSkyboxFog", function(Scale)
	SkyboxScale = 1 / Scale
end)

hook.RunOnce("HUDPaint", function()
	MapScale = GetMapBounds()
	MapBounds = Entity(0):GetModelRenderBounds()
	ClipTab = { {dirs.left, MapBounds.x}, {-dirs.left, MapBounds.x}, {dirs.frwd, MapBounds.y}, {dirs.frwd, MapBounds.y} }
end)

hook.Add("PostDrawTranslucentRenderables", "DrawLava", function(a, b)
	SmoothLevel = SmoothLevel:lerp(Lava.GetLevel())
	local LavaLevel = v:SetZ(SmoothLevel)

	render.Clip( ClipTab, function()
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(draw.fetch_asset(LavaTexture, "noclamp"))

		if not b then
			cam.Wrap3D2D(function()
				surface.DrawTexturedRectUV(-MapScale / 2, -MapScale / 2, MapScale, MapScale, 0, 0, 10, 10)
			end, LavaLevel, Angle(0, CurTime() / 3, 0), 1)
		end

		cam.Wrap3D2D(function()
			surface.DrawTexturedRectUV(-MapScale / 2, -MapScale / 2, MapScale, MapScale, 0, 0, 10 * SkyboxScale, 10 * SkyboxScale)
		end, GetGlobalVector("$skycampos") + (LavaLevel / SkyboxScale), Angle(0, CurTime() / 3, 0), 1)
	end)
end)


hook.Add("RenderScreenspaceEffects", "DrawLavaOverlay", function()
	if hook.Call("Lava.ShouldRenderDamageOverlay") == false then return end

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