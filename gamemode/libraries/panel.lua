if SERVER then return end
function InitializePanel(id, type, parent)
	type = type or "DFrame"

	if _G[id] then
		_G[id]:Remove()
		_G[id] = nil
	end

	_G[id] = vgui.Create(type, parent)

	return _G[id]
end


local blur = Material("pp/blurscreen")
local pmeta = debug.getregistry().Panel
local ScrW = ScrW
local ScrH = ScrH
local math = math
local void = function() end
local FrameTime = FrameTime
local select = select
local render = render
local surface = surface
local input = input
local MOUSE_RIGHT = MOUSE_RIGHT
local Lerp = Lerp
local system = system
local FrameTime = FrameTime
local scrW, scrH = ScrW(), ScrH()

function pmeta:GenerateOverwrite( var )
	local num = 0
	local VarToUse = var .. "Old" .. num
	while self[ VarToUse ] do
		num = num + 1
		VarToUse = var .. "Old" .. num
	end
	self[ VarToUse ] = self[ VarToUse ] or self[ var ] or void

	return self[ VarToUse ]
end

function pmeta:Declip( func )
	surface.DisableClipping( true )
	func()
	surface.DisableClipping( false )
end

function pmeta:Blur( amount )
	amount = amount or 3
	local x, y = self:LocalToScreen( 0, 0 )
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( blur )	
	for i = 1, amount do
		blur:SetFloat("$blur", (i/6) * 6 ) 
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

function pmeta:GetCenterX()
	return math.ceil(ScrW() / 2 - self:GetWide() / 2)
end

function pmeta:GetCenterY()
	return math.ceil(ScrH() / 2 - self:GetTall() / 2)
end

function pmeta:GetHorizontalPos()
	return self:GetPos(), void()
end

function pmeta:GetVerticalPos()
	return select(-1, self:GetPos())
end

function pmeta:SetHorizontalPos(n)
	return self:SetPos(n, self:GetVerticalPos())
end

function pmeta:SetVerticalPos(n)
	return self:SetPos(self:GetHorizontalPos(), n)
end

function pmeta:GetNextHorizontalPos(offset)
	return self:GetWide() + self:GetHorizontalPos() + offset
end

function pmeta:GetNextVerticalPos(offset)
	return self:GetTall() + self:GetVerticalPos() + offset
end

function pmeta:MakeBorder(edge, color )
	edge = edge or ( ScrH() * 0.001 ):ceil()

	local x = self:GenerateOverwrite("PaintOver")
	self.PaintOver = function(s, w, h)
		x( s, w, h )
		draw.NoTexture()
		surface.SetDrawColor( color )
		for i = 1, edge do
			surface.DrawOutlinedRect( i - 1, i - 1, w - i * 2, h - i * 2)
		end
	end

	return color
end

function pmeta:GenerateColorShift(var, colorbefore, colorafter, interval)

	local x = self:GenerateOverwrite("PaintOver")
	self[var] = colorbefore

	self.PaintOver = function(s, w, h)
		x(s, w, h)

		if s.Hovered then
			self[var] = self[var]:Approach(colorafter, FrameTime() * interval)
			s:SetCursor("hand")
		else
			self[var] = self[var]:Approach(colorbefore, FrameTime() * interval)
		end
	end
end

function pmeta:RecurseChildren(func)
	func(self)

	for k, v in pairs(self:GetChildren()) do
		v:RecurseChildren(func)
	end
end

function pmeta:RemoveChildren()
	for _, v in ipairs(self:GetChildren()) do
		v:Remove()
	end
end

function pmeta:SetupRightClick()
	self.ThinkOldRightClick = self.ThinkOldRightClick or self.Think or void
	self.LastInputPressed = nil

	function self:Think()
		if self.Hovered and input.IsMouseDown(MOUSE_RIGHT) and self.LastInputPressed ~= input.IsMouseDown(MOUSE_RIGHT) then
			self.DoRightClick(self)
			self.LastInputPressed = input.IsMouseDown(MOUSE_RIGHT)
		elseif not input.IsMouseDown(MOUSE_RIGHT) then
			self.LastInputPressed = nil
		end

		return self:ThinkOldRightClick()
	end
end

function pmeta:EnsureCenterBounds(desiredW, desiredH, amount )
	amount = amount or 3
	self.DesiredWidth = desiredW
	self.DesiredHeight = desiredH
	local Old = self:GenerateOverwrite("PaintOver")--self.PaintOldRebound = self.PaintOldRebound or self.Paint

	if self.SetSizable then
		self:SetSizable(true)
	end

	function self:PaintOver(w, h)
		Old( self, w, h )
		if w ~= self.DesiredWidth or h ~= self.DesiredHeight then
			self:SetWide(math.Round(Lerp(FrameTime() * amount, w, self.DesiredWidth)))
			self:SetTall(math.Round(Lerp(FrameTime() * amount, h, self.DesiredHeight)))
		end

		if self:GetHorizontalPos() ~= self:GetCenterX() or self:GetVerticalPos() ~= self:GetCenterY() then
			self:SetPos(Lerp(FrameTime() * amount*2, self:GetHorizontalPos(), self:GetCenterX()), Lerp(FrameTime() * amount*2, self:GetVerticalPos(), self:GetCenterY()))
		end
	end
end
