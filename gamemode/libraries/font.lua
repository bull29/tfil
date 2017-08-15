local FontFunctions = {}
local CurrentFont = "ChatFont"
local TemporaryFonts = {}
local GeneratedFonts = {}

function FontFunctions.SetActiveFont(font)
	CurrentFont = font
end

function FontFunctions.GetWide(text, font)
	CurrentFont = font or CurrentFont
	surface.SetFont(CurrentFont)

	return (surface.GetTextSize(text))
end

function FontFunctions.GetTall(text, font)
	CurrentFont = font or CurrentFont
	surface.SetFont(CurrentFont)
	local _, h = surface.GetTextSize(text)

	return h
end

function FontFunctions.GetSize(text, font)
	CurrentFont = font or CurrentFont
	surface.SetFont(CurrentFont)

	return surface.GetTextSize(text)
end

function FontFunctions.GetDesiredHeight(text, width, font )
	CurrentFont = font or CurrentFont
	return width * FontFunctions.GetTall(text, CurrentFont) / FontFunctions.GetWide(text, CurrentFont)
end

function FontFunctions.GenerateFont(text, width, font, maxheight )
	if GeneratedFonts[ text .. width .. font ] then
		return GeneratedFonts[ text .. width .. font ]
	end

	if not TemporaryFonts[ font ] then
		surface.CreateFont( "temporary_font_" .. font, {
			font = font
		})
		TemporaryFonts[ font ] = "temporary_font_" .. font
	end

	local size = FontFunctions.GetDesiredHeight(text, width, TemporaryFonts[ font ] )

	surface.CreateFont("lava_generated_font_" .. width .. "_" .. font:lower(), {
		font = font,
		size = size * ( ( maxheight and maxheight < size and maxheight/size ) or 0)
	})

	GeneratedFonts[ text .. width .. font ] = "lava_generated_font_" .. width .. "_" .. font:lower()
	return GeneratedFonts[ text .. width .. font ]
end

_G.FontFunctions = FontFunctions