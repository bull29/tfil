local render = render
local MATERIAL_FOG_LINEAR = MATERIAL_FOG_LINEAR
local Config = GM.GetConfig()
local dc = DrawColorModify
local bTab = { [ "$pp_colour_addr" ] = 0.02, [ "$pp_colour_addg" ] = 0.02, [ "$pp_colour_addb" ] = 0, [ "$pp_colour_brightness" ] = 0, [ "$pp_colour_contrast" ] = 1, [ "$pp_colour_colour" ] = 3, [ "$pp_colour_mulr" ] = 0, [ "$pp_colour_mulg" ] = 0.02, [ "$pp_colour_mulb" ] = 0 }
local fDensity = 0
local RenderFog = function(f)
	if not Config.GetMapEffects() then fDensity = fDensity:lerp( 0 ) return end
	fDensity = fDensity:lerp( 0.9, FrameTime()/3 )
	render.FogStart(5)
	render.FogColor(255, 128, 0)
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogMaxDensity(fDensity)
	render.FogEnd( (3000 - (1500*fDensity) )* ( f or 1 ) )
	return true
end
hook.Add("SetupWorldFog", "WorldFog", RenderFog)
hook.Add("SetupSkyboxFog", "SkyboxFog", RenderFog)
hook.Add("PostDraw2DSkyBox", "FogSkyUnity", function()
	if not Config.GetMapEffects() then return end
	render.Clear(283 * fDensity, 59 * fDensity, 0, 0, false, true)
end)
hook.Add("RenderScreenspaceEffects","LavaColorModify",function()
	if not Config.GetMapEffects() then return end
	dc( bTab )
end)
hook.Add("Lava.PostRound", "ResetFoglerp", function()
	fDensity = fDensity:lerp( 0 )
end)