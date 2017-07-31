local draw = draw
local pColor = pColor

local function CreateAbilitiesPanel()
	local x = InitializePanel("LavaAbiltiesSelector", "DPanel")
	x:SetSize(ScrW() / 3, ScrH() * 0.87)
	x:MakePopup()
	x:Center()

	x.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, pColor() - 100)
	end

	local m = x:Add("DPanel")
	m:Dock(FILL)
	m:DockMargin(WebElements.Edge, WebElements.Edge, WebElements.Edge, WebElements.Edge)

	m.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, pColor())
	end

	local s = m:Add"lava_scroller"
	s:Dock(FILL)
	s:SetHeight(ScrH() / 2)

	local r = x:Add("RichText")
	r:Dock(BOTTOM)
	r:DockMargin( WebElements.Edge,WebElements.Edge,WebElements.Edge * 5,WebElements.Edge)
	r:SetVerticalScrollbarEnabled(false)
	r:SetMouseInputEnabled(false)
	r:SetTall(ScrH() / 5)

	r.Paint = function(s, w, h)
		s.m_FontName = "lava_abilities_desc"
		s:SetFGColor(color_white)
		s:SetFontInternal("lava_abilities_desc")
		s.Paint = nil
	end

	for k, v in SortedPairs(Abilities.Skills) do
		local c = s:Add("DButton")
		c:Dock(TOP)
		c:SetTall(ScrH() / 10)
		c:SetText(k)
		c:SetFont("lava_abilities_header")
		c:SetContentAlignment(4)
		c:SetTextInset(ScrH() / 10, 0)
		c:SetTextColor(color_white)
		c:GenerateColorShift("HoverVar", pColor():Alpha(50), pColor():Alpha(200) + 50, 255 * 3)
		c:MakeBorder(WebElements.Edge / 3, pColor() - 100)
		local text = v[1]:gsub("\t", "" ):gsub("\n", " "):gsub("%s%s", " ")

		c.Paint = function(s, w, h)
			draw.RoundedBox(0, 0, 0, w, h, s.HoverVar)
			draw.WebImage(Emoji.Get(v[2]), h / 10, h / 10, h - h / 5, h - h / 5, nil, s.Hovered and CurTime():sin() * 50, true)

			if s.Hovered and r.Val ~= text then
				r.Val = text
				r:SetText("\t" .. text)
			end
		end

		c.DoClick = function()
			chat.AddText(pColor(), "You've equipped the " .. k .. " ability!" .. (Rounds.IsState("Preround") and "" or " Your selection will take place the next time you spawn."))
			net.Start("Lava.SelectAbility")
			net.WriteString(k)
			net.SendToServer()
		end
	end

	return x
end

hook.Add("Lava.PopulateWidgetMenu", "CreateAbilitiesWidget", function(Context)
	Context.NewWidget("Abilities", 733, CreateAbilitiesPanel)
end)