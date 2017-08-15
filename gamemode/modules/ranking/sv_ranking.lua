local Ranking = {}
local requestTimeout = {}
local orders = {
	"steamid64",
	"name",
	"ability",
	"lastvisit",
	"timetotal",
	"timealive",
	"timedead",
	"kills",
	"deaths",
	"wins",
	"loses",
	"eggsthrown",
	"eggshit"
}

----------

if not sql.TableExists("tfil_stats") then
	sql.Query([[CREATE TABLE tfil_stats (
		steamid64 varchar(255) NOT NULL,
		name varchar(255) NOT NULL,
		ability varchar(255),
		lastvisit INT NOT NULL,
		timetotal INT,
		timealive INT,
		timedead INT,
		kills INT,
		deaths INT,
		wins INT,
		loses INT,
		eggsthrown INT,
		eggshit INT
	);]])
else
	
end

----------

function Ranking.AddAbilityUse(ply, ability)
	local pdata = ply:GetPData("$ability_usecounts", false)
	local data = {}
	
	if pdata then
		data = util.JSONToTable(pdata)
		
		data[ability] = (data[ability] or 0) + 1
		
		ply:SetPData("$ability_usecounts", util.TableToJSON(data))
	else
		data = {
			[ability] = 1
		}
		
		ply:SetPData("$ability_usecounts", util.TableToJSON(data))
	end
	
	
	local mostUsed = nil
	local count = -1
	
	for k, v in pairs(data) do
		if v > count then
			mostUsed = k
			count = v
		end
	end
	
	if mostUsed == ability then
		sql.Query("UPDATE tfil_stats SET ability = '" .. ability .. "' WHERE steamid64 = '" .. ply:SteamID64() .. "'")
	end
end

function Ranking.AddKill(ply)
	local id = ply:SteamID64()
	local result = sql.QueryRow("SELECT kills FROM tfil_stats WHERE steamid64 = '" .. id .. "';")
	
	if result then
		local kills = (result.kills == "NULL" and 0 or result.kills) + 1
		
		sql.Query("UPDATE tfil_stats SET kills = " .. kills .. " WHERE steamid64 = '" .. id .. "'")
	else
		print("Failed to add a kill to player " .. ply:GetName() .. " (" .. id .. ")")
	end
end

function Ranking.AddDeath(ply)
	local id = ply:SteamID64()
	local result = sql.QueryRow("SELECT deaths FROM tfil_stats WHERE steamid64 = '" .. id .. "';")
	
	if result then
		local deaths = (result.deaths == "NULL" and 0 or result.deaths) + 1
		
		sql.Query("UPDATE tfil_stats SET deaths = " .. deaths .. " WHERE steamid64 = '" .. id .. "'")
	else
		print("Failed to add a death to player " .. ply:GetName() .. " (" .. id .. ")")
	end
end

function Ranking.AddWin(ply)
	local id = ply:SteamID64()
	local result = sql.QueryRow("SELECT wins FROM tfil_stats WHERE steamid64 = '" .. id .. "';")
	
	if result then
		local wins = (result.wins == "NULL" and 0 or result.wins) + 1
		
		sql.Query("UPDATE tfil_stats SET wins = " .. wins .. " WHERE steamid64 = '" .. id .. "'")
	else
		print("Failed to add a win to player " .. ply:GetName() .. " (" .. id .. ")")
	end
end

function Ranking.AddLose(ply)
	local id = ply:SteamID64()
	local result = sql.QueryRow("SELECT loses FROM tfil_stats WHERE steamid64 = '" .. id .. "';")
	
	if result then
		local loses = (result.loses == "NULL" and 0 or result.loses) + 1
		
		sql.Query("UPDATE tfil_stats SET loses = " .. loses .. " WHERE steamid64 = '" .. id .. "'")
	else
		print("Failed to add a lose to player " .. ply:GetName() .. " (" .. id .. ")")
	end
end

function Ranking.AddEggThrow(ply)
	local id = ply:SteamID64()
	local result = sql.QueryRow("SELECT eggsthrown FROM tfil_stats WHERE steamid64 = '" .. id .. "';")
	
	if result then
		local eggsthrown = (result.eggsthrown == "NULL" and 0 or result.eggsthrown) + 1
		
		sql.Query("UPDATE tfil_stats SET eggsthrown = " .. eggsthrown .. " WHERE steamid64 = '" .. id .. "'")
	else
		print("Failed to add a eggthrow to player " .. ply:GetName() .. " (" .. id .. ")")
	end
