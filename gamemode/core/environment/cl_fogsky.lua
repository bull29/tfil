local render = render
local MATERIAL_FOG_LINEAR = MATERIAL_FOG_LINEAR
local Config = GM.GetConfig()

local RenderFog = function(f)
	render.FogStart(5)
	render.FogColor(255, 128, 0)
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogMaxDensity(0.9)
	render.FogEnd(1500 * ( f or 1 ) )
	return true
end

hook.Add("SetupWorldFog", "WorldFog", RenderFog)
hook.Add("SetupSkyboxFog", "SkyboxFog", RenderFog)
hook.Add("PostDraw2DSkyBox", "FogSkyUnity", function()
	if not Config.GetMapEffects() then return end
	render.Clear(255, 128 - 75, 0, 0, false, true)
end)