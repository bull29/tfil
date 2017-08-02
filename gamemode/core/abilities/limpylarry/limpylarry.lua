if SERVER then
	hook.Add("StartCommand", "DisableRagdolling", function(Player, Data)
		local m_R = Player.m_Ragdoll

		if not IsValid(m_R) then
			Player.m_Ragdoll = nil
			return
		end

		if not m_R.Feet then
			m_R.Feet = { L = m_R:GetPhysicsBone("ValveBiped.Bip01_L_Foot"), R = m_R:GetPhysicsBone("ValveBiped.Bip01_R_Foot") }
			m_R.Hands = { L = m_R:GetPhysicsBone("ValveBiped.Bip01_L_Hand"), R = m_R:GetPhysicsBone("ValveBiped.Bip01_R_Hand") }
		end

		if m_R and Data:KeyDown(IN_RELOAD) then
			if Player.m_NextRagdollifcationTime and Player.m_NextRagdollifcationTime > CurTime() then return end
			Ragdoll.Disable(Player)
		elseif m_R and Player:HasAbility("Limpy Larry") then
			local bEnt = m_R:GetPhysicsBone("ValveBiped.Bip01_Spine")
			if not IsValid( bEnt ) then return end

			if Data:GetForwardMove() ~= 0 then
				bEnt:ApplyForceCenter(Data:GetForwardMove():absolutize() * Player:GetForward() * (Data:KeyDown(IN_SPEED) and 1250 or 1000))
			end

			if Data:GetSideMove() ~= 0 then
				bEnt:ApplyForceCenter(Data:GetSideMove():absolutize() * Player:GetRight() * (Data:KeyDown(IN_SPEED) and 1250 or 1000))
			end

			if Data:KeyDown( 2 ) then
				local Head = m_R:GetPhysicsBone("ValveBiped.Bip01_Head1")
				if not IsValid( Head ) then return end
				Head:ApplyForceCenter( Vector( 0, 0, 4000 ))

				if m_R.Feet.L:GetMass() ~= 2000 then
					m_R.Feet.L:SetMass( 2000 )
					m_R.Feet.R:SetMass( 2000 )

					m_R.Feet.R:EnableGravity( true )
					m_R.Feet.L:EnableGravity( true )
				end

			elseif m_R.Feet.L:GetMass() ~= 2 then
				m_R.Feet.L:SetMass( 2 )
				m_R.Feet.R:SetMass( 2 )

				m_R.Feet.R:EnableGravity( false )
				m_R.Feet.L:EnableGravity( false )
			end

			if Data:KeyDown( 1 ) then
				local Hand = m_R:GetPhysicsBone("ValveBiped.Bip01_L_Hand")
				if not IsValid( Hand ) then return end
				Hand:ApplyForceCenter( Vector( 0, 0, 111 ))
			end

			if Data:KeyDown( 2048 ) then
				local Hand = m_R:GetPhysicsBone("ValveBiped.Bip01_R_Hand")
				if not IsValid( Hand ) then return end
				Hand:ApplyForceCenter( Vector( 0, 0, 111 ))
			end
		end
	end)
end

hook.Add("PlayerSwitchFlashlight", "PreventLimpyLight", function( Player, State )
	if State and Player.m_Ragdoll then
		return false
	end
end)

hook.Add( "CanPlayerSuicide", "PreventSuicide", function( Player )
	if Player.m_Ragdoll then
		return false
	end
end)

Abilities.Register("Limpy Larry", [[( Currently in Beta. ) By pressing 'R',
	you have the ability to toggle becoming
	a limp, lifeless ragdoll that
	can squirm and move. You don't take fall
	damage whilst Ragdolled. 
	Use your limpness to squeeze into otherwise
	unreachable spots.
	]], 385 )
