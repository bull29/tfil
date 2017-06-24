local Config = GM.GetConfig()
local Rounds = {}
Rounds.CurrentState = Rounds.CurrentState or "Preround"

local function SetRoundState(st)
	Rounds.CurrentState = st
	SetGlobalString("$RoundState", st)
end

local function SetStringProper(query)
	if GetGlobalString("$RoundTime") ~= query then
		SetGlobalString("$RoundTime", query)
	end
end

local function SetTimer(time)
	Rounds.NextStateChange = time
end

function Rounds.Preround()
	RunConsoleCommand("lava_fog_sky_effects", "0")
	RunConsoleCommand("gmod_admin_cleanup")
	Lava.CurrentLevel = GAMEMODE.ReadLavaData()
	for Player in Values(player.GetAll()) do
		Player:Spawn()
	end

	SetRoundState("Preround")
	SetTimer(os.time() + Config.GetPreroundTime())
	hook.Call("Lava-Preround", GAMEMODE)
end

function Rounds.Start()
	RunConsoleCommand("lava_fog_sky_effects", "1")
	GAMEMODE.CreateNotification( "Round Started!\nThe Floor is Lava!\nEscape and Survive!", 5 )
	for Player in Values(player.GetAll()) do
		if not Player:Alive() then
			Player:Spawn()
		end
	end

	SetRoundState("Started")
	SetTimer(os.time() + Config.GetRoundTime())
	hook.Call("Lava-RoundStarted", GAMEMODE)
end

function Rounds.PostRound()
	SetRoundState("Ended")
	SetTimer(os.time() + Config.GetPostRoundTime())
	hook.Call("Lava-PostRound", GAMEMODE)
end

hook.Add("Think", "SyncRoundTime", function()
	local _ = tostring((os.time() - (Rounds.NextStateChange or os.time())):abs())
	local min = (_ / 60):floor()
	local str = (min < 10 and "0" .. min or min) .. ":" .. (_ % 60 < 10 and "0" .. _ % 60 or _ % 60)
	SetStringProper(str)
end)

hook.Add("Tick", "CycleRounds", function()
	Rounds.NextStateChange = Rounds.NextStateChange or 0
	if Rounds.NextStateChange <= os.time() then
		if Rounds.CurrentState == "Preround" then
			Rounds.Start()
		elseif Rounds.CurrentState == "Started" then
			Rounds.PostRound()
		elseif Rounds.CurrentState == "Ended" then
			Rounds.Preround()
		end
	end
end)

hook.Add("PostPlayerDeath", "CheckAllDead", function( Player)
	if Player:GetPos().z <= Lava.GetLevel() then
		local rag = Player:GetRagdollEntity()
		rag:SetModel("models/player/charple.mdl")
		rag:Ignite( 500, 0 )
	end

	if Rounds.CurrentState == "Started" then
		local ShouldRestart = true

		for Player in Values(player.GetAll()) do
			if Player:Alive() then
				ShouldRestart = false
				break
			end
		end

		if ShouldRestart then
			GAMEMODE.CreateNotification( Player:Nick() .. " is the winner! ", 10 )
			Rounds.PostRound()
		end
	end
end)

hook.Add("PlayerDeathThink", "PreventRespawning",function( Player )
	if not Player:Alive() and Rounds.CurrentState ~= "Preround" then
		return false
	end
end)

hook.Add("PlayerInitialSpawn", "CheckLone",function()
	if #player.GetAll() == 1 then
		Rounds.Preround()
	end
end)

_G.Rounds = Rounds