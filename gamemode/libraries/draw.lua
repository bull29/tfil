--[[
    A Simple Garry's mod drawing library
    Copyright (C) 2016 Bull [STEAM_0:0:42437032] [76561198045139792]
    Freely acquirable at https://github.com/bull29/b_draw-lib
    You can use this anywhere for any purpose as long as you acredit the work to the original author with this notice.
    Optionally, if you choose to use this within your own software, it would be much appreciated if you could inform me of it.
    I love to see what people have done with my code! :)
]]--

if SERVER then return end

file.CreateDir("downloaded_assets")

local exists = file.Exists
local write = file.Write
local fetch = http.Fetch
local white = Color( 255, 255, 255 )
local surface = surface
local crc = util.CRC
local _error = Material("error")
local math = math
local mats = {}
local fetchedavatars = {}

local function fetch_asset(url, param )
	if not url then return _error end

	if mats[url] then
		return mats[url]
	end

	local crc = crc(url)

	if exists("downloaded_assets/" .. crc .. ".png", "DATA") then
		mats[url] = Material("data/downloaded_assets/" .. crc .. ".png", param )

		return mats[url]
	end

	mats[url] = _error

	fetch(url, function(data)
		write("downloaded_assets/" .. crc .. ".png", data)
		mats[url] = Material("data/downloaded_assets/" .. crc .. ".png", param )
	end)

	return mats[url]
end

local function fetchAvatarAsset( id64, size )
	id64 = id64 or "BOT"
	size = size == "medium" and "medium" or size == "small" and "" or size == "large" and "full" or ""

	if fetchedavatars[ id64 .. " " .. size ] then
		return fetchedavatars[ id64 .. " " .. size ]
	end

	fetchedavatars[ id64 .. " " .. size ] = id64 == "BOT" and "http://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/09/09962d76e5bd5b91a94ee76b07518ac6e240057a_full.jpg" or "http://i.imgur.com/uaYpdq7.png"
	if id64 == "BOT" then return end
	fetch("http://steamcommunity.com/profiles/" .. id64 .. "/?xml=1",function( body )
		local link = body:match("http://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/.-jpg")
		if not link then return end

		fetchedavatars[ id64 .. " " .. size ] = link:Replace( ".jpg", ( size ~= "" and "_" .. size or "") .. ".jpg")
	end)
end

function draw.WebImage( url, x, y, width, height, color, angle, cornerorigin )
	color = color or white

	surface.SetDrawColor( color.r, color.g, color.b, color.a )
	surface.SetMaterial( fetch_asset( url ) )
	if not angle then
		surface.DrawTexturedRect( x, y, width, height)
	else
		if not cornerorigin then
			surface.DrawTexturedRectRotated( x, y, width, height, angle )
		else
			surface.DrawTexturedRectRotated( x + width / 2, y + height / 2, width, height, angle )
		end
	end
end

function draw.SeamlessWebImage( url, parentwidth, parentheight, xrep, yrep, color, xo, yo )
	color = color or white
	xo, yo = xo or 0, yo or 0
	local xiwx, yihy = math.ceil( parentwidth/xrep ), math.ceil( parentheight/yrep )
	for x = 0, xrep - 1 do
		for y = 0, yrep - 1 do
			draw.WebImage( url, xo + x*xiwx, yo + y*yihy, xiwx, yihy, color )
		end
	end
end

function draw.SteamAvatar( avatar, res, x, y, width, height, color, ang, corner )
	draw.WebImage( fetchAvatarAsset( avatar, res ), x, y, width, height, color, ang, corner )
end

function draw.Rect( x, y, w, h, col, mat, ang, corigin )
	col = col or white

	if not mat then
		draw.NoTexture()
	else
		if not mats[ mat ] then
			mats[ mat ] = Material( mat )
		end
		surface.SetMaterial( mats[ mat ] )
	end

	surface.SetDrawColor( col )

	if ang then
		surface.DrawTexturedRectRotated( x - ( corigin and w/2 or 0 ), y - ( corigin and h/2 or 0 ), w, h, ang )
	else
		surface.DrawTexturedRect( x - ( corigin and w/2 or 0 ), y - ( corigin and h/2 or 0 ), w, h )
	end
end

draw.fetch_asset = fetch_asset