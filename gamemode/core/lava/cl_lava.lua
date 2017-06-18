local hook = hook
local cam = cam
local draw = draw
local render = render
local EyePos = EyePos
local math = math
local drawOverlay = DrawMaterialOverlay
local drawColor = DrawBloom

local v = Vector(-2193.622803, -2168.888184, -350)
local A = "http://i.imgur.com/3Cw0SeI.jpg"
local B = "http://mirror2.cze.cz/texturesLarge/lava-texture.jpg" or "http://pre13.deviantart.net/c566/th/pre/i/2014/059/8/0/sre_design_texture_test_lava_floor_test_1_by_wakaflockaflame1-d78e6wm.png"
local Col = Color(255, 255, 255, 255)
local len = 5

local OldVal = -1000
hook.Add("PostDrawTranslucentRenderables", "DrawLava", function(a, b)
	if b then return end
	OldVal = OldVal:lerp( Lava.GetLevel() )
	cam.Start3D2D(v:SetZ( OldVal ), Angle(0, CurTime()/2, 0), 4000)
	draw.SeamlessWebImage(B, len, len, 5, 5, Col, -2.5, -2.5)
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
		if not LocalPlayer():Alive() then

			drawColor(0, 3, 0, 0, 0, 20, 255, 128, 0)
			return
		end
		drawColor(0, (math.sin(CurTime() * 10) * 3):abs(), 0, 0, 0, 20, 255, 128, 0)
	end
end)

--render.DrawSphere( vec, -5, 50, 50, Color( 255, 0, 0 ) )
--[[

local person = "http://i.imgur.com/Ic3M9Sx.png"

local function DefineMask(ref)
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.SetStencilWriteMask(254)
	render.SetStencilTestMask(254)
	render.SetStencilReferenceValue(ref or 43)
end

local function ClipToMask()
	render.SetStencilCompareFunction(STENCIL_EQUAL)
end

local function StopMask()
	render.SetStencilEnable(false)
end

local function DrawPerson(size, x, y, objX)
	draw.WebImage(person, x, y, size * 0.554323725, size)
	DefineMask()
	surface.SetDrawColor(0, 0, 0, 1)
	surface.DrawRect(x, y + size - size * objX / 100, size * 0.554323725, size * 8)
	--	draw.RoundedBox(0, 0, 0, ScrH() / 3 * 0.554323725, ScrH() / 3, Col)
	ClipToMask()
	draw.WebImage(person, x, y, size * 0.554323725, ScrH() / 3, Color(255, 0, 0))
	--	draw.RoundedBox(0, 0, 0, ScrH() / 3 * 0.554323725, ScrH() / 3/2, Col - 500)
	StopMask()
end

 --[[ hook.Add("PostDrawHUD", "DrawFire", function()
	local x = (LocalPlayer():EyePos().z - select(-1, LocalPlayer():GetRenderBounds()).z:abs()) - Lava.GetLevel()
	DrawPerson(ScrH() / 3, 500, 50, -x * 1.2)
end)--]]
--]] 