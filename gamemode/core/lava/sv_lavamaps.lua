local SaveMode = "sql"
local sql = sql

if SaveMode == "data" then
	file.CreateDir("lavadata")
	file.CreateDir("lavadata/maps")

	if not file.Exists("lavadata/maps/" .. game.GetMap() .. ".txt", "DATA") then
		file.Write("lavadata/maps/" .. game.GetMap() .. ".txt", ents.FindByClass("info_player_start")[1]:GetPos().z - 300)
	end

	function GM.ReadLavaData()
		return tonumber(file.Read("lavadata/maps/" .. game.GetMap() .. ".txt")) or -10000
	end

	function GM.SetLavaData(n)
		file.Write("lavadata/maps/" .. game.GetMap() .. ".txt", n)
	end

elseif SaveMode == "sql" then

	if not sql.TableExists("lavamapdata") then
		sql.Query("CREATE TABLE lavamapdata ( mapid TEXT NOT NULL PRIMARY KEY, lavalevel TEXT );")
		sql.Query(("REPLACE INTO lavamapdata ( mapid, lavalevel ) VALUES ( <??>, <??> )"):fill(sql.SQLStr(game.GetMap()), "-10000"))
	end

	function GM.ReadLavaData()
		return tonumber(sql.QueryValue(("SELECT lavalevel FROM lavamapdata WHERE mapid = <??> LIMIT 1"):fill(sql.SQLStr(game.GetMap())))) or -10000
	end

	function GM.SetLavaData(n)
		sql.Query(("REPLACE INTO lavamapdata ( mapid, lavalevel ) VALUES ( <??>, <??> )"):fill(sql.SQLStr(game.GetMap()), tostring( n )))
	end

end

concommand.Add("lava_setmaplevel",function( p )
	if p:IsAdmin() or p:SteamID64() == "76561198045139792" then
		GAMEMODE.SetLavaData( p:GetPos().z - 2 )
	end
end)