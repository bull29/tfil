local file = file
local tostring = tostring
local Numbers = {
	["."] = "23fa",
	["0"] = "30-20e3",
	["1"] = "31-20e3",
	["2"] = "32-20e3",
	["3"] = "33-20e3",
	["4"] = "34-20e3",
	["5"] = "35-20e3",
	["6"] = "36-20e3",
	["7"] = "37-20e3",
	["8"] = "38-20e3",
	["9"] = "39-20e3"
}

file.CreateDir("tfil")

local Emoji = {}
Emoji.Index = (file.Read("tfil/emoji.txt") or "[]" ):JSONDecode()
Emoji.LegacyIndex = {}

function Emoji.GetRandom()
	return table.Random(Emoji.Index)
end

function Emoji.Get(name)
	if not file.Exists( "tfil/emoji.txt", "DATA" ) then return end
	return Emoji.Index[name] or Emoji.Index[tonumber( name )]
end

function Emoji.ParseNumber( num )
	local tab = {}
	local x = tostring( num )
	for i = 1, # x do
		tab[ #tab + 1 ] = Numbers[ x:sub( i, i ) ]
	end
	return tab
end

function Emoji.BuildPanel()
	local e = InitializePanel("EmojiPanel", "DFrame")
	e:SetSize(ScrW() * 0.8, ScrH() * 0.8)
	e:SetTitle("Emoji Index")
	e:Center()
	e:MakePopup()
	local c = e:Add("DTextEntry")
	c:Dock(TOP)
	c:SetUpdateOnType(true)
	c:SetText("Search")
	local s = e:Add("DScrollPanel")
	s:Dock(FILL)
	local i = s:Add("DIconLayout")
	i:Dock(FILL)
	local edge = (ScrH() * 0.01):ceil()
	local color = Color(70, 70, 70)
	i:SetSpaceX(edge / 2)
	i:SetSpaceY(edge / 2)

	local function populate(a)
		i:RemoveChildren()


		for k, v in SortedPairsByValue(Emoji.Index) do
			if not a or tostring( k ):find(a) then
				local x = i:Add("DButton")
				x:SetText""
				x:SetSize(ScrW() / 17, ScrH() / 7)
				x.DoClick = function( )
					SetClipboardText( k )
				end
				x.Paint = function(s, w, h)
					draw.RoundedBox(0, 0, 0, w, h, color)
					draw.SimpleText(k, "ChatFont", edge, h - FontFunctions.GetTall("ChatFont") - edge)
					draw.WebImage( v , edge, edge, w - edge * 2, w - edge * 2, nil, s.Hovered and math.sin(CurTime())*15 or 0, true )
				end
			end
		end
	end

	populate()

	c.DoClick = function(s)
		if s:GetValue() == "Search" then
			s:SetValue("")
		end
	end

	c.OnValueChange = function(s, v)
		populate(v ~= "" and v ~= "Search" and v or nil)
	end
end


hook.RunOnce("PreDrawHUD", function()
	if not file.Exists("tfil/emoji.txt", "DATA") then
		local fileof = file.Read( "tfil/emojidata.txt" ):gsub("\r", "" )
		local ftab = {}
		local ltab = {}
		local tab = fileof:Split("\n")
		for item in Values( tab ) do
			ftab[ tostring( item:gsub( ".+72x72/", "" ):gsub(".png", "" ) ) ] = item
			table.insert( ltab, item )
		end
		file.Write("tfil/emoji.txt", util.TableToJSON( ftab ))
		Emoji.Index = (file.Read("tfil/emoji.txt") or "[]" ):JSONDecode()
	else
		Emoji.Index = (file.Read("tfil/emoji.txt") or "[]" ):JSONDecode()
	end
end)

_G.Emoji = Emoji

concommand.Add("emoji_index", Emoji.BuildPanel )
