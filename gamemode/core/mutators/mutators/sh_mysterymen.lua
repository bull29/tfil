local draw = draw
local Mutators = Mutators
local gui = gui
local player = player
local vgui = vgui
local pMeta = debug.getregistry().Player

Mutators.RegisterNewEvent("Mystery Men", "Everybody is under an comprehensive alias. Trust nobody.", function()
	if CLIENT then
		chat.AddTextOld = chat.AddTextOld or chat.AddText

		function chat.AddText( ... )
			if Mutators.IsActive("Mystery Men") then
				local args = { ... }
				if args[1]:IsPlayer() then
					table.insert( args, 1, args[1]:PlayerColor() )
					args[2] = args[2]:Nick()
					return chat.AddTextOld( unpack( args ))
				end
			end
			return chat.AddTextOld( ... )
		end

		pMeta.ShowProfileOld = pMeta.ShowProfileOld or pMeta.ShowProfile

		function pMeta:ShowProfile()
			if Mutators.IsActive("Mystery Men") then
				return gui.OpenURL("https://steamcommunity.com/profiles/"..self:SteamID64())
			end
			return self:ShowProfileOld()
		end
	end
	pMeta.NickOld = pMeta.NickOld or pMeta.Nick

	function pMeta.Nick(self)
		if self:Alive() and Mutators.IsActive("Mystery Men") and self:GetNWString("$mys_nick", "") ~= "" then return self:GetNWString("$mys_nick", "") end

		return pMeta.NickOld(self)
	end

	pMeta.Name, pMeta.GetName = pMeta.Nick, pMeta.Nick

	if SERVER then
		http.Fetch("https://randomuser.me/api/?gender=male&results=" .. player.GetCount() .. "&inc=name,picture", function(body)
			local x = body:JSONDecode()
			local players = player.GetAll()

			for k, v in pairs(x.results) do
				if not players[k] then continue end
				players[k]:SetNWString("$mys_nick", v.name.first:sub(1, 1):upper() .. v.name.first:sub(2) .. " " .. v.name.last:sub(1, 1):upper() .. v.name.last:sub(2))
				players[k]:SetNWString("$mys_avatarurl", v.picture.large)
			end
		end)
	else
		gui.OpenURLOld = gui.OpenURLOld or gui.OpenURL

		function gui.OpenURL(str) -- Its' the little things that count.
			if Mutators.IsActive("Mystery Men") then
				local x = str:match("76" .. ("%d"):rep(15))

				if x and not LocalPlayer():IsAdmin() then
					local Player = player.GetBySteamID64(x)
					if Player then return gui.OpenURLOld("http://images.google." .. system.GetCountry() .. "/search?tbm=isch&q=" .. Player:Nick():gsub(" ", "+")) end
				end
			end

			return gui.OpenURLOld(str)
		end
	end
end, function()
end)

hook.RunOnce("HUDPaint", function()
	if not vgui.GetControlTable("o_AvatarImage") then
		local SetPlayer = debug.getregistry().Panel.SetPlayer

		vgui.Register("o_AvatarImage", {
			SetPlayer = function(self, ent, size)
				self.Player = ent
				SetPlayer(self, ent, size)
			end,
			PaintOver = function(s, w, h)
				if s.Player and s.Player:IsValid() and Mutators.IsActive("Mystery Men") and s.Player:Alive() then
					local url = s.Player:GetNWString("$mys_avatarurl", "")

					if url ~= "" then
						draw.WebImage(url, 0, 0, w, h)
					end
				end
			end
		}, "AvatarImage")
	end

	local sOfPrevention = false -- Stack overflow prevention

	if not vgui.CreateOld then
		vgui.CreateOld = vgui.CreateOld or vgui.Create

		function vgui.Create(a, ...)
			if a == "AvatarImage" and not sOfPrevention then
				sOfPrevention = true

				return vgui.CreateOld("o_AvatarImage", ...)
			elseif sOfPrevention then
				sOfPrevention = false
			end

			return vgui.CreateOld(a, ...)
		end
	end
end)