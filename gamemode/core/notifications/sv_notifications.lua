local Notification = {}
local net = net
local ServerLog = ServerLog
local util = util
Notification.Presets = {}
util.AddNetworkString("lava_notification")

function Notification.Create(Text, Table, Player)
	if hook.Call("Lava.NotificationDispatch", nil, Text, Table, Player) == false then return end
	ServerLog( Text .. "\n" )
	net.Start("lava_notification")
	net.WriteTable(Table)
	net.WriteString(Text)
	net.Send(IsValid( Player ) and Player or player.GetAll())
end

function Notification.SendType(Type, Text, Player)
	if hook.Call("Lava.NotificationDispatch", nil, Text, Notification.Presets[Type], Player) == false then return end
	ServerLog( Text .. "\n" )
	net.Start("lava_notification")
	net.WriteTable(Notification.Presets[Type])
	net.WriteString(Text)
	net.Send(IsValid( Player ) and Player or player.GetAll())
end

function Notification.CreateType(TypeName, Data)
	Notification.Presets[TypeName] = Data
end

Notification.CreateType("General", {
	SOUND = "ambient/water/drip2.wav",
	TIME = 5,
	ICON = 2438
})

Notification.CreateType("Join", {
	SOUND = "garrysmod/save_load4.wav",
	TIME = 6,
	ICON = 347
})

Notification.CreateType("Enter", {
	SOUND = "garrysmod/save_load1.wav",
	TIME = 6,
	ICON = 348
})

Notification.CreateType("Leave", {
	SOUND = "garrysmod/save_load2.wav",
	TIME = 6,
	ICON = 346
})

Notification.CreateType("Winner", {
	SOUND = "garrysmod/save_load3.wav",
	TIME = 10,
	ICON = 2188
})

Notification.CreateType("Mutator", {
	SOUND = "npc/scanner/scanner_siren1.wav",
	TIME = 10,
	ICON = 2
})

gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")

hook.Add("player_connect", "JoinNotif", function(data)
	Notification.SendType("Join", data.name .. " has connected to the server!")
end)

hook.Add("player_disconnect", "JoinNotif", function(data)
	Notification.SendType("Leave", data.name .. " has left the server. ( " .. data.reason .. " )")
end)

hook.Add("PlayerInitialSpawn", "EnteredServer", function(Player)
	Notification.SendType("Enter", Player:Nick() .. " has entered the server!")
end)

_G.Notification = Notification