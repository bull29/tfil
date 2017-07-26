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
local LavaTexture = WebElements.Lava
local SmoothLevel = -1000
local MapScale = 1
local SkyboxScale = 1
local ClipTab = {}

local dirs = {
	right = Vector(1, 0, 0),
	frwd = Vector(0, 1, 0)
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
	MapScale = GetMapBounds() * 2
	local min, max = Entity(0):GetModelRenderBounds()

	ClipTab = {
		[1] = {dirs.right, -min.x:abs()},
		[2] = {-dirs.right, -max.x:abs()},
		[3] = {dirs.frwd, -min.y:abs()},
		[4] = {-dirs.frwd, -max.y:abs()}
	}
end)

hook.Add("PostDrawTranslucentRenderables", "DrawLava", function(a, b)
	SmoothLevel = SmoothLevel:lerp(Lava.GetLevel())
	local LavaLevel = v:SetZ(SmoothLevel)
	local Ang = Angle(0, CurTime(), 0)

	render.Clip(ClipTab, function()
		local x = 220 + (CurTime():sin() * 35):abs()
		surface.SetDrawColor(x, x, x)
		surface.SetMaterial(draw.fetch_asset(LavaTexture, "noclamp"))

		if not b then
			cam.Wrap3D2D(function()
				surface.DrawTexturedRectUV(-MapScale / 2, -MapScale / 2, MapScale, MapScale, 0, 0, MapScale / 5000, MapScale / 5000)
			end, LavaLevel, Ang, 1)

			if EyePos().z < SmoothLevel then
				cam.Wrap3D2D(function()
					surface.DrawTexturedRectUV(-MapScale / 2, -MapScale / 2, MapScale, MapScale, 0, 0, MapScale / 5000, MapScale / 5000)
				end, LavaLevel, Ang + Angle( 180, 0, 0 ), 1)
			end
		end
	end)

	if b then
		cam.Wrap3D2D(function()
			surface.DrawTexturedRectUV(-MapScale / 2, -MapScale / 2, MapScale, MapScale, 0, 0, MapScale / 5000 * SkyboxScale, MapScale / 5000 * SkyboxScale)
		end, GetGlobalVector("$skycampos") + (LavaLevel / SkyboxScale), Ang, 1)
	end
end)

hook.Add("RenderScreenspaceEffects", "DrawLavaOverlay", function()
	if hook.Call("Lava.ShouldRenderDamageOverlay", nil, LocalPlayer()) == false then return end

	if EyePos().z < Lava.GetLevel() then
		if not LocalPlayer():Alive() then
			drawColor(0, 3, 0, 0, 0, 20, 255, 128, 0)

			return
		end

		drawColor(0, 3, 0, 0, 0, 20, 255, 128, 0)
		drawOverlay("effects/water_warp01", 1)
	elseif LocalPlayer():GetPos().z <= Lava.GetLevel() and LocalPlayer():Alive() and Rounds.IsState( "Started" ) then
		drawColor(0, (math.sin(CurTime() * 10) * 3):abs(), 0, 0, 0, 20, 255, 128, 0)
	end
end)

hook.Add("HUDShouldDraw", "DisableDeathscreen", function(name)
	if name == "CHudDamageIndicator" then return false end
end)