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

function GM:PlayerDeath(ply, inflictor, attacker)
	ply.NextSpawnTime = CurTime() + 2
	ply.DeathTime = CurTime()

	if (IsValid(attacker) and attacker:GetClass() == "trigger_hurt") then
		attacker = ply
	end

	if (IsValid(attacker) and attacker:IsVehicle() and IsValid(attacker:GetDriver())) then
		attacker = attacker:GetDriver()
	end

	if (not IsValid(inflictor) and IsValid(attacker)) then
		inflictor = attacker
	end

	if (IsValid(inflictor) and inflictor == attacker and (inflictor:IsPlayer() or inflictor:IsNPC())) then
		inflictor = inflictor:GetActiveWeapon()

		if (not IsValid(inflictor)) then
			inflictor = attacker
		end
	end

	if ply.m_LastShovedBy and IsValid(ply.m_LastShovedBy) and ply.m_LastShovedTime > CurTime() - 10 then
		attacker = ply.m_LastShovedBy
		attacker:AddFrags(1)
	end

	hook.Call("Lava.PlayerDeath", nil, ply, inflictor, attacker)

	if (attacker == ply) then
		net.Start("PlayerKilledSelf")
		net.WriteEntity(ply)
		net.Broadcast()
		MsgAll(attacker:Nick() .. " suicided!\n")

		return
	end

	if (attacker:IsPlayer()) then
		net.Start("PlayerKilledByPlayer")
		net.WriteEntity(ply)
		net.WriteString(inflictor:GetClass())
		net.WriteEntity(attacker)
		net.Broadcast()
		MsgAll(attacker:Nick() .. " killed " .. ply:Nick() .. " using " .. inflictor:GetClass() .. "\n")

		return
	end

	net.Start("PlayerKilled")
	net.WriteEntity(ply)
	net.WriteString(inflictor:GetClass())
	net.WriteString(attacker:GetClass())
	net.Broadcast()
	MsgAll(ply:Nick() .. " was killed by " .. attacker:GetClass() .. "\n")
end