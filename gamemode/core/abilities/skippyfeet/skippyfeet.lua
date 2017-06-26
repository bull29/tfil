hook.Add("Lava.ShouldTakeLavaDamage", "SkippyFeet", function(Player)
	if not Player:HasAbility("Skippy Feet") then return end

	timer.Simple(0, function()
		Player:SetPos(Player:GetPos() + Vector(0, 0, 5))
		Player:SetVelocity(Player:GetAimVector():SetZ(1) * 750)
	end)
end)

hook.Add("GetFallDamage", "AvoidFallDamage", function(Player)
	if Player:HasAbility("Skippy Feet") then return false end
end)

hook.Add("Lava.PostPlayerSpawn", "HalfenHealth", function( Player )
	if Player:HasAbility("Skippy Feet") then
		Player:SetHealth( Player:Health()/2 )
	end
end)

Abilities.Register("Skippy Feet", [[Ever wanted to have a quick way out?
	Everytime you hit lava, you fly away!
	At the cost of 1/2 HP,
	You don't take fall damage either!]], "http://i.imgur.com/EyFYhG5.png")