if SERVER then
	hook.Add("StartCommand", "DisableRagdolling", function(Player, Data)
		local m_R = Player.m_Ragdoll

		if not IsValid(m_R) then
			Player.m_Ragdoll = nil

			return
		end

		if m_R and Data:KeyDown(IN_RELOAD) then
			if Player.m_NextRagdollifcationTime and Player.m_NextRagdollifcationTime > CurTime() then return end
			Ragdoll.Disable(Player)
		elseif m_R and Player:HasAbility("Limpy Larry") then
			local x = m_R:TranslateBoneToPhysBone(m_R:LookupBone("ValveBiped.Bip01_Spine"))
			if not x then return end
			local bEnt = m_R:GetPhysicsObjectNum(x)

			if Data:GetForwardMove() ~= 0 then
				bEnt:ApplyForceCenter(Data:GetForwardMove():absolutize() * Player:GetForward() * (Data:KeyDown(IN_SPEED) and 1250 or 1000))
			end

			if Data:GetSideMove() ~= 0 then
				bEnt:ApplyForceCenter(Data:GetSideMove():absolutize() * Player:GetRight() * (Data:KeyDown(IN_SPEED) and 1250 or 1000))
			end
		end
	end)
end

Abilities.Register("Limpy Larry", [[By pressing 'R',
	you have the ability to toggle becoming
	a limp, lifeless ragdoll that
	can squirm and move. You don't take fall
	damage whilst Ragdolled. 
	Use your limpness to squeeze into otherwise
	unreachable spots.
	]], CLIENT and Emoji.Get(385))