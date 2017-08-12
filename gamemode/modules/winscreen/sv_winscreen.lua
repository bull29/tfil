util.AddNetworkString("lava_winscreen")

hook.Add("Lava.PlayerRankings", "OpenWinscreen", function(ranking)
	net.Start("lava_winscreen")
	net.WriteTable(ranking)
	net.Send(player.GetAll())
end)