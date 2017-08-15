local FontFunctions = {}
local CurrentFont = "ChatFont"
local TemporaryFonts = {}
local GeneratedFonts = {}
local crc = util.CRC

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
	return width * FontFunctions.GetTall(text, CurrentFont) / FontFunctions.GetWide(text)
end

function FontFunctions.GenerateFont(text, width, font, maxheight )
	if GeneratedFonts[ text .. width .. font ] then
		return GeneratedFonts[ text .. width .. font ]
	end

	if not TemporaryFonts[ font ] then
		surface.CreateFont( "temporary_font_" .. font, {
			font = font,
			size = 16
		})
		TemporaryFonts[ font ] = "temporary_font_" .. font
	end

	surface.CreateFont("lava_generated_font_" ..  crc( text .. width .. font ), {
		font = font,
		size = FontFunctions.GetDesiredHeight(text, width, TemporaryFonts[ font ] ):min( maxheight or 10000 ):floor()
	})

	GeneratedFonts[ text .. width .. font ] = "lava_generated_font_" .. crc( text .. width .. font )
	return GeneratedFonts[ text .. width .. font ]
end

_G.FontFunctions = FontFunctions