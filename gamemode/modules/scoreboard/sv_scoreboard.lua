util.AddNetworkString("lava_country")

net.Receive( "lava_country", function( _, Player )
	if not Player.m_HasProvidedCountry then
		Player.m_HasProvidedCountry = true
		local Country = net.ReadString()

		if #Country ~= 2 then return end

		Player:SetNWString("$country", Country:lower() )
	end
end)