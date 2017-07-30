local Player = debug.getregistry().Player
local tonumber = tonumber
local Statistics = {}
Statistics.Datapoints = {}
Statistics.DatapointIDs = {}

function Statistics.Create(Name, sID)
	Statistics.Datapoints[Name] = sID
	Statistics.DatapointIDs[sID] = Name
end

Statistics.Create("Total Wins", "WH")
Statistics.Create("Eggs Thrown", "ET")
Statistics.Create("Eggs Hit", "EH")

local function NetworkStats(Player)
	Player.m_Statistics = {}

	for Name, Stat in pairs(Statistics.Datapoints) do
		Player.m_Statistics[Stat] = Player:GetPData("Lava.Statistics." .. Stat, 0)
	end

	Player:SetNW2String("$stats", util.TableToJSON(Player.m_Statistics))
end

hook.Add("PlayerInitialSpawn", "InitializeStats", NetworkStats)

function Player:IncrementStat(Name, Amount)
	Amount = Amount or 1
	local quer = "Lava.Statistics." .. Statistics.Datapoints[Name]
	self:SetPData(quer, self:GetPData(quer, 0) + Amount)
	NetworkStats(self)
end

_G.Statistics = Statistics