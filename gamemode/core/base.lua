local math = math
local m_NextfTick = CurTime()

function GM:Tick()
	if m_NextfTick <= CurTime() then
		m_NextfTick = CurTime() + 1
		hook.Call("Lava.FullTick")
	end
end

function GM:ShouldCollide(A, B)
	if A:IsPlayer() and B:IsPlayer() and (A:GetMoveType() == 9 or B:GetMoveType() == 9) then return false end
	if A:IsPlayer() and B.m_Owner == A then return false end
	if B:IsPlayer() and A.m_Owner == B then return false end

	return true
end

function GM:OnGamemodeLoaded()
	GAMEMODE, GM = gmod.GetGamemode(), gmod.GetGamemode()
end

function CalculateBaseFallDamage(Speed)
	return math.max(15, math.ceil(0.2418 * Speed - 141.75) * 2)
end

function GM:GetFallDamage(Player, Speed)
	return CalculateBaseFallDamage(Speed)
end

function GM:PlayerCanPickupWeapon(Player, Weapon)
	return Weapon:GetClass() == "lava_fists"
end

function GM:GetTeamColor(Entity)
	if Entity.PlayerColor then return Entity:PlayerColor() end

	return Color(255, 255, 255)
end

function GM:EntityTakeDamage(Entity, Damage)
	if IsValid(Entity) and IsValid(Damage:GetInflictor()) and (Damage:GetInflictor():GetClass() == "prop_physics" or Damage:GetInflictor():GetClass() == "prop_ragdoll") then
		Damage:ScaleDamage(0)
	end

	if IsValid(Entity) and IsValid(Damage:GetAttacker()) and Entity:IsPlayer() and Damage:GetAttacker():GetClass() == "entityflame" then
		Damage:ScaleDamage(math.random(7, 15))
	end

	if Damage:IsBulletDamage() and not hook.Call("Lava.ShouldBlockBulletDamage", nil, Entity, Damage) then return true end
end

if SERVER then util.AddNetworkString("lava_player_death") end

function GM:PlayerDeath(Player, Inflictor, Attacker)
	Player.NextSpawnTime = CurTime() + 2
	Player.DeathTime = CurTime()

	if (IsValid(Attacker) and Attacker:GetClass() == "trigger_hurt") then
		Attacker = Player
	end

	if (IsValid(Attacker) and Attacker:IsVehicle() and IsValid(Attacker:GetDriver())) then
		Attacker = Attacker:GetDriver()
	end

	if (not IsValid(Inflictor) and IsValid(Attacker)) then
		Inflictor = Attacker
	end

	if (IsValid(Inflictor) and Inflictor == Attacker and (Inflictor:IsPlayer() or Inflictor:IsNPC())) then
		Inflictor = Inflictor:GetActiveWeapon()

		if (not IsValid(Inflictor)) then
			Inflictor = Attacker
		end
	end

	if Player.m_LastShovedBy and IsValid(Player.m_LastShovedBy) and Player.m_LastShovedTime > CurTime() - 10 then
		Attacker = Player.m_LastShovedBy
		Attacker:AddFrags(1)
	end

	hook.Call("Lava.PlayerDeath", nil, Player, Inflictor, Attacker)

	net.Start("lava_player_death")
	net.WriteEntity( Player )
	net.WriteEntity( Attacker )
	net.WriteEntity( Inflictor )
	net.Broadcast()
end