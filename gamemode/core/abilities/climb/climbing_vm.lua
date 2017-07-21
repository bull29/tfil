if SERVER then return end


local function ViewmodelPopup(self, View, Weapon, Player)
	if not Player:Alive() or not Player:HasAbility("Chameleon") then
		return
	end

	if not IsValid( Player.m_InvisParent ) then
		Player.m_InvisParent = ClientsideModel("models/v_me_fists.mdl")
	end

	if not IsValid(Player.m_cEffect) then
		Player.m_cEffect = ClientsideModel("models/weapons/c_arms_citizen.mdl")
		Player.m_cEffect:SetParent(Player.m_InvisParent)
		Player.m_cEffect:AddEffects(EF_BONEMERGE)
		Player.m_cEffect.GetPlayerColor = function(self)

			local data = player_manager.TranslatePlayerHands(LocalPlayer():GetModel())

			if data then
				self:SetSkin(data.skin)
				self:SetModel(data.model)
				self:SetBodyGroups(data.body)
			end

			return LocalPlayer():GetPlayerColor()
		end
	end

	local c = Player.m_InvisParent
	c:SetPos(View:GetPos() - View:GetForward() * 10 - View:GetUp() * 10)
	c:SetAngles(View:GetAngles())
	c:SetSequence(c:LookupSequence("Shove"))
	c:SetParent(View)

	c.RenderOverride = function(self)
		--if GetViewEntity() ~= LocalPlayer() or EyePos() ~= LocalPlayer():EyePos() then return end
		local cQuer = Player:GetNW2String("$climbquery", "")
		if not IsValid( View ) then return end
		if cQuer ~= "" then
			c:SetCycle(0.2)
			Player.m_cEffect:SetNoDraw(false)
			View:SetNoDraw(true)
			cam.IgnoreZ(true)
			cQuer = cQuer:Split(" ")
			Player.LerpedSideClimbVar = Player.LerpedSideClimbVar or 0
			Player.LerpedSideClimbVar = Player.LerpedSideClimbVar:lerp(cQuer[2] * 90)
			c:SetRenderAngles(Angle(-20):SetRoll((Player.LerpedSideClimbVar or 0)):SetYaw(cQuer[3]))
			Player.m_cEffect:DrawModel()
			cam.IgnoreZ(false)
		else
			View:SetNoDraw(false)
			Player.m_cEffect:SetNoDraw(true)
		end
	end
end

if CLIENT then
	hook.Add("Tick", "CheckWeaponSwitch", function()
		if not IsValid( LocalPlayer() ) then return end
		local wep = LocalPlayer():GetActiveWeapon()
		if not wep.HaveSetHack and wep:IsValid() and wep:GetClass() == "lava_fists" then
			wep.HaveSetHack = true
			wep.PreDrawViewModel = function(a, b, c, d)
				ViewmodelPopup(a, b, c, d)
			end
		end
	end)
end