end

function Ranking.AddEggHit(ply)
	local id = ply:SteamID64()
	local result = sql.QueryRow("SELECT eggshit FROM tfil_stats WHERE steamid64 = '" .. id .. "';")
	
	if result then
		local eggshit = (result.eggshit == "NULL" and 0 or result.eggshit) + 1
		
		sql.Query("UPDATE tfil_stats SET eggshit = " .. eggshit .. " WHERE steamid64 = '" .. id .. "'")
	else
		print("Failed to add a egghit to player " .. ply:GetName() .. " (" .. id .. ")")
	end
end

----------

hook.Add("PlayerInitialSpawn", "LavaRanking", function(ply)
	local id = ply:SteamID64()
	local result = sql.QueryRow("SELECT * FROM tfil_stats WHERE steamid64 = '" .. id .. "';")
	
	if not result then
		sql.Query("INSERT INTO tfil_stats (steamid64, name, lastvisit) VALUES ('" .. id .. "', '" .. SQLStr(ply:GetName(), true) .. "', " .. os.time() .. ");")
	else
		sql.Query("UPDATE tfil_stats SET name = '" .. SQLStr(ply:GetName(), true) .. "' WHERE steamid64 = '" .. id .. "'")
	end
end)

hook.Add("Lava.RoundStart", "LavaRanking", function()
	for k, ply in pairs(player.GetAll()) do
		local ability = ply:GetPData("$ability", false)
		
		if ability then
			Ranking.AddAbilityUse(ply, ability)
		end
	end
end)

hook.Add("Lava.PlayerRankings", "LavaRanking", function(data)
	Ranking.AddWin(data[1])
	
	for i = 4, #data do
		Ranking.AddLose(data[i])
	end
end)

hook.Add("Lava.PlayerDeath", "LavaRanking", function(ply, wep, attacker)
	if Rounds.CurrentState == "Started" then
		if IsValid(attacker) and attacker:IsPlayer() then
			Ranking.AddKill(attacker)
		end
		
		Ranking.AddDeath(ply)
	end
end)

----------


util.AddNetworkString("tfil_rankingrequest")

net.Receive("tfil_rankingrequest", function(len, ply)
	if requestTimeout[ply] then
		if requestTimeout[ply] > CurTime() then
			ply:ChatPrint("You can't reload yet, seconds left until next allowed timeout: " .. math.Round(requestTimeout[ply] - CurTime(), 1))
			
			return
		end
		
		requestTimeout[ply] = nil
	end
	
	local page = net.ReadInt(16) - 1
	local max = math.Clamp(net.ReadInt(6), 5, 25)
	local orderInd = net.ReadInt(6)
	
	if page and page >= 0 and orderInd and orderInd >= 1 and orderInd <= 26 then
		local order = orders[(orderInd - 1)%13 + 1]
		local asc = orderInd > 13 and "ASC" or "DESC"
		local offset = page > 0 and ("OFFSET " .. (page * max)) or ""
		local search = net.ReadString() or ""
		
		if #search > 25 then
			search = string.sub(search, 1, 25)
		end
		
		search = SQLStr(search, true)
		
		local data = sql.Query("SELECT * FROM tfil_stats WHERE name LIKE '%" .. search .. "%' ORDER BY " .. order .. " " .. asc .. " LIMIT " .. max .. " " .. offset .. ";")
		local dataS = sql.QueryRow("SELECT * FROM tfil_stats WHERE steamid64 = '" .. ply:SteamID64() .. "';")

		if data and istable(data) then
			net.Start("tfil_rankingrequest")
			net.WriteTable(data)
			net.WriteTable(dataS)
			net.Send(ply)
		elseif search ~= "" then
			net.Start("tfil_rankingrequest")
			net.WriteTable{}
			net.WriteTable(dataS or {})
			net.Send(ply)
		end
	end

	requestTimeout[ply] = CurTime() + 0.25
end)

----------

_G.Ranking = Ranking