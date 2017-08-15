local Ranking = {}
local requestCallback
local orders = {
	steamid64 = 1,
	name = 2,
	ability = 3,
	lastvisit = 4,
	timetotal = 5,
	timealive = 6,
	timedead = 7,
	kills = 8,
	deaths = 9,
	wins = 10,
	loses = 11,
	eggsthrown = 12,
	eggshit = 13
}

----------

function Ranking.MakeRequest(page, max, order, asc, callback)
	if orders[order] then
		requestCallback = callback
		
		net.Start("tfil_rankingrequest")
		net.WriteInt(page, 16)
		net.WriteInt(max, 6)
		net.WriteInt(orders[order] + (asc and 13 or 0), 6)
		net.SendToServer()
	end
end

----------

net.Receive("tfil_rankingrequest", function()
	if requestCallback then
		requestCallback(net.ReadTable(), net.ReadTable())
		requestCallback = nil
	end
end)

----------

--Ranking.MakeRequest(1, "name", false, function(data) PrintTable(data[1]) end)

_G.Ranking = Ranking