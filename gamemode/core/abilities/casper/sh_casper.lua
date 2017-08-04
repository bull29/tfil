


hook.Add("Lava.PostPlayerSpawn", "CASPER", function( Player )
	if Player:HasAbility("Casper") then
		Player:SetCustomCollisionCheck( true )
		Player:SetRunSpeed( Player:GetRunSpeed() * 1.3 )
		Player:SetWalkSpeed( Player:GetWalkSpeed() * 1.3 )
		Player:SetAvoidPlayers( false )
	else
		Player:SetCustomCollisionCheck( false )
	end
	Player:CollisionRulesChanged()
end)

function GM:ShouldCollide( A, B )
	if A:IsPlayer() and B:IsPlayer() and ( A:HasAbility("Casper") or B:HasAbility("Casper") ) then
		return false
	end
end

Abilities.Register("Casper", [[You don't collide with players and move slightly faster than others. Extremely beneficial on maps with narrow pathways.]], 1200,
function( Player )
	Player:SetCustomCollisionCheck( true )
	Player:CollisionRulesChanged()
	Player:SetRunSpeed( 225 * 1.3 )
	Player:SetWalkSpeed( 175 * 1.3 )
end,
function( Player )
	Player:SetCustomCollisionCheck( false )
	Player:CollisionRulesChanged()
	Player:SetRunSpeed( 225 )
	Player:SetWalkSpeed( 175 )
end)
