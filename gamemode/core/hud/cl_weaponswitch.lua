--[[
MIT License

Copyright (c) 2017 Collin (code_gs)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

-- Original Skeleton by code_gs. Altered as seen fit by Bull29.

local MAX_SLOTS = 6
local CACHE_TIME = 1
local MOVE_SOUND = "Player.WeaponSelectionMoveSlot"
local SELECT_SOUND = "Player.WeaponSelected"
local iCurSlot = 0
local iCurPos = 1
local flNextPrecache = 0
local iWeaponCount = 0
local tCache = {}
local tCacheLength = {}
local PrecacheWeps
local m_WeaponDrawPanel
local m_WeaponIconIndex = {}
local m_LastWeaponCount = 0
local cl_drawhud = GetConVar("cl_drawhud")
local draw = draw
local WebElements = WebElements
local color_white = color_white
local CurTime = CurTime
local m_NextHideTime = CurTime()

for i = 1, MAX_SLOTS do
	tCache[i] = {}
	tCacheLength[i] = 0
end

PrecacheWeps = function()
	for i = 1, MAX_SLOTS do
		for j = 1, tCacheLength[i] do
			tCache[i][j] = nil
		end

		tCacheLength[i] = 0
	end

	flNextPrecache = RealTime() + CACHE_TIME
	iWeaponCount = 0

	for _, pWeapon in pairs(LocalPlayer():GetWeapons()) do
		iWeaponCount = iWeaponCount + 1
		local iSlot = pWeapon:GetSlot() + 1

		if (iSlot <= MAX_SLOTS) then
			local iLen = tCacheLength[iSlot] + 1
			tCacheLength[iSlot] = iLen
			tCache[iSlot][iLen] = pWeapon
		end
	end

	if (iCurSlot ~= 0) then
		local iLen = tCacheLength[iCurSlot]

		if (iLen < iCurPos) then
			if (iLen == 0) then
				iCurSlot = 0
			else
				iCurPos = iLen
			end
		end
	end
end

hook.Add("HUDPaint", "GS-Weapon Selector", function()
	if (iCurSlot == 0 or not cl_drawhud:GetBool()) then return end
	local pPlayer = LocalPlayer()

	if (not (pPlayer:IsValid() and pPlayer:Alive()) or pPlayer:InVehicle() and not pPlayer:GetAllowWeaponsInVehicle()) then
		iCurSlot = 0

		return
	end

	if (flNextPrecache <= RealTime()) then
		PrecacheWeps()
	end

	if m_WeaponDrawPanel and m_NextHideTime > CurTime() then
		m_WeaponDrawPanel:Show()
		m_WeaponDrawPanel.m_cIndex = iCurSlot .. "." .. iCurPos
		m_WeaponDrawPanel:PaintManual()

		if m_WeaponDrawPanel.ShouldUpdate then
			m_WeaponDrawPanel:Repopulate(tCache)
			m_WeaponDrawPanel.ShouldUpdate = false
		end
	end
end)

hook.Add("PlayerBindPress", "GS-Weapon Selector", function(pPlayer, sBind, bPressed)
	if (sBind == "cancelselect") then
		iCurSlot = 0

		return true
	end

	if (sBind == "invnext") then
		m_NextHideTime = CurTime() + 1.3

		if (not (pPlayer:IsValid() and pPlayer:Alive()) or pPlayer:InVehicle() and not pPlayer:GetAllowWeaponsInVehicle()) then
			iCurSlot = 0

			return true
		end

		if (not bPressed) then return true end
		PrecacheWeps()
		if (iWeaponCount == 0) then return true end
		local bLoop = false

		if (iCurSlot == 0) then
			local pActiveWeapon = pPlayer:GetActiveWeapon()

			if (pActiveWeapon:IsValid()) then
				local iSlot = pActiveWeapon:GetSlot() + 1
				local iLen = tCacheLength[iSlot]
				local tSlotCache = tCache[iSlot]

				if (tSlotCache[iLen] == pActiveWeapon) then
					iCurSlot = iSlot
					bLoop = true
				else
					iCurSlot = iSlot
					iCurPos = 1

					for i = 1, iLen - 1 do
						if (tSlotCache[i] == pActiveWeapon) then
							iCurPos = i + 1
							break
						end
					end

					flSelectTime = RealTime()
					pPlayer:EmitSound(MOVE_SOUND)

					return true
				end
			else
				bLoop = true
			end
		end

		if (bLoop or iCurPos == tCacheLength[iCurSlot]) then
			repeat
				if (iCurSlot == MAX_SLOTS) then
					iCurSlot = 1
				else
					iCurSlot = iCurSlot + 1
				end
			until (tCacheLength[iCurSlot] ~= 0)

			iCurPos = 1
		else
			iCurPos = iCurPos + 1
		end

		flSelectTime = RealTime()
		pPlayer:EmitSound(MOVE_SOUND)

		return true
	end

	if (sBind == "invprev") then
		m_NextHideTime = CurTime() + 1.3

		if (not (pPlayer:IsValid() and pPlayer:Alive()) or pPlayer:InVehicle() and not pPlayer:GetAllowWeaponsInVehicle()) then
			iCurSlot = 0

			return true
		end

		if (not bPressed) then return true end
		PrecacheWeps()
		if (iWeaponCount == 0) then return true end
		local bLoop = false

		if (iCurSlot == 0) then
			local pActiveWeapon = pPlayer:GetActiveWeapon()

			if (pActiveWeapon:IsValid()) then
				local iSlot = pActiveWeapon:GetSlot() + 1
				local tSlotCache = tCache[iSlot]

				if (tSlotCache[1] == pActiveWeapon) then
					iCurSlot = iSlot
					bLoop = true
				else
					iCurSlot = iSlot
					iCurPos = 1

					for i = 2, tCacheLength[iSlot] do
						if (tSlotCache[i] == pActiveWeapon) then
							iCurPos = i - 1
							break
						end
					end

					flSelectTime = RealTime()
					pPlayer:EmitSound(MOVE_SOUND)

					return true
				end
			else
				bLoop = true
			end
		end

		if (bLoop or iCurPos == 1) then
			repeat
				if (iCurSlot <= 1) then
					iCurSlot = MAX_SLOTS
				else
					iCurSlot = iCurSlot - 1
				end
			until (tCacheLength[iCurSlot] ~= 0)

			iCurPos = tCacheLength[iCurSlot]
		else
			iCurPos = iCurPos - 1
		end

		flSelectTime = RealTime()
		pPlayer:EmitSound(MOVE_SOUND)

		return true
	end

	if (sBind:sub(1, 4) == "slot") then
		if (not (pPlayer:IsValid() and pPlayer:Alive()) or pPlayer:InVehicle() and not pPlayer:GetAllowWeaponsInVehicle()) then
			iCurSlot = 0

			return true
		end

		if (not bPressed) then return true end
		PrecacheWeps()

		if (iWeaponCount == 0) then
			pPlayer:EmitSound(MOVE_SOUND)

			return true
		end

		local iSlot = tonumber(sBind:sub(5, 6))
		m_NextHideTime = CurTime() + 1.3

		if (iSlot) then
			if (iSlot <= MAX_SLOTS) then
				if (iSlot == iCurSlot) then
					if (iCurPos == tCacheLength[iCurSlot]) then
						iCurPos = 1
					else
						iCurPos = iCurPos + 1
					end
				elseif (tCacheLength[iSlot] ~= 0) then
					iCurSlot = iSlot
					iCurPos = 1
				end

				flSelectTime = RealTime()
				pPlayer:EmitSound(MOVE_SOUND)
			end

			return true
		end
	end

	if (iCurSlot ~= 0) then
		if (not (pPlayer:IsValid() and pPlayer:Alive()) or pPlayer:InVehicle() and not pPlayer:GetAllowWeaponsInVehicle()) then
			iCurSlot = 0

			return
		end

		if (sBind == "+attack") then
			if (not bPressed) then return true end
			local pWeapon = tCache[iCurSlot][iCurPos]
			iCurSlot = 0

			if (pWeapon:IsValid() and pWeapon ~= pPlayer:GetActiveWeapon()) then
				hook.Add("CreateMove", "GS-Weapon Selector", function(cmd)
					if (pWeapon:IsValid() and pPlayer:IsValid() and pWeapon ~= pPlayer:GetActiveWeapon()) then
						cmd:SelectWeapon(pWeapon)
					else
						hook.Remove("CreateMove", "GS-Weapon Selector")
					end
				end)
			end

			flSelectTime = RealTime()
			pPlayer:EmitSound(SELECT_SOUND)
			m_WeaponDrawPanel:Hide()
			return true
		end

		if (sBind == "+attack2") then
			flSelectTime = RealTime()
			iCurSlot = 0

			return true
		end
	end
end)

hook.RunOnce("HUDPaint", function()
	df = InitializePanel("LavaWeaponSwitchPane", "DIconLayout")
	m_WeaponDrawPanel = df
	df:SetSpaceX( WebElements.Edge )
	df.ShouldUpdate = true
	df:SetSize(ScrW() / 2, ScrH() / 11)
	df:Center()
	df:SetVerticalPos( 0 )
	df.m_tSize = 0

	df.Repopulate = function(self, tab)

		self.m_tSize = 0

		hook.Call("Lava.RegisterWeaponIcons", nil, m_WeaponIconIndex)

		for slot, v in pairs(tab) do
			for subindex, weapon in pairs(v) do
				local Circle = self:Add("DCirclePanel")
				Circle:SetSize(ScrH() / 11, ScrH() / 11)
				self.m_tSize = self.m_tSize + ScrH()/11 + WebElements.Edge
				local type

				if m_WeaponIconIndex[weapon.ClassName] then
					type = isnumber(m_WeaponIconIndex[weapon.ClassName]) and "Emoji" or "String"
				end

				Circle.m_Index = slot .. "." .. subindex
				Circle.m_wIndex = weapon

				Circle.PaintCircle = function(s, w, h)
					local isHovered = s.isHovered
					s.isHovered = s.m_Index == df.m_cIndex

					if not IsValid( weapon ) then
						s:Remove()
						return
					end
					draw.WebImage( WebElements.Circle, 0, 0, w, h, pColor() - 50 )

					if type then
						draw.WebImage(type == "Emoji" and Emoji.Get(m_WeaponIconIndex[weapon.ClassName]) or m_WeaponIconIndex[weapon.ClassName], w / 2, h / 2, type == "Emoji" and w * 0.6 or w * 0.8, type == "Emoji" and h * 0.6 or h * 0.8, (isHovered and color_white or Color(150, 150, 150)), isHovered and -CurTime():sin() * 16 or 0)
					else
						draw.Rect( w/2, h/2, w, h, isHovered and color_white or color_white -100, "entities/" .. ( weapon:GetClass() or "" ):lower() .. ".png", isHovered and -CurTime():sin() * 16 or 0, false )
					end

					if not isHovered then
						draw.WebImage(WebElements.CircleOutline, 0, 0, w, h, pColor() - 100)
						draw.WebImage(WebElements.CircleOutline, w / 2, h / 2, w * 0.9, h * 0.9, pColor() - 50, 0)
					else
						draw.WebImage(WebElements.QuadCircle, w / 2, h / 2, w, h, pColor() - 100, CurTime():sin() * 180)
						draw.WebImage(WebElements.CircleOutline, w / 2, h / 2, w * 0.9, h * 0.9, pColor(), 0)
					end
				end

				Circle.PaintOver = function( s, w, h )
					if s.isHovered then
						s:Declip( function()
							draw.SimpleText( weapon:GetPrintName(), "lava_weapon_switch_name", w/2, h + h/5, nil, 1, 1 )
						end)
					end
				end
			end
		end
		self:SetWide( self.m_tSize )
		self:Center()
		self:SetVerticalPos( ScrH()/50 )
	end
	df:Hide()
end)

hook.Add("Lava.RegisterWeaponIcons", "RegisterFists", function(tab)
	tab["lava_fists"] = 2588 or 2191
end)

hook.Add("Think", "CheckWeaponShift",function()
	if m_WeaponDrawPanel then
		if m_LastWeaponCount ~= #LocalPlayer():GetWeapons() or not LocalPlayer():Alive() then
			m_WeaponDrawPanel:RemoveChildren()
			m_WeaponDrawPanel.ShouldUpdate = true
			m_LastWeaponCount = #LocalPlayer():GetWeapons()
		end
		if m_NextHideTime < CurTime() then
			m_WeaponDrawPanel:Hide()
		end
	end
end)