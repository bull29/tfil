util.AddNetworkString("lava_notification")

function GM.CreateNotification( title, time, player, sound )
	net.Start("lava_notification")
	net.WriteString( title )
	net.WriteInt( time, 32 )
	net.WriteString( sound or "ambient/alarms/warningbell1.wav")
	if player then
		net.Send( player )
	else
		net.Broadcast()
	end
end