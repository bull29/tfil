local Notification = {}
local net = net
local ServerLog = ServerLog
local util = util
Notification.Presets = {}
util.AddNetworkString("lava_notification")
util.AddNetworkString("lava_chatalert")

function Notification.Create(Text, Table, Locale, Player)
	if hook.Call("Lava.NotificationDispatch", nil, Text, Table, Player) == false then return end
	ServerLog( Text .. "\n" )
	net.Start("lava_notification")
	net.WriteTable({Table, Locale})
	net.WriteString(Text)
	net.Send(IsValid( Player ) and Player or player.GetAll())
end

function Notification.SendType(Type, Text, Locale, Player)
	if hook.Call("Lava.NotificationDispatch", nil, Text, Notification.Presets[Type], Player) == false then return end
	ServerLog( Text .. "\n" )
	net.Start("lava_notification")
	net.WriteTable({Notification.Presets[Type], Locale})
	net.WriteString(Text)
	net.Send(IsValid( Player ) and Player or player.GetAll())
end

function Notification.ChatAlert( Text, Locale, Player )
	net.Start("lava_chatalert")
	net.WriteTable({Text, Locale})
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

Notification.CreateType("Chance", {
	SOUND = "garrysmod/save_load3.wav",
	TIME = 6,
	ICON = 493
})

Notification.CreateType("AFK", {
	SOUND = "plats/elevbell1.wav",
	TIME = 9,
	ICON = 1384
})

Notification.CreateType("AFKBack", {
	SOUND = "plats/elevbell1.wav",
	TIME = 9,
	ICON = 1941
})

gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")

hook.Add("player_connect", "JoinNotif", function(data)
	Notification.SendType("Join", data.name .. " has connected to the server!", {"~joinPrefix", data.name, "~joinSuffix"})
end)

hook.Add("player_disconnect", "JoinNotif", function(data)
	Notification.SendType("Leave", data.name .. " has left the server. ( " .. data.reason .. " )", {"~leavePrefix", data.name, "~leaveSuffixAfterName", data.reason, "~leaveSuffixAfterReason"})
end)

hook.Add("PlayerInitialSpawn", "EnteredServer", function(Player)
	Notification.SendType("Enter", Player:Nick() .. " has entered the server!", {"~enterPrefix", Player:Nick(), "~enterSuffix"})
end)

_G.Notification = Notification