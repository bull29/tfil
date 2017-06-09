local acl = AddCSLuaFile
local inc = include
local sp = SortedPairs
local ff = file.Find

Lava = {}
Lava.Files = {}

function IncludeDirectory(dir, filter)
	filter = filter or function() return nil end
	local state
	local files, folders = ff(dir .. "/*", "LUA")

	for _, file in sp(files) do
		state = filter(file)

		if state == "skip" then
			continue
		elseif not state then
			inc(dir .. "/" .. file)
			acl(dir .. "/" .. file )
		elseif state == "CLIENT" then
			acl(dir .. "/" .. file )
			if CLIENT then
				inc(dir .. "/" .. file)
			end
		elseif state == "SERVER" and SERVER then
			inc(dir .. "/" .. file)
		end
	end

	for _, folder in sp(folders) do
		IncludeDirectory(dir .. "/" .. folder, filter)
	end
end

IncludeDirectory("Lava/gamemode/__libraries")

for Hook in pairs( hook.GetTable() ) do
	hook.Clean( Hook )
end

IncludeDirectory("Lava/gamemode/__init")
IncludeDirectory("Lava/gamemode/__thirdparty")
IncludeDirectory("Lava/gamemode/__modules", function( file )
	if file:StartWith("&") then
		return
	elseif file:EndsWith(";_s.lua") then
		return "SERVER"
	elseif file:EndsWith(";_c.lua") then
		return "CLIENT"
	end
end)