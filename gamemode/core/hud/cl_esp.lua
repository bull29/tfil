local m_ESPMeter = 100
local wMat = Material("models/debug/debugwhite")
local cam = cam
local draw = draw
local render = render
local DrawColorModify = DrawColorModify
local PlayerPosTab = {}
local White = color_white
local m_IconAlpha = 0
local pairs = pairs
local m_Activate
local m_HaveUsedupMeter
local m_NextUsetime = CurTime()
local m_IsMutatorActive

local tab = {
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0
}

hook.Add("RenderScreenspaceEffects", "DrawESP", function()
	m_IsMutatorActive = Mutators.IsActive("EmojiEyes")
	m_Activate = m_IsMutatorActive or ( m_Activate and not m_HaveUsedupMeter and not hook.Call("Lava.ShouldBlockESP", nil, LocalPlayer() ) )

	if not m_Activate then
		tab["$pp_colour_colour"] = tab["$pp_colour_colour"]:lerp( 1 )
		tab["$pp_colour_brightness"] = tab["$pp_colour_brightness"]:lerp( 0 )
		m_IconAlpha = m_IconAlpha:lerp( 0 )
	else
		tab["$pp_colour_colour"] = tab["$pp_colour_colour"]:lerp( -1 )
		tab["$pp_colour_brightness"] = tab["$pp_colour_brightness"]:lerp( -0.25 )
		m_IconAlpha = m_IconAlpha:lerp( 255 )
	end

	DrawColorModify(tab)

	if not m_Activate then return end

	m_ESPMeter = hook.Call("Lava.ESPOverride", nil, LocalPlayer()) or m_ESPMeter:Approach( 0, FrameTime() * 20 )
	if m_ESPMeter < 1 then
		m_HaveUsedupMeter = true
	end
	cam.Wrap3D(function()
		cam.IgnoreZ(true)
		render.SuppressEngineLighting(true)

		for k, v in pairs(player.GetAll()) do
			if v == LocalPlayer() or not v:Alive() then continue end

			local Col = v:PlayerColor()

			v = IsValid( v.m_Ragdoll ) and v.m_Ragdoll or v

			render.MaterialOverride(wMat)
			render.SetColorModulation(Col.r / 255, Col.g / 255, Col.b / 255)
			v:DrawModel()
			if v:LookupBone("ValveBiped.Bip01_Head1") then
				PlayerPosTab[ IsValid( v.m_Player ) and v.m_Player or v ] = v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Head1")):ToScreen()
			end
		end

		cam.IgnoreZ(false)
		render.SuppressEngineLighting(false)
	end)
end)

hook.Add("PostRenderVGUI", "RenderEmojis", function()
	if m_Activate then
		for Player, Vec in pairs(PlayerPosTab) do
			if Vec.visible and IsValid(Player) and Player:Alive() then
				draw.WebImage(Emoji.Get(Player:EmojiID()), Vec.x, Vec.y, ScrH() / 25, ScrH() / 25, White:Alpha( m_IconAlpha ), ( CurTime() * ( #Player:Nick()/3 ):max( 1 ) ):sin() * 30 * ( #Player:Nick()%2 == 0 and -1 or 1) )
			elseif not IsValid( Player ) then
				PlayerPosTab[ Player ] = nil
			end
		end
	end

	if not LocalPlayer():Alive() then
		m_ESPMeter = 100
		return
	end

	if m_ESPMeter < 100 and not m_IsMutatorActive then
		draw.WebImage(Emoji.Get( 734 ), ScrW()/2, ScrH() - ScrH()/10, ScrH()/7, ScrH()/7, pColor():Alpha( 100 ), 0 )
		draw.WebImage(Emoji.Get( 734 ), ScrW()/2, ScrH() - ScrH()/10, m_ESPMeter/100*ScrH()/7, m_ESPMeter/100*ScrH()/7, White:Alpha( m_HaveUsedupMeter and 100 or 255 ), 0 )
		if not m_Activate then
			m_ESPMeter = m_ESPMeter:Approach( 100, FrameTime() * 10 )
		end
	elseif m_ESPMeter == 100 and m_HaveUsedupMeter then
		m_HaveUsedupMeter = nil
	end
end)

hook.Add("HUDShouldDraw", "DisableElements", function(name)
	if (m_Activate and not m_IsMutatorActive ) and name == "CHudGMod" then return false end
end)


hook.Add("OnSpawnMenuOpen", "ToggleESP", function()
	if m_NextUsetime > CurTime() then return end
	m_Activate = true
	m_NextUsetime = CurTime() + 1
end)

hook.Add("OnSpawnMenuClose", "ToggleESP", function()
	m_Activate = false
end)
