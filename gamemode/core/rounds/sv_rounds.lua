local Config = GM.GetConfig()
local Rounds = {}
Rounds.CurrentState = Rounds.CurrentState or "Preround"
NextMapTime = NextMapTime or 0
SetGlobalInt( "$NextMapTime", NextMapTime )
local playerRanking = {}

hook.Add("Initialize", "ResetmapTime", function()
	NextMapTime = 0
end)

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
	if NextMapTime >= Config.GetMapSwitchTime() then
		if hook.Call("Lava.GetNextMap") == nil then
			MapVote.Start()
		end
	end

	hook.Call("Lava.PreroundStart")

	RunConsoleCommand("lava_fog_sky_effects", "0")
	RunConsoleCommand("gmod_admin_cleanup")

	Lava.CurrentLevel = Lava.StartingLevel or Entity(0):GetModelRenderBounds().z
	for Player in Values(player.GetAll()) do
		if not Player:GetNW2Bool("$afk") then
			Player:Spawn()
		end
		Player:SetObserverMode( OBS_MODE_NONE )
	end

	SetRoundState("Preround")
	SetTimer(os.time() + Config.GetPreroundTime())
end

function Rounds.Start()
	hook.Call("Lava.RoundStart")

	RunConsoleCommand("lava_fog_sky_effects", "1")

	for Player in Values(player.GetAll()) do
		if not Player:Alive() then
			if not Player:GetNW2Bool("$afk") then
				Player:Spawn()
			end
			Player:SetObserverMode( OBS_MODE_NONE )
		elseif Player:Health() ~= 100 or ( Player.m_Ragdoll and Player.m_RagdollData.Health ~= 100 ) then
			Player:SetHealth( Player:HasAbility("Skippy Feet") and 35 or 100 )
			if Player.m_Ragdoll then Player.m_RagdollData.Health = 100 end
		end
		if Player:GetActiveWeapon():IsValid() and Player:GetActiveWeapon():GetClass() == "lava_fists" then
			Player:GetActiveWeapon():SetEggs( 6 )
		end
	end

	playerRanking = {}

	SetRoundState("Started")
	SetTimer(os.time() + Config.GetRoundTime())

	Notification.Create("The Round has Started! The Floor is Lava!", { SOUND = "ambient/water/drip2.wav", TIME = 5, ICON = 328 })
end

function Rounds.PostRound()
	hook.Call("Lava.PostRound" )
	SetRoundState("Ended")
	SetTimer(os.time() + Config.GetPostRoundTime())

	NextMapTime = NextMapTime + 1
	SetGlobalInt( "$NextMapTime", NextMapTime )
end

hook.Add("Think", "SyncRoundTime", function()
	if #player.GetActive() > 0 then
		local _ = tostring((os.time() - (Rounds.NextStateChange or os.time())):abs())
		local min = (_ / 60):floor()
		local str = (min < 10 and "0" .. min or min) .. ":" .. (_ % 60 < 10 and "0" .. _ % 60 or _ % 60)
		SetStringProper(str)
	else
		SetStringProper("10:10")
		SetRoundState("Snooze")
	end
end)

hook.Add("Tick", "CycleRounds", function()
	if #player.GetActive() == 0 then return end

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

		if hook.Call( "Lava.SelectRoundWinner") == true then return end

		if #player.GetAlive() == 1 then
			if #player.GetActive() == 1 then
				ShouldRestart = false
			else
				ShouldRestart = true
				Notification.SendType( "Winner", player.GetAlive()[1]:Nick() .. " has won!")

				table.insert(playerRanking, player.GetAlive()[1])

				local tbl = {}
				for k, v in pairs(table.Reverse(playerRanking)) do
					if IsValid(v) and v:IsPlayer() then
						table.insert(tbl, v)
					end
				end

				hook.Call("Lava.PlayerRankings", nil, tbl)
			end
		end

		if ShouldRestart then
			Rounds.PostRound()
		end
	end
end

gameevent.Listen( "player_disconnect" )
hook.Add("PostPlayerDeath", "CheckAllDead", function()
	if Rounds.CurrentState == "Started" then
		if #player.GetActive() == 1 then
			Notification.SendType( "Winner", player.GetAll()[1]:Nick() .. " has won by default!")
		end
		Rounds.CheckShouldRestart()
	end
end)
hook.Add( "player_disconnect", "CheckAllDead", function()
	FrameDelay( function()
		Rounds.CheckShouldRestart()
	end)
end )

hook.Add("PlayerDeathThink", "PreventRespawning",function( Player )
	if hook.Call("Lava.DeathThink", nil, Player ) == nil and not Player:Alive() and Rounds.CurrentState ~= "Preround" then
		return false
	end
end)

hook.Add("PlayerInitialSpawn", "CheckLone",function()
	if #player.GetAll() == 1 then
		Rounds.Preround()
	end
end)

hook.Add("PlayerDeath", "SelectPlayerRanking", function(ply)
	table.insert(playerRanking, ply)
end)

_G.Rounds = Rounds