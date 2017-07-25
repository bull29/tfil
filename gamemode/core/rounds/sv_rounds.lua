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
	hook.Call("Lava.PreroundStart")

	RunConsoleCommand("lava_fog_sky_effects", "0")
	RunConsoleCommand("gmod_admin_cleanup")

	Lava.CurrentLevel = Lava.StartingLevel or Entity(0):GetModelRenderBounds().z
	for Player in Values(player.GetAll()) do
		Player:Spawn()
		Player:SetObserverMode( OBS_MODE_NONE )
	end

	SetRoundState("Preround")
	SetTimer(os.time() + Config.GetPreroundTime())
end

function Rounds.Start()
	hook.Call("Lava.RoundStart")

	RunConsoleCommand("lava_fog_sky_effects", "1")
	--GAMEMODE.CreateNotification( "Round Started!\nThe Floor is Lava!\nEscape and Survive!", 5 )
	for Player in Values(player.GetAll()) do
		if not Player:Alive() then
			Player:Spawn()
			Player:SetObserverMode( OBS_MODE_NONE )
		end
	end

	SetRoundState("Started")
	SetTimer(os.time() + Config.GetRoundTime())
end

function Rounds.PostRound()
	hook.Call("Lava.PostRound" )
	SetRoundState("Ended")
	SetTimer(os.time() + Config.GetPostRoundTime())
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

function Rounds.CheckShouldRestart()
	if Rounds.CurrentState == "Started" then
		local ShouldRestart = true

		for Player in Values(player.GetAll()) do
			if Player:Alive() then
				ShouldRestart = false
				break
			end
		end

		if player.GetCount() > 1 and #player.GetAlive() == 1 then
			ShouldRestart = true
		end

		PrintMessage( 4, ( player.GetAlive()[1] or player.GetAll()[1] ):Nick() .. " is the Winner!" )

		if ShouldRestart then
			Rounds.PostRound()
		end
	end
end

gameevent.Listen( "player_disconnect" )
hook.Add("PostPlayerDeath", "CheckAllDead", Rounds.CheckShouldRestart )
hook.Add( "player_disconnect", "CheckAllDead", function()
	FrameDelay( function()
		Rounds.CheckShouldRestart()
	end)
end )

hook.Add("PlayerDeathThink", "PreventRespawning",function( Player )
	if not Player:Alive() and Rounds.CurrentState ~= "Preround" and hook.Call("Lava.DeathThink", nil, Player ) == nil then
		return false
	end
end)

hook.Add("PlayerInitialSpawn", "CheckLone",function()
	if #player.GetAll() == 1 then
		Rounds.Preround()
	end
end)

_G.Rounds = Rounds

Rounds.Start()