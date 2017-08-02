local Context = {}
local draw = draw
local _cEU = false
local WebElements = WebElements
local vgui = vgui
local CurTime = CurTime
local m_HaveClicked
local White = color_white
local m_HaveFullyInitializedWorldPanel

Context.Widgets = {}

Context.NewWidget = function(name, iconid, func)
	Context.Widgets[name] = {iconid, func}
end

hook.Add("DrawOverlay", "DrawContextCusror", function()
	if m_HaveFullyInitializedWorldPanel and vgui.CursorVisible() then
		local x, y = gui.MousePos()
		draw.WebImage(Emoji.Get(input.IsMouseDown(107) and 1563 or 1560), x - 16, y, 32, 32)

		if vgui.GetHoveredPanel() and system.IsWindows() then
			vgui.GetHoveredPanel():SetCursor"blank"
		end

		if input.IsMouseDown(107) and not m_HaveClicked then
			m_HaveClicked = true
			chat.PlaySound()
		elseif not input.IsMouseDown( 107 ) then
			m_HaveClicked = nil
		end
	end
end)

hook.RunOnce("HUDPaint", function()
	local i = InitializePanel("LavaContextCore", "DIconLayout")
	i:Dock(LEFT)
	i:SetSpaceY(ScrH() / 100)
	i:SetWide(ScrW()/15)
	i:SetPaintedManually(true)
	i:DockMargin(ScrH() / 100, ScrH() / 100, ScrH() / 100, 0)
	hook.Call("Lava.PopulateWidgetMenu", nil, Context )

	i:Add("DIconLayout"):SetSize(72, 36)


	for Name, Properties in SortedPairs(Context.Widgets) do
		local t = i:Add("DButton")
		t:SetText("")
		t:SetSize(ScrW()/15, ScrW()/15)
		local tab = t:GenerateColorShift("m_ColorVar", pColor():Alpha( 100 ), pColor(), 255 * 3 )
		t.Paint = function(s, w, h)
			tab[ 1 ] = pColor():Alpha( 100 )
			tab[ 2 ] = pColor()
			if s.Hovered then
				draw.SimpleTextOutlined(Name, "lava_context_text_title", w + w / 5, h/2 - h/4, White, 0, 0, h/25, pColor())
			end

			draw.WebImage(s.Hovered and WebElements.QuadCircle or WebElements.CircleOutline, 0, 0, w, h, s.m_ColorVar, CurTime():sin() * 360, true)
			draw.WebImage(Emoji.Get(Properties[1]), h/5, h/5, w - w/5 * 2, w - w/5 * 2, White:Alpha( s.m_ColorVar.a * 1.5 ), s.Hovered and -CurTime():sin() * 15, true)
		end
		t.DoClick = function()
			if hook.Call( "Lava.CanUseWidget", nil, Name ) == false then return end
			local Panel = Properties[2]()
			if not Panel then return end

			Panel:EnsureCenterBounds( ScrW()/3, ScrH()*0.8 )
			local c = Panel:GenerateOverwrite( "Think" )
			function Panel:Think()
				c( self )
				if not _cEU then
					self:Remove()
				end
			end
		end
	end
end)

function GM:OnContextMenuOpen()
	_cEU = true
	gui.EnableScreenClicker(true)
	if system.IsWindows() then
		vgui.GetWorldPanel():SetCursor"blank"
	end
end

function GM:OnContextMenuClose()
	_cEU = false
	gui.EnableScreenClicker(false)
	vgui.GetWorldPanel():SetCursor"hand"
end

hook.Add("PostDrawHUD", "DrawContext", function()
	if _cEU and LavaContextCore then
		LavaContextCore:PaintManual()
	end
end)

hook.RunOnce("RenderScene", function()
	m_HaveFullyInitializedWorldPanel = true
end)
_G.LavaContextWidget = Context
