local draw = draw
local surface = surface
local FrameTime = FrameTime
local PANEL = {}

function PANEL:Init()
	local x = self:GetChildren()[2]
	local GRIP = x:GetChildren()[3]

	x:SetWide( WebElements.Edge * 2 )
	x.Paint = function(s, w, h)
	--	draw.RoundedBox(0, 0, 0, w, h, pColor() - 150)
	end

	self.OverFlow = x:GetChildren()[2]:GetTall() * 0.7

	x:GetChildren()[1].Paint = nil
	x:GetChildren()[2].Paint = nil

	GRIP:GenerateColorShift("colorOf", ( pColor() + 50 ):Alpha(150), ( pColor() + 25 ):Alpha(255) + 25, 500)

	GRIP.Paint = function(s, w, h)
		s:Declip( function()
			draw.RoundedBox(0, 0, -(self.OverFlow/2) - 1, w, h + (self.OverFlow/2)*2 + 1, s.colorOf)
		end)
	end
end

function PANEL:SetAltDock()
	self.VBar:Dock(LEFT)
	self.pnlCanvas.PerformLayout = function( s )
	end
	self.pnlCanvas:Dock( FILL )
end

vgui.Register("lava_scroller", PANEL, "DScrollPanel")