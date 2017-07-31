
local m_ZDelta
local m_InitialFOV
local m_Case
local m_In
local m_Out
local White = Color( 255, 255, 255 )
local WebElements = WebElements
local draw = draw
local mWHM = WebElements.Edge * 5
local ScrH = ScrH
local ScrW = ScrW
local input = input
local FontFunctions = FontFunctions
local hook = hook

hook.Add("CalcView", "RenderBetterzoom", function( Player, Origin, Angles, FOV )
	if hook.Call( "Lava.CanZoom", nil, Player ) == false then return end

	m_Case = LocalPlayer():KeyDown( IN_ZOOM ) and LocalPlayer():Alive()
	m_In = LocalPlayer():KeyDown( IN_USE )
	m_Out = input.IsKeyDown( KEY_Q )

	if not m_ZDelta then
		m_ZDelta = FOV
		m_InitialFOV = FOV
	end

	if m_Case and m_In and not m_Out then
		m_ZDelta = m_ZDelta:lerp( m_ZDelta - FrameTime() * 1096 ):max( 1 )
	end

	if m_ZDelta ~= m_InitialFOV or m_Case then
		if not m_Case then
			m_ZDelta = m_ZDelta:Approach( m_InitialFOV, FrameTime() * 256 )
		end

		if m_Out then
			m_ZDelta = m_ZDelta:lerp( m_ZDelta + FrameTime() * 1096 ):min( m_InitialFOV - 15 )
		end

		return { fov = m_ZDelta:min( m_Case and ( m_InitialFOV - 15 ) or m_ZDelta ) }
	end
end)

function GM:AdjustMouseSensitivity( number )
	if m_ZDelta ~= m_InitialFOV then
		return m_ZDelta / m_InitialFOV
	end
	return -1
end

hook.Add("HUDPaint", "RenderZoom", function()
	if not m_Case then return end

	local Text = ( m_InitialFOV / m_ZDelta ):Round( 2 ):max( 1.2 ) .. "x"
	local t_Wide = FontFunctions.GetWide( Text, "ChatFont" )

	draw.WebImage( Emoji.Get( 96 ), ScrW() / 2 + mWHM * 2, ScrH() - mWHM * 2.1, mWHM, mWHM, m_In and White or White - 100, 0 )
	draw.WebImage( Emoji.Get( 227 ), ScrW() / 2 + mWHM * 2, ScrH() - mWHM, mWHM, mWHM, m_Out and White or White - 100, 0 )


	draw.WebImage( Emoji.Get( 317 ), ScrW() / 2 - mWHM * 3, ScrH() - mWHM * 2.5, mWHM * 1.7, mWHM * 1.7 )
	draw.WebImage( Emoji.Get( 1433 ), ScrW() / 2 - mWHM * 3, ScrH() - mWHM * 2.5, mWHM * 1.7, mWHM * 1.7, nil, ( m_ZDelta / 100 ):sin() * 3600, 0  )
	draw.SimpleText( Text, "ChatFont", ScrW() / 2 - t_Wide / 2, ScrH() - mWHM * 2, pColor(), TEXT_ALIGN_CENTRE )
end)

hook.Add("Lava.ShouldBlockESP", "PreventESPZoom", function( Player )
	if m_Case then
		return true
	end
end)