include("sh_lava.lua")

if not Rounds then
	include("tfil/gamemode/core/rounds/sv_rounds.lua")
end

local SetGlobalFloat = SetGlobalFloat
local table = table
local Lava = Lava
local Values = Values
local hook = hook
local FrameTime = FrameTime
local player_manager = player_manager
local CurTime = CurTime

Rounds.NextSuperDecentTime = nil

hook.Add("Think", "LavaSync", function()
	if not Lava.StartingLevel then
		Lava.StartingLevel = Entity(0):GetModelRenderBounds().z
		Lava.CurrentLevel = Lava.StartingLevel
	end
	if Lava.CurrentLevel ~= GetGlobalFloat("$lavalev", -10000) then
		SetGlobalFloat("$lavalev", Lava.CurrentLevel)
	end
end)

hook.Add("Think", "LavaMainCycle", function()
	if GAMEMODE.Config.GetHaltMode() then return end

	if Rounds.CurrentState == "Preround" then
		hook.Call("Lava.PreroundTick")

	elseif Rounds.CurrentState == "Started" then
		if hook.Call("Lava.RoundStartedTick") then return end

		Rounds.NextSuperDecentTime = Rounds.NextSuperDecentTime or CurTime() + 10

		if Rounds.NextSuperDecentTime < CurTime() then
			local tab = player.GetAll()

			for k, v in pairs(tab) do
				if not v:Alive() then
					table.remove(tab, k)
				end
			end

			if tab[1] then
				table.sort(tab, function(a, b) return a:GetPos().z < b:GetPos().z end)
				local t = ((tab[1]:GetPos().z - 32 - Lava.GetLevel()) * FrameTime() / 25):max(FrameTime() * 5)
				Lava.ShiftLevel(t)

				if t == FrameTime() * 5 then
					Rounds.NextSuperDecentTime = CurTime() + 30
				end
			end
		else
			Lava.ShiftLevel(FrameTime() * 5)
		end
	elseif Rounds.CurrentState == "Ended" then
		hook.Call("Lava.RoundEndedTick")
		Rounds.NextSuperDecentTime = nil
	end
end)

hook.Add("PlayerTick", "LavaHurt", function(Player)
	if Player.m_Ragdoll and Player.m_Ragdoll:GetPos().z <= Lava.CurrentLevel then
		Ragdoll.Disable( Player )
	end

	if Player:Alive() and Rounds.CurrentState == "Started" and Player:GetPos().z <= Lava.CurrentLevel and hook.Call("Lava.ShouldTakeLavaDamage", nil, Player) ~= false then
		Player:Ignite(0.1, 0)
		Player:EmitSound("ambient/voices/m_scream1.wav")
	end
end)



hook.Add("DoPlayerDeath", "CreateRagdoll", function( Player, Entity )
	Player.m_LastKiller = Entity
end)

hook.Add("PostPlayerDeath", "CreateDeathRagdoll",function( Player )
	if ( IsValid( Player.m_LastKiller ) and Player.m_LastKiller:GetClass() == "entityflame" ) or Player:GetPos().z <= Lava.GetLevel() then
		local rag = Player:GetRagdollEntity()
		rag:SetModel("models/player/charple.mdl")
		rag:Ignite( 500, 0 )
	end
end)

function GM:EntityTakeDamage( Entity, Damage )
	if IsValid( Entity ) and IsValid( Damage:GetAttacker() ) and Entity:IsPlayer() and Damage:GetAttacker():GetClass() == "entityflame" then
		Damage:ScaleDamage( math.random(7,12) )
	end
end