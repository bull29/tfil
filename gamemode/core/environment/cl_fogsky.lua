local render = render
local MATERIAL_FOG_LINEAR = MATERIAL_FOG_LINEAR
local Config = GM.GetConfig()

hook.Add("SetupWorldFog", "Fog", function()
	if not Config.GetMapEffects() then return end
	render.FogStart(5)
	render.FogColor(255, 128, 0)
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogMaxDensity(0.9)
	render.FogEnd(1000)

	return true
end)

hook.Add("PostDrawSkyBox", "FogSkyUnity", function()
	if not Config.GetMapEffects() then return end
	render.Clear(255, 128 - 75, 0, 0, false, true)
end)