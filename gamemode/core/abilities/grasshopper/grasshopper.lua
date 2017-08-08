
hook.Add("SetupMove", "Grasshopper", function( Player, Movedata )
	if Player:HasAbility("Grasshopper") then
		Player.m_JumpsLeft = Player.m_JumpsLeft or 3
		if Player:OnGround() then
			Player.m_JumpsLeft = 3
		end
		if not Player.m_HasApeJumped and Player.m_JumpsLeft > 0 and not Player:OnGround() and Player:KeyDown( 2 ) then
			Player.m_HasApeJumped = true
			Player.m_JumpsLeft = Player.m_JumpsLeft - 1
			local CurrentVelocity = Movedata:GetVelocity()
			local ShouldBlockFall
			if CurrentVelocity.z < 0 then
				ShouldBlockFall = true
			end
			Movedata:SetVelocity( CurrentVelocity:SetZ( 0 ) + ( ( Player:GetJumpPower() + ( ShouldBlockFall and CurrentVelocity.z or 0 ))* Vector( 0, 0, 1 ) * 1.2 ) )
		elseif not Player:KeyDown(2) then
			Player.m_HasApeJumped = nil
		end
	end
end)

Abilities.Register("Grasshopper", [[You sexually identify as an grasshopper and as a result, you can triple jump. You have a slightly higher jump-power than others.]], 2245 )