GM.Name = "The Floor is Lava"
GM.Author = "Bull [76561198045139792]"
GM.Email = "thebull2140@gmail.com"
GM.Website = "https://github.com/bull29"

local acl = AddCSLuaFile
local inc = include
local sp = SortedPairs
local ff = file.Find
local string = string
local hook = hook

function IncludeDirectory(dir, cl, sv )
	cl, sv = cl or "cl_", sv or "sv_"
	local files, folders = ff(dir .. "/*", "LUA")

	for _, file in sp(files) do
		if hook.Call( "Lava.ShouldLoadFile", nil, dir, file ) == false then return end

		if string.StartWith( file, cl ) then
			acl( dir .. "/" .. file )
			if CLIENT then
				inc( dir .. "/" .. file )
			end
		elseif string.StartWith( file, sv ) then
			inc( dir .. "/" .. file )
		else
			acl( dir .. "/" .. file )
			inc( dir .. "/" .. file )
		end
	end

	for _, folder in sp(folders) do
		IncludeDirectory(dir .. "/" .. folder, cl, sv )
	end
end

lang_data = {}
lang = {}

IncludeDirectory("tfil/gamemode/language")
hook.Call("Lava.PostInitLanguageFiles")

IncludeDirectory("tfil/gamemode/libraries")
hook.Call("Lava.PostInitLibraryFiles")

IncludeDirectory("tfil/gamemode/core")
hook.Call("Lava.PostInitGamemodeFiles")

IncludeDirectory("tfil/gamemode/modules")
hook.Call("Lava.PostInitModuleFiles")