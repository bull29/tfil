file.CreateDir("tfil")

local tostring = tostring
local Emoji = {}
Emoji.Index = (file.Read("tfil/emoji.txt") or "[]" ):JSONDecode()
local Numbers = {
	["0"] = 2645,
	["1"] = 2648,
	["2"] = 2649,
	["3"] = 2652,
	["4"] = 2653,
	["5"] = 2654,
	["6"] = 2655,
	["7"] = 2656,
	["8"] = 2657,
	["9"] = 2658
}

hook.RunOnce("HUDPaint", function()
	if true or not file.Exists("tfil/emoji.txt", "DATA") then
		http.Fetch("http://twitter.github.io/twemoji/2/test/preview.html", function(body)
			local tab = {}
			local t = body:Split("<li>&#x")

			for i = 2, #t do
				table.insert(tab, "https://twemoji.maxcdn.com/2/72x72/" .. (t[i]:Trim():Split(";</li>")[1]:lower():gsub(";&#x", "-")) .. ".png")
			end

			file.Write("tfil/emoji.txt", util.TableToJSON(tab))
			Emoji.Index = (file.Read("tfil/emoji.txt") or "[]" ):JSONDecode()
		end)
	else
		Emoji.Index = (file.Read("tfil/emoji.txt") or "[]" ):JSONDecode()
	end
end)

function Emoji.GetRandom()
	return table.Random(Emoji.Index)
end

function Emoji.Get(name)
	return Emoji.Index[name]
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


		for k, v in SortedPairs(Emoji.Index) do
			if not a or tostring( k ):find(a) then
				local x = i:Add("DPanel")
				x:SetSize(ScrW() / 17, ScrH() / 7)

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

_G.Emoji = Emoji


concommand.Add("emoji_index", Emoji.BuildPanel )